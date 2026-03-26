import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vinta/core/models/user_model.dart';
import 'package:vinta/core/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  DateTime? _signupCooldownUntil;
  Timer? _cooldownTimer;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider() {
    _bootstrapAuthState();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;
  bool get isSignupRateLimited =>
      _signupCooldownUntil != null &&
      DateTime.now().isBefore(_signupCooldownUntil!);
  int get signupCooldownSecondsRemaining {
    if (!isSignupRateLimited) {
      return 0;
    }

    final remaining =
        _signupCooldownUntil!.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> _bootstrapAuthState() async {
    if (!SupabaseService.isInitialized) {
      _isInitialized = true;
      notifyListeners();
      return;
    }

    final currentUser = SupabaseService.client.auth.currentUser;
    if (currentUser != null) {
      await _hydrateUser(currentUser, fallbackEmail: currentUser.email ?? '');
    }

    _authSubscription =
        SupabaseService.client.auth.onAuthStateChange.listen((event) {
      final sessionUser = event.session?.user;
      if (sessionUser == null) {
        _user = null;
        notifyListeners();
        return;
      }

      _hydrateUser(sessionUser, fallbackEmail: sessionUser.email ?? '');
    });

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _hydrateUser(User authUser,
      {required String fallbackEmail}) async {
    try {
      final profile = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      _user = UserModel(
        id: authUser.id,
        username: profile?['username'] ??
            authUser.userMetadata?['username'] ??
            'User',
        email: authUser.email ?? profile?['email'] ?? fallbackEmail,
        phoneNumber: profile?['phone_number'] ??
            authUser.userMetadata?['phone_number'] ??
            authUser.userMetadata?['phone'],
        profileImageUrl: profile?['avatar_url'],
        bio: profile?['bio'],
        isVerified: profile?['is_verified'] ?? false,
      );
      _errorMessage = null;
    } catch (_) {
      _user = UserModel(
        id: authUser.id,
        username: authUser.userMetadata?['username'] ?? 'User',
        email: authUser.email ?? fallbackEmail,
        phoneNumber: authUser.userMetadata?['phone_number'] ??
            authUser.userMetadata?['phone'],
      );
    } finally {
      notifyListeners();
    }
  }

  /// Developer-only: skip Supabase auth and use a local test session
  void loginAsDevUser() {
    _user = UserModel(
      id: 'dev-admin-001',
      email: 'dev@vinta.al',
      username: 'VintaDev',
      bio: '🛠️ Developer Testing Account',
      isVerified: true,
    );
    _errorMessage = null;
    _isInitialized = true;
    notifyListeners();
  }

  Future<String> _resolveIdentifierToEmail(String identifier) async {
    final normalized = identifier.trim();
    if (normalized.contains('@') || !SupabaseService.isInitialized) {
      return normalized;
    }

    try {
      final profile = await SupabaseService.client
          .from('profiles')
          .select('email')
          .or('username.eq.$normalized,phone_number.eq.$normalized')
          .maybeSingle();

      final resolvedEmail = profile?['email'];
      if (resolvedEmail is String && resolvedEmail.isNotEmpty) {
        return resolvedEmail;
      }
    } catch (_) {
      // Fall back to the provided value to keep login UX responsive.
    }

    return normalized;
  }

  // Real Automated Signup with Email Automation
  Future<void> signup(
      String username, String email, String password, String phone) async {
    if (isSignupRateLimited) {
      final seconds = signupCooldownSecondsRemaining;
      final message =
          'Please wait $seconds second${seconds == 1 ? '' : 's'} before trying again.';
      _errorMessage = message;
      notifyListeners();
      throw StateError(message);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await SupabaseService.signUp(
        email: email,
        password: password,
        metadata: {
          'username': username,
          'phone_number': phone,
          'phone': phone,
          'display_name': username,
        },
      );

      final createdUser = authResponse.user;
      if (createdUser != null) {
        // Try to create profile row — may fail if RLS blocks it, that's OK
        try {
          await SupabaseService.client.from('profiles').upsert({
            'id': createdUser.id,
            'username': username,
            'phone_number': phone,
            'email': email,
          });
        } catch (profileError) {
          debugPrint('Profile upsert skipped (may be handled by trigger): $profileError');
        }

        await _hydrateUser(createdUser, fallbackEmail: email);
      }
    } catch (e) {
      if (e is AuthException &&
          (e.statusCode == '429' ||
              e.message.contains('over_email_send_rate_limit'))) {
        _startCooldown(65);
        _errorMessage =
            'Too many signup attempts. Please wait about 1 minute before trying again.';
      } else if (e is AuthException) {
        // Show the REAL Supabase error to the user
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resolvedEmail = await _resolveIdentifierToEmail(identifier);
      final response = await SupabaseService.signIn(
          email: resolvedEmail, password: password);
      final user = response.user;

      if (user != null) {
        await _hydrateUser(user, fallbackEmail: resolvedEmail);
      }
    } catch (e) {
      _errorMessage = 'Login failed. Check your credentials and try again.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String identifier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resolvedEmail = await _resolveIdentifierToEmail(identifier);
      await SupabaseService.client.auth.resetPasswordForEmail(resolvedEmail);
    } catch (e) {
      _errorMessage = 'Unable to send reset link for this account.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (SupabaseService.isInitialized) {
      await SupabaseService.signOut();
    }
    _user = null;
    _errorMessage = null;
    _signupCooldownUntil = null;
    notifyListeners();
  }

  // --- Profile & Social Updates (Phase 10) ---
  
  Future<void> updateBio(String newBio) async {
    if (_user == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Updating bio for ${_user!.id} to: $newBio');
      await SupabaseService.client
          .from('profiles')
          .upsert({
            'id': _user!.id,
            'bio': newBio,
            'username': _user!.username, // Ensure username is preserved
            'email': _user!.email,
          });
      
      // Re-hydrate to ensure we have the exact state from DB
      final currentUser = SupabaseService.client.auth.currentUser;
      if (currentUser != null) {
        await _hydrateUser(currentUser, fallbackEmail: currentUser.email ?? '');
      }
      _errorMessage = null;
      debugPrint('Bio updated and state re-hydrated');
    } catch (e) {
      _errorMessage = 'Could not update bio. Please check your connection.';
      debugPrint('Update bio error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAvatar(String imageUrl) async {
    if (_user == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Updating avatar for ${_user!.id} to: $imageUrl');
      await SupabaseService.client
          .from('profiles')
          .upsert({
            'id': _user!.id,
            'avatar_url': imageUrl,
            'username': _user!.username,
            'email': _user!.email,
          });
      
      final currentUser = SupabaseService.client.auth.currentUser;
      if (currentUser != null) {
        await _hydrateUser(currentUser, fallbackEmail: currentUser.email ?? '');
      }
      _errorMessage = null;
      debugPrint('Avatar updated and state re-hydrated');
    } catch (e) {
      _errorMessage = 'Could not update profile picture.';
      debugPrint('Update avatar error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    if (_user == null) return;
    final myId = _user!.id;
    
    try {
      // Check current status
      final existing = await SupabaseService.client
          .from('followers')
          .select()
          .match({'follower_id': myId, 'followed_id': targetUserId})
          .maybeSingle();

      if (existing != null) {
        await SupabaseService.client
            .from('followers')
            .delete()
            .match({'follower_id': myId, 'followed_id': targetUserId});
      } else {
        await SupabaseService.client
            .from('followers')
            .insert({'follower_id': myId, 'followed_id': targetUserId});
      }
    } catch (e) {
      debugPrint('Toggle follow error: $e');
    }
  }

  Future<bool> isFollowing(String targetUserId) async {
    if (_user == null) return false;
    final response = await SupabaseService.client
        .from('followers')
        .select()
        .match({'follower_id': _user!.id, 'followed_id': targetUserId})
        .maybeSingle();
    return response != null;
  }

  void _startCooldown(int seconds) {
    _signupCooldownUntil = DateTime.now().add(Duration(seconds: seconds));
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isSignupRateLimited) {
        timer.cancel();
        _cooldownTimer = null;
        _signupCooldownUntil = null;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
