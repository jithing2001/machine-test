import 'package:hive/hive.dart';

import 'package:test/services/db_services/hive_db.dart';
import 'package:test/services/db_services/todo_model.dart';
import 'package:test/utils/globals.dart';

class HiveService {
  static Future<void> saveUserData(List<UserModel> userData) async {
    final box = await Hive.openBox<UserModel>(Gloabals.userBoxKey);
    await box.clear();
    for (var user in userData) {
      await box.add(user);
    }
  }

  static Future<List<UserModel>> getUserData() async {
    final box = await Hive.openBox<UserModel>(Gloabals.userBoxKey);
    final List<UserModel> userData = box.values.toList();
    return userData;
  }

  static Future<void> saveTodos(List<TodoModel> todos) async {
    final box = await Hive.openBox<TodoModel>('todosBox');
    await box.clear();
    for (var todo in todos) {
      await box.add(todo);
      print('Saved Todo: ${todo.title}, UserId: ${todo.userId}');
    }
  }

  // Retrieve todos from the database
  static Future<List<TodoModel>> getTodos(int userId) async {
    final box = await Hive.openBox<TodoModel>('todosBox');

    // Filter the todos for the given userId and store them in a variable
    final todosForUser =
        box.values.toList();
    print(todosForUser);
    // Return the filtered todos
    return todosForUser;
  }
}
