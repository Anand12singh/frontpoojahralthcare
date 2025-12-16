import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heic_to_png_jpg/heic_to_png_jpg.dart';
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
// import 'dart:html' as html; // For web-specific functionality
import 'dart:typed_data'; // For Uint8List

// import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'WebVideoPlayer.dart';
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
  bool _isUploading = false;
  List<bool> _fileUploadingStates = [];
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


// Update the _pickFiles method to include size validation
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'mp4', 'mov', 'avi', 'heic', 'heif'],
      );

      if (result != null) {
        // Check for files that exceed the size limit
        final oversizedFiles = result.files.where((file) =>
        file.size > 100 * 1024 * 1024 && // 100MB in bytes
            ['mp4', 'mov', 'avi'].contains(file.extension?.toLowerCase())).toList();

        if (oversizedFiles.isNotEmpty) {
          showTopRightToast(
            context,
            'Video files cannot exceed 100MB. Please select smaller files.',
            backgroundColor: Colors.red,
          );

          // Remove oversized files from the selection
          result.files.removeWhere((file) => oversizedFiles.contains(file));

          if (result.files.isEmpty) return;
        }

        setState(() {
          _isUploading = true;
          // Initialize upload states for each file
          _fileUploadingStates = List<bool>.filled(result.files.length, true);
        });

        List<Map<String, dynamic>> newFiles = [];

        for (int i = 0; i < result.files.length; i++) {
          final file = result.files[i];
          final isVideo = ['mp4', 'mov', 'avi'].contains(file.extension?.toLowerCase());
          final isHeic = ['heic', 'heif'].contains(file.extension?.toLowerCase());

          // Handle HEIC file conversion
          Uint8List? finalBytes = file.bytes;
          String? finalExtension = file.extension?.toLowerCase();
          String? finalName = file.name;

          // Enhanced HEIC conversion with fallback options
          if (isHeic && file.bytes != null) {
            try {
              Uint8List? convertedBytes;

              // First try to convert to JPG
              try {
                convertedBytes = await HeicConverter.convertToJPG(
                  heicData: file.bytes!,
                  quality: 85,
                );
                finalExtension = 'jpg';
              } catch (jpgError) {
                debugPrint('JPG conversion failed, trying PNG: $jpgError');

                // Fallback to PNG if JPG conversion fails
                convertedBytes = await HeicConverter.convertToPNG(
                  heicData: file.bytes!,
                );
                finalExtension = 'png';
              }

              if (convertedBytes != null) {
                finalBytes = convertedBytes;
                finalName = file.name
                    .replaceAll('.heic', '.$finalExtension')
                    .replaceAll('.HEIC', '.$finalExtension')
                    .replaceAll('.heif', '.$finalExtension')
                    .replaceAll('.HEIF', '.$finalExtension');
              } else {
                throw Exception('Both JPG and PNG conversion failed');
              }
            } catch (e) {
              debugPrint('HEIC conversion error: $e');
              showTopRightToast(
                context,
                'Failed to convert HEIC image. Using original format which may not display correctly.',
                backgroundColor: Colors.orange,
              );
              // Fallback to original file
              finalBytes = file.bytes;
            }
          }

          // Simulate upload delay for videos (replace with actual upload logic)
          if (isVideo) {
            await Future.delayed(Duration(seconds: 2)); // Simulate upload time
          }

          newFiles.add({
            'path': kIsWeb ? finalName : file.path!,
            'name': finalName,
            'bytes': finalBytes,
            'size': file.size,
            'type': finalExtension?.toUpperCase() ?? 'FILE',
            'isExisting': false,
            'originalExtension': file.extension?.toLowerCase(),
          });

          // Update the upload state for this file
          if (isVideo) {
            setState(() {
              _fileUploadingStates[i] = false;
            });
          }
        }

        setState(() {
          _selectedFiles.addAll(newFiles);
          _isUploading = false;
          _fileUploadingStates = [];
        });

        widget.onFilesSelected(_selectedFiles);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _fileUploadingStates = [];
      });
      debugPrint('File picking error: $e');
    }
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
    final filePath = file['file_path'] ?? '';
    final fileType = (file['type'] ?? '').toLowerCase();
    final isNetwork = file['isExisting'] ?? false;

    // Handle network files by prepending base URL
    final fullPath = isNetwork && widget.baseUrl != null
        ? '${widget.baseUrl}$filePath'
        : filePath;



    _showPreviewDialog(context, file, isNetwork: isNetwork);
  }

  void _showVideoPreviewDialog(BuildContext context, String filePath, {bool isNetwork = false, Map<String, dynamic>? file}) {

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
                  ?WebVideoPlayer(
                filePath: filePath,
                fileBytes: file?['bytes'],
              )
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




  Widget _buildFileVideoPlayer(String filePath) {

    print("_buildFileVideoPlayer");
    print(filePath);
    return VideoPlayerWidget(filePath: filePath);
  }

  void _showPreviewDialog(BuildContext context, Map<String, dynamic> file,
      {bool isNetwork = false}) {
    final filePath = file['path'] ?? '';
    final fileType = (file['type'] ?? '').toLowerCase();
    final fileBytes = file['bytes'];
    final fileName = file['name'] ?? 'file';

    final imageTypes = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'};
    final videoTypes = {'mp4', 'mov', 'avi'};
    final pdfTypes = {'pdf'};
    final documentTypes = {'doc', 'docx'};

    print('isNetwork:$isNetwork');
    final fileExtension = fileType.toLowerCase();
    print("fileExtension");
    print(fileExtension);

    if (imageTypes.contains(fileExtension)) {
      _showImagePreview(context, file, isNetwork);
    } else if (videoTypes.contains(fileExtension)) {
      _showVideoPreviewDialog(context,file:file , filePath, isNetwork: isNetwork);
    } else if (pdfTypes.contains(fileExtension)) {
      print('pdf file');
      _showPdfPreview(context, file, isNetwork: isNetwork);
    } else if (documentTypes.contains(fileExtension)) {
      _showDocumentPreview(context, file);
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
      // ui.platformViewRegistry.registerViewFactory(
      //   viewType,
      //       (int viewId) => html.IFrameElement()
      //     ..src = dataUrl
      //     ..style.width = '100%'
      //     ..style.height = '100%'
      //     ..style.border = 'none'
      //     ..setAttribute('type', 'application/pdf'),
      // );

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

  void _showDocumentPreview(BuildContext context, Map<String, dynamic> file) {
    final filePath = file['path'] ?? '';
    final fileName = file['name'] ?? 'Document';
    final fileExtension = (file['type'] ?? '').toLowerCase();
    final isNetwork = file['isExisting'] ?? false;

    // Build viewer URLs
    Map<String, String> viewerUrls = {};

    if (isNetwork) {
      String fileUrl = filePath;
      if (widget.baseUrl != null && !filePath.startsWith('http')) {
        fileUrl = '${widget.baseUrl}$filePath';
      }

      final encodedUrl = Uri.encodeComponent(fileUrl);

      // Google Docs Viewer (for PDF and some document types)
      viewerUrls['Google Docs'] = 'https://docs.google.com/viewer?url=$encodedUrl&embedded=true';


    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFileIcon(fileExtension),
                      size: 80,
                      color: _getFileIconColor(fileExtension),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${fileExtension.toUpperCase()} Document',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Viewer Options (for network files)
                    if (viewerUrls.isNotEmpty) ...[
                      const Text(
                        'Open with:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...viewerUrls.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getViewerButtonColor(entry.key),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () async {
                              try {
                                if (await canLaunchUrl(Uri.parse(entry.value))) {
                                  await launchUrl(
                                    Uri.parse(entry.value),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              } catch (e) {
                                debugPrint('Error launching ${entry.key}: $e');
                                showTopRightToast(
                                  context,
                                  'Failed to open with ${entry.key}',
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _getViewerIcon(entry.key),
                                const SizedBox(width: 8),
                                Text(entry.key),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                    ],

                    // Download Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => _downloadFile(filePath, fileExtension, isNetwork),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Download Document'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // System Viewer (for mobile)
                    if (!kIsWeb && filePath.isNotEmpty)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: () async {
                          try {
                            await OpenFile.open(filePath);
                          } catch (e) {
                            debugPrint('Error opening file: $e');
                            showTopRightToast(
                              context,
                              'Failed to open document',
                              backgroundColor: Colors.red,
                            );
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.open_in_new),
                            SizedBox(width: 8),
                            Text('Open with System Viewer'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
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
      ),
    );
  }

// Helper methods for viewer buttons
  Color _getViewerButtonColor(String viewerName) {
    switch (viewerName) {
      case 'Google Docs':
        return Colors.blue;
      case 'Office Online':
        return Colors.orange;
      case 'PDF Viewer':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _getViewerIcon(String viewerName) {
    switch (viewerName) {
      case 'Google Docs':
        return const Icon(Icons.document_scanner);
      case 'Office Online':
        return const Icon(Icons.business_center);
      case 'PDF Viewer':
        return const Icon(Icons.picture_as_pdf);
      default:
        return const Icon(Icons.open_in_browser);
    }
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

      // if (file.isNotEmpty && file['bytes'] != null) {
      //   final bytes = file['bytes'] as Uint8List;
      //   final blob = html.Blob([bytes]);
      //   final url = html.Url.createObjectUrlFromBlob(blob);
      //   final anchor = html.AnchorElement(href: url)
      //     ..setAttribute('download', file['name'])
      //     ..click();
      //   html.Url.revokeObjectUrl(url);
      // }
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
                        onTap: _isUploading ? null : _pickFiles,
                        child: Tooltip(
                          message: 'Tap to upload documents',
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
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
                                if (_isUploading)
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.attach_file,
                                    color: Colors.grey,
                                    size: ResponsiveUtils.fontSize(context, 18),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  _isUploading ? "Uploading..." : "Tap to upload documents",
                                  style: TextStyle(
                                    color: _isUploading ? AppColors.secondary : Colors.grey[700],
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

// In your build method, update the file list item to show loading indicators
// Replace the file list item builder with this:
                            itemBuilder: (context, index) {
                              final file = _selectedFiles[index];
                              final fileName = file['name'] ?? '';
                              final apiTags = file['tags'] as List? ?? [];
                              final localTags = widget.docType == 'misc_report' ? widget.miscReportTagging![fileName] ?? [] : [];
                              final tags = apiTags.isNotEmpty ? apiTags : localTags;

                              final isVideo = ['mp4', 'mov', 'avi'].contains((file['type'] ?? '').toLowerCase());
                              final isUploading = index >= _selectedFiles.length - _fileUploadingStates.length &&
                                  _fileUploadingStates.isNotEmpty &&
                                  _fileUploadingStates[index - (_selectedFiles.length - _fileUploadingStates.length)];

                              return GestureDetector(
                                onTap: () => isUploading ? null : _showFilePreview(index),
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
                                          // Show loading indicator for videos that are still uploading
                                          if (isUploading)
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                                              ),
                                            )
                                          else
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
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: isUploading ? Colors.grey : Colors.black,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                // Display tags if they exist
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (tags.isNotEmpty && !isUploading)
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
                                              SizedBox(width: 10),
                                              if (!isUploading)
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
                                          // Remove icon with tooltip (only show when not uploading)
                                          if (!isUploading)
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
                                      // Show upload progress for videos
                                      if (isUploading && isVideo)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: LinearProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                                                  backgroundColor: Colors.grey[300],
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Uploading...',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
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
    if (['jpg', 'jpeg', 'png', 'heic', 'heif'].contains(type)) return Icons.image;
    if (['doc', 'docx'].contains(type)) return Icons.description;
    if (['mp4', 'mov', 'avi'].contains(type)) return Icons.videocam;
    return Icons.insert_drive_file;
  }

  Color _getFileIconColor(String? fileType) {
    final type = (fileType ?? '').toLowerCase();
    if (type == 'pdf') return Colors.red;
    if (['jpg', 'jpeg', 'png', 'heic', 'heif'].contains(type)) return Colors.blue;
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
    // ui.platformViewRegistry.registerViewFactory(
    //   viewType,
    //       (int viewId) {
    //     final container = html.DivElement()
    //       ..style.width = '100%'
    //       ..style.height = '100%'
    //       ..style.display = 'flex'
    //       ..style.flexDirection = 'column';

    //     // Create custom header
    //     final header = html.DivElement()
    //       ..style.backgroundColor = hexColor
    //       ..style.padding = '10px'
    //       ..style.color = 'white'
    //       ..style.fontWeight = 'bold'
    //       ..innerText = 'PDF Document';

    //     // Create iframe
    //     final iframe = html.IFrameElement()
    //       ..src = pdfUrl
    //       ..style.flex = '1'
    //       ..style.border = 'none';

    //     container.append(header);
    //     container.append(iframe);

    //     return container;
    //   },
    // );

    return HtmlElementView(
      viewType: viewType,
    );
  }
}