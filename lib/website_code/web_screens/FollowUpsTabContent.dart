
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../provider/PermissionService.dart';
import '../../services/api_services.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/DatePickerInput.dart';
import '../../widgets/DocumentUploadWidget.dart';
import '../../widgets/showTopSnackBar.dart';
import 'Patient_Registration.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/show_dialog.dart';
import '../../constants/base_url.dart';
import 'package:path/path.dart' as path;

class FollowUpsTabContent extends StatefulWidget {
  final String patientId;
  final bool isMobile;

  const FollowUpsTabContent({super.key, required this.patientId, required this.isMobile});

  @override
  State<FollowUpsTabContent> createState() => _FollowUpsTabContentState();
}

class _FollowUpsTabContentState extends State<FollowUpsTabContent> {
  List<FollowUpEntry> followUpEntries = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasInitialData = false;
  List<bool> isEditingList = [];
  bool _isAddingFollowUp = false;
  String _patientName = '';
  String _patientAge = '';

  @override
  void initState() {
    super.initState();
    _fetchFollowUpData();
    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();
  }

  Future<void> _fetchFollowUpData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('$localurl/get_follow_up_date'),
        headers: headers,
        body: json.encode({
          "patient_id": widget.patientId,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final List<dynamic> data = responseData['data'];
        if (data.isNotEmpty) {
          final firstItem = data[0];
          print("firstItem");
          print(firstItem);
          setState(() {
            _patientName = firstItem['patient_name']?.toString() ?? '';
            _patientAge = firstItem['patient_age']?.toString() ?? '';
          });
        }
        setState(() {
          followUpEntries = data.map((item) {
            // Parse date with custom format (DD-MM-YYYY)
            DateTime parseCustomDate(String dateString) {
              try {
                final parts = dateString.split('-');
                if (parts.length == 3) {
                  return DateTime(
                    int.parse(parts[2]), // year
                    int.parse(parts[1]), // month
                    int.parse(parts[0]), // day
                  );
                }
                throw FormatException('Invalid date format');
              } catch (e) {
                print('Error parsing date $dateString: $e');
                return DateTime.now(); // fallback to current date
              }
            }

            var entry = FollowUpEntry(
              id: item['id'],
              date: parseCustomDate(item['follow_up_dates']),
              nextfollowupdates: item['next_follow_up_dates'] != null
                  ? parseCustomDate(item['next_follow_up_dates'])
                  : null,
              notes: item['notes'] ?? '',
              treatment: item['treatment'] ?? '',
              status: item['follow_up_status'] == 1 || item['status'] == "1",
              location: item['follow_up_location'] ?? '',
              symptomsComplaints: item['symptoms_complaints'] ?? '',
              findings: item['findings'] ?? '',
              investigation: item['investigation'] ?? '',
              intervention: item['intervention'] ?? '',
              docQualification: item['doc_qualification'] ?? '',
              registrationNumber: item['registration_number'] ?? '',
              signs: item['signs'] ?? '',
            );

            // Process investigation images
            if (item['investigation_image'] != null) {
              dynamic invImages = item['investigation_image'];
              if (invImages is String) {
                try {
                  invImages = json.decode(invImages);
                } catch (e) {
                  invImages = [];
                }
              }

              if (invImages is List) {
                entry.uploadedFiles['investigation_image'] = invImages.map<Map<String, dynamic>>((img) {
                  return {
                    'id': img['id'],
                    'file_path': img['file_path'],
                    'name': path.basename(img['file_path']?.toString() ?? 'unknown'),
                    'type': path.extension(img['file_path']?.toString() ?? '').replaceAll('.', '').toUpperCase(),
                    'size': '',
                    'isExisting': true,
                  };
                }).toList();
              }
            }

            if (item['treatment_image'] != null && item['treatment_image'] is List) {
              entry.uploadedFiles['treatment_image'] = (item['treatment_image'] as List).map((img) {
                return {
                  'id': img['id'],
                  'file_path': img['file_path'],
                  'name': path.basename(img['file_path']?.toString() ?? 'unknown'),
                  'type': path.extension(img['file_path']?.toString() ?? '').replaceAll('.', '').toUpperCase(),
                  'size': '',
                  'isExisting': true,
                };
              }).toList();
            }

            // Process treatment prescribed images if they exist
            if (item['treamtment_prescibed'] != null) {
              dynamic treatmentPrescribed = item['treamtment_prescibed'];
              if (treatmentPrescribed is String) {
                try {
                  treatmentPrescribed = json.decode(treatmentPrescribed);
                } catch (e) {
                  treatmentPrescribed = [];
                }
              }

              if (treatmentPrescribed is List) {
                entry.uploadedFiles['treamtment_prescibed'] = treatmentPrescribed.map<Map<String, dynamic>>((img) {
                  return {
                    'id': img['id'],
                    'file_path': img['file_path'],
                    'name': path.basename(img['file_path']?.toString() ?? 'unknown'),
                    'type': path.extension(img['file_path']?.toString() ?? '').replaceAll('.', '').toUpperCase(),
                    'size': '',
                    'isExisting': true,
                  };
                }).toList();
              }
            }

            // Process medications if they exist
            if (item['prescriptions'] != null) {
              try {
                dynamic prescriptions = item['prescriptions'];
                if (prescriptions is String) {
                  prescriptions = json.decode(prescriptions);
                }

                if (prescriptions is List) {
                  for (var med in prescriptions) {
                    if (med['status'] != 0) { // Only add active medications
                      entry.addMedicationRow(
                        id: med['id']?.toString(),
                        name: med['name_of_medication'] ?? '',
                        dosage: med['dosage'] ?? '',
                        frequency: med['frequency'] ?? '',
                        duration: med['duration'] ?? '',
                      );
                    }
                  }
                }
              } catch (e) {
                print('Error parsing prescriptions: $e');
              }
            }

            return entry;
          }).toList();

          isEditingList = List<bool>.generate(followUpEntries.length, (index) => false);

          if (followUpEntries.isEmpty) {
            followUpEntries.add(FollowUpEntry());
            isEditingList.add(true);
          } else {
            _hasInitialData = true;
          }
        });
      }
    } catch (e) {
      print('Error fetching follow-ups: $e');
      showTopRightToast(
        context,
        'Error fetching follow-up data',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addFollowUp() {
    if (_isAddingFollowUp) {
      showTopRightToast(
          context,
          'Please complete the current follow-up before adding another',
          backgroundColor: Colors.orange
      );
      return;
    }

    setState(() {
      _isAddingFollowUp = true;

      // Create a completely fresh entry
      final newEntry = FollowUpEntry(
        id: null,
        date: null,
        nextfollowupdates: null,
        notes: '',
        treatment: '',
        status: true,
        location: '',
        symptomsComplaints: '',
        findings: '',
        investigation: '',
        intervention: '',
        docQualification: '',
        registrationNumber: '',
        signs: '',
        uploadedFiles: {
          "investigation_image": [],
          "treatment_image": [],
          "treamtment_prescibed": [],
        },
      );

      // Clear any existing controllers just to be sure
      newEntry.notesController.clear();
      newEntry.treatmentController.clear();
      newEntry.locationController.clear();
      newEntry.symptomscomplaintsController.clear();
      newEntry.findingsController.clear();
      newEntry.investigationController.clear();
      newEntry.interventionController.clear();
      newEntry._docQualificationController.clear();
      newEntry._registrationNumberController.clear();
      newEntry.signsController.clear();

      // Clear medication controllers
      newEntry.medNameControllers.clear();
      newEntry.medDosageControllers.clear();
      newEntry.medFrequencyControllers.clear();
      newEntry.medDurationControllers.clear();
      newEntry.medicationIds.clear();
      newEntry.deletedMedications.clear();

      followUpEntries.insert(0, newEntry);
      isEditingList.insert(0, true);

      print('Added new entry at index 0. Total entries: ${followUpEntries.length}');
      print('New entry date: ${newEntry.date}, next date: ${newEntry.nextfollowupdates}');
    });
  }

  void _cancelEditOrDelete(int index) {
    final entry = followUpEntries[index];
    if (entry.id == null) {
      // Unsaved → delete
      setState(() {
        followUpEntries.removeAt(index);
        isEditingList.removeAt(index);
        _isAddingFollowUp = false;
      });
    } else {
      // Existing → just exit edit mode
      setState(() {
        isEditingList[index] = false;
      });
    }
  }

  void _toggleEditMode(int index) {
    setState(() {
      isEditingList[index] = !isEditingList[index];
    });
  }

  Future<void> _UpdateSingleFollowUp(int index) async {
    final entry = followUpEntries[index];
    if (entry.date == null) {
      showTopRightToast(context, 'Please select a date', backgroundColor: Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        showTopRightToast(
            context,
            'Authentication token not found. Please login again.',
            backgroundColor: Colors.red
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$localurl/follow_up_date'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({
        'id': entry.id?.toString() ?? '',
        'patient_id': widget.patientId,
        'follow_up_dates': DateFormat('dd-MM-yyyy').format(entry.date!),
        'next_follow_up_dates': entry.nextfollowupdates != null
            ? DateFormat('dd-MM-yyyy').format(entry.nextfollowupdates!)
            : '',
        'notes': entry.notesController.text,
        'treatment': entry.treatmentController.text,
        'follow_up_status': '1',
        'follow_up_location': entry.locationController.text,
        'symptoms_complaints': entry.symptomscomplaintsController.text,
        'findings': entry.findingsController.text,
        'investigation': entry.investigationController.text,
        'intervention': entry.interventionController.text,
        'signs': entry.signsController.text,
        'doc_qualification': entry._docQualificationController.text,
        'registration_number': entry._registrationNumberController.text,
        'prescriptions': jsonEncode(entry.getMedicationPayload())
      });

      // Add investigation images
      List<String> existingInvestigationFiles = [];
      for (var file in entry.uploadedFiles['investigation_image']!) {
        if (file['isExisting'] == true) {
          existingInvestigationFiles.add(file['id'].toString());
        } else if (file['path'] != null) {
          if (kIsWeb && file['bytes'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'investigation_image',
              file['bytes']!,
              filename: file['name'],
            ));
          } else if (!kIsWeb) {
            request.files.add(await http.MultipartFile.fromPath(
              'investigation_image',
              file['path']!,
              filename: file['name'],
            ));
          }
        }
      }

      // Add treatment images
      List<String> existingTreatmentFiles = [];
      for (var file in entry.uploadedFiles['treatment_image']!) {
        if (file['isExisting'] == true) {
          existingTreatmentFiles.add(file['id'].toString());
        } else if (file['path'] != null) {
          if (kIsWeb && file['bytes'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'treatment_image',
              file['bytes']!,
              filename: file['name'],
            ));
          } else if (!kIsWeb) {
            request.files.add(await http.MultipartFile.fromPath(
              'treatment_image',
              file['path']!,
              filename: file['name'],
            ));
          }
        }
      }

      // Add treatment prescribed images
      List<String> existingTreatmentPrescribedFiles = [];
      for (var file in entry.uploadedFiles['treamtment_prescibed']!) {
        if (file['isExisting'] == true) {
          existingTreatmentPrescribedFiles.add(file['id'].toString());
        } else if (file['path'] != null) {
          if (kIsWeb && file['bytes'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'treamtment_prescibed',
              file['bytes']!,
              filename: file['name'],
            ));
          } else if (!kIsWeb) {
            request.files.add(await http.MultipartFile.fromPath(
              'treamtment_prescibed',
              file['path']!,
              filename: file['name'],
            ));
          }
        }
      }

      if (existingInvestigationFiles.isNotEmpty) {
        request.fields['existing_investigation_files'] = existingInvestigationFiles.join(',');
      }
      if (existingTreatmentFiles.isNotEmpty) {
        request.fields['existing_treatment_files'] = existingTreatmentFiles.join(',');
      }
      if (existingTreatmentPrescribedFiles.isNotEmpty) {
        request.fields['existing_treatment_prescribed_files'] = existingTreatmentPrescribedFiles.join(',');
      }

      print("existingTreatmentPrescribedFiles");
      print(existingTreatmentPrescribedFiles);

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);
      print("responseData");
      print(responseData);
      if (response.statusCode == 200) {
        showTopRightToast(
            context,
            'Follow-up saved successfully',
            backgroundColor: Colors.green
        );
        setState(() {
          isEditingList[index] = false;
          _isAddingFollowUp = false;
          _fetchFollowUpData();
        });
      } else {
        showTopRightToast(
            context,
            'Error saving follow-up: ${responseData['message']}',
            backgroundColor: Colors.red
        );
      }
    } catch (e) {
      print('Error in _UpdateSingleFollowUp: $e');
      showTopRightToast(
          context,
          'Error: ${e.toString()}',
          backgroundColor: Colors.red
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary,
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: PermissionService().canEditPatients,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: ResponsiveUtils.scaleWidth(context, 150),
                  child: Animatedbutton(
                    onPressed: _isAddingFollowUp ? null : _addFollowUp,
                    shadowColor: Colors.white,
                    titlecolor: Colors.white,
                    backgroundColor: AppColors.secondary,
                    borderColor: AppColors.secondary,
                    isLoading: false,
                    title: '+ Follow up',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...followUpEntries.asMap().entries.map(
                (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Follow up ${followUpEntries.length - entry.key}',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        if (!isEditingList[entry.key])
                          Row(
                            spacing: 10,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.green.withOpacity(0.7)
                                  ),
                                  child: Text(
                                      'Saved',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w200
                                      )
                                  )
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                                onPressed: () => _toggleEditMode(entry.key),
                              ),
                            ],
                          ),
                        if (isEditingList[entry.key])
                          Visibility(
                            visible: PermissionService().canEditPatients,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check_rounded, color: AppColors.primary),
                                  onPressed: () => _UpdateSingleFollowUp(entry.key),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close_rounded, color: Colors.red),
                                  onPressed: () => _cancelEditOrDelete(entry.key),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Row 1: Date and Symptoms if any
                    Row(
                      children: [
                        Expanded(
                          child: DatePickerInput(
                            key: ValueKey('date_${entry.key}_${entry.value.date}'),
                            label: 'Date',
                            hintlabel: 'Date',
                            initialDate: entry.value.date,
                            onDateSelected: (date) {
                              setState(() {
                                entry.value.date = date;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FormInput(
                            controller: entry.value.notesController,
                            label: 'Symptoms if any',
                            hintlabel: 'Enter Symptoms',
                            maxlength: 4,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Row 2: Signs and Suggested Investigation
                    Row(
                      children: [
                        Expanded(
                          child: FormInput(
                            controller: entry.value.signsController,
                            label: 'Signs',
                            hintlabel: 'Enter Signs',
                            maxlength: 1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FormInput(
                            controller: entry.value.investigationController,
                            label: 'Suggested Investigation',
                            hintlabel: 'Enter investigation',
                            maxlength: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Treatment Prescribed (document upload only) - Full width
                    DocumentUploadWidget(
                      label: "Treatment Prescribed",
                      docType: "treamtment_prescibed",
                      onFilesSelected: (files) {
                        setState(() {
                          entry.value.uploadedFiles['treamtment_prescibed'] = files;
                        });
                      },
                      initialFiles: entry.value.uploadedFiles['treamtment_prescibed']!,
                    ),

                    const SizedBox(height: 16),

                    // Row 3: Next Follow-Up and Intervention if Any
                    Row(
                      children: [
                        Expanded(
                          child: DatePickerInput(
                            key: ValueKey('next_date_${entry.key}_${entry.value.nextfollowupdates}'),
                            label: 'Next Follow-Up Date',
                            hintlabel: 'Next follow up date',
                            initialDate: entry.value.nextfollowupdates,
                            onDateSelected: (date) {
                              setState(() {
                                entry.value.nextfollowupdates = date;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FormInput(
                            controller: entry.value.interventionController,
                            label: 'Intervention if Any',
                            hintlabel: 'Enter intervention',
                            maxlength: 1,
                          ),
                        ),
                      ],
                    ),

                    // Optional: You can add other fields here but commented as per requirements
                    /*
                  // Upload Investigation (commented as per requirements)
                  const SizedBox(height: 12),
                  DocumentUploadWidget(
                    label: "Upload Investigation",
                    docType: "investigation_image",
                    onFilesSelected: (files) {
                      setState(() {
                        entry.value.uploadedFiles['investigation_image'] = files;
                      });
                    },
                    initialFiles: entry.value.uploadedFiles['investigation_image']!,
                  ),

                  const SizedBox(height: 12),

                  // Upload Intervention (commented as per requirements)
                  DocumentUploadWidget(
                    label: "Upload Intervention",
                    docType: "treatment_image",
                    onFilesSelected: (files) {
                      setState(() {
                        entry.value.uploadedFiles['treatment_image'] = files;
                      });
                    },
                    initialFiles: entry.value.uploadedFiles['treatment_image']!,
                  ),
                  */
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildHeaderCell(String text, [double? width]) {
  return Container(
    width: width,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      border: Border(right: BorderSide(color: Colors.grey.shade300)),
    ),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildCell(Widget child, {double? width}) {
  return Container(
    width: width,
    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    decoration: BoxDecoration(
      border: Border(right: BorderSide(color: Colors.grey.shade300)),
    ),
    child: child,
  );
}

class FollowUpEntry {
  int? id;
  DateTime? date;
  DateTime? nextfollowupdates;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController symptomscomplaintsController = TextEditingController();
  final TextEditingController findingsController = TextEditingController();
  final TextEditingController investigationController = TextEditingController();
  final TextEditingController interventionController = TextEditingController();
  final TextEditingController _docQualificationController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController signsController = TextEditingController();
  bool status;
  final Map<String, List<Map<String, dynamic>>> uploadedFiles;

  // Medication-related properties moved to FollowUpEntry
  final List<TextEditingController> medNameControllers = [];
  final List<TextEditingController> medDosageControllers = [];
  final List<TextEditingController> medFrequencyControllers = [];
  final List<TextEditingController> medDurationControllers = [];
  final List<String> medicationIds = [];
  final List<Map<String, dynamic>> deletedMedications = [];

  FollowUpEntry({
    this.id,
    this.date,
    this.nextfollowupdates,
    String? notes,
    String? treatment,
    this.status = true,
    String? location,
    String? symptomsComplaints,
    String? findings,
    String? investigation,
    String? intervention,
    String? docQualification,
    String? registrationNumber,
    String? signs,
    Map<String, List<Map<String, dynamic>>>? uploadedFiles,
  }) : uploadedFiles = uploadedFiles ?? {
    "investigation_image": [],
    "treatment_image": [],
    "treamtment_prescibed": [],
  } {
    if (notes != null) notesController.text = notes;
    if (treatment != null) treatmentController.text = treatment;
    if (location != null) locationController.text = location;
    if (symptomsComplaints != null) symptomscomplaintsController.text = symptomsComplaints;
    if (findings != null) findingsController.text = findings;
    if (investigation != null) investigationController.text = investigation;
    if (intervention != null) interventionController.text = intervention;
    if (docQualification != null) _docQualificationController.text = docQualification;
    if (registrationNumber != null) _registrationNumberController.text = registrationNumber;
    if (signs != null) signsController.text = signs;
  }

  void addMedicationRow({int count = 1, String? id, String name = '', String dosage = '', String frequency = '', String duration = ''}) {
    for (int i = 0; i < count; i++) {
      medNameControllers.add(TextEditingController(text: name));
      medDosageControllers.add(TextEditingController(text: dosage));
      medFrequencyControllers.add(TextEditingController(text: frequency));
      medDurationControllers.add(TextEditingController(text: duration));
      medicationIds.add(id ?? "");
    }
  }

  void removeMedicationRow(int index) {
    // If this is an existing medication, mark it as deleted
    if (medicationIds[index].isNotEmpty) {
      deletedMedications.add({
        "id": medicationIds[index],
        "name_of_medication": medNameControllers[index].text,
        "dosage": medDosageControllers[index].text,
        "frequency": medFrequencyControllers[index].text,
        "duration": medDurationControllers[index].text,
        "status": 0,
      });
    }

    medNameControllers.removeAt(index).dispose();
    medDosageControllers.removeAt(index).dispose();
    medFrequencyControllers.removeAt(index).dispose();
    medDurationControllers.removeAt(index).dispose();
    medicationIds.removeAt(index);
  }

  List<Map<String, dynamic>> getMedicationPayload() {
    List<Map<String, dynamic>> medications = [];

    // Add active medications
    for (int i = 0; i < medNameControllers.length; i++) {
      medications.add({
        "id": medicationIds[i] == null ? "" : medicationIds[i],
        "name_of_medication": medNameControllers[i].text,
        "dosage": medDosageControllers[i].text,
        "frequency": medFrequencyControllers[i].text,
        "duration": medDurationControllers[i].text,
        "status": 1,
      });
    }

    // Add deleted medications
    medications.addAll(deletedMedications);

    return medications;
  }

  void dispose() {
    notesController.dispose();
    treatmentController.dispose();
    locationController.dispose();
    symptomscomplaintsController.dispose();
    findingsController.dispose();
    investigationController.dispose();
    interventionController.dispose();
    _docQualificationController.dispose();
    _registrationNumberController.dispose();
    signsController.dispose();

    // Dispose medication controllers
    for (var controller in medNameControllers) {
      controller.dispose();
    }
    for (var controller in medDosageControllers) {
      controller.dispose();
    }
    for (var controller in medFrequencyControllers) {
      controller.dispose();
    }
    for (var controller in medDurationControllers) {
      controller.dispose();
    }
  }
}

/*
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../provider/PermissionService.dart';
import '../../services/api_services.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/DatePickerInput.dart';
import '../../widgets/DocumentUploadWidget.dart';
import '../../widgets/showTopSnackBar.dart';
import 'Patient_Registration.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/show_dialog.dart';
import '../../constants/base_url.dart';
import 'package:path/path.dart' as path;

class FollowUpsTabContent extends StatefulWidget {
  final String patientId;

  const FollowUpsTabContent({super.key, required this.patientId});

  @override
  State<FollowUpsTabContent> createState() => _FollowUpsTabContentState();
}

class _FollowUpsTabContentState extends State<FollowUpsTabContent> {
  List<FollowUpEntry> followUpEntries = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasInitialData = false;
  List<bool> isEditingList = [];
  bool _isAddingFollowUp = false;
  String _patientName = '';
  String _patientAge = '';
  @override
  void initState() {
    super.initState();
    _fetchFollowUpData();
    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();

  }

  Future<void> _fetchFollowUpData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('$localurl/get_follow_up_date'),
        headers: headers,
        body: json.encode({
          "patient_id": widget.patientId,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final List<dynamic> data = responseData['data'];
        if (data.isNotEmpty) {
          final firstItem = data[0];
          print("firstItem");
          print(firstItem);
          setState(() {
            _patientName = firstItem['patient_name']?.toString() ?? '';
            _patientAge = firstItem['patient_age']?.toString() ?? '';
          });
        }
        setState(() {
          followUpEntries = data.map((item) {
            // Parse date with custom format (DD-MM-YYYY)
            DateTime parseCustomDate(String dateString) {
              try {
                final parts = dateString.split('-');
                if (parts.length == 3) {
                  return DateTime(
                    int.parse(parts[2]), // year
                    int.parse(parts[1]), // month
                    int.parse(parts[0]), // day
                  );
                }
                throw FormatException('Invalid date format');
              } catch (e) {
                print('Error parsing date $dateString: $e');
                return DateTime.now(); // fallback to current date
              }
            }


            var entry = FollowUpEntry(
              id: item['id'],
              date: parseCustomDate(item['follow_up_dates']),
              nextfollowupdates: item['next_follow_up_dates'] != null
                  ? parseCustomDate(item['next_follow_up_dates'])
                  : null,
              notes: item['notes'] ?? '',
              treatment: item['treatment'] ?? '',
              status: item['follow_up_status'] == 1 || item['status'] == "1",
              location: item['follow_up_location'] ?? '',
              symptomsComplaints: item['symptoms_complaints'] ?? '',
              findings: item['findings'] ?? '',
              investigation: item['investigation'] ?? '',
              intervention: item['intervention'] ?? '',
              docQualification: item['doc_qualification'] ?? '',
              registrationNumber: item['registration_number'] ?? '',
              signs: item['signs'] ?? '', // NEW: Parse signs from API
            );

            // Process investigation images
            if (item['investigation_image'] != null) {
              dynamic invImages = item['investigation_image'];
              if (invImages is String) {
                try {
                  invImages = json.decode(invImages);
                } catch (e) {
                  invImages = [];
                }
              }

              if (invImages is List) {
                entry.uploadedFiles['investigation_image'] = invImages.map<Map<String, dynamic>>((img) {
                  return {
                    'id': img['id'],
                    'file_path': img['file_path'],
                    'name': path.basename(img['file_path']?.toString() ?? 'unknown'),
                    'type': path.extension(img['file_path']?.toString() ?? '').replaceAll('.', '').toUpperCase(),
                    'size': '',
                    'isExisting': true,
                  };
                }).toList();
              }
            }

            if (item['treatment_image'] != null && item['treatment_image'] is List) {
              entry.uploadedFiles['treatment_image'] = (item['treatment_image'] as List).map((img) {
                return {
                  'id': img['id'],
                  'file_path': img['file_path'],
                  'name': path.basename(img['file_path']?.toString() ?? 'unknown'),
                  'type': path.extension(img['file_path']?.toString() ?? '').replaceAll('.', '').toUpperCase(),
                  'size': '',
                  'isExisting': true,
                };
              }).toList();
            }
// In the map function where you process follow-up entries:

// Process treatment prescribed images if they exist
            if (item['treamtment_prescibed'] != null) {
              dynamic treatmentPrescribed = item['treamtment_prescibed'];
              if (treatmentPrescribed is String) {
                try {
                  treatmentPrescribed = json.decode(treatmentPrescribed);
                } catch (e) {
                  treatmentPrescribed = [];
                }
              }

              if (treatmentPrescribed is List) {
                entry.uploadedFiles['treamtment_prescibed'] = treatmentPrescribed.map<Map<String, dynamic>>((img) {
                  return {
                    'id': img['id'],
                    'file_path': img['file_path'],
                    'name': path.basename(img['file_path']?.toString() ?? 'unknown'),
                    'type': path.extension(img['file_path']?.toString() ?? '').replaceAll('.', '').toUpperCase(),
                    'size': '',
                    'isExisting': true,
                  };
                }).toList();
              }
            }
            // Process medications if they exist
            if (item['prescriptions'] != null) {
              try {
                dynamic prescriptions = item['prescriptions'];
                if (prescriptions is String) {
                  prescriptions = json.decode(prescriptions);
                }

                if (prescriptions is List) {
                  for (var med in prescriptions) {
                    if (med['status'] != 0) { // Only add active medications
                      entry.addMedicationRow(
                        id: med['id']?.toString(),
                        name: med['name_of_medication'] ?? '',
                        dosage: med['dosage'] ?? '',
                        frequency: med['frequency'] ?? '',
                        duration: med['duration'] ?? '',
                      );
                    }
                  }
                }
              } catch (e) {
                print('Error parsing prescriptions: $e');
              }
            }

            return entry;
          }).toList();

          isEditingList = List<bool>.generate(followUpEntries.length, (index) => false);

          if (followUpEntries.isEmpty) {
            followUpEntries.add(FollowUpEntry());
            isEditingList.add(true);
          } else {
            _hasInitialData = true;
          }
        });
      }
    } catch (e) {
      print('Error fetching follow-ups: $e');
      showTopRightToast(
        context,
        'Error fetching follow-up data',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addFollowUp() {
    if (_isAddingFollowUp) {
      showTopRightToast(
          context,
          'Please complete the current follow-up before adding another',
          backgroundColor: Colors.orange
      );
      return;
    }

    setState(() {
      _isAddingFollowUp = true;

      // Create a completely fresh entry
      final newEntry = FollowUpEntry(
        id: null,
        date: null,
        nextfollowupdates: null,
        notes: '',
        treatment: '',
        status: true,
        location: '',
        symptomsComplaints: '',
        findings: '',
        investigation: '',
        intervention: '',
        docQualification: '',
        registrationNumber: '',
        signs: '',
        uploadedFiles: {
          "investigation_image": [],
          "treatment_image": [],
          "treamtment_prescibed": [],
        },
      );

      // Clear any existing controllers just to be sure
      newEntry.notesController.clear();
      newEntry.treatmentController.clear();
      newEntry.locationController.clear();
      newEntry.symptomscomplaintsController.clear();
      newEntry.findingsController.clear();
      newEntry.investigationController.clear();
      newEntry.interventionController.clear();
      newEntry._docQualificationController.clear();
      newEntry._registrationNumberController.clear();
      newEntry.signsController.clear();

      // Clear medication controllers
      newEntry.medNameControllers.clear();
      newEntry.medDosageControllers.clear();
      newEntry.medFrequencyControllers.clear();
      newEntry.medDurationControllers.clear();
      newEntry.medicationIds.clear();
      newEntry.deletedMedications.clear();

      followUpEntries.insert(0, newEntry);
      isEditingList.insert(0, true);

      print('Added new entry at index 0. Total entries: ${followUpEntries.length}');
      print('New entry date: ${newEntry.date}, next date: ${newEntry.nextfollowupdates}');
    });
  }

  void _cancelEditOrDelete(int index) {
    final entry = followUpEntries[index];
    if (entry.id == null) {
      // Unsaved → delete
      setState(() {
        followUpEntries.removeAt(index);
        isEditingList.removeAt(index);
        _isAddingFollowUp = false;
      });
    } else {
      // Existing → just exit edit mode
      setState(() {
        isEditingList[index] = false;
      });
    }
  }

  // Add this method to toggle edit state
  void _toggleEditMode(int index) {
    setState(() {
      isEditingList[index] = !isEditingList[index];
    });
  }

  Future<void> _UpdateSingleFollowUp(int index) async {
    final entry = followUpEntries[index];
    if (entry.date == null) {
      showTopRightToast(context, 'Please select a date', backgroundColor: Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        showTopRightToast(
            context,
            'Authentication token not found. Please login again.',
            backgroundColor: Colors.red
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$localurl/follow_up_date'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({
        'id': entry.id?.toString() ?? '',
        'patient_id': widget.patientId,
        'follow_up_dates': DateFormat('dd-MM-yyyy').format(entry.date!),
        'next_follow_up_dates': entry.nextfollowupdates != null
            ? DateFormat('dd-MM-yyyy').format(entry.nextfollowupdates!)
            : '',
        'notes': entry.notesController.text,
        'treatment': entry.treatmentController.text,
        'follow_up_status': '1',
        'follow_up_location': entry.locationController.text,
        'symptoms_complaints': entry.symptomscomplaintsController.text,
        'findings': entry.findingsController.text,
        'investigation': entry.investigationController.text,
        'intervention': entry.interventionController.text,
        'signs': entry.signsController.text, // NEW: Add signs to API request
        'doc_qualification': entry._docQualificationController.text,
        'registration_number': entry._registrationNumberController.text,
        'prescriptions': jsonEncode(entry.getMedicationPayload())
      });

      // Add investigation images
      List<String> existingInvestigationFiles = [];
      for (var file in entry.uploadedFiles['investigation_image']!) {
        if (file['isExisting'] == true) {
          existingInvestigationFiles.add(file['id'].toString());
        } else if (file['path'] != null) {
          if (kIsWeb && file['bytes'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'investigation_image',
              file['bytes']!,
              filename: file['name'],
            ));
          } else if (!kIsWeb) {
            request.files.add(await http.MultipartFile.fromPath(
              'investigation_image',
              file['path']!,
              filename: file['name'],
            ));
          }
        }
      }

      // Add treatment images
      List<String> existingTreatmentFiles = [];
      for (var file in entry.uploadedFiles['treatment_image']!) {
        if (file['isExisting'] == true) {
          existingTreatmentFiles.add(file['id'].toString());
        } else if (file['path'] != null) {
          if (kIsWeb && file['bytes'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'treatment_image',
              file['bytes']!,
              filename: file['name'],
            ));
          } else if (!kIsWeb) {
            request.files.add(await http.MultipartFile.fromPath(
              'treatment_image',
              file['path']!,
              filename: file['name'],
            ));
          }
        }
      }

      // ✅ NEW: Add treatment prescribed images
      List<String> existingTreatmentPrescribedFiles = [];
      for (var file in entry.uploadedFiles['treamtment_prescibed']!) {
        if (file['isExisting'] == true) {
          existingTreatmentPrescribedFiles.add(file['id'].toString());
        } else if (file['path'] != null) {
          if (kIsWeb && file['bytes'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'treamtment_prescibed', // Field name for API
              file['bytes']!,
              filename: file['name'],
            ));
          } else if (!kIsWeb) {
            request.files.add(await http.MultipartFile.fromPath(
              'treamtment_prescibed', // Field name for API
              file['path']!,
              filename: file['name'],
            ));
          }
        }
      }

      if (existingInvestigationFiles.isNotEmpty) {
        request.fields['existing_investigation_files'] = existingInvestigationFiles.join(',');
      }
      if (existingTreatmentFiles.isNotEmpty) {
        request.fields['existing_treatment_files'] = existingTreatmentFiles.join(',');
      }
      // ✅ NEW: Add existing treatment prescribed files
      if (existingTreatmentPrescribedFiles.isNotEmpty) {
        request.fields['existing_treatment_prescribed_files'] = existingTreatmentPrescribedFiles.join(',');
      }
print("existingTreatmentPrescribedFiles");
print(existingTreatmentPrescribedFiles);
      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);
      print("responseData");
      print(responseData);
      if (response.statusCode == 200) {
        showTopRightToast(
            context,
            'Follow-up saved successfully',
            backgroundColor: Colors.green
        );
        setState(() {
          isEditingList[index] = false;
          _isAddingFollowUp = false;
          _fetchFollowUpData();
        });
      } else {
        showTopRightToast(
            context,
            'Error saving follow-up: ${responseData['message']}',
            backgroundColor: Colors.red
        );
      }
    } catch (e) {
      print('Error in _UpdateSingleFollowUp: $e');
      showTopRightToast(
          context,
          'Error: ${e.toString()}',
          backgroundColor: Colors.red
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary,
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: PermissionService().canEditPatients,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: ResponsiveUtils.scaleWidth(context, 150),
                  child: Animatedbutton(
                    onPressed: _isAddingFollowUp ? null : _addFollowUp,
                    shadowColor: Colors.white,
                    titlecolor: Colors.white,
                    backgroundColor: AppColors.secondary,
                    borderColor: AppColors.secondary,
                    isLoading: false,
                    title: '+ Follow up',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...followUpEntries.asMap().entries.map(
                (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Follow up ${followUpEntries.length - entry.key}',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        if (!isEditingList[entry.key])
                          Row(
                            spacing: 10,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.green.withOpacity(0.7)),
                                  child: Text('Saved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w200))),
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                                onPressed: () => _toggleEditMode(entry.key),
                              ),
                            ],
                          ),
                        if (isEditingList[entry.key])
                          Visibility(
                            visible: PermissionService().canEditPatients,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check_rounded, color: AppColors.primary),
                                  onPressed: () => _UpdateSingleFollowUp(entry.key),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close_rounded, color: Colors.red),
                                  onPressed: () => _cancelEditOrDelete(entry.key),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                        builder: (context, constraints) {
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
                            runSpacing: 12,
                            spacing: 16,
                            alignment: WrapAlignment.start,
                            children: [
                              DatePickerInput(
                                key: ValueKey('date_${entry.key}_${entry.value.date}'), // Unique key forces rebuild
                                label: 'Date',
                                hintlabel: 'Date',
                                initialDate: entry.value.date,
                                onDateSelected: (date) {
                                  setState(() {
                                    entry.value.date = date;
                                  });
                                },
                              ),

                              FormInput(
                                controller: entry.value.notesController,
                                label: 'Symptoms if any',
                                hintlabel: 'Enter Symptoms',
                                maxlength: 4,
                              ),

                              FormInput(
                                controller: entry.value.treatmentController,
                                label: 'Treatment',
                                hintlabel: 'Enter treatment',
                                maxlength: 4,
                              ),
                              DatePickerInput(
                                key: ValueKey('date_${entry.key}_${entry.value.date}'), // Unique key forces rebuild
                                label: 'Next follow up date',
                                hintlabel: 'Next follow up date',
                                initialDate: entry.value.nextfollowupdates,
                                onDateSelected: (date) {
                                  setState(() {
                                    entry.value.nextfollowupdates = date;
                                  });
                                },
                              ),
                              FormInput(
                                controller: entry.value.locationController,
                                label: 'Location',
                                hintlabel: 'Enter Location',
                                maxlength: 1,
                              ),

                              FormInput(
                                controller: entry.value.symptomscomplaintsController,
                                label: 'Symptoms/Complaints',
                                hintlabel: 'Enter Symptoms/Complaints',
                                maxlength: 1,
                              ),

                              FormInput(
                                controller: entry.value.findingsController,
                                label: 'Add Findings',
                                hintlabel: 'Enter Findings',
                                maxlength: 1,
                              ),
                              FormInput(
                                controller: entry.value.investigationController,
                                label: 'Suggested Investigation',
                                hintlabel: 'Enter investigation',
                                maxlength: 1,
                              ),

                              FormInput(
                                controller: entry.value.signsController, // NEW: Signs controller
                                label: 'Signs',
                                hintlabel: 'Enter Signs',
                                maxlength: 1,
                              ),
                            ].map((child) {
                              return SizedBox(
                                width: itemWidth,
                                child: child,
                              );
                            }).toList(),
                          );
                        }
                    ),
                    const SizedBox(height: 12),
                    DocumentUploadWidget(
                      label: "Upload Investigation",
                      docType: "investigation_image",
                      onFilesSelected: (files) {
                        setState(() {
                          entry.value.uploadedFiles['investigation_image'] = files;
                        });
                      },
                      initialFiles: entry.value.uploadedFiles['investigation_image']!,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                        builder: (context, constraints) {
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
                            runSpacing: 12,
                            children: [
                              FormInput(
                                controller: entry.value.interventionController,
                                label: 'Intervention if Any',
                                hintlabel: 'Enter intervention',
                                maxlength: 1,
                              ),
                            ].map((child) {
                              return SizedBox(
                                width: itemWidth,
                                child: child,
                              );
                            }).toList(),
                          );
                        }
                    ),

                    const SizedBox(height: 12),
                    DocumentUploadWidget(
                      label: "Upload Intervention",
                      docType: "treatment_image",
                      onFilesSelected: (files) {
                        setState(() {
                          entry.value.uploadedFiles['treatment_image'] = files;
                        });
                      },
                      initialFiles: entry.value.uploadedFiles['treatment_image']!,
                    ),
                    const SizedBox(height: 12),
                    DocumentUploadWidget(
                      label: "Treatment Prescribed",
                      docType: "treamtment_prescibed",
                      onFilesSelected: (files) {
                        setState(() {
                          entry.value.uploadedFiles['treamtment_prescibed'] = files;
                        });
                      },
                      initialFiles: entry.value.uploadedFiles['treamtment_prescibed']!,
                    ),

                  */
/*  const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.Containerbackground),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Medication Table
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
                                      onPressed: () {
                                        setState(() {
                                          entry.value.addMedicationRow();
                                        });
                                      },
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
                                                  Text( _patientName,
                                                    //'${_firstNameController.text} ${_lastNameController.text}',
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
                                                  Text('$_patientAge years',
                                                    //'${_ageController.text} years',
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
                                                  controller: entry.value._docQualificationController,
                                                  label: 'Doctor Qualification',
                                                  hintlabel: 'Enter Doctor Qualification',

                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: FormInput(
                                                  controller: entry.value._registrationNumberController,
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
                                      itemCount: entry.value.medNameControllers.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: index == entry.value.medNameControllers.length - 1
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
                                                      controller: entry.value.medNameControllers[index],
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
                                                      controller: entry.value.medDosageControllers[index],
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
                                                      controller: entry.value.medFrequencyControllers[index],
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
                                                      controller: entry.value.medDurationControllers[index],
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
                                                            color: entry.value.medNameControllers.length > 1
                                                                ? Colors.red
                                                                : Colors.grey),
                                                        onPressed: entry.value.medNameControllers.length > 1
                                                            ? () {
                                                          setState(() {
                                                            entry.value.removeMedicationRow(index);
                                                          });
                                                        }
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
                        ],
                      ),
                    ),*/
/*

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildHeaderCell(String text, [double? width]) {
  return Container(
    width: width,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      border: Border(right: BorderSide(color: Colors.grey.shade300)),
    ),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildCell(Widget child, {double? width}) {
  return Container(
    width: width,
    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    decoration: BoxDecoration(
      border: Border(right: BorderSide(color: Colors.grey.shade300)),
    ),
    child: child,
  );
}

class FollowUpEntry {
  int? id;
  DateTime? date;
  DateTime? nextfollowupdates;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController symptomscomplaintsController = TextEditingController();
  final TextEditingController findingsController = TextEditingController();
  final TextEditingController investigationController = TextEditingController();
  final TextEditingController interventionController = TextEditingController();
  final TextEditingController _docQualificationController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController signsController = TextEditingController(); // NEW: Signs controller
  bool status;
  final Map<String, List<Map<String, dynamic>>> uploadedFiles;

  // Medication-related properties moved to FollowUpEntry
  final List<TextEditingController> medNameControllers = [];
  final List<TextEditingController> medDosageControllers = [];
  final List<TextEditingController> medFrequencyControllers = [];
  final List<TextEditingController> medDurationControllers = [];
  final List<String> medicationIds = []; // can hold int or ""
  final List<Map<String, dynamic>> deletedMedications = [];

  FollowUpEntry({
    this.id,
    this.date,
    this.nextfollowupdates,
    String? notes,
    String? treatment,
    this.status = true,
    String? location,
    String? symptomsComplaints,
    String? findings,
    String? investigation,
    String? intervention,
    String? docQualification,
    String? registrationNumber,
    String? signs, // NEW: Add signs parameter
    Map<String, List<Map<String, dynamic>>>? uploadedFiles,
  }) : uploadedFiles = uploadedFiles ?? {
    "investigation_image": [],
    "treatment_image": [],
    "treamtment_prescibed": [],
  } {
    if (notes != null) notesController.text = notes;
    if (treatment != null) treatmentController.text = treatment;
    if (location != null) locationController.text = location;
    if (symptomsComplaints != null) symptomscomplaintsController.text = symptomsComplaints;
    if (findings != null) findingsController.text = findings;
    if (investigation != null) investigationController.text = investigation;
    if (intervention != null) interventionController.text = intervention;
    if (docQualification != null) _docQualificationController.text = docQualification;
    if (registrationNumber != null) _registrationNumberController.text = registrationNumber;
    if (signs != null) signsController.text = signs; // NEW: Initialize signs controller


   // addMedicationRow(count: 2);
  }
// Factory method for creating an empty FollowUpEntry with cleared dates

  void addMedicationRow({int count = 1, String? id, String name = '', String dosage = '', String frequency = '', String duration = ''}) {
    for (int i = 0; i < count; i++) {
      medNameControllers.add(TextEditingController(text: name));
      medDosageControllers.add(TextEditingController(text: dosage));
      medFrequencyControllers.add(TextEditingController(text: frequency));
      medDurationControllers.add(TextEditingController(text: duration));
      medicationIds.add(id ?? "");
    }
  }

  void removeMedicationRow(int index) {
    // If this is an existing medication, mark it as deleted
    if (medicationIds[index].isNotEmpty) {
      deletedMedications.add({
        "id": medicationIds[index],
        "name_of_medication": medNameControllers[index].text,
        "dosage": medDosageControllers[index].text,
        "frequency": medFrequencyControllers[index].text,
        "duration": medDurationControllers[index].text,
        "status": 0, // 0 means deleted
      });
    }

    medNameControllers.removeAt(index).dispose();
    medDosageControllers.removeAt(index).dispose();
    medFrequencyControllers.removeAt(index).dispose();
    medDurationControllers.removeAt(index).dispose();
    medicationIds.removeAt(index);
  }

  List<Map<String, dynamic>> getMedicationPayload() {
    List<Map<String, dynamic>> medications = [];

    // Add active medications
    for (int i = 0; i < medNameControllers.length; i++) {
      medications.add({
        "id": medicationIds[i] == null ? "" : medicationIds[i],
        "name_of_medication": medNameControllers[i].text,
        "dosage": medDosageControllers[i].text,
        "frequency": medFrequencyControllers[i].text,
        "duration": medDurationControllers[i].text,
        "status": 1,
      });
    }

    // Add deleted medications
    medications.addAll(deletedMedications);

    return medications;
  }
  void dispose() {
    notesController.dispose();
    treatmentController.dispose();
    locationController.dispose();
    symptomscomplaintsController.dispose();
    findingsController.dispose();
    investigationController.dispose();
    interventionController.dispose();
    _docQualificationController.dispose();
    _registrationNumberController.dispose();
    signsController.dispose(); // NEW: Dispose signs controller

    // Dispose medication controllers
    for (var controller in medNameControllers) {
      controller.dispose();
    }
    for (var controller in medDosageControllers) {
      controller.dispose();
    }
    for (var controller in medFrequencyControllers) {
      controller.dispose();
    }
    for (var controller in medDurationControllers) {
      controller.dispose();
    }
  }
}*/
