import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todo/data/models/todo_filter.dart';
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
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Todo deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          context.read<TodoBloc>().add(
                            RestoreTodo(todo: state.deletedTodo),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                List<TodoModel> todos = [];
                TodoFilter currentFilter = TodoFilter.all;
                List<TodoModel> filteredTodos = todos;

                if (state is TodoLoaded) {
                  todos = state.todos;
                  currentFilter = state.filter;
                } else if (state is TodoDeleted) {
                  todos = state.todos;
                  currentFilter = state.filter;
                }

                switch (currentFilter) {
                  case TodoFilter.active:
                    filteredTodos =
                        todos.where((t) => !t.isComplete).toList();
                    break;

                  case TodoFilter.completed:
                    filteredTodos =
                        todos.where((t) => t.isComplete).toList();
                    break;

                  case TodoFilter.all:
                    filteredTodos = todos;
                    break;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: currentFilter == TodoFilter.all,
                            onSelected: (_) {
                              context.read<TodoBloc>().add(
                                ChangeFilter(filter: TodoFilter.all),
                              );
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Active'),
                            selected: currentFilter == TodoFilter.active,
                            onSelected: (_) {
                              context.read<TodoBloc>().add(
                                ChangeFilter(filter: TodoFilter.active),
                              );
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Completed'),
                            selected: currentFilter == TodoFilter.completed,
                            onSelected: (_) {
                              context.read<TodoBloc>().add(
                                ChangeFilter(filter: TodoFilter.completed),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: todos.isNotEmpty
                          ? ListView.builder(
                        itemCount: filteredTodos.length,
                        itemBuilder: (context, index) {
                          final todo = filteredTodos[index];

                          return Dismissible(
                            key: ValueKey(todo.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.red,
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) {
                              context.read<TodoBloc>().add(
                                DeleteTodo(id: todo.id),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Card(
                                elevation: 2,
                                child: ListTile(
                                  leading: Checkbox(
                                    visualDensity: VisualDensity.compact,
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
                                      color: todo.isComplete
                                          ? Colors.grey
                                          : Colors.black,
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
                              ),
                            ),
                          );
                        },
                      )
                          : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No todos yet…'),
                          ],
                        ),
                      ),
                    ),
                  ],
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
