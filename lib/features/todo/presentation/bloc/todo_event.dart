import 'package:equatable/equatable.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';

abstract class TodoEvent extends Equatable{
  const TodoEvent();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AddTodo extends TodoEvent{
  final String description;
  const AddTodo({
    required this.description,
});
  @override
  // TODO: implement props
  List<Object?> get props => [description];
}

class DeleteTodo extends TodoEvent{
  final String id;
  const DeleteTodo({
    required this.id,
});
  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class ToggleTodoStatus extends TodoEvent{
  final String id;
  const ToggleTodoStatus({
    required this.id,
});
  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class RestoreTodo extends TodoEvent{
  final TodoModel todo;

  const RestoreTodo({required this.todo});
  @override
  // TODO: implement props
  List<Object?> get props => [todo];
}