import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Use a final instance of Dio for all requests
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://lifeos-7nj8.onrender.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final _storage = const FlutterSecureStorage();

  // =========================
  // 🔐 TOKEN MANAGEMENT
  // =========================

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  // Helper to generate headers with the stored token
  Future<Options> _getAuthOptions() async {
    final token = await getToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // =========================
  // 🔑 AUTH ROUTES
  // =========================

  Future<Response> login(String email, String password) async {
    // Note: The login response will contain the token you need to pass to saveToken()
    return await _dio.post(
      '/auth/login',
      data: {"email": email, "password": password},
    );
  }

  Future<Response> register(String name, String email, String password) async {
    return await _dio.post(
      '/auth/register',
      data: {"name": name, "email": email, "password": password},
    );
  }

  // =========================
  // 🎯 GOALS & AI ROUTES
  // =========================

  Future<List<dynamic>> getGoals() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('/goals', options: options);

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Error fetching goals: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDailyFocus() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('/ai/daily-focus', options: options);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching daily focus: $e");
      return null;
    }
  }

  // =========================
  // 💡 NEW AI SHORTCUTS
  // =========================

  Future<Map<String, dynamic>?> getWeeklyPlan() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('/ai/weekly-plan', options: options);
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getOpportunities() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('/ai/opportunities', options: options);
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
