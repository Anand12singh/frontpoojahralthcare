import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:poojaheakthcare/services/auth_service.dart';
import 'package:poojaheakthcare/widgets/file_download.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../constants/base_url.dart';
import '../utils/colors.dart';
import '../widgets/inputfild.dart';
import '../widgets/show_dialog.dart';
import 'dishcharge_page.dart';

class PostOperationPage extends StatefulWidget {
  var patient_id;
  PostOperationPage({super.key, this.patient_id});

  @override
  State<PostOperationPage> createState() => _PostOperationPageState();
}

class _PostOperationPageState extends State<PostOperationPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  final TextEditingController _surgeryController = TextEditingController();
  final TextEditingController _surgeonController = TextEditingController();
  final TextEditingController _assistantController = TextEditingController();
  final TextEditingController _anaesthetistController = TextEditingController();
  final TextEditingController _anaesthesiaController = TextEditingController();
  final TextEditingController _findingsController = TextEditingController();
  final TextEditingController _procedureController = TextEditingController();
  final TextEditingController _implantsController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _furtherPlanController = TextEditingController();
  final TextEditingController _timetakenController = TextEditingController();
  final TextEditingController _complicationsController =
      TextEditingController();

  DateTime _selectedDate = DateTime.now();
  File? _implantImage;
  final Map<String, List<Map<String, dynamic>>> _uploadedFiles = {
    "implants_image": []
  };
  final Map<String, List<String>> _deletedFiles = {};
  var postOperationId;

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

  Future<void> _pickImage() async {
    final pickedFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
      withData: true,
    );

    if (pickedFiles != null && pickedFiles.files.isNotEmpty) {
      setState(() {
        // Append new files to existing ones instead of replacing
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

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          InkWell(
            onTap: () => _selectDate(context),
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
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
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

  Widget _buildImageUploadField() {
    final hasImages = _uploadedFiles['implants_image']?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(
                  'Implants Image',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '(Optional)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Upload area
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasImages
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // hasImages
                    //     ? '${_uploadedFiles['implants_image']?.length ?? 0} image(s) uploaded'
                    //     :
                    'Click to upload images',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Supports JPG, PNG, PDF',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Uploaded files section
          if (hasImages) ...[
            const SizedBox(height: 16),
            Text(
              'Uploaded Files',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: _uploadedFiles['implants_image']!
                  .map((file) => _buildFileItem('implants_image', file))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileItem(String reportType, Map<String, dynamic> file) {
    final fileType = (file['type'] ?? '').toLowerCase();
    final isExisting = file['isExisting'] == true;
    final filePath = file['path'] ?? '';
    final fileName = file['name'] ?? 'Unknown';

    return GestureDetector(
      onTap: () {
        if (isExisting) {
          _showFilePreview(context, filePath, fileType, isNetwork: true);
        } else {
          if (kIsWeb) {
            // For web, we might have the file data in bytes
            if (file['bytes'] != null) {
              final base64String = base64Encode(file['bytes']);
              _showFilePreview(
                  context,
                  'data:application/octet-stream;base64,$base64String',
                  fileType);
            } else {
              _showFilePreview(context, filePath, fileType);
            }
          } else {
            _showFilePreview(context, filePath, fileType);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(fileType),
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        fileType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (isExisting)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Existing',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
              onPressed: () => _removeFile(reportType, file),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilePreview(BuildContext context, String filePath, String fileType,
      {bool isNetwork = false}) async {
    if (['jpg', 'jpeg', 'png', 'webp'].contains(fileType.toLowerCase())) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: isNetwork
                    ? Image.network(
                        filePath,
                        fit: BoxFit.contain,
                      )
                    : (kIsWeb
                        ? Image.memory(
                            base64Decode(filePath.split(',').last),
                            fit: BoxFit.contain,
                          )
                        : Image.file(
                            File(filePath),
                            fit: BoxFit.contain,
                          )),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      child: IconButton(
                        icon: Icon(Icons.download, color: Colors.white),
                        onPressed: () async {
                          final fileName =
                              'implant_${DateTime.now().millisecondsSinceEpoch}';
                          if (isNetwork) {
                            await FileDownloader.downloadFile(
                              context: context,
                              url: filePath,
                              fileName: fileName,
                              fileType: fileType,
                            );
                          } else if (kIsWeb) {
                            final bytes =
                                base64Decode(filePath.split(',').last);
                            await FileDownloader.downloadFile(
                              context: context,
                              url: '', // Not needed when we have bytes
                              fileName: fileName,
                              fileType: fileType,
                              bytes: bytes,
                            );
                          } else {
                            await OpenFile.open(filePath);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (fileType.toLowerCase() == 'pdf') {
      // PDF Preview with download option
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('PDF Options'),
          content: Text('Would you like to view or download the PDF?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (isNetwork) {
                  await launchUrl(Uri.parse(filePath));
                } else if (kIsWeb) {
                  final bytes = base64Decode(filePath.split(',').last);
                  // For web, we can't create a blob URL without dart:html
                  // So we'll just show a message to right-click and save
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Right-click on the image and select "Save as"'),
                    ),
                  );
                } else {
                  await OpenFile.open(filePath);
                }
              },
              child: Text('View'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final fileName =
                    'implant_${DateTime.now().millisecondsSinceEpoch}';
                if (isNetwork) {
                  await FileDownloader.downloadFile(
                    context: context,
                    url: filePath,
                    fileName: fileName,
                    fileType: 'pdf',
                  );
                } else if (kIsWeb) {
                  final bytes = base64Decode(filePath.split(',').last);
                  // On web without dart:html, we can't programmatically download
                  // So we'll show a message to right-click and save
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Right-click on the image and select "Save as"'),
                    ),
                  );
                } else {
                  await FileDownloader.downloadFile(
                    context: context,
                    url: filePath,
                    fileName: fileName,
                    fileType: 'pdf',
                  );
                }
              },
              child: Text('Download'),
            ),
          ],
        ),
      );
    } else {
      log('Preview not available for $fileType files');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preview not available for $fileType files')),
      );
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
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
          _buildClickableStep(1, 'Operation Details', 0),
          _buildStepConnector(_currentStep >= 0),
          _buildClickableStep(2, 'Treatment Plan', 1),
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
        return _buildOperationDetailsStep();
      case 1:
        return _buildTreatmentPlanStep();
      default:
        return _buildOperationDetailsStep();
    }
  }

  Widget _buildOperationDetailsStep() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              // flex: 2,
              child: buildCustomInput(
                controller: _surgeryController,
                label: 'Surgery',
                hintText: 'Enter surgery name',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              // flex: 1,
              child: _buildDatePickerField(),
            ),
            // const SizedBox(width: 10),
          ],
        ),
        Row(children: [
          Expanded(
            child: buildCustomInput(
              controller: _surgeonController,
              label: 'Surgeon',
              // isRequired: true,
              hintText: 'Enter surgeon name',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: buildCustomInput(
              controller: _assistantController,
              label: 'Assistant',
              hintText: 'Enter assistant name',
            ),
          ),
        ]),

        Row(
          children: [
            Expanded(
              child: buildCustomInput(
                controller: _anaesthetistController,
                label: 'Anaesthetist/s',
                hintText: 'Enter anaesthetist name',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildCustomInput(
                controller: _anaesthesiaController,
                label: 'Anaesthesia',
                hintText: 'Enter anaesthesia type',
              ),
            ),
          ],
        ),
        buildCustomInput(
          controller: _timetakenController,
          label: 'Time Taken',
          hintText: 'Enter Time Taken',
        ),
        // Findings (multi-line)
        buildCustomInput(
          controller: _findingsController,
          label: 'Findings',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
          hintText: 'Enter findings details',
        ),

        // Procedure (multi-line)
        buildCustomInput(
          controller: _procedureController,
          label: 'Procedure',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
          hintText: 'Enter procedure details',
        ),

        // Implants used with image upload
        buildCustomInput(
          controller: _implantsController,
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
          label: 'Implants used, if any',
          hintText: 'Enter implants details',
        ),

        buildCustomInput(
          controller: _complicationsController,
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
          label: 'Complications, if any',
          hintText: 'Enter Complications',
        ),

        _buildImageUploadField(),
      ],
    );
  }

  Widget _buildTreatmentPlanStep() {
    return Column(
      children: [
        // Treatment advised (multi-line)
        buildCustomInput(
          controller: _treatmentController,
          label: 'Treatment advised',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
          hintText: 'Enter treatment details',
        ),

        // Further plan (multi-line)
        buildCustomInput(
          controller: _furtherPlanController,
          label: 'Further Plan/Special care',
          minLines: 3,
          maxLines: 5,
          enableNewLines: true,
          hintText: 'Enter further plan details',
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //     colors: [
      //       Colors.white,
      //       AppColors.primary.withOpacity(0.03),
      //     ],
      //   ),
      //   border: Border(
      //     top: BorderSide(
      //       color: Colors.grey[200]!,
      //       width: 1,
      //     ),
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 6,
      //       offset: const Offset(0, -2),
      //     ),
      //   ],
      // ),

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
                if (_currentStep < 1) {
                  setState(() => _currentStep++);
                } else {
                  submitPostOperationNotes();
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
            child: Text(_currentStep == 1 ? 'SUBMIT' : 'NEXT'),
          ),
        ],
      ),
    );
  }

// Method to fetch post-operation notes
  Future<Map<String, dynamic>?> fetchPostOperationNotes(var patientId) async {
    try {
      final response = await http.post(
        Uri.parse('$localurl/get_post_operation'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "patient_id": patientId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load post-operation notes: ${response.reasonPhrase}');
      }
    } catch (e) {
      log('Error fetching notes: ${e.toString()}');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error fetching notes: ${e.toString()}')),
      // );
      return null;
    }
  }

// Method to submit post-operation notes (updated version)
  Future<void> submitPostOperationNotes() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$localurl/postoperations'),
      );

      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        ShowDialogs.showSnackBar(
          context,
          'Authentication token not found. Please login again.',
        );
        return;
      }

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      Map<String, String> fields = {
        'patient_id': '${widget.patient_id}',
        'surgery': _surgeryController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'surgeon': _surgeonController.text,
        'assistant': _assistantController.text,
        'anaesthetists': _anaesthetistController.text,
        'anaesthesia': _anaesthesiaController.text,
        'findings': _findingsController.text,
        'procedure': _procedureController.text,
        'implants_used': _implantsController.text,
        'treatment_advised': _treatmentController.text,
        'further_plan': _furtherPlanController.text,
        'time_take': _timetakenController.text,
        'complications': _complicationsController.text
      };
      request.fields.addAll(fields);
      log('Form Fields: ${jsonEncode(fields)}');

      List<String> existingFileIds = [];
      String fieldName = "implants_image";
      log(_uploadedFiles.entries.toString());

      for (var entry in _uploadedFiles.entries) {
        final files = entry.value;

        for (var file in files) {
          if (file['isExisting'] == true && file['id'] != null) {
            existingFileIds.add(file['id'].toString());
          } else {
            if (kIsWeb) {
              Uint8List? fileBytes = file['bytes'];
              String? fileName = file['name'] ??
                  'file_${DateTime.now().millisecondsSinceEpoch}';

              if (fileBytes != null && fileName != null) {
                request.files.add(http.MultipartFile.fromBytes(
                  fieldName,
                  fileBytes,
                  filename: fileName,
                ));
              } else {
                log('❌ Web file data incomplete: bytes=${fileBytes != null}, name=${fileName != null}');
                continue;
              }
            } else {
              String? filePath = file['path'];
              String? fileName = file['name'] ??
                  path.basename(filePath ?? '') ??
                  'file_${DateTime.now().millisecondsSinceEpoch}';

              if (filePath != null) {
                final fileToUpload = File(filePath);
                if (await fileToUpload.exists()) {
                  request.files.add(await http.MultipartFile.fromPath(
                    fieldName,
                    filePath,
                    filename: fileName,
                  ));
                } else {
                  log('❌ File not found: $filePath');
                }
              }
            }
          }
        }
      }

      if (existingFileIds.isNotEmpty) {
        request.fields['existing_file'] = existingFileIds.join(',');
      }

      log("existingFileIds: $existingFileIds");
      log('📤 Request Fields: ${jsonEncode(request.fields)}');
      log('📂 Total Files to Upload: ${request.files.length}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post-operation notes submitted successfully'),
          ),
        );
        log('widget.patient_id ${widget.patient_id}');
        log('postOperationId ${postOperationId}');

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DischargePage(
                    patientId: widget.patient_id,
                    postOperationId: postOperationId,
                  )),
        );
      } else {
        log('Failed to submit: ${json.decode(responseBody)['message'] ?? 'Unknown error'}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to submit: ${json.decode(responseBody)['message'] ?? 'Unknown error'}'),
          ),
        );
      }
    } catch (e) {
      log('Error submitting form: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _loadExistingData() async {
    final notes = await fetchPostOperationNotes('${widget.patient_id}');
    if (notes != null && notes['data'] != null) {
      setState(() {
        final data = notes['data'];

        // Handle non-image data
        _surgeryController.text = data['surgery'] ?? '';
        _selectedDate = DateFormat('dd-MM-yyyy').parse(data['date']);
        _surgeonController.text = data['surgeon'] ?? '';
        _assistantController.text = data['assistant'] ?? '';
        _anaesthetistController.text = data['anaesthetists'] ?? '';
        _anaesthesiaController.text = data['anaesthesia'] ?? '';
        _findingsController.text = data['findings'] ?? '';
        _procedureController.text = data['procedure'] ?? '';
        _implantsController.text = data['implants_used'] ?? '';
        _treatmentController.text = data['treatment_advised'] ?? '';
        _furtherPlanController.text = data['further_plan'] ?? '';
        postOperationId = data['id'];
        _timetakenController.text = data['time_take'] ?? "";
        _complicationsController.text = data['complications'] ?? "";

        log(_surgeryController.text.toString());

        // Handle images if they exist
        if (data['implants_image'] != null &&
            data['implants_image'].isNotEmpty) {
          _uploadedFiles['implants_image'] = List<Map<String, dynamic>>.from(
            data['implants_image'].map((image) {
              return {
                'id': image['id'],
                'path': image['image_path'],
                'url': image['image_path'],
                'name': path.basename(Uri.parse(image['image_path']).path),
                'type': path.extension(image['image_path']).replaceAll('.', ''),
                'isExisting': true,
              };
            }),
          );
        }
      });
    } else {
      log('not is null');
    }
  }

  @override
  void initState() {
    log(widget.patient_id.toString());
    super.initState();
    _loadExistingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.medicalBlue.withOpacity(.2),
      appBar: AppBar(
        title: const Text('Post Operation Notes'),
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
            // child:
            // Card(
            // elevation: 4,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10)),
            // color: AppColors.card,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: 1000, minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // _buildStepNavigation(),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Align(
                        //     alignment: Alignment.center,
                        //     child: Text(
                        //       'Post Operation Notes',
                        //       style: TextStyle(
                        //           fontSize: 22,
                        //           color: AppColors.primary,
                        //           fontWeight: FontWeight.bold),
                        //     )),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildCurrentStepContent(),
                        ),
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                )),
            // ),
          );
        },
      ),
    );
  }

  Future<void> _removeFile(String reportType, Map<String, dynamic> file) async {
    try {
      if (file['isExisting'] == true) {
        // Track deleted existing files
        _deletedFiles[reportType] ??= [];
        _deletedFiles[reportType]!.add(file['id'].toString());
      } else {
        if (kIsWeb) {
          setState(() {
            _uploadedFiles[reportType]!.remove(file);
          });
        }
        // Delete newly uploaded files
        else {
          final fileToDelete = File(file['path']);
          if (await fileToDelete.exists()) {
            await fileToDelete.delete();
          }
        }
      }

      setState(() {
        _uploadedFiles[reportType]!.remove(file);
        if (reportType == 'implants_image') {
          _implantImage = null;
        }
      });
    } catch (e) {
      log('Failed to delete file: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete file: ${e.toString()}')),
      );
    }
  }
}
