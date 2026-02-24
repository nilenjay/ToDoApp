import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:todo_app/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_event.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent,TodoState>{

  final TodoLocalDataSource _localDataSource;

  TodoBloc(this._localDataSource): super(const TodoInitial()){
    on<AddTodo>(_addTodo);
    on<DeleteTodo>(_deleteTodo);
    on<ToggleTodoStatus>(_toggleTodoStatus);

    _loadTodos();
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

  FutureOr<void> _deleteTodo(DeleteTodo event, Emitter<TodoState> emit){
    List<TodoModel> oldTodos=[];
    if(state is TodoLoaded){
      oldTodos=(state as TodoLoaded).todos;
    }
    final newTodos=oldTodos.where((todo)=> todo.id!=event.id).toList();
    emit(TodoLoaded(todos: newTodos));
  }

  FutureOr<void>_toggleTodoStatus(ToggleTodoStatus event, Emitter<TodoState> emit){
    List<TodoModel> oldTodos=[];
    if(state is TodoLoaded){
      oldTodos=(state as TodoLoaded).todos;
      final newTodos=oldTodos.map((todo)=> todo.id==event.id ? todo.copyWith(isComplete: !todo.isComplete) : todo).toList();
      emit(TodoLoaded(todos: newTodos));
    }
  }

  Future<void> _loadTodos() async {
    final todos = await _localDataSource.loadTodos();
    emit(TodoLoaded(todos: todos));
  }
}