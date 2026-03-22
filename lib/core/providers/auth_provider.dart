import 'package:flutter/material.dart';
import 'package:vinta/core/models/user_model.dart';
import 'package:vinta/core/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Real Automated Signup with Email Automation
  Future<void> signup(String username, String email, String password, String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Supabase Signup (Automated Welcome Email is triggered by Supabase Auth Service)
      final authResponse = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'phone': phone,
          'display_name': username,
        },
      );

      // 2. Sync local user state (Database Trigger handles the profiles table insert)
      _user = UserModel(
        id: authResponse.user?.id ?? 'u1', 
        username: username,
        email: email,
        phoneNumber: phone,
      );
    } catch (e) {
      debugPrint('Signup error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Real-World Login Bridge
      final response = await SupabaseService.signIn(email: identifier, password: password);
      final user = response.user;

      if (user != null) {
        // Fetch real production profile metadata
        final profile = await SupabaseService.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        _user = UserModel(
          id: user.id,
          username: profile?['username'] ?? 'User',
          email: user.email ?? identifier,
          phoneNumber: profile?['phone_number'] ?? '',
          isVerified: profile?['is_verified'] ?? false,
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String identifier) async {
    _isLoading = true;
    notifyListeners();

    try {
      // REAL-WORLD Automated Password Reset Email
      await SupabaseService.client.auth.resetPasswordForEmail(identifier);
    } catch (e) {
      debugPrint('Reset Password error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    _user = null;
    notifyListeners();
  }
}
