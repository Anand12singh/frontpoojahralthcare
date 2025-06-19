import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
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
            notes: item['notes'] ?? '',
            treatment: item['treatment'] ?? '',
            status: item['follow_up_status'] == 1,
          )).toList();

          // Add one empty entry if no existing data
          if (followUpEntries.isEmpty) {
            followUpEntries.add(FollowUpEntry());
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
    setState(() {
      followUpEntries.add(FollowUpEntry());
    });
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
           backgroundColor: Colors.red
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
           showTopRightToast(context, 'Please select a date for all follow-ups',
               backgroundColor: Colors.red);
          return;
        }

        final endpoint = entry.id == null
            ? '$localurl/follow_up_date'  // Create new
            : '$localurl/follow_up_date';  // Update existing

        final body = json.encode({
          "patient_id": widget.patientId,
          "follow_up_dates": DateFormat('yyyy-MM-dd').format(entry.date!),
          "notes": entry.notesController.text,
          "treatment": entry.treatmentController.text,
          "follow_up_status": entry.status ? 1 : 0,
        });

        final response = entry.id == null
            ? await http.post(Uri.parse(endpoint), headers: headers, body: body)
            : await http.put(Uri.parse(endpoint), headers: headers, body: body);

        if (response.statusCode != 200) {
          final responseData = json.decode(response.body);
           showTopRightToast(
            context,
            'Error saving follow-up: ${responseData['message']}',
               backgroundColor: Colors.red
          );
          return;
        }
      }

       showTopRightToast(context, 'Follow-ups saved successfully',
           backgroundColor: Colors.green);
      // Refresh data after save
      await _fetchFollowUpData();
    } catch (e) {
       showTopRightToast(context, 'Error: $e',
           backgroundColor: Colors.red);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteFollowUp(int? id, int index) async {
    if (id == null) {
      // Just remove from local list if it's a new entry
      setState(() {
        followUpEntries.removeAt(index);
      });
      return;
    }

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
        'Authorization': 'Bearer $token',
      };

      final response = await http.delete(
        Uri.parse('$localurl/follow_up_date/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
         showTopRightToast(context, 'Follow-up deleted successfully',
             backgroundColor: Colors.green);
        setState(() {
          followUpEntries.removeAt(index);
        });
      } else {
        final responseData = json.decode(response.body);
         showTopRightToast(
          context,
          'Error deleting follow-up: ${responseData['message']}',
             backgroundColor: Colors.red
        );
      }
    } catch (e) {
       showTopRightToast(context, 'Error deleting follow-up: $e',
           backgroundColor: Colors.red);
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
          ...followUpEntries.asMap().entries.map(
                (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Follow up ${entry.key + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (entry.value.id != null || entry.key > 0)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFollowUp(entry.value.id, entry.key),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: FormInput(
                            controller: entry.value.notesController,
                            label: 'Notes',
                            hintlabel: 'Enter notes',
                            maxlength: 4,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FormInput(
                            controller: entry.value.treatmentController,
                            label: 'Treatment',
                            hintlabel: 'Enter treatment',
                            maxlength: 4,
                          ),
                        ),
                      ],
                    ),
                    if (_hasInitialData && entry.value.id != null) ...[
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
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
          ),
          const SizedBox(height: 32),
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
          ),
        ],
      ),
    );
  }
}

class FollowUpEntry {
  int? id;
  DateTime? date;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  bool status;

  FollowUpEntry({
    this.id,
    this.date,
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