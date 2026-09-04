import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/not_performed_reason.dart';
import '../../state/assessment_session.dart';
import '../../theme/app_theme.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/circular_timer.dart';
import '../../widgets/not_performed_dialog.dart';
import '../../widgets/sppb_scaffold.dart';
import '../summary_screen.dart';

const _maxSeconds = 60;
const _targetReps = 5;

/// Times 5 consecutive sit-to-stand repetitions. The administrator taps +1 stand button for each one completed.
class ChairStandTimedScreen extends StatefulWidget {
  const ChairStandTimedScreen({super.key});

  @override
  State<ChairStandTimedScreen> createState() => _ChairStandTimedScreenState();
}

class _ChairStandTimedScreenState extends State<ChairStandTimedScreen> {
  late SppbTimerController _controller;
  int _reps = 0;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _controller = SppbTimerController(
      autoStopAt: const Duration(seconds: _maxSeconds),
    )..addListener(_onChanged);
  }

  void _onChanged() {
    if (_controller.isFinished && _reps < _targetReps) {
      _timedOut = true;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _addRep() {
    if (!_controller.isRunning) {
      _controller.start();
    }
    setState(() => _reps++);
    if (_reps >= _targetReps) {
      _controller.stop();
    }
  }

  void _redo() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    setState(() {
      _reps = 0;
      _timedOut = false;
      _controller = SppbTimerController(
        autoStopAt: const Duration(seconds: _maxSeconds),
      )..addListener(_onChanged);
    });
  }

  Future<void> _stopEarly() async {
    final reason = await showNotPerformedDialog(context);
    if (reason == null) return;
    _controller.stop();
    setState(() => _timedOut = true);
    if (!mounted) return;
    await _save(context.read<AssessmentSession>(), reason: reason);
  }

  Future<void> _save(AssessmentSession session, {NotPerformedReason? reason}) async {
    final seconds = _controller.displayElapsed.inMilliseconds / 1000.0;
    final completed = _reps >= _targetReps && !_timedOut;
    session.updateChairStand(
      (c) => c.copyWith(
        fiveStandAttempted: true,
        fiveStandTimeSeconds: seconds,
        fiveStandCompleted: completed,
        fiveStandNotPerformedReason: reason,
      ),
    );
    await session.saveChairStand();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: session,
          child: const SummaryScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();
    final finished = _controller.isFinished;

    return SppbScaffold(
      title: 'Chair Stand Test',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timed 5x Sit-to-Stand',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            finished
                ? (_timedOut
                    ? 'Stopped before 5 repetitions were completed.'
                    : 'All 5 repetitions complete.')
                : 'With arms folded across the chest, stand up and sit '
                    'down 5 times as quickly as possible. Tap "+1 Stand" '
                    'each time the participant reaches a full standing '
                    'position.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularTimer(controller: _controller),
                  const SizedBox(height: 24),
                  Text(
                    '$_reps / $_targetReps stands',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (!finished)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 56),
                      ),
                      onPressed: _addRep,
                      child: const Text('+1 Stand'),
                    ),
                  if (!finished) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accentRed,
                      ),
                      onPressed: _stopEarly,
                      child: const Text('Stop — not performed'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomBar: finished
          ? SaveOrRedoButtons(onSave: () => _save(session), onRedo: _redo)
          : null,
    );
  }
}
