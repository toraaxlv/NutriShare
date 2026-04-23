from datetime import date, timedelta
from collections import defaultdict
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.food_log import FoodLog
from app.models.insight import UserInsight
from app.services.nutrition_service import calculate_targets

# Toleransi: dianggap "lebih" jika >115% target, "kurang" jika <85% target
OVER_THRESHOLD  = 1.15
UNDER_THRESHOLD = 0.85
MIN_STREAK_DAYS = 3      # minimal hari berturut-turut untuk deteksi streak
MIN_DOW_WEEKS   = 3      # minimal kejadian hari-yang-sama untuk deteksi pola mingguan
LOOKBACK_DAYS   = 30     # seberapa jauh ke belakang kita lihat

HARI = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]

NUTRIENT_LABEL = {
    "calories":  "kalori",
    "protein_g": "protein",
    "fat_g":     "lemak",
    "carbs_g":   "karbohidrat",
}


# ---------------------------------------------------------------------------
# Ambil ringkasan harian
# ---------------------------------------------------------------------------

def _get_daily_summaries(user_id, db: Session, days: int = LOOKBACK_DAYS) -> list[dict]:
    """Kembalikan list dict per hari dengan total setiap makro."""
    since = date.today() - timedelta(days=days)
    rows = (
        db.query(
            FoodLog.log_date,
            func.sum(FoodLog.calories).label("calories"),
            func.sum(FoodLog.protein_g).label("protein_g"),
            func.sum(FoodLog.fat_g).label("fat_g"),
            func.sum(FoodLog.carbs_g).label("carbs_g"),
        )
        .filter(FoodLog.user_id == user_id, FoodLog.log_date >= since)
        .group_by(FoodLog.log_date)
        .order_by(FoodLog.log_date)
        .all()
    )
    return [
        {
            "date":      r.log_date,
            "calories":  float(r.calories  or 0),
            "protein_g": float(r.protein_g or 0),
            "fat_g":     float(r.fat_g     or 0),
            "carbs_g":   float(r.carbs_g   or 0),
        }
        for r in rows
    ]


# ---------------------------------------------------------------------------
# Deteksi pola
# ---------------------------------------------------------------------------

def _detect_nutrient_streak(summaries: list[dict], targets: dict) -> dict | None:
    """
    Cari nutrisi yang melebihi atau di bawah target selama MIN_STREAK_DAYS
    hari berturut-turut (dari hari-hari terbaru).
    Kembalikan info streak terpanjang yang relevan, atau None.
    """
    if len(summaries) < MIN_STREAK_DAYS:
        return None

    # Urutkan terbaru dulu untuk mencari streak yang sedang berjalan
    sorted_days = sorted(summaries, key=lambda x: x["date"], reverse=True)

    for nutrient, target_val in targets.items():
        if not target_val:
            continue

        streak_over  = 0
        streak_under = 0

        for day in sorted_days:
            actual = day[nutrient]
            if actual > target_val * OVER_THRESHOLD:
                streak_over  += 1
                streak_under  = 0
            elif actual < target_val * UNDER_THRESHOLD:
                streak_under += 1
                streak_over   = 0
            else:
                break  # streak terputus

        if streak_over >= MIN_STREAK_DAYS:
            return {"nutrient": nutrient, "direction": "over",  "days": streak_over,  "target": target_val}
        if streak_under >= MIN_STREAK_DAYS:
            return {"nutrient": nutrient, "direction": "under", "days": streak_under, "target": target_val}

    return None


def _detect_day_of_week_pattern(summaries: list[dict], targets: dict) -> dict | None:
    """
    Cari hari dalam seminggu yang secara konsisten surplus atau deficit kalori.
    Butuh minimal MIN_DOW_WEEKS kejadian hari yang sama.
    """
    if not targets.get("calories"):
        return None

    cal_target = targets["calories"]
    dow_data: dict[int, list[float]] = defaultdict(list)

    for day in summaries:
        dow = day["date"].weekday()  # 0=Senin ... 6=Minggu
        dow_data[dow].append(day["calories"])

    for dow, cal_list in dow_data.items():
        if len(cal_list) < MIN_DOW_WEEKS:
            continue

        avg = sum(cal_list) / len(cal_list)
        if avg > cal_target * OVER_THRESHOLD:
            return {"dow": dow, "direction": "surplus", "avg_cal": round(avg), "target": cal_target, "count": len(cal_list)}
        if avg < cal_target * UNDER_THRESHOLD:
            return {"dow": dow, "direction": "deficit", "avg_cal": round(avg), "target": cal_target, "count": len(cal_list)}

    return None


def _detect_overall_trend(summaries: list[dict], targets: dict) -> dict | None:
    """Rata-rata kalori 7 hari terakhir vs target."""
    if not targets.get("calories"):
        return None

    recent = sorted(summaries, key=lambda x: x["date"], reverse=True)[:7]
    if len(recent) < 3:
        return None

    avg_cal = sum(d["calories"] for d in recent) / len(recent)
    cal_target = targets["calories"]
    diff = avg_cal - cal_target

    if abs(diff) < cal_target * 0.05:  # dalam 5% target → tidak perlu disorot
        return None

    return {
        "avg_cal":   round(avg_cal),
        "target":    cal_target,
        "diff":      round(diff),
        "direction": "surplus" if diff > 0 else "deficit",
        "days":      len(recent),
    }


# ---------------------------------------------------------------------------
# Template teks
# ---------------------------------------------------------------------------

def _build_insight_text(streak, dow_pattern, overall_trend, targets: dict, total_logged_days: int) -> str:
    paragraphs = []

    # --- Paragraf 1: streak nutrisi atau tren kalori keseluruhan ---
    if streak:
        nutrient_id  = streak["nutrient"]
        label        = NUTRIENT_LABEL.get(nutrient_id, nutrient_id)
        days         = streak["days"]
        direction    = streak["direction"]
        target_val   = round(streak["target"])

        if direction == "over":
            p1 = (
                f"Dalam {days} hari terakhir berturut-turut, asupan {label} kamu "
                f"terus melebihi target harian ({target_val}{'kkal' if nutrient_id == 'calories' else 'g'}). "
                f"Kelebihan {label} yang konsisten bisa menghambat progress kamu. "
                f"Coba perhatikan porsi makanan tinggi {label} di setiap makan."
            )
        else:
            p1 = (
                f"Dalam {days} hari terakhir berturut-turut, asupan {label} kamu "
                f"terus di bawah target ({target_val}{'kkal' if nutrient_id == 'calories' else 'g'}). "
                f"Kekurangan {label} yang berkelanjutan dapat memengaruhi energi dan pemulihan tubuhmu. "
                f"Pertimbangkan untuk menambah sumber {label} di menu harianmu."
            )
        paragraphs.append(p1)

    elif overall_trend:
        avg  = overall_trend["avg_cal"]
        tgt  = round(overall_trend["target"])
        diff = abs(overall_trend["diff"])
        days = overall_trend["days"]

        if overall_trend["direction"] == "surplus":
            p1 = (
                f"Selama {days} hari terakhir, rata-rata kalori harianmu adalah {avg} kkal — "
                f"sekitar {diff} kkal di atas target ({tgt} kkal). "
                f"Surplus kecil itu wajar, tapi kalau tujuanmu adalah defisit, "
                f"coba kurangi satu porsi camilan atau minuman manis per hari."
            )
        else:
            p1 = (
                f"Selama {days} hari terakhir, rata-rata kalori harianmu adalah {avg} kkal — "
                f"sekitar {diff} kkal di bawah target ({tgt} kkal). "
                f"Defisit terlalu dalam bisa membuatmu mudah lapar dan kehilangan massa otot. "
                f"Pastikan kamu makan cukup untuk mendukung aktivitasmu."
            )
        paragraphs.append(p1)

    elif total_logged_days < MIN_STREAK_DAYS:
        paragraphs.append(
            f"Kamu baru memulai perjalanan nutrisimu — terus catat makananmu setiap hari! "
            f"Setelah {MIN_STREAK_DAYS} hari logging, aku bisa mulai mengenali pola makanmu "
            f"dan memberikan saran yang lebih personal."
        )

    # --- Paragraf 2: pola hari-dalam-seminggu ---
    if dow_pattern:
        hari_nama  = HARI[dow_pattern["dow"]]
        avg_cal    = dow_pattern["avg_cal"]
        tgt        = round(dow_pattern["target"])
        count      = dow_pattern["count"]
        direction  = dow_pattern["direction"]

        if direction == "surplus":
            p2 = (
                f"Ada pola menarik: setiap hari {hari_nama} (dari {count} minggu terakhir), "
                f"rata-rata kalorimu mencapai {avg_cal} kkal — jauh di atas target {tgt} kkal. "
                f"Ini bisa jadi kebiasaan makan di luar atau acara sosial. "
                f"Sekarang kamu tahu polanya, kamu bisa lebih siap di hari {hari_nama} berikutnya."
            )
        else:
            p2 = (
                f"Menariknya, setiap hari {hari_nama} (dari {count} minggu terakhir), "
                f"asupan kalorimu rata-rata hanya {avg_cal} kkal — di bawah target {tgt} kkal. "
                f"Mungkin kamu lebih sibuk atau melewatkan makan di hari itu. "
                f"Coba siapkan meal prep atau snack sehat untuk hari {hari_nama}."
            )
        paragraphs.append(p2)

    # Fallback jika tidak ada pola apapun
    if not paragraphs:
        paragraphs.append(
            "Pola makanmu dalam beberapa hari terakhir terlihat cukup stabil. "
            "Terus jaga konsistensi logging-mu agar aku bisa memberikan insight yang lebih detail!"
        )

    return " ".join(paragraphs)


# ---------------------------------------------------------------------------
# Invalidasi cache
# ---------------------------------------------------------------------------

def invalidate_today_insight(user_id, db: Session) -> None:
    """Hapus cache insight hari ini agar di-regenerate saat diminta berikutnya."""
    db.query(UserInsight).filter(
        UserInsight.user_id == user_id,
        UserInsight.generated_date == date.today(),
    ).delete()
    db.commit()


# ---------------------------------------------------------------------------
# Entry point utama
# ---------------------------------------------------------------------------

def get_or_generate_insight(user, db: Session) -> str:
    """
    Kembalikan insight hari ini. Jika belum ada, generate dan simpan ke DB.
    """
    today = date.today()

    # Cek apakah sudah ada insight hari ini
    existing = (
        db.query(UserInsight)
        .filter(UserInsight.user_id == user.id, UserInsight.generated_date == today)
        .first()
    )
    if existing:
        return existing.insight_text

    # Hitung target user
    targets = calculate_targets(user) or {}

    # Ambil data log
    summaries = _get_daily_summaries(user.id, db)
    total_logged_days = len(summaries)

    # Deteksi pola
    streak      = _detect_nutrient_streak(summaries, targets)
    dow_pattern = _detect_day_of_week_pattern(summaries, targets)
    overall     = _detect_overall_trend(summaries, targets)

    # Generate teks
    text = _build_insight_text(streak, dow_pattern, overall, targets, total_logged_days)

    # Simpan ke DB
    insight = UserInsight(
        user_id=user.id,
        generated_date=today,
        insight_text=text,
    )
    db.add(insight)
    db.commit()

    return text
