class UserModel {
  final int id;
  final String name;
  final String? email;
  final DateTime createdAt;
  final int status;
  final String roleName;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.createdAt,
    required this.status,
    required this.roleName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      status: int.tryParse(json['status'].toString()) ?? 0,
      roleName: json['role_name'] ?? json['role'] ?? '',
    );
  }
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? roleName,
    int? status,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roleName: roleName ?? this.roleName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


