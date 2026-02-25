import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_event.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_state.dart';

import '../../data/datasources/todo_local_datasource.dart';
import '../../data/models/todo_model.dart';


class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_)=> TodoBloc(TodoLocalDataSource()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Todo List'),
            ),
            body: BlocConsumer<TodoBloc, TodoState>(
          listener: (context, state) {
            if (state is TodoDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Todo deleted'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      context.read<TodoBloc>().add(RestoreTodo(todo: state.deletedTodo));
                    },
                  ),
                ),
              );
            }
          },
              builder: (context, state) {
                List<TodoModel> todos = [];

                if (state is TodoLoaded) {
                  todos = state.todos;
                } else if (state is TodoDeleted) {
                  todos = state.todos;
                }

                if (todos.isNotEmpty) {
                  return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];

                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.isComplete,
                            onChanged: (_) {
                              context.read<TodoBloc>().add(
                                ToggleTodoStatus(id: todo.id),
                              );
                            },
                          ),
                          title: Text(
                            todo.description,
                            style: TextStyle(
                              color:
                              todo.isComplete ? Colors.grey : Colors.black,
                              decoration: todo.isComplete
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              context.read<TodoBloc>().add(
                                DeleteTodo(id: todo.id),
                              );
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: Text('No List yet, Start the Journey now!!'),
                );
              },
          ),
            floatingActionButton: FloatingActionButton(onPressed: (){
              final controller =TextEditingController();
              showDialog(context: context, builder: (dialogContext){
                return AlertDialog(
                  title: const Text('Add Todo'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter description',
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: (){
                      final text=controller.text.trim();
                      if(text.isNotEmpty){
                        context.read<TodoBloc>().add(
                          AddTodo(description: text),
                        );
                      }
                      Navigator.pop(dialogContext);
                    }, child: const Text('Add')),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              });
            },
              child: const Icon(Icons.add),
            ),

          );
        }
      ),
    );
  }
}
