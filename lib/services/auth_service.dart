import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: await _headers(auth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register(
      String nama, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'nama': nama,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<void> logout() async {
    try {
      final headers = await _headers();
      await http.post(Uri.parse(ApiConstants.logout), headers: headers);
    } catch (e) {
      // Abaikan error jaringan saat logout agar sesi lokal tetap bisa dihapus
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  Future<void> saveSession(String token, String role, String nama, int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('nama', nama);
    await prefs.setInt('user_id', id);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
