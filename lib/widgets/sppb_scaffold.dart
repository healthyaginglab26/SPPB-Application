import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Common page chrome used by every screen: a blue header bar with a
/// back chevron, a title/breadcrumb, and (on every screen except Home) a
/// home button that jumps straight back to the Home screen, abandoning
/// whatever assessment is in progress.
/// [bottomBar] holds the primary action button(s) pinned to the bottom
/// of the screen (e.g. "Next", "Go to test", "Save" / "Redo").
class SppbScaffold extends StatelessWidget {
  const SppbScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomBar,
    this.showBackButton = true,
  });

  final String title;
  final Widget body;
  final Widget? bottomBar;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: showBackButton,
        actions: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Back to Home',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: body,
              ),
            ),
            if (bottomBar != null)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                decoration: const BoxDecoration(color: AppColors.background),
                child: bottomBar,
              ),
          ],
        ),
      ),
    );
  }
}
