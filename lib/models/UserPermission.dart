import 'package:flutter/material.dart';


// models/user_permission_model.dart

class UserPermission {
  final String groupName;
  final String moduleName;
  final List<String> permissions;

  UserPermission({
    required this.groupName,
    required this.moduleName,
    required this.permissions,
  });

  factory UserPermission.fromJson(Map<String, dynamic> json) {
    return UserPermission(
      groupName: json['groupName'] ?? '',
      moduleName: json['moduleName'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'moduleName': moduleName,
      'permissions': permissions,
    };
  }

  String toString() {
    return '''
UserPermission {
  groupName: $groupName,
  moduleName: $moduleName,
  permissions: ${permissions.join(', ')}
}''';
  }
}

class UserPermissionResponse {
  final bool status;
  final String message;
  final Map<String, Map<String, List<Map<String, dynamic>>>> data;

  UserPermissionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserPermissionResponse.fromJson(Map<String, dynamic> json) {
    return UserPermissionResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: Map<String, Map<String, List<Map<String, dynamic>>>>.from(
        json['data'] ?? {},
      ),
    );
  }


}