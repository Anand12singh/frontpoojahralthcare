import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'package:poojaheakthcare/constants/ResponsiveUtils.dart';

import '../../constants/global_variable.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isSidebarCollapsed = false;

  int? hoveredSidebarIndex;

  void onToggleSidebar() {
    setState(() {
      isSidebarCollapsed = !isSidebarCollapsed;
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // perform logout logic here
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isSidebarCollapsed = false;
        });
      },
      onExit: (_) {
        setState(() {
          isSidebarCollapsed = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isSidebarCollapsed
            ? ResponsiveUtils.scaleWidth(context, 80)
            : ResponsiveUtils.scaleWidth(context, 220),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(

            children: [
              // No more tap gesture
              Image.asset(
                isSidebarCollapsed
                    ? 'assets/logo1.png'
                    : 'assets/company_logo.png',
                fit: isSidebarCollapsed ? null : BoxFit.contain,
                height: isSidebarCollapsed
                    ? ResponsiveUtils.scaleHeight(context, 42)
                    : ResponsiveUtils.scaleHeight(context, 50),
                width: double.infinity,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 8, left: 8, bottom: 20, top: 10),
                  child: Column(
                    spacing: 6,
                    children: [
                      _buildSidebarItem(
                        assetPath: 'assets/Dashboard.png',
                        label: 'Dashboard',
                        index: 0,
                        onTap: () {
                          Navigator.pushNamed(context, '/dashboard');
                        },
                      ),
                      _buildSidebarItem(
                        assetPath: 'assets/PatientList.png',
                        label: 'Patient list',
                        index: 1,
                        onTap: () {
                          Navigator.pushNamed(context, '/patientList');
                        },
                      ),
                      _buildSidebarItem(
                        assetPath: 'assets/UserManagement.png',
                        label: 'User Management',
                        index: 3,
                        onTap: () {
                          Navigator.pushNamed(context, '/userManagement');
                        },
                      ),  _buildSidebarItem(
                        assetPath: 'assets/UserManagement.png',
                        label: 'Role Management',
                        index: 4,
                        onTap: () {
                          Navigator.pushNamed(context, '/roleManagement');
                        },
                      ),

                      _buildSidebarItem(
                        assetPath: 'assets/UserManagement.png',
                        label: 'Permission Management',
                        index: 5,
                        onTap: () {
                          Navigator.pushNamed(context, '/permissionManagement');
                        },
                      ),
                      const Spacer(),
                      _buildSidebarItem(
                        assetPath: 'assets/logouticon.png',
                        label: 'Logout',
                        index: 6,
                        isLogout: true,
                        onTap: _showLogoutConfirmation,
                      ),
                      const Divider(
                        color: AppColors.secondary,
                        thickness: 0.5,
                      ),
                      if (isSidebarCollapsed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 11),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundgreycolor,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                            border: Border.all(color: AppColors.darkgreycolor),
                          ),
                          child: SvgPicture.asset(
                            'assets/applelogosvg.svg',
                            height: 20,
                          ),
                        )
                      else
                        Image.asset('assets/appstore.png'),
                      if (isSidebarCollapsed)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundgreycolor,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                            border: Border.all(color: AppColors.darkgreycolor),
                          ),
                          child: Image.asset(
                            'assets/playstorelogo.png',
                            height: 20,
                          ),
                        )
                      else
                        Image.asset('assets/googleplay.png'),
                      Row(
                        children: [
                          if (isSidebarCollapsed)
                          Text(
                            'V1.0.2',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 12),
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          )
                          else
                          Text(
                            'Version V1.0.2',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 12),
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSidebarItem({
    required String assetPath,
    required String label,
    required int index,
    VoidCallback? onTap,
    bool isLogout = false,
  }) {
    final bool isHighlightable = ![2].contains(index);
    final bool isSelected = selectedPageIndex == index && isHighlightable;
    final bool isHovered = hoveredSidebarIndex == index;

    final Color backgroundColor = isLogout
        ? AppColors.lightred
        : isSelected
        ? const Color(0xFFEDF1F6)
        : Colors.transparent;

    final Color iconColor = isLogout
        ? AppColors.red
        : isSelected
        ? AppColors.primary
        : AppColors.secondary;

    final Color textColor = iconColor;
    final Color? borderColor = isHovered
        ? (isLogout ? AppColors.red : AppColors.primary)
        : Colors.transparent;

    Widget content = Row(
      children: [
        if (assetPath.isNotEmpty)
          Image.asset(
            assetPath,
            height: ResponsiveUtils.scaleHeight(context, 20),
            color: iconColor,
          ),
        if (!isSidebarCollapsed) ...[
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14),
              color: textColor,
            ),
          ),
        ],
      ],
    );

    if (isSidebarCollapsed) {
      content = Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 300),
        child: content,
      );
    }

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredSidebarIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredSidebarIndex = null;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor!,
            width: 1,
          ),
        ),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: InkWell(
            onTap: () {
              if (isLogout) {
                onTap?.call();
              } else {
                setState(() {
                  selectedPageIndex = index;
                });
                onTap?.call();
              }
            },
            child: content,
          ),
        ),
      ),
    );
  }
}
