class UserModel {
  final String id;
  final String name;
  final String email;
  final String rolename;
  final String createdat;
  final int status;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.rolename,
    required this.createdat,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
      createdat: json['created_at'] ?? '',
      rolename: json['role_name'] ?? '',
    );
  }
}
