import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For PointerDeviceKind
import 'package:http/http.dart' as http;
import 'package:poojaheakthcare/constants/global_variable.dart';
import 'package:poojaheakthcare/screens/patient_form_screen.dart';
import '../utils/colors.dart';

class RecentPatientsListScreen extends StatefulWidget {
  const RecentPatientsListScreen({super.key});

  @override
  _RecentPatientsListScreenState createState() =>
      _RecentPatientsListScreenState();
}

class _RecentPatientsListScreenState extends State<RecentPatientsListScreen> {
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool sortByName = true;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Cookie':
            'connect.sid=s%3AuEDYQI5oGhq5TztFK-F_ivqibtXxbspe.L65SiGdo4p4ZZY01Vnqd9tb4d64NFnzksLXndIK5zZA'
      };

      final response = await http.get(
        Uri.parse('https://pooja-healthcare.ortdemo.com/api/get_allpatients'),
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

  List<Map<String, dynamic>> _transformApiData(List<dynamic> apiData) {
    return apiData.map((patient) {
      return {
        'phid': patient['phid'] ?? 'N/A',
        'name': '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}',
        'age': patient['age']?.toString() ?? 'N/A',
        'phone': patient['mobile_no'] ?? 'N/A',
        'lastVisit': _formatLastVisitDate(patient['date'] ?? ''),
        'gender': _getGenderIcon(patient['gender'] ?? 1),
        'clinic': patient['location'] ?? 'Pooja Healthcare'
      };
    }).toList();
  }

  String _formatLastVisitDate(String dateString) {
    if (dateString.isEmpty) return 'No visits yet';
    try {
      final date = DateTime.parse(dateString);
      final monthNames = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];
      return "${date.day} ${monthNames[date.month - 1]} ${date.year}";
    } catch (e) {
      return 'Invalid date';
    }
  }

  IconData _getGenderIcon(int gender) {
    switch (gender) {
      case 1:
        return Icons.male;
      case 2:
        return Icons.female;
      default:
        return Icons.transgender;
    }
  }

  void filterPatients(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredPatients = patients.where((patient) {
        return patient['name'].toLowerCase().contains(searchQuery) ||
            patient['phone'].contains(searchQuery) ||
            patient['phid'].toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  void clearSearch() {
    setState(() {
      searchController.clear();
      searchQuery = "";
      filteredPatients = List.from(patients);
    });
  }

  void sortPatients() {
    setState(() {
      filteredPatients.sort((a, b) {
        return sortByName
            ? a['name'].compareTo(b['name'])
            : a['lastVisit'].compareTo(b['lastVisit']);
      });
      sortByName = !sortByName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Patients'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : (isTablet ? 800 : double.infinity),
            ),
            child: Column(
              children: [
                // Responsive Search and Sort Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: filterPatients,
                            decoration: InputDecoration(
                              hintText: "Search by name, phone or ID",
                              prefixIcon:
                                  Icon(Icons.search, size: isDesktop ? 24 : 20),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          size: isDesktop ? 24 : 20),
                                      onPressed: clearSearch,
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isDesktop ? 18 : 14,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isDesktop ? 20 : 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.sort,
                            size: isDesktop ? 28 : 24,
                            color: AppColors.primary,
                          ),
                          onPressed: sortPatients,
                        ),
                      ),
                    ],
                  ),
                ),
                // Responsive Patient List
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : errorMessage.isNotEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(isDesktop ? 40 : 24),
                                child: Text(
                                  errorMessage,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 18 : 16,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : filteredPatients.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(isDesktop ? 40 : 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: isDesktop ? 64 : 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          "No patients found",
                                          style: TextStyle(
                                            fontSize: isDesktop ? 20 : 16,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (searchQuery.isNotEmpty)
                                          TextButton(
                                            onPressed: clearSearch,
                                            child: const Text('Clear search'),
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                              : ScrollConfiguration(
                                  behavior:
                                      ScrollConfiguration.of(context).copyWith(
                                    scrollbars: true,
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                      if (isDesktop) PointerDeviceKind.trackpad,
                                    },
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 40 : 16,
                                      vertical: 8,
                                    ),
                                    itemCount: filteredPatients.length,
                                    itemBuilder: (context, index) {
                                      final patient = filteredPatients[index];
                                      return MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Container(
                                          // color: Colors.white,
                                          margin: EdgeInsets.only(
                                              bottom: isDesktop ? 16 : 12),
                                          child: Card(
                                            color: Colors.white,
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () {
                                                setState(() {
                                                  Global.status = '2';
                                                  Global.patient_id =
                                                      patient['patient_id'];
                                                  Global.phid = patient['phid'];
                                                });
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PatientFormScreen(
                                                      firstName: patient['name']
                                                          .split(' ')[0],
                                                      lastName: patient['name']
                                                                  .split(' ')
                                                                  .length >
                                                              1
                                                          ? patient['name']
                                                              .split(' ')[1]
                                                          : '',
                                                      phone: patient['phone'],
                                                      patientExist: 2,
                                                      phid: patient['phid'],
                                                      patientId:
                                                          patient['patient_id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    isDesktop ? 24 : 16),
                                                child: Row(
                                                  children: [
                                                    // Gender Icon
                                                    Container(
                                                      padding: EdgeInsets.all(
                                                          isDesktop ? 14 : 10),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        patient['gender'],
                                                        color:
                                                            AppColors.primary,
                                                        size:
                                                            isDesktop ? 28 : 24,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: isDesktop
                                                            ? 20
                                                            : 16),
                                                    // Patient Details
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  patient[
                                                                      'name'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        isDesktop
                                                                            ? 20
                                                                            : 16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Text(
                                                                patient[
                                                                    'lastVisit'],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      isDesktop
                                                                          ? 14
                                                                          : 12,
                                                                  color: AppColors
                                                                      .textSecondary,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: isDesktop
                                                                  ? 12
                                                                  : 6),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'PHID: ${patient['phid']}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      isDesktop
                                                                          ? 14
                                                                          : 12,
                                                                  color: AppColors
                                                                      .primary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      isDesktop
                                                                          ? 20
                                                                          : 12),
                                                              Text(
                                                                'Age: ${patient['age']}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      isDesktop
                                                                          ? 14
                                                                          : 12,
                                                                  color: AppColors
                                                                      .textSecondary,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: isDesktop
                                                                  ? 8
                                                                  : 4),
                                                          Text(
                                                            'Phone: ${patient['phone']}',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  isDesktop
                                                                      ? 14
                                                                      : 12,
                                                              color: AppColors
                                                                  .textSecondary,
                                                            ),
                                                          ),
                                                          if (isDesktop ||
                                                              isTablet) ...[
                                                            SizedBox(height: 8),
                                                            Text(
                                                              patient['clinic'],
                                                              style: TextStyle(
                                                                fontSize:
                                                                    isDesktop
                                                                        ? 14
                                                                        : 12,
                                                                color: AppColors
                                                                    .primary,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                    if (isDesktop || isTablet)
                                                      Icon(
                                                        Icons.chevron_right,
                                                        color: AppColors
                                                            .textSecondary,
                                                        size:
                                                            isDesktop ? 32 : 24,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
