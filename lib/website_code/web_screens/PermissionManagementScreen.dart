
import 'package:flutter/material.dart';
import 'package:poojaheakthcare/provider/User_management_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/ResponsiveUtils.dart';
import '../../models/UserPermission.dart';
import '../../provider/PermissionService.dart';
import '../../provider/Permissoin_management_provider.dart';
import '../../provider/Role_management_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/CustomCheckbox.dart';
import '../../widgets/DropdownInput.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/showTopSnackBar.dart';
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
    _initializeData();
  }


  Future<void> _initializeData() async {
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
                                            child: Text(_toCamelCase(role)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            permissionProvider.resetUserSelection();
                                            permissionProvider.resetPermissionStates();
                                            roleProvider.selectedRoleName = val;
                                            roleProvider.selectedRoleId = roleProvider.roles
                                                .firstWhere((role) => role.roleName == val)
                                                .id;
                                            permissionProvider.selectedRoleID = roleProvider.selectedRoleId;
                                            permissionProvider.selectedUser = null;
                                            permissionProvider.selectedUserID = null;
                                            permissionProvider.getrolebyid(
                                                context: context,
                                                roleID: permissionProvider.selectedRoleID!
                                            );
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
                                        items: permissionProvider.roleUserNames.isNotEmpty
                                            ? permissionProvider.roleUserNames.map((user) {
                                          return DropdownMenuItem(
                                            value: user,
                                            child: Text(user),
                                          );
                                        }).toList()
                                            : [
                                          DropdownMenuItem<String>(
                                            value: null,
                                            child: Text(
                                              'No users found',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                            enabled: false,
                                          )
                                        ],
                                        onChanged: permissionProvider.roleUserNames.isNotEmpty
                                            ? (val) {

                                          setState(() {

                                            permissionProvider.resetPermissionStates();
                                           // permissionProvider.permissions={};
                                          //  permissionProvider.permissionStates={};
                                            permissionProvider.selectedUser = val;
                                            final selectedUser = permissionProvider.roleUsers
                                                .firstWhere((user) => user.name == val);
                                            permissionProvider.selectedUserID = selectedUser.id;
                                            print('Selected User ID from role: ${selectedUser.id}');
                                            permissionProvider.getuserpermissons(
                                                context: context,
                                                roleID: permissionProvider.selectedRoleID!,
                                                userID: permissionProvider.selectedUserID!
                                            );
                                          });
                                        }
                                            : null,
                                        label: 'User *',
                                        hintText: '---- Select User ----'

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
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                        Visibility(
                          visible: PermissionService().canEditPermissions,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Animatedbutton(
                                  onPressed: () {
                                    if (permissionProvider.selectedRoleID == null) {
                                      showTopRightToast(context, 'Please select Role', backgroundColor: Colors.red);
                                      return;
                                    }  if (permissionProvider.selectedUserID == null) {
                                      showTopRightToast(context, 'Please select User', backgroundColor: Colors.red);
                                      return;
                                    }

                                    permissionProvider.savepermissions(
                                        context: context,
                                        roleID: permissionProvider.selectedRoleID!,
                                        userID: permissionProvider.selectedUserID!
                                    );
                                  },
                                  backgroundColor: AppColors.secondary,
                                  shadowColor: AppColors.secondary,
                                  title: 'SUBMIT',
                                ),
                              ],
                            ),
                          ),
                        )
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
    final totalItems = modules.length;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

            // Get user permissions for this specific module
            final userModulePermissions = permissionProvider.userPermissions
                .firstWhere(
                  (up) => up.groupName == title && up.moduleName == moduleName,
              orElse: () => UserPermission(groupName: '', moduleName: '', permissions: []),
            )
                .permissions;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFEAEAEA),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Module name
                  Expanded(
                    flex: 3,
                    child: Text(
                      moduleName,
                      style: TextStyle(

                        fontWeight: FontWeight.w800,
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                      ),
                    ),
                  ),

                  // Permission checkboxes in a row
                  Expanded(
                    flex: 1,
                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: permissions.map((permission) {
                        return Row(

                          children: [
                            CustomCheckbox(
                              label: '',

                              initialValue: permissionProvider.permissionStates[title]?[moduleName]?[permission['access_name']] ?? false,

                              onChanged: (value) {
                                print('🔄 Checkbox changed - $title → $moduleName → ${permission['access_name']}: $value');
                                permissionProvider.updatePermissionState(
                                    title, moduleName, permission['access_name'], value);
                              },
                            ),
                            SizedBox(width: 2,),
                            Text(
                              _toCamelCase(      permission['access_name'] ?? ''),

                              style: TextStyle(

                                fontSize: ResponsiveUtils.fontSize(context, 14),
                                color: AppColors.primary,fontWeight: FontWeight.bold

                              ),
                            ),
                            SizedBox(width: 10,),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  // Count display
              /*    Expanded(
                    flex: 1,
                    child: Text(
                      "$moduleSelectedCount / ${permissions.length}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                      ),
                    ),
                  ),*/
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  String _toCamelCase(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) =>
    word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }
}