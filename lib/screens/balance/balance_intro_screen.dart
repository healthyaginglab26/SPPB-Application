import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/balance_trial.dart';
import '../../state/assessment_session.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/not_performed_dialog.dart';
import '../../widgets/sppb_scaffold.dart';
import '../gait/gait_intro_screen.dart';
import 'balance_test_screen.dart';

const _instructions = {
  BalanceStance.sideBySide:
      'Now, I will show you the first position.\n\n'
      'Demonstrate while saying:\n'
      'I want you to try to stand with your feet together, side-by-side, '
      'for 10 seconds. You may use your arms, bend your knees, or move '
      'your body to maintain your balance, but try not to move your feet '
      'or hold on to anything. Try to hold this position for 10 seconds '
      'until I say "Stop".',
  BalanceStance.semiTandem:
      'Now I will show you the second position.\n\n'
      'Demonstrate while saying:\n'
      'Now I want you to try to place the heel of one foot along the side '
      'of the big toe of the other foot. You may use your arms, bend your '
      'knees, or move your body to maintain your balance, but try not to '
      'move your feet or hold on to anything. Try to hold this position '
      'for 10 seconds until I say "Stop".',
  BalanceStance.tandem:
      'Now I will show you the third position.\n\n'
      'Demonstrate while saying:\n'
      'Now I want you to try to place the heel of one foot in front of, '
      'and touching the toes of, the other foot. You may use your arms, '
      'bend your knees, or move your body to maintain your balance, but '
      'try not to move your feet or hold on to anything. Try to hold this '
      'position for 10 seconds until I say "Stop".',
};
 
// Instructions for one balance stance, followed by either the "Not performed" or "Go to test"
class BalanceIntroScreen extends StatelessWidget {
  const BalanceIntroScreen({super.key, this.stance = BalanceStance.sideBySide});

  final BalanceStance stance;

  Future<void> _handleNotPerformed(
    BuildContext context,
    AssessmentSession session,
  ) async {
    final reason = await showNotPerformedDialog(context);
    if (reason == null) return;
    session.recordBalanceTrial(
      BalanceTrial(stance: stance, attempted: false, notPerformedReason: reason),
    );
    await session.saveBalanceTrials();
    if (!context.mounted) return;
    goToScreenAfterBalance(context, stance, session);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();

    return SppbScaffold(
      title: 'Balance Tests',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stance.label, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            Text(
              'Now, I will show you the position.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Text(_instructions[stance]!, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
      bottomBar: NotPerformedOrGoButtons(
        onNotPerformed: () => _handleNotPerformed(context, session),
        onGoToTest: () {
          final route = MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: session,
              child: BalanceTestScreen(stance: stance),
            ),
          );
          Navigator.of(context).push(route);
        },
      ),
    );
  }
}

/// Decides which screen comes after a balance stance has been scored
void goToScreenAfterBalance(
  BuildContext context,
  BalanceStance justScored,
  AssessmentSession session,
) {
  Widget next;
  switch (justScored) {
    case BalanceStance.sideBySide:
      next = session.shouldAttemptSemiTandem
          ? const BalanceIntroScreen(stance: BalanceStance.semiTandem)
          : const GaitIntroScreen();
      break;
    case BalanceStance.semiTandem:
      next = session.shouldAttemptTandem
          ? const BalanceIntroScreen(stance: BalanceStance.tandem)
          : const GaitIntroScreen();
      break;
    case BalanceStance.tandem:
      next = const GaitIntroScreen();
      break;
  }
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(value: session, child: next),
    ),
  );
}
