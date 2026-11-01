import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../models/practice_mode.dart';
import '../models/study_material.dart';
import '../screens/question_practice_screen.dart';
import '../screens/study_material/concept_story_screen.dart';
import '../services/question_filter.dart';
import '../services/question_service.dart';

class TopicVideoPlayerWidget extends StatefulWidget {
  final StudyVideo video;
  final String topicName;
  final String subjectName;

  const TopicVideoPlayerWidget({
    super.key,
    required this.video,
    required this.topicName,
    this.subjectName = 'I.C. Engines',
  });

  @override
  State<TopicVideoPlayerWidget> createState() => _TopicVideoPlayerWidgetState();
}

class _TopicVideoPlayerWidgetState extends State<TopicVideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitializing = true;
  double _playbackSpeed = 1.0;
  bool _isMuted = false;
  int _savedResumeSeconds = 0;
  bool _showResumeBanner = false;

  // Offline Interactive Animation Player State
  int _currentStepIndex = 0;
  bool _isAutoPlayingSteps = false;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _checkSavedProgress();
    _initVideoController();
  }

  String get _storageKey {
    final vId = widget.video.videoId.isNotEmpty ? widget.video.videoId : widget.video.title;
    return 'video_pos_${vId.replaceAll(' ', '_')}';
  }

  List<String> get _stepSequence {
    if (widget.video.learningObjectives.isNotEmpty) {
      return widget.video.learningObjectives;
    }
    return [
      '૧. ${widget.topicName} — પાયાનો સિદ્ધાંત, ચોક્કસ વ્યાખ્યા અને કાર્યપદ્ધતિ.',
      '૨. ${widget.topicName} — જરૂરી ગણિતીય સમીકરણો, SI એકમો અને સંબંધિત કાયદાઓ.',
      '૩. ${widget.topicName} — ઔદ્યોગિક ઉપયોગો, ફાયદા-મર્યાદાઓ અને તફાવતો.',
      '૪. ${widget.topicName} — GSSSB AAE / SSC JE પરીક્ષાલક્ષી ગોલ્ડન પોઇન્ટ્સ અને એક્ઝામ ટ્રેપ્સ.',
    ];
  }

  void _startStepAutoPlay() {
    _stepTimer?.cancel();
    setState(() {
      _isAutoPlayingSteps = true;
    });

    _stepTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _currentStepIndex = (_currentStepIndex + 1) % _stepSequence.length;
      });
    });
  }

  void _stopStepAutoPlay() {
    _stepTimer?.cancel();
    if (mounted) {
      setState(() {
        _isAutoPlayingSteps = false;
      });
    }
  }

  void _toggleStepAutoPlay() {
    if (_isAutoPlayingSteps) {
      _stopStepAutoPlay();
    } else {
      _startStepAutoPlay();
    }
  }

  Future<void> _checkSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pos = prefs.getInt(_storageKey) ?? 0;
      if (mounted && pos > 5) {
        setState(() {
          _savedResumeSeconds = pos;
          _showResumeBanner = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveCurrentProgress(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, seconds);
    } catch (_) {}
  }

  Future<void> _initVideoController() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      // 1. Try local video asset if assetPath is provided
      if (widget.video.assetPath.isNotEmpty) {
        try {
          _controller = VideoPlayerController.asset(widget.video.assetPath);
          await _controller!.initialize();
        } catch (assetErr) {
          debugPrint('Asset video init failed, fallback to offline concept player: $assetErr');
          _controller?.dispose();
          _controller = null;
        }
      }

      // 2. Try network video if url is a valid stream / mp4 URL
      if (_controller == null && widget.video.url.isNotEmpty && widget.video.url.startsWith('http')) {
        try {
          _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.url));
          await _controller!.initialize();
        } catch (netErr) {
          debugPrint('Network video init failed, fallback to offline concept player: $netErr');
          _controller?.dispose();
          _controller = null;
        }
      }

      if (_controller == null) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return;
      }

      _controller!.setLooping(false);

      _controller!.addListener(() {
        if (!mounted || _controller == null) return;
        final posSec = _controller!.value.position.inSeconds;
        if (posSec > 0 && posSec % 5 == 0) {
          _saveCurrentProgress(posSec);
        }
        setState(() {});
      });

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _controller?.dispose();
        _controller = null;
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  void _resumeFromSavedPosition() {
    if (_controller != null && _controller!.value.isInitialized && _savedResumeSeconds > 0) {
      _controller!.seekTo(Duration(seconds: _savedResumeSeconds));
      _controller!.play();
      setState(() {
        _showResumeBanner = false;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) {
      _toggleStepAutoPlay();
      return;
    }
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

  Future<void> _openPracticeScreen() async {
    try {
      final all = await QuestionService.loadQuestionsBySubject(widget.subjectName);
      final filtered = getRelatedQuestions(
        questions: all,
        subject: widget.subjectName,
        topic: widget.topicName,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionPracticeScreen(
            questions: filtered.isNotEmpty ? filtered : all,
            subject: widget.subjectName,
            subTopic: widget.topicName,
            config: PracticeConfig.practice,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load practice questions: $e')),
      );
    }
  }

  void _openRecallQuestionsSheet() {
    final questions = widget.video.recallQuestions;
    if (questions.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _RecallQuestionsSheet(
          questions: questions,
          topicName: widget.topicName,
        );
      },
    );
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
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
                  if (widget.video.episodeNumber > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'EP ${widget.video.episodeNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.video.assetPath.isNotEmpty ? Colors.green.shade800 : Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.video.assetPath.isNotEmpty ? 'OFFLINE HD' : '100% OFFLINE',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Resume Playback Banner if available
            if (_showResumeBanner && _savedResumeSeconds > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.blueGrey.shade900,
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Saved Position: ${_formatDuration(Duration(seconds: _savedResumeSeconds))}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _resumeFromSavedPosition,
                      child: const Text(
                        'Resume ▶',
                        style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Video Viewport or Offline Concept Player (100% In-App Offline)
            if (_isInitializing)
              _buildLoadingViewport()
            else if (_controller != null && _controller!.value.isInitialized)
              _buildActivePlayerViewport()
            else
              _buildInAppConceptPlayer(),

            // Video Description
            if (widget.video.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  widget.video.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
              ),

            // Action Buttons: Play Video + Active Recall + AI Story + Practice MCQs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      (_controller != null && _controller!.value.isInitialized && _controller!.value.isPlaying) || _isAutoPlayingSteps
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 16,
                    ),
                    label: Text(
                      (_controller != null && _controller!.value.isInitialized && _controller!.value.isPlaying) || _isAutoPlayingSteps
                          ? 'Pause Lesson'
                          : '▶ Play Video Lesson',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (widget.video.recallQuestions.isNotEmpty)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _openRecallQuestionsSheet,
                      icon: const Icon(Icons.psychology, size: 16),
                      label: Text(
                        '🧠 Active Recall (${widget.video.recallQuestions.length} Qs)',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purpleAccent,
                      side: const BorderSide(color: Colors.purpleAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConceptStoryScreen(
                            topic: widget.topicName,
                            subject: widget.subjectName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_stories, size: 16),
                    label: const Text(
                      '🎭 AI Story Mode',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.lightGreenAccent,
                      side: const BorderSide(color: Colors.lightGreenAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _openPracticeScreen,
                    icon: const Icon(Icons.quiz_outlined, size: 16),
                    label: const Text(
                      '📝 Practice MCQs',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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

        VideoProgressIndicator(
          _controller!,
          allowScrubbing: true,
          colors: const VideoProgressColors(
            playedColor: Colors.amberAccent,
            bufferedColor: Colors.white24,
            backgroundColor: Colors.white12,
          ),
        ),

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

  Widget _buildInAppConceptPlayer() {
    final steps = _stepSequence;
    final currentStep = steps[_currentStepIndex % steps.length];

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.movie_creation_outlined, color: Colors.amberAccent, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.video.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '100% OFFLINE',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated Visual Step Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isAutoPlayingSteps ? Colors.amberAccent : Colors.white24,
                width: _isAutoPlayingSteps ? 2.0 : 1.0,
              ),
              boxShadow: _isAutoPlayingSteps
                  ? [
                      BoxShadow(
                        color: Colors.amberAccent.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isAutoPlayingSteps ? Icons.play_circle_fill : Icons.pause_circle_filled,
                          color: _isAutoPlayingSteps ? Colors.greenAccent : Colors.amberAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Step ${_currentStepIndex + 1} of ${steps.length}',
                          style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                      ],
                    ),
                    if (_isAutoPlayingSteps)
                      const Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amberAccent),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Playing...',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Smooth animated transition for step text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentStepIndex),
                    child: Text(
                      currentStep,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Step Navigation Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _currentStepIndex = (_currentStepIndex - 1 + steps.length) % steps.length;
                        });
                      },
                    ),
                    Row(
                      children: List.generate(steps.length, (idx) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentStepIndex == idx ? Colors.amberAccent : Colors.white24,
                          ),
                        );
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _currentStepIndex = (_currentStepIndex + 1) % steps.length;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Main Interactive Action Buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAutoPlayingSteps ? Colors.orangeAccent : Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: _toggleStepAutoPlay,
                icon: Icon(_isAutoPlayingSteps ? Icons.pause : Icons.play_arrow_rounded, size: 20),
                label: Text(
                  _isAutoPlayingSteps ? '⏸️ Pause Lesson' : '▶ Play Animated Lesson',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConceptStoryScreen(
                        topic: widget.topicName,
                        subject: widget.subjectName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_stories, size: 18),
                label: const Text('🎭 Play AI Visual Story', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: _openPracticeScreen,
                icon: const Icon(Icons.quiz, size: 18),
                label: const Text('📝 Solve Topic MCQs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecallQuestionsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String topicName;

  const _RecallQuestionsSheet({
    required this.questions,
    required this.topicName,
  });

  @override
  State<_RecallQuestionsSheet> createState() => _RecallQuestionsSheetState();
}

class _RecallQuestionsSheetState extends State<_RecallQuestionsSheet> {
  final Map<int, int> _selectedAnswers = {};
  final Map<int, bool> _revealed = {};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.amberAccent, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🧠 Active Recall: ${widget.topicName}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(widget.questions.length, (index) {
                final q = widget.questions[index];
                final questionText = q['question'] ?? 'Question ${index + 1}';
                final options = (q['options'] as List? ?? []).map((e) => e.toString()).toList();
                final correct = q['correctAnswer'] as int? ?? 0;
                final explanation = q['explanation'] as String? ?? '';
                final isAnswered = _selectedAnswers.containsKey(index);
                final selected = _selectedAnswers[index];

                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${index + 1}. $questionText',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(options.length, (optIdx) {
                          Color color = Colors.white12;
                          if (isAnswered) {
                            if (optIdx == correct) {
                              color = Colors.green.shade800;
                            } else if (optIdx == selected) {
                              color = Colors.red.shade800;
                            }
                          }

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedAnswers[index] = optIdx;
                                _revealed[index] = true;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${String.fromCharCode(65 + optIdx)}. ',
                                    style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Expanded(
                                    child: Text(
                                      options[optIdx],
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (_revealed[index] == true && explanation.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '💡 Explanation: $explanation',
                              style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
