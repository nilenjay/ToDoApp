import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)

class TodoModel extends Equatable{
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String description;
  
  @HiveField(2)
  final bool isComplete;
  
  @HiveField(3)
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