import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/gait_trial.dart';
import '../../state/assessment_session.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/not_performed_dialog.dart';
import '../../widgets/sppb_scaffold.dart';
import '../chair_stand/chair_stand_intro_screen.dart';
import 'gait_test_screen.dart';

/// Instructions for the 4-meter usual-pace walk, read once before the
/// first of the two timed trials.
class GaitIntroScreen extends StatelessWidget {
  const GaitIntroScreen({super.key});

  Future<void> _handleNotPerformed(
    BuildContext context,
    AssessmentSession session,
  ) async {
    final reason = await showNotPerformedDialog(context);
    if (reason == null) return;
    session.recordGaitTrial(
      GaitTrial(trialNumber: 1, attempted: false, notPerformedReason: reason),
    );
    session.recordGaitTrial(
      GaitTrial(trialNumber: 2, attempted: false, notPerformedReason: reason),
    );
    await session.saveGaitTrials();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: session,
          child: const ChairStandIntroScreen(),
        ),
      ),
    );
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
          ],
        ),
      ),
      bottomBar: NotPerformedOrGoButtons(
        onNotPerformed: () => _handleNotPerformed(context, session),
        onGoToTest: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: session,
                child: const GaitTestScreen(trialNumber: 1),
              ),
            ),
          );
        },
      ),
    );
  }
}
