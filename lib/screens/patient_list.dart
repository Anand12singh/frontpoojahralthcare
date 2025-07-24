import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:poojaheakthcare/constants/global_variable.dart';
import 'package:poojaheakthcare/screens/patient_form_screen.dart';
import '../constants/ResponsiveUtils.dart';
import '../constants/base_url.dart';
import '../provider/PermissionService.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../website_code/web_screens/CustomSidebar.dart';
import '../website_code/web_screens/Home_Screen.dart';
import '../website_code/web_screens/PatientDataTabsScreen.dart';
import '../website_code/web_screens/SearchBar.dart';
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
  int _currentPage = 1;
  int _rowsPerPage = 100;
  int _totalRecords = 0;

  String _search = '';
  String? _sortBy;

  String _sortOrder = 'asc';

  List<int> _rowsPerPageOptions = [100, 0]; // 0 will represent "ALL"

  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String errorMessage = '';
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  Future<void> _initializeData() async {
    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();
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
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        "page": _rowsPerPage == 0 ? 1 : _currentPage, // When showing ALL, always request page 1
        "limit": _rowsPerPage == 0 ? 10000 : _rowsPerPage, // Use a large number for "ALL"
        "search": _search,
        "sortBy": _sortBy ?? "",
        "sortOrder": _sortOrder,
      });

      final response = await http.post(
        Uri.parse('https://uatpoojahealthcare.ortdemo.com/api/get_allpatients'), // your endpoint
        headers: headers,
        body: body,
      );
print("response.body");
print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          patients = _transformApiData(responseData['data'] ?? []);
          filteredPatients = List.from(patients);
          _totalRecords = responseData['totalRecords'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load patients.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error occurred: ${e.toString()}';
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
      width: ResponsiveUtils.scaleWidth(context, 500),
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
      _search = query.trim();
      _currentPage = 1;

    });
    _fetchPatients();
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

  String _toCamelCase(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) =>
    word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }
  @override
  Widget build(BuildContext context) {
    int fromRecord = ((_currentPage - 1) * (_rowsPerPage == 0 ? filteredPatients.length : _rowsPerPage)) + 1;
    int toRecord = _rowsPerPage == 0
        ? filteredPatients.length
        : ((_currentPage - 1) * _rowsPerPage) + filteredPatients.length;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),

 

      body: Row(
        children: [

          Sidebar(),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16,bottom: 12,top: 12,right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Patient List',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 26,
                              ),
                            ),
                            Visibility(
                              visible: PermissionService().canAddPatients,
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.only(left: 16),
                                  height: 50, // define desired button height
                                  width: ResponsiveUtils.scaleWidth(context, 160),
                                  child: Animatedbutton(
                                    title: '+ Add Patient',
                                    isLoading: _isLoading,
                                    onPressed: () {
                                      _showAddPatientModal(context);
                                    },
                                    backgroundColor: AppColors.secondary,
                                    shadowColor: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),

                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                          ),
                          child: Column(
                            spacing: 10,
                            children: [
                          Row(
                          children: [
                          Flexible(
                          flex: 3,
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    const Text('Show '),
                                    const SizedBox(width: 8),
                                    DropdownButton2<int>(
                                      dropdownStyleData: DropdownStyleData(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)))
                                      ),
                                      value: _rowsPerPage,
                                      items: _rowsPerPageOptions.map((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(value == 0 ? 'ALL' : value.toString()),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _rowsPerPage = value!;
                                          _currentPage = 1;
                                          _fetchPatients();
                                        });
                                      },
                                    ),
                                  ],
                                ),


                              /*  SizedBox(width: 10,),
                                const Text('Sort By'),
                                DropdownButton2<String>(
                                  dropdownStyleData: DropdownStyleData(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)))),
                                  hint: Text('Sort By'),
                                  value: _sortBy,
                                  items: [
                                    DropdownMenuItem(value: 'first_name', child: Text('First Name')),
                                    DropdownMenuItem(value: 'last_name', child: Text('Last Name')),
                                    DropdownMenuItem(value: 'age', child: Text('Age')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _sortBy = value;
                                      _fetchPatients();
                                    });
                                  },
                                ),
                                SizedBox(width: 10),
                                const Text('Order By'),
                                DropdownButton2<String>(
                                  dropdownStyleData: DropdownStyleData(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)))),
                                  hint: Text('Order By'),
                                  value: _sortOrder,
                                  items: [
                                    DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                                    DropdownMenuItem(value: 'desc', child: Text('Descending')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _sortOrder = value!;
                                      _fetchPatients();
                                    });
                                  },
                                ),

                  */

                              ],
                            ),
                          ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 1,
                    child: CustomTextField(
                      controller: searchController,
                      onChanged: filterPatients,
                      hintText: "Search patient",
                      prefixIcon: Icons.search_rounded,
                    ),
                  ),
                  ],
                      ),
                      Expanded(
                                child: Container(
                                  decoration: BoxDecoration(border: Border.all(color: AppColors.primary.withOpacity(0.1),),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),

                                    ),),
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
                                              Expanded(flex: 1, child: Text("PHID", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                                              Expanded(flex: 3, child: Row(
                                                children: [
                                                  Text(
                                                    "Patient Name",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primary,
                                                      fontSize: ResponsiveUtils.fontSize(context, 16),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if (_sortBy == 'age') {
                                                          // toggle order
                                                          _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
                                                        } else {
                                                          // if changing sort field, start with ascending
                                                          _sortBy = 'age';
                                                          _sortOrder = 'asc';
                                                        }
                                                        _fetchPatients();
                                                      });
                                                    },
                                                    icon: Icon(
                                                      _sortBy == 'age'
                                                          ? (_sortOrder == 'asc'
                                                          ? Icons.arrow_upward
                                                          : Icons.arrow_downward)
                                                          : Icons.unfold_more_rounded,
                                                      size: ResponsiveUtils.fontSize(context, 20),
                                                      color: AppColors.primary,
                                                    ),
                                                  )
                                                ],

                                              )),
                                              Expanded(flex: 2, child: Row(
                                                children: [
                                                  Text("Patient Age", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16))),

                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if (_sortBy == 'first_name') {
                                                          // toggle order
                                                          _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
                                                        } else {
                                                          // if changing sort field, start with ascending
                                                          _sortBy = 'first_name';
                                                          _sortOrder = 'asc';
                                                        }
                                                        _fetchPatients();
                                                      });
                                                    },
                                                    icon: Icon(
                                                      _sortBy == 'first_name'
                                                          ? (_sortOrder == 'asc'
                                                          ? Icons.arrow_upward
                                                          : Icons.arrow_downward)
                                                          : Icons.unfold_more_rounded,
                                                      size: ResponsiveUtils.fontSize(context, 20),
                                                      color: AppColors.primary,
                                                    ),
                                                  )
                                                ],
                                              )),
                                              Expanded(flex: 2, child: Text("Patient Gender", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                                              Expanded(flex: 2, child: Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),
                                              Expanded(flex: 2, child: Text("Last Visit", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary,fontSize:  ResponsiveUtils.fontSize(context, 16)))),

                                              if(PermissionService().canEditPatients ||   PermissionService().canDeletePatients)
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
                                            final _gender = patient?['gender'] == 1 ? 'Male' : 'Female';
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
                                              child: Row(
                                                children: [
                                                  Expanded(flex: 1, child: Text(patient['phid'] ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                  Expanded(flex: 3, child: Text(patient['name'] ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                  Expanded(flex: 2, child: Text(patient['age'].toString() ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                  Expanded(flex: 2, child: Text(_gender ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                  Expanded(flex: 2, child: Text(patient['phone'] ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),
                                                  Expanded(flex: 2, child: Text(_toCamelCase(patient['lastVisit']) ?? '',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),)),

                                                  if(PermissionService().canEditPatients ||   PermissionService().canDeletePatients)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Wrap(
                                                      children: [

                                                        Visibility(
                                                          visible: PermissionService().canEditPatients,
                                                          child: IconButton(
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
                                                              Navigator.pushReplacementNamed(context, '/patientData');

                                                            },
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: PermissionService().canDeletePatients,
                                                          child: IconButton(
                                                            icon:  Icon(Icons.delete_outline, color: Colors.red,size:  ResponsiveUtils.fontSize(context, 22),),
                                                            onPressed: () {
                                                              _showDeleteDialog(context, patient['phid']);
                                                            },
                                                          ),
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

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Showing $fromRecord to $toRecord of $_totalRecords records'),   Row(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // FIRST PAGE
                                            IconButton(
                                              icon: const Icon(Icons.first_page),
                                              onPressed: _currentPage > 1
                                                  ? () {
                                                setState(() {
                                                  _currentPage = 1;
                                                });
                                                _fetchPatients();
                                              }
                                                  : null,
                                            ),
                                            // PREVIOUS
                                            IconButton(
                                              icon: const Icon(Icons.chevron_left),
                                              onPressed: _currentPage > 1
                                                  ? () {
                                                setState(() {
                                                  _currentPage--;
                                                });
                                                _fetchPatients();
                                              }
                                                  : null,
                                            ),

                                            // PAGE NUMBERS
                                            ..._buildPageButtons(),

                                            // NEXT
                                            IconButton(
                                              icon: const Icon(Icons.chevron_right),
                                              onPressed: _currentPage < totalPages
                                                  ? () {
                                                setState(() {
                                                  _currentPage++;
                                                });
                                                _fetchPatients();
                                              }
                                                  : null,
                                            ),

                                            // LAST PAGE
                                            IconButton(
                                              icon: const Icon(Icons.last_page),
                                              onPressed: _currentPage < totalPages
                                                  ? () {
                                                setState(() {
                                                  _currentPage = totalPages;
                                                });
                                                _fetchPatients();
                                              }
                                                  : null,
                                            ),

                                            const SizedBox(width: 16),

                                            // Jump-to-page box
                                            SizedBox(
                                              width: 50,
                                              height: 30,
                                              child: TextFormField(
                                                initialValue: _currentPage.toString(),
                                                textAlign: TextAlign.center,
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                                  border: OutlineInputBorder(),
                                                ),
                                                onFieldSubmitted: (value) {
                                                  int? page = int.tryParse(value);
                                                  if (page != null && page >= 1 && page <= totalPages) {
                                                    setState(() {
                                                      _currentPage = page;
                                                    });
                                                    _fetchPatients();
                                                  }
                                                },
                                              ),
                                            ),

                                            SizedBox(width: 8),

                                            Text("of $totalPages pages"),
                                          ],
                                        ),
                                      ],
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
                Searchbar(),
              ],
            ),
          ),
        ],
      ),

    );
  }

  int get totalPages {
    if (_totalRecords == 0) return 1;
    if (_rowsPerPage == 0) return 1; // When showing ALL, there's only 1 page
    return (_totalRecords / _rowsPerPage).ceil();
  }

  List<Widget> _buildPageButtons() {
    int maxButtons = 5;
    int startPage = (_currentPage - (maxButtons ~/ 2)).clamp(1, totalPages);
    int endPage = (startPage + maxButtons - 1).clamp(1, totalPages);

    if (endPage - startPage < maxButtons - 1) {
      startPage = (endPage - maxButtons + 1).clamp(1, totalPages);
    }

    List<Widget> buttons = [];
    for (int i = startPage; i <= endPage; i++) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              i == _currentPage ? AppColors.secondary : Colors.white,
              foregroundColor:
              i == _currentPage ? Colors.white : AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size(0, 36),
            ),
            onPressed: () {
              setState(() {
                _currentPage = i;
              });
              _fetchPatients();
            },
            child: Text(i.toString()),
          ),
        ),
      );
    }
    return buttons;
  }

  void _showDeleteDialog(BuildContext context, String patientId) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: ResponsiveUtils.scaleWidth(context, 450),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Confirm Delete',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.scaleHeight(context, 20)),
                    Text(
                      'Are you sure you want to delete patient $patientId?',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveUtils.scaleHeight(context, 30)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: ResponsiveUtils.scaleWidth(context, 120),
                          child: Animatedbutton(
                            title: 'Cancel',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            titlecolor: AppColors.red,
                            backgroundColor: Colors.white,
                            shadowColor: Colors.white,
                            borderColor: AppColors.red,
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.scaleWidth(context, 120),
                          child: Animatedbutton(
                            backgroundColor: AppColors.secondary,
                            shadowColor: Colors.white,
                            title: 'Delete',
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _deletePatient(patientId);
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

}