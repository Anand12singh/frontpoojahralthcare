import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/role_model.dart';
import '../services/api_services.dart';
import '../services/auth_service.dart';
import '../widgets/showTopSnackBar.dart';

class RoleManagementProvider with ChangeNotifier {
  List<Role> _roles = [];
  bool isLoading = false;
  String errorMessage = '';
  String? selectedRoleName;
  int? selectedRoleId;
  List<Role> get roles => _roles;
  List<String> get roleNames => _roles.map((role) => role.roleName).toList();
  TextEditingController searchController = TextEditingController();
bool isupdate=false;
  bool updateSuccess = false;
  final TextEditingController roleController = TextEditingController();

  // Add these properties to your provider
  int? _editingRoleId;
  bool get isEditing => _editingRoleId != null;

  // In RoleManagementProvider
  void startEditing(Role role) {
    _editingRoleId = role.id;
    updateSuccess = false;
    roleController.text = role.roleName ?? '';
    notifyListeners(); // This is crucial
  }

  void cancelEditing() {
    _editingRoleId = null;
    updateSuccess = false;
    roleController.clear();
    notifyListeners(); // This is crucial
  }
// Modify your addRole method to handle both cases
  Future<bool> saveRole({
    required BuildContext context,
  }) async {
    if (roleController.text.isEmpty) return false;

    if (isEditing) {
      return await updateRole(
        context: context,
        roleId: _editingRoleId!,
        roleName: roleController.text,
      );
    } else {
      return await addRole(
        context: context,
        roleName: roleController.text,
      );
    }
  }

  Future<void> fetchRoleData(BuildContext context, {bool showLoader = true}) async {

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      Navigator.of(context).pop();
      showTopRightToast(
        context,
        'Authentication token not found. Please login again.',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      await APIManager().apiRequest(
        context,
        API.getAllRoles,
        token: token,
        params: {'search': searchController.text},
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);

          if (data['status'] == true && data['data'] != null) {
            final List<dynamic> roleList = data['data'];
            _roles = roleList.map((json) => Role.fromJson(json)).toList();
            notifyListeners();
          } else {
            errorMessage = data['message'] ?? 'No roles found';
          }
          isLoading = false;
          notifyListeners();
        },
        onFailure: (error) {
          print(errorMessage);
          print(error);
          errorMessage = 'Error fetching roles: $errorMessage';
          isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      errorMessage = 'Exception occurred: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  // Add a new role
  Future<bool> addRole({
    required BuildContext context,
    required String roleName,

  }) async {
    isLoading = true;
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null) return false;

    try {
      bool success = false;
      await APIManager().apiRequest(
        context,
        API.createRole,
        token: token,
        params: {
          'role_name': roleController.text,

        },
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true) {
            success = true;
            roleController.clear();
            fetchRoleData(context);
            showTopRightToast(context, data['message'],backgroundColor: Colors.green);
          } else {
            showTopRightToast(context, data['message'],backgroundColor: Colors.red);
            //errorMessage = data['message'] ?? 'Failed to add role';
          }

          notifyListeners();
        },
        onFailure: (error) {
          print(error);
        //  errorMessage = 'Error adding role: $error';
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
  Future<bool> updateRole({
    required BuildContext context,
    required int roleId,
    required String roleName,
  }) async {
    isLoading = true;
    updateSuccess = false; // Reset success flag
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null) return false;

    try {
      bool success = false;
      await APIManager().apiRequest(
        context,
        API.updateRoleById,
        token: token,
        params: {
          'id': roleId.toString(),
          'role_name': roleName,
        },
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true) {
            success = true;
            updateSuccess = true; // Set success flag
            fetchRoleData(context);
            showTopRightToast(
              context,
              data['message'] ?? 'Role updated successfully',
              backgroundColor: Colors.green,
            );
          } else {
            errorMessage = data['message'] ?? 'Failed to update role';
           // showTopRightToast(context, errorMessage, backgroundColor: Colors.red);
          }
        },
        onFailure: (error) {
          errorMessage = 'Error updating role: $error';
          showTopRightToast(context, errorMessage, backgroundColor: Colors.red);
        },
      );
      return success;
    } catch (e) {
      errorMessage = 'Exception occurred: $e';
      showTopRightToast(context, errorMessage, backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading = false;
      if (updateSuccess) {
        _editingRoleId = null; // Only reset if update was successful
      }
      notifyListeners();
    }
  }

  // Delete a role
  Future<bool> deleteRole({
    required BuildContext context,
    required int roleId,
  }) async {
    isLoading = true;
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null) return false;

    try {
      bool success = false;
      await APIManager().apiRequest(
        context,
        API.deleteRoleById,
        token: token,
        params: {'id': roleId.toString()},
        onSuccess: (responseBody) async {  // Make this async
          final data = json.decode(responseBody);
          if (data['status'] == true) {
            success = true;
            // Remove the role from local list immediately
            _roles.removeWhere((role) => role.id == roleId);
            notifyListeners(); // Notify after local removal

            // Then refresh from server
            await fetchRoleData(context);
            showTopRightToast(context, "Role deleted successfully.", backgroundColor: Colors.green);
          } else {
            errorMessage = data['message'] ?? 'Failed to delete role';
            notifyListeners();
          }
        },
        onFailure: (error) {
          errorMessage = 'Error deleting role: $error';
          notifyListeners();
        },
      );
      return success;
    } catch (e) {
      errorMessage = 'Exception occurred: $e';
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}