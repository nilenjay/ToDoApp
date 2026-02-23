import 'package:flutter/material.dart';
import 'package:todo_app/features/todo/presentation/screens/todo_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TodoModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoScreen(),
    );
  }
}