import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../constants/global_variable.dart';
import '../services/auth_service.dart';
import '../widgets/show_dialog.dart';

class PatientFormScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final int patientExist;
  final int? patientId;
  final String phid;
  const PatientFormScreen(
      {Key? key,
      required this.firstName,
      required this.lastName,
      required this.phone,
      required this.patientExist,
      required this.phid,
      this.patientId})
      : super(key: key);

  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  int _currentStep = 0;
  final GlobalKey<FormState> _personalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _medicalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reportsFormKey = GlobalKey<FormState>();
  //final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _prRectumFiles = [];
  List<Map<String, dynamic>> _paAbdomenFiles = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Personal Information Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _phIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  String _gender = 'Male';
  DateTime _selectedDate = DateTime.now();
  String _location = 'Pooja Healthcare';

  // Medical Information Controllers
  final TextEditingController _heightFtController = TextEditingController();
  // Remove _heightInController and keep only:
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _rbsController = TextEditingController();
  final TextEditingController _complaintsController = TextEditingController();
  final TextEditingController _dmSinceController = TextEditingController();
  final TextEditingController _hypertensionSinceController = TextEditingController();
  final TextEditingController _otherIllnessController = TextEditingController();
  final TextEditingController _surgicalHistoryController = TextEditingController();
  final TextEditingController _drugAllergyController = TextEditingController();

  bool _hasDM = false;
  bool _hasHypertension = false;

  // Examination Controllers
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _bpSystolicController = TextEditingController();
  final TextEditingController _bpDiastolicController = TextEditingController();
  final TextEditingController _oedemaDetailsController =
      TextEditingController();
  final TextEditingController _lymphadenopathyDetailsController =
      TextEditingController();
  final TextEditingController _currentMedicationController =
      TextEditingController();
  bool _isFebrile = false;
  bool _hasPallor = false;
  bool _hasIcterus = false;
  bool _hasOedema = false;
  bool _hasLymphadenopathy = false;
  bool _isLoadingLocations = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _locations = [];
  String? locationId = '1';
  Map<String, dynamic>? _patientData;
  Map<String, dynamic>? _visitData;
  Map<String, dynamic>? _documentData;

  // Systems Review Controllers
  final TextEditingController _rsController = TextEditingController();
  final TextEditingController _cvsController = TextEditingController();
  final TextEditingController _cnsController = TextEditingController();
  final TextEditingController _paAbdomenController = TextEditingController();
  final TextEditingController _prRectumController = TextEditingController();
  final TextEditingController _localExamController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _comorbiditiesController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _adviseController = TextEditingController();
  final TextEditingController _doctorNotesController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _copdDescriptionController = TextEditingController();
  final TextEditingController _ihdDescriptionController = TextEditingController();
  bool _hasIHD = false;
  bool _hasCOPD = false;

  // File Management
  final Map<String, List<Map<String, dynamic>>> _uploadedFiles = {
    'Blood Reports': [],
    'X-Ray Reports': [],
    'CT Scan Reports': [],
    'ECG Reports': [],
    'Echocardiogram Reports': [],
  };

  @override
  void initState() {
    _fetchLocations();

    print('First Name: ${widget.firstName}');
    print('Last Name: ${widget.lastName}');
    print('Phone: ${widget.phone}');
    print('Patient Exist: ${widget.patientExist}');
    print('PHID: ${widget.phid}');
    super.initState();
    _phIdController.text = 'PH-${widget.phid}';
    _ageController.text = '';

    // Initialize some default values for testing
    _firstNameController.text = '${widget.firstName}';
    _lastNameController.text = '${widget.lastName}';
    _phoneController.text = '${widget.phone}';
    if (widget.patientExist == 2 && widget.patientId != null) {
      _fetchPatientDetails(widget.patientId!);
    }
    if (widget.patientExist == 2) {
      _fetchPatientData();
    }
    // _addressController.text = '123 Main St, City';
    // _ageController.text = '35';
    // _heightFtController.text = '5';
    // _heightInController.text = '10';
    // _weightController.text = '70';
    // _calculateBMI();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Dispose all text controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _phIdController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _referralController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _rbsController.dispose();
    _complaintsController.dispose();
    _dmSinceController.dispose();
    _hypertensionSinceController.dispose();
    _otherIllnessController.dispose();
    _surgicalHistoryController.dispose();
    _drugAllergyController.dispose();
    _pulseController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _oedemaDetailsController.dispose();
    _lymphadenopathyDetailsController.dispose();
    _currentMedicationController.dispose();
    _rsController.dispose();
    _cvsController.dispose();
    _cnsController.dispose();
    _paAbdomenController.dispose();
    _prRectumController.dispose();
    _localExamController.dispose();
    _diagnosisController.dispose();
    _comorbiditiesController.dispose();
    _planController.dispose();
    _adviseController.dispose();
    _doctorNotesController.dispose();
    _altPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper functions to ensure valid values
  String _ensureString(String? value) => value?.trim() ?? '';
  String _ensureNumber(String? value) => value?.trim().isEmpty ?? true ? '0' : value!.trim();
  String _ensureStatus(bool value) => value ? '1' : '0';
  String _ensureGender(String gender) {
    return gender == 'Male' ? '1' : gender == 'Female' ? '2' : '3';
  }

  Future<void> _fetchPatientData() async {
    setState(() => _isLoading = true);
    try {
      final requestBody = {
        'id': 1, // Convert phid to int
      };
      final response = await http.post(
        Uri.parse('https://pooja-healthcare.ortdemo.com/api/getpatientbyid'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Response: $data'); // Log the full response

        if (data['status'] == true) {
          // Safely handle the response structure
          final responseData = data['data'];
          if (responseData is List && responseData.isNotEmpty) {
            final firstDataItem = responseData[0];
            setState(() {
              // Handle patient data
              if (firstDataItem['patient'] is List && firstDataItem['patient'].isNotEmpty) {
                _patientData = firstDataItem['patient'][0] as Map<String, dynamic>;
              } else {
                _patientData = {};
              }

              // Handle visit info
              if (firstDataItem['PatientVisitInfo'] is List && firstDataItem['PatientVisitInfo'].isNotEmpty) {
                _visitData = firstDataItem['PatientVisitInfo'][0] as Map<String, dynamic>;
              } else {
                _visitData = {};
              }

              // Handle documents
              if (firstDataItem['PatientDocumentInfo'] is Map) {
                _documentData = firstDataItem['PatientDocumentInfo'] as Map<String, dynamic>;
              } else {
                _documentData = {};
              }

              _populateFormFields();
            });
          } else if (responseData is Map) {
            // Handle case where data is directly a Map
            setState(() {
              _patientData = responseData['patient'] ?? {};
              _visitData = responseData['PatientVisitInfo'] ?? {};
              _documentData = responseData['PatientDocumentInfo'] ?? {};
              _populateFormFields();
            });
          } else {
            throw Exception('Unexpected data format in response');
          }
        } else {
          throw Exception('API returned false status');
        }
      } else {
        throw Exception('Failed to load patient data: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching patient data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading patient data: ${error.toString()}')),
      );
      _initializeWithEmptyData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFormFields() {
    try {
      // Personal Info
      _firstNameController.text = _patientData?['first_name']?.toString() ?? '';
      _lastNameController.text = _patientData?['last_name']?.toString() ?? '';
      _phoneController.text = _patientData?['mobile_no']?.toString() ?? '';
      _altPhoneController.text = _patientData?['alternative_no']?.toString() ?? '';
      _phIdController.text = 'PH-${_patientData?['phid']?.toString() ?? ''}';
      _addressController.text = _patientData?['address']?.toString() ?? '';
      _descriptionController.text = _patientData?['description']?.toString() ?? '';
      _gender = _patientData?['gender'] == 1 ? 'Male' : 'Female';
      try {
        _selectedDate = DateTime.parse(_patientData?['date']?.toString() ?? DateTime.now().toString());
      } catch (e) {
        _selectedDate = DateTime.now();
      }
      _referralController.text = _patientData?['referral_by']?.toString() ?? '';

      // Visit Info
      _ageController.text = _visitData?['age']?.toString() ?? '';
      _heightController.text = _visitData?['height']?.toString() ?? '';
      _weightController.text = _visitData?['weight']?.toString() ?? '';
      _bmiController.text = _visitData?['bmi']?.toString() ?? '';
      _rbsController.text = _visitData?['rbs']?.toString() ?? '';
      _complaintsController.text = _visitData?['chief_complaints']?.toString() ?? '';
      _hasDM = _visitData?['history_of_dm_status'] == 1;
      _dmSinceController.text = _visitData?['history_of_dm_description']?.toString() ?? '';
      _hasHypertension = _visitData?['hypertension_status'] == 1;
      _hypertensionSinceController.text = _visitData?['hypertension_description']?.toString() ?? '';
      _hasIHD = _visitData?['IHD_status'] == 1;
      _ihdDescriptionController.text = _visitData?['IHD_description']?.toString() ?? '';
      _hasCOPD = _visitData?['COPD_status'] == 1;
      _copdDescriptionController.text = _visitData?['COPD_description']?.toString() ?? '';
      _otherIllnessController.text = _visitData?['any_other_illness']?.toString() ?? '';
      _surgicalHistoryController.text = _visitData?['past_surgical_history']?.toString() ?? '';
      _drugAllergyController.text = _visitData?['drug_allergy']?.toString() ?? '';
      _isFebrile = (_visitData?['temp']?.toString() ?? '') == '98.6';
      _pulseController.text = _visitData?['pulse']?.toString() ?? '';
      _bpSystolicController.text = _visitData?['bp_systolic']?.toString() ?? '';
      _bpDiastolicController.text = _visitData?['bp_diastolic']?.toString() ?? '';
      _hasPallor = _visitData?['pallor'] == 1;
      _hasIcterus = _visitData?['icterus'] == 1;
      _hasOedema = _visitData?['oedema_status'] == 1;
      _oedemaDetailsController.text = _visitData?['oedema_description']?.toString() ?? '';
      _hasLymphadenopathy = (_visitData?['lymphadenopathy']?.toString() ?? '') != '';
      _lymphadenopathyDetailsController.text = _visitData?['lymphadenopathy']?.toString() ?? '';
      _currentMedicationController.text = _visitData?['HO_present_medication']?.toString() ?? '';
      _rsController.text = _visitData?['respiratory_system']?.toString() ?? '';
      _cvsController.text = _visitData?['cardio_vascular_system']?.toString() ?? '';
      _cnsController.text = _visitData?['central_nervous_system']?.toString() ?? '';
      _paAbdomenController.text = _visitData?['pa_abdomen']?.toString() ?? '';
      _prRectumController.text = _visitData?['pr_rectum']?.toString() ?? '';
      _localExamController.text = _visitData?['local_examination']?.toString() ?? '';
      _diagnosisController.text = _visitData?['clinical_diagnosis']?.toString() ?? '';
      _comorbiditiesController.text = _visitData?['comorbidities']?.toString() ?? '';
      _planController.text = _visitData?['plan']?.toString() ?? '';
      _adviseController.text = _visitData?['advise']?.toString() ?? '';
      _doctorNotesController.text = _patientData?['doctor_note']?.toString() ?? '';

      // Load documents
      _documentData?.forEach((typeId, files) {
        try {
          final typeIdInt = typeId.toString();
          if (_uploadedFiles.containsKey(typeIdInt) && files is List) {
            _uploadedFiles[typeIdInt] = files.map<Map<String, dynamic>>((file) {
              return {
                ...file is Map ? file as Map<String, dynamic> : {},
                'typeId': typeIdInt,
                'name': path.basename(file['media_url']?.toString() ?? ''),
                'type': path.extension(file['media_url']?.toString() ?? '')
                    .replaceAll('.', '')
                    .toUpperCase(),
                'size': 'N/A',
                'path': file['media_url']?.toString(),
              };
            }).toList();
          }
        } catch (e) {
          debugPrint('Error processing document type $typeId: $e');
        }
      });
    } catch (e) {
      debugPrint('Error populating form fields: $e');
    }
  }

  void _initializeWithEmptyData() {
    setState(() {
      _patientData = {
        'phid': widget.phid,
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'mobile_no': widget.phone
      };
      _visitData = {};
      _documentData = {};
      _populateFormFields();
    });
  }

  Future<void> _fetchPatientDetails(int patientId) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${await AuthService.getToken()}',
      };

      final response = await http.post(
        Uri.parse('https://pooja-healthcare.ortdemo.com/api/getpatientbyid'),
        headers: headers,
        body: json.encode({'id': patientId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true && responseData['data'].isNotEmpty) {
          final patientData = responseData['data'][0];
          final patientInfo = patientData['patient'][0];
          final visitInfo = patientData['PatientVisitInfo'].isNotEmpty
              ? patientData['PatientVisitInfo'][0]
              : null;
          final documents = patientData['PatientDocumentInfo'];

          // Update the UI with the fetched data
          setState(() {
            // Personal Information
            _addressController.text = patientInfo['address'] ?? '';
            _gender = patientInfo['gender'] == 1 ? 'Male'
                : patientInfo['gender'] == 2 ? 'Female' : 'Others';
            _referralController.text = patientInfo['referral_by'] ?? '';
            _doctorNotesController.text = patientInfo['doctor_note'] ?? '';

            // Format date
            if (patientInfo['date'] != null) {
              try {
                _selectedDate = DateTime.parse(patientInfo['date']);
              } catch (e) {
                print('Error parsing date: $e');
              }
            }

            // Set location if available
            if (patientInfo['location'] != null) {
              locationId = patientInfo['location'].toString();
              final location = _locations.firstWhere(
                      (loc) => loc['id'].toString() == locationId,
                  orElse: () => _locations.first
              );
              _location = location['location'];
            }

            if (visitInfo != null) {
              // Medical Information
              _ageController.text = visitInfo['age']?.toString() ?? '';
              _heightController.text = visitInfo['height']?.toString() ?? '';
              _weightController.text = visitInfo['weight']?.toString() ?? '';
              _bmiController.text = visitInfo['bmi']?.toString() ?? '';
              _rbsController.text = visitInfo['rbs']?.toString() ?? '';
              _complaintsController.text = visitInfo['chief_complaints'] ?? '';

              // Medical History
              _hasDM = visitInfo['history_of_dm_status'] == 1;
              _dmSinceController.text = visitInfo['history_of_dm_description'] ?? '';
              _hasHypertension = visitInfo['hypertension_status'] == 1;
              _hypertensionSinceController.text = visitInfo['hypertension_description'] ?? '';
              _otherIllnessController.text = visitInfo['any_other_illness'] ?? '';
              _surgicalHistoryController.text = visitInfo['past_surgical_history'] ?? '';
              _drugAllergyController.text = visitInfo['drug_allergy'] ?? '';

              // Examination
              _pulseController.text = visitInfo['pulse']?.toString() ?? '';
              _bpSystolicController.text = visitInfo['bp_systolic']?.toString() ?? '';
              _bpDiastolicController.text = visitInfo['bp_diastolic']?.toString() ?? '';
              _isFebrile = visitInfo['temp'] == '1';
              _hasPallor = visitInfo['pallor'] == 1;
              _hasIcterus = visitInfo['icterus'] == 1;
              _hasOedema = visitInfo['oedema_status'] == 1;
              _oedemaDetailsController.text = visitInfo['oedema_description'] ?? '';
              _lymphadenopathyDetailsController.text = visitInfo['lymphadenopathy'] ?? '';
              _currentMedicationController.text = visitInfo['HO_present_medication'] ?? '';

              // Systems Review
              _rsController.text = visitInfo['respiratory_system'] ?? '';
              _cvsController.text = visitInfo['cardio_vascular_system'] ?? '';
              _cnsController.text = visitInfo['central_nervous_system'] ?? '';
              _paAbdomenController.text = visitInfo['pa_abdomen'] ?? '';
              _prRectumController.text = visitInfo['pr_rectum'] ?? '';
              _localExamController.text = visitInfo['local_examination'] ?? '';
              _diagnosisController.text = visitInfo['clinical_diagnosis'] ?? '';
              _comorbiditiesController.text = visitInfo['comorbidities'] ?? '';
              _planController.text = visitInfo['plan'] ?? '';
              _adviseController.text = visitInfo['advise'] ?? '';
            }

            // Load documents if available
            if (documents != null) {
              _uploadedFiles.clear();

              // Blood Reports (doc_type_id = 1)
              if (documents['1'] != null) {
                _uploadedFiles['Blood Reports'] = documents['1'].map<Map<String, dynamic>>((doc) {
                  return {
                    'path': doc['media_url'],
                    'name': 'Blood Report ${doc['id']}',
                    'type': path.extension(doc['media_url']).replaceAll('.', '').toUpperCase(),
                  };
                }).toList();
              }

              // X-Ray Reports (doc_type_id = 2)
              if (documents['2'] != null) {
                _uploadedFiles['X-Ray Reports'] = documents['2'].map<Map<String, dynamic>>((doc) {
                  return {
                    'path': doc['media_url'],
                    'name': 'X-Ray Report ${doc['id']}',
                    'type': path.extension(doc['media_url']).replaceAll('.', '').toUpperCase(),
                  };
                }).toList();
              }

              // ECG Reports (doc_type_id = 3)
              if (documents['3'] != null) {
                _uploadedFiles['ECG Reports'] = documents['3'].map<Map<String, dynamic>>((doc) {
                  return {
                    'path': doc['media_url'],
                    'name': 'ECG Report ${doc['id']}',
                    'type': path.extension(doc['media_url']).replaceAll('.', '').toUpperCase(),
                  };
                }).toList();
              }

              // CT Scan Reports (doc_type_id = 4)
              if (documents['4'] != null) {
                _uploadedFiles['CT Scan Reports'] = documents['4'].map<Map<String, dynamic>>((doc) {
                  return {
                    'path': doc['media_url'],
                    'name': 'CT Scan Report ${doc['id']}',
                    'type': path.extension(doc['media_url']).replaceAll('.', '').toUpperCase(),
                  };
                }).toList();
              }

              // Echocardiogram Reports (doc_type_id = 5)
              if (documents['5'] != null) {
                _uploadedFiles['Echocardiogram Reports'] = documents['5'].map<Map<String, dynamic>>((doc) {
                  return {
                    'path': doc['media_url'],
                    'name': 'Echocardiogram Report ${doc['id']}',
                    'type': path.extension(doc['media_url']).replaceAll('.', '').toUpperCase(),
                  };
                }).toList();
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching patient details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load patient data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoadingLocations = true);

    try {
      final response = await http.get(
        Uri.parse('https://pooja-healthcare.ortdemo.com/api/getlocation'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _locations = List<Map<String, dynamic>>.from(data['locations']);
            // Set default location if needed
            if (_locations.isNotEmpty) {
              _location = _locations.first['location'];
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load locations')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _submitForm() async {
    // Validate forms
    bool personalValid = _personalInfoFormKey.currentState?.validate() ?? false;
    bool medicalValid = _medicalInfoFormKey.currentState?.validate() ?? false;
    bool reportsValid = _reportsFormKey.currentState?.validate() ?? false;

    if (!personalValid || !medicalValid || !reportsValid) {
      ShowDialogs.showSnackBar(context, 'Please fill all required fields');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
      );

      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        ShowDialogs.showSnackBar(context, 'Authentication token not found. Please login again.');
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://pooja-healthcare.ortdemo.com/api/storepatient'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Format date properly
      //final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      Map<String, String> fields = {
        'first_name': _ensureString(_firstNameController.text),
        'last_name': _ensureString(_lastNameController.text),
        'gender': _ensureGender(_gender),
        'mobile_no': _ensureString(_phoneController.text),
        'alternative_no': '',
        'address': _ensureString(_addressController.text),
        'date': '2025-03-28',
        'referral_by': _ensureString(_referralController.text),
        'location': locationId!, // Static value that works - replace with your location mapping
        'age': _ensureNumber(_ageController.text),
        'height': _ensureNumber(_heightController.text),
        'weight': _ensureNumber(_weightController.text),
        'bmi': _ensureNumber(_bmiController.text),
        'rbs': _ensureNumber(_rbsController.text),
        'chief_complaints': _ensureString(_complaintsController.text),
        'history_of_dm_status': _ensureStatus(_hasDM),
        'history_of_dm_description': _ensureString(_dmSinceController.text),
        'hypertension_status': _ensureStatus(_hasHypertension),
        'hypertension_description': _ensureString(_hypertensionSinceController.text),
        'IHD_status': '0',
        'IHD_description': '',
        'COPD_status': '0',
        'COPD_description': '',
        'any_other_illness': _ensureString(_otherIllnessController.text),
        'past_surgical_history': _ensureString(_surgicalHistoryController.text),
        'drug_allergy': _ensureString(_drugAllergyController.text),
        'temp': _ensureStatus(_isFebrile),
        'pulse': _ensureNumber(_pulseController.text),
        'bp_systolic': _ensureNumber(_bpSystolicController.text),
        'bp_diastolic': _ensureNumber(_bpDiastolicController.text),
        'pallor': _ensureStatus(_hasPallor),
        'icterus': _ensureStatus(_hasIcterus),
        'oedema_status': _ensureStatus(_hasOedema),
        'oedema_description': _ensureString(_oedemaDetailsController.text),
        'lymphadenopathy': _ensureString(_lymphadenopathyDetailsController.text),
        'HO_present_medication': _ensureString(_currentMedicationController.text),
        'respiratory_system': _ensureString(_rsController.text),
        'cardio_vascular_system': _ensureString(_cvsController.text),
        'central_nervous_system': _ensureString(_cnsController.text),
        'pa_abdomen': _ensureString(_paAbdomenController.text),
        'pr_rectum': _ensureString(_prRectumController.text),
        'local_examination': _ensureString(_localExamController.text),
        'clinical_diagnosis': _ensureString(_diagnosisController.text),
        'comorbidities': _ensureString(_comorbiditiesController.text),
        'plan': _ensureString(_planController.text),
        'advise': _ensureString(_adviseController.text),
        'status': Global.status ?? widget.patientId.toString(),
        'doctor_note': _ensureString(_doctorNotesController.text),
      };

      if (Global.status == '2') {
        fields['patientId'] = widget.patientId.toString();
      }

      request.fields.addAll(fields);

      // Add debug print
      print('Request Fields: ${request.fields}');

      // Handle file uploads
      for (var reportType in _uploadedFiles.keys) {
        for (var file in _uploadedFiles[reportType]!) {
          try {
            final fileToUpload = File(file['path']);
            if (await fileToUpload.exists()) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  _getApiFieldNameForReportType(reportType),
                  file['path'],
                ),
              );
            }
          } catch (e) {
            print('Error adding file: $e');
          }
        }
      }

      // Handle PA Abdomen files
      for (var file in _paAbdomenFiles) {
        try {
          final fileToUpload = File(file['path']);
          if (await fileToUpload.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'pa_abdomen_image', // API field name for PA Abdomen images
                file['path'],
              ),
            );
          }
        } catch (e) {
          print('Error adding PA Abdomen file: $e');
        }
      }

      // Handle PR Rectum files
      for (var file in _prRectumFiles) {
        try {
          final fileToUpload = File(file['path']);
          if (await fileToUpload.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'pr_rectum_image', // API field name for PR Rectum images
                file['path'],
              ),
            );
          }
        } catch (e) {
          print('Error adding PR Rectum file: $e');
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        ShowDialogs.showSnackBar(context, responseData['message'] ?? 'Patient record saved successfully');
        Navigator.of(context).pop();
      } else {
        print('Response Status: ${response.statusCode}');
        print('Response Body: $responseBody');
        ShowDialogs.showSnackBar(context, 'Failed to save patient record. Please try again.');
      }
    } catch (e) {
      Navigator.of(context).pop();
      print('Submission Error: $e');
      ShowDialogs.showSnackBar(context, 'Error occurred: ${e.toString()}');
    }
  }

  String _getApiFieldNameForReportType(String reportType) {
    switch (reportType) {
      case 'Blood Reports':
        return 'blood_report';
      case 'X-Ray Reports':
        return 'xray_report';
      case 'CT Scan Reports':
        return 'ct_scan_report';
      case 'ECG Reports':
        return 'ecg_report';
      case 'Echocardiogram Reports':
        return 'echocardiagram_report';
      default:
        return 'misc_report';
    }
  }

  // File Handling Methods
  Future<void> _handleFileSelection(String reportType, String source) async {
    try {
      var pickedFile;
      File? savedFile;

      if (source == 'camera' || source == 'gallery') {
        pickedFile = await _picker.pickImage(
          source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 90,
        );

        if (pickedFile != null) {
          savedFile = await _saveFile(reportType, pickedFile);
        }
      } else if (source == 'file') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );

        if (result != null && result.files.single.path != null) {
          final originalFile = File(result.files.single.path!);
          savedFile = await _saveFile(reportType, originalFile,
              originalName: result.files.single.name);
        }
      }

      if (savedFile != null) {
        final fileSize = (await savedFile.length()) / 1024;

        setState(() {
          _uploadedFiles[reportType]!.add({
            'path': savedFile!.path,
            'name': path.basename(savedFile.path),
            'size': fileSize.toStringAsFixed(1),
            'type': path
                .extension(savedFile.path)
                .replaceAll('.', '')
                .toUpperCase(),
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: ${e.toString()}')),
      );
    }
  }

  Future<File> _saveFile(String reportType, File originalFile,
      {String? originalName}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final reportDir = Directory(path.join(appDir.path, reportType));

    if (!await reportDir.exists()) {
      await reportDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = originalName != null
        ? path.extension(originalName)
        : path.extension(originalFile.path);
    final filename = '$timestamp$ext';

    final savedFile = File(path.join(reportDir.path, filename));
    await savedFile.writeAsBytes(await originalFile.readAsBytes());

    return savedFile;
  }

  Future<void> _removeFile(String reportType, Map<String, dynamic> file) async {
    try {
      final fileToDelete = File(file['path']);
      if (await fileToDelete.exists()) {
        await fileToDelete.delete();
      }

      setState(() {
        _uploadedFiles[reportType]!.remove(file);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete file: ${e.toString()}')),
      );
    }
  }

  // Form Methods
  void _calculateBMI() {
    if (_heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      try {
        // Split the height into feet and inches
        List<String> parts = _heightController.text.split('.');
        int feet = int.parse(parts[0]);
        int inches = parts.length > 1 ? int.parse(parts[1]) : 0;

        // Validate inches (should be <12)
        if (inches >= 12) {
          _bmiController.text = 'Invalid inches';
          return;
        }

        // Calculate total height in meters
        double heightInMeters = ((feet * 12) + inches) * 0.0254;
        double weightKg = double.parse(_weightController.text);

        // Calculate BMI (kg/m² formula)
        if (heightInMeters > 0 && weightKg > 0) {
          double bmi = weightKg / (heightInMeters * heightInMeters);
          _bmiController.text = bmi.toStringAsFixed(1);
        } else {
          _bmiController.text = '';
        }
      } catch (e) {
        _bmiController.text = 'Invalid format';
      }
    } else {
      _bmiController.text = '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  /*void _submitForm() {
    bool personalValid = _personalInfoFormKey.currentState?.validate() ?? false;
    bool medicalValid = _medicalInfoFormKey.currentState?.validate() ?? false;
    bool reportsValid = _reportsFormKey.currentState?.validate() ?? false;

    if (personalValid && medicalValid && reportsValid) {
      Map<String, dynamic> patientData = {
        'personalInfo': {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phone': _phoneController.text,
          'phId': _phIdController.text,
          'address': _addressController.text,
          'age': _ageController.text,
          'gender': _gender,
          'date': _selectedDate.toString(),
          'referral': _referralController.text,
          'location': _location,
        },
        'medicalInfo': {
          //'height': '${_heightFtController.text}ft ${_heightInController.text}in',
          'height': _heightController.text,
          'weight': _weightController.text,
          'bmi': _bmiController.text,
          'rbs': _rbsController.text,
          'complaints': _complaintsController.text,
          'hasDM': _hasDM,
          'dmSince': _dmSinceController.text,
          'hasHypertension': _hasHypertension,
          'hypertensionSince': _hypertensionSinceController.text,
          'otherIllness': _otherIllnessController.text,
          'surgicalHistory': _surgicalHistoryController.text,
          'drugAllergy': _drugAllergyController.text,
        },
        'examination': {
          'isFebrile': _isFebrile,
          'pulse': _pulseController.text,
          'bp': '${_bpSystolicController.text}/${_bpDiastolicController.text}',
          'hasPallor': _hasPallor,
          'hasIcterus': _hasIcterus,
          'hasOedema': _hasOedema,
          'oedemaDetails': _oedemaDetailsController.text,
          'hasLymphadenopathy': _hasLymphadenopathy,
          'lymphadenopathyDetails': _lymphadenopathyDetailsController.text,
          'currentMedication': _currentMedicationController.text,
        },
        'systemsReview': {
          'rs': _rsController.text,
          'cvs': _cvsController.text,
          'cns': _cnsController.text,
          'paAbdomen': _paAbdomenController.text,
          'prRectum': _prRectumController.text,
          'localExam': _localExamController.text,
          'diagnosis': _diagnosisController.text,
          'comorbidities': _comorbiditiesController.text,
          'plan': _planController.text,
          'advise': _adviseController.text,
        },
        'doctorNotes': _doctorNotesController.text,
        'files': _uploadedFiles,
      };

      print(patientData); // Replace with your submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient record saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }*/

  // UI Components
  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader('Reports & Documents'),
        const SizedBox(height: 20),
        _buildEnhancedUploadCard(
          title: 'Blood Reports',
          files: _uploadedFiles['Blood Reports']!,
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'X-Ray Reports',
          files: _uploadedFiles['X-Ray Reports']!,
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'CT Scan Reports',
          files: _uploadedFiles['CT Scan Reports']!,
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'ECG Reports',
          files: _uploadedFiles['ECG Reports']!,
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'Echocardiogram Reports',
          files: _uploadedFiles['Echocardiogram Reports']!,
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Doctor Notes', level: 2),
        _buildCustomInput(
          controller: _doctorNotesController,
          label: 'Clinical findings and recommendations',
          minLines: 5,
          maxLines: 10,
        ),
      ],
    );
  }

  Future<void> _uploadPrRectumFile(String source) async {
    try {
      File? savedFile;
      String? originalName;
      String fileType = '';

      if (source == 'camera' || source == 'gallery') {
        final pickedFile = await _imagePicker.pickImage(
          source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 90,
        );

        if (pickedFile != null) {
          savedFile = File(pickedFile.path);
          fileType =
              path.extension(pickedFile.path).replaceAll('.', '').toUpperCase();
        }
      } else if (source == 'file') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );

        if (result != null && result.files.single.path != null) {
          savedFile = File(result.files.single.path!);
          originalName = result.files.single.name;
          fileType = path
              .extension(result.files.single.path!)
              .replaceAll('.', '')
              .toUpperCase();
        }
      }

      if (savedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final filesDir = Directory(path.join(appDir.path, 'pr_rectum_files'));

        if (!await filesDir.exists()) {
          await filesDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ext = originalName != null
            ? path.extension(originalName)
            : path.extension(savedFile.path);
        final filename = '$timestamp$ext';

        final newFile = await savedFile.copy(path.join(filesDir.path, filename));
        final fileSize = (await newFile.length()) / 1024;

        setState(() {
          _prRectumFiles.add({
            'path': newFile.path,
            'name': originalName ?? filename,
            'size': fileSize.toStringAsFixed(1),
            'type': fileType,
          });
        });
      }
    } catch (e) {
      ShowDialogs.showSnackBar(context, 'Failed to upload file: ${e.toString()}');
    }
  }

  Widget _buildPrRectumFileItem(Map<String, dynamic> file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(file['type']),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${file['size']} KB • ${file['type']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
            onPressed: () => _removePrRectumFile(file),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _removePrRectumFile(Map<String, dynamic> file) async {
    try {
      final fileToDelete = File(file['path']);
      if (await fileToDelete.exists()) {
        await fileToDelete.delete();
      }

      setState(() {
        _prRectumFiles.remove(file);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete file: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadPaAbdomenFile(String source) async {
    try {
      File? savedFile;
      String? originalName;
      String fileType = '';

      if (source == 'camera' || source == 'gallery') {
        final pickedFile = await _imagePicker.pickImage(
          source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 90,
        );

        if (pickedFile != null) {
          savedFile = File(pickedFile.path);
          fileType =
              path.extension(pickedFile.path).replaceAll('.', '').toUpperCase();
        }
      } else if (source == 'file') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );

        if (result != null && result.files.single.path != null) {
          savedFile = File(result.files.single.path!);
          originalName = result.files.single.name;
          fileType = path
              .extension(result.files.single.path!)
              .replaceAll('.', '')
              .toUpperCase();
        }
      }

      if (savedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final filesDir = Directory(path.join(appDir.path, 'pa_abdomen_files'));

        if (!await filesDir.exists()) {
          await filesDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ext = originalName != null
            ? path.extension(originalName)
            : path.extension(savedFile.path);
        final filename = '$timestamp$ext';

        final newFile =
            await savedFile.copy(path.join(filesDir.path, filename));
        final fileSize = (await newFile.length()) / 1024;

        setState(() {
          _paAbdomenFiles.add({
            'path': newFile.path,
            'name': originalName ?? filename,
            'size': fileSize.toStringAsFixed(1),
            'type': fileType,
          });
        });
      }
    } catch (e) {
      ShowDialogs.showSnackBar(context, 'Failed to upload file: ${e.toString()}');
    }
  }

  Widget _buildPaAbdomenFileItem(Map<String, dynamic> file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(file['type']),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${file['size']} KB • ${file['type']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
            onPressed: () => _removePrRectumFile(file),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _removePaAbdomenFile(Map<String, dynamic> file) async {
    try {
      final fileToDelete = File(file['path']);
      if (await fileToDelete.exists()) {
        await fileToDelete.delete();
      }

      setState(() {
        _paAbdomenFiles.remove(file);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete file: ${e.toString()}')),
      );
    }
  }

  Widget _buildMedicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader('Medical Information'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildCustomInput(
                controller: _heightController,
                label: 'Height (ft.in)',
                hintText: 'e.g. 5.11 for 5ft 11in',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!RegExp(r'^\d{1,2}\.\d{1,2}$').hasMatch(value)) {
                    return 'Enter as ft.in (e.g. 5.11)';
                  }
                  return null;
                },
                onChanged: (_) => _calculateBMI(),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: _buildCustomInput(
                controller: _weightController,
                label: 'Weight (kg)',
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateBMI(),
              ),
            ),
            /*Expanded(
              child: _buildCustomInput(
                controller: _heightFtController,
                label: 'Height (ft)',
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateBMI(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCustomInput(
                controller: _heightInController,
                label: 'Height (in)',
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateBMI(),
              ),
            ),*/
          ],
        ),
        _buildCustomInput(
          controller: _bmiController,
          label: 'BMI',
          enabled: false,
        ),
        _buildCustomInput(
          controller: _rbsController,
          label: 'RBS (mg/dL)',
          keyboardType: TextInputType.number,
        ),
        _buildCustomInput(
          controller: _complaintsController,
          label: 'Chief Complaints',
          minLines: 3,
          maxLines: 5,
        ),
        _buildRadioGroup<bool>(
          label: 'History of DM:',
          groupValue: _hasDM,
          options: const [
            MapEntry(true, 'Yes'),
            MapEntry(false, 'No'),
          ],
          onChanged: (value) => setState(() => _hasDM = value!),
        ),
        if (_hasDM)
          _buildCustomInput(
            controller: _dmSinceController,
            label: 'Since when?',
          ),
        _buildRadioGroup<bool>(
          label: 'Hypertension:',
          groupValue: _hasHypertension,
          options: const [
            MapEntry(true, 'Yes'),
            MapEntry(false, 'No'),
          ],
          onChanged: (value) => setState(() => _hasHypertension = value!),
        ),
        if (_hasHypertension)
          _buildCustomInput(
            controller: _hypertensionSinceController,
            label: 'Since when?',
          ),
        _buildCustomInput(
          controller: _otherIllnessController,
          label: 'Any other illness',
          minLines: 2,
          maxLines: 3,
        ),
        _buildCustomInput(
          controller: _surgicalHistoryController,
          label: 'Past Surgical History',
          minLines: 2,
          maxLines: 3,
        ),
        _buildCustomInput(
          controller: _drugAllergyController,
          label: 'H/O Drug Allergy',
          minLines: 2,
          maxLines: 3,
        ),
        _buildSectionHeader('General Examination', level: 2),
        _buildRadioGroup<bool>(
          label: 'Temperature:',
          groupValue: _isFebrile,
          options: const [
            MapEntry(true, 'Febrile'),
            MapEntry(false, 'Afebrile'),
          ],
          onChanged: (value) => setState(() => _isFebrile = value!),
        ),
        _buildCustomInput(
          controller: _pulseController,
          label: 'Pulse (bpm)',
          keyboardType: TextInputType.number,
        ),
        Row(
          children: [
            Expanded(
              child: _buildCustomInput(
                controller: _bpSystolicController,
                label: 'BP Systolic',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCustomInput(
                controller: _bpDiastolicController,
                label: 'BP Diastolic',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        _buildRadioGroup<bool>(
          label: 'Pallor:',
          groupValue: _hasPallor,
          options: const [
            MapEntry(true, '+'),
            MapEntry(false, 'Nil'),
          ],
          onChanged: (value) => setState(() => _hasPallor = value!),
        ),
        _buildRadioGroup<bool>(
          label: 'Icterus:',
          groupValue: _hasIcterus,
          options: const [
            MapEntry(true, '+'),
            MapEntry(false, 'Nil'),
          ],
          onChanged: (value) => setState(() => _hasIcterus = value!),
        ),
        _buildRadioGroup<bool>(
          label: 'Oedema:',
          groupValue: _hasOedema,
          options: const [
            MapEntry(true, '+'),
            MapEntry(false, 'Nil'),
          ],
          onChanged: (value) => setState(() => _hasOedema = value!),
        ),
        if (_hasOedema)
          _buildCustomInput(
            controller: _oedemaDetailsController,
            label: 'Oedema Details',
          ),
        _buildRadioGroup<bool>(
          label: 'Lymphadenopathy:',
          groupValue: _hasLymphadenopathy,
          options: const [
            MapEntry(true, '+'),
            MapEntry(false, 'Nil'),
          ],
          onChanged: (value) => setState(() => _hasLymphadenopathy = value!),
        ),
        if (_hasLymphadenopathy)
          _buildCustomInput(
            controller: _lymphadenopathyDetailsController,
            label: 'Lymphadenopathy Details',
          ),
        _buildCustomInput(
          controller: _currentMedicationController,
          label: 'H/O Present Medication',
          minLines: 2,
          maxLines: 3,
        ),
        _buildSectionHeader('Systems Review', level: 2),
        _buildCustomInput(
          controller: _rsController,
          label: 'Respiratory System (RS)',
          minLines: 3,
          maxLines: 5,
        ),
        _buildCustomInput(
          controller: _cvsController,
          label: 'Cardiovascular System (CVS)',
          minLines: 3,
          maxLines: 5,
        ),
        _buildCustomInput(
          controller: _cnsController,
          label: 'Central Nervous System (CNS)',
          minLines: 3,
          maxLines: 5,
        ),
        _buildCustomInput(
          controller: _paAbdomenController,
          label: 'P/A Abdomen',
          minLines: 3,
          maxLines: 5,
        ),
        /*_buildCustomInput(
          controller: _prRectumController,
          label: 'P/R Rectum',
          minLines: 3,
          maxLines: 5,
        ),*/
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomInput(
              controller: _prRectumController,
              label: 'P/A Abdomen',
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            Text(
              'P/A Abdomen Documents',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // File upload button with options
            SizedBox(
              width: double.infinity,
              child: PopupMenuButton<String>(
                onSelected: (source) => _uploadPaAbdomenFile(source),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'camera',
                    child: ListTile(
                      leading: Icon(Icons.camera_alt, color: AppColors.primary),
                      title: const Text('Take Photo'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'gallery',
                    child: ListTile(
                      leading:
                      Icon(Icons.photo_library, color: AppColors.primary),
                      title: const Text('Choose from Gallery'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'file',
                    child: ListTile(
                      leading: Icon(Icons.insert_drive_file,
                          color: AppColors.primary),
                      title: const Text('Select File'),
                    ),
                  ),
                ],
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Document',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Display uploaded files
            if (_paAbdomenFiles.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Uploaded Documents:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._paAbdomenFiles
                      .map((file) => _buildPrRectumFileItem(file))
                      .toList(),
                ],
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomInput(
              controller: _prRectumController,
              label: 'P/R Rectum',
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            Text(
              'P/R Rectum Documents',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // File upload button with options
            SizedBox(
              width: double.infinity,
              child: PopupMenuButton<String>(
                onSelected: (source) => _uploadPrRectumFile(source),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'camera',
                    child: ListTile(
                      leading: Icon(Icons.camera_alt, color: AppColors.primary),
                      title: const Text('Take Photo'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'gallery',
                    child: ListTile(
                      leading:
                          Icon(Icons.photo_library, color: AppColors.primary),
                      title: const Text('Choose from Gallery'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'file',
                    child: ListTile(
                      leading: Icon(Icons.insert_drive_file,
                          color: AppColors.primary),
                      title: const Text('Select File'),
                    ),
                  ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Document',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Display uploaded files
            if (_prRectumFiles.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Uploaded Documents:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._prRectumFiles
                      .map((file) => _buildPrRectumFileItem(file))
                      .toList(),
                ],
              ),
          ],
        ),
        _buildCustomInput(
          controller: _localExamController,
          label: 'Local Examination',
          minLines: 3,
          maxLines: 5,
        ),
        _buildCustomInput(
          controller: _diagnosisController,
          label: 'Clinical Diagnosis',
          minLines: 3,
          maxLines: 5,
        ),
        _buildCustomInput(
          controller: _comorbiditiesController,
          label: 'Comorbidities',
          minLines: 2,
          maxLines: 3,
        ),
        _buildCustomInput(
          controller: _planController,
          label: 'Plan',
          minLines: 3,
          maxLines: 5,
        ),
        _buildCustomInput(
          controller: _adviseController,
          label: 'Advise',
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildCustomInput({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
    bool enabled = true,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    double borderRadius = 12.0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  children: isRequired
                      ? [
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: AppColors.error),
                          )
                        ]
                      : [],
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                errorText: errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: enabled ? Colors.white : AppColors.background,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: maxLines > 1 ? 16 : 14,
                ),
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
              keyboardType: keyboardType,
              minLines: minLines,
              maxLines: maxLines,
              enabled: enabled,
              validator: validator,
              onChanged: onChanged,
              style: TextStyle(
                color:
                    enabled ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.calendar_today, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDropdown<T>({
    required T value,
    required List<T> items,
    required String label,
    required void Function(T?) onChanged,
    String Function(T)? displayText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<T>(
              value: value,
              items: items
                  .map((item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          displayText != null
                              ? displayText(item)
                              : item.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: enabled
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: enabled ? onChanged : null,
              style: TextStyle(
                color:
                    enabled ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: enabled ? Colors.white : AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: enabled ? AppColors.primary : AppColors.textSecondary,
              ),
              borderRadius: BorderRadius.circular(12),
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup<T>({
    required String label,
    required T groupValue,
    required List<MapEntry<T, String>> options,
    required void Function(T?) onChanged,
    bool isHorizontal = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            child: isHorizontal
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 30), // Space between options
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<T>(
                              value: option.key,
                              groupValue: groupValue,
                              onChanged: onChanged,
                              //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity:
                                  const VisualDensity(horizontal: -1),
                            ),
                            const SizedBox(
                                width: 4), // Space between radio and text
                            Text(
                              option.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      return RadioListTile<T>(
                        title: Text(
                          option.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: option.key,
                        groupValue: groupValue,
                        onChanged: onChanged,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: AppColors.primary,
                        visualDensity: const VisualDensity(vertical: -4),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {int level = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: level == 1 ? 20 : 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildFileItem(String reportType, Map<String, dynamic> file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(file['type']),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${file['size']} KB • ${file['type']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
            onPressed: () => _removeFile(reportType, file),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedUploadCard({
    required String title,
    required List<Map<String, dynamic>> files,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upload Button with Options
            SizedBox(
              width: double.infinity,
              child: PopupMenuButton<String>(
                onSelected: (value) => _handleFileSelection(title, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'camera',
                    child: ListTile(
                      leading: Icon(Icons.camera_alt, color: AppColors.primary),
                      title: const Text('Take Photo'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'gallery',
                    child: ListTile(
                      leading:
                          Icon(Icons.photo_library, color: AppColors.primary),
                      title: const Text('Choose from Gallery'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'file',
                    child: ListTile(
                      leading: Icon(Icons.insert_drive_file,
                          color: AppColors.primary),
                      title: const Text('Select File'),
                    ),
                  ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Document',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Uploaded Files List
            if (files.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Uploaded Files:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...files.map((file) => _buildFileItem(title, file)).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildClickableStep(1, 'Personal', 0),
          _buildStepConnector(_currentStep >= 0),
          _buildClickableStep(2, 'Medical', 1),
          _buildStepConnector(_currentStep >= 1),
          _buildClickableStep(3, 'Reports', 2),
        ],
      ),
    );
  }

  Widget _buildClickableStep(int number, String label, int step) {
    return GestureDetector(
      onTap: () {
        // Validate the current form before navigating
        bool isValid = true;

        if (_currentStep == 0) {
          isValid = _personalInfoFormKey.currentState?.validate() ?? false;
        } else if (_currentStep == 1) {
          isValid = _medicalInfoFormKey.currentState?.validate() ?? false;
        }
        // No validation needed when navigating from Reports section

        if (isValid) {
          setState(() => _currentStep = step);
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: _buildStepIndicator(number, label, _currentStep >= step),
    );
  }

  Widget _buildStepIndicator(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // Personal Details Section (same structure, but uses updated UI components)
  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader('Personal Information'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildCustomInput(
                controller: _firstNameController,
                label: 'First Name',
                isRequired: true,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCustomInput(
                controller: _lastNameController,
                label: 'Last Name',
              ),
            ),
          ],
        ),
        _buildCustomInput(
          controller: _phoneController,
          label: 'Phone Number',
          isRequired: true,
          keyboardType: TextInputType.phone,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        _buildCustomInput(
          controller: _phIdController,
          label: 'PH ID',
          enabled: false,
        ),
        _buildCustomInput(
          controller: _addressController,
          label: 'Address',
          minLines: 3,
          maxLines: 5,
        ),
        Row(
          children: [
            Expanded(
              child: _buildCustomInput(
                controller: _ageController,
                label: 'Age',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCustomDropdown<String>(
                value: _gender,
                items: ['Male', 'Female', 'Others'],
                label: 'Gender',
                onChanged: (value) => setState(() => _gender = value!),
              ),
            ),
          ],
        ),
        _buildDatePickerField(),
        _buildCustomInput(
          controller: _referralController,
          label: 'Referral By',
        ),
        _buildCustomDropdown<String>(
          value: _location,
          items: _locations.map((loc) => loc['location'] as String).toList(),
          label: 'Location',
          onChanged: (value) {
            setState(() {
              _location = value!;
              // Get and store the id based on the selected location
              locationId = _locations
                  .firstWhere((loc) => loc['location'] == value)['id']
                  .toString();
              print('Selected Location ID: $locationId');
            });
          },
        ),
      ],
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Record'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepNavigation(),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                // Personal Information
                SingleChildScrollView(
                  controller: ScrollController(),
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _personalInfoFormKey,
                    child: _buildPersonalDetails(),
                  ),
                ),
                // Medical Information
                SingleChildScrollView(
                  controller: ScrollController(),
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _medicalInfoFormKey,
                    child: _buildMedicalDetails(),
                  ),
                ),
                // Reports & Documents
                SingleChildScrollView(
                  controller: ScrollController(),
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _reportsFormKey,
                    child: _buildReportsSection(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _currentStep--);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.primary),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text('BACK'),
                  )
                else
                  const SizedBox(width: 120),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      _submitForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(_currentStep == 2 ? 'SUBMIT' : 'NEXT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
