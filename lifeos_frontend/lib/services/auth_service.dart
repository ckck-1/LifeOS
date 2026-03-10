import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "https://8840-154-68-65-174.ngrok-free.app";
  final _storage = const FlutterSecureStorage();

  // REGISTER
  Future<bool> register(String name, String email, String password) async {
    final url = Uri.parse(
      '$baseUrl/auth/register'.trim(),
    ); // <--- trim here just in case
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    return response.statusCode == 200;
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login'.trim());
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'jwt_token', value: data['token']);
      return true;
    }
    return false;
  }
}
