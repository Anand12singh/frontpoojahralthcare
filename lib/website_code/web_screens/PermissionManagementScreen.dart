import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../constants/ResponsiveUtils.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
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
 
  @override
  Widget build(BuildContext context) {
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
                                flex:2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Role Name",  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                      fontSize: ResponsiveUtils.fontSize(context, 14),
                                    ),),
                                    const SizedBox(height: 6),
                                    CustomTextField(
                                      controller: roleController,
                                      hintText: 'Enter Role',
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex:2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Role Name",  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                      fontSize: ResponsiveUtils.fontSize(context, 14),
                                    ),),
                                    const SizedBox(height: 6),
                                    CustomTextField(
                                      controller: roleController,
                                      hintText: 'Enter Role',
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
                              children: [
                                buildPermissionGroup(
                                  context,
                                  title: "Masters",
                                  items: [
                                    "Categories",
                                    "Masters Teachers",
                                    "Tags",
                                    "Course list",
                                    "Plan List",
                                    "Plan Devices",
                                    "Class list",
                                  ],
                                ),
                                const SizedBox(height: 12),
                                buildPermissionGroup(
                                  context,
                                  title: "User Managements",
                                  items: [
                                    "Users",
                                    "Roles",
                                    "Permissions",
                                  ],
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

  Widget buildPermissionGroup(
      BuildContext context, {
        required String title,
        required List<String> items,
      }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(

        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        collapsedBackgroundColor: AppColors.primary.withOpacity(0.05),
        backgroundColor: AppColors.primary.withOpacity(0.05),
        initiallyExpanded: true,
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
              "0 / ${items.length}",
              style: TextStyle(
                color: Colors.grey,
                fontSize: ResponsiveUtils.fontSize(context, 14),
              ),
            ),
          ],
        ),
        children: items.map((item) {
          return Container(
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
                  flex: 3,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (val) {
                          // handle logic here
                        },
                        activeColor: AppColors.secondary,
                      ),
                      Text(
                        "Full Access",
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (val) {
                          // handle logic here
                        },
                        activeColor: AppColors.secondary,
                      ),
                      Text(
                        "View Access",
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

}


 