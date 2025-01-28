import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/services/db_services/todo_model.dart';

class TodoApiService {
  static Future<List<TodoModel>> fetchTodos(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/todos'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data.map<TodoModel>((json) => TodoModel.fromJson(json)).toList();
      } else {
        throw "Failed to load todos";
      }
    } catch (e) {
      rethrow;
    }
  }
}
