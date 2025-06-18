import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:poojaheakthcare/widgets/showTopSnackBar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';

class DocumentUploadWidget extends StatefulWidget {
  final String docType;
  final String label;
  final Function(List<Map<String, dynamic>>) onFilesSelected;
  final List<Map<String, dynamic>>? initialFiles;
  final String? baseUrl; // Add base URL for network files

  const DocumentUploadWidget({
    super.key,
    required this.docType,
    required this.label,
    required this.onFilesSelected,
    this.initialFiles,
    this.baseUrl,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  List<Map<String, dynamic>> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _selectedFiles = widget.initialFiles?.where((file) => file['isExisting'] ?? false).toList() ?? [];
  }

  @override
  void didUpdateWidget(DocumentUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFiles != oldWidget.initialFiles) {
      setState(() {
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

  void _showFilePreview(int index) {
    final file = _selectedFiles[index];
    final filePath = file['path'] ?? '';
    final fileType = (file['type'] ?? '').toLowerCase();
    final isNetwork = file['isExisting'] ?? false;

    // Handle network files by prepending base URL
    final fullPath = isNetwork && widget.baseUrl != null
        ? '${widget.baseUrl}$filePath'
        : filePath;

    _showPreviewDialog(context, fullPath, fileType, isNetwork: isNetwork);
  }

  void _showPreviewDialog(BuildContext context, String filePath, String fileType,
      {bool isNetwork = false}) {
    final imageTypes = {'jpg', 'jpeg', 'png', 'webp'};
    final videoTypes = {'mp4', 'mov', 'avi'};
    final fileExtension = fileType.toLowerCase();

    if (imageTypes.contains(fileExtension)) {
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
                    ? Image.network(filePath, fit: BoxFit.contain)
                    : (kIsWeb
                    ? Image.memory(
                  base64Decode(filePath.split(',').last),
                  fit: BoxFit.contain,
                )
                    : Image.file(File(filePath), fit: BoxFit.contain)),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () => _downloadFile(filePath, fileExtension, isNetwork),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
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
    } else if (fileExtension == 'pdf') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Document'),
          content: Text('File: ${path.basename(filePath)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isNetwork) {
                  // Open network PDF in browser
                  launchUrl(Uri.parse(filePath));
                } else if (kIsWeb) {
                  // For web, show a message about how to download
                  showTopRightToast(context, 'Right-click and select "Save as" to download', backgroundColor: Colors.green);


                } else {
                  // Open local file
                  OpenFile.open(filePath);
                }
              },
              child: const Text('Open'),
            ),
          ],
        ),
      );
    } else {
      // For unsupported file types or videos (which would need additional setup)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('File Preview'),
          content: Text('Preview not available for ${fileExtension.toUpperCase()} files'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _downloadFile(String filePath, String fileType, bool isNetwork) async {
    // Implement your download logic here
    // This would depend on your specific requirements and whether you're on web/mobile
    // You might want to use the flutter_downloader package or similar
    showTopRightToast(context, 'Downloading ${path.basename(filePath)}', backgroundColor: Colors.green);

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
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        return GestureDetector(
                          onTap: () => _showFilePreview(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getFileIcon(file['type']),
                                  color: _getFileIconColor(file['type']),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file['name'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    /*  Text(
                                        _formatSize(file['size']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),*/
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  onPressed: () => _removeFile(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  IconData _getFileIcon(String? fileType) {
    final type = (fileType ?? '').toLowerCase();
    if (type == 'pdf') return Icons.picture_as_pdf;
    if (['jpg', 'jpeg', 'png'].contains(type)) return Icons.image;
    if (['doc', 'docx'].contains(type)) return Icons.description;
    return Icons.insert_drive_file;
  }

  Color _getFileIconColor(String? fileType) {
    final type = (fileType ?? '').toLowerCase();
    if (type == 'pdf') return Colors.red;
    if (['jpg', 'jpeg', 'png'].contains(type)) return Colors.blue;
    if (['doc', 'docx'].contains(type)) return Colors.blue.shade800;
    return Colors.grey;
  }
}