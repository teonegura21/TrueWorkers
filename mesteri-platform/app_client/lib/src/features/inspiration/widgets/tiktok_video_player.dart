import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/inspiration_post.dart';

class TikTokVideoPlayer extends StatefulWidget {
  final InspirationPost post;
  final bool isPlaying;
  final Function(bool) onPlayStateChanged;

  const TikTokVideoPlayer({
    super.key,
    required this.post,
    required this.isPlaying,
    required this.onPlayStateChanged,
  });

  @override
  State<TikTokVideoPlayer> createState() => _TikTokVideoPlayerState();
}

class _TikTokVideoPlayerState extends State<TikTokVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Use the new networkUrl method instead of deprecated network
    _controller = VideoPlayerController.network(widget.post.videoUrl!);
    
    _controller.addListener(_onVideoControllerChanged);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    
    if (widget.isPlaying) {
      _controller.play();
    }
  }

  @override
  void didUpdateWidget(TikTokVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  void _onVideoControllerChanged() {
    if (_controller.value.isInitialized) {
      // Update play state when video ends
      if (_controller.value.position >= _controller.value.duration) {
        widget.onPlayStateChanged(false);
        _controller.seekTo(const Duration(seconds: 0));
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_controller.value.isPlaying) {
          _controller.pause();
          widget.onPlayStateChanged(false);
        } else {
          _controller.play();
          widget.onPlayStateChanged(true);
        }
      },
      child: VideoPlayer(_controller),
    );
  }
}