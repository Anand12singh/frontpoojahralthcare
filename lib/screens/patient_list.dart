import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
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

      final request = http.Request(
          'GET',
          Uri.parse(
              'https://pooja-healthcare.ortdemo.com/api/get_allpatients'));
      request.headers.addAll(headers);

      final response = await http.Response.fromStream(await request.send());

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
      case 3:
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Patients'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: filterPatients,
                    decoration: InputDecoration(
                      hintText: "Search by name, phone or ID",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: sortPatients,
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : filteredPatients.isEmpty
                        ? const Center(
                            child: Text(
                              "No patients available",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredPatients.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  log('patient $patient');
                                  setState(() {
                                    Global.status = '2';
                                    Global.patient_id = patient['patient_id'];
                                    Global.phid = patient['phid'];

                                    log(Global.patient_id.toString());
                                    log(Global.phid.toString());
                                    log(Global.status.toString());
                                  });
                                  // Navigate to PatientFormScreen with the patient's data
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientFormScreen(
                                        firstName:
                                            patient['name'].split(' ')[0],
                                        lastName:
                                            patient['name'].split(' ').length >
                                                    1
                                                ? patient['name'].split(' ')[1]
                                                : '',
                                        phone: patient['phone'],
                                        patientExist:
                                            2, // Assuming existing patient
                                        phid: patient['phid'],
                                        patientId: patient[
                                            'id'], // Pass the original ID
                                      ),
                                    ),
                                  );
                                },
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
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            patient['phid'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          Text(
                                            patient['lastVisit'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              patient['gender'],
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  patient['name'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Age: ${patient['age']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Phone: ${patient['phone']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  patient['clinic'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.primary,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
