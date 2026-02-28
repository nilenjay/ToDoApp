import 'dart:async';
import 'package:todo_app/core/notifications/notification_service.dart';
import 'package:bloc/bloc.dart';
import 'package:todo_app/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_event.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_state.dart';

import '../../data/models/todo_filter.dart';

class TodoBloc extends Bloc<TodoEvent,TodoState>{

  final TodoLocalDataSource _localDataSource;

  TodoBloc(this._localDataSource): super(const TodoInitial()){
    on<AddTodo>(_addTodo);
    on<DeleteTodo>(_deleteTodo);
    on<ToggleTodoStatus>(_toggleTodoStatus);
    on<RestoreTodo>(_restoreTodo);
    on<ChangeFilter>(_changeFilter);
    _loadTodos();
    on<SearchTodos>(_searchTodos);
    on<EditTodo>(_editTodo);
  }

  Future<void>_addTodo(AddTodo event, Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    }
    else if(state is TodoDeleted){
      oldTodos=(state as TodoDeleted).todos;
    }
    final newTodo = TodoModel(
      id: DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      description: event.description,
      addedDate: DateTime.now(),
      isComplete: false,
      dueDate: event.dueDate,
    );
    final newTodos=[...oldTodos,newTodo];
    await _localDataSource.saveTodos(newTodos);
    await _scheduleReminder(newTodo);
    emit(TodoLoaded(todos: newTodos));
  }

  Future<void> _deleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos=[];
    if(state is TodoLoaded){
      oldTodos=(state as TodoLoaded).todos;
    }
    else if(state is TodoDeleted){
      oldTodos=(state as TodoDeleted).todos;
    }

    final deletedTodo=oldTodos.firstWhere((todo)=>todo.id==event.id);
    final newTodos=oldTodos.where((todo)=> todo.id!=event.id).toList();

    await _localDataSource.saveTodos(newTodos);
    await NotificationService.instance
        .cancelNotification(event.id.hashCode);
    emit(TodoDeleted(deletedTodo: deletedTodo, todos: newTodos));
  }

  Future<void> _toggleTodoStatus(ToggleTodoStatus event,Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];

    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    } else if (state is TodoDeleted) {
      oldTodos = (state as TodoDeleted).todos;
    }

    final toggled = oldTodos.firstWhere((t) => t.id == event.id);
    final newTodos = oldTodos.map((todo) => todo.id == event.id ? todo.copyWith(isComplete: !todo.isComplete) : todo).toList();
    final bool willBeComplete = !toggled.isComplete;

    if (willBeComplete) {
      // became completed → cancel reminder
      await NotificationService.instance
          .cancelNotification(event.id.hashCode);
    } else {
      // became incomplete → reschedule reminder
      final updatedTodo = toggled.copyWith(
        isComplete: willBeComplete,
      );

      await _scheduleReminder(updatedTodo);
    }
    await _localDataSource.saveTodos(newTodos);
    emit(TodoLoaded(todos: newTodos));
  }

  Future<void> _loadTodos() async {
    final todos = await _localDataSource.loadTodos();
    emit(TodoLoaded(todos: todos));
  }

  Future<void> _restoreTodo(RestoreTodo event,Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];

    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    } else if (state is TodoDeleted) {
      oldTodos = (state as TodoDeleted).todos;
    }

    final newTodos = [...oldTodos, event.todo];

    await _localDataSource.saveTodos(newTodos);

    emit(TodoLoaded(todos: newTodos));
  }

  Future<void> _changeFilter(ChangeFilter event,Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    TodoFilter currentFilter = event.filter;

    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    } else if (state is TodoDeleted) {
      oldTodos = (state as TodoDeleted).todos;
    }

    emit(TodoLoaded(todos: oldTodos,filter: currentFilter,));
  }

  Future<void> _searchTodos(SearchTodos event,Emitter<TodoState> emit) async {
    List<TodoModel> oldTodos = [];
    TodoFilter currentFilter = TodoFilter.all;

    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
      currentFilter = (state as TodoLoaded).filter;
    } else if (state is TodoDeleted) {
      oldTodos = (state as TodoDeleted).todos;
      currentFilter = (state as TodoDeleted).filter;
    }

    emit(TodoLoaded(todos: oldTodos,filter: currentFilter,searchQuery: event.query));
  }

  Future<void> _scheduleReminder(TodoModel todo) async {
    DateTime? scheduledTime;

    // 🧠 custom reminder wins
    if (todo.reminderTime != null) {
      scheduledTime = todo.reminderTime;
    }
    // 🧠 otherwise default = dueDate - 30 minutes
    else if (todo.dueDate != null) {
      scheduledTime =
          todo.dueDate!.subtract(const Duration(minutes: 30));
    }

    // 🚫 nothing to schedule
    if (scheduledTime == null) return;

    // 🚫 don't schedule past notifications
    if (scheduledTime.isBefore(DateTime.now())) return;

    await NotificationService.instance.scheduleNotification(
      id: todo.id.hashCode,
      title: 'Todo Reminder',
      body: todo.description,
      scheduledTime: scheduledTime,
    );
  }

  Future<void> _editTodo(EditTodo event, Emitter<TodoState> emit)async {
    List<TodoModel>oldTodos=[];

    if (state is TodoLoaded) {
      oldTodos = (state as TodoLoaded).todos;
    } else if (state is TodoDeleted) {
      oldTodos = (state as TodoDeleted).todos;
    }

    TodoFilter currentFilter = TodoFilter.all;
    String currentSearch = '';

    final currentState = state;

    if (currentState is TodoLoaded) {
      currentFilter = currentState.filter;
      currentSearch = currentState.searchQuery;
    } else if (currentState is TodoDeleted) {
      currentFilter = currentState.filter;
      currentSearch = currentState.searchQuery;
    }

    final oldTodo =
    oldTodos.firstWhere((t) => t.id == event.updatedTodo.id);

    await NotificationService.instance.cancelNotification(oldTodo.id.hashCode);

    final newTodos = oldTodos.map((todo) {
      if (todo.id == event.updatedTodo.id) return event.updatedTodo;
      return todo;
    }).toList();

    if (!event.updatedTodo.isComplete) {
      await _scheduleReminder(event.updatedTodo);
    }

    await _localDataSource.saveTodos(newTodos);

    emit(TodoLoaded(
      todos: newTodos,
      filter: currentFilter,
      searchQuery: currentSearch,
    ));
  }
}