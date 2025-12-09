import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Supabase URL dan Anon Key dengan Environment Variables
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yzlemkwmqzatcawvslyf.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl6bGVta3dtcXphdGNhd3ZzbHlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyNTI3MzUsImV4cCI6MjA4MDgyODczNX0.okB2G3Dw36SWWoXkD38cPEBoFQ-S-RO3TjpdgVUAyAo',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Helper untuk get current user
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  String? get currentUserEmail => currentUser?.email;
}
