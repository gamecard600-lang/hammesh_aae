import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../models/study_material.dart';

class TopicVideoPlayerWidget extends StatefulWidget {
  final StudyVideo video;
  final String topicName;

  const TopicVideoPlayerWidget({
    super.key,
    required this.video,
    required this.topicName,
  });

  @override
  State<TopicVideoPlayerWidget> createState() => _TopicVideoPlayerWidgetState();
}

class _TopicVideoPlayerWidgetState extends State<TopicVideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitializing = true;
  bool _hasError = false;
  String _errorMessage = '';
  double _playbackSpeed = 1.0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initVideoController();
  }

  Future<void> _initVideoController() async {
    setState(() {
      _isInitializing = true;
      _hasError = false;
      _errorMessage = '';
    });

    // Official Flutter video_player plugin does not provide C++ desktop playback plugin implementation.
    // On Windows/Desktop, fall back cleanly to the Interactive Video Launcher Card.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = false;
        });
      }
      return;
    }

    try {
      if (widget.video.assetPath.isNotEmpty) {
        try {
          _controller = VideoPlayerController.asset(widget.video.assetPath);
          await _controller!.initialize();
        } catch (assetErr) {
          debugPrint('Asset video init failed, attempting network fallback: $assetErr');
          _controller?.dispose();
          _controller = null;
        }
      }

      if (_controller == null &&
          widget.video.url.isNotEmpty &&
          (widget.video.url.contains('.mp4') || widget.video.url.contains('raw.githubusercontent.com'))) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.url));
        await _controller!.initialize();
      }

      if (_controller == null) {
        // Fallback info mode for external YouTube / web URLs
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return;
      }

      _controller!.setLooping(false);
      
      _controller!.addListener(() {
        if (mounted) setState(() {});
      });

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (e is UnimplementedError ||
            e.toString().contains('UnimplementedError') ||
            e.toString().contains('init() has not been implemented')) {
          _controller?.dispose();
          _controller = null;
          setState(() {
            _isInitializing = false;
            _hasError = false;
          });
        } else {
          setState(() {
            _isInitializing = false;
            _hasError = true;
            _errorMessage = 'Playback Error: Unable to load video. $e';
          });
        }
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _cycleSpeed() {
    if (_controller == null) return;
    final speeds = [1.0, 1.25, 1.5, 2.0];
    final nextIndex = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    final newSpeed = speeds[nextIndex];
    setState(() {
      _playbackSpeed = newSpeed;
    });
    _controller!.setPlaybackSpeed(newSpeed);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: Colors.amber.shade900.withValues(alpha: 0.3),
              child: Row(
                children: [
                  const Icon(Icons.ondemand_video_rounded, color: Colors.amberAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (widget.video.assetPath.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'OFFLINE ASSET',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            // Main Video Viewport or States
            if (_isInitializing)
              _buildLoadingViewport()
            else if (_hasError)
              _buildErrorViewport()
            else if (_controller != null && _controller!.value.isInitialized)
              _buildActivePlayerViewport()
            else
              _buildExternalLauncherCard(),

            // Video Description
            if (widget.video.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.video.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingViewport() {
    return Container(
      height: 200,
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amberAccent),
            SizedBox(height: 12),
            Text(
              'Loading Video Lesson...',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorViewport() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.amber, size: 42),
          const SizedBox(height: 8),
          Text(
            _errorMessage.isNotEmpty ? _errorMessage : 'Video playback error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: _initVideoController,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry Video'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlayerViewport() {
    final value = _controller!.value;

    return Column(
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: AspectRatio(
            aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller!),
                // Play / Pause Overlay Icon
                AnimatedOpacity(
                  opacity: !value.isPlaying ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amberAccent, width: 2),
                    ),
                    child: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.amberAccent,
                      size: 42,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Video Progress Slider
        VideoProgressIndicator(
          _controller!,
          allowScrubbing: true,
          colors: const VideoProgressColors(
            playedColor: Colors.amberAccent,
            bufferedColor: Colors.white24,
            backgroundColor: Colors.white12,
          ),
        ),

        // Bottom Controls Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: Colors.black87,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.amberAccent,
                ),
                onPressed: _togglePlayPause,
              ),
              IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white70,
                ),
                onPressed: _toggleMute,
              ),
              Text(
                '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              TextButton(
                onPressed: _cycleSpeed,
                child: Text(
                  '${_playbackSpeed}x',
                  style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExternalLauncherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          const Icon(Icons.play_circle_outline, color: Colors.amberAccent, size: 48),
          const SizedBox(height: 8),
          Text(
            widget.video.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final uri = Uri.tryParse(widget.video.url);
              if (uri == null) return;
              final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!opened) {
                await launchUrl(uri, mode: LaunchMode.platformDefault);
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open External Lesson Video'),
          ),
        ],
      ),
    );
  }
}
