import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/concept_story.dart';
import '../../services/ai_study_assistant_service.dart';

class ConceptStoryScreen extends StatefulWidget {
  final String topic;
  final String subject;

  const ConceptStoryScreen({
    super.key,
    required this.topic,
    required this.subject,
  });

  @override
  State<ConceptStoryScreen> createState() => _ConceptStoryScreenState();
}

class _ConceptStoryScreenState extends State<ConceptStoryScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _audioEnabled = true;
  bool _isPaused = false;

  ConceptStory? _story;
  int _currentSceneIndex = 0;
  double _sceneProgress = 0.0;
  Timer? _progressAnimationTimer;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _loadStory();
  }

  Future<void> _loadStory() async {
    setState(() {
      _isLoading = true;
      _currentSceneIndex = 0;
      _sceneProgress = 0.0;
    });

    final story = await AiStudyAssistantService.generateConceptStory(
      topic: widget.topic,
      subject: widget.subject,
    );

    if (mounted) {
      setState(() {
        _story = story;
        _isLoading = false;
      });
      _startScene();
    }
  }

  void _startScene() {
    _progressAnimationTimer?.cancel();

    if (_story == null || _story!.scenes.isEmpty) return;

    setState(() {
      _sceneProgress = 0.0;
    });

    const totalSeconds = 8;
    const intervalMs = 100;
    const increment = intervalMs / (totalSeconds * 1000);

    _progressAnimationTimer = Timer.periodic(
      const Duration(milliseconds: intervalMs),
      (timer) {
        if (!mounted || _isPaused) return;
        setState(() {
          _sceneProgress += increment;
          if (_sceneProgress >= 1.0) {
            _sceneProgress = 1.0;
            timer.cancel();
            _nextScene();
          }
        });
      },
    );
  }

  void _nextScene() {
    if (_story == null) return;
    if (_currentSceneIndex < _story!.scenes.length - 1) {
      setState(() {
        _currentSceneIndex++;
      });
      _startScene();
    } else {
      _progressAnimationTimer?.cancel();
    }
  }

  void _previousScene() {
    if (_currentSceneIndex > 0) {
      setState(() {
        _currentSceneIndex--;
      });
      _startScene();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF1E88E5);
    }
  }

  @override
  void dispose() {
    _progressAnimationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141D),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _story == null || _story!.scenes.isEmpty
                ? _buildErrorState()
                : _buildStoryContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.1).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 64,
                color: Colors.lightBlueAccent,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '🎭 Generating AI Concept Story...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Creating a Gujarati animated story for "${widget.topic}"',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: Colors.lightBlueAccent),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            'Story Connection Standby',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadStory,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent() {
    final scene = _story!.scenes[_currentSceneIndex];
    final themeColor = _parseColor(scene.colorThemeHex);

    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth * 0.3) {
          _previousScene();
        } else if (details.globalPosition.dx > screenWidth * 0.7) {
          _nextScene();
        } else {
          _togglePause();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeColor.withValues(alpha: 0.35),
              const Color(0xFF0F172A),
              const Color(0xFF090D16),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Top Progress Bars & Header
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Progress Bars
                  Row(
                    children: List.generate(_story!.scenes.length, (index) {
                      double progress = 0.0;
                      if (index < _currentSceneIndex) {
                        progress = 1.0;
                      } else if (index == _currentSceneIndex) {
                        progress = _sceneProgress;
                      }
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white24,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  // Header Bar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.topic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              widget.subject,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _audioEnabled ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _audioEnabled = !_audioEnabled;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                        ),
                        onPressed: _togglePause,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Scene Card Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Animated Visual Symbol Badge
                    ScaleTransition(
                      scale: Tween(begin: 0.95, end: 1.08).animate(
                        CurvedAnimation(
                          parent: _pulseController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: themeColor.withValues(alpha: 0.6),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          scene.visualSymbol,
                          style: const TextStyle(fontSize: 52),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Scene Title
                    Text(
                      scene.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Narration Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        scene.narration,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Key Takeaway / Formula Highlight Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: themeColor.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.key, color: Colors.amberAccent, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'KEY TAKEAWAY / કન્સેપ્ટ પોઈન્ટ',
                                style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scene.keyTakeaway,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Footer
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black26,
              child: Row(
                children: [
                  if (_currentSceneIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: _previousScene,
                    )
                  else
                    const SizedBox(width: 48),

                  Expanded(
                    child: Text(
                      'Scene ${_currentSceneIndex + 1} of ${_story!.scenes.length}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ),

                  if (_currentSceneIndex < _story!.scenes.length - 1)
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: _nextScene,
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Complete'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
