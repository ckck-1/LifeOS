import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://lifeos-7nj8.onrender.com';

  // In a real app, retrieve this from flutter_secure_storage after login
  static String? _authToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiaWF0IjoxNzc2Njc0Mjk1LCJleHAiOjE3NzcyNzkwOTV9.izhBWRJq_-BE4NX0wAI1ddeiwwk8Vs2SF0KdISiqj5A";

  Future<List<Map<String, dynamic>>> getPriorities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/goals'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      // You would save the token from response.body here
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
