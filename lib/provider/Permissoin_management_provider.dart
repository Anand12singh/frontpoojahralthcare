// provider/permission_management_provider.dart
import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import '../models/Permission_model.dart';
import '../models/UserModel.dart';
import '../models/UserPermission.dart';
import '../models/permission_model.dart';
import '../services/api_services.dart';
import '../services/auth_service.dart';
import '../widgets/showTopSnackBar.dart';

class PermissoinManagementProvider with ChangeNotifier {
  String? selectedUser;
  int? selectedUserID;
  String? selectedRole;
  int? selectedRoleID;
  bool isLoading = false;
  String errorMessage = '';
  List<UserPermissionModel> _roleUsers = [];
  List<UserPermissionModel> get roleUsers => _roleUsers;
  List<String> get roleUserNames => _roleUsers.map((user) => user.name).toList();
  List<UserPermission> _userPermissions = [];
  List<UserPermission> get userPermissions => _userPermissions;

  // Store permissions data
  Map<String, Map<String, List<Map<String, dynamic>>>> permissions = {};
  Map<String, bool> groupExpansionStates = {};
  Map<String, Map<String, Map<String, bool>>> permissionStates = {};

  Future<void> fetchPermissions(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null) return;

    try {
      await APIManager().apiRequest(
        context,
        API.permissionslist,
        token: token,
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true && data['permission'] != null) {
            print("Fetched Permission Data:");
            print(jsonEncode(data['permission'])); // 🔍

            _parsePermissionData(data['permission']);
          }
        },

        onFailure: (error) {
          errorMessage = 'Error fetching permissions: $error';
        },
      );
    } catch (e) {
      errorMessage = 'Exception occurred: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  // Add a new role
  Future<bool> getrolebyid({
    required BuildContext context,
    required int roleID,
  }) async {
    isLoading = true;
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null) return false;

    try {
      bool success = false;
      await APIManager().apiRequest(
        context,
        API.getrolebyid,
        token: token,
        params: {'id': roleID},
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          print(data['data']);
          if (data['status'] == true && data['data'] != null) {
            print(data['data']);
            success = true;
            _roleUsers = (data['data'] as List)
                .map((userJson) => UserPermissionModel.fromJson(userJson))
                .toList();
            print(_roleUsers);
          }
          notifyListeners();
        },
        onFailure: (error) {
          print(error);
          errorMessage = 'Error fetching role users: $error';
        },
      );
      return success;
    } catch (e) {
      print(e);
      errorMessage = 'Exception occurred: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> getuserpermissons({
    required BuildContext context,
    required int roleID,
    required int userID,
  }) async {
    isLoading = true;
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null) return false;

    try {
      bool success = false;
      await APIManager().apiRequest(
        context,
        API.getuserpermissons,
        token: token,
        params: {
          'id': userID,
          'role_id': roleID
        },
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true && data['data'] != null) {
            print("User Permissions Response:");
            print(jsonEncode(data['data'])); // 🔍

            success = true;
            _parseUserPermissionData(data['data']);
          }
          notifyListeners();
        },

        onFailure: (error) {
          errorMessage = 'Error fetching user permissions: $error';
        },
      );
      return success;
    } catch (e) {
      errorMessage = 'Exception occurred: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savepermissions({
    required BuildContext context,
    required int roleID,
    required int userID,
  }) async {
    isLoading = true;
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null) return false;

    try {
      bool success = false;
      final permissionIds = getSelectedPermissionIds();

      await APIManager().apiRequest(
        context,
        API.savepermissions,
        token: token,
        params: {
          'userId': userID,
          'roleId': roleID,
          'permissions': permissionIds
        },
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true) {
            success = true;
          }
          showTopRightToast(context, data['message'], backgroundColor: Colors.green);
          notifyListeners();
        },
        onFailure: (error) {
          print(error);
          errorMessage = 'Error saving permissions: $error';
          showTopRightToast(context, error, backgroundColor: Colors.red);
        },
      );
      return success;
    } catch (e) {
      print(e);
      errorMessage = 'Exception occurred: $e';
      showTopRightToast(context, e.toString(), backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String getSelectedPermissionIds() {
    final selectedIds = <String>[];


    if (permissionStates.isEmpty) {
      return '';
    }


    permissionStates.forEach((groupName, modules) {
      modules.forEach((moduleName, permissions) {
        permissions.forEach((accessName, isSelected) {
          if (isSelected) {
            // Find the permission ID for this access name
            final permissionList = this.permissions[groupName]?[moduleName];
            if (permissionList != null) {
              for (var perm in permissionList) {
                if (perm['access_name'] == accessName) {
                  selectedIds.add(perm['id'].toString());
                  break;
                }
              }
            }
          }
        });
      });
    });

    return selectedIds.join(',');
  }
  void _parsePermissionData(Map<String, dynamic> permissionData) {
    print('📋 Starting to parse permission data...');
    print('Raw permission data: ${jsonEncode(permissionData)}');

    permissions.clear();
    permissionStates.clear();

    permissionData.forEach((groupName, modules) {
      print('\n🔷 Processing Group: $groupName');

      if (modules is Map) {
        final moduleMap = <String, List<Map<String, dynamic>>>{};

        modules.forEach((moduleName, permissionList) {
          print('  ├── Module: $moduleName');

          if (permissionList is List) {
            moduleMap[moduleName] = List<Map<String, dynamic>>.from(permissionList);

            // Initialize checkbox states
            permissionStates.putIfAbsent(groupName, () => {});
            permissionStates[groupName]!.putIfAbsent(moduleName, () => {});

            for (var permission in permissionList) {
              final accessName = permission['access_name']?.toString() ?? '';
              print('  │    ├── Permission: $accessName');

              permissionStates[groupName]![moduleName]!.putIfAbsent(
                  accessName,
                      () => false
              );
            }
          }
        });

        permissions[groupName] = moduleMap;
        groupExpansionStates[groupName] = groupExpansionStates[groupName] ?? false;
      }
    });

    print('\n✅ Final permission states structure:');
    permissionStates.forEach((group, modules) {
      print('  $group:');
      modules.forEach((module, perms) {
        print('    $module: $perms');
      });
    });
  }
  void _parseUserPermissionData(Map<String, dynamic> permissionData) {
    print('\n👤 Starting to parse USER permission data...');
    print('Raw user permission data: ${jsonEncode(permissionData)}');

    _userPermissions.clear();

    // First reset all permission states to false
    print('\n🔄 Resetting all permission states to false...');
    permissionStates.forEach((groupName, modules) {
      modules.forEach((moduleName, permissions) {
        permissions.forEach((accessName, _) {
          permissionStates[groupName]?[moduleName]?[accessName] = false;
        });
      });
    });

    // Helper function to normalize names
    String normalizeName(String name) {
      return name.toLowerCase().replaceAll(' ', '');
    }

    // Create a map of normalized group names to their original names
    final normalizedGroups = permissionStates.keys.fold<Map<String, String>>({}, (map, key) {
      map[normalizeName(key)] = key;
      return map;
    });

    permissionData.forEach((rawGroupName, modules) {
      final normalizedGroupName = normalizeName(rawGroupName);
      final groupName = normalizedGroups[normalizedGroupName];

      print('\n🔷 Processing User Group: $rawGroupName (normalized: $normalizedGroupName) → matched to: $groupName');

      if (groupName != null && modules is Map) {
        // Create a map of normalized module names to their original names for this group
        final normalizedModules = permissionStates[groupName]!.keys.fold<Map<String, String>>({}, (map, key) {
          map[normalizeName(key)] = key;
          return map;
        });

        modules.forEach((rawModuleName, permissionList) {
          final normalizedModuleName = normalizeName(rawModuleName);
          final moduleName = normalizedModules[normalizedModuleName];

          print('  ├── User Module: $rawModuleName (normalized: $normalizedModuleName) → matched to: $moduleName');

          if (moduleName != null && permissionList is List) {
            List<String> permissions = [];

            for (var permission in permissionList) {
              if (permission is Map && permission['permission'] != null) {
                String permValue = permission['permission'].toString();
                permissions.add(permValue);

                // Map permission number to access name
                String accessName = '';
                switch (permValue) {
                  case '1': accessName = 'Add'; break;
                  case '2': accessName = 'Edit'; break;
                  case '3': accessName = 'View'; break;
                  case '4': accessName = 'delete'; break;
                }
                print('  │    ├── Found permission: $permValue → $accessName');

                // Update the permission state
                if (permissionStates[groupName]![moduleName]!.containsKey(accessName)) {
                  print('  │    │    ✅ Updating state for $groupName → $moduleName → $accessName');
                  permissionStates[groupName]![moduleName]![accessName] = true;
                } else {
                  print('  │    │    ❌ No matching access name found for $accessName');
                }
              }
            }

            _userPermissions.add(UserPermission(
              groupName: groupName,
              moduleName: moduleName,
              permissions: permissions,
            ));
          }
        });
      }
    });

    print('\n✅ Final USER permission states:');
    permissionStates.forEach((group, modules) {
      print('  $group:');
      modules.forEach((module, perms) {
        print('    $module: $perms');
      });
    });

    notifyListeners();
  }

  bool hasPermission(String groupName, String moduleName, String permission) {
    // Map access name to permission number
    String permissionNumber = '';
    switch (permission) {
      case 'Add': permissionNumber = '1'; break;
      case 'Edit': permissionNumber = '2'; break;
      case 'View': permissionNumber = '3'; break;
      case 'delete': permissionNumber = '4'; break;
    }

    final hasPerm = _userPermissions.any((up) =>
    up.groupName == groupName &&
        up.moduleName == moduleName &&
        up.permissions.contains(permissionNumber)
    );

    print('🔍 Checking permission - $groupName → $moduleName → $permission ($permissionNumber): $hasPerm');
    return hasPerm;
  }

  void toggleGroupExpansion(String groupName) {
    groupExpansionStates[groupName] = !(groupExpansionStates[groupName] ?? false);
    notifyListeners();
  }

  void updatePermissionState(String groupName, String moduleName, String accessName, bool value) {
    permissionStates[groupName]?[moduleName]?[accessName] = value;
    notifyListeners();
  }

  int getSelectedCount(String groupName, String moduleName) {
    return permissionStates[groupName]?[moduleName]?.values.where((state) => state).length ?? 0;
  }
}


class UserPermissionModel {
  final int id;
  final String name;

  UserPermissionModel({
    required this.id,
    required this.name,
  });

  factory UserPermissionModel.fromJson(Map<String, dynamic> json) {
    return UserPermissionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
