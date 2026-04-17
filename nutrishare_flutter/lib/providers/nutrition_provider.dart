import 'package:flutter/material.dart';
import '../services/nutrition_service.dart';

class NutritionProvider extends ChangeNotifier {
  final NutritionService _svc = NutritionService();
  VoidCallback? onUnauthorized;

  NutritionProvider() {
    _svc.onUnauthorized = () => onUnauthorized?.call();
  }

  // ── Dashboard (Discover) ──────────────────────────────────────────────────
  bool isDashboardLoading = false;
  String? insight;
  Map<String, dynamic>? targets;
  Map<String, dynamic>? forecast;
  Map<String, dynamic>? todaySummary;
  int streak = 0;
  List<dynamic> weightHistory = [];
  List<dynamic> todayLogs = [];
  List<dynamic> dailyHistory = [];

  // ── Diary ─────────────────────────────────────────────────────────────────
  bool isDiaryLoading = false;
  List<dynamic> diaryLogs = [];
  Map<String, dynamic>? diarySummary;
  DateTime diaryDate = DateTime.now();

  // ── Water ─────────────────────────────────────────────────────────────────
  int waterMl = 0;
  int waterTargetMl = 2000;

  // ── Food search ───────────────────────────────────────────────────────────
  List<dynamic> foodSearchResults = [];
  bool isSearching = false;
  List<dynamic> customFoods = [];
  final Map<String, List<dynamic>> _searchCache = {};

  // ── Dashboard ─────────────────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    isDashboardLoading = true;
    notifyListeners();

    final today = _fmt(DateTime.now());

    // Wave 1: data utama — tampilkan dashboard secepat mungkin
    try {
      final results = await Future.wait([
        _svc.getTargets(),
        _svc.getForecast(),
        _svc.getDailySummary(today),
        _svc.getStreak(),
        _svc.getWeightHistory(),
        _svc.getDailyLogs(today),
        _svc.getDailyHistory(),
      ]).timeout(const Duration(seconds: 15));

      final tr = results[0] as Map<String, dynamic>?;
      targets = tr?['complete'] == true ? tr!['targets'] : null;
      final fr = results[1] as Map<String, dynamic>?;
      forecast = fr?['available'] == true ? fr!['forecast'] : null;
      todaySummary = results[2] as Map<String, dynamic>?;
      streak       = results[3] as int? ?? 0;
      weightHistory = results[4] as List<dynamic>;
      todayLogs    = results[5] as List<dynamic>;
      dailyHistory = results[6] as List<dynamic>;
    } catch (_) {}

    isDashboardLoading = false;
    notifyListeners();

    // Wave 2: insight dimuat terpisah (query berat, tidak blokir dashboard)
    try {
      insight = await _svc.getDailyInsight().timeout(const Duration(seconds: 20));
      notifyListeners();
    } catch (_) {}
  }

  void clearDashboard() {
    insight = null;
    targets = null;
    forecast = null;
    todaySummary = null;
    todayLogs = [];
    weightHistory = [];
    dailyHistory = [];
    diaryLogs = [];
    diarySummary = null;
    waterMl = 0;
    waterTargetMl = 2000;
    foodSearchResults = [];
    customFoods = [];
    streak = 0;
    notifyListeners();
  }

  // ── Diary ─────────────────────────────────────────────────────────────────

  Future<void> loadDiary(DateTime date) async {
    diaryDate = date;
    isDiaryLoading = true;
    notifyListeners();

    try {
      final dateStr = _fmt(date);
      final results = await Future.wait([
        _svc.getDailyLogs(dateStr),
        _svc.getDailySummary(dateStr),
        _svc.getWater(dateStr),
      ]).timeout(const Duration(seconds: 15));

      diaryLogs    = results[0] as List<dynamic>;
      diarySummary = results[1] as Map<String, dynamic>?;
      final wd = results[2] as Map<String, dynamic>?;
      waterMl       = wd?['amount_ml'] as int? ?? 0;
      waterTargetMl = wd?['target_ml'] as int? ?? 2000;
    } catch (_) {
      // Pastikan loading state selalu di-reset meski ada error/timeout
    } finally {
      isDiaryLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWater(DateTime date, int amountMl) async {
    final result = await _svc.updateWater(logDate: _fmt(date), amountMl: amountMl);
    if (result != null) {
      waterMl       = result['amount_ml'] as int? ?? amountMl;
      waterTargetMl = result['target_ml'] as int? ?? waterTargetMl;
      notifyListeners();
    }
  }

  Future<void> updateWaterTarget(int targetMl) async {
    final result = await _svc.updateProfile({'water_target_ml': targetMl});
    if (result != null) {
      waterTargetMl = targetMl;
      notifyListeners();
    }
  }

  Future<bool> addFoodLog({
    required Map<String, dynamic> food,
    required String mealType,
    required double quantityG,
    DateTime? date,
  }) async {
    final dateStr = _fmt(date ?? diaryDate);
    final result = await _svc.logFood(
      food: food,
      logDate: dateStr,
      mealType: mealType,
      quantityG: quantityG,
    );
    if (result != null) {
      await loadDiary(date ?? diaryDate);
      // Refresh dashboard today-summary if logging for today
      if (_isToday(date ?? diaryDate)) await _refreshTodaySummary();
      return true;
    }
    return false;
  }

  Future<bool> updateLog(String logId, double quantityG) async {
    final result = await _svc.updateLog(logId: logId, quantityG: quantityG);
    if (result != null) {
      await loadDiary(diaryDate);
      if (_isToday(diaryDate)) await _refreshTodaySummary();
      return true;
    }
    return false;
  }

  Future<bool> removeLog(String logId) async {
    final ok = await _svc.deleteLog(logId);
    if (ok) {
      await loadDiary(diaryDate);
      if (_isToday(diaryDate)) await _refreshTodaySummary();
    }
    return ok;
  }

  Future<void> _refreshTodaySummary() async {
    final today = _fmt(DateTime.now());
    final results = await Future.wait([
      _svc.getDailySummary(today),
      _svc.getStreak(),
      _svc.getDailyLogs(today),
    ]);
    todaySummary = results[0] as Map<String, dynamic>?;
    streak = results[1] as int? ?? 0;
    todayLogs = results[2] as List<dynamic>;
    notifyListeners();
  }

  // ── Food search ───────────────────────────────────────────────────────────

  Future<void> searchFoods(String query) async {
    final key = query.trim().toLowerCase();
    if (key.length < 2) {
      foodSearchResults = [];
      notifyListeners();
      return;
    }

    if (_searchCache.containsKey(key)) {
      foodSearchResults = _searchCache[key]!;
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();
    final results = await _svc.searchFoods(key);
    _searchCache[key] = results;
    foodSearchResults = results;
    isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    foodSearchResults = [];
    notifyListeners();
  }

  void invalidateSearchCache() {
    _searchCache.clear();
  }

  // ── Custom food ───────────────────────────────────────────────────────────

  Future<void> loadCustomFoods() async {
    customFoods = await _svc.getCustomFoods();
    notifyListeners();
  }

  Future<List<dynamic>> getRecipeIngredients(String foodId) async {
    return _svc.getRecipeIngredients(foodId);
  }

  Future<Map<String, dynamic>?> createFood({
    required String name,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    double fiberPer100g = 0,
    List<Map<String, dynamic>> ingredients = const [],
  }) async {
    final result = await _svc.createFood(
      name: name,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      carbsPer100g: carbsPer100g,
      fatPer100g: fatPer100g,
      fiberPer100g: fiberPer100g,
      ingredients: ingredients,
    );
    if (result != null) {
      customFoods = await _svc.getCustomFoods();
      _searchCache.clear();
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>?> updateFood({
    required String foodId,
    required String name,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    double fiberPer100g = 0,
    List<Map<String, dynamic>> ingredients = const [],
  }) async {
    final result = await _svc.updateFood(
      foodId: foodId,
      name: name,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      carbsPer100g: carbsPer100g,
      fatPer100g: fatPer100g,
      fiberPer100g: fiberPer100g,
      ingredients: ingredients,
    );
    if (result != null) {
      customFoods = await _svc.getCustomFoods();
      _searchCache.clear();
      notifyListeners();
    }
    return result;
  }

  // ── Weight logging ────────────────────────────────────────────────────────

  Future<bool> logWeight({required DateTime date, required double weightKg}) async {
    final ok = await _svc.logWeight(logDate: _fmt(date), weightKg: weightKg);
    if (ok) {
      weightHistory = await _svc.getWeightHistory();
      // Refresh forecast since current weight changed
      final fr = await _svc.getForecast();
      forecast = fr?['available'] == true ? fr!['forecast'] : null;
      notifyListeners();
    }
    return ok;
  }

  // ── Profile update ────────────────────────────────────────────────────────

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final result = await _svc.updateProfile(data);
    if (result != null) {
      // Refresh targets and forecast after profile change
      final results = await Future.wait([_svc.getTargets(), _svc.getForecast()]);
      final tr = results[0] as Map<String, dynamic>?;
      targets = tr?['complete'] == true ? tr!['targets'] as Map<String, dynamic>? : null;
      final fr = results[1] as Map<String, dynamic>?;
      forecast = fr?['available'] == true ? fr!['forecast'] as Map<String, dynamic>? : null;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── Computed helpers ──────────────────────────────────────────────────────

  double macroProgress(String nutrient) {
    final actual = (todaySummary?[nutrient] as num?)?.toDouble() ?? 0;
    final target = (targets?[nutrient] as num?)?.toDouble() ?? 0;
    if (target <= 0) return 0;
    return (actual / target).clamp(0.0, 1.0);
  }

  String get calorieStatus {
    final actual = (todaySummary?['total_calories'] as num?)?.toDouble() ?? 0;
    final target = (targets?['calories'] as num?)?.toDouble() ?? 0;
    if (target <= 0 || actual == 0) return 'START LOGGING TODAY';
    if (actual > target * 1.15) return 'TOO MUCH FOR TODAY';
    if (actual < target * 0.85) return 'BELOW TARGET TODAY';
    return 'ON TRACK TODAY';
  }

  String get insightText =>
      insight ?? 'Mulai catat makananmu setiap hari agar aku bisa memberikan insight yang lebih personal.';

  String get forecastDateLabel {
    final date = forecast?['forecast_date'] as String?;
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
    } catch (_) {
      return date;
    }
  }

  List<dynamic> logsForMeal(String mealType) =>
      diaryLogs.where((l) => l['meal_type'] == mealType).toList();

  // ── Utils ─────────────────────────────────────────────────────────────────

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}
