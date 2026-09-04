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
