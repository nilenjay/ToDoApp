import 'package:equatable/equatable.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';

abstract class TodoState extends Equatable{
  const TodoState();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class TodoInitial extends TodoState{
  const TodoInitial();
}

class TodoLoaded extends TodoState{
  final List<TodoModel> todos;

  const TodoLoaded({
    required this.todos,
});
  @override
  // TODO: implement props
  List<Object?> get props => [todos];
}