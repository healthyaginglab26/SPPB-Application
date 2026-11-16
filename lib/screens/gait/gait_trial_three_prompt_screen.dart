import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/assessment_session.dart';
import '../../widgets/sppb_scaffold.dart';
import 'gait_flow.dart';
import 'gait_test_screen.dart';

/// Shown after both required gait trials are done. A third trial is
/// optional under the SPPB protocol (e.g. if a trial was affected by an
/// interruption) and is purely administrator-initiated.
class GaitTrialThreePromptScreen extends StatelessWidget {
  const GaitTrialThreePromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();

    return SppbScaffold(
      title: 'Gait Speed Test',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trials 1 and 2 complete',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'If you need to re-time the walk for any reason (for '
              'example, an interruption during one of the trials), you '
              'may run an optional third trial. The fastest completed '
              'trial will be used for scoring.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: session,
                      child: GaitTestScreen(
                        trialNumber: 3,
                        distanceMeters: session.gaitDistanceMeters ?? 4.0,
                        startType: session.gaitStartType,
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Run Trial 3 (optional)'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => goToScreenAfterGait(context, session),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
