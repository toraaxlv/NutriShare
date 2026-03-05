ACTIVITY_MULTIPLIERS = {
    "sedentary":   1.2,
    "light":       1.375,
    "moderate":    1.55,
    "active":      1.725,
    "very_active": 1.9,
}

def calculate_targets(user) -> dict:
    """Hitung kalori & makro harian menggunakan formula Mifflin-St Jeor."""
    if not all([user.weight_kg, user.height_cm, user.age]):
        return None

    # BMR (asumsi male, bisa dikembangkan dengan field sex)
    bmr = 10 * user.weight_kg + 6.25 * user.height_cm - 5 * user.age + 5

    multiplier = ACTIVITY_MULTIPLIERS.get(user.activity_level, 1.2)
    tdee = bmr * multiplier

    goal_adjustment = {"lose": -500, "maintain": 0, "gain": 300}
    calories = tdee + goal_adjustment.get(user.goal, 0)

    return {
        "calories":   round(calories),
        "protein_g":  round(user.weight_kg * 2.0),           # 2g per kg
        "fat_g":      round(calories * 0.25 / 9),            # 25% dari kalori
        "carbs_g":    round((calories - (user.weight_kg * 2.0 * 4) - (calories * 0.25)) / 4),
    }