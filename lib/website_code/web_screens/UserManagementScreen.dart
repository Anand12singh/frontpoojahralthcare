
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poojaheakthcare/provider/User_management_provider.dart';
import 'package:provider/provider.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../provider/PermissionService.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/custom_text_field.dart';
import 'AddUserDialog.dart';
import 'CustomSidebar.dart';
import 'SearchBar.dart';

class Usermanagementscreen extends StatefulWidget {
  const Usermanagementscreen({super.key});

  @override
  State<Usermanagementscreen> createState() => _UsermanagementscreenState();
}

class _UsermanagementscreenState extends State<Usermanagementscreen> {
  int _currentPage = 1;
  int _rowsPerPage = 100;
  int _totalRecords = 0;
    final ScrollController _scrollController = ScrollController();

  List<dynamic> _rowsPerPageOptions = [100, 'ALL'];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  Future<void> _initializeData() async {
    // Ensure widgets binding is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserManagementProvider>(context, listen: false);
      provider.fetchUserData(context);
    });
    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();
  }


  int get totalPages {
    if (_totalRecords == 0) return 1;
    return (_totalRecords / _rowsPerPage).ceil();
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int userId) async {
    await ConfirmationDialog.show(
      context: context,
      title: 'Delete User',
      message: 'Are you sure you want to delete this user? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: AppColors.secondary,
      onConfirm: () async {
        await Provider.of<UserManagementProvider>(context, listen: false)
            .deleteUserById(context, userId);
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
       final isMobile = ResponsiveUtils.isMobile(context);
    final provider = Provider.of<UserManagementProvider>(context);

   
    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F8FC),
        drawer: const Sidebar(),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 3,
          titleSpacing: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'User Management',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            if (PermissionService().canAddUsers)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const AddUserDialog(),
                    );
                  },
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar for Mobile
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: provider.searchController,
                        onChanged: (value) {
                          provider.fetchUserData(context, showLoader: false);
                        },
                        hintText: "Search User",
                        prefixIcon: Icons.search_rounded,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // User Count and Add Button (Mobile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Users ${provider.users.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (PermissionService().canAddUsers)
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const AddUserDialog(),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add User'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Loading Indicator
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),

              // Error Message
              if (provider.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      provider.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              // User List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchUserData(context);
                  },
                  child: provider.users.isEmpty && !provider.isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: AppColors.hinttext.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              if (PermissionService().canAddUsers)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            const AddUserDialog(),
                                      );
                                    },
                                    child: const Text('Add First User'),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: provider.users.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.backgroundColor,
                          ),
                          itemBuilder: (context, index) {
                            final user = provider.users[index];
                            return _buildMobileUserCard(user, context, provider);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Container(
                    child: provider.isLoading
                        ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                        :/* provider.errorMessage.isNotEmpty
                        ? Center(
                        child: Text(provider.errorMessage,
                            style: const TextStyle(color: Colors.red)))
                        :*/ Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            margin: const EdgeInsets.fromLTRB(
                                16, 16, 16, 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.hinttext
                                      .withOpacity(0.2)),
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
                                          provider.fetchUserData(context,showLoader: false);

                                        },
                                        hintText: "Search User",
                                        prefixIcon:
                                        Icons.search_rounded,
                                      ),
                                    ),
                                    Visibility(
                                      visible:PermissionService().canAddUsers ,
                                      child: Center(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: 16, right: 16),
                                          height: 50,
                                          width: ResponsiveUtils
                                              .scaleWidth(context, 160),
                                          child: Animatedbutton(
                                            title: '+ Add User',
                                            isLoading:
                                            provider.isLoading,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                barrierDismissible:
                                                false,
                                                builder: (context) =>
                                                const AddUserDialog(),
                                              );
                                            },
                                            backgroundColor:
                                            AppColors.secondary,
                                            shadowColor:
                                            AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primary
                                            .withOpacity(0.1),),
                                      borderRadius:
                                      const BorderRadius.only(
                                        topRight:
                                        Radius.circular(12),
                                        topLeft:
                                        Radius.circular(12),
                                        bottomRight:
                                        Radius.circular(12),
                                        bottomLeft:
                                        Radius.circular(12),
                                      ),),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                            const BorderRadius
                                                .only(
                                              topRight:
                                              Radius.circular(12),
                                              topLeft:
                                              Radius.circular(12),
                                            ),),
                                          child: Padding(
                                            padding: EdgeInsets
                                                .symmetric(
                                                vertical: 12.0,
                                                horizontal: 12),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                        "NAME",
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: AppColors
                                                                .primary,
                                                            fontSize: ResponsiveUtils
                                                                .fontSize(
                                                                context,
                                                                16)))),
                                              /*  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "EMAIL",
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              color: AppColors
                                                                  .primary,
                                                              fontSize:
                                                              ResponsiveUtils.fontSize(context, 16)),
                                                        ),
                                                      ],
                                                    )),*/
                                                Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            "ROLE",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: AppColors
                                                                    .primary,
                                                                fontSize: ResponsiveUtils.fontSize(
                                                                    context,
                                                                    16))),
                                                      ],
                                                    )),
                                                Visibility(
                                                  visible:PermissionService().canEditUsers ,
                                                  child: Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          "STATUS",
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              color: AppColors
                                                                  .primary,
                                                              fontSize: ResponsiveUtils
                                                                  .fontSize(
                                                                  context,
                                                                  16)))),
                                                ),
                                                Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                        "CREATED/UPDATED BY",
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: AppColors
                                                                .primary,
                                                            fontSize: ResponsiveUtils
                                                                .fontSize(
                                                                context,
                                                                16)))),
                                                if(   PermissionService().canEditUsers ||      PermissionService().canDeleteUsers )
                                                Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                        "Actions",
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: AppColors
                                                                .primary,
                                                            fontSize: ResponsiveUtils
                                                                .fontSize(
                                                                context,
                                                                16)))),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (provider.users.isNotEmpty)
                                          Expanded(
                                            child: ListView.separated(
                                              itemCount: provider
                                                  .users.length,
                                              separatorBuilder:
                                                  (context, index) =>
                                              const Divider(
                                                height: 1,
                                                thickness: 1,
                                                color: AppColors
                                                    .backgroundColor,
                                              ),
                                              itemBuilder:
                                                  (context, index) {
                                                final user = provider
                                                    .users[index];
                                                return Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      vertical:
                                                      6.0,
                                                      horizontal:
                                                      12),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                              user.name,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                  ResponsiveUtils.fontSize(context, 14)))),
                                                      /*Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                              user.email ??
                                                                  '',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                  ResponsiveUtils.fontSize(context, 14)))),*/
                                                      Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                              _toCamelCase(user.roleName),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                  ResponsiveUtils.fontSize(context, 14)))),
                                                      Visibility(
                                                        visible:PermissionService().canEditUsers ,
                                                        child: Expanded(
                                                          flex: 2,
                                                          child: _buildToggle(
                                                            context: context,
                                                            value: user.status == 1, // Convert to boolean (1 = true, 0 = false)
                                                            onChanged: (newValue) async {
                                                              await Provider.of<UserManagementProvider>(context, listen: false)
                                                                  .updateUserStatus(
                                                                  context,
                                                                  user.id,
                                                                  newValue ? 1 : 0 // Convert back to 1/0
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          DateFormat(
                                                              'dd-MM-yyyy HH:mm')
                                                              .format(
                                                              user.createdAt),
                                                          style: TextStyle(
                                                              fontSize:
                                                              ResponsiveUtils.fontSize(context, 14)),
                                                        ),
                                                      ),
                                                      if(   PermissionService().canEditUsers ||      PermissionService().canDeleteUsers )
                                                      Expanded(
                                                        flex: 1,
                                                        child: Wrap(
                                                          children: [
                                                            Visibility(
                                                              visible:PermissionService().canEditUsers ,
                                                              child: IconButton(
                                                                icon: Icon(
                                                                    Icons
                                                                        .edit_outlined,
                                                                    color:
                                                                    AppColors.primary,
                                                                    size: ResponsiveUtils.fontSize(context, 22)),
                                                                onPressed: () async {
                                                                  await Provider.of<UserManagementProvider>(context, listen: false)
                                                                      .getUserById(context, user.id);
                                                                  showDialog(
                                                                    context: context,
                                                                    barrierDismissible: false,
                                                                    builder: (context) => AddUserDialog(user: user), // Pass the user here
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible:PermissionService().canDeleteUsers ,
                                                              child: IconButton(
                                                                icon: Icon(
                                                                    Icons
                                                                        .delete_outline,
                                                                    color:
                                                                    Colors.red,
                                                                    size: ResponsiveUtils.fontSize(context, 22)),
                                                                onPressed: () => _showDeleteConfirmation(context, user.id),
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
                                          )
                                        else
                                          const Expanded(
                                            child: Center(
                                              child: Text(
                                                  "No users found"),
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
                      ],
                    ),
                  ),
                ),
                const Searchbar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: isLoading ? null : (newValue) async {
            // Check permission first
            if (!PermissionService().canEditUsers) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No permission to change status")),
              );
              return;
            }

            bool confirm = false;
            await ConfirmationDialog.show(
              context: context,
              title: 'Confirm Status Change',
              message: 'Are you sure?',
              confirmText: 'Confirm',
              confirmColor: AppColors.secondary,
              onConfirm: () => confirm = true,
              onCancel: () => confirm = false,
            );

            if (confirm) {
              onChanged(newValue);
            }
          },
          activeColor: Colors.green,
          activeTrackColor: Colors.green.shade100,
          inactiveThumbColor: Colors.grey[300],
          inactiveTrackColor: Colors.grey[400],
        ),
        Text(
          value ? 'Active' : 'Inactive',
          style: TextStyle(
            color: value ? Colors.green : Colors.red,
            fontSize: ResponsiveUtils.fontSize(context, 14),
          ),
        ),
      ],
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


  Widget _buildMobileUserCard(dynamic user, BuildContext context, UserManagementProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.status == 1
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: user.status == 1 ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    user.status == 1 ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: user.status == 1 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // User Details
            _buildMobileDetailRow(
              icon: Icons.person_outline,
              label: 'Role',
              value: _toCamelCase(user.roleName),
            ),
            const SizedBox(height: 8),

            _buildMobileDetailRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email ?? 'N/A',
            ),
            const SizedBox(height: 8),

            _buildMobileDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Created',
              value: DateFormat('dd MMM yyyy, hh:mm a').format(user.createdAt),
            ),
            const SizedBox(height: 16),

            // Actions Row
            if (PermissionService().canEditUsers ||
                PermissionService().canDeleteUsers)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Status Toggle
                  if (PermissionService().canEditUsers)
                    Expanded(
                      child: _buildMobileToggle(
                        context: context,
                        value: user.status == 1,
                        onChanged: (newValue) async {
                          bool confirm = false;
                          await ConfirmationDialog.show(
                            context: context,
                            title: 'Confirm Status Change',
                            message: 'Are you sure you want to ${newValue ? 'activate' : 'deactivate'} this user?',
                            confirmText: 'Confirm',
                            confirmColor: AppColors.secondary,
                            onConfirm: () => confirm = true,
                            onCancel: () => confirm = false,
                          );

                          if (confirm) {
                            await provider.updateUserStatus(
                              context,
                              user.id,
                              newValue ? 1 : 0,
                            );
                          }
                        },
                      ),
                    ),

                  // Edit Button
                  if (PermissionService().canEditUsers)
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        onPressed: () async {
                          await provider.getUserById(context, user.id);
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AddUserDialog(user: user),
                          );
                        },
                      ),
                    ),

                  // Delete Button
                  if (PermissionService().canDeleteUsers)
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 22,
                        ),
                        onPressed: () => _showDeleteConfirmation(context, user.id),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.hinttext,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.hinttext,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Switch(
          value: value,
          onChanged: (newValue) async {
            if (!PermissionService().canEditUsers) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No permission to change status")),
              );
              return;
            }
            onChanged(newValue);
          },
          activeColor: Colors.green,
          activeTrackColor: Colors.green.shade100,
          inactiveThumbColor: Colors.grey[300],
          inactiveTrackColor: Colors.grey[400],
        ),
        Text(
          value ? 'Active' : 'Inactive',
          style: TextStyle(
            color: value ? Colors.green : Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}
