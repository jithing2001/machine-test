import 'package:flutter/material.dart';
import 'package:test/services/api_services.dart/api_call.dart';
import 'package:test/services/api_services.dart/todo_service/todo_service.dart';
import 'package:test/services/db_services/hive_db.dart';
import 'package:test/services/db_services/hive_services.dart';
import 'package:test/services/db_services/todo_model.dart';

class UserDataProvider extends ChangeNotifier {
  UserDataProvider() {
    initUserData();
  }

  List<UserModel> _userData = [];
  String? _error;
  bool isLoading = true;
  List<TodoModel> _todos = [];
  List<TodoModel> get todos => _todos;

  List<UserModel> get userData => _userData;
  String? get error => _error;

  void initUserData({bool isrefresh = false}) async {
    _error = null;
    if (!isrefresh) {
      isLoading = true;
      notifyListeners();
    }
    await HiveService.getUserData().then((value) {
      if (value.isNotEmpty && userData.isEmpty) {
        _userData = value;
      }
    });

    await GetAPi.fetchUserData().then((value) async {
      if (value.isNotEmpty) {
        _userData = value;
        await HiveService.saveUserData(userData);
      }
    }).catchError((error) {
      _error = '$error';
    });

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTodos(int userId) async {
    isLoading = true;

    try {
      // Fetch from local DB
      final localTodos = await HiveService.getTodos(userId);

      if (localTodos.isNotEmpty) {
        _todos = List.from(localTodos
            .where((todo) => todo.userId == userId)
            .toList()); 
      } else {
        // Fetch from API and save to DB
        final apiTodos = await TodoApiService.fetchTodos(userId);
        if (apiTodos.isNotEmpty) {
          _todos = apiTodos.where((todo) => todo.userId == userId).toList();
          await HiveService.saveTodos(apiTodos);
        }
      }
    } catch (e) {
      _todos = [];
    } finally {
      isLoading = false;
      notifyListeners(); // Notify after completion
    }
  }
}
