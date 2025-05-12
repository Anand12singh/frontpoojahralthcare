import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class FileDownloader {
  static Future<void> downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
    required String fileType,
    Uint8List? bytes,
  }) async {
    try {
      if (kIsWeb) {
        await _downloadFileWeb(
          context: context,
          url: url,
          fileName: fileName,
          fileType: fileType,
          bytes: bytes,
        );
      } else {
        await _downloadFileMobile(
          context: context,
          url: url,
          fileName: fileName,
          fileType: fileType,
          bytes: bytes,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
      rethrow;
    }
  }

  static Future<void> _downloadFileWeb({
    required BuildContext context,
    required String url,
    required String fileName,
    required String fileType,
    Uint8List? bytes,
  }) async {
    try {
      // For web, we have two cases:
      // 1. We have a direct URL to the file
      // 2. We have the file bytes (for newly uploaded files)
      if (bytes != null) {
        // Create a blob URL from bytes
        final blobUrl = await _createBlobUrl(bytes, '$fileName.$fileType');
        await launchUrl(Uri.parse(blobUrl));
      } else {
        // Direct URL download
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }

  static Future<void> _downloadFileMobile({
    required BuildContext context,
    required String url,
    required String fileName,
    required String fileType,
    Uint8List? bytes,
  }) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        throw 'Storage permission not granted';
      }

      // Get the download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        String newPath = '';
        List<String> paths = directory!.path.split('/');
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != 'Android') {
            newPath += '/$folder';
          } else {
            break;
          }
        }
        newPath = '$newPath/Download';
        directory = Directory(newPath);
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory!.exists()) {
        await directory.create(recursive: true);
      }

      // Handle the file data
      final filePath = '${directory.path}/$fileName.$fileType';
      if (bytes != null) {
        // Write bytes directly if we have them
        await File(filePath).writeAsBytes(bytes);
      } else {
        // Download from URL
        final response = await http.get(Uri.parse(url));
        await File(filePath).writeAsBytes(response.bodyBytes);
      }

      // Open the file after download
      await OpenFile.open(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded to ${path.basename(filePath)}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
      rethrow;
    }
  }

  // Helper method to create a blob URL (web only)
  static Future<String> _createBlobUrl(Uint8List bytes, String fileName) async {
    // This is a placeholder - in a real web app, you'd use JS interop
    // or a package like universal_html to create blob URLs
    throw UnsupportedError(
        'Blob URL creation not implemented on this platform');
  }
}
