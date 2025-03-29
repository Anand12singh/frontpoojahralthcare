import 'package:flutter/material.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class PatientFormScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final int patientExist;
  final String phid;
  const PatientFormScreen(
      {Key? key,
      required this.firstName,
      required this.lastName,
      required this.phone,
      required this.patientExist,
      required this.phid})
      : super(key: key);

  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

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
  final TextEditingController _heightInController = TextEditingController();
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
    super.dispose();
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
    if (_heightFtController.text.isNotEmpty &&
        _heightInController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      try {
        double heightInInches = (double.parse(_heightFtController.text) * 12 +
            double.parse(_heightInController.text));
        double weight = double.parse(_weightController.text);
        double bmi = (weight / (heightInInches * heightInInches)) * 703;
        _bmiController.text = bmi.toStringAsFixed(1);
      } catch (e) {
        _bmiController.text = '';
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
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
          'height':
              '${_heightFtController.text}ft ${_heightInController.text}in',
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
    }
  }

  // UI Components
  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
          ],
        ),
        _buildCustomInput(
          controller: _weightController,
          label: 'Weight (kg)',
          keyboardType: TextInputType.number,
          onChanged: (_) => _calculateBMI(),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    children: options.map((option) {
                      return Expanded(
                        child: RadioListTile<T>(
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
                        ),
                      );
                    }).toList(),
                  )
                : Column(
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
        if (step == 0 || (step > 0 && _formKey.currentState!.validate())) {
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
          items: const [
            'Pooja Healthcare',
            'Pooja Nursing Home',
            'Fortis Hospital, Mulund',
            'Breach Candy Hospital',
            'P D Hinduja Hospital, Mahim',
            'Jupiter Hospital, Thane'
          ],
          label: 'Location',
          onChanged: (value) => setState(() => _location = value!),
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
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepNavigation(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _buildPersonalDetails(),
                    _buildMedicalDetails(),
                    _buildReportsSection(),
                  ],
                ),
              ),
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
                    if (_formKey.currentState!.validate()) {
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
