import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_state.dart';


class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_)=> TodoBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Todo List'),
        ),
        body: BlocBuilder<TodoBloc,TodoState>(
            builder: (context,state){
              if(state is TodoLoaded){
                final todos=state.todos;
                if(todos.isNotEmpty){
                  return ListView.builder(itemBuilder: )
                }
              }
            }),
      ),
    );
  }
}
