import 'package:json_annotation/json_annotation.dart';

part 'assignment.g.dart';

@JsonSerializable()
class Assignment {
  final int id;
  final String title;
  final String? description;
  final int classId;
  final DateTime dueDate;
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.title,
    this.description,
    required this.classId,
    required this.dueDate,
    required this.createdAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) => _$AssignmentFromJson(json);
  Map<String, dynamic> toJson() => _$AssignmentToJson(this);
} 