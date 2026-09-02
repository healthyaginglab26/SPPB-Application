import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/gait_trial.dart';
import '../../state/assessment_session.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/circular_timer.dart';
import '../../widgets/not_performed_dialog.dart';
import '../../widgets/sppb_scaffold.dart';
import '../chair_stand/chair_stand_intro_screen.dart';

/// Times a single 4-meter walk trial: tap Start as the participant
/// begins walking, tap again the instant they cross the finish line.
/// Unlike the balance holds, this timer has no auto-stop.
class GaitTestScreen extends StatefulWidget {
  const GaitTestScreen({super.key, required this.trialNumber});

  final int trialNumber;

  @override
  State<GaitTestScreen> createState() => _GaitTestScreenState();
}

class _GaitTestScreenState extends State<GaitTestScreen> {
  late SppbTimerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SppbTimerController()..addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onDialTap() {
    if (!_controller.isRunning && !_controller.isFinished) {
      _controller.start();
    } else if (_controller.isRunning) {
      _controller.stop();
    }
  }

  void _redo() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    setState(() {
      _controller = SppbTimerController()..addListener(_onChanged);
    });
  }

  void _goToNext(AssessmentSession session) {
    if (widget.trialNumber == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: session,
            child: const GaitTestScreen(trialNumber: 2),
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: session,
            child: const ChairStandIntroScreen(),
          ),
        ),
      );
    }
  }

  Future<void> _save(AssessmentSession session) async {
    final seconds = _controller.displayElapsed.inMilliseconds / 1000.0;
    session.recordGaitTrial(
      GaitTrial(
        trialNumber: widget.trialNumber,
        attempted: true,
        timeSeconds: seconds,
      ),
    );
    await session.saveGaitTrials();
    if (!mounted) return;
    _goToNext(session);
  }

  Future<void> _notPerformed(AssessmentSession session) async {
    final reason = await showNotPerformedDialog(context);
    if (reason == null) return;
    session.recordGaitTrial(
      GaitTrial(
        trialNumber: widget.trialNumber,
        attempted: false,
        notPerformedReason: reason,
      ),
    );
    await session.saveGaitTrials();
    if (!mounted) return;
    _goToNext(session);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();

    return SppbScaffold(
      title: 'Gait Speed Test',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trial ${widget.trialNumber} of 2',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            _controller.isFinished
                ? 'Walk complete.'
                : _controller.isRunning
                    ? 'Timing… tap the dial the instant the participant '
                        'crosses the finish line.'
                    : 'Position the participant at the start of the '
                        'course. Press Start as they begin walking.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: CircularTimer(controller: _controller, onTap: _onDialTap),
            ),
          ),
          if (!_controller.isRunning && !_controller.isFinished)
            Center(
              child: TextButton(
                onPressed: () => _notPerformed(session),
                child: const Text('Not performed'),
              ),
            ),
        ],
      ),
      bottomBar: _controller.isFinished
          ? SaveOrRedoButtons(onSave: () => _save(session), onRedo: _redo)
          : null,
    );
  }
}
