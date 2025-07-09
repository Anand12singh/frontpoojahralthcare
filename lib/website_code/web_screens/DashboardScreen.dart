import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:poojaheakthcare/widgets/showTopSnackBar.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../constants/base_url.dart';
import '../../constants/global_variable.dart';
import '../../screens/olddpatientfom.dart';
import '../../services/auth_service.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/custom_text_field.dart';
import 'Home_Screen.dart';
import 'PatientDataTabsScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<Map<String, String>> bookmarksData = const [
    {
      'patientName': 'Gretchen O\'Kon, M/31',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Whitney Hettinger, F/22',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Leroy Auer, M/32',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Gilbert Rogahn, F/46',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Leroy Auer, M/54',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Gilbert Rogahn, F/37',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Ms. Luz Hueis, M/44',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
  ];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;


 void _AddPatientsubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });
    FocusScope.of(context).unfocus();

    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        showTopRightToast(
            context, 'Authentication token not found. Please login again.');
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Cookie':
        'connect.sid=s%3AuEDYQI5oGhq5TztFK-F_ivqibtXxbspe.L65SiGdo4p4ZZY01Vnqd9tb4d64NFnzksLXndIK5zZA'
      };

      final response = await http.post(
        Uri.parse('$localurl/add_patient'),
        headers: headers,
        body: json.encode({
          "first_name": _nameController.text.trim(),
          "last_name": _lastnameController.text.trim(),
          "mobile_no": _phoneController.text.trim(),
        }),
      );

      log('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          _isLoading = false;
          _handleSuccessResponse(responseData);
        } else {
          _isLoading = false;
          _showErrorSnackbar(responseData['message'] ?? 'Submission failed');
        }
      } else {
        _isLoading = false;
        _showErrorSnackbar('API Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSubmitting = false;
      });
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitting = false;
        });
      }
    }
  }
  void _showErrorSnackbar(String message) {
    showTopRightToast(context,message,backgroundColor: Colors.red);

  }


  void _handleSuccessResponse(Map<String, dynamic> responseData) {
    final data = responseData['data'][0];
    int patientExist = data['patientExist'] ?? 0;
    String? phid = data['patient_id']?.toString() ?? 'NA';
    String? phid1 = data['phid']?.toString() ?? 'NA';

    Global.status = patientExist.toString();
    Global.patient_id = phid;
    Global.phid = phid;
    Global.phid1 = phid1;
    GlobalPatientData.firstName =_nameController.text.trim();
    GlobalPatientData.lastName =_lastnameController.text.trim();
    GlobalPatientData.phone =_phoneController.text.trim();
    GlobalPatientData.patientExist =patientExist;
    GlobalPatientData.phid =phid1;
    GlobalPatientData.patientId =phid ;

    log('Patient Exist: $patientExist, PHID: $phid');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
        initialPage: 2,
        ),
      ),
    );
  }
  void _showAddPatientModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: _addPatient(
              firstNameController: _nameController,
              lastNameController: _lastnameController,
              phoneController: _phoneController,
              isLoading: _isLoading,

              onPressed: () {
            /*    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientDataTabsScreen(),
                  ),
                );*/
                Navigator.pop(context); // Close the modal
              },
            ),
          ),
        ),
      ),
    );
  }
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isMobile ?   Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back,\nDr. Pooja",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Here's what's happening\nwith your patients today.",
                      style: TextStyle(fontSize: 16, color: AppColors.greycolor),
                    ),
                    SizedBox(height: 20),
                  ],
                ),

                Container(
                  width:ResponsiveUtils.scaleWidth(context, 160),

                  child:Animatedbutton(
                    title: '+ Add Patient',
                    isLoading: _isLoading,
                    onPressed: () {
                      _showAddPatientModal(context);
                    },
                    backgroundColor: AppColors.secondary,
                    shadowColor: AppColors.primary,
                  ),
                ),
              ],
            ):
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back, Dr. Pooja",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Here's what's happening with your patients today.",
                      style: TextStyle(fontSize: 16, color: AppColors.greycolor),
                    ),
                    SizedBox(height: 20),
                  ],
                 ),

                 Container(
                   width:ResponsiveUtils.scaleWidth(context, 160),

                   child:Animatedbutton(
                     title: '+ Add Patient',
                     isLoading: _isLoading,
                     onPressed: () {
                       _showAddPatientModal(context);
                     },
                     backgroundColor: AppColors.secondary,
                     shadowColor: AppColors.primary,
                   ),
                 ),
               ],
             ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Expanded(
                    flex: 7, //
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Section

                        // Stats Cards - Horizontal Scroll
                        SizedBox(
                          height: 120, // Fixed height for stats cards
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildStatCard("Todays Follow Ups", "42", 'assets/Dashboardicon5.png'),
                              const SizedBox(width: 16),
                              _buildStatCard("New Patients", "210", 'assets/Dashboardicon4.png'),
                              const SizedBox(width: 16),
                              _buildStatCard("Pending Reports", "12", 'assets/Dashboardicon3.png'),
                              const SizedBox(width: 16),
                              _buildStatCard("Total Appointment", "879", 'assets/Dashboardicon2.png'),
                              const SizedBox(width: 16),
                              _buildStatCard("Total Patients", "1222", 'assets/Dashboardicon1.png'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),


                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Bookmarks",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        children: [
                                          // Table Header
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.1),
                                              borderRadius: const BorderRadius.only(
                                                  topRight: Radius.circular(12),
                                                  topLeft: Radius.circular(12)),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Patient name",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Diagnosis",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Summary",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "Actions",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Table Rows
                                          Expanded(
                                            child: ListView(
                                              children: [
                                                _buildTableRow("Gretchen O'Kon, M/31", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                _buildDivider(),
                                                _buildTableRow("Whitney Hettinger, F/22", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                _buildDivider(),
                                                _buildTableRow("Leroy Auer, M/32", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                _buildDivider(),
                                                _buildTableRow("Gilbert Rogahn, F/46", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                _buildDivider(),
                                                _buildTableRow("Leroy Auer, M/54", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                _buildDivider(),
                                                _buildTableRow("Gilbert Rogahn, F/37", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                _buildDivider(),
                                                _buildTableRow("Ms. Luz Hueis, M/44", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
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
                        ),

                        const SizedBox(height: 20),

                        // Follow Ups Section
                        SizedBox(
                          height: 200, // Fixed height for follow-ups
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Follow ups",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      "Today",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
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

                  // Sidebar Column (20% width)
                  Expanded(
                    flex: 3, // 20% of width
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Add more sidebar items here
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );


  }
  Widget _addPatient({
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController phoneController,
    required bool isLoading,  // Added this parameter
    required VoidCallback onPressed,  // Added this parameter
  })
  {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Patient Registration',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C3B70),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quickly onboard a patient into the system.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondary),
            ),
            const SizedBox(height: 24),
            _buildField('First Name', 'Enter first name',   [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Only letters allowed
            ],firstNameController,    validator: (value) => value?.isEmpty ?? true
                ? 'Please enter patient name'
                : null,),
            const SizedBox(height: 16),
            _buildField('Last Name', 'Enter last name', [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Only letters allowed
            ], lastNameController,validator: (value) => value?.isEmpty ?? true
                ? 'Please enter patient name'
                : null,),
            const SizedBox(height: 16),
            _buildField('Phone Number', 'Enter Phone Number', [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Only letters allowed
            ], phoneController,    validator: (value) {
              if (value?.isEmpty ?? true)
                return 'Please enter phone number';
              if (!RegExp(r'^[0-9]{10}$').hasMatch(value!))
                return 'Enter a valid 10-digit number';
              return null;
            },
            ),
            const SizedBox(height: 24),
            Row(
              spacing: 10,
              children: [
                Expanded(

                  child: Animatedbutton(

                    title: 'Discard',
                    isLoading: isLoading,
                    onPressed: () {
                      _nameController.clear();
                      _lastnameController.clear();
                      _phoneController.clear();
                      Navigator.pop(context);
                    },
                    titlecolor:AppColors.secondary,
                    backgroundColor: Colors.white,
                    borderColor: AppColors.secondary,

                    shadowColor: AppColors.primary,
                  ),
                ),


                Expanded(
                  child: Animatedbutton(
                    title: 'Add Patient',
                    isLoading: isLoading,
                    onPressed: _isSubmitting ? null : () => _AddPatientsubmit(),



                    backgroundColor: AppColors.secondary,
                    shadowColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Example of the _buildField method (you should have this implemented)
  Widget _buildField(
      String label,
      String hint,
  final List<TextInputFormatter>? inputFormatters,
      TextEditingController controller, {
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: controller,
          hintText: hint,
          inputFormatters:inputFormatters,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: validator,

        ),
      ],
    );
  }


  Widget _buildFollowUpItem({
    required String name,
    required String date,
    required String condition,
    required String phone,
    required bool isToday,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
      ),


      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primary
            ),
          ),
          const SizedBox(height: 4),
          Text(date,
            style: const TextStyle(
            fontWeight: FontWeight.bold,
              color: AppColors.primary,
            fontSize: 12,
          ),
          ),
          const SizedBox(height: 4),
          Text(condition, style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
              color: AppColors.primary
          ),),
          const SizedBox(height: 8),
          Row(
            children: [

              Text(phone, style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                  color: AppColors.primary
              ),),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String assetPath) {
    return Container(
      width: 170,

      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Image.asset(
                assetPath,
                height: 50,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String patientName, String diagnosis, String summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              patientName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(diagnosis),
          ),
          Expanded(
            flex: 2,
            child: Text(summary),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Action menu logic
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey,
    );
  }
}