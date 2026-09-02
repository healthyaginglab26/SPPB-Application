import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/assessment_session.dart';
import '../theme/app_theme.dart';
import '../widgets/sppb_scaffold.dart';
import 'new_assessment_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SppbScaffold(
      title: 'SPPB Home',
      showBackButton: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 160,
                width: double.infinity,
                color: AppColors.railBlue.withOpacity(0.08),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.accessibility_new,
                  size: 72,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('SPPB', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Test Guide and Administration Tool',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 24, color: AppColors.accentOrange),
            Text(
              'The Short Physical Performance Battery (SPPB) is made up of '
              'three groups of tests to assess a person\'s balance, usual '
              'walking speed, and ability to rise from a chair. This app '
              'guides you through administering the full battery, times '
              'each component, and stores every raw reading alongside the '
              'calculated sub-scores and total score.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      bottomBar: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => AssessmentSession(),
                  child: const NewAssessmentScreen(),
                ),
              ),
            );
          },
          child: const Text('New Assessment'),
        ),
      ),
    );
  }
}
