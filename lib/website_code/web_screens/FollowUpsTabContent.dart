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
  final Map<String, List<Map<String, dynamic>>> _uploadedFiles = {
    "investigation_image": [],
    "treatment_image": [],
  };

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

            // Create a new FollowUpEntry
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
      followUpEntries.insert(0, FollowUpEntry());
      isEditingList.insert(0, true);
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
        // Clear uploaded files when canceling
        _uploadedFiles['investigation_image']!.clear();
        _uploadedFiles['treatment_image']!.clear();
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
    if (entry.nextfollowupdates == null) {
      showTopRightToast(context, 'Please select a next follow up date', backgroundColor: Colors.red);
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
        'next_follow_up_dates': DateFormat('dd-MM-yyyy').format(entry.nextfollowupdates!),
        'notes': entry.notesController.text,
        'treatment': entry.treatmentController.text,
        'follow_up_status': '1',
        'follow_up_location': entry.locationController.text,
        'symptoms_complaints': entry.symptomscomplaintsController.text,
        'findings': entry.findingsController.text,
        'investigation': entry.investigationController.text,
        'intervention': entry.interventionController.text,
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

      if (existingInvestigationFiles.isNotEmpty) {
        request.fields['existing_investigation_files'] = existingInvestigationFiles.join(',');
      }
      if (existingTreatmentFiles.isNotEmpty) {
        request.fields['existing_treatment_files'] = existingTreatmentFiles.join(',');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

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
  Future<void> _saveFollowUps() async {
    setState(() {
      _isSaving = true;
    });

    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        showTopRightToast(
          context,
          'Authentication token not found. Please login again.',
          backgroundColor: Colors.red,
        );
        return;
      }

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Save all follow-ups
      for (var entry in followUpEntries) {
        if (entry.date == null) {
          showTopRightToast(
            context,
            'Please select a date for all follow-ups',
            backgroundColor: Colors.red,
          );
          return;
        }

        final endpoint = '$localurl/follow_up_date';
        final Map<String, dynamic> requestBody = {
          "patient_id": widget.patientId,
          "follow_up_dates": DateFormat('yyyy-MM-dd').format(entry.date!),
          "next_follow_up_dates": DateFormat('yyyy-MM-dd').format(entry.nextfollowupdates!),
          "notes": entry.notesController.text,
          "treatment": entry.treatmentController.text,
          "follow_up_status": entry.status ? 1 : 0,
        };

        // Add ID only for existing entries
        if (entry.id != null) {
          requestBody['id'] = entry.id;
        }

        final body = json.encode(requestBody);
        print("body");
        print(endpoint);
        print(body);
        final response =  await http.put(Uri.parse(endpoint), headers: headers, body: body);

        if (response.statusCode != 200) {
          final responseData = json.decode(response.body);
          print("responseData['message");
          print(responseData['message']);
          print(responseData['status']);
          showTopRightToast(
            context,
            'Error saving follow-up: ${responseData['message']}',
            backgroundColor: Colors.red,
          );
          return;
        }
      }

      showTopRightToast(
        context,
        'Follow-ups saved successfully',
        backgroundColor: Colors.green,
      );
      setState(() {
        _isAddingFollowUp = false; // Reset the flag
      });

      // Refresh data after save
      await _fetchFollowUpData();
    } catch (e) {

      showTopRightToast(
        context,
        'Error: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
/*  void _cancelEditOrDelete(int index) {
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
  }*/



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
            visible:PermissionService().canEditPatients ,
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
                          style:  TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        if (!isEditingList[entry.key])
                          Row(
                            spacing:10,
                            children: [
                              Container(

                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: Colors.green.withOpacity(0.7)),
                                  child: Text('Saved',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w200),)),
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                                onPressed: () => _toggleEditMode(entry.key),
                              ),
                            ],
                          ),
                        if (isEditingList[entry.key])
                          Visibility(
                            visible:PermissionService().canEditPatients ,
                            child: Row(
                              children: [
                              /*  GestureDetector(
                                  onTap: () => _UpdateSingleFollowUp(entry.key),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedTick04,
                                    color: AppColors.primary,

                                  ),
                                ),*/
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
                          runSpacing: 12,
                        spacing: 16,
                                         alignment: WrapAlignment.start,
                        //  mainAxisAlignment: MainAxisAlignment.start,
                                           //   crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DatePickerInput(
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
                              label: 'Notes',
                              hintlabel: 'Enter notes',
                              maxlength: 4,
                            ),

                            FormInput(
                              controller: entry.value.treatmentController,
                              label: 'Treatment',
                              hintlabel: 'Enter treatment',
                              maxlength: 4,
                            ),
                            DatePickerInput(
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
                              label: 'Add investigation',
                              hintlabel: 'Enter investigation',
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
                      label: "Upload Documents",
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
                            runSpacing: 12,
                            children: [
                              FormInput(
                                controller: entry.value.interventionController,
                                label: 'Add intervention',
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
                      label: "Upload Documents",
                      docType: "treatment_image",
                      onFilesSelected: (files) {
                        setState(() {
                          entry.value.uploadedFiles['treatment_image'] = files;
                        });
                      },
                      initialFiles: entry.value.uploadedFiles['treatment_image']!,
                    ),
                    const SizedBox(width: 16),
                 /*   if (_hasInitialData && entry.value.id != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Status: '),
                          Switch(
                            value: entry.value.status,
                            onChanged: (value) {
                              setState(() {
                                entry.value.status = value;
                              });
                            },
                            activeColor: AppColors.secondary,
                          ),
                          Text(entry.value.status ? 'Active' : 'Inactive'),
                        ],
                      ),
                    ],*/
                  ],
                ),
              ),
            ),
          ),
     /*     const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                style: ButtonStyle(shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))))),
                icon: const Icon(
                  Icons.add_box_rounded,
                  color: AppColors.secondary,
                  size: 40,
                ),
                onPressed: _addFollowUp,
              ),
            ],
          ),*/
          //const SizedBox(height: 32),
          /*
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
                onPressed: _saveFollowUps,
                shadowColor: Colors.white,
                backgroundColor: AppColors.secondary,
                isLoading: _isSaving,
                title: _hasInitialData ? 'Update' : 'Save',
              ),
            ],
          ),*/
        ],
      ),
    );
  }
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
  bool status;
  final Map<String, List<Map<String, dynamic>>> uploadedFiles;

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
    Map<String, List<Map<String, dynamic>>>? uploadedFiles,
  }) : uploadedFiles = uploadedFiles ?? {
    "investigation_image": [],
    "treatment_image": [],
  } {
    if (notes != null) notesController.text = notes;
    if (treatment != null) treatmentController.text = treatment;
    if (location != null) locationController.text = location;
    if (symptomsComplaints != null) symptomscomplaintsController.text = symptomsComplaints;
    if (findings != null) findingsController.text = findings;
    if (investigation != null) investigationController.text = investigation;
    if (intervention != null) interventionController.text = intervention;
  }

  void dispose() {
    notesController.dispose();
    treatmentController.dispose();
    locationController.dispose();
    symptomscomplaintsController.dispose();
    findingsController.dispose();
    investigationController.dispose();
    interventionController.dispose();
  }
}