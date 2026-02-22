import 'package:equatable/equatable.dart';

class TodoModel extends Equatable{

  final String id;
  final String description;
  final bool isComplete;
  final DateTime addedDate;

  const TodoModel({
    required this.id,
    required this.description,
    this.isComplete=false,
    required this.addedDate,
});

  TodoModel copyWith({String? id, String? description, bool? isComplete, DateTime? addedDate}){
    return TodoModel(id: id?? this.id, addedDate: addedDate?? this.addedDate, isComplete: isComplete?? this.isComplete, description: description?? this.description);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id,addedDate,isComplete,description];
}