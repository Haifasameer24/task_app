class AppUser {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    name: json['name'],
    email: json['email'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}