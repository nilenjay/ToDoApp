import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_event.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent,TodoState>{
  TodoBloc(): super(const TodoInitial()){
    on<AddTodo>(_addTodo);

  }
  FutureOr<void>_addTodo(AddTodo event, Emitter<TodoState> emit) {
    List<TodoModel> oldTodos = [];
    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    }
    final newTodo = TodoModel(
      id: DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      description: event.description,
      addedDate: DateTime.now(),
      isComplete: false,
    );
    final newTodos=[...oldTodos,newTodo];
    emit(TodoLoaded(todos: newTodos));
  }
}