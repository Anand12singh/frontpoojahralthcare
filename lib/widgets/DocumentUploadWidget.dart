import 'dart:async';
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
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/ResponsiveUtils.dart';
import '../utils/colors.dart';
import 'VideoPlayerWidget.dart';
import 'dart:html' as html; // For web-specific functionality
import 'dart:typed_data'; // For Uint8List

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'confirmation_dialog.dart'; // Alternative if needed
class DocumentUploadWidget extends StatefulWidget {
  final String docType;
  final String label;
  final Function(List<Map<String, dynamic>>) onFilesSelected;
  final List<Map<String, dynamic>>? initialFiles;
  final String? baseUrl;
  final Map<String, List<String>>? miscReportTagging; // add this param

  const DocumentUploadWidget({
    Key? key,
    required this.docType,
    required this.label,
    required this.onFilesSelected,
    this.initialFiles,
    this.baseUrl,
    this.miscReportTagging, // require tagging to be passed
  }) : super(key: key);

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
print("_selectedFiles");
print(_selectedFiles);
        widget.onFilesSelected(_selectedFiles);
      }
    } catch (e) {
      debugPrint('File picking error: $e');
    }
  }

/*
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected(_selectedFiles);
  }
*/

  String _formatSize(dynamic size) {
    if (size is int) {
      if (size <= 0) return '0 KB';
      return '${(size / 1024).toStringAsFixed(0)} KB';
    }
    return size?.toString() ?? '';
  }

  void _showFilePreview(int index) {
    final file = _selectedFiles[index];
    final filePath = file['file_path'] ?? '';
    final fileType = (file['type'] ?? '').toLowerCase();
    final isNetwork = file['isExisting'] ?? false;

    // Handle network files by prepending base URL
    final fullPath = isNetwork && widget.baseUrl != null
        ? '${widget.baseUrl}$filePath'
        : filePath;

    print("filePath");
    print(file);
    print(filePath);

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
                    backgroundColor: AppColors.secondary,
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
    final fileName = file['name'] ?? 'file';

    final imageTypes = {'jpg', 'jpeg', 'png', 'webp'};
    final videoTypes = {'mp4', 'mov', 'avi'};
    final pdfTypes = {'pdf'};
    final documentTypes = {'doc', 'docx'};
    print('file:$file');
    print('isNetwork:$isNetwork');
    final fileExtension = fileType.toLowerCase();
    print("fileExtension");
    print(fileExtension);

    if (imageTypes.contains(fileExtension)) {
      _showImagePreview(context, file, isNetwork);
    } else if (videoTypes.contains(fileExtension)) {
      _showVideoPreviewDialog(context, filePath, isNetwork: isNetwork);
    } else if (pdfTypes.contains(fileExtension)) {
      print('pdf file');
      _showPdfPreview(context, file, isNetwork: isNetwork);
    } else if (documentTypes.contains(fileExtension)) {
      _showDocumentPreview(context, fileName);
    } else {
      _showGenericPreview(context, fileName, fileExtension);
    }
  }
  void _showImagePreview(BuildContext context, Map<String, dynamic> file, bool isNetwork) {
    final filePath = file['file_path'] ?? file['path'] ?? '';
    final fileBytes = file['bytes'];
    final fileName = file['name'] ?? 'Image';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: _buildImagePreview(file, isNetwork),
              ),
            ),
            _buildPreviewActionButtons(context, filePath, 'image', isNetwork),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(Map<String, dynamic> file, bool isNetwork) {
    final filePath = file['file_path'] ?? file['path'] ?? '';
    final fileBytes = file['bytes'];
    final fileName = file['name'] ?? 'Image';

    try {
      if (isNetwork) {
        // For network images, ensure the URL is properly formatted
        String imageUrl = filePath;

        // Add base URL if needed
        if (widget.baseUrl != null && !filePath.startsWith('http')) {
          imageUrl = '${widget.baseUrl}$filePath';
        }

        // Clean up any double slashes in the URL
       // imageUrl = imageUrl.replaceAll('//', '/').replaceAll(':/', '://');
print("imageUrl");
print(imageUrl);
        return Image.network(
          imageUrl,
          fit: BoxFit.contain,

          errorBuilder: (context, error, stackTrace) {
            debugPrint('Network image error: $error');
            return _buildImageErrorWidget(fileName, 'Failed to load network image');
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
        );
      } else if (kIsWeb) {
        if (fileBytes != null && fileBytes is Uint8List) {
          return Image.memory(
            fileBytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageErrorWidget(fileName, 'Failed to load image bytes');
            },
          );
        }
        return _buildImageErrorWidget(fileName, 'No image data available');
      } else {
        return Image.file(
          File(filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorWidget(fileName, 'Failed to load local file');
          },
        );
      }
    } catch (e) {
      debugPrint('Image preview error: $e');
      return _buildImageErrorWidget(fileName, e.toString());
    }
  }
  Widget _buildImageErrorWidget(String fileName, String error) {
    print( error.toString());
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          Text(
            'Failed to load image',
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
          Text(
            fileName,
            style: const TextStyle(fontSize: 14),
          ),
          if (error.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Error: $error',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _showPdfPreview(BuildContext context, Map<String, dynamic> file, {bool isNetwork = false}) {
    final filePath = file['file_path'] ?? file['path'] ?? '';
    final fileName = file['name'] ?? 'PDF Document';
    final fileBytes = file['bytes'];

    // Add baseUrl for network if needed
    String pdfUrl = filePath;
    if (isNetwork && widget.baseUrl != null && !filePath.startsWith('http')) {
      pdfUrl = '${widget.baseUrl}$filePath';
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
              child: Builder(
                builder: (_) {
                  if (isNetwork) {
                    // Network PDF - use iframe with proper URL
                    return PdfIframe(pdfUrl: pdfUrl);
                  } else {
                    // Local PDF - handle both web and mobile
                    if (kIsWeb) {
                      // For web, ensure we have proper bytes
                      if (fileBytes != null && fileBytes is Uint8List) {
                        return _buildWebPdfPreview(fileBytes, fileName);
                      } else {
                        return _buildPdfErrorWidget('No PDF data available for web preview');
                      }
                    } else {
                      // For mobile, use SfPdfViewer with bytes
                      try {
                        if (fileBytes != null && fileBytes is Uint8List) {
                          return SfPdfViewer.memory(
                            fileBytes,
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                          );
                        } else if (filePath.isNotEmpty) {
                          // Fallback to file path if bytes not available
                          return SfPdfViewer.file(
                            File(filePath),
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                          );
                        } else {
                          return _buildPdfErrorWidget('No PDF data available');
                        }
                      } catch (e) {
                        debugPrint('PDF viewer error: $e');
                        return _buildPdfErrorWidget('Failed to load PDF: $e');
                      }
                    }
                  }
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildWebPdfPreview(Uint8List fileBytes, String fileName) {
    try {
      // Convert bytes to base64
      final base64String = base64Encode(fileBytes);
      final dataUrl = 'data:application/pdf;base64,$base64String';

      // Create a unique viewType
      final viewType = 'pdf_${fileName.hashCode}';

      // Register iframe view
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        viewType,
            (int viewId) => html.IFrameElement()
          ..src = dataUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..setAttribute('type', 'application/pdf'),
      );

      return HtmlElementView(
        viewType: viewType,
      );
    } catch (e) {
      debugPrint('Web PDF preview error: $e');
      return _buildPdfErrorWidget('Failed to load PDF: $e');
    }
  }
  Widget _buildPdfErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          const Text(
            'Failed to load PDF',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  void _showDocumentPreview(BuildContext context, String fileName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description, size: 80, color: Colors.blue),
                  const SizedBox(height: 20),
                  Text(
                    fileName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Document preview not available'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => launchUrl(Uri.parse('https://docs.google.com/viewer?url=YOUR_FILE_URL')),
                    child: const Text('View in Google Docs'),
                  ),
                ],
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
  }

  void _showGenericPreview(BuildContext context, String fileName, String fileType) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.insert_drive_file, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    fileName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text('$fileType file preview not available'),
                ],
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
  }

  Widget _buildPreviewActionButtons(BuildContext context, String filePath, String? fileType, bool isNetwork) {
    return Positioned(
      top: 10,
      right: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            decoration: BoxDecoration(color: AppColors.secondary,borderRadius: BorderRadius.circular( 8)),
message: 'Download',
            child: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () => _downloadFile(filePath, fileType ?? '', isNetwork),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            decoration: BoxDecoration(color: AppColors.secondary,borderRadius: BorderRadius.circular( 8)),
            message: 'Close',
            child: CircleAvatar(
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
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

  Future<void> _removeFile(int index) async {
    final file = _selectedFiles[index];
    final fileName = file['name'] ?? 'file';

    // Create a Completer to handle the dialog result
    final completer = Completer<bool>();

    // Show your existing confirmation dialog
    ConfirmationDialog.show(
      context: context,
      title: 'Confirm Removal',
      message: 'Are you sure you want to remove $fileName?',
      confirmText: 'Remove',
      confirmColor: AppColors.secondary,
      onConfirm: () => completer.complete(true),  // User confirmed
      onCancel: () => completer.complete(false),  // User canceled
    );

    // Wait for the user's decision
    bool confirm = await completer.future;

    if (confirm) {
      setState(() {
        _selectedFiles.removeAt(index);
      });
      widget.onFilesSelected(_selectedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final itemCount = isSmallScreen ? 1 : 2;
            final spacing = 16.0;
            final totalPadding = spacing * (itemCount - 1);
            final itemWidth = (constraints.maxWidth - totalPadding) / itemCount;

            return Wrap(
              spacing: spacing,
              children: [
                // Upload Document Field
                SizedBox(
                  width: itemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: ResponsiveUtils.fontSize(context, 14),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickFiles,
                        child: Tooltip(
                          message:'Tap to upload documents',
                          decoration: BoxDecoration(color: AppColors.secondary,borderRadius: BorderRadius.circular( 8)),
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
                                Icon(
                                  Icons.attach_file,
                                  color: Colors.grey,
                                  size: ResponsiveUtils.fontSize(context, 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Tap to upload documents",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: ResponsiveUtils.fontSize(context, 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Uploaded Files Display
                SizedBox(
                  width: itemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uploaded Files',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: ResponsiveUtils.fontSize(context, 14),
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
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: ResponsiveUtils.fontSize(context, 14),
                            ),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedFiles.length,
                          // In the DocumentUploadWidget's build method, update the file list item:
                          itemBuilder: (context, index) {
                            final file = _selectedFiles[index];

                            final fileName = file['name'] ?? '';
                            final apiTags = file['tags'] as List? ?? [];
                            final localTags = widget.docType == 'misc_report' ? widget.miscReportTagging![fileName] ?? [] : [];
                            final tags = apiTags.isNotEmpty ? apiTags : localTags;

                            print("tags");
                            print(tags);
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
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _getFileIcon(file['type']),
                                          size: 16,
                                          color: _getFileIconColor(file['type']),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                file['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              // Display tags if they exist


                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [  if (tags.isNotEmpty)
                                            Wrap(
                                              spacing: 4,
                                              children: tags.map((tag) {
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: AppColors.secondary,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    tag,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: AppColors.secondary,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
SizedBox(width: 10,),
                                            Tooltip(
                                              message: 'Preview file',
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.remove_red_eye,
                                                color: AppColors.secondary,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 4),
                                        // Remove icon with tooltip
                                        Tooltip(
                                          message: 'Remove file',
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            onPressed: () => _removeFile(index),
                                          ),
                                        ),
                                      ],
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
            );
          },
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


class PdfIframe extends StatelessWidget {
  final String pdfUrl;
  final Color headerColor;

  const PdfIframe({
    Key? key,
    required this.pdfUrl,
    this.headerColor =  AppColors.secondary, // Default green
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewType = 'pdf_${pdfUrl.hashCode}';

    // Convert color to hex for CSS
    final hexColor = '#${headerColor.value.toRadixString(16).substring(2)}';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewType,
          (int viewId) {
        final container = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.flexDirection = 'column';

        // Create custom header
        final header = html.DivElement()
          ..style.backgroundColor = hexColor
          ..style.padding = '10px'
          ..style.color = 'white'
          ..style.fontWeight = 'bold'
          ..innerText = 'PDF Document';

        // Create iframe
        final iframe = html.IFrameElement()
          ..src = pdfUrl
          ..style.flex = '1'
          ..style.border = 'none';

        container.append(header);
        container.append(iframe);

        return container;
      },
    );

    return HtmlElementView(
      viewType: viewType,
    );
  }
}