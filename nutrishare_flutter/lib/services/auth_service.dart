import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String _tokenKey = 'access_token';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _saveToken(data['access_token']);
      return {'success': true, 'user': User.fromJson(data['user'])};
    } else {
      return {'success': false, 'message': data['detail'] ?? 'Login gagal'};
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String name,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    developer.log('REGISTER status: ${response.statusCode}', name: 'AuthService');
    developer.log('REGISTER body: ${response.body}', name: 'AuthService');

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      await _saveToken(data['access_token']);
      return {'success': true, 'user': User.fromJson(data['user'])};
    } else {
      return {'success': false, 'message': data['detail'] ?? 'Registrasi gagal'};
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Dipanggil oleh NutritionService setiap kali response 401 diterima.
  /// Menghapus token sehingga app otomatis redirect ke login.
  Future<void> handleUnauthorized() async {
    await logout();
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    if (response.statusCode == 401) await handleUnauthorized();
    return null;
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }
}
