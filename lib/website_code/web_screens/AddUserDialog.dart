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
  final UserModel? user;

  const AddUserDialog({super.key, this.user});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  bool _isPasswordVisible = false;
  
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
    _isPasswordVisible = false;
  }

  @override
  void dispose() {
    _resetFormFields();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserManagementProvider>(context);
    final roleProvider = Provider.of<RoleManagementProvider>(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile) {
      return _buildMobileDialog(context, provider, roleProvider, screenWidth);
    }

    return _buildWebDialog(context, provider, roleProvider);
  }

  Widget _buildMobileDialog(BuildContext context, UserManagementProvider provider, RoleManagementProvider roleProvider, double screenWidth) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: screenWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.user == null ? 'Add User' : 'Update User',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () {
                      _resetFormFields();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 20),

              // Name Field
              _buildMobileLabel('Name *'),
              const SizedBox(height: 6),
              CustomTextField(
                controller: provider.nameController,
                hintText: 'Enter user name',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                ],
              ),
              const SizedBox(height: 20),

              // Role Field
              _buildMobileLabel('Role *'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedRole,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '---- Select Role ----',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    items: roleProvider.roleNames.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            role,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        provider.selectedRole = val;
                        if (val != null) {
                          roleProvider.selectedRoleId = roleProvider.roles
                              .firstWhere((role) => role.roleName == val)
                              .id;
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildMobileLabel(
                  widget.user == null ? 'Password *' : 'Password (Leave empty to keep current)'),
              const SizedBox(height: 6),
              CustomTextField(
                hintText: 'Enter password',
                controller: provider.passwordController,
                obscureText: !_isPasswordVisible,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.hinttext,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              if (widget.user == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Password must:\n'
                        '• Be at least 6 characters long\n'
                        '• Include 1 uppercase letter\n'
                        '• Include 1 number\n'
                        '• Include 1 special character',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              const SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.red,
                        side: BorderSide(color: AppColors.red, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _resetFormFields();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        _validateAndSubmit(context, provider, roleProvider);
                      },
                      child: Text(
                        widget.user == null ? 'Save' : 'Update',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebDialog(BuildContext context, UserManagementProvider provider, RoleManagementProvider roleProvider) {
    return Dialog(
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
                        hintText: 'Enter user name',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-z]')),
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
                          items: roleProvider.roleNames.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              provider.selectedRole = val;
                              roleProvider.selectedRoleId = roleProvider.roles
                                  .firstWhere((role) => role.roleName == val)
                                  .id;
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
                      Text("Password",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontSize: ResponsiveUtils.fontSize(context, 14),
                          )),
                      const SizedBox(height: 6),
                      CustomTextField(
                        hintText: 'Password',
                        controller: provider.passwordController,
                        obscureText: provider.obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(provider.obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              provider.obscurePassword = !provider.obscurePassword;
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
                    _validateAndSubmit(context, provider, roleProvider);
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
    );
  }

  Widget _buildMobileLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontSize: 14,
      ),
    );
  }

  void _validateAndSubmit(BuildContext context, UserManagementProvider provider, RoleManagementProvider roleProvider) {
    final name = provider.nameController.text.trim();
    final role = provider.selectedRole;
    final password = provider.passwordController.text;

    if (name.isEmpty) {
      _showMobileToast(context, 'Please enter a valid name');
      return;
    }

    if (role == null || role.isEmpty) {
      _showMobileToast(context, 'Please select a valid role');
      return;
    }

    if (widget.user == null) {
      // Only validate password when adding a new user
      if (password.isEmpty) {
        _showMobileToast(context, 'Password cannot be empty');
        return;
      }

      if (password.length < 6 ) {
        _showMobileToast(context, 
            'Password must:\n'
            '- Be at least 6 characters long\n'
            '- Include 1 uppercase letter\n'
            '- Include 1 number\n'
            '- Include 1 special character'
            );
        return;
      }

      provider.addUser(
        context: context,
        roleId: roleProvider.selectedRoleId,
      );
    } else {
      // For updating user
      if (password.isNotEmpty) {
        if (password.length < 6 || !RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password)) {
          _showMobileToast(context,
              'Password must:\n'
              '- Be at least 6 characters long\n'
              '- Include 1 uppercase letter\n'
              '- Include 1 number\n'
              '- Include 1 special character');
          return;
        }
      }
      
      provider.updateUser(
        context: context,
        userId: widget.user!.id,
        roleId: roleProvider.selectedRoleId,
      );
    }
  }

  void _showMobileToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}