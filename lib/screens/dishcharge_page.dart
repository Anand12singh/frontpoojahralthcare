import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poojaheakthcare/screens/patient_info_screen.dart';

import 'package:poojaheakthcare/screens/post_opration_page.dart';

import '../constants/base_url.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../widgets/inputfild.dart';
import '../widgets/show_dialog.dart';

class DischargePage extends StatefulWidget {
  var patientId;
  var postOperationId;

  DischargePage({
    super.key,
    this.patientId,
    this.postOperationId,
  });

  @override
  State<DischargePage> createState() => _DischargePageState();
}

class _DischargePageState extends State<DischargePage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Basic Info Controllers
  final TextEditingController _consultantController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _uhIdController = TextEditingController();
  final TextEditingController _qualificationsController =
      TextEditingController();
  final TextEditingController _indoorRegNoController = TextEditingController();
  DateTime _followupdateFindingController = DateTime.now();

  // Date/Time Controllers
  DateTime _admissionDate = DateTime.now();
  TimeOfDay _admissionTime = TimeOfDay.now();
  DateTime _dischargeDate = DateTime.now();
  TimeOfDay _dischargeTime = TimeOfDay.now();

  // Medical Info Controllers
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _tbSinceController = TextEditingController();

  final TextEditingController _drugAllergyController = TextEditingController();
  final TextEditingController _chiefComplaintsController =
      TextEditingController();

  // History Controllers
  bool _hasDM = false;
  bool _hasTB = false;
  bool _isLoading = false;
  bool _isEditing = false;
  int? _existingDischargeId;
  final TextEditingController _dmSinceController = TextEditingController();
  bool _hasHypertension = false;
  final TextEditingController _hypertensionSinceController =
      TextEditingController();
  bool _hasIHD = false;
  final TextEditingController _ihdDescriptionController =
      TextEditingController();

  final TextEditingController _surgicalHistoryController =
      TextEditingController();
  final TextEditingController _personalHistoryController =
      TextEditingController();
  final TextEditingController _otherIllnessController = TextEditingController();
  final TextEditingController _presentMedicationController =
      TextEditingController();
  final TextEditingController _familyHistoryControllers =
      TextEditingController();

  // Examination/Treatment Controllers
  final TextEditingController _onExaminationController =
      TextEditingController();
  final TextEditingController _treatmentGivenController =
      TextEditingController();
  final TextEditingController _hospitalizationCourseControllers =
      TextEditingController();

  // File handling
  final Map<String, List<Map<String, dynamic>>> _uploadedFiles = {};
  final Map<String, List<String>> _deletedFiles = {};

  Future<void> _selectDate(BuildContext context, bool isAdmissionDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isAdmissionDate ? _admissionDate : _dischargeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isAdmissionDate) {
          _admissionDate = picked;
        } else {
          _dischargeDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isAdmissionTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isAdmissionTime ? _admissionTime : _dischargeTime,
    );

    if (picked != null) {
      setState(() {
        if (isAdmissionTime) {
          _admissionTime = picked;
        } else {
          _dischargeTime = picked;
        }
      });
    }
  }

  Widget _buildDatePickerField(String label, DateTime date, bool isAdmission) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _selectDate(context, isAdmission),
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
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd-MM-yyyy').format(date),
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

  Widget _buildTimePickerField(String label, TimeOfDay time, bool isAdmission) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          InkWell(
            onTap: () => _selectTime(context, isAdmission),
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
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.access_time, color: AppColors.primary),
                ],
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
          _buildClickableStep(1, 'Basic Info', 0),
          _buildStepConnector(_currentStep >= 0),
          _buildClickableStep(2, 'Medical History', 1),
          _buildStepConnector(_currentStep >= 1),
          _buildClickableStep(3, 'Treatment', 2),
        ],
      ),
    );
  }

  Widget _buildClickableStep(int number, String title, int stepIndex) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return InkWell(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _currentStep = stepIndex;
          });
        }
      },
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive || isCompleted
                  ? AppColors.primary
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      number.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive || isCompleted
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildMedicalHistoryStep();
      case 2:
        return _buildTreatmentStep();
      default:
        return _buildBasicInfoStep();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildCustomInput(
                  controller: _consultantController,
                  label: 'Consultant',
                  hintText: 'Enter consultant name'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildCustomInput(
                  controller: _contactController,
                  label: 'Contact',
                  hintText: 'Enter contact number',
                  keyboardType: TextInputType.phone),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildCustomInput(
                controller: _uhIdController,
                label: 'UH ID',
                hintText: 'Enter UH ID',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildCustomInput(
                controller: _qualificationsController,
                label: 'Qualifications',
                hintText: 'Enter qualifications',
              ),
            ),
          ],
        ),
        buildCustomInput(
          controller: _indoorRegNoController,
          label: 'Indoor Reg No',
          hintText: 'Enter indoor registration number',
        ),
        Row(
          children: [
            Expanded(
              child:
                  _buildDatePickerField('Admission Date', _admissionDate, true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child:
                  _buildTimePickerField('Admission Time', _admissionTime, true),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildDatePickerField(
                  'Discharge Date', _dischargeDate, false),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimePickerField(
                  'Discharge Time', _dischargeTime, false),
            ),
          ],
        ),
        buildCustomInput(
          controller: _diagnosisController,
          label: 'Diagnosis',
          hintText: 'Enter diagnosis details',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
        buildCustomInput(
          controller: _drugAllergyController,
          label: 'Any drug allergy reported/noted',
          hintText: 'Enter drug allergy details',
          minLines: 2,
          maxLines: 3,
          enableNewLines: true,
        ),
        buildCustomInput(
          controller: _chiefComplaintsController,
          label: 'Chief complaints',
          hintText: 'Enter chief complaints',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
      ],
    );
  }

  Widget _buildMedicalHistoryStep() {
    return Column(
      children: [
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
          buildCustomInput(
            controller: _dmSinceController,
            label: 'Since when?',
            hintText: 'Enter duration of DM',
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
          buildCustomInput(
            controller: _hypertensionSinceController,
            label: 'Since when?',
            hintText: 'Enter duration of hypertension',
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
          buildCustomInput(
            controller: _ihdDescriptionController,
            label: 'IHD Since When',
            hintText: 'Enter IHD details',
          ),
        _buildRadioGroup<bool>(
          label: 'TB:',
          groupValue: _hasTB,
          options: const [
            MapEntry(true, 'Yes'),
            MapEntry(false, 'No'),
          ],
          onChanged: (value) => setState(() => _hasTB = value!),
        ),
        if (_hasTB)
          buildCustomInput(
            controller: _tbSinceController,
            label: 'TB Since When',
            hintText: 'Enter TB details',
          ),
        buildCustomInput(
          controller: _surgicalHistoryController,
          label: 'Surgical History',
          hintText: 'Enter surgical history',
          minLines: 2,
          maxLines: 4,
          enableNewLines: true,
        ),
        buildCustomInput(
          controller: _personalHistoryController,
          label: 'Personal History',
          hintText: 'Enter personal history',
          minLines: 2,
          maxLines: 4,
          enableNewLines: true,
        ),
        buildCustomInput(
          controller: _otherIllnessController,
          label: 'Other Illness',
          hintText: 'Enter other illness details',
          minLines: 2,
          maxLines: 4,
          enableNewLines: true,
        ),
        buildCustomInput(
          controller: _presentMedicationController,
          label: 'History of Present Medication',
          hintText: 'Enter current medication details',
          minLines: 2,
          maxLines: 4,
          enableNewLines: true,
        ),
        buildCustomInput(
          controller: _familyHistoryControllers,
          label: 'Family History',
          hintText: 'Enter Family History',
          minLines: 2,
          maxLines: 4,
          enableNewLines: true,
        ),
      ],
    );
  }

  Widget _buildTreatmentStep() {
    return Column(
      children: [
        buildCustomInput(
          controller: _onExaminationController,
          label: 'On Examination',
          hintText: 'Enter examination findings',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
        buildCustomInput(
          controller: _treatmentGivenController,
          label: 'Treatment given',
          hintText: 'Enter treatment details',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
        ),
        buildCustomInput(
          controller: _hospitalizationCourseControllers,
          label: 'Course during hospitalization',
          hintText: 'Enter Course during hospitalization',
          minLines: 2,
          maxLines: 4,
          enableNewLines: true,
        ),
        buildDatePickerField(
            label: 'Follow Up Date',
            selectedDate: _followupdateFindingController,
            onTap: () => _selectDateGeneric1(
                  context: context,
                  currentDate: _followupdateFindingController,
                  onDateSelected: (picked) =>
                      _followupdateFindingController = picked,
                )),
      ],
    );
  }

  Future<void> _selectDateGeneric1({
    required BuildContext context,
    required DateTime currentDate,
    required Function(DateTime) onDateSelected,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != currentDate) {
      setState(() => onDateSelected(picked));
    }
  }

  Widget buildDatePickerField({
    required String label,
    required DateTime selectedDate,
    required VoidCallback onTap,
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
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
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
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

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // if (_currentStep > 0)
          ElevatedButton(
            onPressed: () {
              if (_currentStep == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostOperationPage()),
                );
              }
              if (_formKey.currentState!.validate()) {
                setState(() => _currentStep--);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.primary),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: const Text('BACK'),
          ),
          // else
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: Text(_currentStep == 2 ? 'SUBMIT' : 'NEXT'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchDischargeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final request =
          http.Request('POST', Uri.parse('$localurl/get_discharge'));

      request.body = json.encode({
        "patient_id": widget.patientId.toString(),
        // "post_operation_id": widget.postOperationId.toString(),
      });
      request.headers.addAll(headers);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 &&
          jsonResponse['status'] == true &&
          jsonResponse['data'].isNotEmpty) {
        final dischargeData = jsonResponse['data'][0];
        log('dischargeData ${dischargeData}');
        _populateFormFields(dischargeData);
      }
    } catch (e) {
      log(' error $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFormFields(Map<String, dynamic> data) {
    try {
      // Basic Info
      _consultantController.text = data['consultant']?.toString() ?? '';
      _contactController.text = data['contact']?.toString() ?? '';
      _uhIdController.text = data['uh_id']?.toString() ?? '';
      _qualificationsController.text = data['qualifications']?.toString() ?? '';
      _indoorRegNoController.text = data['indoor_reg_no']?.toString() ?? '';
      _followupdateFindingController = DateTime.parse(
          data['follow_up']?.toString() ?? DateTime.now().toString());

      // Dates
      if (data['admission_date'] != null) {
        try {
          _admissionDate = DateTime.parse(data['admission_date'].toString());
        } catch (e) {
          log('Error parsing admission_date: $e');
        }
      }
      if (data['discharge_date'] != null) {
        try {
          _dischargeDate = DateTime.parse(data['discharge_date'].toString());
        } catch (e) {
          log('Error parsing discharge_date: $e');
        }
      }

      // Times
      if (data['admission_time'] != null) {
        try {
          final timeParts = data['admission_time'].toString().split(':');
          _admissionTime = TimeOfDay(
            hour: int.tryParse(timeParts[0]) ?? 0,
            minute: int.tryParse(timeParts[1]) ?? 0,
          );
        } catch (e) {
          log('Error parsing admission_time: $e');
        }
      }
      if (data['discharge_time'] != null) {
        try {
          final timeParts = data['discharge_time'].toString().split(':');
          _dischargeTime = TimeOfDay(
            hour: int.tryParse(timeParts[0]) ?? 0,
            minute: int.tryParse(timeParts[1]) ?? 0,
          );
        } catch (e) {
          log('Error parsing discharge_time: $e');
        }
      }

      // Medical Info
      _diagnosisController.text = data['diagnosis']?.toString() ?? '';
      _drugAllergyController.text = data['drug_allergy']?.toString() ?? '';
      _chiefComplaintsController.text =
          data['chief_complaints']?.toString() ?? '';

      // History
      _hasDM = data['history_of_dm_status'] == 1;
      _dmSinceController.text =
          data['history_of_dm_description']?.toString() ?? '';
      _hasTB = data['tb'] == 1;
      _tbSinceController.text = data['tb_since']?.toString() ?? '';

      _hasHypertension = data['hypertension_status'] == 1;
      _hypertensionSinceController.text =
          data['hypertension_description']?.toString() ?? '';
      _hasIHD = data['IHD_status'] == 1;
      _ihdDescriptionController.text =
          data['IHD_description']?.toString() ?? '';
      _surgicalHistoryController.text =
          data['surgical_history']?.toString() ?? '';
      _personalHistoryController.text =
          data['personal_history']?.toString() ?? '';
      _otherIllnessController.text = data['other_illness']?.toString() ?? '';
      _presentMedicationController.text =
          data['history_of_present_medication']?.toString() ?? '';
      _familyHistoryControllers.text = data['family_history']?.toString() ?? '';

      // Examination/Treatment
      _onExaminationController.text = data['on_examination']?.toString() ?? '';
      _treatmentGivenController.text =
          data['treatment_given']?.toString() ?? '';
      _hospitalizationCourseControllers.text =
          data['course_during_hospitalization']?.toString() ?? '';

      log('Form fields populated successfully');
    } catch (e) {
      log('Error populating form fields: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        ShowDialogs.showSnackBar(
          context,
          'Authentication token not found. Please login again.',
        );
        return;
      }

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        "id": widget.patientId,
        "patient_id": widget.patientId,
        "post_operation_id": widget.postOperationId,
        "consultant": _consultantController.text,
        "contact": _contactController.text,
        "uh_id": int.tryParse(_uhIdController.text),
        "qualifications": _qualificationsController.text,
        "indoor_reg_no": _indoorRegNoController.text,
        "admission_date": DateFormat('yyyy-MM-dd').format(_admissionDate),
        "admission_time": '${_admissionTime.hour}:${_admissionTime.minute}:00',
        "discharge_date": DateFormat('yyyy-MM-dd').format(_dischargeDate),
        "discharge_time": '${_dischargeTime.hour}:${_dischargeTime.minute}:00',
        "diagnosis": _diagnosisController.text,
        "drug_allergy": _drugAllergyController.text,
        "chief_complaints": _chiefComplaintsController.text,
        "tb": _hasTB ? 1 : 0,
        "tb_since": _hasTB ? _tbSinceController.text : "",
        "surgical_history": _surgicalHistoryController.text,
        "personal_history": _personalHistoryController.text,
        "other_illness": _otherIllnessController.text,
        "history_of_present_medication": _presentMedicationController.text,
        "family_history": _familyHistoryControllers.text,
        "on_examination": _onExaminationController.text,
        "treatment_given": _treatmentGivenController.text,
        "course_during_hospitalization": _hospitalizationCourseControllers.text,
        "history_of_dm_status": _hasDM ? 1 : 0,
        "history_of_dm_description": _hasDM ? _dmSinceController.text : "",
        "hypertension_status": _hasHypertension ? 1 : 0,
        "hypertension_description":
            _hasHypertension ? _hypertensionSinceController.text : "",
        "IHD_status": _hasIHD ? 1 : 0,
        "IHD_description": _hasIHD ? _ihdDescriptionController.text : "",
        'follow_up':
            _followupdateFindingController.toIso8601String().split('T')[0]
      });
      log("body  $body");

      final response = await http.post(
        Uri.parse('$localurl/post_discharge'),
        headers: headers,
        body: body,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: Text(responseData['message'] ??
                    'Dishcharge record saved successfully'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    log(widget.patientId.toString());
    log(widget.postOperationId.toString());
    // TODO: implement initState
    super.initState();
    _fetchDischargeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.medicalBlue.withOpacity(.2),
      appBar: AppBar(
        title: const Text('Discharge Information'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 1000,
                minHeight: constraints.maxHeight,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // _buildStepNavigation(),
                      // const SizedBox(height: 20),
                      // Align(
                      //   alignment: Alignment.center,
                      //   child: Text(
                      //     'Discharge Information',
                      //     style: TextStyle(
                      //       fontSize: 22,
                      //       color: AppColors.primary,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildCurrentStepContent(),
                      ),
                      _buildNavigationButtons(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _consultantController.dispose();
    _contactController.dispose();
    _uhIdController.dispose();
    _qualificationsController.dispose();
    _indoorRegNoController.dispose();
    _diagnosisController.dispose();
    _drugAllergyController.dispose();
    _chiefComplaintsController.dispose();
    _dmSinceController.dispose();
    _hypertensionSinceController.dispose();
    _ihdDescriptionController.dispose();
    _surgicalHistoryController.dispose();
    _personalHistoryController.dispose();
    _otherIllnessController.dispose();
    _presentMedicationController.dispose();
    _onExaminationController.dispose();
    _treatmentGivenController.dispose();
    _hospitalizationCourseControllers.dispose();
    _familyHistoryControllers.dispose();

    super.dispose();
  }
}
