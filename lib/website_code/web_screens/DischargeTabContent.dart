import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poojaheakthcare/screens/patient_info_screen.dart';
import 'package:toast/toast.dart';

import '../../constants/base_url.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/CustomCheckbox.dart';
import '../../widgets/DatePickerInput.dart';
import '../../widgets/DocumentUploadWidget.dart';
import '../../widgets/TimePickerInput.dart';
import '../../widgets/showTopSnackBar.dart';
import '../../widgets/show_dialog.dart';

import 'Patient_Registration.dart';

class DischargeTabContent extends StatefulWidget {
   var patientId;
   var postOperationId;

   DischargeTabContent({
  super.key,
  this.patientId,
  this.postOperationId,
  });

  @override
  State<DischargeTabContent> createState() => _DischargeTabContentState();
}

class _DischargeTabContentState extends State<DischargeTabContent> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEditing = false;
  int? _existingDischargeId;

  // Information Controllers
  final TextEditingController _consultantController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _qualificationsController = TextEditingController();
  final TextEditingController _indoorRegNoController = TextEditingController();
  final TextEditingController _operationTypeController = TextEditingController();
  final TextEditingController _drugAllergyController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _chiefComplaintsController = TextEditingController();

  // Date/Time fields
  DateTime _admissionDate = DateTime.now();
  DateTime _dischargeDate = DateTime.now();
  DateTime _investigationsDate = DateTime.now();
  DateTime _followUpDate = DateTime.now();

  // Past History Controllers
  bool _hasDM = false;
  bool _hasHypertension = false;
  bool _hasIHD = false;
  bool _hasCOPD = false;
  bool _hasTB = false;
  final TextEditingController _surgicalHistoryController = TextEditingController();
  final TextEditingController _personalHistoryController = TextEditingController();
  final TextEditingController _otherIllnessController = TextEditingController();
  final TextEditingController _presentMedicationController = TextEditingController();
  final TextEditingController _familyHistoryController = TextEditingController();
  final TextEditingController _onExaminationController = TextEditingController();
  final TextEditingController _treatmentGivenController = TextEditingController();
  final TextEditingController _hospitalizationCourseController = TextEditingController();

  // Investigations Controllers
  final TextEditingController _testController = TextEditingController();
  final TextEditingController _positiveFindingsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDischargeData();
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

      final request = http.Request('POST', Uri.parse('$localurl/get_discharge'));
      request.body = json.encode({
        "patient_id": widget.patientId.toString(),
      });
      request.headers.addAll(headers);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 && jsonResponse['status'] == true && jsonResponse['data'].isNotEmpty) {
        final dischargeData = jsonResponse['data'][0];
        _populateFormFields(dischargeData);
        _existingDischargeId = dischargeData['id'];
        _isEditing = true;
      }
    } catch (e) {
      log('Error fetching discharge data: $e');
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
      _qualificationsController.text = data['qualifications']?.toString() ?? '';
      _indoorRegNoController.text = data['indoor_reg_no']?.toString() ?? '';
      _drugAllergyController.text = data['drug_allergy']?.toString() ?? '';
      _diagnosisController.text = data['diagnosis']?.toString() ?? '';
      _chiefComplaintsController.text = data['chief_complaints']?.toString() ?? '';

      // Dates
      if (data['admission_date'] != null) {
        _admissionDate = DateTime.parse(data['admission_date'].toString());
      }
      if (data['discharge_date'] != null) {
        _dischargeDate = DateTime.parse(data['discharge_date'].toString());
      }
      if (data['follow_up'] != null) {
        _followUpDate = DateTime.parse(data['follow_up'].toString());
      }

      // Past History
      _hasDM = data['history_of_dm_status'] == 1;
      _hasHypertension = data['hypertension_status'] == 1;
      _hasIHD = data['IHD_status'] == 1;
      _hasTB = data['tb'] == 1;
      _surgicalHistoryController.text = data['surgical_history']?.toString() ?? '';
      _personalHistoryController.text = data['personal_history']?.toString() ?? '';
      _otherIllnessController.text = data['other_illness']?.toString() ?? '';
      _presentMedicationController.text = data['history_of_present_medication']?.toString() ?? '';
      _familyHistoryController.text = data['family_history']?.toString() ?? '';
      _onExaminationController.text = data['on_examination']?.toString() ?? '';
      _treatmentGivenController.text = data['treatment_given']?.toString() ?? '';
      _hospitalizationCourseController.text = data['course_during_hospitalization']?.toString() ?? '';
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
         showTopRightToast(
          context,
          'Authentication token not found. Please login again.',
           backgroundColor: Colors.red
        );
        return;
      }

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        "id": _existingDischargeId,
        "patient_id": widget.patientId,
        "post_operation_id": widget.postOperationId,
        "consultant": _consultantController.text,
        "contact": _contactController.text,
        "qualifications": _qualificationsController.text,
        "indoor_reg_no": _indoorRegNoController.text,
        "admission_date": DateFormat('yyyy-MM-dd').format(_admissionDate),
        "discharge_date": DateFormat('yyyy-MM-dd').format(_dischargeDate),
        "operation_type": _operationTypeController.text,
        "drug_allergy": _drugAllergyController.text,
        "diagnosis": _diagnosisController.text,
        "chief_complaints": _chiefComplaintsController.text,
        "tb": _hasTB ? 1 : 0,
        "surgical_history": _surgicalHistoryController.text,
        "personal_history": _personalHistoryController.text,
        "other_illness": _otherIllnessController.text,
        "history_of_present_medication": _presentMedicationController.text,
        "family_history": _familyHistoryController.text,
        "on_examination": _onExaminationController.text,
        "treatment_given": _treatmentGivenController.text,
        "course_during_hospitalization": _hospitalizationCourseController.text,
        "history_of_dm_status": _hasDM ? 1 : 0,
        "hypertension_status": _hasHypertension ? 1 : 0,
        "IHD_status": _hasIHD ? 1 : 0,
        "COPD_status": _hasCOPD ? 1 : 0,
        "follow_up": DateFormat('yyyy-MM-dd').format(_followUpDate),
      });

      final response = await http.post(
        Uri.parse('$localurl/post_discharge'),
        headers: headers,
        body: body,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        showTopRightToast(context,responseData['message'] ?? 'Discharge record saved successfully',backgroundColor: Colors.green);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['message']}')),
        );
      }
    } catch (e) {
      showTopRightToast(context,'Error: $e',backgroundColor: Colors.red);


    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Information
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
                  const Text('1. Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      FormInput(
                          controller: _consultantController,
                          label: 'Consultant',
                          hintlabel: 'Enter consultant name'
                      ),
                      FormInput(
                          controller: _contactController,
                          label: 'Contact',
                          hintlabel: 'Enter contact number',


                      ),
                      FormInput(
                          controller: _qualificationsController,
                          label: 'Qualifications',
                          hintlabel: 'Enter qualifications'
                      ),
                      FormInput(
                          controller: _indoorRegNoController,
                          label: 'Indoor Reg No',
                          hintlabel: 'Enter indoor registration number'
                      ),
                      DatePickerInput(
                        label: 'Admission Date',
                        hintlabel: 'Admission Date',
                        initialDate: _admissionDate,
                        onDateSelected: (date) {
                          setState(() => _admissionDate = date);
                        },
                      ),
                      TimePickerInput(
                        label: 'Admission Time',
                        hintlabel: 'Admission Time',
                        initialTime: TimeOfDay.fromDateTime(_admissionDate),
                        onTimeSelected: (time) {
                          setState(() {
                            _admissionDate = DateTime(
                              _admissionDate.year,
                              _admissionDate.month,
                              _admissionDate.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                      ),
                      DatePickerInput(
                        label: 'Discharge Date',
                        hintlabel: 'Discharge Date',
                        initialDate: _dischargeDate,
                        onDateSelected: (date) {
                          setState(() => _dischargeDate = date);
                        },
                      ),
                      TimePickerInput(
                        hintlabel:'Discharge Time' ,
                        label: 'Discharge Time',
                        initialTime: TimeOfDay.fromDateTime(_dischargeDate),
                        onTimeSelected: (time) {
                          setState(() {
                            _dischargeDate = DateTime(
                              _dischargeDate.year,
                              _dischargeDate.month,
                              _dischargeDate.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FormInput(
                            controller: _operationTypeController,
                            label: 'Operation Type',
                            hintlabel: 'Enter operation type'
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FormInput(
                            controller: _drugAllergyController,
                            label: 'Any drug allergy reported/noted',
                            hintlabel: 'Enter drug allergy details'
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FormInput(
                            controller: _diagnosisController,
                            label: 'Diagnosis',
                            hintlabel: 'Enter diagnosis details',

                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FormInput(
                            controller: _chiefComplaintsController,
                            label: 'Chief complaints',
                            hintlabel: 'Enter chief complaints',

                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. Past History
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
                  const Text('2. Past History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomCheckbox(
                        label: 'H/O DM',
                        initialValue: _hasDM,
                        onChanged: (value) => setState(() => _hasDM = value),
                      ),
                      CustomCheckbox(
                        label: 'Hypertension',
                        initialValue: _hasHypertension,
                        onChanged: (value) => setState(() => _hasHypertension = value),
                      ),
                      CustomCheckbox(
                        label: 'IHD',
                        initialValue: _hasIHD,
                        onChanged: (value) => setState(() => _hasIHD = value),
                      ),
                      CustomCheckbox(
                        label: 'COPD',
                        initialValue: _hasCOPD,
                        onChanged: (value) => setState(() => _hasCOPD = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FormInput(
                          controller: _surgicalHistoryController,
                          label: 'Surgical History',
                          hintlabel: 'Enter surgical history',

                      ),
                      FormInput(
                          controller: _personalHistoryController,
                          label: 'Personal History',
                          hintlabel: 'Enter personal history',

                      ),
                      FormInput(
                          controller: _otherIllnessController,
                          label: 'Other Illness',
                          hintlabel: 'Enter other illness details',

                      ),
                      FormInput(
                          controller: _presentMedicationController,
                          label: 'History of Present Medication',
                          hintlabel: 'Enter current medication details',

                      ),
                      FormInput(
                          controller: _familyHistoryController,
                          label: 'Family History',
                          hintlabel: 'Enter family history',

                      ),
                      FormInput(
                          controller: _onExaminationController,
                          label: 'On Examination',
                          hintlabel: 'Enter examination findings',

                      ),
                      FormInput(
                          controller: _treatmentGivenController,
                          label: 'Treatment given',
                          hintlabel: 'Enter treatment details',


                      ),
                      FormInput(
                          controller: _hospitalizationCourseController,
                          label: 'Course during hospitalization',
                          hintlabel: 'Enter course details',

                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. Upload Documents
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
                  const Text('3. Upload Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DocumentUploadWidget(
                    label: "Upload Documents",
                    docType: "Media History",
                    onFilesSelected: (files) {
                      // Handle file uploads
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Investigations
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
                  const Text('4. Investigations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DatePickerInput(
                        label: 'Investigations Date',
                        initialDate: _investigationsDate,
                        onDateSelected: (date) {
                          setState(() => _investigationsDate = date);
                        }, hintlabel: '',
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FormInput(
                            controller: _testController,
                            label: 'Test',
                            hintlabel: 'Enter test details',


                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FormInput(
                            controller: _positiveFindingsController,
                            label: 'Positive Findings',
                            hintlabel: 'Enter findings',

                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_box, color: AppColors.secondary, size: 40),
                        onPressed: () {
                          // Add more investigation fields
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Follow Up Date
           /* DatePickerInput(
              label: 'Follow Up Date',
              initialDate: _followUpDate,
              onDateSelected: (date) {
                setState(() => _followUpDate = date);
              }, hintlabel: '',
            ),

            const SizedBox(height: 32),*/

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Animatedbutton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  shadowColor: Colors.white,
                  titlecolor: AppColors.primary,
                  backgroundColor: Colors.white,
                  borderColor: AppColors.secondary,
                  isLoading: false,
                  title: 'Cancel',
                ),
                const SizedBox(width: 12),
                Animatedbutton(
                  onPressed: _submitForm,
                  shadowColor: Colors.white,
                  backgroundColor: AppColors.secondary,
                  isLoading: _isLoading,
                  title: _isEditing ? 'Update' : 'Save',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _consultantController.dispose();
    _contactController.dispose();
    _qualificationsController.dispose();
    _indoorRegNoController.dispose();
    _operationTypeController.dispose();
    _drugAllergyController.dispose();
    _diagnosisController.dispose();
    _chiefComplaintsController.dispose();
    _surgicalHistoryController.dispose();
    _personalHistoryController.dispose();
    _otherIllnessController.dispose();
    _presentMedicationController.dispose();
    _familyHistoryController.dispose();
    _onExaminationController.dispose();
    _treatmentGivenController.dispose();
    _hospitalizationCourseController.dispose();
    _testController.dispose();
    _positiveFindingsController.dispose();
    super.dispose();
  }
}