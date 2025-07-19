class Permission {
  final int id;
  final String permission;
  final String routes;
  final String accessName;

  Permission({
    required this.id,
    required this.permission,
    required this.routes,
    required this.accessName,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] ?? 0,
      permission: json['permission']?.toString() ?? '',
      routes: json['routes'] ?? '',
      accessName: json['access_name'] ?? '',
    );
  }
}

class PermissionGroup {
  final String groupName;
  final String moduleName;
  final List<Permission> permissions;

  PermissionGroup({
    required this.groupName,
    required this.moduleName,
    required this.permissions,
  });

  factory PermissionGroup.fromJson(String groupName, String moduleName, List<dynamic> jsonList) {
    return PermissionGroup(
      groupName: groupName,
      moduleName: moduleName,
      permissions: jsonList.map((json) => Permission.fromJson(json)).toList(),
    );
  }
}


