import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:poojaheakthcare/services/auth_service.dart';
import 'package:poojaheakthcare/widgets/AnimatedButton.dart';
import 'package:provider/provider.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../constants/base_url.dart';
import '../../constants/global_variable.dart';
import '../../provider/PermissionService.dart';
import '../../screens/patient_info_screen.dart';
import '../../services/api_services.dart';
import '../../utils/colors.dart';
import '../../widgets/CustomCheckbox.dart';
import '../../widgets/DatePickerInput.dart';
import '../../widgets/DocumentUploadWidget.dart';
import '../../widgets/DropdownInput.dart';
import '../../widgets/HistoryYesNoField.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

import '../../widgets/showTopSnackBar.dart';
import '../../widgets/show_dialog.dart';
import 'Home_Screen.dart';
import 'PatientDetailsSidebar.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  static const Map<int, String> _docTypeMapping = {
    1: 'miscellaneous_report',
    2: 'xray_report',
    3: 'ecg_report',
    4: 'ct_scan_report',
    5: 'echocardiagram_report',
    6: 'misc_report',
    7: 'pr_image',
    8: 'pa_abdomen_image',
    9: 'pr_rectum_image',
    10: 'doctor_note_image',
    15: 'patient_treatment',
  };
  bool _isInitialized = false; // Add this flag

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
  final TextEditingController _OccupationController = TextEditingController();
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
  final TextEditingController _RBSController = TextEditingController();
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

  //Doc &report controllers
  // Add these to your existing controllers list
  final TextEditingController _laboratoryController = TextEditingController();
  final TextEditingController _hemoglobinController = TextEditingController();
  final TextEditingController _totalLeucocyteCountController =
      TextEditingController();
  final TextEditingController _esrController = TextEditingController();
  final TextEditingController _plateletsController = TextEditingController();
  final TextEditingController _urineRoutineController = TextEditingController();
  final TextEditingController _urineCultureController = TextEditingController();
  final TextEditingController _bunController = TextEditingController();
  final TextEditingController _serumCreatinineController =
      TextEditingController();
  final TextEditingController _serumElectrolytesController =
      TextEditingController();
  final TextEditingController _lftController = TextEditingController();
  final TextEditingController _prothrombinTimeController =
      TextEditingController();
  final TextEditingController _bloodSugarFastingController =
      TextEditingController();
  final TextEditingController _bloodSugarPostPrandialController =
      TextEditingController();
  final TextEditingController _hba1cController = TextEditingController();
  final TextEditingController _hbsagController = TextEditingController();
  final TextEditingController _hivController = TextEditingController();
  final TextEditingController _hcvController = TextEditingController();
  final TextEditingController _thyroidFunctionT3TestController =
      TextEditingController();
  final TextEditingController _thyroidFunctionT4TestController =
      TextEditingController();
  final TextEditingController _thyroidFunctionTSHTestController =
      TextEditingController();
  final TextEditingController _miscReportController = TextEditingController();
  final TextEditingController _bloodReportFindingsController =
      TextEditingController();
  final TextEditingController _xrayFindingsController = TextEditingController();
  final TextEditingController _ctScanFindingsController =
      TextEditingController();
  final TextEditingController _mriFindingsController = TextEditingController();
  final TextEditingController _petScanFindingsController =
      TextEditingController();
  final TextEditingController _ecgFindingsController = TextEditingController();
  final TextEditingController _echoFindingsController = TextEditingController();
  final TextEditingController _pftFindingsController = TextEditingController();
  final TextEditingController _miscFindingsController = TextEditingController();
  final TextEditingController _doctorDiagnosisController =
      TextEditingController();
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
  DateTime? _followUpDate = DateTime.now(); // Initialize with default value
  DateTime _ConsulationDate = DateTime.now(); // Initialize with default value
  DateTime? _CTScanDate = DateTime.now(); // Initialize with default value

  Map<String, List<String>> miscReportTagging = {};
  final TextEditingController _docQualificationController =
      TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
// Add these with your other controllers
  final List<TextEditingController> _medNameControllers = [];
  final List<TextEditingController> _medDosageControllers = [];
  final List<TextEditingController> _medFrequencyControllers = [];
  final List<TextEditingController> _medDurationControllers = [];
  List<dynamic> _medicationIds = []; // can hold int or ""

  // Other state variables
  bool _isLoadingLocations = false;

  List<Map<String, dynamic>> _locations = [];
  String? locationId = '2';
  Map<String, dynamic>? _patientData;
  Map<String, dynamic>? _visitData;
  var _documentData;

  String _formatDate(DateTime? date) {
    if (date == null)
      return ''; // or return null if your API accepts empty values
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String? _gender; // Make it nullable
  String _basePhId = '';
  String _phIdYear = '';
  String _fullPhId = ''; // This will be PHID/YEAR

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _deletedMedications = [];
  String? _selectedLocationId = '2';
  String _selectedLocationName = '';

  bool _isFetchingLocation = false;
// Add these to your existing state variables
  String _tempStatus = 'Afebrile'; // 'Febrile' or 'Afebrile'
  String _pallorStatus = 'Nil'; // '+' or 'Nil'
  String _icterusStatus = 'Nil'; // '+' or 'Nil'
  String _lymphadenopathyStatus = 'Nil'; // '+' or 'Nil'
  String _oedemaStatus = 'Nil'; // '+' or 'Nil'
  String _ensureString(String? value) => value?.trim() ?? '';
  String _ensureNumber(String? value) =>
      value?.trim().isEmpty ?? true ? '0' : value!.trim();
  String _ensureStatus(bool value) => value ? '1' : '0';
  String _ensureGender(String? gender) {
    if (gender == 'Male') return '1';
    if (gender == 'Female') return '2';
    return ''; // or some default value if required
  }

  late Map<String, List<Map<String, dynamic>>> _uploadedFiles = {
    'miscellaneous_report': [],
    'xray_report': [],
    'ecg_report': [],
    'ct_scan_report': [],
    'echocardiagram_report': [],
    'misc_report': [],
    'pr_image': [],
    'pa_abdomen_image': [],
    'pr_rectum_image': [],
    'doctor_note_image': [],
    'patient_treatment': [],
  };
  List<Map<String, dynamic>> medications = [];
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();

    _addMedicationRow(count: 2);
    _initializePhId();
    _phIdController.text =
        '${GlobalPatientData.patientId == "NA" ? GlobalPatientData.phid : GlobalPatientData.patientId}';
    _firstNameController.text = GlobalPatientData.firstName ?? '';
    _lastNameController.text = GlobalPatientData.lastName ?? '';
    _phoneController.text = GlobalPatientData.phone ?? '';
    _uploadedFiles = {
      'miscellaneous_report': [],
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

    _docQualificationController.text = ''; // Set initial value if available
    _registrationNumberController.text = '';
    _fetchLocations();
    _isInitialized = true;
  }

  void _initializePhId() {
    // Get base PH ID
    _basePhId =
        '${GlobalPatientData.patientId == "NA" ? GlobalPatientData.phid : GlobalPatientData.patientId}';

    // Default to current year initially
    _phIdYear = DateTime.now().year.toString();

    // Create full PH ID
    _fullPhId = '$_basePhId/$_phIdYear';

    // Set controller text
    _phIdController.text = _fullPhId;
  }

  void _initializeData() {
    // Don't call initState() here!
    // Instead, reset/reinitialize only what you need
    _uploadedFiles = {
      'miscellaneous_report': [],
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

    // Clear form data if needed
    _firstNameController.text = GlobalPatientData.firstName ?? '';
    _lastNameController.text = GlobalPatientData.lastName ?? '';
    _phoneController.text = GlobalPatientData.phone ?? '';

    // Re-fetch patient data
    _fetchPatientData();

    // Reset other state as needed

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only respond to refresh after initial initialization
    if (!_isInitialized) return;

    final patientProvider = Provider.of<PatientProvider>(context, listen: true);

    if (patientProvider.needsRefresh) {
      patientProvider.clearRefresh();
      _initializeData(); // This now only resets data, not initState
    }
  }

  Future<void> _submit() async {
    final params = {
      "first_name": _firstNameController.text.trim(),
      "last_name": _lastNameController.text.trim(),
      "mobile_no": _phoneController.text.trim(),
    };

    await APIManager().apiRequest(
      context,
      API.checkpatientinfo,
      params: params,
      onSuccess: (responseBody) {
        final responseData = json.decode(responseBody);

        if (responseData['status'] == true) {
          final data = responseData['data'][0];
          int patientExist = data['patientExist'] ?? 0;
          debugPrint("patientExist: $patientExist");

          GlobalPatientData.patientExist = patientExist;

          if (GlobalPatientData.patientExist == 2) {
            // Patient exists — fetch patient data
            _fetchPatientData();
          }
        } else {
          showTopRightToast(
            context,
            responseData['message'] ?? 'Submission failed',
            backgroundColor: Colors.red,
          );
        }
      },
      onFailure: (error) {
        showTopRightToast(
          context,
          'Error: $error',
          backgroundColor: Colors.red,
        );
      },
    );
  }

  void _calculateBMI() {
    if (_heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      try {
        double heightCm = double.parse(_heightController.text);
        double heightM = heightCm / 100; // Convert cm to meters
        double weightKg = double.parse(_weightController.text);

        if (heightM > 0 && weightKg > 0) {
          double bmi = weightKg / (heightM * heightM);
          _bmiController.text = bmi.toStringAsFixed(1);
        } else {
          _bmiController.text = '';
        }
      } catch (e) {
        _bmiController.text = 'Invalid number';
      }
    } else {
      _bmiController.text = '';
    }
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoading = true);

    await APIManager().apiRequest(
      context,
      API.getlocation,
      params: {}, // No parameters for GET
      onSuccess: (responseBody) {
        final data = json.decode(responseBody);

        if (data['success'] == true) {
          setState(() {
            _locations = List<Map<String, dynamic>>.from(data['locations']);
            if (_locations.isNotEmpty) {
              _selectedLocationId ??= _locations.first['id'].toString();
              _selectedLocationName = _locations.first['location'].toString();
            }
            debugPrint("_locations: $_locations");
          });
        } else {
          showTopRightToast(
            context,
            data['message'] ?? "Failed to fetch locations.",
            backgroundColor: Colors.red,
          );
        }
      },
      onFailure: (error) {
        showTopRightToast(
          context,
          "Error fetching locations: $error",
          backgroundColor: Colors.red,
        );
      },
    );

    setState(() => _isLoading = false);
  }

  Future<void> _fetchPatientData() async {
    setState(() => _isLoading = true);

    try {
      final requestBody = {'id': GlobalPatientData.phid};

      await APIManager().apiRequest(
        context,
        API.getPatientById,
        params: requestBody,
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          log('Patient data: $data');

          if (data['status'] == true && data['data'] != null) {
            final responseData =
                data['data'] is List ? data['data'][0] : data['data'];

            setState(() {
              _patientData = responseData['patient'] is List
                  ? (responseData['patient'].isNotEmpty
                      ? responseData['patient'][0]
                      : {})
                  : responseData['patient'] ?? {};

              _visitData = responseData['PatientVisitInfo'] is List
                  ? (responseData['PatientVisitInfo'].isNotEmpty
                      ? responseData['PatientVisitInfo'][0]
                      : {})
                  : responseData['PatientVisitInfo'] ?? {};

              _documentData = responseData['PatientDocumentInfo'] ?? [];

              // Safely map DoctorNotesInfo
              final doctorNotesInfo =
                  responseData['DoctorNotesInfo'] as List<dynamic>? ?? [];
              _mapDoctorNotes(doctorNotesInfo);

              log('_documentData $_documentData');
              log('_patientData $_patientData');

              _populateFormFields();
            });
          } else {
            throw Exception('API returned false status or no data');
          }
        },
        onFailure: (error) {
          debugPrint('Error fetching patient data: $error');
          showTopRightToast(
            context,
            'Error loading patient data: $error',
            backgroundColor: Colors.red,
          );
          _initializeWithEmptyData();
        },
      );
    } catch (e) {
      debugPrint('Unexpected error: $e');
      showTopRightToast(
        context,
        'Unexpected error loading patient data: ${e.toString()}',
        backgroundColor: Colors.red,
      );
      _initializeWithEmptyData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mapDoctorNotes(List<dynamic> doctorNotesInfo) {
    _medNameControllers.clear();
    _medDosageControllers.clear();
    _medFrequencyControllers.clear();
    _medDurationControllers.clear();
    _medicationIds.clear();

    for (var note in doctorNotesInfo) {
      _medNameControllers
          .add(TextEditingController(text: note['name_of_medication'] ?? ''));
      _medDosageControllers
          .add(TextEditingController(text: note['dosage'] ?? ''));
      _medFrequencyControllers
          .add(TextEditingController(text: note['frequency'] ?? ''));
      _medDurationControllers
          .add(TextEditingController(text: note['duration'] ?? ''));

      _medicationIds.add(note['id'] ?? ""); // if missing, fallback to empty
    }

    setState(() {});
  }

/*  Future<void> _fetchPatientData() async {
    setState(() => _isLoading = true);
    try {
      final requestBody = {'id': Global.phid};
      final response = await http.post(
        Uri.parse('$localurl/getpatientbyid'),
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

      showTopRightToast(context,'Error loading patient data: ${e.toString()}',backgroundColor: Colors.red);

      _initializeWithEmptyData();
    } finally {
      setState(() => _isLoading = false);
    }
  }*/

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

  void _updatePhIdFromPatientData() {
    // Update base PH ID
    _basePhId = _patientData?['phid']?.toString() ?? _basePhId;

    // Extract year from created_at field
    final createdAt = _patientData?['created_at']?.toString();
    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        _phIdYear = date.year.toString();
      } catch (e) {
        _phIdYear = DateTime.now().year.toString();
      }
    }

    // Update full PH ID
    _fullPhId = '$_basePhId/$_phIdYear';

    // Update controller
    _phIdController.text = _fullPhId;
  }

  void _populateFormFields() {
    try {
      _firstNameController.text = _patientData?['first_name']?.toString() ?? '';
      _lastNameController.text = _patientData?['last_name']?.toString() ?? '';
      _phoneController.text = _patientData?['mobile_no']?.toString() ?? '';
      _altPhoneController.text =
          _patientData?['alternative_no']?.toString() ?? '';
      _occupationController.text =
          _patientData?['occupation']?.toString() ?? '';
      _phIdController.text = '${_patientData?['phid']?.toString() ?? ''}';

      _addressController.text = _patientData?['address']?.toString() ?? '';
      _OccupationController.text =
          _patientData?['occupation']?.toString() ?? '';
      _cityController.text = _patientData?['city']?.toString() ?? '';
      _stateController.text = _patientData?['state']?.toString() ?? '';
// Initialize pincode controller with proper null/zero handling
      _pincodeController.text =
          ((_patientData?['pincode'] == null || _patientData?['pincode'] == 0)
              ? ''
              : _patientData?['pincode'].toString())!;
      _countryController.text = _patientData?['country']?.toString() ?? '';

      _descriptionController.text =
          _patientData?['description']?.toString() ?? '';

      final genderValue = _patientData?['gender'];
      _gender = genderValue == 1
          ? 'Male'
          : genderValue == 2
              ? 'Female'
              : null;

      _updatePhIdFromPatientData();
      _selectedDate = DateTime.tryParse(
              _patientData?['registration_date']?.toString() ?? '') ??
          DateTime.now();

      _ConsulationDate = DateTime.tryParse(
              _patientData?['consultation_date']?.toString() ?? '') ??
          DateTime.now();

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
      _laboratoryController.text =
          _visitData?['blood_laboratory']?.toString() ?? '';
      _bloodReportFindingsController.text =
          _visitData?['blood_finding']?.toString() ?? '';
      _rbsController.text = _visitData?['rbs']?.toString() ?? '';
      _complaintsController.text =
          _visitData?['chief_complaints']?.toString() ?? '';
      // Replace all direct boolean assignments with proper conversions
      _hasDM = (_visitData?['history_of_dm_status']?.toString() ?? "0") == "1";
      print(
          '_hasDM: $_hasDM (raw value: ${_visitData?['history_of_dm_status']})');

      _hasHypertension =
          (_visitData?['hypertension_status']?.toString() ?? "0") == "1";
      print(
          '_hasHypertension: $_hasHypertension (raw value: ${_visitData?['hypertension_status']})');

      _hasIHD = (_visitData?['IHD_status']?.toString() ?? "0") == "1";
      print('_hasIHD: $_hasIHD (raw value: ${_visitData?['IHD_status']})');

      _hasCOPD = (_visitData?['COPD_status']?.toString() ?? "0") == "1";
      print('_hasCOPD: $_hasCOPD (raw value: ${_visitData?['COPD_status']})');

      _hasPallor = (_visitData?['pallor']?.toString() ?? "0") == "1";
      print('_hasPallor: $_hasPallor (raw value: ${_visitData?['pallor']})');

      _hasIcterus = (_visitData?['icterus']?.toString() ?? "0") == "1";
      print('_hasIcterus: $_hasIcterus (raw value: ${_visitData?['icterus']})');

      _hasOedema = (_visitData?['oedema_status']?.toString() ?? "0") == "1";
      print(
          '_hasOedema: $_hasOedema (raw value: ${_visitData?['oedema_status']})');

      _hasLymphadenopathy =
          (_visitData?['lymphadenopathy']?.toString() ?? "0") == "1";
      print(
          '_hasLymphadenopathy: $_hasLymphadenopathy (raw value: ${_visitData?['lymphadenopathy']})');
      _SincewhenController.text =
          _visitData?['history_of_dm_description']?.toString() ?? '';

      _tempStatus = (_visitData?['temp'] == null || _visitData?['temp'] == "0")
          ? 'Afebrile'
          : 'Febrile';

      // Pallor
      _pallorStatus =
          (_visitData?['pallor']?.toString() ?? "0") == "1" ? '+' : 'Nil';

      // Icterus
      _icterusStatus =
          (_visitData?['icterus']?.toString() ?? "0") == "1" ? '+' : 'Nil';

      // Lymphadenopathy
      _lymphadenopathyStatus =
          (_visitData?['lymphadenopathy']?.toString() ?? "0") == "1"
              ? '+'
              : 'Nil';

      // Oedema
      _oedemaStatus = (_visitData?['oedema_status']?.toString() ?? "0") == "1"
          ? '+'
          : 'Nil';

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
      _RBSController.text = _visitData?['rbs_text']?.toString() ?? '';
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
      _registrationNumberController.text =
          _visitData?['registration_number']?.toString() ?? '';
      _docQualificationController.text =
          _visitData?['doc_qualification']?.toString() ?? '';
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
      _followUpDate =
          DateTime.parse(_visitData?['follow_up_date']?.toString() ?? '');
      _CTScanDate =
          DateTime.parse(_visitData?['date_of_ct_scan']?.toString() ?? '');
      _hivController.text = _visitData?['hiv']?.toString() ?? '';
      _hcvController.text = _visitData?['hcv']?.toString() ?? '';
      _thyroidFunctionT3TestController.text =
          _visitData?['t3']?.toString() ?? '';
      _thyroidFunctionT4TestController.text =
          _visitData?['t4']?.toString() ?? '';
      _thyroidFunctionTSHTestController.text =
          _visitData?['tsh']?.toString() ?? '';
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

      // In _populateFormFields method, update the file mapping section:
      // In _populateFormFields method, update the file mapping section:
      if (_documentData != null && _documentData is Map) {
        _documentData.forEach((docTypeId, files) {
          try {
            final typeId = int.tryParse(docTypeId.toString());
            if (typeId == null) return;
            final docType = _docTypeMapping[typeId];
            if (docType == null || files is! List) return;

            _uploadedFiles[docType] = files.map<Map<String, dynamic>>((file) {
              // Parse tagging information
              List<String> tags = [];
              try {
                if (file['tagging'] != null && file['tagging'].isNotEmpty) {
                  String taggingStr = file['tagging'].toString();

                  // Handle different possible formats
                  if (taggingStr.startsWith('"') && taggingStr.endsWith('"')) {
                    // Remove extra quotes: "[\"tag1\",\"tag2\"]" -> [\"tag1\",\"tag2\"]
                    taggingStr = taggingStr.substring(1, taggingStr.length - 1);
                  }

                  // Replace escaped quotes with regular quotes
                  taggingStr = taggingStr.replaceAll(r'\"', '"');

                  // Now parse the JSON
                  final parsedTags = jsonDecode(taggingStr);
                  if (parsedTags is List) {
                    tags = List<String>.from(parsedTags);
                  }
                }
              } catch (e) {
                debugPrint('Error parsing tags: $e');
                debugPrint('Raw tagging string: ${file['tagging']}');
              }

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
                'tags': tags, // Add tags to the file data
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

  Future<void> _onFileSelected(String fileName) async {
    final TextEditingController _tagController = TextEditingController();

    // Check if file already has a tag to avoid re-tagging
    if (miscReportTagging.containsKey(fileName) &&
        miscReportTagging[fileName]!.isNotEmpty) {
      return; // File already tagged, skip
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Add Tag for MISC Document"),
          content: CustomTextField(
            controller: _tagController,
            hintText: "Enter tag name",
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            Animatedbutton(
              onPressed: () {
                Navigator.pop(context);
              },
              shadowColor: Colors.transparent,
              backgroundColor: Colors.white,
              borderColor: AppColors.red,
              titlecolor: AppColors.red,
              title: "Cancel",
            ),
            Animatedbutton(
              onPressed: () {
                final tag = _tagController.text.trim();
                if (tag.isNotEmpty) {
                  setState(() {
                    miscReportTagging[fileName] = [tag];
                    print("Added tag '$tag' for file: $fileName");
                  });
                }
                Navigator.pop(context);
              },
              shadowColor: Colors.transparent,
              backgroundColor: AppColors.secondary,
              title: "Save",
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _medNameControllers) {
      controller.dispose();
    }
    for (var controller in _medDosageControllers) {
      controller.dispose();
    }
    for (var controller in _medFrequencyControllers) {
      controller.dispose();
    }
    for (var controller in _medDurationControllers) {
      controller.dispose();
    }

    _isInitialized = false;
    // Dispose all controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _phIdController.dispose();
    _addressController.dispose();
    _OccupationController.dispose();
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
    _RBSController.dispose();
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
    _thyroidFunctionT3TestController.dispose();
    _thyroidFunctionT4TestController.dispose();
    _thyroidFunctionTSHTestController.dispose();
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

  Future<void> _fetchLocationByPincode() async {
    final pincode = _pincodeController.text.trim();
    if (pincode.isEmpty || pincode.length != 6) {
      return; // Only proceed if pincode is valid
    }

    setState(() {
      _isFetchingLocation = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$localurl/get_location_by_pincode'),
        body: {'pincode': pincode},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            _cityController.text = data['city'] ?? '';
            _stateController.text = data['state'] ?? '';
            _countryController.text = data['country'] ?? '';
          });
        } else {
          setState(() {
            print(data['message']);
            showTopRightToast(context, data['message'] ?? 'Invalid Pincode',
                backgroundColor: Colors.red);
          });
        }
      }
    } catch (e) {
      // Handle error
      debugPrint('Error fetching location: $e');
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  void _addMedicationRow({int count = 1}) {
    for (int i = 0; i < count; i++) {
      setState(() {
        _medNameControllers.add(TextEditingController());
        _medDosageControllers.add(TextEditingController());
        _medFrequencyControllers.add(TextEditingController());
        _medDurationControllers.add(TextEditingController());

        _medicationIds.add(""); // new rows get empty string
      });
    }
  }

  List<Map<String, dynamic>> getMedicationPayload() {
    List<Map<String, dynamic>> medications = [];

    // Add active medications
    for (int i = 0; i < _medNameControllers.length; i++) {
      medications.add({
        "id": _medicationIds[i] == null ? "" : _medicationIds[i],
        "name_of_medication": _medNameControllers[i].text,
        "dosage": _medDosageControllers[i].text,
        "frequency": _medFrequencyControllers[i].text,
        "duration": _medDurationControllers[i].text,
        "status": 1,
      });
    }

    // Add deleted medications
    medications.addAll(_deletedMedications);

    return medications;
  }

  void _removeMedicationRow(int index) {
    setState(() {
      // If it's an existing medication, add to deleted list
      if (_medicationIds[index] != null &&
          _medicationIds[index].toString().isNotEmpty) {
        _deletedMedications.add({"id": _medicationIds[index], "status": 0});
      }

      // Remove from active list
      _medNameControllers.removeAt(index).dispose();
      _medDosageControllers.removeAt(index).dispose();
      _medFrequencyControllers.removeAt(index).dispose();
      _medDurationControllers.removeAt(index).dispose();
      _medicationIds.removeAt(index);
    });
  }

  Future<void> _submitForm({bool showSuccessDialog = false}) async {
    bool personalValid = _personalInfoFormKey.currentState?.validate() ?? false;
    bool medicalValid = _medicalInfoFormKey.currentState?.validate() ?? false;
    bool reportsValid = _reportsFormKey.currentState?.validate() ?? false;
    // if (!_validateFiles()) {
    //   ShowDialogs.showSnackBar(
    //       context, 'Some files are invalid. Please check your uploads.');
    //   return;
    // }

    if (!personalValid || !medicalValid || !reportsValid) {
      showTopRightToast(context, 'Please fill all required fields',
          backgroundColor: Colors.red);
      return;
    }

    if (!personalValid || !medicalValid || !reportsValid || _gender == null) {
      showTopRightToast(context, 'Please Select Gender.',
          backgroundColor: Colors.red);
      return;
    }
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Center(
            child: CircularProgressIndicator(
          color: AppColors.primary,
        )),
      );
      String _formatMiscReportTagging(Map<String, List<String>> tagging) {
        if (tagging.isEmpty) return '{}';

        // Filter out only entries for newly uploaded files
        final newEntries = tagging.entries
            .where((entry) {
              final fileName = entry.key;
              return _uploadedFiles['misc_report']?.any((file) =>
                      file['name'] == fileName && !file['isExisting']) ??
                  false;
            })
            .map((entry) => '"${entry.key}":${jsonEncode(entry.value)}')
            .join(',');

        return '{$newEntries}';
      }

      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        showTopRightToast(
            context, 'Authentication token not found. Please login again.');
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$localurl/storepatient'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      log('_doctorNotesController.text ${_doctorNotesController.text}');
      log('token $token');
      for (int i = 0; i < _medNameControllers.length; i++) {
        medications.add({
          "sr_no": i + 1,
          "name_of_medication": _medNameControllers[i].text,
          "dosage": _medDosageControllers[i].text,
          "frequency": _medFrequencyControllers[i].text,
          "duration": _medDurationControllers[i].text,
        });
      }
      // ✅ Add Form Fields
      Map<String, String> fields = {
        'first_name': _ensureString(_firstNameController.text),
        'last_name': _ensureString(_lastNameController.text),
        'gender': _ensureGender(_gender),
        'mobile_no': _ensureString(_phoneController.text),
        'alternative_no': _ensureString(_altPhoneController.text),
        'address': _ensureString(_addressController.text),
        'occupation': _ensureString(_OccupationController.text),
        'city': _ensureString(_cityController.text),
        'state': _ensureString(_stateController.text),
        'pincode': _ensureNumber(_pincodeController.text),
        'country': _ensureString(_countryController.text),
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
        'history_of_dm_description': _ensureString(_SincewhenController.text),
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
        'pallor': _pallorStatus == '+' ? '1' : '0',
        'icterus': _icterusStatus == '+' ? '1' : '0',
        'lymphadenopathy': _lymphadenopathyStatus == '+' ? '1' : '0',
        'oedema_status': _oedemaStatus == '+' ? '1' : '0',
        'pulse': _ensureNumber(_pulseController.text),
        'rbs_text': _ensureNumber(_RBSController.text),
        'bp_systolic': _ensureNumber(_bpSystolicController.text),
        'bp_diastolic': _ensureNumber(_bpDiastolicController.text),

        'oedema_description': _ensureString(_oedemaDetailsController.text),

        'HO_present_medication':
            _ensureString(_currentMedicationController.text),

        'blood_laboratory': _ensureString(_laboratoryController.text),
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
        'status':
            "2", //Global.status ?? GlobalPatientData.patientId.toString(),
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
        'blood_finding': _ensureString(_bloodReportFindingsController.text),
        'blood_sugar_fasting': _ensureString(_bloodSugarFastingController.text),
        'blood_sugar_post_prandial':
            _ensureString(_bloodSugarPostPrandialController.text),
        'hba1c': _ensureString(_hBA1CController.text),
        'hbsag': _ensureString(_hBSAGController.text),
        'hiv': _ensureString(_hivController.text),
        'hcv': _ensureString(_hcvController.text),
        't3': _ensureString(_thyroidFunctionT3TestController.text),
        't4': _ensureString(_thyroidFunctionT4TestController.text),
        'tsh': _ensureString(_thyroidFunctionTSHTestController.text),
        'misc': _ensureString(_miscController.text),
        'x_ray_laboratory': _ensureString(_xRayLaboratoryController.text),
        'date_of_x_ray': _dateofXRayController.toIso8601String().split('T')[0],
        'x_ray_finding': _ensureString(_xRayFindingController.text),
        'ct_scan_laboratory': _ensureString(_ctscanLaboratoryController.text),

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
        'registration_number':
            _ensureString(_registrationNumberController.text),
        'doc_qualification': _ensureString(_docQualificationController.text),
        'date_of_msic': _dateofmiscController.toIso8601String().split('T')[0],
        'msic_finding': _ensureString(_miscFindingController.text),
        "misc_report_tagging": _formatMiscReportTagging(miscReportTagging),
        // "medications": medications.toString(),
      };

      fields['medications'] = jsonEncode(getMedicationPayload());
      fields['patientId'] = GlobalPatientData.phid.toString();
      /* if (Global.status == '2') {
        fields['patientId'] = Global.phid.toString();
      }*/
      log('Form Fields: ${jsonEncode(fields)}');
      request.fields.addAll(fields);

      List<String> existingFileIds = [];

// Debug: Print all uploaded files
      log('📋 Total document types in _uploadedFiles: ${_uploadedFiles.length}');
      for (var docType in _uploadedFiles.keys) {
        log('📄 Document type: $docType, File count: ${_uploadedFiles[docType]?.length ?? 0}');
        if (_uploadedFiles[docType] != null) {
          for (var file in _uploadedFiles[docType]!) {
            log('   - File: ${file['name']}, isExisting: ${file['isExisting']}, id: ${file['id']}');
          }
        }
      }

// Process files
      for (var docType in _uploadedFiles.keys) {
        final fieldName = _mapDocTypeToField(docType);

        // Debug: Check mapping
        log('🔄 Processing docType: $docType -> fieldName: $fieldName');

        if (fieldName == null) {
          log('⚠️ Skipping: No field mapping for docType: $docType');
          continue;
        }

        if (_uploadedFiles[docType] == null ||
            _uploadedFiles[docType]!.isEmpty) {
          log('ℹ️ No files for docType: $docType');
          continue;
        }

        for (var file in _uploadedFiles[docType]!) {
          log('📤 Processing file: ${file['name']}, isExisting: ${file['isExisting']}');

          if (!file['isExisting']) {
            // For new files
            final fileName = file['name'];
            final tags = miscReportTagging[fileName] ?? [];
            log('   Tags for $fileName: $tags');

            if (kIsWeb && file['bytes'] != null) {
              log('🌐 Web upload: Adding multipart file for $fileName');
              var multipartFile = http.MultipartFile.fromBytes(
                fieldName,
                file['bytes']!,
                filename: file['name'],
              );

              // Add tags as additional field if this is a MISC report
              if (docType == 'misc_report' && tags.isNotEmpty) {
                final tagField = '${fieldName}_${fileName}_tags';
                log('🏷️ Adding tags field: $tagField = $tags');
                request.fields[tagField] = tags.join(',');
              }

              request.files.add(multipartFile);
              log('✅ Added file to request: $fileName');
            } else if (!kIsWeb && file['path'] != null) {
              log('📱 Mobile upload: Adding multipart file from path: ${file['path']}');
              var multipartFile = await http.MultipartFile.fromPath(
                fieldName,
                file['path']!,
                filename: file['name'],
              );

              // Add tags as additional field if this is a MISC report
              if (docType == 'misc_report' && tags.isNotEmpty) {
                final tagField = '${fieldName}_${fileName}_tags';
                log('🏷️ Adding tags field: $tagField = $tags');
                request.fields[tagField] = tags.join(',');
              }

              request.files.add(multipartFile);
              log('✅ Added file to request: $fileName');
            } else {
              log('❌ File missing required data: bytes or path');
            }
          } else {
            // For existing files
            log('💾 Existing file ID: ${file['id']}');
            existingFileIds.add(file['id'].toString());
          }
        }
      }

// Debug: Print existing file IDs
      if (existingFileIds.isNotEmpty) {
        log('🆔 Existing file IDs to preserve: ${existingFileIds.join(',')}');
        request.fields['existing_file'] = existingFileIds.join(',');
      } else {
        log('ℹ️ No existing files to preserve');
      }

// Debug: Print total files in request
      log('📦 Total files in request: ${request.files.length}');
      log('📊 Request fields count: ${request.fields.length}');
      //For Treatment Prescribed Tab
      /*  for (int i = 0; i < _medNameControllers.length; i++) {
        medications.add({
          'name': _medNameControllers[i].text,
          'dosage': _medDosageControllers[i].text,
          'frequency': _medFrequencyControllers[i].text,
          'duration': _medDurationControllers[i].text,
        });
      }
      fields['medications'] = jsonEncode(medications);*/
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
        final patientProvider =
            Provider.of<PatientProvider>(context, listen: false);
        patientProvider.markForRefresh();

        if (showSuccessDialog) {
          // Show the success dialog popup
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                child: Container(
                  width: ResponsiveUtils.scaleWidth(context, 400),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // GIF Animation
                      SizedBox(
                        height: ResponsiveUtils.scaleHeight(
                            context, 100), // Adjust height as needed
                        child: Image.asset('assets/list.gif'),
                      ),

                      const SizedBox(height: 16),
                      // Message
                      Text(
                        'Patient record saved successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 20),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // OK Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: ResponsiveUtils.fontSize(context, 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          // Show normal snackbar for intermediate saves
          showTopRightToast(
            context,
            'Patient information saved successfully.',
            backgroundColor: Colors.green,
          );
        }
      } else {
        showTopRightToast(context,
            '❌ Failed to save patient record. Status code: ${response.statusCode}',
            backgroundColor: Colors.green);
      }
    } catch (e, stackTrace) {
      // Navigator.of(context).pop();s
      Navigator.of(context).pop();
      log('🚨 Submission Error: $e');
      log('Stack Trace: $stackTrace');
      showTopRightToast(context, 'Error occurred: ${e.toString()}',
          backgroundColor: Colors.green);
    }
  }

  String? _mapDocTypeToField(String docType) {
    switch (docType) {
      case 'miscellaneous_report':
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
      case 'patient_treatment': // Add this case
        return 'patient_treatment';
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
        Uri.parse('$localurl/storepatient'),
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
        );*/ /*
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
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    if (isMobile) {
      return _buildMobileForm();
    }

    return _buildDesktopForm();
  }

  Widget _buildMobileForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Step Navigation for mobile
          _buildMobileStepNavigation(),
          const SizedBox(height: 20),

          // Form Content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildMobilePersonalInfoForm(),
                _buildMobileMedicalInfoForm(),
                _buildMobileAdditionalInfoForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          topLeft: Radius.circular(12),
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

  Widget _buildMobileStepNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Step 1: Personal Info
          GestureDetector(
            onTap: () {
              _navigateToStep(0);
            },
            child: _buildMobileStepIndicator(1, 'Personal', _currentStep >= 0),
          ),
          _buildMobileStepConnector(_currentStep >= 0),

          // Step 2: Medical Info
          GestureDetector(
            onTap: () {
              _navigateToStep(1);
            },
            child: _buildMobileStepIndicator(2, 'Medical', _currentStep >= 1),
          ),
          _buildMobileStepConnector(_currentStep >= 1),

          // Step 3: Reports
          GestureDetector(
            onTap: () {
              _navigateToStep(2);
            },
            child: _buildMobileStepIndicator(3, 'Reports', _currentStep >= 2),
          ),
        ],
      ),
    );
  }
  void _navigateToStep(int targetStep) {
    // Don't navigate if trying to go to the same step
    if (_currentStep == targetStep) return;

    // Navigate directly without validation
    setState(() {
      _currentStep = targetStep;
    });

    // Scroll to top of form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildMobileStepIndicator(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondary : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
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
            color: isActive ? AppColors.primary : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildMobilePersonalInfoForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _personalInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Basic Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Basic Details Fields
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Name
                  FormInput(
                    label: 'First Name *',
                    hintlabel: 'Enter First Name',
                    controller: _firstNameController,
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  FormInput(
                    label: 'Last Name *',
                    hintlabel: 'Enter Last Name',
                    controller: _lastNameController,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  FormInput(
                    label: 'Phone Number *',
                    hintlabel: 'Enter Phone Number',
                    controller: _phoneController,
                    maxcount: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),

                  // PH ID (Read-only)
                  FormInput(
                    label: 'PH ID',
                    hintlabel: _fullPhId,
                    value: _fullPhId,
                    fillColor: Colors.grey.shade100,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // Occupation
                  FormInput(
                    label: 'Occupation',
                    hintlabel: 'Enter Occupation',
                    controller: _OccupationController,
                  ),
                  const SizedBox(height: 16),

                  // Address
                  FormInput(
                    label: 'Address',
                    hintlabel: 'Enter Address',
                    controller: _addressController,
                    maxlength: 2,
                  ),
                  const SizedBox(height: 16),

                  // Pin Code
                  FormInput(
                    label: 'Pin Code',
                    hintlabel: 'Enter Pin Code',
                    controller: _pincodeController,
                    maxcount: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      if (value.length == 6) {
                        _fetchLocationByPincode();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // City (Read-only after pincode)
                  FormInput(
                    label: 'City',
                    hintlabel: 'Enter City',
                    controller: _cityController,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // State (Read-only after pincode)
                  FormInput(
                    label: 'State',
                    hintlabel: 'Enter State',
                    controller: _stateController,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // Country (Read-only after pincode)
                  FormInput(
                    label: 'Country',
                    hintlabel: 'Enter Country',
                    controller: _countryController,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // Age
                  FormInput(
                    label: 'Age',
                    hintlabel: 'Enter Age',
                    controller: _ageController,
                    maxcount: 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),

                  // Gender Dropdown
                  DropdownInput<String>(
                    label: 'Gender *',
                    hintText: 'Select Gender',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    value: _gender,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select gender';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Consultation Date
                  DatePickerInput(
                    label: 'Consultation Date',
                    hintlabel: _formatDate(_ConsulationDate),
                    onDateSelected: (date) {
                      setState(() {
                        _ConsulationDate = date;
                      });
                    },
                    initialDate: _ConsulationDate,
                  ),
                  const SizedBox(height: 16),

                  // Referral By
                  FormInput(
                    label: 'Referral by',
                    hintlabel: 'Enter Referral by',
                    controller: _referralController,
                  ),
                  const SizedBox(height: 16),

                  // Clinic Location Dropdown
                  DropdownInput<String>(
                    label: 'Clinic Location',
                    hintText: 'Select Location',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    items: _locations.map((loc) {
                      return DropdownMenuItem<String>(
                        value: loc['id'].toString(),
                        child: Text(loc['location'].toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocationId = value;
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
                  const SizedBox(height: 16),

                  if (_selectedLocationName == "Others")
                    FormInput(
                      label: 'Other Location',
                      hintlabel: 'Enter Other Location',
                      controller: _otherLocationController,
                    ),

                  if (_selectedLocationName == "Others")
                    const SizedBox(height: 16),

                  // Height
                  FormInput(
                    label: 'Height (cms)',
                    hintlabel: 'Enter Height',
                    controller: _heightController,
                    maxcount: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _calculateBMI(),
                  ),
                  const SizedBox(height: 16),

                  // Weight
                  FormInput(
                    label: 'Weight (kg)',
                    hintlabel: 'Enter Weight',
                    controller: _weightController,
                    maxcount: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    onChanged: (value) => _calculateBMI(),
                  ),
                  const SizedBox(height: 16),

                  // BMI (Read-only)
                  FormInput(
                    label: 'BMI (kg/m²)',
                    hintlabel: _bmiController.text.isNotEmpty
                        ? _bmiController.text
                        : 'Calculate...',
                    value: _bmiController.text.isNotEmpty
                        ? _bmiController.text
                        : 'Calculate...',
                    fillColor: Colors.grey.shade100,
                    readOnly: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Navigation Buttons
            _buildMobileNavigationButtons(isFirstStep: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMedicalInfoForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _medicalInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Chief Complaints
            Text(
              '1. Chief Complaints',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: FormInput(
                label: 'Chief Complaints',
                hintlabel: 'Enter chief complaints',
                controller: _complaintsController,
                maxlength: 3,
              ),
            ),

            const SizedBox(height: 20),

            // 2. History
            Text(
              '2. History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medical History Checkboxes
                  CustomCheckbox(
                    label: 'H/O DM',
                    initialValue: _hasDM,
                    onChanged: (value) => setState(() => _hasDM = value),
                  ),
                  if (_hasDM) ...[
                    const SizedBox(height: 8),
                    FormInput(
                      label: 'Since when',
                      hintlabel: 'Enter details',
                      controller: _SincewhenController,
                    ),
                  ],
                  const SizedBox(height: 16),

                  CustomCheckbox(
                    label: 'Hypertension',
                    initialValue: _hasHypertension,
                    onChanged: (value) =>
                        setState(() => _hasHypertension = value),
                  ),
                  if (_hasHypertension) ...[
                    const SizedBox(height: 8),
                    FormInput(
                      label: 'Since when',
                      hintlabel: 'Enter details',
                      controller: _hypertensionSinceController,
                    ),
                  ],
                  const SizedBox(height: 16),

                  CustomCheckbox(
                    label: 'IHD',
                    initialValue: _hasIHD,
                    onChanged: (value) => setState(() => _hasIHD = value),
                  ),
                  if (_hasIHD) ...[
                    const SizedBox(height: 8),
                    FormInput(
                      label: 'IHD Description',
                      hintlabel: 'Enter details',
                      controller: _ihdDescriptionController,
                    ),
                  ],
                  const SizedBox(height: 16),

                  CustomCheckbox(
                    label: 'COPD',
                    initialValue: _hasCOPD,
                    onChanged: (value) => setState(() => _hasCOPD = value),
                  ),
                  if (_hasCOPD) ...[
                    const SizedBox(height: 8),
                    FormInput(
                      label: 'COPD Description',
                      hintlabel: 'Enter details',
                      controller: _copdDescriptionController,
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Other Illness Fields
                  FormInput(
                    label: 'Any Other Illness',
                    hintlabel: 'Enter details',
                    controller: _otherIllnessController,
                    maxlength: 2,
                  ),
                  const SizedBox(height: 16),

                  FormInput(
                    label: 'Past Surgical History',
                    hintlabel: 'Enter details',
                    controller: _surgicalHistoryController,
                    maxlength: 2,
                  ),
                  const SizedBox(height: 16),

                  FormInput(
                    label: 'H/O Drug Allergy',
                    hintlabel: 'Enter details',
                    controller: _drugAllergyController,
                    maxlength: 2,
                    useCamelCase: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. General Examination
            Text(
              '3. General Examination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Temperature
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temp',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CustomRadioButton<String>(
                            value: 'Afebrile',
                            groupValue: _tempStatus,
                            onChanged: (value) {
                              _tempController.text = "0";
                              setState(() => _tempStatus = value!);
                            },
                            label: 'Afebrile',
                          ),
                          const SizedBox(width: 8),
                          CustomRadioButton<String>(
                            value: 'Febrile',
                            groupValue: _tempStatus,
                            onChanged: (value) {
                              setState(() => _tempStatus = value!);
                            },
                            label: 'Febrile',
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (_tempStatus == 'Febrile') ...[
                    const SizedBox(height: 16),
                    FormInput(
                      label: 'Temperature',
                      hintlabel: 'Enter temperature',
                      controller: _tempController,
                      maxcount: 4,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Pulse
                  FormInput(
                    label: 'Pulse (BPM)',
                    hintlabel: 'Enter pulse',
                    controller: _pulseController,
                    maxcount: 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    useCamelCase: false,
                  ),
                  const SizedBox(height: 16),

                  // RBS
                  FormInput(
                    label: 'RBS (Random Blood Sugar)',
                    hintlabel: 'Enter RBS',
                    controller: _RBSController,
                    useCamelCase: false,
                  ),
                  const SizedBox(height: 16),

                  // Blood Pressure
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BP (MM/Hg)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FormInput(
                              label: '',
                              hintlabel: 'Systolic',
                              controller: _bpSystolicController,
                              useCamelCase: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('/', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FormInput(
                              label: '',
                              hintlabel: 'Diastolic',
                              controller: _bpDiastolicController,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pallor
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pallor',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          const SizedBox(width: 8),
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
                  const SizedBox(height: 16),

                  // Icterus
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Icterus',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          const SizedBox(width: 8),
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
                  const SizedBox(height: 16),

                  // Lymphadenopathy
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lymphadenopathy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          const SizedBox(width: 8),
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
                  const SizedBox(height: 16),

                  // Oedema
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Oedema',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          const SizedBox(width: 8),
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
                  const SizedBox(height: 20),

                  // Present Medication
                  FormInput(
                    label: 'H/O Present Medication',
                    hintlabel: 'Enter medication details',
                    controller: _currentMedicationController,
                    maxlength: 3,
                    useCamelCase: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Systemic Examination
            Text(
              '4. Systemic Examination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // RS
                  FormInput(
                    label: 'RS (Respiratory System)',
                    hintlabel: 'Enter details',
                    controller: _rsController,
                    maxlength: 2,
                    useCamelCase: false,
                  ),
                  const SizedBox(height: 16),

                  // CVS
                  FormInput(
                    label: 'CVS (Cardio Vascular System)',
                    hintlabel: 'Enter details',
                    controller: _cvsController,
                    maxlength: 2,
                    useCamelCase: false,
                  ),
                  const SizedBox(height: 16),

                  // CNS
                  FormInput(
                    label: 'CNS (Central Nervous System)',
                    hintlabel: 'Enter details',
                    controller: _cnsController,
                    maxlength: 2,
                    useCamelCase: false,
                  ),
                  const SizedBox(height: 16),

                  // PA Abdomen
                  FormInput(
                    label: 'P/A Per Abdomen',
                    hintlabel: 'Enter details',
                    controller: _paAbdomenController,
                    maxlength: 2,
                    useCamelCase: false,
                  ),
                  const SizedBox(height: 16),

                  // PR Rectum
                  FormInput(
                    label: 'P/R Rectum Notes',
                    hintlabel: 'Enter details',
                    controller: _prRectumController,
                    maxlength: 2,
                  ),
                  const SizedBox(height: 16),

                  // Local Examination
                  FormInput(
                    label: 'Local Examination',
                    hintlabel: 'Enter details',
                    controller: _localExamController,
                    maxlength: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 5. Diagnosis & Plan
            Text(
              '5. Diagnosis & Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clinical Diagnosis
                  FormInput(
                    label: 'Clinical Diagnosis',
                    hintlabel: 'Enter diagnosis',
                    controller: _diagnosisController,
                    maxlength: 3,
                  ),
                  const SizedBox(height: 16),

                  // Comorbidities
                  FormInput(
                    label: 'Comorbidities',
                    hintlabel: 'Enter comorbidities',
                    controller: _comorbiditiesController,
                    maxlength: 2,
                  ),
                  const SizedBox(height: 16),

                  // Plan
                  FormInput(
                    label: 'Plan',
                    hintlabel: 'Enter plan',
                    controller: _planController,
                    maxlength: 3,
                  ),
                  const SizedBox(height: 16),

                  // Advice
                  FormInput(
                    label: 'Advice',
                    hintlabel: 'Enter advice',
                    controller: _adviseController,
                    maxlength: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Navigation Buttons
            _buildMobileNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAdditionalInfoForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _reportsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Reports
            Text(
              '1. Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document Upload
                  DocumentUploadWidget(
                    docType: 'miscellaneous_report',
                    label: "Upload Reports",
                    onFilesSelected: (files) {
                      setState(() {
                        _uploadedFiles['miscellaneous_report'] = files;
                      });
                    },
                    initialFiles: _uploadedFiles['miscellaneous_report'],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Doctor Notes
            Text(
              '2. Doctor Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Final Diagnosis
                  FormInput(
                    label: 'Final Diagnosis',
                    hintlabel: 'Enter final diagnosis',
                    controller: _doctorNotesController,
                    maxlength: 4,
                  ),
                  const SizedBox(height: 20),

                  // Prescription Upload
                  DocumentUploadWidget(
                    docType: 'patient_treatment',
                    label: "Prescription Upload",
                    onFilesSelected: (files) {
                      setState(() {
                        _uploadedFiles['patient_treatment'] = files;
                      });
                    },
                    initialFiles: _uploadedFiles['patient_treatment'],
                  ),
                  const SizedBox(height: 20),

                  // Follow-up Date
                  DatePickerInput(
                    label: 'Follow up date',
                    hintlabel: _followUpDate != null
                        ? _formatDate(_followUpDate!)
                        : 'Select date',
                    onDateSelected: (date) {
                      setState(() {
                        _followUpDate = date;
                      });
                    },
                    initialDate: _followUpDate ?? DateTime.now(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Misc
            Text(
              '3. Misc',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Miscellaneous Upload
                  DocumentUploadWidget(
                    docType: 'misc_report',
                    label: "Miscellaneous Upload",
                    onFilesSelected: (files) async {
                      setState(() {
                        _uploadedFiles['misc_report'] = files;

                        for (var file in files) {
                          final fileName = file['name'];
                          if (fileName != null && !file['isExisting']) {
                            _onFileSelected(fileName);
                          }
                        }
                      });
                    },
                    initialFiles: _uploadedFiles['misc_report'],
                    miscReportTagging: miscReportTagging,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Navigation Buttons
            _buildMobileNavigationButtons(isLastStep: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavigationButtons({
    bool isFirstStep = false,
    bool isLastStep = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: Animatedbutton(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                shadowColor: Colors.white,
                titlecolor: AppColors.primary,
                backgroundColor: Colors.white,
                borderColor: AppColors.secondary,
                isLoading: _isLoading,
                title: 'BACK',
              ),
            ),
          if (!isFirstStep && !isLastStep) const SizedBox(width: 12),
          if (!isLastStep)
            Expanded(
              child: Animatedbutton(
                onPressed: () async {
                  // Validate current step
                  bool isValid = false;

                  if (isFirstStep) {
                    isValid = _personalInfoFormKey.currentState?.validate() ?? false;
                  } else if (_currentStep == 1) {
                    isValid = _medicalInfoFormKey.currentState?.validate() ?? false;
                  }

                  if (isValid) {
                    setState(() => _isLoading = true);
                    try {
                      // Save the form data
                     await _submitForm(showSuccessDialog: false);

                      // Navigate to next step immediately after save
                      if (mounted) {
                        setState(() {
                          _currentStep++; // THIS LINE WAS MISSING
                          _isLoading = false;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  }
                },
                shadowColor: Colors.white,
                backgroundColor: AppColors.secondary,
                isLoading: _isLoading,
                title: 'NEXT/SAVE',
              ),
            ),
          if (isLastStep) const SizedBox(width: 12),
          if (isLastStep)
            Expanded(
              child: Animatedbutton(
                onPressed: () async {
                  bool isValid = _reportsFormKey.currentState?.validate() ?? false;
                  if (isValid) {
                    setState(() => _isLoading = true);
                    try {
                      await _submitForm(showSuccessDialog: true);
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  }
                },
                shadowColor: Colors.white,
                backgroundColor: AppColors.secondary,
                isLoading: _isLoading,
                title: 'SUBMIT',
              ),
            ),
        ],
      ),
    );
  }





  Widget _buildStepNavigation() {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      width: 550,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildClickableStep(1,
              isMobile ? 'Personal\nInformation' : 'Personal Information', 0),
          _buildStepConnector(_currentStep >= 0),
          _buildClickableStep(
              2, isMobile ? 'Medical\nInformation' : 'Medical Information', 1),
          _buildStepConnector(_currentStep >= 1),
          _buildClickableStep(
              3, isMobile ? 'Reports &\nDocuments' : 'Reports & Documents', 2),
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
          width: ResponsiveUtils.scaleWidth(context, 32),
          height: ResponsiveUtils.scaleHeight(context, 32),
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
                fontSize: ResponsiveUtils.fontSize(context, 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontSize: ResponsiveUtils.fontSize(context, 12),
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
              Text(
                '1. Basic Details',
                style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 20),
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                int itemsPerRow;

                if (screenWidth < 600) {
                  itemsPerRow = 1; // mobile
                } else if (screenWidth < 1200) {
                  itemsPerRow = 3; // tablet
                } else if (screenWidth < 1500) {
                  itemsPerRow = 3; // small desktop
                } else {
                  itemsPerRow = 4; // large desktop
                }

                double itemWidth = (screenWidth / itemsPerRow) - 16; // padding
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    FormInput(
                      label: 'First Name *',
                      hintlabel: "Enter First Name",
                      controller: _firstNameController,
                    ),
                    FormInput(
                      label: 'Last Name *',
                      hintlabel: "Enter Last Name",
                      controller: _lastNameController,
                    ),
                    FormInput(
                      label: 'Phone Number *',
                      hintlabel: "Enter Phone Number",
                      controller: _phoneController,
                      maxcount: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]')), // Only letters allowed
                      ],
                    ),
                    FormInput(
                      label: 'PH ID',
                      hintlabel: "Enter PH ID",
                      value: _fullPhId, // Pass the value directly
                      fillColor: Colors.grey.shade100,
                      readOnly: true,
                    ),
                    FormInput(
                      label: 'Occupation',
                      hintlabel: "Enter Occupation",
                      controller: _OccupationController,
                    ),
                    FormInput(
                      label: 'Address',
                      hintlabel: "Enter Address",
                      controller: _addressController,
                      maxlength: 1,
                    ),
                    FormInput(
                      label: 'Pin Code',
                      hintlabel: "Enter Pin Code",
                      controller: _pincodeController,
                      maxcount: 6,
                      onChanged: (value) {
                        if (value.length == 6) {
                          _fetchLocationByPincode();
                        } else if (value.length < 6) {
                          // Clear location fields if pincode is incomplete
                          setState(() {
                            _cityController.clear();
                            _stateController.clear();
                            _countryController.clear();
                          });
                        }
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]')), // Only letters allowed
                      ],
                    ),
                    FormInput(
                      label: 'City',
                      hintlabel: "Enter City",
                      controller: _cityController,
                      readOnly: true,
                    ),
                    FormInput(
                        label: 'State',
                        hintlabel: "Enter State",
                        controller: _stateController,
                        readOnly: true),
                    FormInput(
                        label: 'Country',
                        hintlabel: "Enter Country",
                        readOnly: true,
                        controller: _countryController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z]')), // Only letters allowed
                        ]),
                    FormInput(
                      label: 'Age',
                      hintlabel: "Enter Age",
                      maxcount: 3,
                      controller: _ageController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]')), // Only letters allowed
                      ],
                    ),
                    DropdownInput<String>(
                      label: 'Gender *',
                      hintText: 'Select Gender',
                      hintStyle: TextStyle(
                          color: AppColors.hinttext,
                          fontSize: ResponsiveUtils.fontSize(context, 16)),
                      items: [
                        DropdownMenuItem(
                            value: 'Male',
                            child: Text(
                              'Male',
                              style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.fontSize(context, 16)),
                            )),
                        DropdownMenuItem(
                            value: 'Female',
                            child: Text(
                              'Female',
                              style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.fontSize(context, 16)),
                            )),
                        DropdownMenuItem(
                            value: 'Other',
                            child: Text(
                              'Other',
                              style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.fontSize(context, 16)),
                            )),
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
                      initialDate:
                          _ConsulationDate, // Pass the initial date if needed
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
                          child: Text(
                            loc['location'].toString(),
                            style: TextStyle(
                                fontSize:
                                    ResponsiveUtils.fontSize(context, 16)),
                          ),
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
                    if (_selectedLocationName == "Others")
                      FormInput(
                        label: 'Other  Location',
                        hintlabel: "Enter Other  Location",
                        controller: _otherLocationController,
                      ),
                    FormInput(
                      label: 'Height (cms)',
                      hintlabel: "Enter Height (cms)",
                      controller: _heightController,
                      maxcount: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      onChanged: (value) => _calculateBMI(), // Add this line
                    ),
                    FormInput(
                      label: 'Weight (kg)',
                      hintlabel: "Enter Weight",
                      maxcount: 6, // increase if decimals allowed
                      controller: _weightController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      onChanged: (value) => _calculateBMI(),
                    ),
                    FormInput(
                      label: 'BMI (kg/m²)',
                      hintlabel: "Enter BMI",
                      controller: _bmiController,
                      fillColor: Colors.grey.shade100,
                      readOnly: true, // Add this property
                      useCamelCase: false,
                    ),
                  ].map((child) {
                    return SizedBox(
                      width: itemWidth,
                      child: child,
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 20),
              _buildFormNavigationButtons(isFirstStep: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalInfoForm() {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Form(
      key: _medicalInfoFormKey,
      child: SingleChildScrollView(
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
                  Text("1. Chief Complaints",
                      style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16),
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
                  Text("2. History",
                      style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  const SizedBox(height: 8),
                  // isMobile ?

                  LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      int itemsPerRow;

                      if (screenWidth < 600) {
                        itemsPerRow = 1; // mobile
                      } else if (screenWidth < 1200) {
                        itemsPerRow = 2; // tablet
                      } else if (screenWidth < 1500) {
                        itemsPerRow = 2; // small desktop
                      } else {
                        itemsPerRow = 2; // large desktop
                      }

                      double itemWidth = (screenWidth / itemsPerRow) - 16;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          HistoryYesNoField(
                            label: "H/O DM",
                            value: _hasDM,
                            onChanged: (val) => setState(() => _hasDM = val),
                            extraField: FormInput(
                              label: 'Since when',
                              maxlength: 1,
                              controller: _SincewhenController,
                            ),
                          ),
                          HistoryYesNoField(
                            label: "Hypertension",
                            value: _hasHypertension,
                            onChanged: (val) =>
                                setState(() => _hasHypertension = val),
                            extraField: FormInput(
                              label: 'Since when',
                              maxlength: 1,
                              controller: _hypertensionSinceController,
                            ),
                          ),
                          HistoryYesNoField(
                            label: "IHD",
                            value: _hasIHD,
                            onChanged: (val) => setState(() => _hasIHD = val),
                            extraField: FormInput(
                              label: 'IHD Description',
                              maxlength: 1,
                              controller: _ihdDescriptionController,
                            ),
                          ),
                          HistoryYesNoField(
                            label: "COPD",
                            value: _hasCOPD,
                            onChanged: (val) => setState(() => _hasCOPD = val),
                            extraField: FormInput(
                              label: 'COPD Description',
                              maxlength: 1,
                              controller: _copdDescriptionController,
                            ),
                          ),
                        ].map((child) {
                          return SizedBox(width: itemWidth, child: child);
                        }).toList(),
                      );
                    },
                  ),

                  /*:
               Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCheckbox(
                            label: 'H/O DM',
                            initialValue: _hasDM,
                            onChanged: (value) => setState(() => _hasDM = value),

                          ),
                          const SizedBox(height: 8),
                          if (_hasDM)
                            FormInput(
                              label: 'Since when',
                              maxlength: 1,
                              controller: _SincewhenController,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCheckbox(
                            label: 'Hypertension',
                            initialValue: _hasHypertension,
                            onChanged: (value) {
                              setState(() {
                                _hasHypertension = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          if (_hasHypertension)
                            FormInput(
                              label: 'Since when',
                              maxlength: 1,
                              controller: _hypertensionSinceController,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCheckbox(
                            label: 'IHD',
                            initialValue: _hasIHD,
                            onChanged: (value) {
                              setState(() {
                                _hasIHD = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          if (_hasIHD)
                            FormInput(
                              label: 'IHD Description',
                              maxlength: 1,
                              controller: _ihdDescriptionController,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCheckbox(
                            label: 'COPD',
                            initialValue: _hasCOPD,
                            onChanged: (value) {
                              setState(() {
                                _hasCOPD = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          if (_hasCOPD)
                            FormInput(
                              label: 'COPD Description',
                              maxlength: 1,
                              controller: _copdDescriptionController,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
      */

                  const SizedBox(height: 8),

                  LayoutBuilder(builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    int itemsPerRow;

                    if (screenWidth < 600) {
                      itemsPerRow = 1; // mobile
                    } else if (screenWidth < 1200) {
                      itemsPerRow = 3; // tablet
                    } else if (screenWidth < 1500) {
                      itemsPerRow = 3; // small desktop
                    } else {
                      itemsPerRow = 4; // large desktop
                    }

                    double itemWidth =
                        (screenWidth / itemsPerRow) - 16; // padding
                    return Wrap(
                      spacing: 16,
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
                          useCamelCase: false,
                        ),
                      ].map((child) {
                        return SizedBox(
                          width: itemWidth,
                          child: child,
                        );
                      }).toList(),
                    );
                  }),
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
                  Text("3. General Examination",
                      style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  const SizedBox(height: 8),
                  LayoutBuilder(builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    int itemsPerRow;

                    if (screenWidth < 600) {
                      itemsPerRow = 1; // mobile
                    } else if (screenWidth < 1200) {
                      itemsPerRow = 4; // tablet
                    } else if (screenWidth < 1500) {
                      itemsPerRow = 4; // small desktop
                    } else {
                      itemsPerRow = 4; // large desktop
                    }

                    double itemWidth =
                        (screenWidth / itemsPerRow) - 16; // padding
                    return Wrap(
                      spacing: 16,
                      runSpacing: 12,
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
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  CustomRadioButton<String>(
                                    value: 'Afebrile',
                                    groupValue: _tempStatus,
                                    onChanged: (value) {
                                      _tempController.text = "0";
                                      setState(() => _tempStatus = value!);
                                    },
                                    label: 'Afebrile',
                                  ),
                                  SizedBox(width: 8),
                                  CustomRadioButton<String>(
                                    value: 'Febrile',
                                    groupValue: _tempStatus,
                                    onChanged: (value) {
                                      setState(() => _tempStatus = value!);
                                    },
                                    label: 'Febrile',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (_tempStatus == 'Febrile')
                          FormInput(
                            label: 'Temperature',
                            controller: _tempController,
                            maxcount: 4,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                          ),
                        FormInput(
                          label: 'Pulse (BPM)',
                          controller: _pulseController,
                          maxcount: 5,
                          useCamelCase: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                        ),
                        FormInput(
                          label: 'RBS(Random Blood Sugar)',
                          controller: _RBSController,
                          maxcount: 5,
                          useCamelCase: false,
                        ),

                        Container(
                          width: isMobile
                              ? ResponsiveUtils.scaleWidth(context, 200)
                              : ResponsiveUtils.scaleWidth(context, 308),
                          child: Row(
                            spacing: 8,
                            children: [
                              SizedBox(
                                  width: isMobile
                                      ? ResponsiveUtils.scaleWidth(context, 70)
                                      : ResponsiveUtils.scaleWidth(
                                          context, 100),
                                  child: FormInput(
                                    label: 'BP (MM/Hg)',
                                    hintlabel: 'Systolic',
                                    controller: _bpSystolicController,
                                    useCamelCase: false,
                                  )),
                              Text(
                                "/",
                                style: TextStyle(
                                    fontSize:
                                        ResponsiveUtils.fontSize(context, 26)),
                              ),
                              SizedBox(
                                  width: isMobile
                                      ? ResponsiveUtils.scaleWidth(context, 70)
                                      : ResponsiveUtils.scaleWidth(
                                          context, 100),
                                  child: FormInput(
                                    label: '',
                                    hintlabel: 'Diastolic',
                                    controller: _bpDiastolicController,
                                  )),
                            ],
                          ),
                        ),
                        // const DropdownInput(label: 'Pallor'),
                        // Pallor
                      ].map((child) {
                        return SizedBox(
                          width: itemWidth,
                          child: child,
                        );
                      }).toList(),
                    );
                  }),
                  SizedBox(
                    height: 16,
                  ),
                  LayoutBuilder(builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    int itemsPerRow;

                    if (screenWidth < 600) {
                      itemsPerRow = 1; // mobile
                    } else if (screenWidth < 1200) {
                      itemsPerRow = 4; // tablet
                    } else if (screenWidth < 1500) {
                      itemsPerRow = 4; // small desktop
                    } else {
                      itemsPerRow = 4; // large desktop
                    }

                    double itemWidth =
                        (screenWidth / itemsPerRow) - 16; // padding

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pallor",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontSize:
                                        ResponsiveUtils.fontSize(context, 14))),
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

                        // Icterus
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Icterus",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontSize:
                                        ResponsiveUtils.fontSize(context, 14))),
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

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Lymphadenopathy",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontSize:
                                        ResponsiveUtils.fontSize(context, 14))),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                CustomRadioButton<String>(
                                  value: '+',
                                  groupValue: _lymphadenopathyStatus,
                                  onChanged: (value) {
                                    setState(
                                        () => _lymphadenopathyStatus = value!);
                                  },
                                  label: '+',
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                CustomRadioButton<String>(
                                  value: 'Nil',
                                  groupValue: _lymphadenopathyStatus,
                                  onChanged: (value) {
                                    setState(
                                        () => _lymphadenopathyStatus = value!);
                                  },
                                  label: 'Nil',
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Oedema",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontSize:
                                        ResponsiveUtils.fontSize(context, 14))),
                            SizedBox(
                              height: 8,
                            ),
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
                                SizedBox(
                                  width: 4,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
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
                      ].map((child) {
                        return SizedBox(
                          width: itemWidth,
                          child: child,
                        );
                      }).toList(),
                    );
                  }),
                  SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(
                        label: 'H/O Present Medication',
                        controller: _currentMedicationController,
                        useCamelCase: false,
                      )),
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
                  Text("4. Systemic Examination",
                      style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        double screenWidth = constraints.maxWidth;
                        int itemsPerRow;

                        if (screenWidth < 600) {
                          itemsPerRow = 1; // mobile
                        } else if (screenWidth < 1200) {
                          itemsPerRow = 3; // tablet
                        } else if (screenWidth < 1500) {
                          itemsPerRow = 3; // small desktop
                        } else {
                          itemsPerRow = 4; // large desktop
                        }

                        double itemWidth =
                            (screenWidth / itemsPerRow) - 16; // padding

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            FormInput(
                              label: 'RS (Respiratory System)',
                              controller: _rsController,
                              useCamelCase: false,
                            ),
                            FormInput(
                              label: 'CVS (Cardio Vascular System)',
                              controller: _cvsController,
                              useCamelCase: false,
                            ),
                            FormInput(
                              label: 'CNS (Central Nervous System)',
                              controller: _cnsController,
                              useCamelCase: false,
                            ),
                            FormInput(
                              label: 'P/A Per Abdomen',
                              controller: _paAbdomenController,
                              useCamelCase: false,
                            ),
                          ].map((child) {
                            return SizedBox(
                              width: itemWidth,
                              child: child,
                            );
                          }).toList(),
                        );
                      }),
                      SizedBox(
                        width: double.infinity,
                        child: DocumentUploadWidget(
                          docType:
                              'pa_abdomen_image', // This should match one of your map keys
                          label: "P/A Per Abdomen",

                          onFilesSelected: (files) {
                            setState(() {
                              _uploadedFiles['pa_abdomen_image'] = files;
                            });
                          },
                          initialFiles: _uploadedFiles['pa_abdomen_image'],
                        ),
                      ),
                      LayoutBuilder(builder: (context, constraints) {
                        double screenWidth = constraints.maxWidth;
                        int itemsPerRow;

                        if (screenWidth < 600) {
                          itemsPerRow = 1; // mobile
                        } else if (screenWidth < 1200) {
                          itemsPerRow = 3; // tablet
                        } else if (screenWidth < 1500) {
                          itemsPerRow = 3; // small desktop
                        } else {
                          itemsPerRow = 4; // large desktop
                        }

                        double itemWidth =
                            (screenWidth / itemsPerRow) - 16; // padding

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            //  FormInput(label: 'P/A Abdomen Notes',controller: _paAbdomenController,),
                            FormInput(
                              label: 'P/R Rectum Notes',
                              controller: _prRectumController,
                            ),
                            Container()
                          ].map((child) {
                            return SizedBox(
                              width: itemWidth,
                              child: child,
                            );
                          }).toList(),
                        );
                      }),
                      SizedBox(
                          width: double.infinity,
                          child: FormInput(
                            label: 'Local Examination',
                            maxlength: 2,
                            controller: _localExamController,
                          )),
                      SizedBox(
                        width: double.infinity,
                        child: DocumentUploadWidget(
                          docType:
                              'ct_scan_report', // This should match one of your map keys
                          label: "Miscellaneous Uploads",
                          onFilesSelected: (files) {
                            setState(() {
                              _uploadedFiles['ct_scan_report'] = files;
                            });
                          },
                          initialFiles: _uploadedFiles['ct_scan_report'],
                        ),
                      ),
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
                  Text("5. Diagnosis & Plan",
                      style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  const SizedBox(height: 8),
                  LayoutBuilder(builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    int itemsPerRow;

                    if (screenWidth < 600) {
                      itemsPerRow = 1; // mobile
                    } else if (screenWidth < 1200) {
                      itemsPerRow = 3; // tablet
                    } else if (screenWidth < 1500) {
                      itemsPerRow = 3; // small desktop
                    } else {
                      itemsPerRow = 4; // large desktop
                    }

                    double itemWidth =
                        (screenWidth / itemsPerRow) - 16; // padding
                    return Wrap(
                      spacing: 16,
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
                      ].map((child) {
                        return SizedBox(
                          width: itemWidth,
                          child: child,
                        );
                      }).toList(),
                    );
                  }),
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
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isFirstStep)
            SizedBox(
              width: ResponsiveUtils.scaleWidth(context, 150),
              child: Animatedbutton(
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
              ),
            )
          else
            const SizedBox(width: 120),
          const SizedBox(width: 10),
          Visibility(
            visible: isLastStep ? PermissionService().canEditPatients : true,
            child: SizedBox(
              width: ResponsiveUtils.scaleWidth(context, 150),
              child: Animatedbutton(
                onPressed: () async {
                  if (!isLastStep) {
                    // For medical info step (step 1), just validate and save
                    bool medicalValid =
                        _medicalInfoFormKey.currentState?.validate() ?? false;
                    if (medicalValid) {
                      // Save without showing success dialog
                      await _submitForm(showSuccessDialog: false);
                      setState(() => _currentStep++);
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else {
                    // For final step, show success dialog
                    await _submitForm(showSuccessDialog: true);
                  }
                },
                /*     onPressed: () {
                  if (!isLastStep) {
              */ /*      setState(() => _currentStep++);
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );*/ /*
                  } else {
                    _submitForm(showSuccessDialog: false);
                 }
                },*/
                shadowColor: Colors.white,
                backgroundColor: AppColors.secondary,
                isLoading: _isLoading,
                title: isLastStep ? 'SUBMIT' : 'NEXT/SAVE',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
      withData: true,
    );

    if (pickedFiles != null && pickedFiles.files.isNotEmpty) {
      setState(() {
        _uploadedFiles['implants_image'] ??= [];
        _uploadedFiles['implants_image']!.addAll(pickedFiles.files.map((file) {
          return {
            'bytes': file.bytes!,
            'name': file.name,
            'type': path.extension(file.name).replaceAll('.', '').toLowerCase(),
            'isExisting': false,
          };
        }).toList());
      });
    }
  }

  Widget _buildAdditionalInfoForm() {
    return Form(
      key: _reportsFormKey,
      child: SingleChildScrollView(
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    '1. Reports',
                    style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 18),
                        fontWeight: FontWeight.w800),
                  ),
                  /*           SizedBox(height: 20,),
                  Row(children: [
                    Text(
                      'Blood Report',
                      style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 16), fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.backgroundcolor,
                        thickness: 1,
                      ),
                    ),
                  ],),
                  const SizedBox(height: 10),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Laboratory',controller: _laboratoryController,)),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                      builder: (context,constraints) {
                        double screenWidth = constraints.maxWidth;
                        int itemsPerRow;

                        if (screenWidth < 600) {
                          itemsPerRow = 1; // mobile
                        } else if (screenWidth < 1200) {
                          itemsPerRow = 3; // tablet
                        } else if (screenWidth < 1500) {
                          itemsPerRow = 3; // small desktop
                        } else {
                          itemsPerRow = 4; // large desktop
                        }

                        double itemWidth = (screenWidth / itemsPerRow) - 16; // padding
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children:  [

                          FormInput(label: 'Hemoglobin',controller: _hemoglobinController,),
                          FormInput(label: 'Total leucocyte count',controller: _totalLeucocyteCountController,),
                          FormInput(label: 'ESR',controller: _esrController,useCamelCase: false),
                          FormInput(label: 'Platelets',controller: _plateletsController,),
                          FormInput(label: 'Urine Routine',controller:_urineRoutineController),
                          FormInput(label: 'Urine Culture',controller:_urineCultureController),
                          FormInput(label: 'BUN',controller:_bunController,useCamelCase: false,),
                          FormInput(label: 'Serum Creatinine',controller:_serumCreatinineController),
                          FormInput(label: 'Serum Electrolytes',controller:_serumElectrolytesController),
                          FormInput(label: 'LFT',controller:_lftController,useCamelCase: false),
                          FormInput(label: 'Prothrombin Time / INR',controller:_prothrombinTimController,useCamelCase: false),
                          FormInput(label: 'Blood Sugar Fasting',controller:_bloodSugarFastingController),
                          FormInput(label: 'Blood Sugar Post Prandial',controller:_bloodSugarPostPrandialController),
                          FormInput(label: 'HBA1C',controller:_hBA1CController,useCamelCase: false),
                          FormInput(label: 'HBSAG',controller:_hBSAGController,useCamelCase: false),
                          FormInput(label: 'HIV',controller:_hivController,useCamelCase: false),
                          FormInput(label: 'HCV',controller:_hcvController,useCamelCase: false),
                          FormInput(label: 'Thyroid Function Test T3',controller:_thyroidFunctionT3TestController),
                          FormInput(label: 'Thyroid Function Test T4',controller:_thyroidFunctionT4TestController),
                          FormInput(label: 'Thyroid Function Test TSH',controller:_thyroidFunctionTSHTestController,useCamelCase: false),
                          FormInput(label: 'MISC',controller:_miscController,useCamelCase: false),
                          SizedBox(
                              width: double.infinity,
                              child: FormInput(label: 'Findings',controller: _bloodReportFindingsController, maxlength: 2,)),

                        ].map((child) {
                          return SizedBox(
                            width: itemWidth,
                            child: child,
                          );
                        }).toList(),
                      );
                    }
                  ),
                  SizedBox(height: 20,),
                  Row(children: [
                    Text(
                      'X-Ray Report',
                      style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 16), fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.backgroundcolor,
                        thickness: 1,
                      ),
                    ),
                  ],),
                  SizedBox(height: 10,),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings',controller:_xRayFindingController,maxlength: 2,)),
                  SizedBox(height: 10,),
                  Row(

                    children: [
                    Text(
                      'CT Scan Report',
                      style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 16), fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                      Expanded(
                        child: Divider(
                          color: AppColors.backgroundcolor,
                          thickness: 1,
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
               */
                  /*   Row(
                    spacing: 10,
                    children: [

                      FormInput(label: 'CT Scan',hintlabel: "Upload CT Scan Reports",controller:_ctScanFindingsController),

                      Expanded(

                          child: FormInput(label: 'Media History',)),
                    ],
                  ),*/
                  /*
                  SizedBox(height: 10,),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                     // FormInput(label: 'Date',hintlabel: "dd-mm-yyyy",),
                      DatePickerInput(
                        label: 'Date',
                        hintlabel: 'Date',
                        onDateSelected: (date) {
                          setState(() {
                            _CTScanDate = date; // Update the selected date
                          });
                        },
                        initialDate: _CTScanDate, // Pass the initial date if needed
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: FormInput(label: 'Findings',controller: _ctscanFindingController,maxlength: 2,)),
                    ],
                  ),

                  SizedBox(height: 10,),

                */
                  /*  Row(children: [
                    Text(
                      'MRI Report',
                      style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 16), fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.backgroundcolor,
                        thickness: 1,
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
                      style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 16), fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.backgroundcolor,
                        thickness: 1,
                      ),
                    ),
                  ],),
                  SizedBox(height: 10,),

                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings',controller: _petscanFindingController,)),
                  SizedBox(height: 10,),*/
                  /*
                  Row(

                    children: [
                      Text(
                        'ECG Report',
                        style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 16), fontWeight: FontWeight.w600,color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.backgroundcolor,
                          thickness: 1,
                        ),
                      ),
                    ],),
            */
                  /*      SizedBox(height: 10,),
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
*/
/*
                  SizedBox(height: 10,),

                  SizedBox(
            width: double.infinity,
                      child: FormInput(label: 'Findings',controller: _ecgFindingController,maxlength: 2,)),
                  SizedBox(height: 10,),

                  Row(

                    children: [
                      Text(
                        '2D ECHO Report',
                        style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 16), fontWeight: FontWeight.w600,color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.backgroundcolor,
                          thickness: 1,
                        ),
                      ),
                    ],),
                  SizedBox(height: 10,),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings',controller:_a2dFindingController,maxlength: 2,)),
               */
                  /*   SizedBox(height: 10,),
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
                      child: FormInput(label: 'Findings',controller: _echoFindingsController,)),*/ /*
             */ /*     SizedBox(height: 10,),
                  Row(

                    children: [
                      Text(
                        'PFT Report',
                        style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 16), fontWeight: FontWeight.w600,color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.backgroundcolor,
                          thickness: 1,
                        ),
                      ),
                    ],),*/ /*
             */ /*     SizedBox(height: 10,),
                  SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings',controller: _pftFindingController,)),*/ /*
                  SizedBox(height: 10),
                  Row(

                    children: [
                      Text(
                        'Miscellaneous',
                        style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 16), fontWeight: FontWeight.w600,color: AppColors.hinttext),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.backgroundcolor,
                          thickness: 1,
                        ),
                      ),
                    ],),*/
                  SizedBox(
                    height: 10,
                  ),
                  DocumentUploadWidget(
                    docType:
                        'miscellaneous_report', // This should match one of your map keys
                    label: "Upload Reports",
                    onFilesSelected: (files) async {
                      setState(() {
                        _uploadedFiles['miscellaneous_report'] = files;
                      });
                    },

                    initialFiles: _uploadedFiles['miscellaneous_report'],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  /*         SizedBox(
                      width: double.infinity,
                      child: FormInput(label: 'Findings',controller: _miscFindingController,)),
                  SizedBox(height: 10,),*/
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
                  Text(
                    '2. Doctor Notes',
                    style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 18),
                        fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FormInput(
                      label: 'Final Diagnosis',
                      hintlabel: "Text",
                      maxlength: 5,
                      controller: _doctorNotesController,
                    ),
                  ),
                  SizedBox(height: 20),
                  DocumentUploadWidget(
                    docType: 'patient_treatment',
                    label: "Prescription Upload",
                    onFilesSelected: (files) {
                      setState(() {
                        _uploadedFiles['patient_treatment'] = files;
                      });
                    },
                    initialFiles: _uploadedFiles['patient_treatment'],
                  ),
                  SizedBox(height: 16),

                  /*     // Medication Table
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Treatment Prescribed',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: ResponsiveUtils.fontSize(context, 14),
                            ),
                          ),
                          Tooltip(
                            message: 'Tap to Add Row',
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () => _addMedicationRow(),
                              icon: Icon(Icons.add_box_rounded, size: 26, color: AppColors.secondary),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: AppColors.secondary),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          )

                        ],
                      ),
                      SizedBox(height: 10),

                      // Excel-like Table
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Patient Name: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                              fontSize: ResponsiveUtils.fontSize(context, 14),
                                            ),
                                          ),
                                          Text(
                                            '${_firstNameController.text} ${_lastNameController.text}',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),

                                      SizedBox(width: 20),
                                      Row(
                                        children: [
                                          Text(
                                            'Age: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                              fontSize: ResponsiveUtils.fontSize(context, 14),
                                            ),
                                          ),
                                          Text(
                                            '${_ageController.text} years',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FormInput(
                                          controller: _docQualificationController,
                                          label: 'Doctor Qualification',
                                          hintlabel: 'Enter Doctor Qualification',

                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: FormInput(
                                          controller: _registrationNumberController,
                                          label: 'Registration Number',
                                          hintlabel: 'Enter Registration Numbers',

                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Table Header
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    _buildHeaderCell('Sr No', 60),
                                    Expanded(
                                      flex: 3,
                                      child: _buildHeaderCell('Name of Medication'),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: _buildHeaderCell('Dosage'),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: _buildHeaderCell('Frequency'),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: _buildHeaderCell('Duration'),
                                    ),
                                    _buildHeaderCell('Action', 80),
                                  ],
                                ),
                              ),
                            ),

                            // Table Rows
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _medNameControllers.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                    border: Border(
                                      bottom: BorderSide(

                                          color: index == _medNameControllers.length - 1
                                              ? Colors.transparent
                                              : Colors.grey.shade300
                                      ),
                                    ),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        _buildCell(
                                            Center(child: Text('${index + 1}')),
                                            width: 60
                                         ),
                                        Expanded(
                                          flex: 3,
                                          child: _buildCell(
                                            TextFormField(
                                              controller: _medNameControllers[index],
                                              decoration: InputDecoration(
                                                hintText: 'Enter medication',
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: _buildCell(
                                            TextFormField(
                                              controller: _medDosageControllers[index],
                                              decoration: InputDecoration(
                                                hintText: 'Dosage',
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: _buildCell(
                                            TextFormField(
                                              controller: _medFrequencyControllers[index],
                                              decoration: InputDecoration(
                                                hintText: 'Frequency',
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: _buildCell(
                                            TextFormField(
                                              controller: _medDurationControllers[index],
                                              decoration: InputDecoration(
                                                hintText: 'Duration',
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        _buildCell(
                                            Center(
                                              child: IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: _medNameControllers.length > 1
                                                        ? Colors.red
                                                        : Colors.grey),
                                                onPressed: _medNameControllers.length > 1
                                                    ? () => _removeMedicationRow(index)
                                                    : null,
                                              ),
                                            ),
                                            width: 80
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),



                    ],
                  ),

*/

                  SizedBox(height: 20),
                  DatePickerInput(
                    label: 'Follow up date',
                    hintlabel: 'Follow up date',
                    onDateSelected: (date) {
                      setState(() {
                        _followUpDate = date;
                      });
                    },
                    initialDate: _followUpDate,
                  ),
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
                  Text(
                    '3. Misc',
                    style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 18),
                        fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  /*  SizedBox(
                  width: double.infinity,
                  child: FormInput(label: 'Text',hintlabel: "Text",maxlength: 5,controller: _miscLaboratoryController,)),

                SizedBox(height: 10,),*/
                  DocumentUploadWidget(
                    docType: 'misc_report',
                    label: "Miscellaneous Upload",
                    onFilesSelected: (files) {
                      setState(() async {
                        _uploadedFiles['misc_report'] = files;
                        print("_uploadedFiles['misc_report']");
                        print(_uploadedFiles['misc_report']);

                        for (var file in files) {
                          final fileName = file['name'];
                          if (fileName != null && !file['isExisting']) {
                            await _onFileSelected(fileName);
                          }
                        }
                      });
                    },
                    initialFiles: _uploadedFiles['misc_report'],
                    miscReportTagging: miscReportTagging,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildFormNavigationButtons(isLastStep: true),
          ],
        ),
      ),
    );
  }
}




class FormInput extends StatelessWidget {
  final String label;
  final String hintlabel;
  final bool isDate;
  final int maxlength;
  final int maxcount;
  final Color fillColor;
  final TextEditingController? controller;
  final String? value; // Add this
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final Function(String)? onChanged;
  final bool useCamelCase;

  const FormInput({
    super.key,
    required this.label,
    this.maxlength = 1,
    this.maxcount = 200,
    this.isDate = false,
    this.hintlabel = "",
    this.fillColor = Colors.white,
    this.controller,
    this.value, // Add this
    this.inputFormatters,
    this.readOnly = false,
    this.onChanged,
    this.useCamelCase = true,
  });

  String _toCamelCase(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double fieldWidth;

    if (screenWidth < 600) {
      fieldWidth = double.infinity;
    } else if (screenWidth < 1200) {
      fieldWidth = screenWidth * 0.45;
    } else if (screenWidth == 1440) {
      fieldWidth = 250;
    } else if (screenWidth >= 1300 && screenWidth <= 1370) {
      fieldWidth = screenWidth * 0.14; // 233px at 1366px width
    } else {
      fieldWidth = 275;
    }

    return SizedBox(
      width: fieldWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            useCamelCase ? _toCamelCase(label) : label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: ResponsiveUtils.fontSize(context, 14),
            ),
          ),
          const SizedBox(height: 4),

          // If value is provided, show as display field
          if (value != null && readOnly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                value!,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                  color: Colors.black87,
                ),
              ),
            )
          // Otherwise use the CustomTextField
          else
            CustomTextField(
              fillColor: fillColor,
              enabled: !readOnly,
              maxLines: maxlength,
              multiline: true,
              maxLength: maxcount,
              controller: controller ?? TextEditingController(),
              hintText: hintlabel,
              keyboardType: TextInputType.text,
              inputFormatters: inputFormatters,
              textInputAction: TextInputAction.next,
              validator: (value) => null,
              readOnly: readOnly,
              onChanged: onChanged,
              useCamelCase: useCamelCase,
            ),
        ],
      ),
    );
  }
}
