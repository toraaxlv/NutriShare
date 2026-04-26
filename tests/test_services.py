"""
White Box Unit Tests — NutriShare Backend Services
Jalankan: pytest tests/test_services.py -v
"""
import pytest
from datetime import date, timedelta
from types import SimpleNamespace
from app.services.auth_service import hash_password, verify_password, create_access_token
from app.services.nutrition_service import calculate_targets, calculate_forecast
from app.services.insight_service import (
    _detect_nutrient_streak,
    _detect_overall_trend,
    _build_insight_text,
)


# ── Helpers ───────────────────────────────────────────────────────────────────

def _user(**kwargs):
    defaults = dict(
        gender="male",
        date_of_birth=date(1995, 1, 1),
        weight_kg=70.0,
        height_cm=175.0,
        activity_level="sedentary",
        goal="lose",
        goal_rate_kg_per_week=0.5,
        target_weight_kg=65.0,
        custom_exercise_calories=None,
    )
    defaults.update(kwargs)
    return SimpleNamespace(**defaults)


def _summary(d, calories, protein_g=50, fat_g=30, carbs_g=100):
    return {"date": d, "calories": float(calories), "protein_g": float(protein_g),
            "fat_g": float(fat_g), "carbs_g": float(carbs_g)}


# ── Auth Service ──────────────────────────────────────────────────────────────

class TestAuthService:
    def test_hash_password_bukan_plaintext(self):
        h = hash_password("secret123")
        assert h != "secret123"
        assert h.startswith("$2b$")

    def test_verify_password_benar(self):
        h = hash_password("secret123")
        assert verify_password("secret123", h) is True

    def test_verify_password_salah(self):
        h = hash_password("secret123")
        assert verify_password("wrong", h) is False

    def test_create_access_token_berisi_sub(self):
        from jose import jwt
        from app.config import settings
        token = create_access_token({"sub": "user-123"})
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        assert payload["sub"] == "user-123"

    def test_create_access_token_ada_expiry(self):
        from jose import jwt
        from app.config import settings
        token = create_access_token({"sub": "user-123"})
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        assert "exp" in payload


# ── Nutrition Service ─────────────────────────────────────────────────────────

class TestCalculateTargets:
    def test_profil_lengkap_return_dict(self):
        result = calculate_targets(_user())
        assert result is not None
        assert "calories" in result

    def test_profil_tidak_lengkap_return_none(self):
        result = calculate_targets(_user(gender=None))
        assert result is None

    def test_goal_lose_kalori_lebih_rendah_dari_tdee(self):
        result = calculate_targets(_user(goal="lose", goal_rate_kg_per_week=0.5))
        assert result["calories"] < result["tdee"]

    def test_goal_gain_kalori_lebih_tinggi_dari_tdee(self):
        result = calculate_targets(_user(goal="gain", goal_rate_kg_per_week=0.5))
        assert result["calories"] > result["tdee"]

    def test_goal_maintain_kalori_sama_dengan_tdee(self):
        result = calculate_targets(_user(goal="maintain", goal_rate_kg_per_week=0))
        assert result["calories"] == result["tdee"]

    def test_floor_1200_kkal(self):
        # User ekstrem: sangat kecil + target turun cepat
        u = _user(weight_kg=40.0, height_cm=150.0, goal="lose",
                  goal_rate_kg_per_week=2.0, activity_level="no_activity")
        result = calculate_targets(u)
        assert result["calories"] >= 1200

    def test_aktivitas_custom_pakai_custom_exercise_calories(self):
        u = _user(activity_level="custom", custom_exercise_calories=500)
        result = calculate_targets(u)
        # TDEE = BMR + 500, bukan BMR × multiplier
        assert result is not None
        assert result["tdee"] > 0

    def test_gender_female_bmr_lebih_rendah(self):
        male   = calculate_targets(_user(gender="male"))
        female = calculate_targets(_user(gender="female"))
        assert male["bmr"] > female["bmr"]


class TestCalculateForecast:
    def test_goal_maintain_return_none(self):
        assert calculate_forecast(_user(goal="maintain")) is None

    def test_forecast_berisi_forecast_date(self):
        result = calculate_forecast(_user())
        assert result is not None
        assert "forecast_date" in result

    def test_weeks_needed_proporsional(self):
        result = calculate_forecast(_user(weight_kg=70, target_weight_kg=65,
                                         goal_rate_kg_per_week=0.5))
        assert result["weeks_needed"] == pytest.approx(10.0, rel=0.01)


# ── Insight Service ───────────────────────────────────────────────────────────

class TestDetectNutrientStreak:
    def _targets(self): return {"calories": 2000, "protein_g": 140, "fat_g": 55, "carbs_g": 250}

    def test_streak_over_terdeteksi(self):
        today = date.today()
        summaries = [_summary(today - timedelta(days=i), 2400) for i in range(4)]
        result = _detect_nutrient_streak(summaries, self._targets())
        assert result is not None
        assert result["direction"] == "over"
        assert result["days"] >= 3

    def test_streak_under_terdeteksi(self):
        today = date.today()
        summaries = [_summary(today - timedelta(days=i), 1500) for i in range(4)]
        result = _detect_nutrient_streak(summaries, self._targets())
        assert result is not None
        assert result["direction"] == "under"

    def test_kurang_dari_3_hari_return_none(self):
        today = date.today()
        summaries = [_summary(today - timedelta(days=i), 2400) for i in range(2)]
        result = _detect_nutrient_streak(summaries, self._targets())
        assert result is None

    def test_dalam_range_return_none(self):
        today = date.today()
        # semua nilai dalam range 85–115% dari target masing-masing
        summaries = [_summary(today - timedelta(days=i), 2000, protein_g=140, fat_g=55, carbs_g=250) for i in range(5)]
        result = _detect_nutrient_streak(summaries, self._targets())
        assert result is None


class TestDetectOverallTrend:
    def _targets(self): return {"calories": 2000}

    def test_surplus_terdeteksi(self):
        today = date.today()
        summaries = [_summary(today - timedelta(days=i), 2400) for i in range(5)]
        result = _detect_overall_trend(summaries, self._targets())
        assert result is not None
        assert result["direction"] == "surplus"

    def test_deficit_terdeteksi(self):
        today = date.today()
        summaries = [_summary(today - timedelta(days=i), 1500) for i in range(5)]
        result = _detect_overall_trend(summaries, self._targets())
        assert result is not None
        assert result["direction"] == "deficit"

    def test_dalam_5_persen_return_none(self):
        today = date.today()
        summaries = [_summary(today - timedelta(days=i), 2050) for i in range(5)]
        result = _detect_overall_trend(summaries, self._targets())
        assert result is None

    def test_kurang_dari_3_hari_return_none(self):
        today = date.today()
        summaries = [_summary(today - timedelta(days=i), 2400) for i in range(2)]
        result = _detect_overall_trend(summaries, self._targets())
        assert result is None


class TestBuildInsightText:
    def test_fallback_jika_tidak_ada_pola(self):
        text = _build_insight_text(None, None, None, {}, 10)
        assert "stabil" in text.lower()

    def test_mendorong_logging_jika_data_kurang(self):
        text = _build_insight_text(None, None, None, {}, 1)
        assert "catat" in text.lower() or "logging" in text.lower()

    def test_streak_over_muncul_di_teks(self):
        streak = {"nutrient": "calories", "direction": "over", "days": 4, "target": 2000}
        text = _build_insight_text(streak, None, None, {"calories": 2000}, 10)
        assert "melebihi" in text.lower()

    def test_streak_under_muncul_di_teks(self):
        streak = {"nutrient": "calories", "direction": "under", "days": 4, "target": 2000}
        text = _build_insight_text(streak, None, None, {"calories": 2000}, 10)
        assert "di bawah" in text.lower()
