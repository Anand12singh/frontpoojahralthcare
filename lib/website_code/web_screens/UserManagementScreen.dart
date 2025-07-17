import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:poojaheakthcare/provider/User_management_provider.dart';
import 'package:poojaheakthcare/services/auth_service.dart';
import 'package:poojaheakthcare/widgets/showTopSnackBar.dart';
import 'package:provider/provider.dart';

import '../../constants/ResponsiveUtils.dart';
import '../../services/api_services.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/DropdownInput.dart';
import '../../widgets/custom_text_field.dart';
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
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  TextEditingController searchController = TextEditingController();
  List<dynamic> _rowsPerPageOptions = [ 100,'ALL'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
    Provider.of<UserManagementProvider>(context,listen: false).fetchUserData(context);
    });

  }


  int get totalPages {
    if (_totalRecords == 0) return 1;
    return (_totalRecords / _rowsPerPage).ceil();
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
    return ChangeNotifierProvider(
      create: (context) => UserManagementProvider(),
      child: Consumer<UserManagementProvider>(
        builder: (context, Provider, _) {
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
                child:  Provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : Provider.errorMessage.isNotEmpty
                    ? Center(child: Text(Provider.errorMessage, style: const TextStyle(color: Colors.red)))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

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
                                          const Text('Show '),
                                          const SizedBox(width: 8),
                                          DropdownButton2<dynamic>(
                                            dropdownStyleData: DropdownStyleData(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)))),
                                            value: _rowsPerPage,
                                            items: _rowsPerPageOptions.map((dynamic value) {
                                              return DropdownMenuItem<dynamic>(
                                                value: value,
                                                child: Text(value.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {

                                              });
                                            },
                                          ),
                                        ],
                                      ),



                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  flex: 1,
                                  child: CustomTextField(
                                    controller: searchController,
                                    onChanged: (p0) {

                                    },
                                    hintText: "Search User",
                                    prefixIcon: Icons.search_rounded,
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 16, right: 16),
                                    height: 50, // define desired button height
                                    width: ResponsiveUtils.scaleWidth(context, 160),
                                    child: Animatedbutton(
                                      title: '+ Add Role',
                                      isLoading: Provider.isLoading,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const AddUserDialog(),
                                        );
                                      },

                                      backgroundColor: AppColors.secondary,
                                      shadowColor: AppColors.primary,
                                    ),
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
                                            Expanded(flex: 2, child: Row(
                                              children: [
                                                Text(
                                                  "EMAIL",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                    fontSize: ResponsiveUtils.fontSize(context, 16),
                                                  ),
                                                ),

                                              ],

                                            )),
                                            Expanded(flex: 2, child: Row(
                                              children: [
                                                Text("ROLE", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16))),


                                              ],
                                            )),
                                            Expanded(flex: 2, child: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                                            Expanded(flex: 2, child: Text("CREATED/UPDATED BY", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),

                                            Expanded(flex: 1, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.separated(
                                        itemCount:Provider.users.length,
                                        separatorBuilder: (context, index) => const Divider( height: 1,
                                            thickness: 1,
                                            color: AppColors.backgroundColor),
                                        itemBuilder: (context, index) {
                                          final user = Provider.users[index];

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
                                            child: Row(
                                              children: [
                                                Expanded(flex: 2, child: Text(user.name,style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                Expanded(flex: 2, child: Text(user.email,style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                Expanded(flex: 2, child: Text(user.rolename,style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                Expanded(flex: 2, child: Text(user.status.toString(),style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                Expanded(flex: 2, child: Text(user.createdat,style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),

                                                Expanded(
                                                  flex: 1,
                                                  child: Wrap(
                                                    children: [

                                                      IconButton(
                                                        icon:  Icon(Icons.edit_outlined , color: AppColors.primary,size:  ResponsiveUtils.fontSize(context, 22)),
                                                        onPressed: () {


                                                        },
                                                      ),
                                                      IconButton(
                                                        icon:  Icon(Icons.delete_outline, color: Colors.red,size:  ResponsiveUtils.fontSize(context, 22),),
                                                        onPressed: () {

                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Showing 1 to 20 of $_totalRecords records'),   Row(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // FIRST PAGE
                                          IconButton(
                                              icon: const Icon(Icons.first_page),
                                              onPressed: (){}
                                          ),
                                          // PREVIOUS
                                          IconButton(
                                              icon: const Icon(Icons.chevron_left),
                                              onPressed: (){}
                                          ),

                                          // PAGE NUMBERS
                                          ..._buildPageButtons(),

                                          // NEXT
                                          IconButton(
                                              icon: const Icon(Icons.chevron_right),
                                              onPressed:(){}
                                          ),

                                          // LAST PAGE
                                          IconButton(
                                            icon: const Icon(Icons.last_page),
                                            onPressed:() {

                                            },
                                          ),

                                          const SizedBox(width: 16),

                                          // Jump-to-page box
                                          SizedBox(
                                            width: 50,
                                            height: 30,
                                            child: TextFormField(
                                              initialValue:"1",
                                              textAlign: TextAlign.center,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                                border: OutlineInputBorder(),
                                              ),
                                              onFieldSubmitted: (value) {

                                              },
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
        },

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


class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole;
  bool obscurePassword = true;

  final List<String> roleOptions = ['Admin', 'Doctor', 'Receptionist'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add user",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form Grid (2 columns)
            Row(
              children: [
                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text("Name *",  style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                      ),),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: nameController,
                        hintText: 'Enter name',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text("Email *",  style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                      ),),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: emailController,
                        hintText: 'Enter email',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownInput<String>(
                          value: selectedRole,
                          items: roleOptions.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedRole = val;
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
                // Password
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text("Password *",  style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                      ),),
                      const SizedBox(height: 6),
                      CustomTextField(
                        hintText: 'Password',
                        controller: passwordController,
                        obscureText: obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
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

            // Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Animatedbutton(

                  onPressed: () {
                    // Perform Save Logic
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty &&
                        selectedRole != null &&
                        passwordController.text.isNotEmpty) {
                      // Save logic here
                      Navigator.of(context).pop();
                    } else {
                      // Show error message
                    }
                  },
                  shadowColor: AppColors.primary,
                  titlecolor:AppColors.red,
                  title: 'Close', backgroundColor: Colors.white,
                  borderColor: AppColors.red,

                ),

                const SizedBox(width: 16),
                Animatedbutton(

                  onPressed: () {
                    // Perform Save Logic
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty &&
                        selectedRole != null &&
                        passwordController.text.isNotEmpty) {
                      // Save logic here
                      Navigator.of(context).pop();
                    } else {
                      // Show error message
                    }
                  },
                  shadowColor: AppColors.primary,
                  title: 'Save', backgroundColor: AppColors.secondary,

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
