import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:poojaheakthcare/provider/Role_management_provider.dart';
import 'package:poojaheakthcare/provider/User_management_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/ResponsiveUtils.dart';
import '../../models/UserModel.dart';
import '../../models/role_model.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/DropdownInput.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/showTopSnackBar.dart';


class AddUserDialog extends StatefulWidget {
  final UserModel? user; // Add this line

  const AddUserDialog({super.key, this.user}); // Modify constructor


  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {


@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<UserManagementProvider>(context, listen: false);
    final roleProvider = Provider.of<RoleManagementProvider>(context, listen: false);

    // Fetch roles first
    roleProvider.fetchRoleData(context).then((_) {
      // If editing an existing user, populate the fields
      if (widget.user != null) {
        provider.nameController.text = widget.user!.name;
        provider.selectedRole = widget.user!.roleName;
        provider.passwordController.text = ''; // Clear password for editing

        // Find and set the role ID using the correct Role class
        final role = roleProvider.roles.firstWhere(
                (r) => r.roleName == widget.user!.roleName,
            orElse: () => Role(
              id: 0,
              roleName: '',
              permissionIds: [],
              status: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
        );
        if (role.id != 0) {
          roleProvider.selectedRoleId = role.id;
        }
      }
    });
  });
}

void _resetFormFields() {
  final provider = Provider.of<UserManagementProvider>(context, listen: false);
  final roleProvider = Provider.of<RoleManagementProvider>(context, listen: false);

  provider.nameController.clear();
  provider.passwordController.clear();
  provider.selectedRole = null;
  provider.obscurePassword = true;

  roleProvider.selectedRoleId = 0;
}
@override
void dispose() {
  _resetFormFields();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserManagementProvider>(context);
    final roleprovider = Provider.of<RoleManagementProvider>(context);
    return WillPopScope(

      onWillPop: () async {
        _resetFormFields();
        return true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 700,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(

                    widget.user == null ? 'Add user' : 'Update user',

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _resetFormFields();
                      Navigator.of(context).pop();
                    },

                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name *",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: ResponsiveUtils.fontSize(context, 14),
                            )),
                        const SizedBox(height: 6),
                        CustomTextField(
                          controller: provider.nameController,
                          hintText: 'Enter name',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          ],
                        ),

                      ],
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: DropdownInput<String>(
                            value: provider.selectedRole,
                            items: roleprovider.roleNames.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                provider.selectedRole = val;
                                roleprovider.selectedRoleId = roleprovider.roles
                                    .firstWhere((role) => role.roleName == val)
                                    .id;
                                print(roleprovider.selectedRoleId);
                              });
                            },
                            label: 'Role *',
                            hintText: '---- Select Role ----',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Password *",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: ResponsiveUtils.fontSize(context, 14),
                            )),
                        const SizedBox(height: 6),
                        CustomTextField(
                          hintText: 'Password',
                          controller: provider.passwordController,
                          obscureText:  provider.obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon( provider.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                provider.obscurePassword = ! provider.obscurePassword;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Animatedbutton(
                    onPressed: () {

                      _resetFormFields();
                      Navigator.of(context).pop();
                    },
                    shadowColor: AppColors.primary,
                    titlecolor: AppColors.red,
                    title: 'Close',
                    backgroundColor: Colors.white,
                    borderColor: AppColors.red,
                  ),
                  const SizedBox(width: 16),
                  Animatedbutton(
                    onPressed: () {
                      final name = provider.nameController.text.trim();
                      final role = provider.selectedRole;
                      final password = provider.passwordController.text;

                      if (name.isEmpty) {
                        showTopRightToast(
                          context,
                          'Please enter a valid name',
                          backgroundColor: Colors.red,
                        );
                        return;
                      }

                      if (role == null || role.isEmpty) {
                        showTopRightToast(
                          context,
                          'Please select a valid role',
                          backgroundColor: Colors.red,
                        );
                        return;
                      }

                      if (widget.user == null) {
                        // Only validate password when adding a new user
                        if (password.isEmpty) {
                          showTopRightToast(
                            context,
                            'Password cannot be empty',
                            backgroundColor: Colors.red,
                          );
                          return;
                        }

                        if (password.length < 6) {
                          showTopRightToast(
                            context,
                            'Password must be at least 6 characters',
                            backgroundColor: Colors.red,
                          );
                          return;
                        }

                        final passwordPattern =
                            r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$';

                        if (!RegExp(passwordPattern).hasMatch(password)) {
                          showTopRightToast(
                            context,
                            'Password must include at least 1 uppercase letter, 1 number, and 1 special character',
                            backgroundColor: Colors.red,
                          );
                          return;
                        }

                        provider.addUser(
                          context: context,
                          roleId: roleprovider.selectedRoleId,
                        );
                      } else {

                        if (password.isEmpty) {
                          showTopRightToast(
                            context,
                            'Password cannot be empty',
                            backgroundColor: Colors.red,
                          );
                          return;
                        }

                        if (password.length < 6) {
                          showTopRightToast(
                            context,
                            'Password must be at least 6 characters',
                            backgroundColor: Colors.red,
                          );
                          return;
                        }

                        final passwordPattern =
                            r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$';

                        if (!RegExp(passwordPattern).hasMatch(password)) {
                          showTopRightToast(
                            context,
                            'Password must include at least 1 uppercase letter, 1 number, and 1 special character',
                            backgroundColor: Colors.red,
                          );
                          return;
                        }
                        // Update existing user
                        provider.updateUser(
                          context: context,
                          userId: widget.user!.id,
                          roleId: roleprovider.selectedRoleId,
                        );
                      }
                    },

                    shadowColor: AppColors.primary,
                    title: widget.user == null ? 'Save' : 'Update',
                    backgroundColor: AppColors.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}