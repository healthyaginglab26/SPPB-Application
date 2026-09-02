/// Supabase project credentials.
///
/// Robert: fill these in once the Supabase project exists, or (recommended
/// for anything beyond local testing) pass them at build/run time instead
/// of hardcoding them, e.g.:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// The --dart-define values below take priority over the fallback
/// constants, so it's safe to leave the fallbacks blank in source control
/// and only ever supply real values via --dart-define / your CI secrets.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vhiplhqgsqmrucgbtrol.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZoaXBsaHFnc3FtcnVjZ2J0cm9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgzMDA5MTQsImV4cCI6MjEwMzg3NjkxNH0.mkFw_T3SYlm6ewJBtdYcOq7iMO3xrcsbpvoxx4zdzkE',
  );

  static bool get isConfigured =>
      url.startsWith('https://vhiplhqgsqmrucgbtrol.supabase.co') &&
      anonKey.isNotEmpty;
}
