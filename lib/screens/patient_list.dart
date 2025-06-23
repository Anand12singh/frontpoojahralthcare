import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:poojaheakthcare/constants/base_url.dart';
import 'package:poojaheakthcare/constants/global_variable.dart';
import 'package:poojaheakthcare/screens/patient_form_screen.dart';
import '../utils/colors.dart';
import '../website_code/web_screens/Home_Screen.dart';
import '../widgets/custom_text_field.dart';

class RecentPatientsListScreen extends StatefulWidget {
  const RecentPatientsListScreen({super.key});

  @override
  _RecentPatientsListScreenState createState() => _RecentPatientsListScreenState();
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
        'Cookie': 'connect.sid=s%3AuEDYQI5oGhq5TztFK-F_ivqibtXxbspe.L65SiGdo4p4ZZY01Vnqd9tb4d64NFnzksLXndIK5zZA'
      };

      final response = await http.get(
        Uri.parse('$localurl/get_allpatients'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF2FF),
        elevation: 0,
        title: const Text(
          'Patient List',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 350,
              child: CustomTextField(
                controller: searchController,
                onChanged: filterPatients,
           hintText: "Search patients...",
prefixIcon: Icons.search_rounded,

              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
              ),
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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text("PHID", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                          Expanded(flex: 2, child: Text("Patient Name", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                          Expanded(flex: 2, child: Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                          Expanded(flex: 2, child: Text("Last Visit", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                          Expanded(flex: 1, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredPatients.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(patient['phid'] ?? '')),
                              Expanded(flex: 2, child: Text(patient['name'] ?? '')),
                              Expanded(flex: 2, child: Text(patient['phone'] ?? '')),
                              Expanded(flex: 2, child: Text(patient['lastVisit'] ?? '')),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.primary),
                                      onPressed: () {

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

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(
                                              initialPage: 2,
                                            ),
                                          ),
                                        );

                                      },
                                    ),
                                /*    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteDialog(context, patient['phid']);
                                      },
                                    ),*/
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
        ],
      ),

    );
  }

  void _showDeleteDialog(BuildContext context, String phid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete patient $phid?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Implement delete functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Patient $phid deleted')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}