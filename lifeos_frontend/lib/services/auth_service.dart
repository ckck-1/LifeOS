import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lifeos_frontend/auth/login.dart';
// import 'package:lifeos_frontend/screens/auth/register_screen.dart';

class AuthService {
  final String baseUrl = "http://192.168.1.15:3000:3000/api/auth";
  final _storage = const FlutterSecureStorage();

  // LOGIN
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save the JWT token returned by your Express controller
      await _storage.write(key: 'jwt_token', value: data['token']);
      return true;
    }
    return false;
  }

  // REGISTER
  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    return response.statusCode == 200;
  }
}
