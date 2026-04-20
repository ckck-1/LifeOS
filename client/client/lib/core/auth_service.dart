import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://lifeos-7nj8.onrender.com';

  static String? _authToken;

  // =========================
  // 🔐 REGISTER
  // =========================
  Future<bool> register(String name, String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');

      final body = {
        'name': name,
        'email': email,
        'password': password,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // 🔑 LOGIN
  // =========================
  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');

      final body = {
        'email': email,
        'password': password,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // 🎯 GET PRIORITIES (AUTH)
  // =========================
  Future<List<Map<String, dynamic>>> getPriorities() async {
    try {
      if (_authToken == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/goals'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}