import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/assessment_session.dart';
import '../widgets/sppb_scaffold.dart';
import 'balance/balance_intro_screen.dart';

class SppbIntroScreen extends StatelessWidget {
  const SppbIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SppbScaffold(
      title: 'SPPB',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Short Physical Performance Battery',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 24),
            Text(
              'There are three parts to this test. In this first part, '
              'you will try to maintain your balance in three different '
              'standing positions.\n\n'
              'I will first describe then show each position to you. '
              'Then, I\'d like you to do it. If you cannot do a particular '
              'movement, or if you feel it would be unsafe to try to do it, '
              'tell me and we\'ll move on to the next test.\n\n'
              'Please remember, I do not want you to try to do anything '
              'that you feel might be unsafe.\n\n'
              'Do you have any questions before we begin?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      bottomBar: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final session = context.read<AssessmentSession>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: session,
                  child: const BalanceIntroScreen(),
                ),
              ),
            );
          },
          child: const Text('Next'),
        ),
      ),
    );
  }
}
