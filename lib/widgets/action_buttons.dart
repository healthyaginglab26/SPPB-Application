import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The orange "Not performed" / blue "Go to test" pair shown on every
/// component's instruction screen.
///
/// Disables both buttons the instant either is tapped, so a fast
/// double-tap can't fire a handler twice (both handlers are async and
/// typically navigate to a new screen once they finish, which is too
/// slow to rely on for debouncing).
class NotPerformedOrGoButtons extends StatefulWidget {
  const NotPerformedOrGoButtons({
    super.key,
    required this.onNotPerformed,
    required this.onGoToTest,
    this.goToTestLabel = 'Go to test',
  });

  final VoidCallback onNotPerformed;
  final VoidCallback onGoToTest;
  final String goToTestLabel;

  @override
  State<NotPerformedOrGoButtons> createState() =>
      _NotPerformedOrGoButtonsState();
}

class _NotPerformedOrGoButtonsState extends State<NotPerformedOrGoButtons> {
  bool _busy = false;

  void _fire(VoidCallback callback) {
    if (_busy) return;
    setState(() => _busy = true);
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
            ),
            onPressed: _busy ? null : () => _fire(widget.onNotPerformed),
            child: const Text('Not performed'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _busy ? null : () => _fire(widget.onGoToTest),
            child: Text(widget.goToTestLabel),
          ),
        ),
      ],
    );
  }
}

/// The blue "Save" / outlined red "Redo" pair shown once a timed trial
/// has finished. Save is disabled after the first tap (it's an async
/// write that usually navigates away); Redo re-arms it, since Redo
/// starts a fresh attempt on the same screen.
class SaveOrRedoButtons extends StatefulWidget {
  const SaveOrRedoButtons({
    super.key,
    required this.onSave,
    required this.onRedo,
  });

  final VoidCallback onSave;
  final VoidCallback onRedo;

  @override
  State<SaveOrRedoButtons> createState() => _SaveOrRedoButtonsState();
}

class _SaveOrRedoButtonsState extends State<SaveOrRedoButtons> {
  bool _saving = false;

  void _handleSave() {
    if (_saving) return;
    setState(() => _saving = true);
    widget.onSave();
  }

  void _handleRedo() {
    setState(() => _saving = false);
    widget.onRedo();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _handleSave,
            child: const Text('Save'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(onPressed: _handleRedo, child: const Text('Redo')),
        ),
      ],
    );
  }
}
