import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/assessment_session.dart';
import '../theme/app_theme.dart';
import '../widgets/sppb_scaffold.dart';

// Final scores screen
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _saving = false;
  bool _saved = false;
  String? _error;

  Future<void> _finish(AssessmentSession session) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await session.finalizeAssessment();
      if (!mounted) return;
      setState(() => _saved = true);
    } catch (e) {
      setState(() => _error = 'Could not save final scores: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();

    return SppbScaffold(
      title: 'SPPB Summary',
      showBackButton: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Results', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              '${session.assessment.patientFirstName} '
              '${session.assessment.patientLastName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 24),
            _ScoreRow(label: 'Balance', score: session.balanceScore),
            _ScoreRow(label: 'Gait Speed', score: session.gaitScore),
            _ScoreRow(label: 'Chair Stand', score: session.chairStandScore),
            const Divider(height: 32),
            _ScoreRow(
              label: 'Total SPPB Score',
              score: session.totalScore,
              maxScore: 12,
              emphasize: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              Text(_error!, style: const TextStyle(color: AppColors.accentRed)),
            ],
            if (_saved) ...[
              const SizedBox(height: 24),
              const Text(
                'Assessment saved to Supabase.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomBar: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saving
              ? null
              : _saved
                  ? () => Navigator.of(context)
                      .popUntil((route) => route.isFirst)
                  : () => _finish(session),
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(_saved ? 'Done — return to Home' : 'Save Assessment'),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.score,
    this.maxScore = 4,
    this.emphasize = false,
  });

  final String label;
  final int score;
  final int maxScore;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(color: AppColors.primaryBlue)
        : Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('$score / $maxScore', style: style),
        ],
      ),
    );
  }
}
