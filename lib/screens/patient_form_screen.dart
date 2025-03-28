import 'package:flutter/material.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({Key? key}) : super(key: key);

  @override
  _PatientFormScreenState createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

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

  @override
  void initState() {
    super.initState();
    _phIdController.text = 'PH-${DateTime.now().millisecondsSinceEpoch}';
    _ageController.text = '';
  }

  @override
  void dispose() {
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

  final Map<String, List<Map<String, dynamic>>> _uploadedFiles = {
    'Blood Reports': [],
    'X-Ray Reports': [],
    'CT Scan Reports': [],
    'ECG Reports': [],
    'Echocardiogram Reports': [],
  };

  final ImagePicker _picker = ImagePicker();

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
    double borderRadius = 10.0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: isRequired ? '$label*' : label,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 12,
          ),
          labelStyle: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.8),
            fontSize: 16,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
          ),
        ),
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        enabled: enabled,
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(
          color: enabled ? AppColors.textPrimary : Colors.grey[600],
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _buildCustomDropdown<T>({
    required T value,
    required List<T> items,
    required String label,
    required void Function(T?) onChanged,
    String Function(T)? displayText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    displayText != null ? displayText(item) : item.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
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
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          isHorizontal
              ? Row(
                  children: options.map((option) {
                    return Expanded(
                      child: RadioListTile<T>(
                        title: Text(option.value),
                        value: option.key,
                        groupValue: groupValue,
                        onChanged: onChanged,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  children: options.map((option) {
                    return RadioListTile<T>(
                      title: Text(option.value),
                      value: option.key,
                      groupValue: groupValue,
                      onChanged: onChanged,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {int level = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: level == 1 ? 22 : 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
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

 Widget _buildFileItem(String reportType, Map<String, dynamic> file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            file['path'].toLowerCase().endsWith('.pdf')
                ? Icons.picture_as_pdf
                : Icons.image,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'],
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${file['size']} KB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeFile(reportType, file),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFileSelection(String reportType, String source) async {
    try {
      XFile? pickedFile;
      File? savedFile;
      
      if (source == 'camera' || source == 'gallery') {
        pickedFile = await _picker.pickImage(
          source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 90,
        );
        
        if (pickedFile != null) {
          // Create report-specific folder
          final appDir = await getApplicationDocumentsDirectory();
          final reportDir = Directory(path.join(appDir.path, reportType));
          if (!await reportDir.exists()) {
            await reportDir.create(recursive: true);
          }
          
          // Generate unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final ext = path.extension(pickedFile.path);
          final filename = '$timestamp$ext';
          
          // Save file to app directory
          savedFile = File(path.join(reportDir.path, filename));
          await savedFile.writeAsBytes(await pickedFile.readAsBytes());
          
          // Get file size in KB
          final fileSize = (await savedFile.length()) / 1024;
          
          setState(() {
            _uploadedFiles[reportType]!.add({
              'path': savedFile!.path,
              'name': filename,
              'size': fileSize.toStringAsFixed(1),
              'originalPath': pickedFile.path,
            });
          });
        }
      }
      else if (source == 'file') {
        // For PDFs or other documents
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
        );
        
        if (result != null && result.files.single.path != null) {
          final originalFile = File(result.files.single.path!);
          
          // Create report-specific folder
          final appDir = await getApplicationDocumentsDirectory();
          final reportDir = Directory(path.join(appDir.path, reportType));
          if (!await reportDir.exists()) {
            await reportDir.create(recursive: true);
          }
          
          // Generate unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final ext = path.extension(result.files.single.name);
          final filename = '$timestamp$ext';
          
          // Save file to app directory
          savedFile = File(path.join(reportDir.path, filename));
          await savedFile.writeAsBytes(await originalFile.readAsBytes());
          
          // Get file size in KB
          final fileSize = (await savedFile.length()) / 1024;
          
          setState(() {
            _uploadedFiles[reportType]!.add({
              'path': savedFile!.path,
              'name': filename,
              'size': fileSize.toStringAsFixed(1),
              'originalPath': originalFile.path,
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
}
  Widget _buildUploadCard(String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      height: 1,
      width: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isActive ? AppColors.primary : Colors.grey[300],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> patientData = {
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
        // Add all other fields...
      };

      print(patientData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient record saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Record'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(1, 'Personal', _currentStep >= 0),
                _buildStepConnector(_currentStep >= 0),
                _buildStepIndicator(2, 'Medical', _currentStep >= 1),
                _buildStepConnector(_currentStep >= 1),
                _buildStepIndicator(3, 'Reports', _currentStep >= 2),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
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
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
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
