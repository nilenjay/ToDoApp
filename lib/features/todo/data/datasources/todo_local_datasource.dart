import 'package:hive/hive.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';

class TodoLocalDataSource {
  static const String _boxName = 'todosBox';

  Future<Box<TodoModel>> _openBox() async {
    return await Hive.openBox<TodoModel>(_boxName);
  }

  Future<List<TodoModel>> loadTodos() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> saveTodos(List<TodoModel> todos) async {
    final box = await _openBox();
    await box.clear();
    await box.addAll(todos);
  }
}