enum TaskStatus {
  upcoming,
  inProgress,
  done,
}

class TaskModel  {
  String id;
  String name;
  String description;
  String userId;
  String cat;
  DateTime createdAt;
  DateTime dueDate;
  TaskStatus status;
  bool haveNotify;

  TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.createdAt,
    required this.dueDate,
    required this.status,
    required this.cat,
    required this.haveNotify

  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'status': status.name,
    'cat': cat,
    'haveNotify' : haveNotify
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    userId: json['userId'],
    createdAt: DateTime.parse(json['createdAt']),
    dueDate: DateTime.parse(json['dueDate']),
    status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
    cat: json['cat'],
      haveNotify: json['haveNotify']
  );

}
