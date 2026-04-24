// import 'dart:convert';
// import 'package:http/http.dart' as http;
// // ADD THIS IMPORT (adjust path if your folder structure is different):
// import '../models/task_model.dart'; 

// class TaskService {
//   final String baseUrl = "https://lifeos-7nj8.onrender.com/tasks";

//   Future<List<LifeTask>> fetchTasks() async {
//     try {
//       final response = await http.get(Uri.parse(baseUrl));
//       if (response.statusCode == 200) {
//         List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => LifeTask.fromJson(json)).toList();
//       }
//       return [];
//     } catch (e) {
//       return [];
//     }
//   }

//   Future<bool> addTask(LifeTask task) async {
//     final response = await http.post(
//       Uri.parse(baseUrl),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(task.toJson()),
//     );
//     return response.statusCode == 200;
//   }
// }