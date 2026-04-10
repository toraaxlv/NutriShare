class User {
  final String id;
  final String email;
  final String? username;
  final String? name;
  final String? gender;
  final String? dateOfBirth;
  final double? weightKg;
  final double? heightCm;
  final String? activityLevel;
  final double? customExerciseCalories;
  final String? goal;
  final double? targetWeightKg;
  final double? goalRateKgPerWeek;
  final int? waterTargetMl;

  User({
    required this.id,
    required this.email,
    this.username,
    this.name,
    this.gender,
    this.dateOfBirth,
    this.weightKg,
    this.heightCm,
    this.activityLevel,
    this.customExerciseCalories,
    this.goal,
    this.targetWeightKg,
    this.goalRateKgPerWeek,
    this.waterTargetMl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      name: json['name'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      weightKg: json['weight_kg']?.toDouble(),
      heightCm: json['height_cm']?.toDouble(),
      activityLevel: json['activity_level'],
      customExerciseCalories: json['custom_exercise_calories']?.toDouble(),
      goal: json['goal'],
      targetWeightKg: json['target_weight_kg']?.toDouble(),
      goalRateKgPerWeek: json['goal_rate_kg_per_week']?.toDouble(),
      waterTargetMl: json['water_target_ml'] as int?,
    );
  }
}
