import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poojaheakthcare/screens/patient_info_screen.dart';
import 'package:toast/toast.dart';

import '../../constants/ResponsiveUtils.dart';
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
import 'package:path/path.dart' as path;
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
  final Map<String, List<Map<String, dynamic>>> _uploadedFiles = {
    "discharge_images": []
  };
  // Information Controllers
  final TextEditingController _consultantController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _qualificationsController = TextEditingController();
  final TextEditingController _indoorRegNoController = TextEditingController();
  final TextEditingController _operationTypeController = TextEditingController();
  final TextEditingController _drugAllergyController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _chiefComplaintsController = TextEditingController();
  final TextEditingController _SincewhenController = TextEditingController();
  final TextEditingController _hypertensionSinceController = TextEditingController();

  final TextEditingController _copdDescriptionController = TextEditingController();
  final TextEditingController _ihdDescriptionController = TextEditingController();
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

  List<Investigation> _investigations = [Investigation()];
  // Investigations Controllers
  final TextEditingController _testController = TextEditingController();
  final TextEditingController _positiveFindingsController = TextEditingController();
  String _ensureStatus(bool value) => value ? '1' : '0';
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
        final dischargeData = jsonResponse['data'];
        print("dischargeData");
        print(dischargeData);
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
  String _ensureString(String? value) => value?.trim() ?? '';
  void _populateFormFields(Map<String, dynamic> data) {
    try {
      print("data");
      print(data);
      // Basic Info
      _consultantController.text = data['consultant']?.toString() ?? '';
      _contactController.text = data['contact']?.toString() ?? '';
      _qualificationsController.text = data['qualifications']?.toString() ?? '';
      _indoorRegNoController.text = data['indoor_reg_no']?.toString() ?? '';
      _drugAllergyController.text = data['drug_allergy']?.toString() ?? '';
      _diagnosisController.text = data['diagnosis']?.toString() ?? '';
      _chiefComplaintsController.text = data['chief_complaints']?.toString() ?? '';
      _SincewhenController.text =
          data['history_of_dm_description']?.toString() ?? '';

      _hypertensionSinceController.text =
          data['hypertension_description']?.toString() ?? '';


      _ihdDescriptionController.text =
          data['IHD_description']?.toString() ?? '';


      _copdDescriptionController.text =
          data['COPD_description']?.toString() ?? '';
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
      _hasCOPD = data['COPD_status'] == 1;
      print("_hasCOPD");
      print(data['COPD_status']);
      print(_hasCOPD);
      print(_hasIHD);
      _hasTB = data['tb'] == 1;
      _surgicalHistoryController.text = data['surgical_history']?.toString() ?? '';
      _operationTypeController.text = data['operation_type']?.toString() ?? '';
      _personalHistoryController.text = data['personal_history']?.toString() ?? '';
      _otherIllnessController.text = data['other_illness']?.toString() ?? '';
      _presentMedicationController.text = data['history_of_present_medication']?.toString() ?? '';
      _familyHistoryController.text = data['family_history']?.toString() ?? '';
      _onExaminationController.text = data['on_examination']?.toString() ?? '';
      _treatmentGivenController.text = data['treatment_given']?.toString() ?? '';
      _hospitalizationCourseController.text = data['course_during_hospitalization']?.toString() ?? '';
      if (data['investigations'] != null && data['investigations'] is List) {
        _investigations = (data['investigations'] as List).map((item) => Investigation(
          date: item['investigation_date'] != null
              ? DateTime.parse(item['investigation_date'])
              : DateTime.now(),
          test: item['test'] ?? '',
          positiveFinding: item['positive_finding'] ?? '',
        )).toList();
      }

      if (data['discharge_images'] != null && data['discharge_images'] is List) {
        print( "_uploadedFiles");
        print( _uploadedFiles['discharge_images']);
        _uploadedFiles['discharge_images'] = (data['discharge_images'] as List).map((file) {
          return {
            'id': file['id'],
            'path': file['image_path'],
            'name': path.basename(file['image_path']?.toString() ?? 'unknown'),
            'type': path.extension(file['image_path']?.toString() ?? '').replaceAll('.', '').toUpperCase(),
            'size': '',
            'isExisting': true,
          };
        }).toList();
      }
    } catch (e) {
      log('Error populating form fields: $e');
    }
  }

  void _addInvestigation() {
    setState(() {
      _investigations.add(Investigation());
    });
  }

  void _removeInvestigation(int index) {
    setState(() {
      _investigations.removeAt(index);
    });
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

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$localurl/post_discharge'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add form fields
      request.fields.addAll({
        "id": _existingDischargeId?.toString() ?? '',
        "patient_id": widget.patientId.toString(),
        "post_operation_id": widget.postOperationId?.toString() ?? "0",
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
        "tb": _hasTB ? '1' : '0',
        "surgical_history": _surgicalHistoryController.text,
        "personal_history": _personalHistoryController.text,
        "other_illness": _otherIllnessController.text,
        "history_of_present_medication": _presentMedicationController.text,
        "family_history": _familyHistoryController.text,
        "on_examination": _onExaminationController.text,
        "treatment_given": _treatmentGivenController.text,
        "course_during_hospitalization": _hospitalizationCourseController.text,
        "history_of_dm_status": _hasDM ? '1' : '0',
        "hypertension_status": _ensureStatus(_hasHypertension),
        "IHD_status": _ensureStatus(_hasIHD),
        "COPD_status":_ensureStatus(_hasCOPD) ,
        'history_of_dm_description': _ensureString(_SincewhenController.text),
        'hypertension_description':
        _ensureString(_hypertensionSinceController.text),
        'IHD_description': _ensureString(_ihdDescriptionController.text),
        'COPD_description': _ensureString(_copdDescriptionController.text),
        "follow_up": DateFormat('yyyy-MM-dd').format(_followUpDate),
        "investigations": json.encode(_investigations.map((inv) => {
          "investigation_date": inv.date.toIso8601String(),
          "test": inv.testController.text,
          "positive_finding": inv.positiveFindingController.text,
        }).toList()),
      });

      // Add file uploads
      List<String> existingFileIds = [];
      for (var file in _uploadedFiles['discharge_images'] ?? []) {
        if (!file['isExisting']) {
          if (kIsWeb && file['bytes'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'discharge_images',
              file['bytes']!,
              filename: file['name'],
            ));
          } else if (!kIsWeb && file['path'] != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'discharge_images',
              file['path']!,
              filename: file['name'],
            ));
          }
        } else {
          existingFileIds.add(file['id'].toString());
        }
      }
      if (existingFileIds.isNotEmpty) {
        request.fields['existing_file'] = existingFileIds.join(',');
      }
      log("existingFileIds $existingFileIds");

      log('Sending discharge data: ${request.fields}');
      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (response.statusCode == 200) {
        showTopRightToast(
            context,
            responseData['message'] ?? 'Discharge record saved successfully',
            backgroundColor: Colors.green
        );
      } else {
        print('Error: ${responseData['message']}');
        showTopRightToast(
            context,
            'Error: ${responseData['message']}',
            backgroundColor: Colors.red
        );
      }
    } catch (e) {
      showTopRightToast(
          context,
          'Error: $e',
          backgroundColor: Colors.red
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
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
                   Text('1. Information', style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 18), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      FormInput(
                          controller: _consultantController,
                          label: 'Consultant',
                          hintlabel: 'Enter consultant name'
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
                            label: 'Surgery Type',
                            hintlabel: 'Enter surgery type'
                        ),
                      ),
                      const SizedBox(width: 16),
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
maxlength: 4,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormInput(
                            controller: _chiefComplaintsController,
                            label: 'Chief complaints',
                            hintlabel: 'Enter chief complaints',
maxlength: 4,
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
                   Text('2. Past History', style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 18), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  isMobile ?
                  Wrap(
                    spacing: 16,
                    runSpacing: 14,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,

                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCheckbox(
                            label: 'H/O DM',
                            initialValue: _hasDM,
                            onChanged: (value) => setState(() => _hasDM = value),
                          ),
                          const SizedBox(height: 8),
                          if(_hasDM)
                            FormInput(label: 'Since when',maxlength: 1,controller: _SincewhenController,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCheckbox(label: 'Hypertension'
                            ,initialValue: _hasHypertension
                            ,onChanged: (value) {
                              setState(() {
                                _hasHypertension=value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          if(_hasHypertension)
                            FormInput(label: 'Since when',maxlength: 1,controller: _hypertensionSinceController,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCheckbox(label: 'IHD',initialValue: _hasIHD  ,onChanged: (value) {
                            setState(() {
                              _hasIHD=value;
                            });
                          },),
                          const SizedBox(height: 8),
                          if(_hasIHD)
                            FormInput(label: 'IHD Description',maxlength: 1,controller: _ihdDescriptionController,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomCheckbox(label: 'COPD'  ,initialValue: _hasCOPD,onChanged: (value) {
                            setState(() {
                              print("_hasCOPD");
                              print(_hasCOPD);
                              _hasCOPD=value;
                            });
                          },),
                          const SizedBox(height: 8),
                          if(_hasCOPD)
                            FormInput(label: 'COPD Description',maxlength: 1,controller: _copdDescriptionController,),
                        ],
                      ),

                    ],
                  ) :Row(
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
                  )
              ,
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      FormInput(
                          controller: _surgicalHistoryController,
                          label: 'Surgical History',
                          hintlabel: 'Enter surgical history',
maxlength: 4,
                      ),
                      FormInput(
                          controller: _personalHistoryController,
                          label: 'Personal History',
                          hintlabel: 'Enter personal history',
                        maxlength: 4,
                      ),
                      FormInput(
                          controller: _otherIllnessController,
                          label: 'Other Illness',
                          hintlabel: 'Enter other illness details',
                        maxlength: 4,
                      ),
                      FormInput(
                          controller: _presentMedicationController,
                          label: 'History of Present Medication',
                          hintlabel: 'Enter current medication details',
                        maxlength: 4,
                      ),
                      FormInput(
                          controller: _familyHistoryController,
                          label: 'Family History',
                          hintlabel: 'Enter family history',
                        maxlength: 4,
                      ),
                      FormInput(
                          controller: _onExaminationController,
                          label: 'On Examination',
                          hintlabel: 'Enter examination findings',
                        maxlength: 4,
                      ),
                      FormInput(
                          controller: _treatmentGivenController,
                          label: 'Treatment given',
                          hintlabel: 'Enter treatment details',
                        maxlength: 4,

                      ),
                      FormInput(
                          controller: _hospitalizationCourseController,
                          label: 'Course during hospitalization',
                          hintlabel: 'Enter course details',
                        maxlength: 4,
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
                   Text('3. Upload Documents', style: TextStyle(fontSize: ResponsiveUtils.fontSize(context, 18), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DocumentUploadWidget(
                    label: "Upload Documents",
                    docType: "discharge_images",
                    onFilesSelected: (files) {
                      setState(() {
                        _uploadedFiles['discharge_images'] = files;
                      });
                    },
                    initialFiles: _uploadedFiles['discharge_images'],
                  ),
                  const SizedBox(height: 16),
                  // Follow Up Date
                  DatePickerInput(
                    label: 'Follow Up Date',
                    initialDate: _followUpDate,
                    onDateSelected: (date) {
                      setState(() => _followUpDate = date);
                    }, hintlabel: '',
                  ),


                ],
              ),
            ),

           // const SizedBox(height: 32),

            // 4. Investigations
     /*       Container(
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
                  ..._investigations.asMap().entries.map((entry) {
                    final index = entry.key +1;
                    final investigation = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DatePickerInput(
                                label: 'Investigations Date',
                                hintlabel: 'Investigations Date',
                                initialDate: investigation.date,
                                onDateSelected: (date) {
                                  setState(() {
                                    investigation.date = date;
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FormInput(
                                  controller: investigation.testController,
                                  label: 'Test',
                                  hintlabel: 'Enter test name',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FormInput(
                                  controller: investigation.positiveFindingController,
                                  label: 'Positive Findings',
                                  hintlabel: 'Enter findings',
                                ),
                              ),
                              if (_investigations.length > 1)
                                IconButton(
                                  padding: EdgeInsets.all(8),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeInvestigation(index),
                                ),
                            ],
                          ),

                        ],
                      ),
                    );
                  }).toList(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        style: ButtonStyle(shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))))),

                        icon: const Icon(Icons.add_box, color: AppColors.secondary, size: 40),
                        onPressed: _addInvestigation,
                      ),
                    ],
                  ),
                ],
              ),
            ),*/

            const SizedBox(height: 32),
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
    for (var inv in _investigations) {
      inv.dispose();
    }

    super.dispose();
  }
}

class Investigation {
  DateTime date;
  final TextEditingController testController;
  final TextEditingController positiveFindingController;

  Investigation({
    DateTime? date,
    String test = '',
    String positiveFinding = '',
  }) :
        date = date ?? DateTime.now(),
        testController = TextEditingController(text: test),
        positiveFindingController = TextEditingController(text: positiveFinding);

  void dispose() {
    testController.dispose();
    positiveFindingController.dispose();
  }
}