import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:poojaheakthcare/widgets/AnimatedButton.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../constants/base_url.dart';
import '../../constants/global_variable.dart';
import '../../screens/patient_list.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../widgets/KeepAlivePage.dart';
import '../../widgets/showTopSnackBar.dart';
import 'DashboardScreen.dart';
import 'PatientDataTabsScreen.dart';
import 'PatientRegistrationPage.dart';
import 'Patient_Registration.dart';

class HomeScreen extends StatefulWidget {
  final int initialPage; // Add this line

  const HomeScreen({super.key, this.initialPage = 0}); // Modify this line


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedPageIndex = 0;
  bool isSidebarCollapsed = false;
  late Timer _timer;
  late String _currentTime;
  late PageController _pageController; // Change this line
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  @override
  void initState() {
    super.initState();
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _formatDateTime(DateTime.now());
      });
    });
    _fetchPatients();
    _pageController = PageController(initialPage: widget.initialPage); // Modify this line
    selectedPageIndex = widget.initialPage; // Add this line
  }


  String _formatDateTime(DateTime dt) {
    final time = DateFormat('HH:mm:ss').format(dt);
    final date = DateFormat('dd-MM-yyyy').format(dt);
    return "$time | $date";
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer.cancel();
    super.dispose();
  }

  final List<int> nonHighlightablePageIndices = [
    2,
  ];

  final List<Widget> pages = [
    KeepAlivePage(child: DashboardScreen()),
    KeepAlivePage(child: RecentPatientsListScreen()),
    KeepAlivePage(child: PatientDataTabsScreen()),
    // Add other pages similarly
  ];
  void _toggleSidebar() {
    setState(() {
      isSidebarCollapsed = !isSidebarCollapsed;
    });
  }


  Future<void> _fetchPatients() async {
    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        showTopRightToast(
            context, 'Authentication token not found. Please login again.');
        return;
      }
      final headers = {
        'Accept': 'application/json',
        'Cookie': 'connect.sid=s%3AuEDYQI5oGhq5TztFK-F_ivqibtXxbspe.L65SiGdo4p4ZZY01Vnqd9tb4d64NFnzksLXndIK5zZA',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$localurl/get_patient'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          patients = _transformApiData(responseData['data'] ?? []);
          print("patients");
          print(patients);
          filteredPatients = List.from(patients);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load patients: ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching patients: ${e.toString()}';
        isLoading = false;
      });
    }
  }
  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        filteredPatients = List.from(patients);
      });
    } else {
      final results = patients.where((patient) {
        final name = patient['name']?.toString().toLowerCase() ?? '';
        final phid = patient['phid']?.toString().toLowerCase() ?? '';
        final phone = patient['phone']?.toString().toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) ||
            phid.contains(query.toLowerCase()) ||
            phone.contains(query.toLowerCase());
      }).toList();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showSearchResults = true;
          filteredPatients = results;
        });
      });
    }
  }



  Future<void> _logout() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$localurl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Clear any stored tokens or user data
        await AuthService.deleteToken();
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      showTopRightToast(
        context,
        'Error during logout: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }
  List<Map<String, dynamic>> _transformApiData(List<dynamic> apiData) {
    return apiData.map((patient) {
      return {
        'id': patient['id'] ?? 'N/A',
        'phid': patient['phid'] ?? 'N/A',
        'name': '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}',
        'age': patient['age']?.toString() ?? 'N/A',
        'phone': patient['mobile_no'] ?? 'N/A',
        'lastVisit': _formatLastVisitDate(patient['date'] ?? ''),
        'gender': patient['gender'] ?? 1,
      };
    }).toList();
  }


  String _formatLastVisitDate(String dateString) {
    if (dateString.isEmpty) return 'No visits yet';
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: ResponsiveUtils.scaleWidth(context, 400), // Fixed width for the dialog
            margin: const EdgeInsets.symmetric(horizontal: 20), // Optional margin
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Text(
                      'Confirm Logout',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                     SizedBox(height: ResponsiveUtils.scaleHeight(context, 20)),
                     Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 16),),
                    ),
                     SizedBox(height:  ResponsiveUtils.scaleHeight(context, 30)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: ResponsiveUtils.scaleWidth(context, 120), // Fixed width for Cancel button
                          child: Animatedbutton(
                            title: 'Cancel',

                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            titlecolor:AppColors.secondary,
                            backgroundColor: Colors.white,
                            shadowColor: Colors.white,
                            borderColor: AppColors.secondary,
                          ),
                        ),
                        // SizedBox(width:  ResponsiveUtils.scaleWidth(context, 16)),
                        SizedBox(
                          width:  ResponsiveUtils.scaleWidth(context, 120), // Fixed width for Logout button
                          child: Animatedbutton(
                            backgroundColor: AppColors.secondary,
                            shadowColor: Colors.white,
                            title: 'Logout',
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _logout();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);



    double fieldposition;

    if (ResponsiveUtils.isMobile(context)) {
      fieldposition = MediaQuery.of(context).size.width / 2 - ResponsiveUtils.scaleWidth(context, 290);
    } else if (ResponsiveUtils.isTablet(context)) {
      fieldposition = MediaQuery.of(context).size.width / 2 - ResponsiveUtils.scaleWidth(context, 400);
    } else {
      fieldposition = MediaQuery.of(context).size.width / 2 - ResponsiveUtils.scaleWidth(context, 450);
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar:isMobile ? _buildMobileAppBar() :null,
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: Row(
        children: [
          if(!isMobile)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSidebarCollapsed
                ? ResponsiveUtils.scaleWidth(context, 85)
                : ResponsiveUtils.scaleWidth(context, 200),

            color:Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(right: 20,left: 20,bottom: 20,top: 10),
              child: Column(
                spacing: 4,
                children: [
                  Image.asset(
                    isSidebarCollapsed
                        ? 'assets/logo1.png'
                        : 'assets/companyNameLogo.png',
                    height: ResponsiveUtils.scaleHeight(context, 44)
                  ),
                  SizedBox(height: 20,),
                  _buildSidebarItem(
                    assetPath: 'assets/Dashboard.png',
                    label: 'Dashboard',
                    index: 0,
                  ),
                  _buildSidebarItem(
                    assetPath: 'assets/PatientList.png',
                    label: 'Patient list',
                    index: 1,
                  ),
                 /* _buildSidebarItem(
                    assetPath: 'assets/DrSchedule.png',
                    label: 'Dr. Schedule',
                    index: 2,
                  ),
                  _buildSidebarItem(
                    assetPath: 'assets/ChangesLog.png',
                    label: 'Change log',
                    index: 3,
                  ),
                  _buildSidebarItem(
                    assetPath: 'assets/UserManagement.png',
                    label: 'User Management',
                    index: 4,
                  )
                  _buildSidebarItem(
                    assetPath: 'assets/Master.png',
                    label: 'Masters',
                    index: 5,
                  ),*/
                  const Spacer(),
                 /* _buildSidebarItem(
                    assetPath: 'assets/settingicon.png',
                    label: 'Settings',
                    index: 3,
                  ),*/
                  _buildSidebarItem(
                    assetPath: 'assets/logouticon.png',
                    label: 'Logout',
                    index: 4,
                    onTap: _showLogoutConfirmation, // Add this parameter
                  ),
                  Divider(color: AppColors.secondary,),
                  isSidebarCollapsed
                      ?SvgPicture.asset(
                    'assets/applelogosvg.svg',
                    height: 20,
                    // height: null,   // Remove or specify a height if needed
                  )
                      : Image.asset(
                    'assets/appstore.png',

                  ),
                  Image.asset(

                    isSidebarCollapsed
                        ?  'assets/playstorelogo.png'
                        : 'assets/googleplay.png',
                    height: isSidebarCollapsed ?20 :null,

                  ),
                ],
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    if(!isMobile)
                    Container(
                      height: ResponsiveUtils.scaleHeight(context, 80),
                      color: Colors.white,
                      padding: ResponsiveUtils.fieldPadding(context),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isSidebarCollapsed
                                  ? Icons.keyboard_arrow_right
                                  : Icons.keyboard_arrow_left,
                            ),
                            onPressed: _toggleSidebar,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(

                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE4EAF1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children: [
                                   Icon(Icons.search, size:  ResponsiveUtils.fontSize(context, 16), color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(

                                      controller: _searchController,
                                      onChanged: _handleSearch,
                                      decoration:  InputDecoration(
                                        hintText: 'Search Patient Name',
                                        hintStyle: TextStyle(fontSize:ResponsiveUtils.fontSize(context, 14), color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    IconButton(
                                      icon:  Icon(Icons.close, size: ResponsiveUtils.fontSize(context, 18), color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        _handleSearch('');
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                            Text(
                            _currentTime,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: pages,
                        scrollDirection: Axis.vertical,
                      ),
                    ),

                  ],
                ),
                if (_showSearchResults)

                  Positioned(
                    top:isMobile ? 10:80,
                    //left: fieldposition,
                   // left: MediaQuery.of(context).size.width / 2 - 892, // center 600px container
                    child: SizedBox(
                      width: ResponsiveUtils.getPopupWidth(context),


                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: filteredPatients.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("No results found"),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              return ListTile(
                                title: Text(patient['name'] ?? '',style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 14),)),
                                subtitle: Text('PHID: ${patient['phid']}',style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 14),)),
                                trailing: Text(patient['phone'] ?? '',style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 14),),),
                                onTap: () {
                                  GlobalPatientData.firstName = patient['name'].split(' ')[0];
                                  GlobalPatientData.lastName =
                                  patient['name'].split(' ').length > 1 ? patient['name'].split(' ')[1] : '';
                                  GlobalPatientData.phone = patient['phone'];
                                  GlobalPatientData.patientExist = patient['patientExist'];
                                  Global.status = "2";
                                  Global.phid = patient['id'].toString();
                                  GlobalPatientData.patientId = patient['phid'];

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(initialPage: 2),
                                    ),
                                  );

                                  _searchController.clear();
                                  _handleSearch('');
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

              ],
            ),
          )

        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: ResponsiveUtils.fieldPadding(context),
        child: Builder(
          builder: (context) {
            return Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE4EAF1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: ResponsiveUtils.fontSize(context, 16), color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _handleSearch,
                            decoration: InputDecoration(
                              hintText: 'Search Patient Name',
                              hintStyle: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 14), color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.close, size: ResponsiveUtils.fontSize(context, 18), color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _handleSearch('');
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _currentTime,
                  style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 12), color: Colors.black),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Image.asset('assets/companyNameLogo.png'),
          ),
          _buildDrawerItem('Dashboard', 0, 'assets/Dashboard.png'),
          _buildDrawerItem('Patient list', 1, 'assets/PatientList.png'),




          Divider(color: AppColors.secondary,),
          _buildDrawerItem('Logout', 4, 'assets/logouticon.png', onTap: _showLogoutConfirmation),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String label, int index, String assetPath, {VoidCallback? onTap}) {
    return ListTile(
      leading: Image.asset(
        assetPath,
        height: ResponsiveUtils.scaleHeight(context, 20),
        color: AppColors.secondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveUtils.fontSize(context, 14),
          color: AppColors.secondary,
        ),
      ),
      onTap: onTap ??
              () {
            setState(() {
              selectedPageIndex = index;
              _pageController.jumpToPage(index);
            });
            Navigator.pop(context);
          },
    );
  }

  Widget _buildSidebarItem({
    required String assetPath,
    required String label,
    required int index,
    VoidCallback? onTap, // Add this parameter
  }) {
    final bool isHighlightable = !nonHighlightablePageIndices.contains(index);
    final bool isSelected = selectedPageIndex == index && isHighlightable;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEDF1F6) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: InkWell(
          onTap: onTap ?? () { // Use the provided onTap or default behavior
            if (isHighlightable) {
              setState(() => selectedPageIndex = index);
              _pageController.jumpToPage(index);
            }
          },
          child: Row(
            children: [
              Image.asset(
                assetPath,
                height: ResponsiveUtils.scaleHeight(context, 20),
                color: isSelected ? AppColors.primary : AppColors.secondary,
              ),
              if (!isSidebarCollapsed) ...[
                const SizedBox(width: 12),
                 Text(
                  label,
                  style: TextStyle(
                    fontSize:  ResponsiveUtils.fontSize(context, 12),
                    color: isSelected ? AppColors.primary : AppColors.secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}
