import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';

class DocumentUploadWidget extends StatefulWidget {
  final String docType;
  final String label;
  final Function(List<Map<String, dynamic>>) onFilesSelected;
  final List<Map<String, dynamic>>? initialFiles;

  const DocumentUploadWidget({
    super.key,
    required this.docType,
    required this.label,
    required this.onFilesSelected,
    this.initialFiles,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  List<Map<String, dynamic>> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing files if any
    _selectedFiles = widget.initialFiles?.where((file) => file['isExisting'] ?? false).toList() ?? [];
  }

  @override
  void didUpdateWidget(DocumentUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update when parent provides new initialFiles
    if (widget.initialFiles != oldWidget.initialFiles) {
      setState(() {
        // Keep newly uploaded files and merge with updated existing files
        final newFiles = _selectedFiles.where((f) => !(f['isExisting'] ?? true)).toList();
        final existingFiles = widget.initialFiles?.where((f) => f['isExisting'] ?? false).toList() ?? [];
        _selectedFiles = [...newFiles, ...existingFiles];
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        List<Map<String, dynamic>> newFiles = result.files.map((file) {
          return {
            'path': kIsWeb ? file.name : file.path!,
            'name': file.name,
            'bytes': file.bytes,
            'size': file.size,
            'type': file.extension?.toUpperCase() ?? 'FILE',
            'isExisting': false,
          };
        }).toList();

        setState(() {
          _selectedFiles.addAll(newFiles);
        });

        widget.onFilesSelected(_selectedFiles);
      }
    } catch (e) {
      debugPrint('File picking error: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected(_selectedFiles);
  }

  String _formatSize(dynamic size) {
    if (size is int) {
      if (size <= 0) return '0 KB';
      return '${(size / 1024).toStringAsFixed(0)} KB';
    }
    return size?.toString() ?? '';
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
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickFiles,
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            "Tap to upload documents",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Uploaded Files Display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uploaded Files',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
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
                    child: _selectedFiles.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        "No files selected",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    )
                        : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_selectedFiles.length, (index) {
                        final file = _selectedFiles[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${file['name']} (${_formatSize(file['size'])})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _removeFile(index),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 18,
                                ),
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