import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:poojaheakthcare/constants/ResponsiveUtils.dart';
import 'package:poojaheakthcare/utils/colors.dart';

import 'package:poojaheakthcare/constants/base_url.dart';
import 'package:poojaheakthcare/widgets/showTopSnackBar.dart';

import '../../constants/global_variable.dart';
import '../../services/auth_service.dart';

import '../../widgets/custom_text_field.dart';
import 'Home_Screen.dart';
import 'PatientDataTabsScreen.dart';

class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  bool isSidebarCollapsed = false;
  bool _showSearchResults = false;
  TextEditingController _searchController = TextEditingController();
  late PageController _pageController;
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  String _currentTime = '';
  bool isLoading = true;
  late Timer _timer;
  // Dummy page widgets
  final List<Widget> pages = [
    Center(child: Text('Dashboard')),
    Center(child: Text('Patient List')),
    Center(child: Text('User Management')),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _updateTime();
    _fetchPatients();
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _formatDateTime(DateTime.now());
      });
    });
  }

  List<Map<String, dynamic>> _transformApiData(List<dynamic> apiData) {
    return apiData.map((patient) {
      return {
        'id': patient['id'] ?? 'N/A',
        'phid': patient['phid'] ?? 'N/A',
        'name':
        '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}'.trim(),
        'age': patient['age']?.toString() ?? 'N/A',
        'phone': patient['mobile_no'] ?? 'N/A',
        'lastVisit': _formatLastVisitDate(patient['date'] ?? ''),
        'gender': patient['gender'] ?? 1,
      };
    }).toList();
  }
  @override
  void dispose() {
    _searchController.dispose();
    _timer.cancel();
    super.dispose();
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

  String _formatDateTime(DateTime dt) {
    final time = DateFormat('HH:mm:ss').format(dt);
    final date = DateFormat('dd-MM-yyyy').format(dt);
    return "$time | $date";
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
        'Cookie':
        'connect.sid=s%3AuEDYQI5oGhq5TztFK-F_ivqibtXxbspe.L65SiGdo4p4ZZY01Vnqd9tb4d64NFnzksLXndIK5zZA',
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
          filteredPatients = List.from(patients);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showTopRightToast(context,
            'Failed to load patients: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showTopRightToast(context, 'Error fetching patients: $e');
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  void _toggleSidebar() {
    setState(() {
      isSidebarCollapsed = !isSidebarCollapsed;
    });
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        filteredPatients = [];
      });
      return;
    }

    final result = patients
        .where((patient) => (patient['name']?.toLowerCase() ?? '')
        .contains(query.toLowerCase()))
        .toList();

    setState(() {
      filteredPatients = result;
      _showSearchResults = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtils.isMobile(context);

    return Stack(
      children: [
        Column(
          children: [
            if (!isMobile)
              Container(
                height: ResponsiveUtils.scaleHeight(context, 80),
                color: Colors.white,
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  /*  IconButton(
                      icon: Icon(
                        isSidebarCollapsed
                            ? Icons.keyboard_arrow_right
                            : Icons.keyboard_arrow_left,
                      ),
                      onPressed: _toggleSidebar,
                    ),*/
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _searchController,
                              onChanged: _handleSearch,
                              hintText: 'Search',
                              prefixIcon: Icons.search_rounded,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: ResponsiveUtils.fontSize(context, 18),
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _handleSearch('');
                              },
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _currentTime,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20),
                      ),
                    ),
                  ],
                ),
              ),

          ],
        ),
        if (_showSearchResults)
          Positioned(
            top: isMobile ? 10 : 80,
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
                        title: Text(
                          patient['name'] ?? '',
                          style: TextStyle(
                            fontSize:
                            ResponsiveUtils.fontSize(context, 14),
                          ),
                        ),
                        subtitle: Text(
                          'PHID: ${patient['phid']}',
                          style: TextStyle(
                            fontSize:
                            ResponsiveUtils.fontSize(context, 14),
                          ),
                        ),
                        trailing: Text(
                          patient['phone'] ?? '',
                          style: TextStyle(
                            fontSize:
                            ResponsiveUtils.fontSize(context, 14),
                          ),
                        ),
                        onTap: () {
                          GlobalPatientData.firstName = patient['name'].split(' ')[0];
                          GlobalPatientData.lastName = patient['name'].split(' ').length > 1
                              ? patient['name'].split(' ')[1]
                              : '';
                          GlobalPatientData.phone = patient['phone'];
                          GlobalPatientData.patientExist =patient['patientExist'];


                          Global.status ="2";
                          Global.phid =patient['id'].toString();
                          GlobalPatientData.patientId =patient['phid'] ;

                          print("patient['patient_id']");
                          print(GlobalPatientData.patientId);
                          print( Global.phid);

                          Navigator.pushReplacementNamed(context, '/patientData');
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
    );
  }
}
