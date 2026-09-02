import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Drives a stopwatch-style timer. Kept separate from the widget so a
/// screen can start/stop it programmatically (e.g. auto-stopping a
/// balance hold at exactly 10.00s) and read [elapsed] for scoring.
class SppbTimerController extends ChangeNotifier {
  SppbTimerController({this.autoStopAt});

  /// If set, the timer stops itself the instant it reaches this
  /// duration (used for the balance holds, which are capped at 10s).
  final Duration? autoStopAt;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  Duration get elapsed => _stopwatch.elapsed;
  bool get isRunning => _stopwatch.isRunning;
  bool _finished = false;
  bool get isFinished => _finished;

  void start() {
    if (_stopwatch.isRunning) return;
    _finished = false;
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
      final cap = autoStopAt;
      if (cap != null && _stopwatch.elapsed >= cap) {
        // Snap exactly to the cap so scoring sees e.g. 10.00, not 10.03.
        stop(overrideElapsed: cap);
        return;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void stop({Duration? overrideElapsed}) {
    if (!_stopwatch.isRunning && _finished) return;
    _stopwatch.stop();
    _ticker?.cancel();
    _finished = true;
    if (overrideElapsed != null) {
      _elapsedOverride = overrideElapsed;
    }
    notifyListeners();
  }

  Duration? _elapsedOverride;

  Duration get displayElapsed => _elapsedOverride ?? elapsed;

  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    _ticker?.cancel();
    _finished = false;
    _elapsedOverride = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

/// A round dial styled after the NIA reference app: tick marks at
/// 0/15/30/45 (one 60-second lap), a red arc sweeping clockwise to show
/// elapsed time, and either a "Start" label (idle) or the running/final
/// digital readout in the center. Tapping the dial toggles start/stop.
class CircularTimer extends StatelessWidget {
  const CircularTimer({
    super.key,
    required this.controller,
    this.size = 260,
    this.onTap,
  });

  final SppbTimerController controller;
  final double size;
  final VoidCallback? onTap;

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centis = (d.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$centis';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final elapsed = controller.displayElapsed;
        final idle = !controller.isRunning && !controller.isFinished;
        return GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _DialPainter(elapsed: elapsed),
              child: Center(
                child: idle
                    ? Container(
                        width: size * 0.6,
                        height: size * 0.6,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Start',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Text(
                        _format(elapsed),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.elapsed});

  final Duration elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final trackPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius - 8, trackPaint);

    // Tick marks every 5 seconds (12 ticks around the 60s dial).
    final tickPaint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 2;
    for (var i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180 - math.pi / 2;
      final outer = Offset(
        center.dx + (radius - 4) * math.cos(angle),
        center.dy + (radius - 4) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - 14) * math.cos(angle),
        center.dy + (radius - 14) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Elapsed arc, one full lap == 60 seconds; keeps sweeping around for
    // times beyond 60s (chair stand / gait can run longer than a
    // balance hold).
    final totalSeconds = elapsed.inMilliseconds / 1000.0;
    final fraction = (totalSeconds % 60) / 60.0;
    final sweep = 2 * math.pi * (fraction == 0 && totalSeconds > 0 ? 1 : fraction);
    final arcPaint = Paint()
      ..color = AppColors.accentRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -math.pi / 2,
      sweep,
      false,
      arcPaint,
    );

    // Labels at 0 / 15 / 30 / 45.
    const labels = {0: '0', 15: '15', 30: '30', 45: '45'};
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    labels.forEach((seconds, label) {
      final angle = (seconds / 60) * 2 * math.pi - math.pi / 2;
      final pos = Offset(
        center.dx + (radius - 28) * math.cos(angle),
        center.dy + (radius - 28) * math.sin(angle),
      );
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    });
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.elapsed != elapsed;
}
