import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:poojaheakthcare/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:poojaheakthcare/widgets/AnimatedButton.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../constants/base_url.dart';
import '../../provider/PermissionService.dart';
import '../../utils/colors.dart';
import '../../widgets/DatePickerInput.dart';
import '../../widgets/DocumentUploadWidget.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/showTopSnackBar.dart';
import '../../widgets/show_dialog.dart';


class SurgeryTabContent extends StatefulWidget {
  final String patientId;
  const SurgeryTabContent({super.key, required this.patientId});

  @override
  State<SurgeryTabContent> createState() => _SurgeryTabContentState();
}

class _SurgeryTabContentState extends State<SurgeryTabContent> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  var postOperationId;

  // Controllers
  final TextEditingController _surgeryController = TextEditingController();
  final TextEditingController _surgeonController = TextEditingController();
  final TextEditingController _assistantController = TextEditingController();
  final TextEditingController _anaesthetistController = TextEditingController();
  final TextEditingController _anaesthesiaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _findingsController = TextEditingController();
  final TextEditingController _procedureController = TextEditingController();
  final TextEditingController _implantsController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _furtherPlanController = TextEditingController();
  final TextEditingController _timetakenHrController = TextEditingController();
  final TextEditingController _timetakenMinController = TextEditingController();
  final TextEditingController _complicationsController = TextEditingController();

  DateTime? _selectedDate;
  final Map<String, List<Map<String, dynamic>>> _uploadedFiles = {
    "implants_image": []
  };
  final Map<String, List<String>> _deletedFiles = {};

  // Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // File Picker
  Future<void> _pickImage() async {
    final pickedFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
      withData: true,
    );

    if (pickedFiles != null && pickedFiles.files.isNotEmpty) {
      setState(() {
        _uploadedFiles['implants_image'] ??= [];
        _uploadedFiles['implants_image']!.addAll(pickedFiles.files.map((file) {
          return {
            'bytes': file.bytes!,
            'name': file.name,
            'type': path.extension(file.name).replaceAll('.', '').toLowerCase(),
            'isExisting': false,
          };
        }).toList());
      });
    }
  }

  // Remove File
  Future<void> _removeFile(String reportType, Map<String, dynamic> file) async {
    try {
      if (file['isExisting'] == true) {
        _deletedFiles[reportType] ??= [];
        _deletedFiles[reportType]!.add(file['id'].toString());
      }
      setState(() {
        _uploadedFiles[reportType]!.remove(file);
      });
    } catch (e) {
      log('Failed to delete file: ${e.toString()}');
      showTopRightToast(context,'Failed to delete file: ${e.toString()}',backgroundColor: Colors.red);

    }
  }

  // Date Picker Widget
  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                const Icon(Icons.calendar_month_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Image Upload Widget
  Widget _buildImageUploadField() {
    final hasImages = _uploadedFiles['implants_image']?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DocumentUploadWidget(
          label: "Implants",
          docType: "discharge_images",
          onFilesSelected: (files) {
            setState(() {
              _uploadedFiles['implants_image'] = files;
            });
          },
          initialFiles: _uploadedFiles['implants_image'],
        ),
   /*     const Text('Implants', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 4),
        InkWell(
          onTap: _pickImage,
          child: Container(
            width: 300,
            height: 48,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.3),
                width: 1.5,
              )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text('Upload Implants' ,style: TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontSize: 14,
    ),),
      Text('Upload' ,style: TextStyle(

    color: AppColors.secondary,
    fontSize: 14,
    ),),

              //  Icon(Icons.cloud_upload, size: 40, color: AppColors.primary),


              *//*  const SizedBox(height: 4),
                const Text('Supports JPG, PNG, PDF', style: TextStyle(fontSize: 12)),*//*
              ],
            ),
          ),
        ),
        if (hasImages) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _uploadedFiles['implants_image']!.map((file) {
                return Chip(

                backgroundColor: AppColors.surface,

                  shape: RoundedRectangleBorder(
                    side: BorderSide(color:AppColors.textSecondary.withOpacity(0.3),width: 1.5 ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),

                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(file['name'],  style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),),


                    ],
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16,color: Colors.red,),
                  onDeleted: () => _removeFile('implants_image', file),
                );
              }).toList(),
            ),
          ),
        ],*/
      ],
    );
  }

  // Fetch Existing Data
  Future<void> _loadExistingData() async {
    try {
      final response = await http.post(
        Uri.parse('$localurl/get_post_operation'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"patient_id": widget.patientId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            final operationData = data['data'];
            print("operationData");
            print(operationData);
            postOperationId = operationData['id'];
            _surgeryController.text = operationData['surgery'] ?? '';
            _selectedDate = operationData['date'] != null
                ? DateFormat('dd-mm-yyyy').parse(operationData['date'])
                : null;
            _surgeonController.text = operationData['surgeon'] ?? '';
            _assistantController.text = operationData['assistant'] ?? '';
            _anaesthetistController.text = operationData['anaesthetists'] ?? '';
            _anaesthesiaController.text = operationData['anaesthesia'] ?? '';
            _locationController.text = operationData['operation_location'] ?? '';
            _findingsController.text = operationData['findings'] ?? '';
            _procedureController.text = operationData['procedure'] ?? '';
            _implantsController.text = operationData['implants_used'] ?? '';
            _treatmentController.text = operationData['treatment_advised'] ?? '';
            _furtherPlanController.text = operationData['further_plan'] ?? '';
            _complicationsController.text = operationData['complications'] ?? '';

            // Parse time taken
            if (operationData['time_take'] != null) {
              final timeParts = operationData['time_take'].split(' ');
              if (timeParts.length >= 2) {
                _timetakenHrController.text = timeParts[0];
                _timetakenMinController.text = timeParts[2];
              }
            }

            // Handle images
            if (operationData['implants_image'] != null && operationData['implants_image'].isNotEmpty) {
              _uploadedFiles['implants_image'] = List<Map<String, dynamic>>.from(
                operationData['implants_image'].map((image) {
                  return {
                    'id': image['id'],
                    'path': image['image_path'],
                    'name': path.basename(image['image_path']),
                    'type': path.extension(image['image_path']).replaceAll('.', ''),
                    'isExisting': true,
                  };
                }),
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading surgery data: $e');
    }
  }

  // Submit Form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;


    setState(() => _isLoading = true);
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
      
        showTopRightToast(context,'Authentication required',backgroundColor: Colors.red);
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$localurl/postoperations'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Prepare form fields
      Map<String, String> fields = {
        'patient_id': widget.patientId,
        'surgery': _surgeryController.text,

        'surgeon': _surgeonController.text,
        'assistant': _assistantController.text,
        'anaesthetists': _anaesthetistController.text,
        'anaesthesia': _anaesthesiaController.text,
        'findings': _findingsController.text,
        'operation_location': _locationController.text,
        'procedure': _procedureController.text,
        'implants_used': _implantsController.text,
        'treatment_advised': _treatmentController.text,
        'further_plan': _furtherPlanController.text,
        'complications': _complicationsController.text,
        'time_take': '${_timetakenHrController.text} Hr ${_timetakenMinController.text} Min',
      };
      if (_selectedDate != null) {
        fields["date"] =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);
      }

      if (postOperationId != null) {
        fields['id'] = postOperationId.toString();
      }

      request.fields.addAll(fields);
print("request.fields");
print(request.fields);
      // Handle file uploads
      List<String> existingFileIds = [];
      for (var file in _uploadedFiles['implants_image'] ?? []) {
        if (file['isExisting'] == true) {
          existingFileIds.add(file['id'].toString());
        } else if (kIsWeb) {
          if (file['bytes'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'implants_image',
              file['bytes']!,
              filename: file['name'],
            ));
          }
        } else {
          if (file['path'] != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'implants_image',
              file['path']!,
              filename: file['name'],
            ));
          }
        }
      }

      if (existingFileIds.isNotEmpty) {
        request.fields['existing_file'] = existingFileIds.join(',');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        if (result['status'] == true) {
          showTopRightToast(context, 'Surgery details saved successfully',backgroundColor: Colors.green);
          postOperationId = result['data']['id'];
        } else {
          showTopRightToast(context, result['message'] ?? 'Failed to save', backgroundColor: Colors.green);
        }
      } else {
        showTopRightToast(context, 'Error: ${response.statusCode}', backgroundColor: Colors.red);
      }
    } catch (e) {
      print('Error: ${e.toString()}');
     // showTopRightToast(context, 'Error: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();
  }

  @override
  void dispose() {
    _surgeryController.dispose();
    _surgeonController.dispose();
    _assistantController.dispose();
    _anaesthetistController.dispose();
    _anaesthesiaController.dispose();
    _locationController.dispose();
    _findingsController.dispose();
    _procedureController.dispose();
    _implantsController.dispose();
    _treatmentController.dispose();
    _furtherPlanController.dispose();
    _timetakenHrController.dispose();
    _timetakenMinController.dispose();
    _complicationsController.dispose();
    super.dispose();
  }
  double responsiveWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth > 800 ? 600 : screenWidth * 0.8).toDouble();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final formFieldWidth = responsiveWidth(context);
    final fieldSpacing = isLargeScreen ? 16.0 : 8.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
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
               Text('1. Surgery Details', style: TextStyle(      fontSize: ResponsiveUtils.fontSize(context, 18), fontWeight: FontWeight.bold,)),
              const SizedBox(height: 16),


              // Row 1 - Modified to be responsive
              if (isLargeScreen) ...[
                Row(
                  children: [
                    Container(
                      width:  screenWidth * 0.313,
                      child: _buildFormInput('Surgery', _surgeryController),
                    ),
                    SizedBox(width: fieldSpacing),
                    Expanded(
                      child: DatePickerInput(
                        label: 'Date',

                        initialDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                        hintlabel: 'Date',
                      ),
                    ),
                    SizedBox(width: fieldSpacing),
                    Expanded(child: _buildFormInput('Surgeon', _surgeonController)),
                  ],
                ),
              ] else ...[
                Column(
                  children: [
                    _buildFormInput('Surgery', _surgeryController),
                    SizedBox(height: fieldSpacing),
                    DatePickerInput(
                      label: 'Date',
                      initialDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                      },
                      hintlabel: '',
                    ),
                    SizedBox(height: fieldSpacing),
                    _buildFormInput('Surgeon', _surgeonController),
                  ],
                ),
              ],
              SizedBox(height: fieldSpacing),

              // Row 2 - Modified to be responsive
              if (isLargeScreen) ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final timeFieldWidth = isMobile ? constraints.maxWidth * 1.0 : 285.0; // Explicitly convert to double

                    return Wrap(
                      spacing: fieldSpacing,
                      runSpacing: fieldSpacing,
                      alignment: WrapAlignment.start,
                      children: [
                        SizedBox(
                          width: isMobile ? constraints.maxWidth * 1.0 : constraints.maxWidth * 0.240, // Convert to double
                          child: _buildFormInput('Assistant', _assistantController),
                        ),
                        SizedBox(
                          width: isMobile ? constraints.maxWidth * 1.0 : constraints.maxWidth * 0.240, // Convert to double
                          child: _buildFormInput('Anaesthetist/s', _anaesthetistController),
                        ),
                        SizedBox(
                          width: isMobile ? constraints.maxWidth * 1.0 : constraints.maxWidth * 0.240, // Convert to double
                          child: _buildFormInput('Anaesthesia', _anaesthesiaController),
                        ),
                        Container(
                          width: timeFieldWidth, // Now properly typed as double
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text('Time Taken:',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: ResponsiveUtils.fontSize(context, 14))),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: CustomTextField(
                                      maxLength: 2,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                      ],
                                      controller: _timetakenHrController,
                                      hintText: '00',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Hr',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 60,
                                    child: CustomTextField(
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                      ],
                                      maxLength: 2,
                                      controller: _timetakenMinController,
                                      hintText: '00',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Min',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
              ] else ...[
                Column(
                  children: [
                    _buildFormInput('Assistant', _assistantController),
                    SizedBox(height: fieldSpacing),
                    _buildFormInput('Anaesthetist/s', _anaesthetistController),
                    SizedBox(height: fieldSpacing),
                    _buildFormInput('Anaesthesia', _anaesthesiaController),
                    SizedBox(height: fieldSpacing),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Time taken:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: ResponsiveUtils.fontSize(context, 14))),
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: CustomTextField(
                                maxLength: 2,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
                                controller: _timetakenHrController,
                                hintText: '00',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Hr', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 60,
                              child: CustomTextField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
                                maxLength: 2,
                                controller: _timetakenMinController,
                                hintText: '00',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Min', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              SizedBox(height: fieldSpacing),

              // Row 3 - Modified to be responsive
              if (isLargeScreen) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width:  screenWidth * 0.313,
                      child: _buildFormInput('Location', _locationController, maxLines: 1),
                    ),
                    SizedBox(width: fieldSpacing),
                    Expanded(child: _buildFormInput('Findings', _findingsController, maxLines: 3)),
                    SizedBox(width: fieldSpacing),
                    Expanded(child: _buildFormInput('Implants used, if any', _implantsController, maxLines: 3)),
                  ],
                ),
              ] else ...[
                Column(
                  children: [
                    _buildFormInput('Location', _locationController, maxLines: 1),
                    SizedBox(height: fieldSpacing),
                    _buildFormInput('Findings', _findingsController, maxLines: 3),
                    SizedBox(height: fieldSpacing),
                    _buildFormInput('Implants used, if any', _implantsController, maxLines: 3),
                  ],
                ),
              ],
              SizedBox(height: fieldSpacing),

              // Implants Upload
              _buildImageUploadField(),
              SizedBox(height: fieldSpacing),

              // Row 4 - Modified to be responsive
              _buildFormInput('Complications, if any', _complicationsController, maxLines: 3),
              SizedBox(height: fieldSpacing),

              // Procedure
              _buildFormInput('Procedure', _procedureController, maxLines: 4),
              SizedBox(height: fieldSpacing),

              // Notes
              _buildFormInput('Notes', _furtherPlanController, maxLines: 2),
              SizedBox(height: 20),

              // Buttons
              Visibility(
                visible:PermissionService().canEditPatients ,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: ResponsiveUtils.scaleWidth(context, 150),
                      child: Animatedbutton(
                        onPressed: () => Navigator.pop(context),
                        shadowColor: Colors.white,
                        titlecolor: AppColors.primary,
                        backgroundColor: Colors.white,
                        borderColor: AppColors.secondary,
                        isLoading: false,
                        title: 'Cancel',
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: ResponsiveUtils.scaleWidth(context, 150),
                      child: Animatedbutton(
                        onPressed: _submitForm,
                        shadowColor: Colors.white,
                        backgroundColor: AppColors.secondary,
                        isLoading: _isLoading,
                        title: 'Save',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormInput(String label, TextEditingController controller, {int maxLines = 1}) {
    String _toCamelCase(String text) {
      if (text.isEmpty) return text;

      return text
          .split(' ')
          .map((word) =>
      word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '')
          .join(' ');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_toCamelCase(label), style:  TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary,fontSize: ResponsiveUtils.fontSize(context, 14))),
        const SizedBox(height: 4),
        CustomTextField(
          controller: controller,
          maxLines: maxLines,
          hintText: 'Enter $label',
        ),
      ],
    );
  }
}