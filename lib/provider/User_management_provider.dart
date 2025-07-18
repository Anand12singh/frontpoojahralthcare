import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../models/UserModel.dart';
import '../services/api_services.dart';
import '../services/auth_service.dart';
import '../widgets/showTopSnackBar.dart';

class UserManagementProvider with ChangeNotifier{
  bool isLoading = false;
  String errorMessage = '';
  List<UserModel> _users = [];
  late final int status; // 1 for Active, 0 for Deactivate
  String get statusText => status == 1 ? 'Active' : 'Deactivate';
  Color get statusColor => status == 1 ? Colors.green : Colors.red;
  List<UserModel> get users => _users;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String? selectedRole;
  bool obscurePassword = true;
  int? selectedUserId;
  List<UserModel> get user => _users;
  List<String> get userNames => _users.map((user) => user.name).toList();


  Future<void> fetchUserData(BuildContext context, {bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      notifyListeners();
    }

    errorMessage = '';

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

    await APIManager().apiRequest(
      context,
      API.getallusers,
      token: token,
      params: {'search': searchController.text},
      onSuccess: (responseBody) {
        final data = json.decode(responseBody);

        if (data['status'] == true && data['data'].isNotEmpty) {
          final List<dynamic> userList = data['data'];
          _users = userList.map((userJson) => UserModel.fromJson(userJson)).toList();
        } else {
          errorMessage = data['message'] ?? 'Users not found';
        }
      },
      onFailure: (error) {
        errorMessage = 'Error: $error';
      },
    );

    if (showLoader) {
      isLoading = false;
      notifyListeners();
    } else {
      // Notify only if UI depends on user list change (optional)
      notifyListeners();
    }
  }
  Future<void> getUserById(BuildContext context, int userId) async {

    notifyListeners();
    errorMessage = '';

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

    await APIManager().apiRequest(
      context,
      API.getUserById,
      token: token,
      params: {'id': userId},
      onSuccess: (responseBody) {
        final data = json.decode(responseBody);
        if (data['status'] == true && data['data'] != null) {
          final updatedUser = UserModel.fromJson(data['data']);

          // Update existing user in list or add if not found
          final index = _users.indexWhere((u) => u.id == userId);
          if (index >= 0) {
            _users[index] = updatedUser;
          } else {
            _users.add(updatedUser);
          }
        } else {
          errorMessage = data['message'] ?? 'User not found';
        }
      },
      onFailure: (error) {
        print("Error fetching user: $error");
        errorMessage = 'Error: $error';
      },
    );


    notifyListeners();
  }
  void clearControllers() {
    nameController.clear();
    passwordController.clear();
    selectedRole = null;
    obscurePassword = true;
    notifyListeners();
  }

  Future<void> deleteUserById(BuildContext context,int userId) async {
    try {
      isLoading = true;
      notifyListeners();

      String? token = await AuthService.getToken();
      if (token == null) return;

      await APIManager().apiRequest(
        context,
        API.deleteUserById,
        token: token,
        params: {
          "id":userId
        },
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true) {
            // Update the local user list
            fetchUserData(context);
            showTopRightToast(context, data['message'],backgroundColor: Colors.green);
            notifyListeners();
          }
        },
        onFailure: (error) {
          // Handle error
        },
      );
    } catch (e) {
      // Handle exception
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> updateUser({
    required BuildContext context,
    required int userId,
    required int? roleId,
  }) async {
    isLoading = true;
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null) return false;

    try {
      bool success = false;
      await APIManager().apiRequest(
        context,
        API.updateUserById, // Make sure you have this API endpoint
        token: token,
        params: {
          "id": userId,
          "name": nameController.text,
          "role": roleId,
          "password": passwordController.text.isNotEmpty
              ? passwordController.text
              : null,
        },
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true) {
            Navigator.of(context).pop();
            success = true;
            fetchUserData(context);
            showTopRightToast(context, data['message'], backgroundColor: Colors.green);
          } else {
            errorMessage = data['message'] ?? 'Failed to update user';
          }
        },
        onFailure: (error) {
          errorMessage = 'Error updating user: $error';
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
  Future<void> updateUserStatus(BuildContext context,int userId, int newStatus) async {
    try {

      notifyListeners();

      String? token = await AuthService.getToken();
      if (token == null) return;

      await APIManager().apiRequest(
        context,
        API.activeUserById,
        token: token,
        params: {
          'id': userId.toString(),
          'status': newStatus.toString(),
        },
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true) {
            // Update the local user list
            final index = _users.indexWhere((u) => u.id == userId);
            if (index != -1) {
              _users[index] = _users[index].copyWith(status: newStatus);
              notifyListeners();
            }
          }
        },
        onFailure: (error) {
          // Handle error
        },
      );
    } catch (e) {
      // Handle exception
    } finally {

      notifyListeners();
    }
  }
  Future<bool> addUser({
    required BuildContext context,


    required  int?  roleId,
  }) async {
    isLoading = true;
    notifyListeners();

    String? token = await AuthService.getToken();
    if (token == null) return false;

    try {
      bool success = false;
      await APIManager().apiRequest(
        context,
        API.createUser,
        token: token,
        params: {
      "name":nameController.text,
      "role":roleId,
      "password":passwordController.text

        },

        onSuccess: (responseBody) {

          final data = json.decode(responseBody);
          if (data['status'] == true) {
            Navigator.of(context).pop();
            success = true;

            fetchUserData(context);

         showTopRightToast(context, data['message'],backgroundColor: Colors.green);
          } else {
            errorMessage = data['message'] ?? 'Failed to add role';
          }
        },
        onFailure: (error) {
          errorMessage = 'Error adding role: $error';
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

}