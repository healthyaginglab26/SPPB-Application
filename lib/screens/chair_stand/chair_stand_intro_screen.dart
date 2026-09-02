import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import '../../state/assessment_session.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/not_performed_dialog.dart';
import '../../widgets/sppb_scaffold.dart';
import '../summary_screen.dart';
import 'chair_stand_single_screen.dart';

class ChairStandIntroScreen extends StatelessWidget {
  const ChairStandIntroScreen({super.key});

  Future<void> _handleNotPerformed(
    BuildContext context,
    AssessmentSession session,
  ) async {
    final reason = await showNotPerformedDialog(context);
    if (reason == null) return;
    session.updateChairStand(
      (c) => c.copyWith(
        singleStandAttempted: false,
        singleStandNotPerformedReason: reason,
      ),
    );
    await session.saveChairStand();
    if (!context.mounted) return;
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

    return SppbScaffold(
      title: 'Chair Stand Test',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chair Stand', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            Text(
              'Do you think it would be safe for you to try to stand up '
              'from a chair without using your arms?\n\n'
              'First we will check whether you can stand up from the '
              'chair once without using your arms. If you can, I will '
              'then ask you to stand up and sit down five times as '
              'quickly as you can, without stopping in between.',
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
                child: const ChairStandSingleScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
