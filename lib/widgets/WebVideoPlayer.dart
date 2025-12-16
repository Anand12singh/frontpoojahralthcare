import 'dart:typed_data';
// import 'dart:html' as html;
// import 'dart:ui' as ui; // for platformViewRegistry
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class WebVideoPlayer extends StatefulWidget {
  final String filePath;
  final Uint8List fileBytes;

  const WebVideoPlayer({
    Key? key,
    required this.filePath,
    required this.fileBytes,
  }) : super(key: key);

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late final String _viewType;
  late final String _videoUrl;

  @override
  void initState() {
    super.initState();

    // Create a blob URL from file bytes
    // final blob = html.Blob([widget.fileBytes]);
    // _videoUrl = html.Url.createObjectUrlFromBlob(blob);

    // Generate a unique viewType
    _viewType = 'video_${DateTime.now().millisecondsSinceEpoch}_${widget.filePath.hashCode}';

    // Register the VideoElement
    // ignore: undefined_prefixed_name
    // ui.platformViewRegistry.registerViewFactory(
    //   _viewType,
    //       (int viewId) => html.VideoElement()
    //     ..src = _videoUrl
    //     ..controls = true
    //     ..autoplay = false
    //     ..style.width = '100%'
    //     ..style.height = '100%',
    // );
  }

  @override
  void dispose() {
    // Revoke blob URL to free memory
    // html.Url.revokeObjectUrl(_videoUrl);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
