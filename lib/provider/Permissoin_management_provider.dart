// provider/permission_management_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
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

  void _parsePermissionData(Map<String, dynamic> permissionData) {
    permissions.clear();
    permissionStates.clear();

    permissionData.forEach((groupName, modules) {
      if (modules is Map) {
        final moduleMap = <String, List<Map<String, dynamic>>>{};

        modules.forEach((moduleName, permissionList) {
          if (permissionList is List) {
            moduleMap[moduleName] = List<Map<String, dynamic>>.from(permissionList);

            // Initialize checkbox states
            permissionStates.putIfAbsent(groupName, () => {});
            permissionStates[groupName]!.putIfAbsent(moduleName, () => {});

            for (var permission in permissionList) {
              permissionStates[groupName]![moduleName]!.putIfAbsent(
                  permission['access_name']?.toString() ?? '',
                      () => false
              );
            }
          }
        });

        permissions[groupName] = moduleMap;
        groupExpansionStates[groupName] = groupExpansionStates[groupName] ?? false;
      }
    });
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