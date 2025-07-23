import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;


// Widget para mostrar thumbnail de video con ícono de reproducción
class VideoThumbnail extends StatefulWidget {
  final String url;

  const VideoThumbnail({Key? key, required this.url}) : super(key: key);

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  Uint8List? _thumbnailBytes;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
  final thumbnail = await vt.VideoThumbnail.thumbnailData(
    video: widget.url,
    imageFormat: vt.ImageFormat.JPEG,
    maxWidth: 1280,
    quality: 75,
  );
  if (mounted) {
    setState(() {
      _thumbnailBytes = thumbnail;
    });
  }
}

  void _openFullscreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(url: widget.url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbnailBytes == null) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: _openFullscreen,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.memory(_thumbnailBytes!, fit: BoxFit.cover),
          const Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
        ],
      ),
    );
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final String url;

  const FullscreenVideoPlayer({Key? key, required this.url}) : super(key: key);

  @override
  _FullscreenVideoPlayerState createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController _controller;
  double _volume = 1.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      }).catchError((error) {
        if (!mounted) return;
        setState(() {
          _error = error.toString();
        });
      });

    _controller.addListener(() {
      if (_controller.value.hasError) {
        if (!mounted) return;
        setState(() {
          _error = _controller.value.errorDescription;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_controller.value.isInitialized) return;
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _setVolume(double value) {
    setState(() {
      _volume = value;
      _controller.setVolume(_volume);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error al cargar video:\n$_error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayPause,
                ),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0,
                    max: 1,
                    onChanged: _setVolume,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                  ),
                ),
                const Icon(Icons.volume_up, color: Colors.white),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
