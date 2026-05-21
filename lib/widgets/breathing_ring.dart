import 'dart:math' as math;
import 'package:flutter/material.dart';

class BreathingRing extends StatefulWidget {
  final String phaseName;
  final int secondsRemaining;
  final String phaseType; // 'inhale', 'hold', 'exhale', 'holdOut', 'idle'
  final int phaseDuration;

  const BreathingRing({
    super.key,
    required this.phaseName,
    required this.secondsRemaining,
    required this.phaseType,
    required this.phaseDuration,
  });

  @override
  State<BreathingRing> createState() => _BreathingRingState();
}

class _BreathingRingState extends State<BreathingRing> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController; // For hold phase subtle vibration
  
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleController.addListener(() {
      setState(() {
        _currentScale = _scaleController.value;
      });
    });
    _triggerAnimation();
  }

  @override
  void didUpdateWidget(covariant BreathingRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phaseType != widget.phaseType || oldWidget.phaseDuration != widget.phaseDuration) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    _pulseController.stop();
    
    double targetScale = 1.0;
    Duration duration = Duration(seconds: widget.phaseDuration > 0 ? widget.phaseDuration : 1);

    switch (widget.phaseType) {
      case 'inhale':
        targetScale = 1.35;
        _scaleController.duration = duration;
        _scaleController.animateTo(targetScale, curve: Curves.linear);
        break;
      case 'hold':
        targetScale = 1.35;
        _scaleController.duration = const Duration(milliseconds: 300);
        _scaleController.animateTo(targetScale, curve: Curves.easeOut).then((_) {
          if (widget.phaseType == 'hold') {
            _pulseController.repeat(reverse: true);
          }
        });
        break;
      case 'exhale':
        targetScale = 0.9;
        _scaleController.duration = duration;
        _scaleController.animateTo(targetScale, curve: Curves.linear);
        break;
      case 'holdOut':
        targetScale = 0.9;
        _scaleController.duration = const Duration(milliseconds: 300);
        _scaleController.animateTo(targetScale, curve: Curves.easeOut);
        break;
      case 'idle':
      default:
        targetScale = 1.0;
        _scaleController.duration = const Duration(milliseconds: 1000);
        _scaleController.animateTo(targetScale, curve: Curves.easeInOut);
        break;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getPhaseColor() {
    switch (widget.phaseType) {
      case 'inhale':
        return const Color(0xFF06B6D4); // Cyan
      case 'hold':
        return const Color(0xFF8B5CF6); // Purple
      case 'exhale':
        return const Color(0xFFF43F5E); // Rose
      case 'holdOut':
        return const Color(0xFFF59E0B); // Amber
      case 'idle':
      default:
        return const Color(0xFF9CA3AF); // Muted grey
    }
  }

  Color _getGlowColor() {
    switch (widget.phaseType) {
      case 'inhale':
        return const Color(0x4006B6D4);
      case 'hold':
        return const Color(0x408B5CF6);
      case 'exhale':
        return const Color(0x40F43F5E);
      case 'holdOut':
        return const Color(0x40F59E0B);
      case 'idle':
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _getPhaseColor();
    final Color glowColor = _getGlowColor();

    return Center(
      child: Container(
        width: 320,
        height: 320,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer dashed ring (always visible, representing bounds)
            CustomPaint(
              size: const Size(280, 280),
              painter: DashedRingPainter(color: Colors.white.withOpacity(0.08)),
            ),
            
            // Pulsing ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                // When hold is active, apply a small oscillation to the scale
                double scaleMultiplier = 1.0;
                if (widget.phaseType == 'hold') {
                  scaleMultiplier = 1.0 + (_pulseController.value * 0.03);
                }
                
                return Transform.scale(
                  scale: _currentScale * scaleMultiplier,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor,
                          blurRadius: 35,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Inner text display
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: color,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Text(widget.phaseName.toUpperCase()),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.secondsRemaining > 0 ? '${widget.secondsRemaining}' : '--',
                  style: const TextStyle(
                    fontFamily: 'Share Tech Mono',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashedRingPainter extends CustomPainter {
  final Color color;

  DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    const int dashCount = 80;
    const double dashAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final double startAngle = i * dashAngle;
        final double endAngle = startAngle + dashAngle;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          endAngle - startAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
