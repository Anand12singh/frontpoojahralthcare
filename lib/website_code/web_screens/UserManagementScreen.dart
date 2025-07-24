import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poojaheakthcare/provider/User_management_provider.dart';
import 'package:poojaheakthcare/services/auth_service.dart';
import 'package:poojaheakthcare/widgets/showTopSnackBar.dart';
import 'package:provider/provider.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../provider/PermissionService.dart';
import '../../services/api_services.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/DropdownInput.dart';
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
    final provider = Provider.of<UserManagementProvider>(context);

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
                                      /*        const Text('Show '),
                                              const SizedBox(width: 8),
                                              DropdownButton2<dynamic>(
                                                dropdownStyleData:
                                                DropdownStyleData(
                                                    decoration:
                                                    BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.all(Radius.circular(12)))),
                                                value: _rowsPerPage,
                                                items: _rowsPerPageOptions
                                                    .map((dynamic
                                                value) {
                                                  return DropdownMenuItem<
                                                      dynamic>(
                                                    value: value,
                                                    child: Text(value
                                                        .toString()),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                              ),*/
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
                                      visible:true ,//PermissionService().canAddUsers ,
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
                                                Expanded(
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
                                                      Expanded(
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
                      /*          Padding(
                                  padding:
                                  const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                          'Showing 1 to 20 of $_totalRecords records'),
                                      Row(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [
                                              IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .first_page),
                                                  onPressed:
                                                      () {}),
                                              IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .chevron_left),
                                                  onPressed:
                                                      () {}),
                                              ..._buildPageButtons(),
                                              IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .chevron_right),
                                                  onPressed:
                                                      () {}),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons
                                                        .last_page),
                                                onPressed: () {},
                                              ),
                                              const SizedBox(
                                                  width: 16),
                                              SizedBox(
                                                width: 50,
                                                height: 30,
                                                child:
                                                TextFormField(
                                                  initialValue:
                                                  "1",
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                  keyboardType:
                                                  TextInputType
                                                      .number,
                                                  decoration:
                                                  InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical:
                                                        6,
                                                        horizontal:
                                                        8),
                                                    border:
                                                    OutlineInputBorder(),
                                                  ),
                                                  onFieldSubmitted:
                                                      (value) {},
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text("of 10 pages"),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),*/
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
    return  Row(
      children: [
        Switch(
          value: value,
          onChanged: isLoading ? null : onChanged,
          activeColor:Colors.green ,
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
}
class StatusWidget extends StatelessWidget {
  final int status;
  final Function(int) onChanged;

  const StatusWidget({
    super.key,
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 1 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 1 ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: status,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          iconSize: 16,
          elevation: 0,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 14),
            color: status == 1 ? Colors.green : Colors.red,
          ),
          onChanged: (int? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: [
            DropdownMenuItem<int>(
              value: 1,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Active'),
                ],
              ),
            ),
            DropdownMenuItem<int>(
              value: 0,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Deactivate'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}