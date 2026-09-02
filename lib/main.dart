import 'package:flutter/material.dart';

import 'config/supabase_config.dart';
import 'screens/home_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const SppbApp());
}

class SppbApp extends StatelessWidget {
  const SppbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPPB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: SupabaseConfig.isConfigured
          ? const HomeScreen()
          : const _SupabaseNotConfiguredScreen(),
    );
  }
}

class _SupabaseNotConfiguredScreen extends StatelessWidget {
  const _SupabaseNotConfiguredScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 56, color: AppColors.accentOrange),
              const SizedBox(height: 16),
              Text(
                'Supabase is not configured',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Set SUPABASE_URL and SUPABASE_ANON_KEY in '
                'lib/config/supabase_config.dart, or pass them with '
                '--dart-define when running the app.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
