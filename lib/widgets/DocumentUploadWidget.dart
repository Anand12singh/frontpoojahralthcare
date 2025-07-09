import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:poojaheakthcare/widgets/showTopSnackBar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/ResponsiveUtils.dart';
import '../utils/colors.dart';
import 'VideoPlayerWidget.dart';
import 'dart:html' as html; // For web-specific functionality
import 'dart:typed_data'; // For Uint8List
import 'package:universal_html/html.dart' as universal_html; // Alternative if needed
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
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'mp4', 'mov', 'avi'],
      );

      if (result != null) {
  /*      for (var file in result.files) {
          if (file.size > 50 * 1024 * 1024) { // 50MB limit
            showTopRightToast(
                context,
                'File ${file.name} is too large (max 50MB)',
                backgroundColor: Colors.red
            );
            return;
          }
        }*/
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

    _showPreviewDialog(context, file, isNetwork: isNetwork);
  }

  void _showVideoPreviewDialog(BuildContext context, String filePath, {bool isNetwork = false}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16/9,
              child: isNetwork
                  ? _buildNetworkVideoPlayer(filePath)
                  : (kIsWeb
                  ? _buildWebVideoPlayer(filePath)
                  : _buildFileVideoPlayer(filePath)),
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
                      onPressed: () => _downloadFile(filePath, 'mp4', isNetwork),
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
  }

  Widget _buildNetworkVideoPlayer(String url) {
    return VideoPlayerWidget(url: url, isNetwork: true);
  }

  Widget _buildWebVideoPlayer(String filePath) {
    // For web, you might need to use a different approach
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam, size: 50),
          Text('Video playback not supported in preview\n${path.basename(filePath)}'),
          TextButton(
            onPressed: () => launchUrl(Uri.parse(filePath)),
            child: const Text('Open in new tab'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileVideoPlayer(String filePath) {
    return VideoPlayerWidget(filePath: filePath);
  }

  void _showPreviewDialog(BuildContext context, Map<String, dynamic> file,
      {bool isNetwork = false}) {
    final filePath = file['path'] ?? '';
    final fileType = (file['type'] ?? '').toLowerCase();
    final fileBytes = file['bytes'];

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
                    ? Image.network(
                  filePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                          'Failed to load image\n${error.toString()}'),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
                    : (kIsWeb
                    ? Image.memory(
                  fileBytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text('Failed to load image'),
                    );
                  },
                )
                    : Image.file(
                  File(filePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text('Failed to load image'),
                    );
                  },
                )),
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
                        onPressed: () => _downloadFile(
                            isNetwork ? filePath : filePath, fileExtension, isNetwork),
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
    } else if (videoTypes.contains(fileExtension)) {
      _showVideoPreviewDialog(context, filePath, isNetwork: isNetwork);
    }
  }



  Future<void> _downloadFile(String filePath, String fileType, bool isNetwork) async {
    try {
      if (kIsWeb) {
        // Web implementation - triggers browser download
        await _downloadFileWeb(filePath, fileType, isNetwork);
      } else {
        // Mobile implementation - saves to downloads folder
        await _downloadFileMobile(filePath, fileType, isNetwork);
      }
     /* showTopRightToast(
        context,
        'Downloaded ${path.basename(filePath)}',
        backgroundColor: Colors.green,
      );*/
    } catch (e) {
      debugPrint('Download error: $e');
      showTopRightToast(
        context,
        'Failed to download file',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _downloadFileWeb(String filePath, String fileType, bool isNetwork) async {
    if (isNetwork) {
      // For network files on web, let the browser handle the download
      await launchUrl(Uri.parse(filePath), mode: LaunchMode.externalApplication);
    } else {
      // For local files selected in web
      final file = _selectedFiles.firstWhere(
            (f) => f['path'] == filePath || f['name'] == path.basename(filePath),
        orElse: () => {},
      );

      if (file.isNotEmpty && file['bytes'] != null) {
        final bytes = file['bytes'] as Uint8List;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', file['name'])
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    }
  }

  Future<void> _downloadFileMobile(String filePath, String fileType, bool isNetwork) async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${dir.path}/downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final fileName = path.basename(filePath);
    final savePath = '${downloadsDir.path}/$fileName';

    if (isNetwork) {
      // Download network file
      final response = await Dio().get(
        filePath,
        options: Options(responseType: ResponseType.bytes),
      );
      await File(savePath).writeAsBytes(response.data);
    } else {
      // Copy local file to downloads
      if (filePath.startsWith('content://')) {
        // Handle content URIs (Android)
        final file = await File(filePath).create();
        await file.copy(savePath);
      } else {
        await File(filePath).copy(savePath);
      }
    }

    // Optionally open the file after download
    await OpenFile.open(savePath);
  }
/*  Future<void> _downloadFile(String filePath, String fileType, bool isNetwork) async {
    try {
      if (kIsWeb) {
        // Handle web download
        if (isNetwork) {
          // For network files, use the URL directly
          await launchUrl(Uri.parse(filePath));
        } else {
          // For local files selected in web, create a download link
          final file = _selectedFiles.firstWhere(
                (f) => f['path'] == filePath || f['name'] == path.basename(filePath),
            orElse: () => {},
          );

          if (file.isNotEmpty && file['bytes'] != null) {
            final bytes = file['bytes'] as Uint8List;
            final blob = html.Blob([bytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor = html.AnchorElement(href: url)
              ..setAttribute('download', file['name'])
              ..click();
            html.Url.revokeObjectUrl(url);
          }
        }
      } else {
        // Handle mobile download
        if (isNetwork) {
          await launchUrl(Uri.parse(filePath));
        } else {
          OpenFile.open(filePath);
        }
      }
      showTopRightToast(
        context,
        'Downloading ${path.basename(filePath)}',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      debugPrint('Download error: $e');
      showTopRightToast(
        context,
        'Failed to download file',
        backgroundColor: Colors.red,
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile?
        Wrap(
         spacing: 16,

          children: [
            // Upload Document Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style:  TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: ResponsiveUtils.fontSize(context, 14)
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
                        Icon(Icons.attach_file, color: Colors.grey,size:  ResponsiveUtils.fontSize(context, 18),),
                        const SizedBox(width: 8),
                        Text(
                          "Tap to upload documents",
                          style: TextStyle(color: Colors.grey[700],fontSize:  ResponsiveUtils.fontSize(context, 14),),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Uploaded Files Display
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uploaded Files',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: ResponsiveUtils.fontSize(context, 14)
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
                      style: TextStyle(color: Colors.grey[700],fontSize:  ResponsiveUtils.fontSize(context, 14),),
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
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                            // border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getFileIcon(file['type']),
                                size: 16,
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
                                  size: 16,
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
          ],
        ):

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
                    style:  TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: ResponsiveUtils.fontSize(context, 14)
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
                          Icon(Icons.attach_file, color: Colors.grey,size:  ResponsiveUtils.fontSize(context, 18),),
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

            const SizedBox(width: 14),

            // Uploaded Files Display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uploaded Files',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: ResponsiveUtils.fontSize(context, 13)
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
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                              // border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getFileIcon(file['type']),
                                  size: 16,
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
                                    size: 16,
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
    if (['mp4', 'mov', 'avi'].contains(type)) return Icons.videocam;
    return Icons.insert_drive_file;
  }

  Color _getFileIconColor(String? fileType) {
    final type = (fileType ?? '').toLowerCase();
    if (type == 'pdf') return Colors.red;
    if (['jpg', 'jpeg', 'png'].contains(type)) return Colors.blue;
    if (['doc', 'docx'].contains(type)) return Colors.blue.shade800;
    if (['mp4', 'mov', 'avi'].contains(type)) return Colors.purple;
    return Colors.grey;
  }

}

