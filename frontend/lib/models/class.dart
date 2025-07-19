class ClassModel {
  final String id;
  final String name;
  final String subject;
  final String description;
  final String teacherId;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.description,
    required this.teacherId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'description': description,
      'teacherId': teacherId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      subject: json['subject'],
      description: json['description'],
      teacherId: json['teacherId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 