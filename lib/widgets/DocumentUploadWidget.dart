import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';

class DocumentUploadWidget extends StatefulWidget {
  final String label1;
  final String label2;

  const DocumentUploadWidget({
    super.key,
    required this.label1,
    required this.label2,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  List<PlatformFile> _selectedFiles = [];

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  String _formatSize(int bytes) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Document Field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label1,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _pickFiles,
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: AppColors.textSecondary.withOpacity(0.3),
                            width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Tap to upload documents",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Media History Display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label2,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.3),
                          width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedFiles.isEmpty
                        ? Text("No media selected",
                        style: TextStyle(color: Colors.grey[700]))
                        : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_selectedFiles.length, (index) {
                        final file = _selectedFiles[index];
                        return Container(

                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Media ${index + 1} (${_formatSize(file.size)})',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _removeFile(index),
                                child: const Icon(Icons.close,
                                    color: Colors.red, size: 18),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
