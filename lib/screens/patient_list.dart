import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:poojaheakthcare/constants/global_variable.dart';
import 'package:poojaheakthcare/screens/patient_form_screen.dart';
import '../constants/ResponsiveUtils.dart';
import '../constants/base_url.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../website_code/web_screens/Home_Screen.dart';
import '../widgets/AnimatedButton.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/showTopSnackBar.dart';

class RecentPatientsListScreen extends StatefulWidget {
  const RecentPatientsListScreen({super.key});

  @override
  _RecentPatientsListScreenState createState() => _RecentPatientsListScreenState();
}

class _RecentPatientsListScreenState extends State<RecentPatientsListScreen> {
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  TextEditingController searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String searchQuery = "";
  bool sortByName = true;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String errorMessage = '';
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchPatients();
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
          log('${response.reasonPhrase}');
          errorMessage = 'Failed to load patients.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        log('${e.toString()}');
        errorMessage = 'No results found.';
        isLoading = false;
      });
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
          Navigator.of(context).pop();
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
                    titlecolor:AppColors.red,
                    backgroundColor: Colors.white,
                    borderColor: AppColors.red,

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
  Future<void> _deletePatient(String patientId) async {
    try {
      setState(() => isLoading = true);
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        showTopRightToast(
            context, 'Authentication token not found. Please login again.');
        return;
      }
      final headers = {
        'Content-Type': 'application/json',
        'Cookie': 'connect.sid=s%3AuEDYQI5oGhq5TztFK-F_ivqibtXxbspe.L65SiGdo4p4ZZY01Vnqd9tb4d64NFnzksLXndIK5zZA',
      'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$localurl/soft_delete_patient'),
        headers: headers,
        body: json.encode({'patient_id': patientId}),
      );


      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          showTopRightToast(context, 'Patient deleted successfully', backgroundColor: Colors.green);
          _fetchPatients(); // Refresh the list
        } else {
          showTopRightToast(context, responseData['message'] ?? 'Failed to delete patient', backgroundColor: Colors.red);
        }
      } else {
        showTopRightToast(context, 'Error: ${response.statusCode}', backgroundColor: Colors.red);
      }
    } catch (e) {
      showTopRightToast(context, 'Error: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF2FF),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Patient List',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
        ),
      ),


      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Container(
                margin:  EdgeInsets.only(left: 16),
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
              Padding(
                padding:  EdgeInsets.all(16),
                child: SizedBox(

                  width:  ResponsiveUtils.scaleWidth(context, 350),
                  child: CustomTextField(
                    controller: searchController,
                    onChanged: filterPatients,
                    hintText: "Search patient",
                    prefixIcon: Icons.search_rounded,

                  ),
                ),
              ),
            ],
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
                    child:  Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text("PHID", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                          Expanded(flex: 2, child: Text("Patient Name", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                          Expanded(flex: 2, child: Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                          Expanded(flex: 2, child: Text("Last Visit", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(patient['phid'] ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                              Expanded(flex: 2, child: Text(patient['name'] ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                              Expanded(flex: 2, child: Text(patient['phone'] ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                              Expanded(flex: 2, child: Text(patient['lastVisit'] ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                              Expanded(
                                flex: 1,
                                child: Wrap(
                                  children: [
                                    IconButton(
                                      icon:  Icon(Icons.edit_outlined , color: AppColors.primary,size:  ResponsiveUtils.fontSize(context, 22)),
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
                                    IconButton(
                                      icon:  Icon(Icons.delete_outline, color: Colors.red,size:  ResponsiveUtils.fontSize(context, 22),),
                                      onPressed: () {
                                        _showDeleteDialog(context, patient['phid']);
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
        ],
      ),

    );
  }

  void _showDeleteDialog(BuildContext context, String patientId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),

          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete patient $patientId?'),
          actions: [
            TextButton(
              child: const Text('Cancel',style: TextStyle(color: AppColors.primary),),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // Implement delete functionality
                Navigator.of(context).pop();
                await _deletePatient(patientId);



              },
            ),
          ],
        );
      },
    );
  }
}