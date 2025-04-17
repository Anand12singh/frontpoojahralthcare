import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/colors.dart';
import '../widgets/inputfild.dart';

class DischargePage extends StatefulWidget {
  const DischargePage({super.key});

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

  // Date/Time Controllers
  DateTime _admissionDate = DateTime.now();
  TimeOfDay _admissionTime = TimeOfDay.now();
  DateTime _dischargeDate = DateTime.now();
  TimeOfDay _dischargeTime = TimeOfDay.now();

  // Medical Info Controllers
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _drugAllergyController = TextEditingController();
  final TextEditingController _chiefComplaintsController =
      TextEditingController();

  // History Controllers
  bool _hasDM = false;
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
          InkWell(
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
                    DateFormat('dd/MM/yyyy').format(date),
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
            label: 'IHD Description',
            hintText: 'Enter IHD details',
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
          controller: _otherIllnessController,
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
          controller: _otherIllnessController,
          label: 'Course during hospitalization',
          hintText: 'Enter Course during hospitalization',
          minLines: 2,
          maxLines: 4,
          enableNewLines: true,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: () {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  void _submitForm() {
    // Process form submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Discharge information submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Discharge Information',
                          style: TextStyle(
                            fontSize: 22,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
