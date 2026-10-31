import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _hasError = false;
  double _playbackSpeed = 1.0;
  bool _isMuted = false;
  int _savedResumeSeconds = 0;
  bool _showResumeBanner = false;

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
      _hasError = false;
    });

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
          });
        }
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
                  if (widget.video.assetPath.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'OFFLINE HD',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                    Text(
                      'Saved Position: ${_formatDuration(Duration(seconds: _savedResumeSeconds))}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const Spacer(),
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

            // Main Video Viewport or States
            if (_isInitializing)
              _buildLoadingViewport()
            else if (_hasError)
              _buildErrorViewport()
            else if (_controller != null && _controller!.value.isInitialized)
              _buildActivePlayerViewport()
            else
              _buildExternalLauncherCard(),

            // Learning Objectives
            if (widget.video.learningObjectives.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flag_circle_outlined, color: Colors.amberAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Learning Objectives (શીખવાના મુખ્ય મુદ્દા):',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...widget.video.learningObjectives.map((obj) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '• $obj',
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
                      ),
                    )),
                  ],
                ),
              ),

            // Video Description
            if (widget.video.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  widget.video.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
              ),

            // Action Buttons: Active Recall + AI Story + Practice MCQs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
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

  Widget _buildErrorViewport() {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_outline, color: Colors.amberAccent, size: 42),
          const SizedBox(height: 6),
          Text(
            widget.video.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () async {
                  final uri = Uri.tryParse(widget.video.url);
                  if (uri == null) return;
                  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (!opened) {
                    await launchUrl(uri, mode: LaunchMode.platformDefault);
                  }
                },
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Play Video Lesson', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purpleAccent,
                  side: const BorderSide(color: Colors.purpleAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                label: const Text('🎭 AI Story Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
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
            label: const Text('Open Lesson Video'),
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
                  const Icon(Icons.psychology, color: Colors.amberAccent, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Active Recall: ${widget.topicName}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'વિડિયો જોયા પછી તમારી યાદશક્તિ અને સમજ ચકાસો:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Divider(color: Colors.white24, height: 24),
              ...widget.questions.asMap().entries.map((entry) {
                final idx = entry.key;
                final q = entry.value;
                final questionText = q['question']?.toString() ?? '';
                final options = (q['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
                final correct = (q['correctAnswer'] as num?)?.toInt() ?? 0;
                final explanation = q['explanation']?.toString() ?? '';

                final selected = _selectedAnswers[idx];
                final isRevealed = _revealed[idx] ?? false;

                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isRevealed
                          ? (selected == correct ? Colors.greenAccent : Colors.redAccent)
                          : Colors.white12,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'પ્રશ્ન ${idx + 1}: $questionText',
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold, height: 1.35),
                        ),
                        const SizedBox(height: 10),
                        ...options.asMap().entries.map((optEntry) {
                          final optIdx = optEntry.key;
                          final optText = optEntry.value;

                          Color optColor = Colors.white12;
                          Color textColor = Colors.white70;

                          if (isRevealed) {
                            if (optIdx == correct) {
                              optColor = Colors.green.shade800;
                              textColor = Colors.white;
                            } else if (selected == optIdx) {
                              optColor = Colors.red.shade800;
                              textColor = Colors.white;
                            }
                          } else if (selected == optIdx) {
                            optColor = Colors.blueAccent.shade700;
                            textColor = Colors.white;
                          }

                          return InkWell(
                            onTap: isRevealed
                                ? null
                                : () {
                                    setState(() {
                                      _selectedAnswers[idx] = optIdx;
                                      _revealed[idx] = true;
                                    });
                                  },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: optColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Colors.white24,
                                    child: Text(
                                      String.fromCharCode(65 + optIdx),
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      optText,
                                      style: TextStyle(color: textColor, fontSize: 12.5),
                                    ),
                                  ),
                                  if (isRevealed && optIdx == correct)
                                    const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                                  if (isRevealed && selected == optIdx && optIdx != correct)
                                    const Icon(Icons.cancel, color: Colors.redAccent, size: 18),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (isRevealed && explanation.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '💡 સમજૂતી: $explanation',
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 11.5, height: 1.35),
                            ),
                          ),
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
