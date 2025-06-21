// ignore_for_file: sized_box_for_whitespace

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:poojaheakthcare/services/auth_service.dart';
import 'package:poojaheakthcare/widgets/AnimatedButton.dart';
import '../../constants/global_variable.dart';
import '../../screens/patient_info_screen.dart';
import '../../utils/colors.dart';
import '../../widgets/CustomCheckbox.dart';
import '../../widgets/DatePickerInput.dart';
import '../../widgets/DropdownInput.dart';
import '../../widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

import '../../widgets/showTopSnackBar.dart';
import '../../widgets/show_dialog.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  static const Map<int, String> _docTypeMapping = {
    1: 'blood_reports',
    2: 'xray_report',
    3: 'ecg_report',
    4: 'ct_scan_report',
    5: 'echocardiagram_report',
    6: 'misc_report',
    7: 'pr_image',
    8: 'pa_abdomen_image',
    9: 'pr_rectum_image',
    10: 'doctor_note_image',
  };

  int _currentStep = 0;
  bool _isLoading = false;
  final GlobalKey<FormState> _personalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _medicalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reportsFormKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool checkboxValue = false;
  String radioValue = 'option1';

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _phIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _rbsController = TextEditingController();
  final TextEditingController _ChiefComplaintsController =
      TextEditingController();
  final TextEditingController _SincewhenController = TextEditingController();
  final TextEditingController _AnyOtherIllnessController =
      TextEditingController();
  final TextEditingController _PastSurgicalHistoryController =
      TextEditingController();
  final TextEditingController _HODrugAllergyController =
      TextEditingController();
  final TextEditingController _HOPresentMedicationController =
      TextEditingController();
  final TextEditingController _complaintsController = TextEditingController();
  final TextEditingController _dmSinceController = TextEditingController();
  final TextEditingController _hypertensionSinceController =
      TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _otherIllnessController = TextEditingController();
  final TextEditingController _surgicalHistoryController =
      TextEditingController();
  final TextEditingController _drugAllergyController = TextEditingController();
  final TextEditingController _copdDescriptionController =
      TextEditingController();
  final TextEditingController _ihdDescriptionController =
      TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _bpSystolicController = TextEditingController();
  final TextEditingController _bpDiastolicController = TextEditingController();
  final TextEditingController _oedemaDetailsController =
      TextEditingController();
  final TextEditingController _lymphadenopathyDetailsController =
      TextEditingController();
  final TextEditingController _currentMedicationController =
      TextEditingController();
  final TextEditingController _rsController = TextEditingController();
  final TextEditingController _cvsController = TextEditingController();
  final TextEditingController _cnsController = TextEditingController();
  final TextEditingController _paAbdomenController = TextEditingController();
  final TextEditingController _prRectumController = TextEditingController();
  final TextEditingController _localExamController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _comorbiditiesController =
      TextEditingController();
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _adviseController = TextEditingController();
  final TextEditingController _doctorNotesController = TextEditingController();
  Map<String, dynamic>? _patientData;
  Map<String, dynamic>? _visitData;
  String _gender = 'Male';
  DateTime _selectedDate = DateTime.now();
  bool _hasDM = false;
  bool _hasHypertension = false;
  bool _hasIHD = false;
  bool _hasCOPD = false;
  bool _isFebrile = false;
  bool _hasPallor = false;
  bool _hasIcterus = false;
  bool _hasOedema = false;
  bool _hasLymphadenopathy = false;
  String? _selectedLocationId = '2';
  String _selectedLocationName = '';
  List<Map<String, dynamic>> _locations = [];
  var _documentData;
  String? locationId = '2';

  String _ensureString(String? value) => value?.trim() ?? '';
  String _ensureNumber(String? value) =>
      value?.trim().isEmpty ?? true ? '0' : value!.trim();
  String _ensureStatus(bool value) => value ? '1' : '0';
  String _ensureGender(String gender) {
    return gender == 'Male'
        ? '1'
        : gender == 'Female'
            ? '2'
            : '3';
  }

  @override
  void initState() {
    super.initState();
    _phIdController.text = 'PH-${GlobalPatientData.patientId ?? ''}';
    _firstNameController.text = GlobalPatientData.firstName ?? '';
    _lastNameController.text = GlobalPatientData.lastName ?? '';
    _phoneController.text = GlobalPatientData.phone ?? '';
    print("Global.phid");
    print(GlobalPatientData.phid);
    if (GlobalPatientData.patientExist == 2) {
      _fetchPatientData();
    }

    _fetchLocations();
  }

  void _calculateBMI() {
    if (_heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      try {
        List<String> parts = _heightController.text.split('.');
        int feet = int.parse(parts[0]);
        int inches = parts.length > 1 ? int.parse(parts[1]) : 0;

        if (inches >= 12) {
          _bmiController.text = 'Invalid inches';
          return;
        }

        double heightInMeters = ((feet * 12) + inches) * 0.0254;
        double weightKg = double.parse(_weightController.text);

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

  Future<void> _fetchLocations() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://pooja-healthcare.ortdemo.com/api/getlocation'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _locations = List<Map<String, dynamic>>.from(data['locations']);
            if (_locations.isNotEmpty) {
              _selectedLocationId ??= _locations.first['id'].toString();
              _selectedLocationName = _locations.first['location'].toString();
            }
            print("_locations");
            print(_locations);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPatientData() async {
    setState(() => _isLoading = true);
    try {
      final requestBody = {'id': Global.phid};
      final response = await http.post(
        Uri.parse('https://pooja-healthcare.ortdemo.com/api/getpatientbyid'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      log('requestBody $requestBody');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Patient data: $data');

        if (data['status'] == true && data['data'] != null) {
          final responseData =
              data['data'] is List ? data['data'][0] : data['data'];

          setState(() {
            _patientData = responseData['patient'] is List
                ? responseData['patient'][0]
                : responseData['patient'] ?? {};

            _visitData = responseData['PatientVisitInfo'] is List
                ? (responseData['PatientVisitInfo'].isNotEmpty
                    ? responseData['PatientVisitInfo'][0]
                    : {})
                : responseData['PatientVisitInfo'] ?? {};

            _documentData = responseData['PatientDocumentInfo'] ?? {};

            log('_documentData $_documentData');

            _populateFormFields();
          });
        } else {
          throw Exception('API returned false status or no data');
        }
      } else {
        throw Exception('Failed to load patient data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching patient data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading patient data: ${e.toString()}')),
      );
      _initializeWithEmptyData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeWithEmptyData() {
    setState(() {
      _patientData = {
        'phid': Global.phid,
        'first_name': GlobalPatientData.firstName,
        'last_name': GlobalPatientData.lastName,
        'mobile_no': GlobalPatientData.phone
      };
      _visitData = {};
      _documentData = {};
      _populateFormFields();
    });
  }

  void _populateFormFields() {
    try {
      // Personal Info
      _firstNameController.text = _patientData?['first_name']?.toString() ?? '';
      _lastNameController.text = _patientData?['last_name']?.toString() ?? '';
      _phoneController.text = _patientData?['mobile_no']?.toString() ?? '';
      _altPhoneController.text =
          _patientData?['alternative_no']?.toString() ?? '';
      _phIdController.text = 'PH-${_patientData?['phid']?.toString() ?? ''}';
      _addressController.text = _patientData?['address']?.toString() ?? '';
      _descriptionController.text =
          _patientData?['description']?.toString() ?? '';
      _gender = _patientData?['gender'] == 1 ? 'Male' : 'Female';

      try {
        _selectedDate = DateTime.parse(
            _patientData?['date']?.toString() ?? DateTime.now().toString());
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
      _complaintsController.text =
          _visitData?['chief_complaints']?.toString() ?? '';
      _hasDM = _visitData?['history_of_dm_status'] == 1;
      _dmSinceController.text =
          _visitData?['history_of_dm_description']?.toString() ?? '';
      _hasHypertension = _visitData?['hypertension_status'] == 1;
      _hypertensionSinceController.text =
          _visitData?['hypertension_description']?.toString() ?? '';
      _hasIHD = _visitData?['IHD_status'] == 1;
      _ihdDescriptionController.text =
          _visitData?['IHD_description']?.toString() ?? '';
      _hasCOPD = _visitData?['COPD_status'] == 1;
      _copdDescriptionController.text =
          _visitData?['COPD_description']?.toString() ?? '';
      _otherIllnessController.text =
          _visitData?['any_other_illness']?.toString() ?? '';
      _surgicalHistoryController.text =
          _visitData?['past_surgical_history']?.toString() ?? '';
      _drugAllergyController.text =
          _visitData?['drug_allergy']?.toString() ?? '';
      _tempController.text = _visitData?['temp']?.toString() ?? '';
      _pulseController.text = _visitData?['pulse']?.toString() ?? '';
      _bpSystolicController.text = _visitData?['bp_systolic']?.toString() ?? '';
      _bpDiastolicController.text =
          _visitData?['bp_diastolic']?.toString() ?? '';
      _hasPallor = _visitData?['pallor'] == 1;
      _hasIcterus = _visitData?['icterus'] == 1;
      _hasOedema = _visitData?['oedema_status'] == 1;
      _oedemaDetailsController.text =
          _visitData?['oedema_description']?.toString() ?? '';
      _hasLymphadenopathy =
          (_visitData?['lymphadenopathy']?.toString() ?? '') != '';
      _lymphadenopathyDetailsController.text =
          _visitData?['lymphadenopathy']?.toString() ?? '';
      _currentMedicationController.text =
          _visitData?['HO_present_medication']?.toString() ?? '';
      _rsController.text = _visitData?['respiratory_system']?.toString() ?? '';
      _cvsController.text =
          _visitData?['cardio_vascular_system']?.toString() ?? '';
      _cnsController.text =
          _visitData?['central_nervous_system']?.toString() ?? '';
      _paAbdomenController.text = _visitData?['pa_abdomen']?.toString() ?? '';
      _prRectumController.text = _visitData?['pr_rectum']?.toString() ?? '';
      _localExamController.text =
          _visitData?['local_examination']?.toString() ?? '';
      _diagnosisController.text =
          _visitData?['clinical_diagnosis']?.toString() ?? '';
      _comorbiditiesController.text =
          _visitData?['comorbidities']?.toString() ?? '';
      _planController.text = _visitData?['plan']?.toString() ?? '';
      _adviseController.text = _visitData?['advise']?.toString() ?? '';
      _doctorNotesController.text =
          _patientData?['doctor_note']?.toString() ?? '';

      locationId = _patientData?['location']?.toString() ?? '2';

      _selectedLocationId = _patientData?['location']?.toString() ?? '2';

      final location = _locations.firstWhere(
        (loc) => loc['id'].toString() == _selectedLocationId,
        orElse: () => {'id': '2', 'location': 'Unknown'},
      );
      _selectedLocationName = location['location'] ?? 'Unknown';

      _uploadedFiles.clear();

      if (_documentData != null && _documentData is Map) {
        _documentData.forEach((docTypeId, files) {
          try {
            final typeId = int.tryParse(docTypeId.toString());
            if (typeId == null) return;
            final docType = _docTypeMapping[typeId];
            if (docType == null || files is! List) return;

            _uploadedFiles[docType] = files.map<Map<String, dynamic>>((file) {
              return {
                'id': file['id'],
                'path': file['media_url'],
                'name':
                    path.basename(file['media_url']?.toString() ?? 'unknown'),
                'type': path
                    .extension(file['media_url']?.toString() ?? '')
                    .replaceAll('.', '')
                    .toUpperCase(),
                'size': 'N/A',
                'isExisting': true,
              };
            }).toList();
          } catch (e) {
            log('error $e');
          }
        });
      }
    } catch (e) {
      debugPrint('Error populating form fields: $e');
    }
  }

  final Map<String, List<Map<String, dynamic>>> _uploadedFiles = {
    'blood_reports': [],
    'xray_report': [],
    'ecg_report': [],
    'ct_scan_report': [],
    'echocardiagram_report': [],
    'misc_report': [],
    'pr_image': [],
    'pa_abdomen_image': [],
    'pr_rectum_image': [],
    'doctor_note_image': [],
  };

  @override
  void dispose() {
    // Dispose all controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _phIdController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _SincewhenController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _AnyOtherIllnessController.dispose();
    _PastSurgicalHistoryController.dispose();
    _HODrugAllergyController.dispose();
    _ageController.dispose();
    _referralController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _rbsController.dispose();
    _complaintsController.dispose();
    _ChiefComplaintsController.dispose();
    _HOPresentMedicationController.dispose();
    _dmSinceController.dispose();
    _hypertensionSinceController.dispose();
    _tempController.dispose();
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
    _copdDescriptionController.dispose();
    _ihdDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    bool personalValid = _personalInfoFormKey.currentState?.validate() ?? false;
    bool medicalValid = _medicalInfoFormKey.currentState?.validate() ?? false;
    bool reportsValid = _reportsFormKey.currentState?.validate() ?? false;
    // if (!_validateFiles()) {
    //   ShowDialogs.showSnackBar(
    //       context, 'Some files are invalid. Please check your uploads.');
    //   return;
    // }

    if (!personalValid || !medicalValid || !reportsValid) {
      ShowDialogs.showSnackBar(context, 'Please fill all required fields');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const Center(child: CircularProgressIndicator()),
      );

      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        ShowDialogs.showSnackBar(
            context, 'Authentication token not found. Please login again.');
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
      log('_doctorNotesController.text ${_doctorNotesController.text}');

      // ✅ Add Form Fields
      Map<String, String> fields = {
        'first_name': _ensureString(_firstNameController.text),
        'last_name': _ensureString(_lastNameController.text),
        'gender': _ensureGender(_gender),
        'mobile_no': _ensureString(_phoneController.text),
        'alternative_no': _ensureString(_altPhoneController.text),
        'address': _ensureString(_addressController.text),
        'date': _selectedDate.toIso8601String().split('T')[0],
        'referral_by': _ensureString(_referralController.text),
        'location': _selectedLocationId ?? '1',
        'age': _ensureNumber(_ageController.text),
        'height': _ensureNumber(_heightController.text),
        'weight': _ensureNumber(_weightController.text),
        'bmi': _ensureNumber(_bmiController.text),
        'rbs': _ensureNumber(_rbsController.text),
        'chief_complaints': _ensureString(_complaintsController.text),
        'history_of_dm_status': _ensureStatus(_hasDM),
        'history_of_dm_description': _ensureString(_dmSinceController.text),
        'hypertension_status': _ensureStatus(_hasHypertension),
        'hypertension_description':
            _ensureString(_hypertensionSinceController.text),
        'IHD_status': _ensureStatus(_hasIHD),
        'IHD_description': _ensureString(_ihdDescriptionController.text),
        'COPD_status': _ensureStatus(_hasCOPD),
        'COPD_description': _ensureString(_copdDescriptionController.text),
        'any_other_illness': _ensureString(_otherIllnessController.text),
        'past_surgical_history': _ensureString(_surgicalHistoryController.text),
        'drug_allergy': _ensureString(_drugAllergyController.text),
        'temp': _ensureString(_tempController.text),
        'pulse': _ensureNumber(_pulseController.text),
        'bp_systolic': _ensureNumber(_bpSystolicController.text),
        'bp_diastolic': _ensureNumber(_bpDiastolicController.text),
        'pallor': _ensureStatus(_hasPallor),
        'icterus': _ensureStatus(_hasIcterus),
        'oedema_status': _ensureStatus(_hasOedema),
        'oedema_description': _ensureString(_oedemaDetailsController.text),
        'lymphadenopathy':
            _ensureString(_lymphadenopathyDetailsController.text),
        'HO_present_medication':
            _ensureString(_currentMedicationController.text),
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
        'status': Global.status ?? GlobalPatientData.patientId.toString(),
        'doctor_note': _ensureString(_doctorNotesController.text),
        'description': _ensureString(_descriptionController.text),
      };

      if (Global.status == '2') {
        fields['patientId'] = Global.phid.toString();
      }

      request.fields.addAll(fields);
      log('Form Fields: ${jsonEncode(fields)}');
      List<String> existingFileIds = [];
      // ✅ Handle File Uploads (New + Existing)
      // ✅ Handle File Uploads (New + Existing)
      for (var entry in _uploadedFiles.entries) {
        final docType = entry.key;
        final files = entry.value;

        String? fieldName = _mapDocTypeToField(docType);
        if (fieldName == null) continue;

        for (var file in files) {
          if (file['isExisting'] == true) {
            existingFileIds.add(file['id'].toString());
          } else {
            if (kIsWeb) {
              Uint8List? fileBytes = file['bytes'];
              String? fileName = file['name'] ??
                  'file_${DateTime.now().millisecondsSinceEpoch}';

              if (fileBytes != null && fileName != null) {
                request.files.add(http.MultipartFile.fromBytes(
                  fieldName,
                  fileBytes,
                  filename: fileName,
                ));
              } else {
                log('❌ Web file data incomplete: bytes=${fileBytes != null}, name=${fileName != null}');
                continue;
              }
            } else {
              // Mobile handling
              String? filePath = file['path'];
              String? fileName = file['name'] ??
                  path.basename(filePath ?? '') ??
                  'file_${DateTime.now().millisecondsSinceEpoch}';

              if (filePath != null) {
                final fileToUpload = File(filePath);
                if (await fileToUpload.exists()) {
                  request.files.add(await http.MultipartFile.fromPath(
                    fieldName,
                    filePath,
                    filename: fileName,
                  ));
                } else {
                  log('❌ File not found: $filePath');
                }
              }
            }
          }
        }
      }

      if (existingFileIds.isNotEmpty) {
        request.fields['existing_file'] = existingFileIds.join(',');
      }
      log("existingFileIds $existingFileIds");

      log('📤 Request Fields: ${jsonEncode(request.fields)}');
      log('📂 Total Files to Upload: ${request.files.length}');

      // ✅ Send Request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      Navigator.of(context).pop();
      log('✅ Response Status: ${response.statusCode}');
      log('📜 Response Body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        showDialog(
            context: context,
            barrierDismissible: false, // Prevents closing without interaction
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: Text(responseData['message'] ??
                    'Patient record saved successfully'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PatientInfoScreen()),
                      );
                    },
                    child: const Text('view'),
                  ),
                ],
              );
            });
        // Navigator.of(context).pop();
      } else {
        ShowDialogs.showSnackBar(context,
            '❌ Failed to save patient record. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      // Navigator.of(context).pop();s
      log('🚨 Submission Error: $e');
      log('Stack Trace: $stackTrace');

      ShowDialogs.showSnackBar(context, 'Error occurred: ${e.toString()}');
    }
  }

  String? _mapDocTypeToField(String docType) {
    switch (docType) {
      case 'blood_reports':
        return 'blood_report';
      case 'xray_report':
        return 'xray_report';
      case 'ecg_report':
        return 'ecg_report';
      case 'ct_scan_report':
        return 'ct_scan_report';
      case 'echocardiagram_report':
        return 'echocardiagram_report';
      case 'misc_report':
        return 'misc_report';
      case 'doctor_note_image':
        return 'doctor_note_image';
      case 'pr_rectum_image':
        return 'pr_rectum_image';
      case 'pa_abdomen_image':
        return 'pa_abdomen_image';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Step Indicator
          _buildStepNavigation(),
          const SizedBox(height: 20),

          // Form Content
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildPersonalInfoForm(),
                _buildMedicalInfoForm(),
                _buildAdditionalInfoForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNavigation() {
    return Container(
      width: 550,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildClickableStep(1, 'Personal Information', 0),
          _buildStepConnector(_currentStep >= 0),
          _buildClickableStep(2, 'Medical Information', 1),
          _buildStepConnector(_currentStep >= 1),
          _buildClickableStep(3, 'Reports & Documents', 2),
        ],
      ),
    );
  }

  Widget _buildClickableStep(int number, String label, int step) {
    return GestureDetector(
      onTap: () {
        bool isValid = true;
        if (_currentStep == 0) {
          isValid = _personalInfoFormKey.currentState?.validate() ?? false;
        } else if (_currentStep == 1) {
          isValid = _medicalInfoFormKey.currentState?.validate() ?? false;
        }

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
            color: isActive ? AppColors.secondary : AppColors.numberbackground,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isActive ? AppColors.secondary : AppColors.numberbackground,
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

  Widget _buildPersonalInfoForm() {
    return Form(
      key: _personalInfoFormKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.Offwhitebackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.Containerbackground),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Personal Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 16,
                children: [
                  FormInput(
                    label: 'First Name',
                    hintlabel: "Enter First Name",
                    controller: _firstNameController,
                  ),
                  FormInput(
                    label: 'Last Name',
                    hintlabel: "Enter Last Name",
                    controller: _lastNameController,
                  ),
                  FormInput(
                    label: 'Phone Number',
                    hintlabel: "Enter Phone Number",
                    controller: _phoneController,
                  ),
                  FormInput(
                    label: 'PH ID',
                    hintlabel: "Enter PH ID",
                    controller: _phIdController,
                  ),
                  FormInput(
                    label: 'Address',
                    hintlabel: "Enter Address",
                    controller: _addressController,
                  ),
                  FormInput(
                    label: 'City',
                    hintlabel: "Enter City",
                    controller: _cityController,
                  ),
                  FormInput(
                    label: 'State',
                    hintlabel: "Enter State",
                    controller: _stateController,
                  ),
                  FormInput(
                    label: 'Pin Code',
                    hintlabel: "Enter Pin Code",
                    controller: _pincodeController,
                  ),
                  FormInput(
                    label: 'Country',
                    hintlabel: "Enter Country",
                    controller: _countryController,
                  ),
                  FormInput(
                    label: 'Age',
                    hintlabel: "Enter Country",
                    controller: _ageController,
                  ),
                  DropdownInput<String>(
                    label: 'Gender',
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _gender = value;
                        });
                      }
                    },
                    value: _gender,
                  ),
                  DatePickerInput(
                    label: 'Consultation Date',
                    hintlabel: 'dd-mm-yyyy',
                    onDateSelected: (date) {
                      // Handle selected date
                      print('Consultation Date: $date');
                    },
                  ),
                  FormInput(
                    label: 'Referral by',
                    hintlabel: "Enter Referral by",
                    controller: _referralController,
                  ),
                  DropdownInput<String>(
                    label: 'Clinic Location',
                    items: _locations.map((loc) {
                      return DropdownMenuItem<String>(
                        value: loc['id'].toString(),
                        child: Text(loc['location'].toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocationId = value;
                        // Find the corresponding location name
                        final selectedLoc = _locations.firstWhere(
                          (loc) => loc['id'].toString() == value,
                          orElse: () => {'id': '2', 'location': 'Unknown'},
                        );
                        _selectedLocationName =
                            selectedLoc['location'] ?? 'Unknown';
                      });
                    },
                    value: _selectedLocationId,
                  ),
                  FormInput(
                    label: 'Other  Location',
                    hintlabel: "Enter Other  Location",
                  ),
                  FormInput(
                    label: 'Height (cms)',
                    hintlabel: "Enter Height (cms)",
                    controller: _heightController,
                  ),
                  FormInput(
                    label: 'Weight (kg)',
                    hintlabel: "Enter Weight",
                    controller: _weightController,
                  ),
                  FormInput(
                    label: 'BMI (kg/m²)',
                    hintlabel: "Enter BMI",
                    controller: _bmiController,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFormNavigationButtons(isFirstStep: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalInfoForm() {
    return Form(
      key: _medicalInfoFormKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.Offwhitebackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.Containerbackground),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Chief Complaints
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("1. Chief Complaints",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                    const SizedBox(height: 8),
                    Container(
                        width: double.infinity,
                        child: FormInput(
                          label: 'Chief Complaints',
                          maxlength: 5,
                          controller: _complaintsController,
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. History
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("2. History",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomCheckbox(
                        label: 'H/O DM',
                        onChanged: (value) => setState(() => _hasDM = value),
                      ),
                      CustomCheckbox(label: 'Hypertension'),
                      CustomCheckbox(label: 'IHD'),
                      CustomCheckbox(label: 'COPD'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FormInput(
                    label: 'Since when',
                    maxlength: 1,
                    controller: _SincewhenController,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      FormInput(
                        label: 'Any Other Illness',
                        maxlength: 5,
                        controller: _otherIllnessController,
                      ),
                      FormInput(
                        label: 'Past Surgical History',
                        maxlength: 5,
                        controller: _surgicalHistoryController,
                      ),
                      FormInput(
                        label: 'H/O Drug Allergy',
                        maxlength: 5,
                        controller: _drugAllergyController,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. General Examination
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("3. General Examination",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      Container(
                        width: 275,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Temp",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                CustomRadioButton<String>(
                                  value: 'Febrile',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: 'Febrile',
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                CustomRadioButton<String>(
                                  value: 'Afebrile',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: 'Afebrile',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      FormInput(label: 'Pulse (BPM)'),
                      Container(
                        width: 308,
                        child: Row(
                          spacing: 8,
                          children: [
                            SizedBox(
                                width: 140,
                                child: FormInput(
                                  label: 'BP (mmHg)',
                                  hintlabel: 'Systolic',
                                  controller: _bpSystolicController,
                                )),
                            Text(
                              "/",
                              style: TextStyle(fontSize: 26),
                            ),
                            SizedBox(
                                width: 140,
                                child: FormInput(
                                  label: '',
                                  hintlabel: 'Diastolic',
                                  controller: _bpDiastolicController,
                                )),
                          ],
                        ),
                      ),
                      // const DropdownInput(label: 'Pallor'),
                      Container(
                        width: 275,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pallor",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                CustomRadioButton<String>(
                                  value: '',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: '',
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text("+"),
                                SizedBox(
                                  width: 4,
                                ),
                                CustomRadioButton<String>(
                                  value: 'Nil',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: 'Nil',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 275,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Icterus",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                CustomRadioButton<String>(
                                  value: ' ',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: ' ',
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text("+"),
                                SizedBox(
                                  width: 4,
                                ),
                                CustomRadioButton<String>(
                                  value: 'Nil',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: 'Nil',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 275,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Lymphadenopathy",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                CustomRadioButton<String>(
                                  value: '',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: '',
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text("+"),
                                SizedBox(
                                  width: 4,
                                ),
                                CustomRadioButton<String>(
                                  value: 'Nil',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: 'Nil',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 275,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Oedema",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                CustomRadioButton<String>(
                                  value: ' ',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: ' ',
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text("+"),
                                SizedBox(
                                  width: 4,
                                ),
                                CustomRadioButton<String>(
                                  value: 'Nil',
                                  groupValue: radioValue,
                                  onChanged: (value) {
                                    setState(() => radioValue = value!);
                                  },
                                  label: 'Nil',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          width: double.infinity,
                          child: FormInput(
                            label: 'H/O Present Medication',
                            controller: _currentMedicationController,
                          )),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Systemic Examination
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("4. Systemic Examination",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      FormInput(
                        label: 'RS (Respiratory System)',
                        controller: _rsController,
                      ),
                      FormInput(
                        label: 'CVS (Cardio Vascular System)',
                        controller: _cvsController,
                      ),
                      FormInput(
                        label: 'CNS (Central Nervous System)',
                        controller: _cnsController,
                      ),
                      FormInput(
                        label: 'P/A Per Abdomen',
                        controller: _paAbdomenController,
                      ),
                      FormInput(label: 'Upload Attachments'),
                      FormInput(
                        label: 'P/A Abdomen Notes',
                        controller: _paAbdomenController,
                      ),
                      FormInput(
                        label: 'P/R Rectum Notes',
                        controller: _prRectumController,
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: FormInput(
                            label: 'Local Examination',
                            maxlength: 2,
                            controller: _localExamController,
                          )),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 5. Diagnosis & Plan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("5. Diagnosis & Plan",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                          width: double.infinity,
                          child: FormInput(
                            label: 'Clinical Diagnosis',
                            controller: _diagnosisController,
                          )),
                      SizedBox(
                          width: double.infinity,
                          child: FormInput(
                            label: 'Comorbidities',
                            controller: _comorbiditiesController,
                          )),
                      SizedBox(
                          width: double.infinity,
                          child: FormInput(
                            label: 'Plan',
                            controller: _planController,
                          )),
                      SizedBox(
                          width: double.infinity,
                          child: FormInput(
                            label: 'Advice',
                            controller: _adviseController,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildFormNavigationButtons(),
          ],
        ),
      ),
    );
  }

// Add this new helper method
  Widget _buildFormNavigationButtons({
    bool isFirstStep = false,
    bool isLastStep = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isFirstStep)
            Animatedbutton(
              onPressed: () {
                setState(() => _currentStep--);
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              shadowColor: Colors.white,
              titlecolor: AppColors.primary,
              backgroundColor: Colors.white,
              borderColor: AppColors.secondary,
              isLoading: _isLoading,
              title: 'BACK',
            )
          else
            const SizedBox(width: 120),
          const SizedBox(width: 10),
          Animatedbutton(
            onPressed: () {
              if (!isLastStep) {
                setState(() => _currentStep++);
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _submitForm();
              }
            },
            shadowColor: Colors.white,
            backgroundColor: AppColors.secondary,
            isLoading: _isLoading,
            title: isLastStep ? 'SUBMIT' : 'NEXT',
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoForm() {
    return Form(
      key: _reportsFormKey,
      child: Column(
        spacing: 10,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.Offwhitebackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.Containerbackground),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Reports',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'Blood Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(
                              left: 8), // Add some spacing
                          color: AppColors.backgroundcolor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: const [
                      SizedBox(
                          width: double.infinity,
                          child: FormInput(label: 'Laboratory')),
                      FormInput(label: 'Hemoglobin'),
                      FormInput(label: 'Total leucocyte count'),
                      FormInput(label: 'ESR'),
                      FormInput(label: 'Platelets'),
                      FormInput(label: 'Urine Routine'),
                      FormInput(label: 'Urine Culture'),
                      FormInput(label: 'BUN'),
                      FormInput(label: 'Serum Creatinine'),
                      FormInput(label: 'Serum Electrolytes'),
                      FormInput(label: 'LFT'),
                      FormInput(label: 'Prothrombin Time / INR'),
                      FormInput(label: 'Blood Sugar Fasting'),
                      FormInput(label: 'Blood Sugar Post Prandial'),
                      FormInput(label: 'HBA1C'),
                      FormInput(label: 'HBSAG'),
                      FormInput(label: 'HIV'),
                      FormInput(label: 'HCV'),
                      FormInput(label: 'Thyroid Function Test T3 T4 TSH'),
                      FormInput(label: 'MISC'),
                      SizedBox(
                          width: double.infinity,
                          child: FormInput(label: 'Findings')),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'X-Ray Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(
                              left: 8), // Add some spacing
                          color: AppColors.backgroundcolor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings')),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'CT Scan Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(
                              left: 8), // Add some spacing
                          color: AppColors.backgroundcolor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      FormInput(
                        label: 'CT Scan',
                        hintlabel: "Upload CT Scan Reports",
                      ),
                      Expanded(child: FormInput(label: 'Media History')),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      // FormInput(label: 'Date',hintlabel: "dd-mm-yyyy",),
                      DatePickerInput(
                        label: 'Date',
                        hintlabel: 'dd-mm-yyyy',
                        onDateSelected: (date) {
                          // Handle selected date
                          print('Date Date: $date');
                        },
                      ),
                      Expanded(child: FormInput(label: 'Findings')),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'MRI Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(
                              left: 8), // Add some spacing
                          color: AppColors.backgroundcolor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings')),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'PET Scan Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(
                              left: 8), // Add some spacing
                          color: AppColors.backgroundcolor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings')),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'ECG Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(
                              left: 8), // Add some spacing
                          color: AppColors.backgroundcolor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      FormInput(
                        label: 'ECG Report',
                        hintlabel: "Upload ECG Reports",
                      ),
                      Expanded(child: FormInput(label: 'Media History')),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings')),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        '2D ECHO Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(
                              left: 8), // Add some spacing
                          color: AppColors.backgroundcolor,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings')),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'Echocardiogram Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(
                              left: 8), // Add some spacing
                          color: AppColors.backgroundcolor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings')),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'PFT Report',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(
                              left: 8), // Add some spacing
                          color: AppColors.backgroundcolor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings')),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      FormInput(
                        label: 'MISC',
                        hintlabel: "Upload MISC",
                      ),
                      Expanded(child: FormInput(label: 'Media History')),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings')),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.Offwhitebackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.Containerbackground),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '2. Doctor Notes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(
                      label: 'Diagnosis',
                      hintlabel: "Text",
                      maxlength: 5,
                    )),

                SizedBox(
                  height: 10,
                ),
                Row(
                  spacing: 10,
                  children: [
                    FormInput(
                      label: 'Media Upload',
                      hintlabel: "Upload Media",
                    ),
                    Expanded(child: FormInput(label: 'Media History')),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                DatePickerInput(
                  label: 'Follow up date',
                  hintlabel: 'dd-mm-yyyy',
                  onDateSelected: (date) {
                    // Handle selected date
                    print('Follow up date: $date');
                  },
                ),
                //  FormInput(label: 'Follow up date',hintlabel: "dd-mm-yyyy",),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.Offwhitebackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.Containerbackground),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '2. Misc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(
                      label: 'Text',
                      hintlabel: "Text",
                      maxlength: 5,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFormNavigationButtons(isLastStep: true),
        ],
      ),
    );
  }
}

class FormInput extends StatelessWidget {
  final String label;
  final String hintlabel;
  final bool isDate;
  final int maxlength;
  final TextEditingController? controller;

  const FormInput({
    super.key,
    required this.label,
    this.maxlength = 1,
    this.isDate = false,
    this.hintlabel = "",
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 275,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 4),
          CustomTextField(
            maxLines: maxlength,
            controller: controller ?? TextEditingController(),
            hintText: hintlabel,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: (value) {
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class PatientDetailsSidebar extends StatelessWidget {
  const PatientDetailsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sidebarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PH ID– 75842152',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.primary)),
              SizedBox(height: 8),
              buildInfoBlock("Patient's Name", "Balasubramaniam Tiwari - 42/M"),
              buildInfoBlock("History", "H/O DM  |  IHD  |  COPD"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoBlock("Location", "Pooja Nursing\nHome"),
                  Container(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildInfoBlock("Occupation", "Service"),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoBlock("Diagnosis", "Lorem Ipsum"),
                  Container(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildInfoBlock("Surgery Type", "No"),
                        ],
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoBlock("Chief Complaints", "Lorem Ipsum"),
                  Container(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildInfoBlock("Clinical Diagnosis", "Lorem Ipsum"),
                        ],
                      )),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                  width: double.infinity, child: FormInput(label: 'Summary')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sidebarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contact Patient",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary),
              ),
              ListTile(
                leading: Image.asset(
                  "assets/whatsapp.png",
                  height: 20,
                ),
                title: const Text('Connect on Whatsapp'),
                onTap: () {},
              ),
              ListTile(
                leading: Image.asset(
                  "assets/call.png",
                  height: 20,
                ),
                title: const Text('Connect on Call'),
                onTap: () {},
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


//ss