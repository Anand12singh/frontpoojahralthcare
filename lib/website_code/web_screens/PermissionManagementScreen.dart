
import 'package:flutter/material.dart';
import 'package:poojaheakthcare/provider/User_management_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/ResponsiveUtils.dart';
import '../../provider/Permissoin_management_provider.dart';
import '../../provider/Role_management_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/CustomCheckbox.dart';
import '../../widgets/DropdownInput.dart';
import '../../widgets/custom_text_field.dart';
import 'CustomSidebar.dart';
import 'SearchBar.dart';
class Permissionmanagementscreen extends StatefulWidget {
  const Permissionmanagementscreen({super.key});

  @override
  State<Permissionmanagementscreen> createState() => _PermissionmanagementscreenState();
}

class _PermissionmanagementscreenState extends State<Permissionmanagementscreen> {
  bool isLoading = false;
  String errorMessage = '';
  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _totalRecords = 0;
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  TextEditingController searchController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  List<dynamic> _rowsPerPageOptions = [ 10, 20, 50,100,'ALL'];


  int get totalPages {
    if (_totalRecords == 0) return 1;
    return (_totalRecords / _rowsPerPage).ceil();
  }
  bool add = false;
  bool edit = false;
  bool delete = false;
  bool view = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserManagementProvider>(context, listen: false);
      final roleProvider = Provider.of<RoleManagementProvider>(context, listen: false);
      final permissionProvider = Provider.of<PermissoinManagementProvider>(context, listen: false);
      permissionProvider.fetchPermissions(context);
      // Fetch both users and roles
      userProvider.fetchUserData(context);
      roleProvider.fetchRoleData(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserManagementProvider>(context);
    final roleProvider = Provider.of<RoleManagementProvider>(context);
    final permissionProvider = Provider.of<PermissoinManagementProvider>(context);


    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      body: Row(
        children: [

          Sidebar(),
          Expanded(
            child: Stack(

              children: [
                Padding(

                  padding: const EdgeInsets.only(top: 80),
                  child: Container(
                    child:  isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : errorMessage.isNotEmpty
                        ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                          padding: EdgeInsets.all(12),

                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                          ),
                          child: Row(
                            spacing: 20,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: DropdownInput<String>(
                                        value: roleProvider.selectedRoleName,
                                        items: roleProvider.roleNames.map((role) {
                                          return DropdownMenuItem(
                                            value: role,
                                            child: Text(role),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            roleProvider.selectedRoleName = val;
                                            roleProvider.selectedRoleId = roleProvider.roles
                                                .firstWhere((role) => role.roleName == val)
                                                .id;
                                            permissionProvider.selectedRoleID=roleProvider.selectedRoleId;
                                            print('Selected Role ID: ${roleProvider.selectedRoleId}');
                                          });
                                        },
                                        label: 'Role *',
                                        hintText: '---- Select Role ----',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: DropdownInput<String>(
                                        value: permissionProvider.selectedUser,
                                        items: userProvider.userNames.map((user) {
                                          return DropdownMenuItem(
                                            value: user,
                                            child: Text(user),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            permissionProvider.selectedUser = val;
                                            final selectedUser = userProvider.users
                                                .firstWhere((user) => user.name == val);
                                            userProvider.selectedUserId = selectedUser.id;
                                            permissionProvider.selectedUserID = selectedUser.id;


                                            print('Selected User ID: ${selectedUser.id}');
                                          });
                                        },
                                        label: 'User *',
                                        hintText: '---- Select User ----',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.hinttext.withOpacity(0.2),
                              ),
                            ),
                            child: ListView(

                              children: permissionProvider.permissions.entries.map((groupEntry) {
                                final groupName = groupEntry.key;
                                final modules = groupEntry.value;

                                return buildPermissionGroup(
                                  context,
                                  title: groupName,
                                  modules: modules,
                                  permissionProvider: permissionProvider,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Searchbar(),

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget buildPermissionGroup(
      BuildContext context, {
        required String title,
        required Map<String, List<Map<String, dynamic>>> modules,
        required PermissoinManagementProvider permissionProvider,
      }) {
    final totalItems = modules.length; // Count of modules (User, Roles, Permissions)
    final selectedCount = modules.entries.fold<int>(0, (sum, entry) {
      final modulePermissions = entry.value;
      return sum + (modulePermissions.any((perm) =>
      permissionProvider.permissionStates[title]?[entry.key]?[perm['access_name']] ?? false) ? 1 : 0);
      });

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          collapsedBackgroundColor: AppColors.primary.withOpacity(0.05),
          backgroundColor: AppColors.primary.withOpacity(0.05),
          initiallyExpanded: permissionProvider.groupExpansionStates[title] ?? false,
          onExpansionChanged: (expanded) {
            permissionProvider.toggleGroupExpansion(title);
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                ),
              ),
              Text(
                "$selectedCount / $totalItems",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                ),
              ),
            ],
          ),
          children: modules.entries.map((moduleEntry) {
            final moduleName = moduleEntry.key;
            final permissions = moduleEntry.value;

            // Count selected permissions for this module
            final moduleSelectedCount = permissions.where((perm) =>
            permissionProvider.permissionStates[title]?[moduleName]?[perm['access_name']] ?? false).length;

            return Column(
              children: [
                // Module header row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFEAEAEA),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          moduleName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.fontSize(context, 14),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "$moduleSelectedCount / ${permissions.length}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: ResponsiveUtils.fontSize(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Permission checkboxes
                ...permissions.map((permission) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24), // Indented
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFEAEAEA),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              permission['access_name'] ?? '',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, 14),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              CustomCheckbox(
                                label: '',
                                initialValue: permissionProvider.permissionStates[title]?[moduleName]?[permission['access_name']] ?? false,
                                onChanged: (value) {
                                  permissionProvider.updatePermissionState(
                                      title, moduleName, permission['access_name'], value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}