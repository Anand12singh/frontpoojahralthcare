import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/DatePickerInput.dart';
import '../../widgets/showTopSnackBar.dart';
import 'Patient_Registration.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/show_dialog.dart';
import '../../constants/base_url.dart';

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
  @override
  void initState() {
    super.initState();
    _fetchFollowUpData();
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
          followUpEntries = data.map((item) => FollowUpEntry(
            id: item['id'],
            date: DateTime.parse(item['follow_up_dates']),
            nextfollowupdates: item['next_follow_up_dates'] != null
                ? DateTime.parse(item['next_follow_up_dates'])
                : null,
            notes: item['notes'] ?? '',
            treatment: item['treatment'] ?? '',
            status: item['follow_up_status'] == 1,
          )).toList();
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
       showTopRightToast(context, 'Error fetching follow-ups: $e',
           backgroundColor: Colors.red);
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
      followUpEntries = [...followUpEntries];
      isEditingList = [...isEditingList];
      followUpEntries.insert(0, FollowUpEntry());
      isEditingList.insert(0, true);
    });
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
      showTopRightToast(context, 'Please select a  next follow up date', backgroundColor: Colors.red);
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

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',

      };

      final endpoint = '$localurl/follow_up_date';
      final Map<String, dynamic> requestBody = {
        "id":entry.id,
        "patient_id": widget.patientId,
        "follow_up_dates": DateFormat('dd-MM-yyyy').format(entry.date!),
        "next_follow_up_dates": entry.nextfollowupdates != null
            ? DateFormat('dd-MM-yyyy').format(entry.nextfollowupdates!)
            : null,
        "notes": entry.notesController.text,
        "treatment": entry.treatmentController.text,
        "follow_up_status": 1
      };



      final body = json.encode(requestBody);
      print("body");
      print(body);
      final response =  await http.post(Uri.parse(endpoint), headers: headers, body: body);

      if (response.statusCode == 200) {
        showTopRightToast(context, 'Follow-up saved successfully', backgroundColor: Colors.green);
        setState(() {
          isEditingList[index] = false;
          _isAddingFollowUp = false; // Reset the flag
          _fetchFollowUpData();
        });
      } else {
        final responseData = json.decode(response.body);
        showTopRightToast(
            context,
            'Error saving follow-up: ${responseData['message']}',
            backgroundColor: Colors.red
        );
        print(response.statusCode);
        print(endpoint);
        print(responseData['message']);
      }
    } catch (e) {
      print(e);
      showTopRightToast(context, 'Error: $e', backgroundColor: Colors.red);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Animatedbutton(
                onPressed: _isAddingFollowUp ? null : _addFollowUp,
                shadowColor: Colors.white,
                titlecolor: Colors.white,
                backgroundColor: AppColors.secondary,
                borderColor: AppColors.secondary,
                isLoading: false,
                title: '+ Follow up',
              ),
            ],
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
                          IconButton(
                            icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                            onPressed: () => _toggleEditMode(entry.key),
                          ),
                        if (isEditingList[entry.key])
                          Row(
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
                                onPressed: () => _toggleEditMode(entry.key),
                              ),
                            ],
                          )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      runSpacing: 12,
                    spacing: 16,
                 alignment: WrapAlignment.spaceBetween,
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
                      ],
                    ),

                    const SizedBox(width: 12),
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
  bool status;

  FollowUpEntry({
    this.id,
    this.date,
    this.nextfollowupdates,
    String? notes,
    String? treatment,
    this.status = true,
  }) {
    if (notes != null) notesController.text = notes;
    if (treatment != null) treatmentController.text = treatment;
  }

  void dispose() {
    notesController.dispose();
    treatmentController.dispose();
  }
}