import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/balance_trial.dart';
import '../../state/assessment_session.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/circular_timer.dart';
import '../../widgets/sppb_scaffold.dart';
import 'balance_intro_screen.dart';

/// Runs the 10-second timed hold for one balance stance. It Automatically stops at 10 sec
class BalanceTestScreen extends StatefulWidget {
  const BalanceTestScreen({super.key, required this.stance});

  final BalanceStance stance;

  @override
  State<BalanceTestScreen> createState() => _BalanceTestScreenState();
}

class _BalanceTestScreenState extends State<BalanceTestScreen> {
  late SppbTimerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SppbTimerController(autoStopAt: const Duration(seconds: 10));
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    // The dial repaints itself; this rebuild is only needed for the surrounding instruction text and the Save/Redo bar
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
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
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    setState(() {
      _controller = SppbTimerController(autoStopAt: const Duration(seconds: 10))
        ..addListener(_onControllerChanged);
    });
  }

  Future<void> _save(AssessmentSession session) async {
    final seconds = _controller.displayElapsed.inMilliseconds / 1000.0;
    session.recordBalanceTrial(
      BalanceTrial(
        stance: widget.stance,
        attempted: true,
        heldSeconds: seconds,
      ),
    );
    await session.saveBalanceTrials();
    if (!mounted) return;
    goToScreenAfterBalance(context, widget.stance, session);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();

    return SppbScaffold(
      title: 'Balance Tests',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.stance.label,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            _controller.isFinished
                ? 'Hold complete.'
                : _controller.isRunning
                    ? 'Timing… tap the dial if the participant loses '
                        'balance or the position breaks down.'
                    : 'After getting the participant into the correct '
                        'position say: Are you ready?\n\n'
                        'Gently let go of the participant and '
                        'simultaneously say Ready, begin and press Start '
                        'to start the timer.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: CircularTimer(controller: _controller, onTap: _onDialTap),
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
