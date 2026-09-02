import 'package:flutter/material.dart';

import '../models/not_performed_reason.dart';

/// "Please select a reason for not completing the test." picker, matching
/// the reference app's dialog. Returns the chosen reason, or null if the
/// administrator closed the dialog without choosing one.
Future<NotPerformedReason?> showNotPerformedDialog(BuildContext context) {
  return showModalBottomSheet<NotPerformedReason>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Please select a reason for not completing the test.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            ...NotPerformedReason.values.map(
              (reason) => ListTile(
                title: Text(reason.label),
                onTap: () => Navigator.of(context).pop(reason),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Close'),
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
