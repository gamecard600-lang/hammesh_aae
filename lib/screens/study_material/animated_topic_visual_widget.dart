import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/study_material.dart';

class AnimatedTopicVisualWidget extends StatefulWidget {
  final StudyMaterial material;

  const AnimatedTopicVisualWidget({
    super.key,
    required this.material,
  });

  @override
  State<AnimatedTopicVisualWidget> createState() => _AnimatedTopicVisualWidgetState();
}

class _AnimatedTopicVisualWidgetState extends State<AnimatedTopicVisualWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = true;
  double _playbackSpeed = 1.0;
  int _currentStepIndex = 0;
  String _activeTab = 'animation'; // animation, pv, ts, steps, online

  VisualLearning? get vl => widget.material.visualLearning;

  bool get isVisualEnabled {
    if (vl == null) return false;
    return vl!.enabled || vl!.visualRequired;
  }

  String get animationKey {
    if (vl != null && vl!.animationKey.isNotEmpty) {
      return vl!.animationKey;
    }
    // Fallback detection from title if key is empty
    final title = '${widget.material.subject} ${widget.material.topic} ${widget.material.title}'.toLowerCase();
    if (title.contains('carnot')) return 'carnot_cycle';
    if (title.contains('otto')) return 'otto_cycle';
    if (title.contains('diesel')) return 'diesel_cycle';
    if (title.contains('dual')) return 'dual_cycle';
    if (title.contains('brayton')) return 'brayton_cycle';
    if (title.contains('rankine')) return 'rankine_cycle';
    if (title.contains('vcr') || title.contains('vapor compression')) return 'vcr_cycle';
    if (title.contains('bell-coleman')) return 'bell_coleman_cycle';
    if (title.contains('mohr')) return 'mohrs_circle';
    if (title.contains('sfd') || title.contains('bmd')) return 'sfd_bmd';
    if (title.contains('pump')) return 'centrifugal_pump';
    if (title.contains('bernoulli') || title.contains('venturi')) return 'bernoulli';
    if (title.contains('gear')) return 'gears_train';
    if (title.contains('cam')) return 'cam_follower';
    if (title.contains('casting')) return 'casting_flow';
    if (title.contains('machining') || title.contains('lathe')) return 'lathe_cutting';
    return 'general_process';
  }

  List<String> get stepSequence {
    if (vl != null && vl!.sequence.isNotEmpty) {
      return vl!.sequence;
    }
    return [
      'Phase 1: Initial System State',
      'Phase 2: Thermodynamic Transformation / Work Transfer',
      'Phase 3: High Energy / Peak Pressure Condition',
      'Phase 4: Return State / Exhaust / Energy Rejection',
    ];
  }

  List<String> get availableDiagrams {
    if (vl != null && vl!.diagrams.isNotEmpty) {
      return vl!.diagrams;
    }
    final key = animationKey;
    if (['carnot_cycle', 'otto_cycle', 'diesel_cycle', 'dual_cycle', 'brayton_cycle', 'stirling_cycle', 'ericsson_cycle', 'bell_coleman_cycle', 'air_compressor'].contains(key)) {
      return ['pv', 'ts'];
    }
    if (['rankine_cycle', 'reheat_rankine_cycle', 'regenerative_rankine_cycle'].contains(key)) {
      return ['pv', 'ts'];
    }
    if (['vcr_cycle'].contains(key)) {
      return ['ph', 'ts'];
    }
    if (['mohrs_circle', 'sfd_bmd', 'stress_strain_curve', 'iron_carbon_diagram', 'psychrometric_chart'].contains(key)) {
      return ['graph'];
    }
    return ['schematic'];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        final totalSteps = stepSequence.length;
        if (totalSteps > 0) {
          final newIndex = (_controller.value * totalSteps).floor().clamp(0, totalSteps - 1);
          if (newIndex != _currentStepIndex) {
            setState(() {
              _currentStepIndex = newIndex;
            });
          }
        }
      });

    if (isVisualEnabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  void _stepNext() {
    final totalSteps = stepSequence.length;
    if (totalSteps == 0) return;
    setState(() {
      _currentStepIndex = (_currentStepIndex + 1) % totalSteps;
      _controller.value = _currentStepIndex / totalSteps;
    });
  }

  void _stepPrev() {
    final totalSteps = stepSequence.length;
    if (totalSteps == 0) return;
    setState(() {
      _currentStepIndex = (_currentStepIndex - 1 + totalSteps) % totalSteps;
      _controller.value = _currentStepIndex / totalSteps;
    });
  }

  void _cycleSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }
      _controller.duration = Duration(milliseconds: (4000 / _playbackSpeed).round());
      if (_isPlaying) {
        _controller.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Strictly enforcing Rule 1 & Rule 14: If visual is NOT required for this topic, show NOTHING.
    if (!isVisualEnabled) {
      return const SizedBox.shrink();
    }

    final steps = stepSequence;
    final diagrams = availableDiagrams;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.motion_photos_on, color: Colors.amberAccent, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vl?.title.isNotEmpty == true ? vl!.title : widget.material.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'INTERACTIVE VISUAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (vl?.purpose.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    vl!.purpose,
                    style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                  ),
                ],
              ],
            ),
          ),

          // Tab Switcher Bar (Animation / PV Diagram / TS Diagram / Steps)
          Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('animation', '🎬 Animated Working', Icons.play_circle_outline),
                  if (diagrams.contains('pv'))
                    _buildTabButton('pv', '📈 P-V Diagram', Icons.show_chart),
                  if (diagrams.contains('ts'))
                    _buildTabButton('ts', '🌡️ T-S Diagram', Icons.thermostat),
                  if (diagrams.contains('ph'))
                    _buildTabButton('ph', '📊 P-H Diagram', Icons.bar_chart),
                  if (diagrams.contains('graph'))
                    _buildTabButton('graph', '📐 Plot / Curve', Icons.draw),
                  _buildTabButton('steps', '📋 Process Steps (${steps.length})', Icons.list_alt),
                  if (vl?.videoUrl != null || vl?.imageUrl != null)
                    _buildTabButton('online', '🌐 Online Media', Icons.language),
                ],
              ),
            ),
          ),

          // Main Interactive Canvas Area
          Container(
            height: 240,
            decoration: const BoxDecoration(
              color: Color(0xFF090D16), // Dark engineering canvas background
            ),
            child: _buildCanvasContent(),
          ),

          // Control Bar (Play, Pause, Step Next/Prev, Speed)
          if (_activeTab != 'steps')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.amberAccent,
                      size: 28,
                    ),
                    tooltip: _isPlaying ? 'Pause' : 'Play',
                  ),
                  IconButton(
                    onPressed: _stepPrev,
                    icon: const Icon(Icons.skip_previous, color: Colors.white70, size: 22),
                    tooltip: 'Previous Process Step',
                  ),
                  IconButton(
                    onPressed: _stepNext,
                    icon: const Icon(Icons.skip_next, color: Colors.white70, size: 22),
                    tooltip: 'Next Process Step',
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _cycleSpeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade400),
                      ),
                      child: Text(
                        '${_playbackSpeed}x Speed',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Active Step Context Box
          if (steps.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50.withValues(alpha: 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Step ${_currentStepIndex + 1} of ${steps.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentStepIndex + 1) / steps.length,
                            backgroundColor: Colors.blue.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[_currentStepIndex],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String id, String label, IconData icon) {
    final isSelected = _activeTab == id;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        avatar: Icon(icon, size: 14, color: isSelected ? Colors.black : Colors.white70),
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        selectedColor: Colors.amberAccent,
        backgroundColor: Colors.blueGrey.shade900,
        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _activeTab = id;
            });
          }
        },
      ),
    );
  }

  Widget _buildCanvasContent() {
    if (_activeTab == 'steps') {
      return _buildProcessStepsList();
    }

    if (_activeTab == 'online') {
      return _buildOnlineMediaView();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _TechnicalConceptPainter(
            animationKey: animationKey,
            viewMode: _activeTab, // animation, pv, ts, ph, graph
            progress: _controller.value,
            stepIndex: _currentStepIndex,
            stepsCount: stepSequence.length,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildProcessStepsList() {
    final steps = stepSequence;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final isCurrent = index == _currentStepIndex;
        return Card(
          color: isCurrent ? Colors.blue.shade900 : const Color(0xFF1E293B),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 12,
              backgroundColor: isCurrent ? Colors.amberAccent : Colors.blueGrey,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? Colors.black : Colors.white,
                ),
              ),
            ),
            title: Text(
              steps[index],
              style: TextStyle(
                color: Colors.white,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                fontSize: 12.5,
              ),
            ),
            trailing: isCurrent ? const Icon(Icons.play_arrow, color: Colors.amberAccent, size: 18) : null,
            onTap: () {
              setState(() {
                _currentStepIndex = index;
                _controller.value = index / steps.length;
                _activeTab = 'animation';
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildOnlineMediaView() {
    final imageUrl = vl?.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return InteractiveViewer(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, color: Colors.amberAccent, size: 36),
                  const SizedBox(height: 8),
                  const Text('Online diagram unavailable offline.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() => _activeTab = 'animation'),
                    child: const Text('View Offline Canvas Visual'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_fill, color: Colors.amberAccent, size: 48),
          const SizedBox(height: 8),
          Text(vl?.title ?? 'Online Video Explanation', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => setState(() => _activeTab = 'animation'),
            icon: const Icon(Icons.art_track),
            label: const Text('Switch to Technical Canvas Visual'),
          ),
        ],
      ),
    );
  }
}

class _TechnicalConceptPainter extends CustomPainter {
  final String animationKey;
  final String viewMode; // animation, pv, ts, ph, graph
  final double progress;
  final int stepIndex;
  final int stepsCount;

  _TechnicalConceptPainter({
    required this.animationKey,
    required this.viewMode,
    required this.progress,
    required this.stepIndex,
    required this.stepsCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (viewMode == 'pv') {
      _paintPvDiagram(canvas, size);
      return;
    }
    if (viewMode == 'ts') {
      _paintTsDiagram(canvas, size);
      return;
    }
    if (viewMode == 'ph') {
      _paintPhDiagram(canvas, size);
      return;
    }
    if (viewMode == 'graph') {
      _paintGraphDiagram(canvas, size);
      return;
    }

    // Animation view mode
    switch (animationKey) {
      case 'carnot_cycle':
      case 'otto_cycle':
      case 'diesel_cycle':
      case 'dual_cycle':
        _paintPistonEngineCycle(canvas, size);
        break;
      case 'brayton_cycle':
        _paintGasTurbineBrayton(canvas, size);
        break;
      case 'rankine_cycle':
      case 'reheat_rankine_cycle':
      case 'regenerative_rankine_cycle':
        _paintSteamPowerPlant(canvas, size);
        break;
      case 'vcr_cycle':
      case 'bell_coleman_cycle':
        _paintRefrigerationSystem(canvas, size);
        break;
      case 'centrifugal_pump':
      case 'reciprocating_pump':
        _paintPumpSystem(canvas, size);
        break;
      case 'hydraulic_turbine':
        _paintHydraulicTurbine(canvas, size);
        break;
      case 'bernoulli':
        _paintVenturiBernoulli(canvas, size);
        break;
      case 'pipe_flow':
      case 'viscosity_profile':
        _paintPipeViscosityFlow(canvas, size);
        break;
      case 'mohrs_circle':
        _paintMohrsCircleCanvas(canvas, size);
        break;
      case 'sfd_bmd':
        _paintSfdBmdCanvas(canvas, size);
        break;
      case 'stress_strain_curve':
        _paintStressStrainCanvas(canvas, size);
        break;
      case 'gears_train':
        _paintGearsCanvas(canvas, size);
        break;
      case 'cam_follower':
        _paintCamFollowerCanvas(canvas, size);
        break;
      case 'casting_flow':
        _paintCastingCanvas(canvas, size);
        break;
      case 'lathe_cutting':
        _paintLatheCuttingCanvas(canvas, size);
        break;
      default:
        _paintGeneralEngineeringCanvas(canvas, size);
        break;
    }
  }

  // P-V DIAGRAM PAINTER (TECHNICALLY CORRECT FOR THERMODYNAMIC CYCLES)
  void _paintPvDiagram(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final axisPaint = Paint()..color = Colors.white70..strokeWidth = 2;
    final margin = 40.0;
    final ox = margin;
    final oy = h - margin;
    final rx = w - margin;
    final ry = margin;

    // Axes
    canvas.drawLine(Offset(ox, oy), Offset(rx, oy), axisPaint); // V axis
    canvas.drawLine(Offset(ox, oy), Offset(ox, ry), axisPaint); // P axis

    _drawText(canvas, 'Volume (V) →', Offset(rx - 70, oy + 10), Colors.white70, 11);
    _drawText(canvas, 'P (Pressure)', Offset(ox - 35, ry - 20), Colors.white70, 11);

    final path = Path();
    final p1 = Offset(ox + 30, oy - 20); // BDC low pressure
    final p2 = Offset(ox + 80, ry + 30); // TDC high pressure
    final p3 = Offset(ox + 160, ry + 30); // Expansion start
    final p4 = Offset(ox + 220, oy - 20); // BDC end

    if (animationKey.contains('otto')) {
      // 1->2 Isentropic compression, 2->3 Isochoric, 3->4 Isentropic expansion, 4->1 Isochoric
      path.moveTo(p1.dx, p1.dy);
      path.quadraticBezierTo(p1.dx + 20, p2.dy + 40, p2.dx, p2.dy); // 1-2
      path.lineTo(p2.dx, ry + 15); // 2-3 Constant volume line
      path.quadraticBezierTo(p2.dx + 60, p1.dy - 30, p4.dx, p4.dy); // 3-4
      path.lineTo(p1.dx, p1.dy); // 4-1
    } else if (animationKey.contains('diesel')) {
      // 1->2 Isentropic, 2->3 Isobaric, 3->4 Isentropic, 4->1 Isochoric
      path.moveTo(p1.dx, p1.dy);
      path.quadraticBezierTo(p1.dx + 20, p2.dy + 40, p2.dx, p2.dy);
      path.lineTo(p3.dx, p2.dy); // Isobaric horizontal line
      path.quadraticBezierTo(p3.dx + 40, p1.dy - 20, p4.dx, p4.dy);
      path.lineTo(p1.dx, p1.dy);
    } else {
      // Carnot / General
      path.moveTo(p1.dx, p1.dy);
      path.quadraticBezierTo(p1.dx + 30, p2.dy + 50, p2.dx, p2.dy);
      path.quadraticBezierTo(p2.dx + 50, p2.dy - 10, p3.dx, ry + 40);
      path.quadraticBezierTo(p3.dx + 30, p4.dy - 30, p4.dx, p4.dy);
      path.quadraticBezierTo(p1.dx + 80, p1.dy + 10, p1.dx, p1.dy);
    }

    final curvePaint = Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawPath(path, curvePaint);

    // State Points
    _drawPoint(canvas, p1, '1', Colors.amberAccent);
    _drawPoint(canvas, p2, '2', Colors.amberAccent);
    _drawPoint(canvas, p3, '3', Colors.amberAccent);
    _drawPoint(canvas, p4, '4', Colors.amberAccent);

    // Active state pulse
    final stepPos = [p1, p2, p3, p4][stepIndex % 4];
    canvas.drawCircle(stepPos, 8, Paint()..color = Colors.redAccent);

    _drawText(canvas, 'P-V Diagram (Cycle Direction 1→2→3→4→1)', Offset(ox + 30, ry + 5), Colors.amberAccent, 12);
  }

  // T-S DIAGRAM PAINTER (WITH SATURATION DOME WHERE APPLICABLE)
  void _paintTsDiagram(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final axisPaint = Paint()..color = Colors.white70..strokeWidth = 2;
    final margin = 40.0;
    final ox = margin;
    final oy = h - margin;
    final rx = w - margin;
    final ry = margin;

    canvas.drawLine(Offset(ox, oy), Offset(rx, oy), axisPaint); // S axis
    canvas.drawLine(Offset(ox, oy), Offset(ox, ry), axisPaint); // T axis

    _drawText(canvas, 'Entropy (S) →', Offset(rx - 70, oy + 10), Colors.white70, 11);
    _drawText(canvas, 'Temperature (T)', Offset(ox - 35, ry - 20), Colors.white70, 11);

    // Draw Vapor Saturation Dome for Rankine / VCR cycles
    if (animationKey.contains('rankine') || animationKey.contains('vcr')) {
      final domePath = Path();
      domePath.moveTo(ox + 20, oy - 10);
      domePath.quadraticBezierTo(w * 0.5, ry + 10, rx - 30, oy - 10);
      canvas.drawPath(domePath, Paint()..color = Colors.blue.shade400..style = PaintingStyle.stroke..strokeWidth = 2);
      _drawText(canvas, 'Vapor Saturation Dome', Offset(w * 0.38, ry + 25), Colors.blue.shade300, 10);
    }

    final p1 = Offset(ox + 50, oy - 30);
    final p2 = Offset(ox + 50, ry + 50);
    final p3 = Offset(rx - 70, ry + 50);
    final p4 = Offset(rx - 70, oy - 30);

    final cyclePath = Path();
    cyclePath.moveTo(p1.dx, p1.dy);
    cyclePath.lineTo(p2.dx, p2.dy);
    cyclePath.lineTo(p3.dx, p3.dy);
    cyclePath.lineTo(p4.dx, p4.dy);
    cyclePath.close();

    canvas.drawPath(cyclePath, Paint()..color = Colors.amberAccent..style = PaintingStyle.stroke..strokeWidth = 3);

    _drawPoint(canvas, p1, '1', Colors.cyanAccent);
    _drawPoint(canvas, p2, '2', Colors.cyanAccent);
    _drawPoint(canvas, p3, '3', Colors.cyanAccent);
    _drawPoint(canvas, p4, '4', Colors.cyanAccent);

    final stepPos = [p1, p2, p3, p4][stepIndex % 4];
    canvas.drawCircle(stepPos, 8, Paint()..color = Colors.redAccent);

    _drawText(canvas, 'T-S Diagram (Isentropics = Vertical Lines)', Offset(ox + 30, ry + 5), Colors.cyanAccent, 12);
  }

  void _paintPhDiagram(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final margin = 40.0;
    canvas.drawLine(Offset(margin, h - margin), Offset(w - margin, h - margin), Paint()..color = Colors.white70..strokeWidth = 2);
    canvas.drawLine(Offset(margin, h - margin), Offset(margin, margin), Paint()..color = Colors.white70..strokeWidth = 2);

    _drawText(canvas, 'Enthalpy (h) →', Offset(w - 110, h - margin + 10), Colors.white70, 11);
    _drawText(canvas, 'Pressure (P)', Offset(margin - 35, margin - 20), Colors.white70, 11);

    // Saturation Dome
    final dome = Path();
    dome.moveTo(margin + 20, h - margin - 10);
    dome.quadraticBezierTo(w * 0.45, margin + 20, w - margin - 40, h - margin - 10);
    canvas.drawPath(dome, Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 2);

    _drawText(canvas, 'Refrigeration P-h Dome (Throttling = Vertical 3-4)', Offset(margin + 20, margin + 10), Colors.amberAccent, 12);
  }

  void _paintGraphDiagram(Canvas canvas, Size size) {
    if (animationKey == 'mohrs_circle') {
      _paintMohrsCircleCanvas(canvas, size);
    } else if (animationKey == 'sfd_bmd') {
      _paintSfdBmdCanvas(canvas, size);
    } else if (animationKey == 'stress_strain_curve') {
      _paintStressStrainCanvas(canvas, size);
    } else {
      _drawGeneralGraph(canvas, size);
    }
  }

  void _paintPistonEngineCycle(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cX = w * 0.35;
    final cylTop = h * 0.2;
    final cylBottom = h * 0.8;
    final cylWidth = 110.0;

    // Cylinder Wall
    final wallPaint = Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawLine(Offset(cX - cylWidth / 2, cylTop), Offset(cX - cylWidth / 2, cylBottom), wallPaint);
    canvas.drawLine(Offset(cX + cylWidth / 2, cylTop), Offset(cX + cylWidth / 2, cylBottom), wallPaint);
    canvas.drawLine(Offset(cX - cylWidth / 2, cylTop), Offset(cX + cylWidth / 2, cylTop), wallPaint);

    // Piston position oscillates
    final pistonY = cylTop + 20 + (cylBottom - cylTop - 70) * (0.5 + 0.5 * math.sin(progress * 2 * math.pi));

    // Gas color changes
    final compressFactor = 1.0 - (pistonY - cylTop) / (cylBottom - cylTop);
    final gasColor = Color.lerp(Colors.blueAccent, Colors.redAccent, compressFactor)!;
    canvas.drawRect(Rect.fromLTRB(cX - cylWidth / 2 + 2, cylTop + 2, cX + cylWidth / 2 - 2, pistonY), Paint()..color = gasColor.withValues(alpha: 0.6));

    // Piston Block
    canvas.drawRect(Rect.fromLTRB(cX - cylWidth / 2 + 2, pistonY, cX + cylWidth / 2 - 2, pistonY + 28), Paint()..color = Colors.grey.shade400);

    // Connecting Rod
    canvas.drawLine(Offset(cX, pistonY + 28), Offset(cX, cylBottom + 10), wallPaint..color = Colors.white70);

    // Heat vectors Q_in / Q_out
    if (compressFactor > 0.6) {
      _drawArrow(canvas, Offset(cX - cylWidth / 2 - 30, cylTop + 30), Offset(cX - cylWidth / 2 + 5, cylTop + 30), Colors.amberAccent, 'Q_in');
    } else {
      _drawArrow(canvas, Offset(cX + cylWidth / 2 - 5, cylTop + 50), Offset(cX + cylWidth / 2 + 30, cylTop + 50), Colors.cyanAccent, 'Q_out');
    }

    _drawText(canvas, 'Piston-Cylinder Work & Heat Exchange', Offset(w * 0.55, h * 0.5), Colors.white, 13);
  }

  void _paintGasTurbineBrayton(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Compressor -> CC -> Turbine
    final comp = Rect.fromLTWH(w * 0.1, h * 0.3, 60, 80);
    final cc = Rect.fromLTWH(w * 0.4, h * 0.2, 80, 50);
    final turb = Rect.fromLTWH(w * 0.7, h * 0.3, 60, 80);

    canvas.drawRect(comp, Paint()..color = Colors.blue.shade800);
    canvas.drawRect(cc, Paint()..color = Colors.red.shade800);
    canvas.drawRect(turb, Paint()..color = Colors.amber.shade800);

    _drawText(canvas, 'COMP', Offset(comp.left + 10, comp.top + 30), Colors.white, 11);
    _drawText(canvas, 'COMB CHAMBER', Offset(cc.left + 5, cc.top + 18), Colors.white, 9);
    _drawText(canvas, 'TURBINE', Offset(turb.left + 5, turb.top + 30), Colors.white, 10);

    // Shaft
    canvas.drawLine(Offset(comp.right, h * 0.5), Offset(turb.left, h * 0.5), Paint()..color = Colors.white..strokeWidth = 4);
  }

  void _paintSteamPowerPlant(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pump = Offset(w * 0.2, h * 0.75);
    final boiler = Offset(w * 0.2, h * 0.25);
    final turbine = Offset(w * 0.8, h * 0.25);
    final condenser = Offset(w * 0.8, h * 0.75);

    final linePaint = Paint()..color = Colors.white54..strokeWidth = 2;
    canvas.drawLine(pump, boiler, linePaint);
    canvas.drawLine(boiler, turbine, linePaint);
    canvas.drawLine(turbine, condenser, linePaint);
    canvas.drawLine(condenser, pump, linePaint);

    canvas.drawCircle(pump, 20, Paint()..color = Colors.blue.shade700);
    canvas.drawCircle(boiler, 20, Paint()..color = Colors.red.shade700);
    canvas.drawCircle(turbine, 20, Paint()..color = Colors.amber.shade700);
    canvas.drawCircle(condenser, 20, Paint()..color = Colors.teal.shade700);

    _drawText(canvas, 'PUMP', Offset(pump.dx - 15, pump.dy - 4), Colors.white, 9);
    _drawText(canvas, 'BOILER', Offset(boiler.dx - 18, boiler.dy - 4), Colors.white, 9);
    _drawText(canvas, 'TURB', Offset(turbine.dx - 14, turbine.dy - 4), Colors.white, 9);
    _drawText(canvas, 'COND', Offset(condenser.dx - 15, condenser.dy - 4), Colors.white, 9);

    final flowPos = (progress * 4) % 4;
    Offset dot = pump;
    if (flowPos < 1) {
      dot = Offset.lerp(pump, boiler, flowPos)!;
    } else if (flowPos < 2) {
      dot = Offset.lerp(boiler, turbine, flowPos - 1)!;
    } else if (flowPos < 3) {
      dot = Offset.lerp(turbine, condenser, flowPos - 2)!;
    } else {
      dot = Offset.lerp(condenser, pump, flowPos - 3)!;
    }

    canvas.drawCircle(dot, 7, Paint()..color = Colors.cyanAccent);
  }

  void _paintRefrigerationSystem(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final comp = Offset(w * 0.25, h * 0.75);
    final cond = Offset(w * 0.75, h * 0.75);
    final exp = Offset(w * 0.75, h * 0.25);
    final evap = Offset(w * 0.25, h * 0.25);

    final linePaint = Paint()..color = Colors.white54..strokeWidth = 2;
    canvas.drawLine(comp, cond, linePaint);
    canvas.drawLine(cond, exp, linePaint);
    canvas.drawLine(exp, evap, linePaint);
    canvas.drawLine(evap, comp, linePaint);

    canvas.drawCircle(comp, 18, Paint()..color = Colors.redAccent);
    canvas.drawCircle(cond, 18, Paint()..color = Colors.orangeAccent);
    canvas.drawCircle(exp, 18, Paint()..color = Colors.cyanAccent);
    canvas.drawCircle(evap, 18, Paint()..color = Colors.blueAccent);

    _drawText(canvas, 'COMP', Offset(comp.dx - 14, comp.dy - 4), Colors.white, 9);
    _drawText(canvas, 'COND', Offset(cond.dx - 14, cond.dy - 4), Colors.white, 9);
    _drawText(canvas, 'EXP', Offset(exp.dx - 10, exp.dy - 4), Colors.black, 9);
    _drawText(canvas, 'EVAP', Offset(evap.dx - 14, evap.dy - 4), Colors.white, 9);
  }

  void _paintPumpSystem(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.45);
    final r = 55.0;

    canvas.drawCircle(center, r + 15, Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 3);

    final angle = progress * 2 * math.pi * 3;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      canvas.drawLine(Offset(math.cos(a) * 10, math.sin(a) * 10), Offset(math.cos(a + 0.3) * r, math.sin(a + 0.3) * r), Paint()..color = Colors.amberAccent..strokeWidth = 4);
    }
    canvas.restore();
    _drawText(canvas, 'Impeller Rotation & Centrifugal Head Generation', Offset(w * 0.18, h - 25), Colors.white, 12);
  }

  void _paintHydraulicTurbine(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.6, h * 0.5);

    // Nozzle Jet on left
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.45, 80, 20), Paint()..color = Colors.grey);
    canvas.drawLine(Offset(w * 0.1 + 80, h * 0.5), Offset(center.dx - 45, h * 0.5), Paint()..color = Colors.lightBlueAccent..strokeWidth = 8);

    // Runner
    canvas.drawCircle(center, 45, Paint()..color = Colors.amberAccent..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  void _paintVenturiBernoulli(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.1, h * 0.3);
    path.lineTo(w * 0.35, h * 0.3);
    path.lineTo(w * 0.45, h * 0.45);
    path.lineTo(w * 0.55, h * 0.45);
    path.lineTo(w * 0.65, h * 0.3);
    path.lineTo(w * 0.9, h * 0.3);

    path.moveTo(w * 0.1, h * 0.7);
    path.lineTo(w * 0.35, h * 0.7);
    path.lineTo(w * 0.45, h * 0.55);
    path.lineTo(w * 0.55, h * 0.55);
    path.lineTo(w * 0.65, h * 0.7);
    path.lineTo(w * 0.9, h * 0.7);

    canvas.drawPath(path, Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 2.5);
    _drawText(canvas, 'Venturi Throat Contraction: Velocity Rises, Pressure Drops', Offset(w * 0.12, h - 20), Colors.white, 12);
  }

  void _paintPipeViscosityFlow(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawLine(Offset(w * 0.1, h * 0.25), Offset(w * 0.9, h * 0.25), Paint()..color = Colors.white..strokeWidth = 3);
    canvas.drawLine(Offset(w * 0.1, h * 0.75), Offset(w * 0.9, h * 0.75), Paint()..color = Colors.white..strokeWidth = 3);

    // Parabolic velocity profile
    for (int i = 0; i < 7; i++) {
      final y = h * (0.3 + i * 0.065);
      final uFactor = math.sin((i / 6) * math.pi);
      canvas.drawLine(Offset(w * 0.3, y), Offset(w * (0.3 + 0.35 * uFactor), y), Paint()..color = Colors.amberAccent..strokeWidth = 2);
    }
  }

  void _paintMohrsCircleCanvas(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);
    final r = 60.0;

    canvas.drawLine(Offset(w * 0.1, h * 0.5), Offset(w * 0.9, h * 0.5), Paint()..color = Colors.white54); // sigma
    canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, h * 0.9), Paint()..color = Colors.white54); // tau

    canvas.drawCircle(center, r, Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 3);

    // Principal Stresses
    canvas.drawCircle(Offset(center.dx + r, center.dy), 5, Paint()..color = Colors.amberAccent);
    canvas.drawCircle(Offset(center.dx - r, center.dy), 5, Paint()..color = Colors.amberAccent);

    _drawText(canvas, 'σ1 (Max Principal)', Offset(center.dx + r - 20, center.dy + 12), Colors.amberAccent, 10);
    _drawText(canvas, 'σ2 (Min Principal)', Offset(center.dx - r - 30, center.dy + 12), Colors.amberAccent, 10);
    _drawText(canvas, 'τmax = R', Offset(center.dx - 15, center.dy - r - 15), Colors.cyanAccent, 11);
  }

  void _paintSfdBmdCanvas(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawLine(Offset(w * 0.1, h * 0.3), Offset(w * 0.9, h * 0.3), Paint()..color = Colors.white..strokeWidth = 3); // Beam

    // SFD
    final sfd = Path();
    sfd.moveTo(w * 0.1, h * 0.3);
    sfd.lineTo(w * 0.1, h * 0.15);
    sfd.lineTo(w * 0.5, h * 0.15);
    sfd.lineTo(w * 0.5, h * 0.45);
    sfd.lineTo(w * 0.9, h * 0.45);
    sfd.lineTo(w * 0.9, h * 0.3);
    canvas.drawPath(sfd, Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 2);

    // BMD
    final bmd = Path();
    bmd.moveTo(w * 0.1, h * 0.7);
    bmd.lineTo(w * 0.5, h * 0.9);
    bmd.lineTo(w * 0.9, h * 0.7);
    canvas.drawPath(bmd, Paint()..color = Colors.amberAccent..style = PaintingStyle.stroke..strokeWidth = 2);

    _drawText(canvas, 'Shear Force Diagram (SFD)', Offset(w * 0.15, h * 0.1), Colors.cyanAccent, 11);
    _drawText(canvas, 'Bending Moment Diagram (BMD)', Offset(w * 0.15, h * 0.65), Colors.amberAccent, 11);
  }

  void _paintStressStrainCanvas(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ox = 40.0;
    final oy = h - 30.0;

    canvas.drawLine(Offset(ox, oy), Offset(w - 30, oy), Paint()..color = Colors.white70);
    canvas.drawLine(Offset(ox, oy), Offset(ox, 20), Paint()..color = Colors.white70);

    final curve = Path();
    curve.moveTo(ox, oy);
    curve.lineTo(ox + 50, oy - 80); // Elastic
    curve.lineTo(ox + 70, oy - 85); // Yield
    curve.quadraticBezierTo(ox + 140, oy - 140, ox + 180, oy - 130); // UTS
    curve.lineTo(ox + 210, oy - 100); // Fracture

    canvas.drawPath(curve, Paint()..color = Colors.amberAccent..style = PaintingStyle.stroke..strokeWidth = 3);
    _drawText(canvas, 'Stress-Strain Curve (Mild Steel Tensile Test)', Offset(ox + 20, 20), Colors.amberAccent, 12);
  }

  void _paintGearsCanvas(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c1 = Offset(w * 0.35, h * 0.5);
    final c2 = Offset(w * 0.65, h * 0.5);
    final r = 50.0;

    final angle = progress * 2 * math.pi;
    canvas.drawCircle(c1, r, Paint()..color = Colors.blue.shade900..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(c2, r, Paint()..color = Colors.teal.shade900..style = PaintingStyle.stroke..strokeWidth = 3);

    for (int i = 0; i < 8; i++) {
      final a1 = angle + i * math.pi / 4;
      canvas.drawLine(c1, Offset(c1.dx + math.cos(a1) * (r + 8), c1.dy + math.sin(a1) * (r + 8)), Paint()..color = Colors.amberAccent..strokeWidth = 3);
      final a2 = -angle + i * math.pi / 4;
      canvas.drawLine(c2, Offset(c2.dx + math.cos(a2) * (r + 8), c2.dy + math.sin(a2) * (r + 8)), Paint()..color = Colors.amberAccent..strokeWidth = 3);
    }
  }

  void _paintCamFollowerCanvas(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.35, h * 0.6);

    // Eccentric Cam
    final camAngle = progress * 2 * math.pi;
    final camCenter = Offset(center.dx + 15 * math.cos(camAngle), center.dy + 15 * math.sin(camAngle));
    canvas.drawCircle(camCenter, 40, Paint()..color = Colors.amberAccent..style = PaintingStyle.stroke..strokeWidth = 3);

    // Follower
    final followerY = camCenter.dy - 40 - 15 * math.sin(camAngle);
    canvas.drawRect(Rect.fromLTWH(center.dx - 6, followerY - 60, 12, 60), Paint()..color = Colors.cyanAccent);
  }

  void _paintCastingCanvas(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Mold box
    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.7, h * 0.6), Paint()..color = Colors.brown.shade800);
    // Mold cavity
    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.45, w * 0.3, h * 0.25), Paint()..color = Colors.amberAccent);
    _drawText(canvas, 'Sand Casting Mold Cavity & Liquid Metal Flow', Offset(w * 0.2, h - 25), Colors.white, 12);
  }

  void _paintLatheCuttingCanvas(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.35, w * 0.7, h * 0.3), Paint()..color = Colors.grey.shade600);

    final toolX = w * (0.2 + (progress % 1.0) * 0.5);
    final toolPath = Path()..moveTo(toolX, h * 0.25)..lineTo(toolX + 25, h * 0.35)..lineTo(toolX + 10, h * 0.5)..close();
    canvas.drawPath(toolPath, Paint()..color = Colors.amberAccent);
    _drawText(canvas, 'Single Point Cutting Tool & Chip Curling', Offset(w * 0.15, h - 20), Colors.white, 12);
  }

  void _paintGeneralEngineeringCanvas(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final n1 = Offset(w * 0.2, h * 0.5);
    final n2 = Offset(w * 0.5, h * 0.5);
    final n3 = Offset(w * 0.8, h * 0.5);

    canvas.drawLine(n1, n2, Paint()..color = Colors.white54..strokeWidth = 3);
    canvas.drawLine(n2, n3, Paint()..color = Colors.white54..strokeWidth = 3);

    canvas.drawCircle(n1, 20, Paint()..color = Colors.blue.shade700);
    canvas.drawCircle(n2, 20, Paint()..color = Colors.amber.shade700);
    canvas.drawCircle(n3, 20, Paint()..color = Colors.teal.shade700);

    _drawText(canvas, 'INPUT', Offset(n1.dx - 15, n1.dy - 4), Colors.white, 9);
    _drawText(canvas, 'PROCESS', Offset(n2.dx - 20, n2.dy - 4), Colors.white, 9);
    _drawText(canvas, 'OUTPUT', Offset(n3.dx - 18, n3.dy - 4), Colors.white, 9);
  }

  void _drawPoint(Canvas canvas, Offset pos, String label, Color color) {
    canvas.drawCircle(pos, 5, Paint()..color = color);
    _drawText(canvas, label, Offset(pos.dx + 6, pos.dy - 12), color, 11);
  }

  void _drawArrow(Canvas canvas, Offset p1, Offset p2, Color color, String text) {
    canvas.drawLine(p1, p2, Paint()..color = color..strokeWidth = 2);
    _drawText(canvas, text, Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2 - 12), color, 10);
  }

  void _drawGeneralGraph(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final margin = 40.0;
    canvas.drawLine(Offset(margin, h - margin), Offset(w - margin, h - margin), Paint()..color = Colors.white70..strokeWidth = 2);
    canvas.drawLine(Offset(margin, h - margin), Offset(margin, margin), Paint()..color = Colors.white70..strokeWidth = 2);

    final path = Path()..moveTo(margin, h - margin);
    path.quadraticBezierTo(w * 0.5, margin + 20, w - margin, h - margin - 20);
    canvas.drawPath(path, Paint()..color = Colors.amberAccent..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _TechnicalConceptPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.stepIndex != stepIndex ||
        oldDelegate.viewMode != viewMode ||
        oldDelegate.animationKey != animationKey;
  }
}
