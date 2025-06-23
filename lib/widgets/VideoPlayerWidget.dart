import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? url;
  final String? filePath;
  final bool isNetwork;

  const VideoPlayerWidget({
    super.key,
    this.url,
    this.filePath,
    this.isNetwork = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.isNetwork) {
        _videoPlayerController = VideoPlayerController.network(widget.url!);
      } else {
        _videoPlayerController = VideoPlayerController.file(File(widget.filePath!));
      }

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Chewie(controller: _chewieController!);
  }
}