import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/assessment_session.dart';
import '../chair_stand/chair_stand_intro_screen.dart';
import '../summary_screen.dart';

/// Decides what comes after the gait speed component is done (including
/// "not performed"): the Chair Stand test normally, or straight to the
/// Summary when this session was started as gait-speed-only.
Future<void> goToScreenAfterGait(
  BuildContext context,
  AssessmentSession session,
) async {
  Widget next;
  if (session.gaitOnly) {
    await session.skipNonGaitComponents();
    next = const SummaryScreen();
  } else {
    next = const ChairStandIntroScreen();
  }
  if (!context.mounted) return;
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(value: session, child: next),
    ),
  );
}
