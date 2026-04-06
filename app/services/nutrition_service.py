from datetime import date, timedelta

ACTIVITY_MULTIPLIERS = {
    "no_activity": 1.0,
    "sedentary":   1.2,
    "light":       1.375,
    "moderate":    1.55,
    "very_active": 1.9,
    # 'custom' ditangani terpisah menggunakan custom_exercise_calories
}

# Kalori per kg per minggu (1 kg lemak ≈ 7700 kkal)
KCAL_PER_KG = 7700


def _calculate_age(date_of_birth: date) -> int:
    today = date.today()
    age = today.year - date_of_birth.year
    if (today.month, today.day) < (date_of_birth.month, date_of_birth.day):
        age -= 1
    return age


def calculate_targets(user) -> dict | None:
    """
    Hitung kalori & makro harian menggunakan formula Mifflin-St Jeor.
    Membutuhkan: gender, date_of_birth, weight_kg, height_cm, activity_level, goal.
    """
    required = [user.gender, user.date_of_birth, user.weight_kg, user.height_cm,
                user.activity_level, user.goal]
    if not all(required):
        return None

    age = _calculate_age(user.date_of_birth)

    # BMR — Mifflin-St Jeor
    bmr = 10 * user.weight_kg + 6.25 * user.height_cm - 5 * age
    bmr += 5 if user.gender == "male" else -161

    # TDEE
    if user.activity_level == "custom" and user.custom_exercise_calories:
        tdee = bmr + user.custom_exercise_calories
    else:
        multiplier = ACTIVITY_MULTIPLIERS.get(user.activity_level, 1.2)
        tdee = bmr * multiplier

    # Penyesuaian goal
    rate = user.goal_rate_kg_per_week or 0.0
    daily_adjustment = (KCAL_PER_KG * rate) / 7

    if user.goal == "lose":
        calories = tdee - daily_adjustment
    elif user.goal == "gain":
        calories = tdee + daily_adjustment
    else:  # maintain
        calories = tdee

    calories = max(calories, 1200)  # batas minimum aman

    protein_g = round(user.weight_kg * 2.0)          # 2g per kg berat badan
    fat_g     = round(calories * 0.25 / 9)           # 25% dari kalori
    carbs_g   = round((calories - protein_g * 4 - fat_g * 9) / 4)

    return {
        "calories":   round(calories),
        "protein_g":  protein_g,
        "fat_g":      fat_g,
        "carbs_g":    max(carbs_g, 0),
        "tdee":       round(tdee),
        "bmr":        round(bmr),
        "daily_surplus_deficit": round(calories - tdee),
    }


def calculate_forecast(user) -> dict | None:
    """
    Hitung perkiraan tanggal target berat tercapai.
    Hanya relevan jika goal adalah lose atau gain.
    """
    if not user.target_weight_kg or not user.weight_kg or not user.goal_rate_kg_per_week:
        return None
    if user.goal == "maintain":
        return None

    diff_kg = abs(user.target_weight_kg - user.weight_kg)
    if diff_kg < 0.1:
        return {"forecast_date": date.today().isoformat(), "weeks_needed": 0}

    weeks_needed = diff_kg / user.goal_rate_kg_per_week
    forecast_date = date.today() + timedelta(weeks=weeks_needed)

    return {
        "current_weight_kg": user.weight_kg,
        "target_weight_kg":  user.target_weight_kg,
        "diff_kg":           round(diff_kg, 2),
        "rate_kg_per_week":  user.goal_rate_kg_per_week,
        "weeks_needed":      round(weeks_needed, 1),
        "forecast_date":     forecast_date.isoformat(),
    }
