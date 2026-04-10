import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class NutritionService {
  static const String _base = String.fromEnvironment('BASE_URL', defaultValue: 'https://nutrishare-production.up.railway.app/api/v1');
  final AuthService _auth = AuthService();
  void Function()? onUnauthorized;

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Periksa response: jika 401, hapus token dan panggil onUnauthorized.
  Future<bool> _checkUnauthorized(http.Response res) async {
    if (res.statusCode == 401) {
      await _auth.handleUnauthorized();
      onUnauthorized?.call();
      return true;
    }
    return false;
  }

  // ── Profile ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getTargets() async {
    final res = await http.get(Uri.parse('$_base/profile/targets'), headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  Future<Map<String, dynamic>?> getForecast() async {
    final res = await http.get(Uri.parse('$_base/profile/forecast'), headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  // ── Logs ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getDailySummary(String date) async {
    final res = await http.get(Uri.parse('$_base/logs/summary?log_date=$date'), headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  Future<List<dynamic>> getDailyLogs(String date) async {
    final res = await http.get(Uri.parse('$_base/logs/?log_date=$date'), headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return [];
  }

  Future<Map<String, dynamic>?> logFood({
    required String foodItemId,
    required String logDate,
    required String mealType,
    required double quantityG,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/logs/'),
      headers: await _headers(),
      body: jsonEncode({
        'food_item_id': foodItemId,
        'log_date': logDate,
        'meal_type': mealType,
        'quantity_g': quantityG,
      }),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  Future<Map<String, dynamic>?> updateLog({
    required String logId,
    required double quantityG,
  }) async {
    final res = await http.patch(
      Uri.parse('$_base/logs/$logId'),
      headers: await _headers(),
      body: jsonEncode({'quantity_g': quantityG}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  Future<bool> deleteLog(String logId) async {
    final res = await http.delete(
      Uri.parse('$_base/logs/$logId'),
      headers: await _headers(),
    );
    if (res.statusCode == 204) return true;
    await _checkUnauthorized(res);
    return false;
  }

  // ── Foods ─────────────────────────────────────────────────────────────────

  Future<List<dynamic>> searchFoods(String query) async {
    final res = await http.get(
      Uri.parse('$_base/foods/search?q=${Uri.encodeComponent(query)}'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['results'] ?? [];
    }
    await _checkUnauthorized(res);
    return [];
  }

  Future<List<dynamic>> getCustomFoods() async {
    final res = await http.get(
      Uri.parse('$_base/foods/custom'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return [];
  }

  Future<List<dynamic>> listFoods() async {
    final res = await http.get(
      Uri.parse('$_base/foods/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return [];
  }

  Future<Map<String, dynamic>?> createFood({
    required String name,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    double fiberPer100g = 0,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/foods/'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'calories_per_100g': caloriesPer100g,
        'protein_per_100g': proteinPer100g,
        'carbs_per_100g': carbsPer100g,
        'fat_per_100g': fatPer100g,
        'fiber_per_100g': fiberPer100g,
      }),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/profile/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  Future<int> getStreak() async {
    final res = await http.get(Uri.parse('$_base/logs/streak'), headers: await _headers());
    if (res.statusCode == 200) return (jsonDecode(res.body)['streak'] as num?)?.toInt() ?? 0;
    await _checkUnauthorized(res);
    return 0;
  }

  // ── Weight logs ───────────────────────────────────────────────────────────

  Future<bool> logWeight({required String logDate, required double weightKg}) async {
    final res = await http.post(
      Uri.parse('$_base/weight-logs/'),
      headers: await _headers(),
      body: jsonEncode({'log_date': logDate, 'weight_kg': weightKg}),
    );
    if (res.statusCode == 201) return true;
    await _checkUnauthorized(res);
    return false;
  }

  Future<List<dynamic>> getWeightHistory({int limit = 30}) async {
    final res = await http.get(
      Uri.parse('$_base/weight-logs/?limit=$limit'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return [];
  }

  // ── Water ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getWater(String date) async {
    final res = await http.get(
      Uri.parse('$_base/water/?log_date=$date'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  Future<Map<String, dynamic>?> updateWater({
    required String logDate,
    required int amountMl,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/water/'),
      headers: await _headers(),
      body: jsonEncode({'log_date': logDate, 'amount_ml': amountMl}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  // ── Sleep ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getSleep(String date) async {
    final res = await http.get(
      Uri.parse('$_base/sleep/?log_date=$date'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final body = res.body.trim();
      if (body == 'null') return null;
      return jsonDecode(body);
    }
    await _checkUnauthorized(res);
    return null;
  }

  Future<Map<String, dynamic>?> updateSleep({
    required String logDate,
    required String bedTime,
    required String wakeTime,
    required double durationHours,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/sleep/'),
      headers: await _headers(),
      body: jsonEncode({
        'log_date':       logDate,
        'bed_time':       bedTime,
        'wake_time':      wakeTime,
        'duration_hours': durationHours,
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    await _checkUnauthorized(res);
    return null;
  }

  // ── Insights ──────────────────────────────────────────────────────────────

  Future<String?> getDailyInsight() async {
    final res = await http.get(
      Uri.parse('$_base/insights/daily'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['insight'] as String?;
    }
    await _checkUnauthorized(res);
    return null;
  }
}
