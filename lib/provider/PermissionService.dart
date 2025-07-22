// Model Classes
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PermissionItem {
  final String permission;

  PermissionItem({required this.permission});

  factory PermissionItem.fromJson(Map<String, dynamic> json) {
    return PermissionItem(
      permission: json['permission'].toString(),
    );
  }
}

class PermissionCategory {
  final List<PermissionItem> items;

  PermissionCategory({required this.items});

  factory PermissionCategory.fromJson(List<dynamic> jsonList) {
    final items = jsonList.map((item) =>
        PermissionItem.fromJson(item as Map<String, dynamic>)).toList();
    return PermissionCategory(items: items);
  }
}

class GlobalPermissions {
  final PermissionCategory? patientList;
  final UserManagementPermissions? userManagements;

  GlobalPermissions({
    this.patientList,
    this.userManagements,
  });

  factory GlobalPermissions.fromJson(Map<String, dynamic> json) {
    return GlobalPermissions(
      patientList: json['patientlist'] != null
          ? PermissionCategory.fromJson(json['patientlist']['patientlist'] ?? [])
          : null,
      userManagements: json['UserManagements'] != null
          ? UserManagementPermissions.fromJson(json['UserManagements'])
          : null,
    );
  }
}

class UserManagementPermissions {
  final PermissionCategory? user;
  final PermissionCategory? roles;
  final PermissionCategory? permissions;

  UserManagementPermissions({
    this.user,
    this.roles,
    this.permissions,
  });

  factory UserManagementPermissions.fromJson(Map<String, dynamic> json) {
    return UserManagementPermissions(
      user: json['User'] != null ? PermissionCategory.fromJson(json['User']) : null,
      roles: json['Roles'] != null ? PermissionCategory.fromJson(json['Roles']) : null,
      permissions: json['Permissions'] != null ? PermissionCategory.fromJson(json['Permissions']) : null,
    );
  }
}
// Permission Check Function
Future<void> checkPermissions() async {
  final prefs = await SharedPreferences.getInstance();
  final permissionsString = prefs.getString('global_permissions');

  if (permissionsString != null) {
    final permissionsJson = json.decode(permissionsString);
    final permissions = GlobalPermissions.fromJson(permissionsJson);

    // Patient Permissions
    final canAddPatients = permissions.patientList?.items.any((p) => p.permission == '1' )?? false ;
    final canEditPatients = permissions.patientList?.items.any((p) => p.permission == '2')?? false;
    final canViewPatients = permissions.patientList?.items.any((p) => p.permission == '3')?? false;
    final canDeletePatients = permissions.patientList?.items.any((p) => p.permission == '4')?? false;

    // User Management - User Permissions
    final canAddUsers = permissions.userManagements?.user?.items.any((p) => p.permission == '1')?? false;
    final canEditUsers = permissions.userManagements?.user?.items.any((p) => p.permission == '2')?? false;
    final canViewUsers = permissions.userManagements?.user?.items.any((p) => p.permission == '3')?? false;
    final canDeleteUsers = permissions.userManagements?.user?.items.any((p) => p.permission == '4')?? false;

    // User Management - Roles Permissions
    final canAddRoles = permissions.userManagements?.roles?.items.any((p) => p.permission == '1')?? false;
    final canEditRoles = permissions.userManagements?.roles?.items.any((p) => p.permission == '2')?? false;
    final canViewRoles = permissions.userManagements?.roles?.items.any((p) => p.permission == '3')?? false;
    final canDeleteRoles = permissions.userManagements?.roles?.items.any((p) => p.permission == '4')?? false;

    // User Management - Permissions Permissions
    final canAddPermissions = permissions.userManagements?.permissions?.items.any((p) => p.permission == '1')?? false;
    final canEditPermissions = permissions.userManagements?.permissions?.items.any((p) => p.permission == '2')?? false;
    final canViewPermissions = permissions.userManagements?.permissions?.items.any((p) => p.permission == '3')?? false;
    final canDeletePermissions = permissions.userManagements?.permissions?.items.any((p) => p.permission == '4')?? false ;

    // Print all permissions
    print('=== Patient Permissions ===');
    print('Can Add Patients: $canAddPatients');
    print('Can Edit Patients: $canEditPatients');
    print('Can View Patients: $canViewPatients');
    print('Can Delete Patients: $canDeletePatients');

    print('\n=== User Permissions ===');
    print('Can Add Users: $canAddUsers');
    print('Can Edit Users: $canEditUsers');
    print('Can View Users: $canViewUsers');
    print('Can Delete Users: $canDeleteUsers');

    print('\n=== Role Permissions ===');
    print('Can Add Roles: $canAddRoles');
    print('Can Edit Roles: $canEditRoles');
    print('Can View Roles: $canViewRoles');
    print('Can Delete Roles: $canDeleteRoles');

    print('\n=== Permission Management ===');
    print('Can Add Permissions: $canAddPermissions');
    print('Can Edit Permissions: $canEditPermissions');
    print('Can View Permissions: $canViewPermissions');
    print('Can Delete Permissions: $canDeletePermissions');
  } else {
    print('No permissions found in SharedPreferences');
  }
}



class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  GlobalPermissions? _permissions;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsString = prefs.getString('global_permissions');

      if (permissionsString != null && permissionsString.isNotEmpty) {
        final decodedJson = json.decode(permissionsString);
        if (decodedJson is Map<String, dynamic>) {
          _permissions = GlobalPermissions.fromJson(decodedJson);
        }
      }
      _isInitialized = true;
    } catch (e) {
      print('Error initializing permissions: $e');
      _permissions = null;
      _isInitialized = true; // Still mark as initialized to prevent infinite loops
    }
  }

  // Patient Permissions
  bool get canAddPatients =>
      _permissions?.patientList?.items?.any((p) => p.permission == '1') ?? false;

  bool get canEditPatients =>
      _permissions?.patientList?.items?.any((p) => p.permission == '2') ?? false;

  bool get canViewPatients =>
      _permissions?.patientList?.items?.any((p) => p.permission == '3') ?? false;

  bool get canDeletePatients =>
      _permissions?.patientList?.items?.any((p) => p.permission == '4') ?? false;

  // User Management - User Permissions
  bool get canAddUsers =>
      _permissions?.userManagements?.user?.items?.any((p) => p.permission == '1') ?? false;

  bool get canEditUsers =>
      _permissions?.userManagements?.user?.items?.any((p) => p.permission == '2') ?? false;

  bool get canViewUsers =>
      _permissions?.userManagements?.user?.items?.any((p) => p.permission == '3') ?? false;

  bool get canDeleteUsers =>
      _permissions?.userManagements?.user?.items?.any((p) => p.permission == '4') ?? false;

  // User Management - Roles Permissions
  bool get canAddRoles =>
      _permissions?.userManagements?.roles?.items?.any((p) => p.permission == '1') ?? false;

  bool get canEditRoles =>
      _permissions?.userManagements?.roles?.items?.any((p) => p.permission == '2') ?? false;

  bool get canViewRoles =>
      _permissions?.userManagements?.roles?.items?.any((p) => p.permission == '3') ?? false;

  bool get canDeleteRoles =>
      _permissions?.userManagements?.roles?.items?.any((p) => p.permission == '4') ?? false;

  // User Management - Permissions Permissions
  bool get canAddPermissions =>
      _permissions?.userManagements?.permissions?.items?.any((p) => p.permission == '1') ?? false;

  bool get canEditPermissions =>
      _permissions?.userManagements?.permissions?.items?.any((p) => p.permission == '2') ?? false;

  bool get canViewPermissions =>
      _permissions?.userManagements?.permissions?.items?.any((p) => p.permission == '3') ?? false;

  bool get canDeletePermissions =>
      _permissions?.userManagements?.permissions?.items?.any((p) => p.permission == '4') ?? false;

  // Status checks
  bool get isInitialized => _isInitialized;
  bool get hasPermissions => _permissions != null;

  Future<void> reloadPermissions() async {
    await initialize();
  }

  // Fallback method if you need to check permissions before initialization completes
  Future<bool> checkPermission(Future<bool> Function() permissionCheck) async {
    if (!_isInitialized) {
      await initialize();
    }
    return await permissionCheck();
  }
}