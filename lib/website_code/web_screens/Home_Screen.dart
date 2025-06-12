import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../screens/patient_list.dart';
import '../../utils/colors.dart';
import '../../widgets/KeepAlivePage.dart';
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

  @override
  void initState() {
    super.initState();
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _formatDateTime(DateTime.now());
      });
    });
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
    _timer.cancel();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSidebarCollapsed ? 80 : 220,
            color:Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                spacing: 4,
                children: [
                  Image.asset(
                    isSidebarCollapsed
                        ? 'assets/logo1.png'
                        : 'assets/companyNameLogo.png',
                    height: 44,
                  ),
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
                  _buildSidebarItem(
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
                  ),
                  _buildSidebarItem(
                    assetPath: 'assets/Master.png',
                    label: 'Masters',
                    index: 5,
                  ),
                  const Spacer(),
                  _buildSidebarItem(
                    assetPath: 'assets/settingicon.png',
                    label: 'Settings',
                    index: 5,
                  ),
                  _buildSidebarItem(
                    assetPath: 'assets/logouticon.png',
                    label: 'Logout',
                    index: 5,
                  ),
                  Divider(color: AppColors.secondary,),
                  Image.asset(
                    'assets/appstore.png',
                    //height: 18,

                  ), Image.asset(
                    'assets/googleplay.png',
                   // height: 18,

                  ),
                ],
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            children:  [
                              Icon(Icons.search, size: 16, color: Colors.grey),
SizedBox(width: 8,),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  decoration: InputDecoration(
                                    hintText: 'Search Patient Name',
                                    hintStyle: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              const Icon(Icons.close, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _currentTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7186A3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,

                    children: pages,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required String assetPath,
    required String label,
    required int index,
  }) {
    final bool isSelected = selectedPageIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEDF1F6) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: InkWell(
          onTap: () {
            setState(() => selectedPageIndex = index);
            _pageController.jumpToPage(index);
          },
          child: Row(
            children: [
              Image.asset(
                assetPath,
                height: 18,
                color: isSelected ? AppColors.primary : AppColors.secondary,
              ),
              if (!isSidebarCollapsed) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
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
