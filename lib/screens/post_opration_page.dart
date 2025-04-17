import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../utils/colors.dart';
import '../widgets/inputfild.dart';
import 'dishcharge_page.dart';

class PostOperationPage extends StatefulWidget {
  const PostOperationPage({super.key});

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

  DateTime _selectedDate = DateTime.now();
  File? _implantImage;
  final Map<String, List<Map<String, dynamic>>> _uploadedFiles = {};
  final Map<String, List<String>> _deletedFiles = {};

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
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (pickedFile != null) {
      setState(() {
        _uploadedFiles['implants_image'] = [
          {
            'bytes': pickedFile.files.single.bytes!,
            'name': pickedFile.files.single.name,
            'type': path
                .extension(pickedFile.files.single.name)
                .replaceAll('.', '')
                .toLowerCase(),
            'isExisting': false,
          }
        ];
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
                    hasImages ? 'image uploaded' : 'Click to upload images',
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _uploadedFiles['implants_image']!
                  .map((file) => _buildFileItem('implants_image', file))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileItem(String fileType, Map<String, dynamic> file) {
    return GestureDetector(
      onTap: () => _showFilePreview(context, file),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _getFileIcon(file['type']),
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                file['name'],
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFile(fileType, file),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilePreview(
      BuildContext context, Map<String, dynamic> file) async {
    final fileType = file['type'];
    final fileName = file['name'];

    if (['jpg', 'jpeg', 'png'].contains(fileType.toLowerCase())) {
      // Image Preview
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
                child: kIsWeb
                    ? Image.memory(
                        file['bytes'],
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        File(file['path']),
                        fit: BoxFit.contain,
                      ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (fileType.toLowerCase() == 'pdf') {
      // PDF Preview
      if (kIsWeb) {
        // For web, convert bytes to object URL
        final bytes = file['bytes'] as Uint8List;
        // final blob = Blob([bytes], 'application/pdf');
        // final url = Url.createObjectUrlFromBlob(blob);

        // if (await canLaunchUrl(Uri.parse(url))) {
        //   await launchUrl(
        //     Uri.parse(url),
        //     mode: LaunchMode.externalApplication,
        //   );
        //   // Clean up the object URL after some time
        //   Future.delayed(const Duration(seconds: 30), () {
        //     Url.revokeObjectUrl(url);
        //   });
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Could not open PDF')),
        //   );
        // }
      } else {
        // For mobile, use Syncfusion PDF Viewer
        try {
          if (file['path'] != null) {
            // Local file
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(fileName)),
                  body: SfPdfViewer.file(File(file['path'])),
                ),
              ),
            );
          } else if (file['bytes'] != null) {
            // Bytes data (for web or cached files)
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/$fileName');
            await tempFile.writeAsBytes(file['bytes']);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(fileName)),
                  body: SfPdfViewer.file(tempFile),
                ),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load PDF: ${e.toString()}')),
          );
        }
      }
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
            const SizedBox(width: 10),
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
          ],
        ),

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
            child: Text(_currentStep == 1 ? 'SUBMIT' : 'NEXT'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DischargePage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Post-operation notes submitted successfully')),
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
                    maxWidth: 1000, minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // _buildStepNavigation(),
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Post Operation Notes',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildCurrentStepContent(),
                        ),
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                )),
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
