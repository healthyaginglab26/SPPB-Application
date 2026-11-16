import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/gait_trial.dart';
import '../../state/assessment_session.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/circular_timer.dart';
import '../../widgets/not_performed_dialog.dart';
import '../../widgets/sppb_scaffold.dart';
import 'gait_flow.dart';
import 'gait_trial_three_prompt_screen.dart';

/// Times a single walk trial (3m or 4m course, standing or moving start).
class GaitTestScreen extends StatefulWidget {
  const GaitTestScreen({
    super.key,
    required this.trialNumber,
    required this.distanceMeters,
    this.startType = GaitStartType.standing,
  });

  final int trialNumber;
  final double distanceMeters;
  final GaitStartType startType;

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

  Future<void> _goToNext(AssessmentSession session) async {
    if (widget.trialNumber < 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: session,
            child: GaitTestScreen(
              trialNumber: widget.trialNumber + 1,
              distanceMeters: widget.distanceMeters,
              startType: widget.startType,
            ),
          ),
        ),
      );
    } else if (widget.trialNumber == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: session,
            child: const GaitTrialThreePromptScreen(),
          ),
        ),
      );
    } else {
      await goToScreenAfterGait(context, session);
    }
  }

  Future<void> _save(AssessmentSession session) async {
    final seconds = _controller.displayElapsed.inMilliseconds / 1000.0;
    session.recordGaitTrial(
      GaitTrial(
        trialNumber: widget.trialNumber,
        distanceMeters: widget.distanceMeters,
        startType: widget.startType,
        attempted: true,
        timeSeconds: seconds,
      ),
    );
    await session.saveGaitTrials();
    if (!mounted) return;
    await _goToNext(session);
  }

  Future<void> _notPerformed(AssessmentSession session) async {
    final reason = await showNotPerformedDialog(context);
    if (reason == null) return;
    session.recordGaitTrial(
      GaitTrial(
        trialNumber: widget.trialNumber,
        distanceMeters: widget.distanceMeters,
        startType: widget.startType,
        attempted: false,
        notPerformedReason: reason,
      ),
    );
    await session.saveGaitTrials();
    if (!mounted) return;
    await _goToNext(session);
  }

  /// Lets the administrator abandon the walk partway through (participant
  /// stops, feels unsafe, etc.) and record why, instead of forcing a Save
  /// with a partial/meaningless time.
  Future<void> _stopNotPerformedMidWalk(AssessmentSession session) async {
    _controller.stop();
    final reason = await showNotPerformedDialog(context);
    if (reason == null) {
      // Administrator backed out of the dialog: resume the walk timer.
      _controller.start();
      return;
    }
    session.recordGaitTrial(
      GaitTrial(
        trialNumber: widget.trialNumber,
        distanceMeters: widget.distanceMeters,
        startType: widget.startType,
        attempted: false,
        notPerformedReason: reason,
      ),
    );
    await session.saveGaitTrials();
    if (!mounted) return;
    await _goToNext(session);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();
    final trialLabel = widget.trialNumber == 3
        ? 'Trial 3 (optional)'
        : 'Trial ${widget.trialNumber} of 2';

    return SppbScaffold(
      title: 'Gait Speed Test',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$trialLabel '
            '(${widget.distanceMeters.toStringAsFixed(0)}m course, '
            '${widget.startType.label})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            _controller.isFinished
                ? 'Walk complete.'
                : _controller.isRunning
                    ? 'Timing… tap the dial the instant the participant '
                        'crosses the finish line.'
                    : widget.startType == GaitStartType.moving
                        ? 'Position the participant before the start of '
                            'the course so they are already moving when '
                            'they cross the start line. Press Start as '
                            'they cross it.'
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
          if (_controller.isRunning)
            Center(
              child: TextButton(
                onPressed: () => _stopNotPerformedMidWalk(session),
                child: const Text('Stop — not completed'),
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
