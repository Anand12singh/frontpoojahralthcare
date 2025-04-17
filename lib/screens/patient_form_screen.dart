import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:poojaheakthcare/screens/patient_info_screen.dart';
import 'package:poojaheakthcare/screens/video_open.dart';
import '../constants/global_variable.dart';
import '../services/auth_service.dart';
import '../widgets/show_dialog.dart';
import '../utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/foundation.dart' as foundation;

// web_specific.dart

class PatientFormScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final int patientExist;
  final int? patientId;
  final String phid;

  const PatientFormScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.patientExist,
    required this.phid,
    this.patientId,
  }) : super(key: key);

  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
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

  final Map<String, List<String>> _deletedFiles = {};
  int _currentStep = 0;
  final GlobalKey<FormState> _personalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _medicalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reportsFormKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedLocationId = '2';
  String _selectedLocationName = '';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _phIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _gender = 'Male';
  DateTime _selectedDate = DateTime.now();
  String _location = 'Pooja Healthcare';

  // Medical Information Controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _rbsController = TextEditingController();
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

  // Systems Review Controllers
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

  // Other state variables
  bool _isLoadingLocations = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _locations = [];
  String? locationId = '2';
  Map<String, dynamic>? _patientData;
  Map<String, dynamic>? _visitData;
  var _documentData;

  // File Management
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
  void initState() {
    super.initState();
    _phIdController.text = 'PH-${Global.phid1}';
    _firstNameController.text = widget.firstName;
    _lastNameController.text = widget.lastName;
    _phoneController.text = widget.phone;

    if (widget.patientExist == 2) {
      _fetchPatientData();
    }

    _fetchLocations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Dispose all controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _phIdController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _referralController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _rbsController.dispose();
    _complaintsController.dispose();
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
      // Replace this:
      locationId = _patientData?['location']?.toString() ?? '2';
      if (_visitData?['temp'] != null ||
          _visitData?['temp'].isNotEmpty ||
          _visitData?['temp'] != "null") {
        _isFebrile = true;
      }

// With this:
      _selectedLocationId = _patientData?['location']?.toString() ?? '2';
// Find the corresponding location name
      final location = _locations.firstWhere(
        (loc) => loc['id'].toString() == _selectedLocationId,
        orElse: () => {'id': '2', 'location': 'Unknown'},
      );
      _selectedLocationName = location['location'] ?? 'Unknown';

      // Load documents
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

  void _initializeWithEmptyData() {
    setState(() {
      _patientData = {
        'phid': Global.phid,
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'mobile_no': widget.phone
      };
      _visitData = {};
      _documentData = {};
      _populateFormFields();
    });
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoadingLocations = true);
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

  final Map<String, int> _reverseDocTypeMapping = {
    'blood_reports': 1,
    'xray_report': 2,
    'ecg_report': 3,
    'ct_scan_report': 4,
    'echocardiagram_report': 5,
    'misc_report': 6,
    'pr_image': 7,
    'pa_abdomen_image': 8,
    'pr_rectum_image': 9,
    'doctor_note_image': 10,
  };

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
        'status': Global.status ?? widget.patientId.toString(),
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

  bool _validateFiles() {
    for (var entry in _uploadedFiles.entries) {
      for (var file in entry.value) {
        if (file['isExisting'] != true) {
          if (kIsWeb) {
            if (file['bytes'] == null || file['name'] == null) {
              return false;
            }
          } else {
            if (file['path'] == null || !File(file['path']).existsSync()) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  Future<void> _handleFileSelection(String fileType, String source) async {
    try {
      if (!mounted) return;

      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          withData: true,
          allowMultiple: true,
        );

        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _uploadedFiles[fileType] ??= [];
            _uploadedFiles[fileType]!.add({
              'name': result.files.single.name,
              'bytes': result.files.single.bytes!,
              'type': path
                  .extension(result.files.single.name)
                  .replaceAll('.', '')
                  .toLowerCase(),
              'isExisting': false,
            });
          });
        }
      } else {
        // Mobile handling
        File? file;
        String? fileName;

        if (source == 'camera' || source == 'gallery') {
          final XFile? image = await ImagePicker().pickImage(
              source: source == 'camera'
                  ? ImageSource.camera
                  : ImageSource.gallery);
          if (image != null) {
            file = File(image.path);
            fileName = path.basename(image.path);
          }
        } else if (source == 'file') {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: [
                'pdf',
                'jpg',
                'jpeg',
                'png',
                // 'mp4',
                // 'mov',
                // 'avi'
              ],
              allowMultiple: true);
          if (result != null && result.files.single.path != null) {
            file = File(result.files.single.path!);
            fileName = result.files.single.name;
          }
        }

        if (file != null) {
          setState(() {
            _uploadedFiles[fileType] ??= [];
            _uploadedFiles[fileType]!.add({
              'path': file!.path,
              'name': fileName ?? 'Document',
              'type':
                  path.extension(file.path).replaceAll('.', '').toLowerCase(),
              'isExisting': false,
            });
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeFile(String reportType, Map<String, dynamic> file) async {
    try {
      if (file['isExisting'] == true) {
        // Track deleted existing files
        _deletedFiles[reportType] ??= [];
        _deletedFiles[reportType]!.add(file['id'].toString());
      } else {
        // Delete newly uploaded files
        final fileToDelete = File(file['path']);
        if (await fileToDelete.exists()) {
          await fileToDelete.delete();
        }
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

  // Helper functions
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

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  // UI Components
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
    bool enableNewLines = false,
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
                              style: TextStyle(color: AppColors.error))
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide:
                      const BorderSide(color: AppColors.error, width: 1.5),
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
              keyboardType:
                  enableNewLines ? TextInputType.multiline : keyboardType,
              minLines: minLines,
              maxLines: enableNewLines
                  ? null
                  : maxLines, // Allow unlimited lines if enableNewLines is true
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
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
                        padding: const EdgeInsets.only(right: 30),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<T>(
                              value: option.key,
                              groupValue: groupValue,
                              onChanged: onChanged,
                              visualDensity:
                                  const VisualDensity(horizontal: -1),
                            ),
                            const SizedBox(width: 4),
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

  void _showFilePreview(BuildContext context, String filePath, String fileType,
      {bool isNetwork = false}) async {
    // final String lowerFileType = fileType.toLowerCase();
    if (['jpg', 'jpeg', 'png', "webp"].contains(fileType.toLowerCase())) {
      // Image Preview
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: isNetwork
                    ? Image.network(
                        filePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text('Failed to load image',
                              style: TextStyle(color: Colors.red)),
                        ),
                      )
                    : (kIsWeb
                        ? Image.memory(
                            base64Decode(filePath.split(',').last),
                            fit: BoxFit.contain,
                          )
                        : Image.file(
                            File(filePath),
                            fit: BoxFit.contain,
                          )),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (fileType.toLowerCase() == 'pdf') {
      // PDF Preview
      if (kIsWeb) {
        // Web: Use url_launcher instead of html.window.open
        if (await canLaunchUrl(Uri.parse(filePath))) {
          await launchUrl(Uri.parse(filePath),
              mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open PDF')),
          );
        }
      } else {
        // Mobile: Use Syncfusion PDF Viewer
        try {
          String localPath = filePath;
          if (isNetwork) {
            final dir = await getTemporaryDirectory();
            final file = File('${dir.path}/temp.pdf');
            final response = await http.get(Uri.parse(filePath));
            await file.writeAsBytes(response.bodyBytes);
            localPath = file.path;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('PDF Preview')),
                body: SfPdfViewer.file(File(localPath)),
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load PDF: ${e.toString()}')),
          );
        }
      }
//     }
//      else if (['mp4', 'mov', 'avi'].contains(lowerFileType)) {
//       if (kIsWeb) {
//         // Web handling - open in new tab
//         if (await canLaunchUrl(Uri.parse(filePath))) {
//           await launchUrl(Uri.parse(filePath),
//               mode: LaunchMode.externalApplication);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Could not open video')),
//           );
//         }
//       } else {

//         try {

//           await Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => Scaffold(
//       appBar: AppBar(title: Text('Video Preview')),
//       body: Center(
//         child: VideoPlayerWidget(
//           videoUrl: filePath,  // Use videoUrl instead of videoPath
//           isNetwork: isNetwork, // Explicitly specify if it's a network URL
//         ),
//       ),
//     ),
//   ),
// );
//         } catch (e) {

//           debugPrint('In-app video player failed: $e');
//           if (await canLaunchUrl(Uri.parse(filePath))) {
//             await launchUrl(Uri.parse(filePath));
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Could not open video')),
//             );
//           }
//         }
//       }
    } else {
      log('Preview not available for $fileType files');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preview not available for $fileType files')),
      );
    }
  }

  Widget _buildFileItem(String reportType, Map<String, dynamic> file) {
    final fileType = (file['type'] ?? '').toLowerCase();
    final isExisting = file['isExisting'] == true;
    final filePath = file['path'] ?? '';
    final fileName = file['name'] ?? 'Unknown';

    return GestureDetector(
      onTap: () {
        if (isExisting) {
          _showFilePreview(context, filePath, fileType, isNetwork: true);
        } else {
          if (kIsWeb) {
            // For web, we might have the file data in bytes
            if (file['bytes'] != null) {
              final base64String = base64Encode(file['bytes']);
              _showFilePreview(
                  context,
                  'data:application/octet-stream;base64,$base64String',
                  fileType);
            } else {
              _showFilePreview(context, filePath, fileType);
            }
          } else {
            _showFilePreview(context, filePath, fileType);
          }
        }
      },
      child: Container(
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
                _getFileIcon(fileType),
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
                    fileName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        fileType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (isExisting)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Existing',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ),
                    ],
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
      ),
    );
  }

  Widget _buildEnhancedUploadCard({
    required String title,
    required List<Map<String, dynamic>> files,
    required String fileType,
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
            SizedBox(
              width: double.infinity,
              child: PopupMenuButton<String>(
                onSelected: (source) => _handleFileSelection(fileType, source),
                itemBuilder: (context) => [
                  if (!kIsWeb) ...[
                    // Only show these options on mobile
                    PopupMenuItem(
                      value: 'camera',
                      child: ListTile(
                        leading:
                            Icon(Icons.camera_alt, color: AppColors.primary),
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
                  ],
                  // Show file option on both web and mobile
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
              ...files.map((file) => _buildFileItem(fileType, file)).toList(),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.03),
          ],
        ),
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
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
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
          enableNewLines: true,
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
          value: _selectedLocationName, // Show the name, not the ID
          items: _locations.map((loc) => loc['location'].toString()).toList(),
          label: 'Location',
          onChanged: (value) {
            if (value != null) {
              final selectedLoc = _locations.firstWhere(
                (loc) => loc['location'] == value,
                orElse: () => {'id': '1', 'location': 'Unknown'},
              );
              setState(() {
                _selectedLocationName = value;
                _selectedLocationId = selectedLoc['id'].toString();
              });
            }
          },
        )
      ],
    );
  }

  Widget _buildMedicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader('Medical Information'),
        const SizedBox(height: 20),

        // Physical Measurements
        Row(
          children: [
            Expanded(
              child: _buildCustomInput(
                controller: _heightController,
                label: 'Height (ft.in)',
                hintText: 'e.g. 5.11 for 5ft 11in',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _calculateBMI(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCustomInput(
                controller: _weightController,
                label: 'Weight (kg)',
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateBMI(),
              ),
            ),
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

        // Chief Complaints
        _buildCustomInput(
          controller: _complaintsController,
          label: 'Chief Complaints',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),

        // Medical History
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

        _buildRadioGroup<bool>(
          label: 'IHD:',
          groupValue: _hasIHD,
          options: const [
            MapEntry(true, 'Yes'),
            MapEntry(false, 'No'),
          ],
          onChanged: (value) => setState(() => _hasIHD = value!),
        ),
        if (_hasIHD)
          _buildCustomInput(
            controller: _ihdDescriptionController,
            label: 'IHD Description',
          ),

        _buildRadioGroup<bool>(
          label: 'COPD:',
          groupValue: _hasCOPD,
          options: const [
            MapEntry(true, 'Yes'),
            MapEntry(false, 'No'),
          ],
          onChanged: (value) => setState(() => _hasCOPD = value!),
        ),
        if (_hasCOPD)
          _buildCustomInput(
            controller: _copdDescriptionController,
            label: 'COPD Description',
          ),

        _buildCustomInput(
          controller: _otherIllnessController,
          label: 'Any other illness',
          minLines: 2,
          maxLines: 3,
          enableNewLines: true,
        ),
        _buildCustomInput(
          controller: _surgicalHistoryController,
          label: 'Past Surgical History',
          minLines: 2,
          maxLines: 3,
          enableNewLines: true,
        ),
        _buildCustomInput(
          controller: _drugAllergyController,
          label: 'H/O Drug Allergy',
          minLines: 2,
          maxLines: 3,
          enableNewLines: true,
        ),

        // General Examination
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

        if (_isFebrile)
          _buildCustomInput(
            controller: _tempController,
            label: 'Temperature',
            keyboardType: TextInputType.number,
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
          enableNewLines: true,
        ),

        // Systems Review
        _buildSectionHeader('Systems Review', level: 2),
        _buildCustomInput(
          controller: _rsController,
          label: 'Respiratory System (RS)',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
        _buildCustomInput(
          controller: _cvsController,
          label: 'Cardiovascular System (CVS)',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
        _buildCustomInput(
          controller: _cnsController,
          label: 'Central Nervous System (CNS)',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),

        // PA Abdomen Section
        _buildCustomInput(
          controller: _paAbdomenController,
          label: 'P/A Abdomen Findings',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(
              width: double.infinity,
              child: PopupMenuButton<String>(
                onSelected: (source) =>
                    _handleFileSelection('pa_abdomen_image', source),
                itemBuilder: (context) => [
                  if (!kIsWeb) ...[
                    // Only show these options on mobile
                    PopupMenuItem(
                      value: 'camera',
                      child: ListTile(
                        leading:
                            Icon(Icons.camera_alt, color: AppColors.primary),
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
                  ],
                  // Show file option on both web and mobile
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
                        'Upload PA Abdomen Document',
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
            if (_uploadedFiles['pa_abdomen_image']?.isNotEmpty ?? false)
              Column(
                children: [
                  Text(
                    'Uploaded PA Documents:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._uploadedFiles['pa_abdomen_image']!
                      .map((file) => _buildFileItem('pa_abdomen_image', file))
                      .toList(),
                ],
              ),
          ],
        ),

        // PR Rectum Section
        _buildCustomInput(
          controller: _prRectumController,
          label: 'P/R Rectum Findings',
          minLines: 3,
          maxLines: 5,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(
              width: double.infinity,
              child: PopupMenuButton<String>(
                onSelected: (source) =>
                    _handleFileSelection('pr_rectum_image', source),
                itemBuilder: (context) => [
                  if (!kIsWeb) ...[
                    // Only show these options on mobile
                    PopupMenuItem(
                      value: 'camera',
                      child: ListTile(
                        leading:
                            Icon(Icons.camera_alt, color: AppColors.primary),
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
                  ],
                  // Show file option on both web and mobile
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
                        'Upload PR Rectum Document',
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
            if (_uploadedFiles['pr_rectum_image']?.isNotEmpty ?? false)
              Column(
                children: [
                  Text(
                    'Uploaded PR Documents:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._uploadedFiles['pr_rectum_image']!
                      .map((file) => _buildFileItem('pr_rectum_image', file))
                      .toList(),
                ],
              ),
          ],
        ),

        // Local Examination
        _buildCustomInput(
          controller: _localExamController,
          label: 'Local Examination',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),

        // Diagnosis and Plan
        _buildCustomInput(
          controller: _diagnosisController,
          label: 'Clinical Diagnosis',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
        _buildCustomInput(
          controller: _comorbiditiesController,
          label: 'Comorbidities',
          minLines: 2,
          maxLines: 3,
          enableNewLines: true,
        ),
        _buildCustomInput(
          controller: _planController,
          label: 'Plan',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
        _buildCustomInput(
          controller: _adviseController,
          label: 'Advise',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
      ],
    );
  }

  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader('Reports & Documents'),
        const SizedBox(height: 20),
        _buildEnhancedUploadCard(
          title: 'Blood Reports',
          files: _uploadedFiles['blood_reports'] ?? [],
          fileType: 'blood_reports',
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'X-Ray Reports',
          files: _uploadedFiles['xray_report'] ?? [],
          fileType: 'xray_report',
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'CT Scan Reports',
          files: _uploadedFiles['ct_scan_report'] ?? [],
          fileType: 'ct_scan_report',
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'ECG Reports',
          files: _uploadedFiles['ecg_report'] ?? [],
          fileType: 'ecg_report',
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'Echocardiogram Reports',
          files: _uploadedFiles['echocardiagram_report'] ?? [],
          fileType: 'echocardiagram_report',
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'Miscellaneous Reports',
          files: _uploadedFiles['misc_report'] ?? [],
          fileType: 'misc_report',
        ),
        const SizedBox(height: 16),
        _buildEnhancedUploadCard(
          title: 'Doctor Note Images',
          files: _uploadedFiles['doctor_note_image'] ?? [],
          fileType: 'doctor_note_image',
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Doctor Notes', level: 2),
        _buildCustomInput(
          controller: _doctorNotesController,
          label: 'Clinical findings and recommendations',
          minLines: 5,
          maxLines: 10,
          enableNewLines: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: MediaQuery.of(context).viewInsets.bottom == 0
          ? null
          : Row(
              children: [
                const Spacer(),
                TextButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: const Text("Done"))
              ],
            ),
      appBar: AppBar(
        title: const Text('Patient Record'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: 800, minHeight: constraints.maxHeight),
            child: Column(
              children: [
                _buildStepNavigation(),
                Expanded(
                  child: IndexedStack(
                    index: _currentStep,
                    children: [
                      // Personal Information
                      SingleChildScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _personalInfoFormKey,
                          child: _buildPersonalDetails(),
                        ),
                      ),
                      // Medical Information
                      SingleChildScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _medicalInfoFormKey,
                          child: _buildMedicalDetails(),
                        ),
                      ),
                      // Reports & Documents
                      SingleChildScrollView(
                        controller: _scrollController,
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        AppColors.primary.withOpacity(0.03),
                      ],
                    ),
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
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
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
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
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
          ),
        );
      }),
    );
  }
}
