import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // CONFIGURATION: These placeholders must be replaced with the user's specific project keys
  // to enable REAL-WORLD automated emails and database persistence.
  static const String supabaseUrl = 'https://tqlnlcgirhzcmtkpjktt.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRxbG5sY2dpcmh6Y210a3Bqa3R0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxOTI2NTcsImV4cCI6MjA4OTc2ODY1N30.0DDt_XZZJu9Ci1saZ6HbWaAREM7FOmF9VyDnQcuM4s8';
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _isInitialized = true;
  }

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
          'Supabase is not initialized. Call SupabaseService.initialize() first.');
    }
    return Supabase.instance.client;
  }

  // Real Automated Email Trigger (via Supabase Auth)
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
      emailRedirectTo: 'vinta://welcome', // Directing users back after verified
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
