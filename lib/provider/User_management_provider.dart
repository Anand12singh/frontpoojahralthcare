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

  List<UserModel> get users => _users;


  Future<void> fetchUserData(BuildContext context) async {

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
    await APIManager().apiRequest(
      context,
      API.getallusers,
      token: token,
      params: {'search': ''},
      onSuccess: (responseBody) {
        final data = json.decode(responseBody);

        if (data['status'] == true && data['data'].isNotEmpty) {
          final List<dynamic> userList = data['data'];
          _users = userList.map((userJson) => UserModel.fromJson(userJson)).toList();
print("_users");
print(_users);
          isLoading = false;
          notifyListeners(); // Trigger UI update

        } else {

            isLoading = false;
            errorMessage = data['message'] ?? 'Users not found';
            notifyListeners();
        }
      },
      onFailure: (error) {

          isLoading = false;
          errorMessage = 'Error: $error';
          notifyListeners();
      },
    );
  }

}