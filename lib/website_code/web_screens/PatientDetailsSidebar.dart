import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants/base_url.dart';
import '../../utils/colors.dart';
import 'Patient_Registration.dart';

class PatientDetailsSidebar extends StatefulWidget {
  final String patientId; // Add patientId parameter
  const PatientDetailsSidebar({super.key, required this.patientId});

  @override
  State<PatientDetailsSidebar> createState() => _PatientDetailsSidebarState();
}

class _PatientDetailsSidebarState extends State<PatientDetailsSidebar> {
  Map<String, dynamic>? patientData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$localurl/front_patient_by_id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': widget.patientId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'].isNotEmpty) {
          setState(() {
            patientData = data['data'][0];
            print("patientData");
            print(patientData);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Patient not found';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Patient data not found.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  String _getGenderText(int? genderCode) {
    switch (genderCode) {
      case 1:
        return 'M';
      case 2:
        return 'F';
      case 3:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  String _getHistoryText() {
    if (patientData == null || patientData!['PatientVisitInfo'].isEmpty) {
      return 'No history';
    }

    final visitInfo = patientData!['PatientVisitInfo'][0];
    List<String> historyParts = [];

    if (visitInfo['history_of_dm_status'] == true) {
      historyParts.add('DM');
    }
    if (visitInfo['hypertension_status'] == true) {
      historyParts.add('Hypertension');
    }
    if (visitInfo['IHD_status'] == true) {
      historyParts.add('IHD');
    }
    if (visitInfo['COPD_status'] == true) {
      historyParts.add('COPD');
    }

    return historyParts.isEmpty ? 'No significant history' : historyParts.join(' | ');
  }

  String _getLocationText() {
    if (patientData == null || patientData!['patient'].isEmpty) return 'Unknown';

    final patient = patientData!['patient'][0];
    if (patient['other_location'] != null && patient['other_location'].isNotEmpty) {
      return patient['other_location'];
    }

    switch (patient['location']) {
      case 1:
        return 'Pooja Nursing Home';
    // Add other location cases as needed
      default:
        return 'Unknown location';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary,
      ));
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (patientData == null) {
      return const Center(child: Text('No patient data available'));
    }

    final patient = patientData!['patient'][0];
    final dischargeInfo = patientData!['discharge_info'].isNotEmpty
        ? patientData!['discharge_info'][0]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sidebarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text("PH ID-${patient['phid']}", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20,color: AppColors.primary)),
              SizedBox(height: 8),
              buildInfoBlock("Patient's Name", "${patient['first_name']} ${patient['last_name']} - ${patient['age'] ?? ''}/${_getGenderText(patient['gender'])}"),
              buildInfoBlock("History", _getHistoryText()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoBlock("Location", _getLocationText()),
                  Container(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildInfoBlock("Occupation", patient['occupation'] ?? 'Not specified'),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoBlock("Diagnosis", dischargeInfo?['diagnosis'] ?? 'Not specified'),
                  Container(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildInfoBlock("Surgery Type", dischargeInfo?['operation_type'] ?? 'Not specified'),
                        ],
                      )),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoBlock("Chief Complaints", patient['doctor_note'] ?? 'Not specified'),
                  Container(width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildInfoBlock("Clinical Diagnosis", dischargeInfo?['diagnosis'] ?? 'Not specified'),
                        ],
                      )),
                ],
              ),

              SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: FormInput(label: 'Summary')),

            ],
          ),
        ),
        const SizedBox(height: 20),
        _sidebarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contact Patient",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: AppColors.secondary),),
              ListTile(
                leading: Image.asset(
                  "assets/whatsapp.png",
                  height: 20,
                ),
                title: const Text('Connect on Whatsapp'),
                onTap: () {
                  // Implement WhatsApp functionality
                },
              ),
              ListTile(
                leading: Image.asset(
                  "assets/call.png",
                  height: 20,
                ),
                title: Text('Connect on Call - ${patient['mobile_no']}'),
                onTap: () {
                  // Implement call functionality
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildInfoBlock(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black),
          children: [
            TextSpan(
              text: '$title\n',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xFF5B5B5B),
              ),
            ),
            TextSpan(
              text: content,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF132A3E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}