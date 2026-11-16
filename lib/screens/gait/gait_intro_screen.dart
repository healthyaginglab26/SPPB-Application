import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/gait_trial.dart';
import '../../state/assessment_session.dart';
import '../../theme/app_theme.dart';
import '../../widgets/not_performed_dialog.dart';
import '../../widgets/sppb_scaffold.dart';
import 'gait_flow.dart';
import 'gait_test_screen.dart';

// Instructions for the usual-pace walk, followed by a choice of course
// length / start type (4m Standing / 4m Moving / 3m), or Not performed.
class GaitIntroScreen extends StatefulWidget {
  const GaitIntroScreen({super.key});

  @override
  State<GaitIntroScreen> createState() => _GaitIntroScreenState();
}

class _GaitIntroScreenState extends State<GaitIntroScreen> {
  bool _busy = false;

  Future<void> _handleNotPerformed(AssessmentSession session) async {
    if (_busy) return;
    final reason = await showNotPerformedDialog(context);
    if (reason == null) return;
    setState(() => _busy = true);

    session.recordGaitTrial(
      GaitTrial(trialNumber: 1, attempted: false, notPerformedReason: reason),
    );
    session.recordGaitTrial(
      GaitTrial(trialNumber: 2, attempted: false, notPerformedReason: reason),
    );
    await session.saveGaitTrials();
    if (!mounted) return;
    try {
      await goToScreenAfterGait(context, session);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _chooseCourse(
    AssessmentSession session,
    double meters,
    GaitStartType startType,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);

    session.setGaitDistance(meters);
    session.setGaitStartType(startType);
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: session,
            child: GaitTestScreen(
              trialNumber: 1,
              distanceMeters: meters,
              startType: startType,
            ),
          ),
        ),
      );
    } finally {
      // Re-enable the course buttons if the administrator came back here
      // (e.g. pressed Back) instead of completing the trial.
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();

    return SppbScaffold(
      title: 'Gait Speed Test',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gait Speed', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            Text(
              'This is our walking course. I want you to walk to the '
              'other end of the course at your usual walking pace, as if '
              'you were walking down the street to go to the store, just '
              'like you would in everyday life. Walk all the way past the '
              'other end of the tape before you stop. I will walk with '
              'you.\n\n'
              'Do you feel this would be unsafe?\n\n'
              'You will do this walk twice; we will use the faster of the '
              'two times to score this test.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Select the course length and start type being used for '
              'this walk.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy
                  ? null
                  : () => _chooseCourse(session, 4.0, GaitStartType.standing),
              child: const Text('4m Standing Start (Standard SPPB)'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy
                  ? null
                  : () => _chooseCourse(session, 4.0, GaitStartType.moving),
              child: const Text('4m Moving Start'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy
                  ? null
                  : () => _chooseCourse(session, 3.0, GaitStartType.standing),
              child: const Text('3 meter course'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
              ),
              onPressed: _busy ? null : () => _handleNotPerformed(session),
              child: const Text('Not performed'),
            ),
          ),
        ],
      ),
    );
  }
}
