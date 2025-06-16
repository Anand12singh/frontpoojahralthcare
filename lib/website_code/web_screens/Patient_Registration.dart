import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
import '../../widgets/DocumentUploadWidget.dart';
import '../../widgets/DropdownInput.dart';
import '../../widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

import '../../widgets/showTopSnackBar.dart';
import '../../widgets/show_dialog.dart';
import 'Home_Screen.dart';
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
  final TextEditingController _ChiefComplaintsController = TextEditingController();
  final TextEditingController _SincewhenController = TextEditingController();
  final TextEditingController _AnyOtherIllnessController = TextEditingController();
  final TextEditingController _PastSurgicalHistoryController = TextEditingController();
  final TextEditingController _HODrugAllergyController = TextEditingController();
  final TextEditingController _HOPresentMedicationController = TextEditingController();
  final TextEditingController _complaintsController = TextEditingController();
  final TextEditingController _dmSinceController = TextEditingController();
  final TextEditingController _hypertensionSinceController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _otherIllnessController = TextEditingController();
  final TextEditingController _surgicalHistoryController = TextEditingController();
  final TextEditingController _drugAllergyController = TextEditingController();
  final TextEditingController _copdDescriptionController = TextEditingController();
  final TextEditingController _ihdDescriptionController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _bpSystolicController = TextEditingController();
  final TextEditingController _bpDiastolicController = TextEditingController();
  final TextEditingController _oedemaDetailsController = TextEditingController();
  final TextEditingController _lymphadenopathyDetailsController = TextEditingController();
  final TextEditingController _currentMedicationController = TextEditingController();
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


  //Doc &report controllers
  // Add these to your existing controllers list
  final TextEditingController _laboratoryController = TextEditingController();
  final TextEditingController _hemoglobinController = TextEditingController();
  final TextEditingController _totalLeucocyteCountController = TextEditingController();
  final TextEditingController _esrController = TextEditingController();
  final TextEditingController _plateletsController = TextEditingController();
  final TextEditingController _urineRoutineController = TextEditingController();
  final TextEditingController _urineCultureController = TextEditingController();
  final TextEditingController _bunController = TextEditingController();
  final TextEditingController _serumCreatinineController = TextEditingController();
  final TextEditingController _serumElectrolytesController = TextEditingController();
  final TextEditingController _lftController = TextEditingController();
  final TextEditingController _prothrombinTimeController = TextEditingController();
  final TextEditingController _bloodSugarFastingController = TextEditingController();
  final TextEditingController _bloodSugarPostPrandialController = TextEditingController();
  final TextEditingController _hba1cController = TextEditingController();
  final TextEditingController _hbsagController = TextEditingController();
  final TextEditingController _hivController = TextEditingController();
  final TextEditingController _hcvController = TextEditingController();
  final TextEditingController _thyroidFunctionTestController = TextEditingController();
  final TextEditingController _miscReportController = TextEditingController();
  final TextEditingController _bloodReportFindingsController = TextEditingController();
  final TextEditingController _xrayFindingsController = TextEditingController();
  final TextEditingController _ctScanFindingsController = TextEditingController();
  final TextEditingController _mriFindingsController = TextEditingController();
  final TextEditingController _petScanFindingsController = TextEditingController();
  final TextEditingController _ecgFindingsController = TextEditingController();
  final TextEditingController _echoFindingsController = TextEditingController();
  final TextEditingController _pftFindingsController = TextEditingController();
  final TextEditingController _miscFindingsController = TextEditingController();
  final TextEditingController _doctorDiagnosisController = TextEditingController();
  final TextEditingController _miscTextController = TextEditingController();


  final TextEditingController _otherLocationController =
  TextEditingController();


  final TextEditingController _prothrombinTimController =
  TextEditingController();

  final TextEditingController _hBA1CController = TextEditingController();
  final TextEditingController _hBSAGController = TextEditingController();

//Thyroid Function tes
  final TextEditingController _t3Controller = TextEditingController();
  final TextEditingController _t4Controller = TextEditingController();
  final TextEditingController _tshController = TextEditingController();
  final TextEditingController _miscController = TextEditingController();
  final TextEditingController _xRayLaboratoryController =
  TextEditingController();
  DateTime _dateofXRayController = DateTime.now();
  final TextEditingController _xRayFindingController = TextEditingController();
//ctscan
  final TextEditingController _ctscanLaboratoryController =
  TextEditingController();
  DateTime _dateofctscanController = DateTime.now();
  final TextEditingController _ctscanFindingController =
  TextEditingController();
//mri
  final TextEditingController _mriLaboratoryController =
  TextEditingController();
  DateTime _dateofmriController = DateTime.now();
  final TextEditingController _mriFindingController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
//petscan
  final TextEditingController _petscanLaboratoryController =
  TextEditingController();
  DateTime _dateofpetscanController = DateTime.now();
  final TextEditingController _petscanFindingController =
  TextEditingController();

//ecg
  final TextEditingController _ecgLaboratoryController =
  TextEditingController();
  DateTime _dateofecgController = DateTime.now();
  final TextEditingController _ecgFindingController = TextEditingController();

//2d
  final TextEditingController _a2dLaboratoryController =
  TextEditingController();
  DateTime _dateofe2dController = DateTime.now();
  final TextEditingController _a2dFindingController = TextEditingController();
//pet
  final TextEditingController _pftLaboratoryController =
  TextEditingController();
  DateTime _dateofpftController = DateTime.now();
  final TextEditingController _pftFindingController = TextEditingController();
//folow
  DateTime _followupdateFindingController = DateTime.now();
  //misc
  final TextEditingController _miscLaboratoryController =
  TextEditingController();
  DateTime _dateofmiscController = DateTime.now();
  final TextEditingController _miscFindingController = TextEditingController();

  // Medical Conditions
  bool _hasDM = false;
  bool _hasHypertension = false;
  bool _hasIHD = false;
  bool _hasCOPD = false;
  bool _isFebrile = false;
  bool _hasPallor = false;
  bool _hasIcterus = false;
  bool _hasOedema = false;
  bool _hasLymphadenopathy = false;
  DateTime _followUpDate = DateTime.now(); // Initialize with default value
  DateTime _ConsulationDate = DateTime.now(); // Initialize with default value
  DateTime _CTScanDate = DateTime.now(); // Initialize with default value


  // Other state variables
  bool _isLoadingLocations = false;

  List<Map<String, dynamic>> _locations = [];
  String? locationId = '2';
  Map<String, dynamic>? _patientData;
  Map<String, dynamic>? _visitData;
  var _documentData;

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  String _gender = 'Male';
  DateTime _selectedDate = DateTime.now();

  String? _selectedLocationId = '2';
  String _selectedLocationName = '';

// Add these to your existing state variables
  String _tempStatus = 'Afebrile'; // 'Febrile' or 'Afebrile'
  String _pallorStatus = 'Nil';    // '+' or 'Nil'
  String _icterusStatus = 'Nil';   // '+' or 'Nil'
  String _lymphadenopathyStatus = 'Nil'; // '+' or 'Nil'
  String _oedemaStatus = 'Nil';    // '+' or 'Nil'
  String _ensureString(String? value) => value?.trim() ?? '';
  String _ensureNumber(String? value) => value?.trim().isEmpty ?? true ? '0' : value!.trim();
  String _ensureStatus(bool value) => value ? '1' : '0';
  String _ensureGender(String gender) {
    return gender == 'Male' ? '1' : gender == 'Female' ? '2' : '3';
  }

  late Map<String, List<Map<String, dynamic>>> _uploadedFiles = {
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

  void initState() {
    super.initState();
    _phIdController.text = 'PH-${GlobalPatientData.patientId ?? ''}';
    _firstNameController.text = GlobalPatientData.firstName ?? '';
    _lastNameController.text = GlobalPatientData.lastName ?? '';
    _phoneController.text = GlobalPatientData.phone ?? '';
    _uploadedFiles = {
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
    _submit();


    _fetchLocations();
  }
  Future<void> _submit() async {



    try {
      final headers = {
        'Content-Type': 'application/json',
        'Cookie':
        'connect.sid=s%3AuEDYQI5oGhq5TztFK-F_ivqibtXxbspe.L65SiGdo4p4ZZY01Vnqd9tb4d64NFnzksLXndIK5zZA'
      };

      final response = await http.post(
        Uri.parse('https://pooja-healthcare.ortdemo.com/api/checkpatientinfo'),
        headers: headers,
        body: json.encode({
          "first_name": _firstNameController.text.trim(),
          "last_name": _lastNameController.text.trim(),
          "mobile_no": _phoneController.text.trim(),
        }),
      );

      log('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          final data = responseData['data'][0];
          int patientExist = data['patientExist'] ?? 0;
          print("patientExist");
          print(patientExist);



          GlobalPatientData.patientExist= patientExist;

          if (GlobalPatientData.patientExist == 2) {
            _fetchPatientData();
          }
        } else {
          showTopRightToast(context,responseData['message'] ?? 'Submission failed',backgroundColor: Colors.red);
        }
      } else {
        showTopRightToast(context,'API Error: ${response.statusCode}',backgroundColor: Colors.red);
      }
    } catch (e) {
      showTopRightToast(context,'Error: ${e.toString()}',backgroundColor: Colors.red);
    } finally {

    }
  }
  void _calculateBMI() {
    if (_heightController.text.isNotEmpty && _weightController.text.isNotEmpty) {
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
            log('_patientData $_patientData');

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
    try {  _firstNameController.text = _patientData?['first_name']?.toString() ?? '';
    _lastNameController.text = _patientData?['last_name']?.toString() ?? '';
    _phoneController.text = _patientData?['mobile_no']?.toString() ?? '';
    _altPhoneController.text =
        _patientData?['alternative_no']?.toString() ?? '';
    _occupationController.text =
        _patientData?['occupation']?.toString() ?? '';
    _phIdController.text = 'PH-${_patientData?['phid']?.toString() ?? ''}';
    _addressController.text = _patientData?['address']?.toString() ?? '';
    _descriptionController.text =
        _patientData?['description']?.toString() ?? '';
    _gender = _patientData?['gender'] == 1 ? 'Male' : 'Female';

    _selectedDate = DateTime.parse(
        _patientData?['date']?.toString() ?? DateTime.now().toString());

    _ConsulationDate = DateTime.parse(
        _patientData?['date']?.toString() ?? DateTime.now().toString());



    _referralController.text = _patientData?['referral_by']?.toString() ?? '';
    _selectedLocationId = _patientData?['location']?.toString() ?? '2';
    log('_selectedLocationId $_selectedLocationId');
    final location = _locations.firstWhere(
          (loc) => loc['id'].toString() == _selectedLocationId,
      orElse: () => {}, // return empty map if not found
    );

    log('locationlocation: $location');
    _otherLocationController.text =
        _patientData?['other_location']?.toString() ?? '';
      // Personal Info
      _tempController.text = _visitData?['temp']?.toString() ?? '';
      _ageController.text = _visitData?['age']?.toString() ?? '';
      _heightController.text = _visitData?['height']?.toString() ?? '';
      _weightController.text = _visitData?['weight']?.toString() ?? '';
      _bmiController.text = _visitData?['bmi']?.toString() ?? '';
      _rbsController.text = _visitData?['rbs']?.toString() ?? '';
      _complaintsController.text =
          _visitData?['chief_complaints']?.toString() ?? '';
    // Replace all direct boolean assignments with proper conversions
    _hasDM = (_visitData?['history_of_dm_status']?.toString() ?? "0") == "1";
    print('_hasDM: $_hasDM (raw value: ${_visitData?['history_of_dm_status']})');

    _hasHypertension = (_visitData?['hypertension_status']?.toString() ?? "0") == "1";
    print('_hasHypertension: $_hasHypertension (raw value: ${_visitData?['hypertension_status']})');

    _hasIHD = (_visitData?['IHD_status']?.toString() ?? "0") == "1";
    print('_hasIHD: $_hasIHD (raw value: ${_visitData?['IHD_status']})');

    _hasCOPD = (_visitData?['COPD_status']?.toString() ?? "0") == "1";
    print('_hasCOPD: $_hasCOPD (raw value: ${_visitData?['COPD_status']})');

    _hasPallor = (_visitData?['pallor']?.toString() ?? "0") == "1";
    print('_hasPallor: $_hasPallor (raw value: ${_visitData?['pallor']})');

    _hasIcterus = (_visitData?['icterus']?.toString() ?? "0") == "1";
    print('_hasIcterus: $_hasIcterus (raw value: ${_visitData?['icterus']})');

    _hasOedema = (_visitData?['oedema_status']?.toString() ?? "0") == "1";
    print('_hasOedema: $_hasOedema (raw value: ${_visitData?['oedema_status']})');

    _hasLymphadenopathy = (_visitData?['lymphadenopathy']?.toString() ?? "0") == "1";
    print('_hasLymphadenopathy: $_hasLymphadenopathy (raw value: ${_visitData?['lymphadenopathy']})');
      _dmSinceController.text =
          _visitData?['history_of_dm_description']?.toString() ?? '';



    _tempStatus = _visitData?['temp'] == '0' ? 'Afebrile' : 'Febrile';

    // Pallor
    _pallorStatus = (_visitData?['pallor']?.toString() ?? "0") == "1" ? '+' : 'Nil';

    // Icterus
    _icterusStatus = (_visitData?['icterus']?.toString() ?? "0") == "1" ? '+' : 'Nil';

    // Lymphadenopathy
    _lymphadenopathyStatus = (_visitData?['lymphadenopathy']?.toString() ?? "0") == "1" ? '+' : 'Nil';

    // Oedema
    _oedemaStatus = (_visitData?['oedema_status']?.toString() ?? "0") == "1" ? '+' : 'Nil';

    _hypertensionSinceController.text =
          _visitData?['hypertension_description']?.toString() ?? '';


      _ihdDescriptionController.text =
          _visitData?['IHD_description']?.toString() ?? '';


      _copdDescriptionController.text =
          _visitData?['COPD_description']?.toString() ?? '';
      _otherIllnessController.text =
          _visitData?['any_other_illness']?.toString() ?? '';
      _surgicalHistoryController.text =
          _visitData?['past_surgical_history']?.toString() ?? '';
      _drugAllergyController.text =
          _visitData?['drug_allergy']?.toString() ?? '';
      _isFebrile = (_visitData?['temp']?.toString() ?? '') == '98.6';
      _pulseController.text = _visitData?['pulse']?.toString() ?? '';
      _bpSystolicController.text = _visitData?['bp_systolic']?.toString() ?? '';
      _bpDiastolicController.text =
          _visitData?['bp_diastolic']?.toString() ?? '';

      _oedemaDetailsController.text =
          _visitData?['oedema_description']?.toString() ?? '';

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

      _hemoglobinController.text = _visitData?['heamoglobin']?.toString() ?? '';
      _totalLeucocyteCountController.text =
          _visitData?['total_leucocyte_count']?.toString() ?? '';
      _totalLeucocyteCountController.text =
          _visitData?['total_leucocyte_count']?.toString() ?? '';
      _esrController.text = _visitData?['esr']?.toString() ?? '';
      _plateletsController.text = _visitData?['platelets']?.toString() ?? '';
      _urineRoutineController.text =
          _visitData?['urine_routine']?.toString() ?? '';
      _urineCultureController.text =
          _visitData?['urine_culture']?.toString() ?? '';
      _bunController.text = _visitData?['bun']?.toString() ?? '';
      _serumCreatinineController.text =
          _visitData?['serum_creatinine']?.toString() ?? '';
      _serumElectrolytesController.text =
          _visitData?['serum_electrolytes']?.toString() ?? '';
      _lftController.text = _visitData?['lft']?.toString() ?? '';
      _prothrombinTimController.text =
          _visitData?['prothrombin_time_inr']?.toString() ?? '';
      _bloodSugarFastingController.text =
          _visitData?['blood_sugar_fasting']?.toString() ?? '';
      _bloodSugarPostPrandialController.text =
          _visitData?['blood_sugar_post_prandial']?.toString() ?? '';
      _hBA1CController.text = _visitData?['hba1c']?.toString() ?? '';
      _hBSAGController.text = _visitData?['hbsag']?.toString() ?? '';
    _followUpDate = DateTime.parse(_visitData?['follow_up_date']?.toString() ?? DateTime.now().toString());
    _CTScanDate = DateTime.parse(_visitData?['date_of_ct_scan']?.toString() ?? DateTime.now().toString());
      _hivController.text = _visitData?['hiv']?.toString() ?? '';
      _hcvController.text = _visitData?['hcv']?.toString() ?? '';
      _t3Controller.text = _visitData?['t3']?.toString() ?? '';
      _t4Controller.text = _visitData?['t4']?.toString() ?? '';
      _tshController.text = _visitData?['tsh']?.toString() ?? '';
      _miscController.text = _visitData?['misc']?.toString() ?? '';
      _xRayLaboratoryController.text =
          _visitData?['x_ray_laboratory']?.toString() ?? '';
      if (location.isNotEmpty) {
        _selectedLocationName = location['location'] ?? '';
        log('_selectedLocationName $_selectedLocationName');
      } else {
        _selectedLocationName = '';
        log('Location not found for ID $_selectedLocationId');
      }

      _dateofXRayController = DateTime.parse(
          _visitData?['date_of_x_ray']?.toString() ??
              DateTime.now().toString());

      _xRayFindingController.text =
          _visitData?['x_ray_finding']?.toString() ?? '';
      _ctscanLaboratoryController.text =
          _visitData?['ct_scan_laboratory']?.toString() ?? '';


      _ctscanFindingController.text =
          _visitData?['ct_scan_finding']?.toString() ?? '';

      _mriLaboratoryController.text =
          _visitData?['mri_laboratory']?.toString() ?? '';

      _dateofmriController = DateTime.parse(
          _visitData?['date_of_mri']?.toString() ?? DateTime.now().toString());

      _mriFindingController.text = _visitData?['mri_finding']?.toString() ?? '';
      _petscanLaboratoryController.text =
          _visitData?['pet_scan_laboratory']?.toString() ?? '';
      _dateofpetscanController = DateTime.parse(
          _visitData?['date_of_pet_scan']?.toString() ??
              DateTime.now().toString());
      _petscanFindingController.text =
          _visitData?['pet_scan_finding']?.toString() ?? '';
      _ecgLaboratoryController.text =
          _visitData?['ecg_laboratory']?.toString() ?? '';
      _dateofecgController = DateTime.parse(
          _visitData?['date_of_ecg']?.toString() ?? DateTime.now().toString());
      _ecgFindingController.text = _visitData?['ecg_finding']?.toString() ?? '';
      _a2dLaboratoryController.text =
          _visitData?['a2d_echo_laboratory']?.toString() ?? '';
      _a2dFindingController.text =
          _visitData?['a2d_echo_finding']?.toString() ?? '';
      _dateofe2dController = DateTime.parse(
          _visitData?['date_of_a2d_echo']?.toString() ??
              DateTime.now().toString());

      _pftLaboratoryController.text =
          _visitData?['pft_laboratory']?.toString() ?? '';
      _pftFindingController.text = _visitData?['pft_finding']?.toString() ?? '';
      _dateofpftController = DateTime.parse(
          _visitData?['date_of_pft']?.toString() ?? DateTime.now().toString());
      _miscLaboratoryController.text =
          _visitData?['msic_laboratory']?.toString() ?? '';
      _miscFindingController.text =
          _visitData?['msic_finding']?.toString() ?? '';
      _dateofmiscController = DateTime.parse(
          _visitData?['date_of_msic']?.toString() ?? DateTime.now().toString());
      _followupdateFindingController = DateTime.parse(
          _visitData?['follow_up_date']?.toString() ??
              DateTime.now().toString());


      print("Before populating _uploadedFiles:");
      print(_uploadedFiles);

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
                'name': path.basename(file['media_url']?.toString() ?? 'unknown'),
                'type': path.extension(file['media_url']?.toString() ?? '').replaceAll('.', '').toUpperCase(),
                'size': 'N/A',
                'isExisting': true,
              };
            }).toList();

            print("After populating ${docType}:");
            print(_uploadedFiles[docType]);
          } catch (e) {
            log('error $e');
          }
        });
      }
    } catch (e) {
      debugPrint('Error populating form fields: $e');
    }
  }


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

    _laboratoryController.dispose();
    _hemoglobinController.dispose();
    _totalLeucocyteCountController.dispose();
    _esrController.dispose();
    _plateletsController.dispose();
    _urineRoutineController.dispose();
    _urineCultureController.dispose();
    _bunController.dispose();
    _serumCreatinineController.dispose();
    _serumElectrolytesController.dispose();
    _lftController.dispose();
    _prothrombinTimeController.dispose();
    _bloodSugarFastingController.dispose();
    _bloodSugarPostPrandialController.dispose();
    _hba1cController.dispose();
    _hbsagController.dispose();
    _hivController.dispose();
    _hcvController.dispose();
    _thyroidFunctionTestController.dispose();
    _miscReportController.dispose();
    _bloodReportFindingsController.dispose();
    _xrayFindingsController.dispose();
    _ctScanFindingsController.dispose();
    _mriFindingsController.dispose();
    _petScanFindingsController.dispose();
    _ecgFindingsController.dispose();
    _echoFindingsController.dispose();
    _pftFindingsController.dispose();
    _miscFindingsController.dispose();
    _doctorDiagnosisController.dispose();
    _miscTextController.dispose();

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
        'date': _formatDate(_ConsulationDate),
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
        'temp': _tempStatus == 'Febrile' ? '1' : '0',
        'pallor': _pallorStatus == '+' ? '1' : '0',
        'icterus': _icterusStatus == '+' ? '1' : '0',
        'lymphadenopathy': _lymphadenopathyStatus == '+' ? '1' : '0',
        'oedema_status': _oedemaStatus == '+' ? '1' : '0',
        'pulse': _ensureNumber(_pulseController.text),
        'bp_systolic': _ensureNumber(_bpSystolicController.text),
        'bp_diastolic': _ensureNumber(_bpDiastolicController.text),


        'oedema_description': _ensureString(_oedemaDetailsController.text),

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
        'other_location': _ensureString(_otherLocationController.text),
        //add
        'follow_up_date': _formatDate(_followUpDate),
        'date_of_ct_scan': _formatDate(_CTScanDate),

        'heamoglobin': _ensureString(_hemoglobinController.text),
        'total_leucocyte_count':
        _ensureString(_totalLeucocyteCountController.text),
        'esr': _ensureString(_esrController.text),
        'platelets': _ensureString(_plateletsController.text),
        'urine_routine': _ensureString(_urineRoutineController.text),
        'urine_culture': _ensureString(_urineCultureController.text),
        'bun': _ensureString(_bunController.text),
        'serum_creatinine': _ensureString(_serumCreatinineController.text),
        'serum_electrolytes': _ensureString(_serumElectrolytesController.text),
        'lft': _ensureString(_lftController.text),
        'prothrombin_time_inr': _ensureString(_prothrombinTimController.text),
        'blood_sugar_fasting': _ensureString(_bloodSugarFastingController.text),
        'blood_sugar_post_prandial':
        _ensureString(_bloodSugarPostPrandialController.text),
        'hba1c': _ensureString(_hBA1CController.text),
        'hbsag': _ensureString(_hBSAGController.text),
        'hiv': _ensureString(_hivController.text),
        'hcv': _ensureString(_hcvController.text),
        't3': _ensureString(_t3Controller.text),
        't4': _ensureString(_t4Controller.text),
        'tsh': _ensureString(_tshController.text),
        'misc': _ensureString(_miscController.text),
        'x_ray_laboratory': _ensureString(_xRayLaboratoryController.text),
        'date_of_x_ray': _dateofXRayController.toIso8601String().split('T')[0],
        'x_ray_finding': _ensureString(_xRayFindingController.text),
        'ct_scan_laboratory': _ensureString(_ctscanLaboratoryController.text),
        'date_of_ct_scan':
        _dateofctscanController.toIso8601String().split('T')[0],

        'ct_scan_finding': _ensureString(_ctscanFindingController.text),

        'mri_laboratory': _ensureString(_mriLaboratoryController.text),
        'date_of_mri': _dateofmriController.toIso8601String().split('T')[0],
        'mri_finding': _ensureString(_mriFindingController.text),
        'pet_scan_laboratory': _ensureString(_petscanLaboratoryController.text),
        'date_of_pet_scan':
        _dateofpetscanController.toIso8601String().split('T')[0],
        'pet_scan_finding': _ensureString(_petscanFindingController.text),

        'ecg_laboratory': _ensureString(_ecgLaboratoryController.text),
        'date_of_ecg': _dateofecgController.toIso8601String().split('T')[0],

        'ecg_finding': _ensureString(_ecgFindingController.text),
        'a2d_echo_laboratory': _ensureString(_a2dLaboratoryController.text),
        'date_of_a2d_echo':
        _dateofe2dController.toIso8601String().split('T')[0],

        'a2d_echo_finding': _ensureString(_a2dFindingController.text),
        'pft_laboratory': _ensureString(_pftLaboratoryController.text),
        'date_of_pft': _dateofpftController.toIso8601String().split('T')[0],
        'pft_finding': _ensureString(_pftFindingController.text),
        'msic_laboratory': _ensureString(_miscLaboratoryController.text),
        'date_of_msic': _dateofmiscController.toIso8601String().split('T')[0],
        'msic_finding': _ensureString(_miscFindingController.text),
      };

      if (Global.status == '2') {
        fields['patientId'] = Global.phid.toString();
      }

      request.fields.addAll(fields);
      log('Form Fields: ${jsonEncode(fields)}');
      List<String> existingFileIds = [];
// Inside your _submitForm function
      for (var docType in _uploadedFiles.keys) {
        final fieldName = _mapDocTypeToField(docType);
        if (fieldName == null) continue;

        for (var file in _uploadedFiles[docType]!) {
          if (!file['isExisting']) { // Only upload new files
            if (kIsWeb && file['bytes'] != null) {
              request.files.add(http.MultipartFile.fromBytes(
                fieldName,
                file['bytes']!,
                filename: file['name'],
              ));
            } else if (!kIsWeb && file['path'] != null) {
              request.files.add(await http.MultipartFile.fromPath(
                fieldName,
                file['path']!,
                filename: file['name'],
              ));
            }
          } else {
            // For existing files, you might want to send their IDs
            existingFileIds.add(file['id'].toString());
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
                            builder: (context) => HomeScreen(initialPage: 1,)),
                      );
                    },
                    child: const Text('view'),
                  ),
                ],
              );
            });
        // Navigator.of(context).pop();
      } else {
        showTopRightToast(context, '❌ Failed to save patient record. Status code: ${response.statusCode}', backgroundColor: Colors.green);

      }
    } catch (e, stackTrace) {
      // Navigator.of(context).pop();s
      log('🚨 Submission Error: $e');
      log('Stack Trace: $stackTrace');
      showTopRightToast(context, 'Error occurred: ${e.toString()}', backgroundColor: Colors.green);


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
/*  Future<void> _submitForm() async {
    bool personalValid = _personalInfoFormKey.currentState?.validate() ?? false;
    bool medicalValid = _medicalInfoFormKey.currentState?.validate() ?? false;
    bool reportsValid = _reportsFormKey.currentState?.validate() ?? false;

    if (!personalValid || !medicalValid || !reportsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
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
      print("token : ${token}");

      // Add Form Fields
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
        'hypertension_description': _ensureString(_hypertensionSinceController.text),
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
        'doctor_note': _ensureString(_doctorNotesController.text),
        'description': _ensureString(_descriptionController.text),
      };

      request.fields.addAll(fields);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("responseBody");
      print(responseBody);
      print(request.fields);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        showTopRightToast(context, responseData['message'], backgroundColor: Colors.green);

        // Navigate to success screen or patient info screen
        */

  /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientInfoScreen()),
        );*//*
      } else {
        showTopRightToast(context, 'Failed to save patient record. Status code: ${response.statusCode}', backgroundColor: Colors.red);

      }
    } catch (e) {
      showTopRightToast(context, 'Error occurred: ${e.toString()}', backgroundColor: Colors.red);


    } finally {
      setState(() => _isLoading = false);
    }
  }*/

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
          IndexedStack(
            index: _currentStep,
            children: [
              _buildPersonalInfoForm(),
              _buildMedicalInfoForm(),
              _buildAdditionalInfoForm(),
            ],
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
              color: isActive ? AppColors.secondary : AppColors.numberbackground,
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
              children:  [
                FormInput(label: 'First Name',hintlabel: "Enter First Name",  controller: _firstNameController,),
                FormInput(label: 'Last Name',hintlabel: "Enter Last Name",  controller: _lastNameController,),
                FormInput(label: 'Phone Number',hintlabel: "Enter Phone Number", controller: _phoneController,),
                FormInput(label: 'PH ID',hintlabel: "Enter PH ID",controller: _phIdController,),
                FormInput(label: 'Address',hintlabel: "Enter Address",controller: _addressController,),
                FormInput(label: 'City',hintlabel: "Enter City",controller: _cityController,),
                FormInput(label: 'State',hintlabel: "Enter State",controller: _stateController,),
                FormInput(label: 'Pin Code',hintlabel: "Enter Pin Code",controller: _pincodeController,),
                FormInput(label: 'Country',hintlabel: "Enter Country",controller: _countryController,),
                FormInput(label: 'Age',hintlabel: "Enter Country",controller: _ageController,),
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
                    setState(() {
                      _ConsulationDate = date; // Update the selected date
                    });
                  },
                  initialDate: _ConsulationDate, // Pass the initial date if needed
                ),

                FormInput(label: 'Referral by',hintlabel: "Enter Referral by",controller: _referralController,),
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
                      _selectedLocationName = selectedLoc['location'] ?? 'Unknown';
                    });
                  },
                  value: _selectedLocationId,
                ),
                FormInput(label: 'Other  Location',hintlabel: "Enter Other  Location",),

                FormInput(label: 'Height (cms)',hintlabel: "Enter Height (cms)",controller: _heightController,),
                FormInput(label: 'Weight (kg)',hintlabel: "Enter Weight",controller: _weightController,),
                FormInput(label: 'BMI (kg/m²)',hintlabel: "Enter BMI",controller: _bmiController,),

              ],
            ),
            const SizedBox(height: 20),
            _buildFormNavigationButtons(isFirstStep: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoForm() {
    return Form(
      key: _medicalInfoFormKey,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("1. Chief Complaints",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),

                const SizedBox(height: 8),
                Container(

                    width: double.infinity,
                    child: FormInput(label: 'Chief Complaints',maxlength: 5,controller: _complaintsController,)),

              ],
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [

                    CustomCheckbox(
                    label: 'H/O DM',
                    initialValue: _hasDM,
                    onChanged: (value) => setState(() => _hasDM = value),
                  ),
                      CustomCheckbox(label: 'Hypertension'
                        ,initialValue: _hasHypertension
                      ,onChanged: (value) {
                        setState(() {
                          _hasHypertension=value;
                        });
                      },
                      ),
                      CustomCheckbox(label: 'IHD',initialValue: _hasIHD  ,onChanged: (value) {
                        setState(() {
                          _hasIHD=value;
                        });
                      },),
                     CustomCheckbox(label: 'COPD'  ,initialValue: _hasCOPD,onChanged: (value) {
                       setState(() {
                         print("_hasCOPD");
                         print(_hasCOPD);
                         _hasCOPD=value;
                       });
                     },),

                  ],
                ),
                const SizedBox(height: 8),
                FormInput(label: 'Since when',maxlength: 1,controller: _SincewhenController,),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children:  [
                    FormInput(label: 'Any Other Illness',maxlength: 5,controller: _otherIllnessController,),
                    FormInput(label: 'Past Surgical History',maxlength: 5,controller: _surgicalHistoryController,),
                    FormInput(label: 'H/O Drug Allergy',maxlength: 5,controller: _drugAllergyController,),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),
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
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: 'Febrile',
                                groupValue: _tempStatus,
                                onChanged: (value) {
                                  setState(() => _tempStatus = value!);
                                },
                                label: 'Febrile',
                              ),
                              SizedBox(width: 8),
                              CustomRadioButton<String>(
                                value: 'Afebrile',
                                groupValue: _tempStatus,
                                onChanged: (value) {
                                  setState(() => _tempStatus = value!);
                                },
                                label: 'Afebrile',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),


                     FormInput(label: 'Pulse (BPM)',controller: _pulseController,),
                     Container(
                       width: 308,
                       child: Row(
                         spacing: 8,
                         children: [
                           SizedBox(
                               width: 140,
                               child: FormInput(label: 'BP (mmHg)',hintlabel: 'Systolic',controller: _bpSystolicController,)),
                           Text("/",style: TextStyle(fontSize: 26),),
                           SizedBox(
                               width: 140,
                               child: FormInput(label: '',hintlabel: 'Diastolic',controller: _bpDiastolicController,)),
                         ],
                       ),
                     ),
                   // const DropdownInput(label: 'Pallor'),
                    // Pallor
                    Container(
                      width: 275,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pallor",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: '+',
                                groupValue: _pallorStatus,
                                onChanged: (value) {
                                  setState(() => _pallorStatus = value!);
                                },
                                label: '+',
                              ),
                              SizedBox(width: 4),
                              SizedBox(width: 4),
                              CustomRadioButton<String>(
                                value: 'Nil',
                                groupValue: _pallorStatus,
                                onChanged: (value) {
                                  setState(() => _pallorStatus = value!);
                                },
                                label: 'Nil',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

// Icterus
                    Container(
                      width: 275,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Icterus",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: '+',
                                groupValue: _icterusStatus,
                                onChanged: (value) {
                                  setState(() => _icterusStatus = value!);
                                },
                                label: '+',
                              ),
                              SizedBox(width: 4),
                              SizedBox(width: 4),
                              CustomRadioButton<String>(
                                value: 'Nil',
                                groupValue: _icterusStatus,
                                onChanged: (value) {
                                  setState(() => _icterusStatus = value!);
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
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),

                          SizedBox(height: 8,),

                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: '+',
                                groupValue: _lymphadenopathyStatus,
                                onChanged: (value) {
                                  setState(() => _lymphadenopathyStatus = value!);
                                },
                                label: '+',
                              ),
                              SizedBox(width: 4,),

                              SizedBox(width: 4,),
                              CustomRadioButton<String>(
                                value: 'Nil',
                                groupValue: _lymphadenopathyStatus,
                                onChanged: (value) {
                                  setState(() => _lymphadenopathyStatus = value!);
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
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),

                          SizedBox(height: 8,),

                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: '+',
                                groupValue: _oedemaStatus,
                                onChanged: (value) {
                                  setState(() => _oedemaStatus = value!);
                                },
                                label: '+',
                              ),
                              SizedBox(width: 4,),

                              SizedBox(width: 4,),
                              CustomRadioButton<String>(
                                value: 'Nil',
                                groupValue: _oedemaStatus,
                                onChanged: (value) {
                                  setState(() => _oedemaStatus = value!);
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
                        child:  FormInput(label: 'H/O Present Medication',controller: _currentMedicationController,)),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children:  [
                    FormInput(label: 'RS (Respiratory System)',controller: _rsController,),
                    FormInput(label: 'CVS (Cardio Vascular System)',controller: _cvsController,),
                    FormInput(label: 'CNS (Central Nervous System)',controller: _cnsController,),
                    FormInput(label: 'P/A Per Abdomen',controller: _paAbdomenController,),

                    FormInput(label: 'Upload Attachments'),
                    FormInput(label: 'P/A Abdomen Notes',controller: _paAbdomenController,),
                    FormInput(label: 'P/R Rectum Notes',controller: _prRectumController,),
                    SizedBox(
                        width: double.infinity,
                        child:  FormInput(label: 'Local Examination',maxlength: 2,controller: _localExamController,)),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children:  [
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Clinical Diagnosis',controller: _diagnosisController,)),
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Comorbidities',controller: _comorbiditiesController,)),
                    SizedBox(

                        width: double.infinity,
                        child: FormInput(label: 'Plan',controller: _planController,)),
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Advice',controller: _adviseController,)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFormNavigationButtons(),
        ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 20,),
                Row(children: [
                  Text(
                    'Blood Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children:  [
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Laboratory',controller: _laboratoryController,)),
                    FormInput(label: 'Hemoglobin',controller: _hemoglobinController,),
                    FormInput(label: 'Total leucocyte count',controller: _totalLeucocyteCountController,),
                    FormInput(label: 'ESR',controller: _esrController,),
                    FormInput(label: 'Platelets',controller: _plateletsController,),
                    FormInput(label: 'Urine Routine',controller:_urineRoutineController),
                    FormInput(label: 'Urine Culture',controller:_urineCultureController),
                    FormInput(label: 'BUN',controller:_bunController),
                    FormInput(label: 'Serum Creatinine',controller:_serumCreatinineController),
                    FormInput(label: 'Serum Electrolytes',controller:_serumElectrolytesController),
                    FormInput(label: 'LFT',controller:_lftController),
                    FormInput(label: 'Prothrombin Time / INR',controller:_prothrombinTimController),
                    FormInput(label: 'Blood Sugar Fasting',controller:_bloodSugarFastingController),
                    FormInput(label: 'Blood Sugar Post Prandial',controller:_bloodSugarPostPrandialController),
                    FormInput(label: 'HBA1C',controller:_hBA1CController),
                    FormInput(label: 'HBSAG',controller:_hBSAGController),
                    FormInput(label: 'HIV',controller:_hivController),
                    FormInput(label: 'HCV',controller:_hcvController),
                    FormInput(label: 'Thyroid Function Test T3 T4 TSH',controller:_thyroidFunctionTestController),
                    FormInput(label: 'MISC',controller:_miscController),
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Findings',controller: _miscFindingsController,)),

                  ],
                ),
                SizedBox(height: 20,),
                Row(children: [
                  Text(
                    'X-Ray Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings',controller:_xRayFindingController)),
                SizedBox(height: 10,),
                Row(

                  children: [
                  Text(
                    'CT Scan Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                SizedBox(height: 10,),

                DocumentUploadWidget(
                  docType: 'ct_scan_report', // This should match one of your map keys
                  label: "CT Scan Report",
                  onFilesSelected: (files) {
                    setState(() {
                      _uploadedFiles['ct_scan_report'] = files;
                    });
                  },
                  initialFiles: _uploadedFiles['ct_scan_report'],
                ),
             /*   Row(
                  spacing: 10,
                  children: [

                    FormInput(label: 'CT Scan',hintlabel: "Upload CT Scan Reports",controller:_ctScanFindingsController),

                    Expanded(

                        child: FormInput(label: 'Media History',)),
                  ],
                ),*/
                SizedBox(height: 10,),
                Row(
                  spacing: 10,
                  children: [
                   // FormInput(label: 'Date',hintlabel: "dd-mm-yyyy",),
                    DatePickerInput(
                      label: 'Date',
                      hintlabel: 'dd-mm-yyyy',
                      onDateSelected: (date) {
                        setState(() {
                          _CTScanDate = date; // Update the selected date
                        });
                      },
                      initialDate: _CTScanDate, // Pass the initial date if needed
                    ),
                    Expanded(

                        child: FormInput(label: 'Findings',controller: _ctscanFindingController,)),
                  ],
                ),     SizedBox(height: 10,),

                Row(children: [
                  Text(
                    'MRI Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings',controller: _mriFindingController,)),
                SizedBox(height: 10,),
                Row(children: [
                  Text(
                    'PET Scan Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                SizedBox(height: 10,),

                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings',controller: _petscanFindingController,)),
                SizedBox(height: 10,),
                Row(

                  children: [
                    Text(
                      'ECG Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 8), // Add some spacing
                        color: AppColors.backgroundcolor,
                      ),
                    ),
                  ],),
                SizedBox(height: 10,),
                DocumentUploadWidget(
                  docType: 'ecg_report', // This should match one of your map keys
                  label: "Upload ECG Reports",
                  onFilesSelected: (files) {
                    setState(() {
                      _uploadedFiles['ecg_report'] = files;
                    });
                  },
                  initialFiles: _uploadedFiles['ecg_report'],
                ),

                SizedBox(height: 10,),
                SizedBox(
          width: double.infinity,
                    child: FormInput(label: 'Findings',controller: _ecgFindingController,)),
                SizedBox(height: 10,),

                Row(

                  children: [
                    Text(
                      '2D ECHO Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 8), // Add some spacing
                        color: AppColors.backgroundcolor,
                      ),)
                  ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings',controller:_echoFindingsController)),
                SizedBox(height: 10,),
                Row(

                  children: [
                    Text(
                      'Echocardiogram Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 8), // Add some spacing
                        color: AppColors.backgroundcolor,
                      ),
                    ),
                  ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings',controller: _echoFindingsController,)),
                SizedBox(height: 10,),
                Row(

                  children: [
                    Text(
                      'PFT Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 8), // Add some spacing
                        color: AppColors.backgroundcolor,
                      ),
                    ),
                  ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings',controller: _pftFindingController,)),
                SizedBox(height: 10),

                DocumentUploadWidget(
                  docType: 'misc_report', // This should match one of your map keys
                  label: "Upload MISC",
                  onFilesSelected: (files) {
                    setState(() {
                      _uploadedFiles['misc_report'] = files;
                    });
                  },
                  initialFiles: _uploadedFiles['misc_report'],
                ),

                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings',controller: _miscFindingController,)),
                SizedBox(height: 10,),

              ],
            ),
          ),
          Container( width: double.infinity,
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
            SizedBox(height: 20,),
            SizedBox(
                width: double.infinity,
                child: FormInput(label: 'Diagnosis',hintlabel: "Text",maxlength: 5,)),

              SizedBox(height: 10,),
              Row(
                spacing: 10,
                children: [
                  FormInput(label: 'Media Upload',hintlabel: "Upload Media",),


                  Expanded(

                      child: FormInput(label: 'Media History',)),
                ],
              ),
              SizedBox(height: 10,),
              DatePickerInput(
                label: 'Flollow up date',
                hintlabel: 'dd-mm-yyyy',
                onDateSelected: (date) {
                  setState(() {
                    _followUpDate = date; // Update the selected date
                  });
                },
                initialDate: _followUpDate, // Pass the initial date if needed
              ),
            //  FormInput(label: 'Follow up date',hintlabel: "dd-mm-yyyy",),
          ],),
          ),
          Container( width: double.infinity,
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
            SizedBox(height: 20,),
            SizedBox(
                width: double.infinity,
                child: FormInput(label: 'Text',hintlabel: "Text",maxlength: 5,controller: _miscTextController,)),


          ],),
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
    this.maxlength=1,
    this.isDate = false,
    this.hintlabel="",
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
            children:  [
              Text('PH ID– 75842152', style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20,color: AppColors.primary)),
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
                  Container(  width: 150,
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
                  Container(width: 150,
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
