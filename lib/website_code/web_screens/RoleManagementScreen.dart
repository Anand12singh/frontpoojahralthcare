// ignore_for_file: prefer_final_fields, deprecated_member_use, unnecessary_to_list_in_spreads, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../provider/PermissionService.dart';
import '../../provider/Role_management_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/showTopSnackBar.dart';
import 'CustomSidebar.dart';
import 'SearchBar.dart';
class Rolemanagementscreen extends StatefulWidget {
  const Rolemanagementscreen({super.key});

  @override
  State<Rolemanagementscreen> createState() => _RolemanagementscreenState();
}

class _RolemanagementscreenState extends State<Rolemanagementscreen> {

  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _totalRecords = 0;


  List<dynamic> _rowsPerPageOptions = [ 10, 20, 50,100,'ALL'];

  int get totalPages {
    if (_totalRecords == 0) return 1;
    return (_totalRecords / _rowsPerPage).ceil();
  }

  @override
  void initState() {
    super.initState();

    // Create and call an async function immediately
    _initializeData();
  }

// Separate async function for initialization
  Future<void> _initializeData() async {
    // Ensure widgets binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Wait for permission service initialization
    await PermissionService().initialize();

    // Fetch role data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<RoleManagementProvider>(context, listen: false);
      await provider.fetchRoleData(context);
    });
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int roleId) async {
    await ConfirmationDialog.show(
      context: context,
      title: 'Delete Role',
      message: 'Are you sure you want to delete this role? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: AppColors.secondary,
      onConfirm: () async {
        await Provider.of<RoleManagementProvider>(context, listen: false)
            .deleteRole(context: context, roleId:roleId );
      },
    );
  }
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}'; // Format as DD/MM/YYYY
    } catch (e) {
      return isoDate; // Return original string if parsing fails
    }
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


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoleManagementProvider>(context, listen: false);
        final isMobile = ResponsiveUtils.isMobile(context);
       if (isMobile) {
  final provider = Provider.of<RoleManagementProvider>(context);

  return Scaffold(
    backgroundColor: const Color(0xFFEAF2FF),
    appBar: AppBar(
      title: const Text('Role Management'),
    ),
    drawer: Drawer(child: Sidebar()),
    body: provider.isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        : ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Role Form
              Visibility(
                visible: PermissionService().canAddRoles ||
                    PermissionService().canEditRoles,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.hinttext.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Role Name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: provider.roleController,
                        hintText: 'Enter Role',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Animatedbutton(
                              shadowColor: Colors.transparent,
                              title:
                                  provider.isEditing ? 'Update' : 'Save',
                              backgroundColor: AppColors.secondary,
                              onPressed: () async {
                                await provider.saveRole(context: context);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Animatedbutton(
                              shadowColor: Colors.transparent,
                              title: 'Cancel',
                              backgroundColor: Colors.white,
                              borderColor: AppColors.red,
                              titlecolor: AppColors.red,
                              onPressed: provider.cancelEditing,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Search
              CustomTextField(
                controller: provider.searchController,
                hintText: "Search Roles",
                prefixIcon: Icons.search_rounded,
                onChanged: (v) {
                  provider.fetchRoleData(context, showLoader: false);
                },
              ),

              const SizedBox(height: 12),

              // Role List
              ...provider.roles.map((role) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.hinttext.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _toCamelCase(role.roleName),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Created: ${_formatDate(role.createdAt.toString())}",
                          ),
                       
                        ],
                      ),
                         Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (PermissionService().canEditRoles)
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                              shape: BoxShape.circle, 
                              color: AppColors.primary.withOpacity(0.1)
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: AppColors.primary,
                                      size: 22),
                                onPressed: () {
                                  Provider.of<RoleManagementProvider>(
                                          context,
                                          listen: false)
                                      .startEditing(role);
                                },
                              ),
                            ),
                          
                          SizedBox(width: 12),
                          if (PermissionService().canDeleteRoles)
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.red.withOpacity(0.1)
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red,
                                      size: 22,),
                                onPressed: () {
                                  _showDeleteConfirmation(
                                      context, role.id);
                                },
                              ),
                            ),
                        ],
                      ),
                 
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 16),

          
            ],
          ),
  );



}

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
                    child:  provider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : provider.errorMessage.isNotEmpty
                        ? Center(child: Text(provider.errorMessage, style: const TextStyle(color: Colors.red)))
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Visibility(
                          visible: PermissionService().canAddRoles || PermissionService().canEditRoles,
                          child: Consumer<RoleManagementProvider>(
                            builder: (context, provider, child) {
                              return Container(
                                padding: EdgeInsets.all(12),
                                margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Role Name", style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                            fontSize: ResponsiveUtils.fontSize(context, 14),
                                          )),
                                          const SizedBox(height: 6),
                                          CustomTextField(
                                            controller: provider.roleController,
                                            hintText: 'Enter Role',
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))
                                            ],
                                            enabled: PermissionService().canAddRoles ||
                                                (PermissionService().canEditRoles && provider.isEditing),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                       
                                          if ((PermissionService().canAddRoles && !provider.isEditing) ||
                                              (PermissionService().canEditRoles && provider.isEditing))
                                            SizedBox(
                                              width: 150,
                                              child: Animatedbutton(
                                                onPressed: () async {
                                                  final name = provider.roleController.text.trim();
                                                  if (name.isEmpty) {
                                                    showTopRightToast(
                                                      context,
                                                      'Please enter a Role',
                                                      backgroundColor: Colors.red,
                                                    );
                                                    return;
                                                  }
                                                  final success = await provider.saveRole(context: context);
                                                  if (success) {
                                                    provider.cancelEditing();
                                                  }
                                                },
                                                shadowColor: Colors.transparent,
                                                title: provider.isEditing ? 'Update' : 'Save',
                                                backgroundColor: AppColors.secondary,
                                              ),
                                            ),
                                          if ((PermissionService().canAddRoles && !provider.isEditing) ||
                                              (PermissionService().canEditRoles && provider.isEditing))
                                            const SizedBox(width: 16),
                                          if ((PermissionService().canAddRoles && !provider.isEditing) ||
                                              (PermissionService().canEditRoles && provider.isEditing))
                                          Animatedbutton(
                                            onPressed: () {
                                              Provider.of<RoleManagementProvider>(context, listen: false)
                                                  .cancelEditing();
                                            },
                                            shadowColor: Colors.transparent,
                                            titlecolor: AppColors.red,
                                            title: 'Cancel',
                                            backgroundColor: Colors.white,
                                            borderColor: AppColors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                        ),

                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),

                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                            ),
                            child: Column(
                              spacing: 10,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Row(

                                            children: [
                                         
                                            ],
                                          ),



                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      flex: 1,
                                      child: CustomTextField(
                                        controller: provider.searchController,
                                        onChanged: (p0) {
                                          provider.fetchRoleData(context,showLoader: false);
                                        },
                                        hintText: "Search Roles",
                                        prefixIcon: Icons.search_rounded,
                                      ),
                                    ),

                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(border: Border.all(color: AppColors.primary.withOpacity(0.1),),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        topLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),

                                      ),),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(12),
                                              topLeft: Radius.circular(12),
                                            ),
                                          ),
                                          child:  Padding(
                                            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                                            child: Row(
                                              children: [
                                                Expanded(flex: 2, child: Text("NAME", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                                              Expanded(flex: 2, child: Text("CREATED/UPDATED BY", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                                                if(PermissionService().canEditRoles ||PermissionService().canDeleteRoles )
                                                Expanded(flex: 1, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Consumer<RoleManagementProvider>(
                                            builder: (context, roleProvider, child) {
                                            return Expanded(
                                              child: ListView.separated(
                                                itemCount: provider
                                                    .roles.length,
                                                separatorBuilder: (context, index) => const Divider( height: 1,
                                                    thickness: 1,
                                                    color: AppColors.backgroundColor),
                                                itemBuilder: (context, index) {
                                                  final role =  provider
                                                      .roles[index];
                                            
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
                                                    child: Row(
                                                      children: [
                                                        Expanded(flex: 2, child: Text(_toCamelCase(role.roleName),style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                        Expanded(flex: 2, child: Text(  _formatDate(role.createdAt.toString())
                                                            ,style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                if(PermissionService().canEditRoles ||PermissionService().canDeleteRoles )
                                                        Expanded(
                                                          flex: 1,
                                                          child: Wrap(
                                                            children: [
                                            
                                                              Visibility(
                                                                visible:PermissionService().canEditRoles ,
                                                                child: IconButton(
                                                                  icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                                                                  onPressed: () {
                                                                    Provider.of<RoleManagementProvider>(context, listen: false)
                                                                        .startEditing(role);
                                                                  },
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible:PermissionService().canDeleteRoles ,
                                                                child: IconButton(
                                                                  icon:  Icon(Icons.delete_outline, color: Colors.red,size:  ResponsiveUtils.fontSize(context, 22),),
                                                                  onPressed: () {
                                                                    _showDeleteConfirmation(context,role.id);
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          }
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                       
                              ],
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
  List<Widget> _buildPageButtons() {
    int maxButtons = 5;
    int startPage = (_currentPage - (maxButtons ~/ 2)).clamp(1, totalPages);
    int endPage = (startPage + maxButtons - 1).clamp(1, totalPages);

    if (endPage - startPage < maxButtons - 1) {
      startPage = (endPage - maxButtons + 1).clamp(1, totalPages);
    }

    List<Widget> buttons = [];
    for (int i = startPage; i <= endPage; i++) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              i == _currentPage ? AppColors.secondary : Colors.white,
              foregroundColor:
              i == _currentPage ? Colors.white : AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size(0, 36),
            ),
            onPressed: () {
              setState(() {
                _currentPage = i;
              });

            },
            child: Text(i.toString()),
          ),
        ),
      );
    }
    return buttons;
  }

}


 