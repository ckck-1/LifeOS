import 'dart:convert';
import 'package:frontendtwo/models/task_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://lifeos-7nj8.onrender.com';
  static const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // Use your full token here

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      };

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'), headers: _headers);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Task.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> addTask(Task task) async {
    await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
  }
}