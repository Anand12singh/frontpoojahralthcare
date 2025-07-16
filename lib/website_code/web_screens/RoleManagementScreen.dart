import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../constants/ResponsiveUtils.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/DropdownInput.dart';
import '../../widgets/custom_text_field.dart';
import 'CustomSidebar.dart';
import 'SearchBar.dart';
class Rolemanagementscreen extends StatefulWidget {
  const Rolemanagementscreen({super.key});

  @override
  State<Rolemanagementscreen> createState() => _RolemanagementscreenState();
}

class _RolemanagementscreenState extends State<Rolemanagementscreen> {
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
                                flex:1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [ Animatedbutton(

                                    onPressed: () {
                                      // Perform Save Logic

                                    },
                                    shadowColor: AppColors.primary,
                                    title: 'Save', backgroundColor: AppColors.secondary,

                                  ),
                                    const SizedBox(width: 16),
                                    Animatedbutton(

                                      onPressed: () {
                                        // Perform Save Logic

                                      },
                                      shadowColor: AppColors.primary,
                                      titlecolor:AppColors.red,
                                      title: 'Reset', backgroundColor: Colors.white,
                                      borderColor: AppColors.red,

                                    ),



                                  ],
                                ),
                              ),
                            ],
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

                                                Expanded(flex: 1, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.separated(
                                            itemCount: filteredPatients.length,
                                            separatorBuilder: (context, index) => const Divider( height: 1,
                                                thickness: 1,
                                                color: AppColors.backgroundColor),
                                            itemBuilder: (context, index) {
                                              final patient = filteredPatients[index];
                                              final _gender = patient?['gender'] == 1 ? 'Male' : 'Female';
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
                                                child: Row(
                                                  children: [
                                                    Expanded(flex: 2, child: Text(patient['phid'] ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                    Expanded(flex: 2, child: Text(patient['phone'] ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),

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


 