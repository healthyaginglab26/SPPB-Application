import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/assessment_session.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sppb_scaffold.dart';
import '../summary_screen.dart';
import 'chair_stand_timed_screen.dart';

class ChairStandSingleScreen extends StatefulWidget {
  const ChairStandSingleScreen({super.key});

  @override
  State<ChairStandSingleScreen> createState() =>
      _ChairStandSingleScreenState();
}

class _ChairStandSingleScreenState extends State<ChairStandSingleScreen> {
  bool _busy = false;

  Future<void> _recordAndAdvance(
    AssessmentSession session, {
    required bool successful,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);

    session.updateChairStand(
      (c) => c.copyWith(
        singleStandAttempted: true,
        singleStandSuccessful: successful,
      ),
    );
    await session.saveChairStand();
    if (!mounted) return;

    if (!successful) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: session,
            child: const SummaryScreen(),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: session,
          child: const ChairStandTimedScreen(),
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
            Text(
              'Single Stand Check',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            Text(
              'Please fold your arms across your chest and stand up once.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Was the participant able to stand up once without using '
              'their arms?',
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
                  : () => _recordAndAdvance(session, successful: true),
              child: const Text('Yes — proceed to timed test'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
              ),
              onPressed: _busy
                  ? null
                  : () => _recordAndAdvance(session, successful: false),
              child: const Text('No — unable'),
            ),
          ),
        ],
      ),
    );
  }
}
