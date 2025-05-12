import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isLocalFile;
  final bool isNetwork;

  final Map<String, String>? httpHeaders;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.isLocalFile = false,
    this.httpHeaders,
    required this.isNetwork,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      // Dispose old controller only if it's already initialized
      if (_isInitialized) {
        await _controller.dispose();
      }

      setState(() {
        _isInitialized = false;
        _hasError = false;
        _errorMessage = '';
      });

      if (widget.isLocalFile) {
        _controller = VideoPlayerController.file(File(widget.videoUrl));
      } else {
        _controller = widget.httpHeaders != null
            ? VideoPlayerController.network(
                widget.videoUrl,
                httpHeaders: widget.httpHeaders!,
              )
            : VideoPlayerController.network(widget.videoUrl);
      }

      _controller.addListener(_videoListener);

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _videoListener() {
    if (_controller.value.hasError && mounted) {
      _handleError(_controller.value.errorDescription ?? 'Unknown video error');
    }
  }

  void _handleError(dynamic error) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
        _isInitialized = false;
      });
    }
    debugPrint('Video Player Error: $error');
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return _buildVideoPlayer();
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          _buildPlayPauseButton(),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      icon: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 50,
      ),
      onPressed: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading video...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(
            _errorMessage.isNotEmpty ? _errorMessage : 'Failed to load video',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeController,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
