import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PatientFormScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final int patientExist;
  final String phid;

  const PatientFormScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.patientExist,
    required this.phid,
  }) : super(key: key);

  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  int _currentStep = 0;
  final GlobalKey<FormState> _personalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _medicalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reportsFormKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isLoadingLocations = false;
  List<Map<String, dynamic>> _locations = [];

  // Document type mapping
  final Map<int, String> _documentTypes = {
    1: 'Blood Reports',
    2: 'X-Ray Reports',
    3: 'ECG Reports',
    4: 'CT Scan Reports',
    5: 'Echocardiogram Reports',
    6: 'Miscellaneous Reports',
    7: 'P/R Images',
    8: 'P/A Abdomen Images',
    9: 'P/R Rectum Images',
    10: 'Doctor Notes Images',
  };

  // File Management
  final Map<int, List<Map<String, dynamic>>> _uploadedFiles = {};
  List<Map<String, dynamic>> _newFilesToUpload = [];

  // Patient Data
  Map<String, dynamic>? _patientData;
  Map<String, dynamic>? _visitData;
  Map<String, dynamic>? _documentData;

  // Personal Information Controllers
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
  final TextEditingController _otherIllnessController = TextEditingController();
  final TextEditingController _surgicalHistoryController =
      TextEditingController();
  final TextEditingController _drugAllergyController = TextEditingController();
  bool _hasDM = false;
  bool _hasHypertension = false;
  bool _hasIHD = false;
  bool _hasCOPD = false;
  final TextEditingController _ihdDescriptionController =
      TextEditingController();
  final TextEditingController _copdDescriptionController =
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
  bool _isFebrile = false;
  bool _hasPallor = false;
  bool _hasIcterus = false;
  bool _hasOedema = false;
  bool _hasLymphadenopathy = false;

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

  @override
  void initState() {
    super.initState();
    _phIdController.text = 'PH-${widget.phid}';
    _firstNameController.text = widget.firstName;
    _lastNameController.text = widget.lastName;
    _phoneController.text = widget.phone;

    // Initialize document type categories
    _documentTypes.forEach((key, value) {
      _uploadedFiles[key] = [];
    });

    _fetchLocations();
    if (widget.patientExist == 2) {
      _fetchPatientData();
    }
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
              _location = _locations.first['location'];
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load locations')),
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
        log(' data$data');
        if (data['status'] == true) {
          // Safely handle the response structure
          final responseData = data['data'];

          if (responseData is List && responseData.isNotEmpty) {
            final firstDataItem = responseData[0];

            setState(() {
              // Handle patient data
              if (firstDataItem['patient'] is List &&
                  firstDataItem['patient'].isNotEmpty) {
                _patientData =
                    firstDataItem['patient'][0] as Map<String, dynamic>;
              } else {
                _patientData = {};
              }

              // Handle visit info
              if (firstDataItem['PatientVisitInfo'] is List &&
                  firstDataItem['PatientVisitInfo'].isNotEmpty) {
                _visitData = firstDataItem['PatientVisitInfo'][0]
                    as Map<String, dynamic>;
              } else {
                _visitData = {};
              }

              // Handle documents
              if (firstDataItem['PatientDocumentInfo'] is Map) {
                _documentData = firstDataItem['PatientDocumentInfo']
                    as Map<String, dynamic>;
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
        SnackBar(
            content: Text('Error loading patient data: ${error.toString()}')),
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
      _isFebrile = (_visitData?['temp']?.toString() ?? '') == '98.6';
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

      // Load documents
      _documentData?.forEach((typeId, files) {
        try {
          final typeIdInt = int.tryParse(typeId.toString()) ?? 0;
          if (_uploadedFiles.containsKey(typeIdInt) && files is List) {
            _uploadedFiles[typeIdInt] = files.map<Map<String, dynamic>>((file) {
              return {
                ...file is Map ? file as Map<String, dynamic> : {},
                'typeId': typeIdInt,
                'name': path.basename(file['media_url']?.toString() ?? ''),
                'type': path
                    .extension(file['media_url']?.toString() ?? '')
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

  Future<void> _uploadFile(int typeId, String source) async {
    try {
      File? savedFile;
      String? originalName;

      if (source == 'camera' || source == 'gallery') {
        final pickedFile = await _picker.pickImage(
          source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 90,
        );

        if (pickedFile != null) {
          savedFile = File(pickedFile.path);
          originalName = path.basename(pickedFile.path);
        }
      } else if (source == 'file') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );

        if (result != null && result.files.single.path != null) {
          savedFile = File(result.files.single.path!);
          originalName = result.files.single.name;
        }
      }

      if (savedFile != null) {
        final fileSize = (await savedFile.length()) / 1024;
        final fileType =
            path.extension(savedFile.path).replaceAll('.', '').toUpperCase();

        setState(() {
          _newFilesToUpload.add({
            'file': savedFile,
            'name': originalName ?? path.basename(savedFile!.path),
            'size': fileSize.toStringAsFixed(1),
            'type': fileType,
            'typeId': typeId,
            'isNew': true,
          });

          _uploadedFiles[typeId]?.add({
            'file': savedFile,
            'name': originalName ?? path.basename(savedFile!.path),
            'size': fileSize.toStringAsFixed(1),
            'type': fileType,
            'typeId': typeId,
            'isNew': true,
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeFile(int typeId, Map<String, dynamic> file) async {
    try {
      setState(() {
        if (file['isNew'] == true) {
          _newFilesToUpload.removeWhere((f) => f['name'] == file['name']);
        }
        _uploadedFiles[typeId]?.remove(file);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete file: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_personalInfoFormKey.currentState!.validate() ||
        !_medicalInfoFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Prepare patient data
      final patientData = {
        'phid': _phIdController.text.replaceAll('PH-', ''),
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'gender': _gender == 'Male' ? 1 : 2,
        'mobile_no': _phoneController.text,
        'alternative_no': _altPhoneController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'referral_by': _referralController.text,
        'location': _locations.firstWhere(
          (loc) => loc['location'] == _location,
          orElse: () => _locations.first,
        )['id'],
        'doctor_note': _doctorNotesController.text,
      };

      // Prepare visit data
      final visitData = {
        'age': int.tryParse(_ageController.text) ?? 0,
        'height': _heightController.text,
        'weight': _weightController.text,
        'bmi': _bmiController.text,
        'rbs': int.tryParse(_rbsController.text) ?? 0,
        'chief_complaints': _complaintsController.text,
        'history_of_dm_status': _hasDM ? 1 : 0,
        'history_of_dm_description': _dmSinceController.text,
        'hypertension_status': _hasHypertension ? 1 : 0,
        'hypertension_description': _hypertensionSinceController.text,
        'IHD_status': _hasIHD ? 1 : 0,
        'IHD_description': _ihdDescriptionController.text,
        'COPD_status': _hasCOPD ? 1 : 0,
        'COPD_description': _copdDescriptionController.text,
        'any_other_illness': _otherIllnessController.text,
        'past_surgical_history': _surgicalHistoryController.text,
        'drug_allergy': _drugAllergyController.text,
        'temp': _isFebrile ? '98.6' : '',
        'pulse': int.tryParse(_pulseController.text) ?? 0,
        'bp_systolic': int.tryParse(_bpSystolicController.text) ?? 0,
        'bp_diastolic': int.tryParse(_bpDiastolicController.text) ?? 0,
        'pallor': _hasPallor ? 1 : 0,
        'icterus': _hasIcterus ? 1 : 0,
        'oedema_status': _hasOedema ? 1 : 0,
        'oedema_description': _oedemaDetailsController.text,
        'lymphadenopathy':
            _hasLymphadenopathy ? _lymphadenopathyDetailsController.text : '',
        'HO_present_medication': _currentMedicationController.text,
        'respiratory_system': _rsController.text,
        'cardio_vascular_system': _cvsController.text,
        'central_nervous_system': _cnsController.text,
        'pa_abdomen': _paAbdomenController.text,
        'pr_rectum': _prRectumController.text,
        'local_examination': _localExamController.text,
        'clinical_diagnosis': _diagnosisController.text,
        'comorbidities': _comorbiditiesController.text,
        'plan': _planController.text,
        'advise': _adviseController.text,
      };

      // Upload new files
      for (final file in _newFilesToUpload) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://pooja-healthcare.ortdemo.com/api/uploadDocument'),
        );

        request.fields['patient_id'] = _patientData?['id']?.toString() ?? '';
        request.fields['visit_id'] = _visitData?['id']?.toString() ?? '';
        request.fields['doc_type_id'] = file['typeId'].toString();

        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file['file'].path,
          filename: file['name'],
        ));

        final response = await request.send();
        if (response.statusCode != 200) {
          throw Exception('Failed to upload file ${file['name']}');
        }
      }

      // Update patient and visit data
      final patientResponse = await http.post(
        Uri.parse('https://pooja-healthcare.ortdemo.com/api/updatePatient'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': _patientData?['id'],
          ...patientData,
          'visit_data': visitData,
        }),
      );

      if (patientResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient record saved successfully')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save patient data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Reports & Documents'),
        const SizedBox(height: 20),

        // Regular reports (types 1-6)
        ..._documentTypes.entries.where((e) => e.key <= 6).map((entry) {
          return Column(
            children: [
              _buildEnhancedUploadCard(
                title: entry.value,
                typeId: entry.key,
                files: _uploadedFiles[entry.key] ?? [],
              ),
              const SizedBox(height: 16),
            ],
          );
        }),

        // Examination images
        _buildSectionHeader('Examination Images', level: 2),
        const SizedBox(height: 16),

        // PR Rectum Images (type 9)
        _buildImageUploadCard(
          title: 'P/R Rectum Images',
          typeId: 9,
          files: _uploadedFiles[9] ?? [],
        ),
        const SizedBox(height: 16),

        // P/A Abdomen Images (type 8)
        _buildImageUploadCard(
          title: 'P/A Abdomen Images',
          typeId: 8,
          files: _uploadedFiles[8] ?? [],
        ),
        const SizedBox(height: 16),

        // PR Images (type 7)
        _buildImageUploadCard(
          title: 'P/R Images',
          typeId: 7,
          files: _uploadedFiles[7] ?? [],
        ),
        const SizedBox(height: 24),

        // Doctor Notes
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

  Widget _buildEnhancedUploadCard({
    required String title,
    required int typeId,
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
            SizedBox(
              width: double.infinity,
              child: PopupMenuButton<String>(
                onSelected: (source) => _uploadFile(typeId, source),
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
              ...files.map((file) => _buildFileItem(typeId, file)).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard({
    required String title,
    required int typeId,
    required List<Map<String, dynamic>> files,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
            onSelected: (source) => _uploadFile(typeId, source),
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
                  leading: Icon(Icons.photo_library, color: AppColors.primary),
                  title: const Text('Choose from Gallery'),
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Upload Image',
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
          const SizedBox(height: 8),
          Text(
            'Uploaded Images:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...files.map((file) => _buildFileItem(typeId, file)).toList(),
        ],
      ],
    );
  }

  Widget _buildFileItem(int typeId, Map<String, dynamic> file) {
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
            onPressed: () => _removeFile(typeId, file),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
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

  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          controller: _altPhoneController,
          label: 'Alternative Phone Number',
          keyboardType: TextInputType.phone,
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
        _buildCustomInput(
          controller: _descriptionController,
          label: 'Description',
          minLines: 2,
          maxLines: 3,
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
        _isLoadingLocations
            ? _buildCustomInput(
                controller: TextEditingController(text: 'Loading locations...'),
                label: 'Location',
                enabled: false,
              )
            : _buildCustomDropdown<String>(
                value: _location,
                items:
                    _locations.map((loc) => loc['location'] as String).toList(),
                label: 'Location',
                onChanged: (value) => setState(() => _location = value!),
              ),
      ],
    );
  }

  Widget _buildMedicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Medical Information'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildCustomInput(
                controller: _heightController,
                label: 'Height (cm)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCustomInput(
                controller: _weightController,
                label: 'Weight (kg)',
                keyboardType: TextInputType.number,
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
            label: 'DM Description',
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
            label: 'Hypertension Description',
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
        _buildCustomInput(
          controller: _prRectumController,
          label: 'P/R Rectum',
          minLines: 3,
          maxLines: 5,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Record'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStepNavigation(),
                Expanded(
                  child: IndexedStack(
                    index: _currentStep,
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _personalInfoFormKey,
                          child: _buildPersonalDetails(),
                        ),
                      ),
                      SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _medicalInfoFormKey,
                          child: _buildMedicalDetails(),
                        ),
                      ),
                      SingleChildScrollView(
                        controller: _scrollController,
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
                          onPressed: () => setState(() => _currentStep--),
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
