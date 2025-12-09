import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import 'user_database_service.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseService _supabase = SupabaseService();
  final UserDatabaseService _userDb = UserDatabaseService();

  // Get current user
  User? get currentUser => _supabase.currentUser;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.client.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user account
      final response = await _supabase.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        // Save to Hive and Supabase
        await _saveUserProfile(
          name: name,
          email: email,
          uid: response.user!.id,
        );
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Sign in with email and password
  Future<AuthResponse?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Save/update user profile
        await _saveUserProfile(
          name: response.user!.userMetadata?['name'] ?? 'User',
          email: email,
          uid: response.user!.id,
        );
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Sign in with Google (Supabase OAuth)
  Future<bool> signInWithGoogle() async {
    try {
      // Trigger Google OAuth via Supabase
      final response = await _supabase.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.foodmind://callback', // Deep link untuk Android/iOS
      );

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan saat login dengan Google: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.client.auth.signOut();

      // Clear user profile from Hive
      final box = await Hive.openBox<UserProfile>('userProfile');
      await box.clear();
    } catch (e) {
      throw 'Gagal logout: $e';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal mengirim email reset password: $e';
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _supabase.currentUser != null;
  }

  // Save user profile to Hive and Supabase
  Future<void> _saveUserProfile({
    required String name,
    required String email,
    String? uid,
  }) async {
    try {
      final box = await Hive.openBox<UserProfile>('userProfile');
      
      UserProfile? existingProfile;
      if (box.isNotEmpty) {
        existingProfile = box.getAt(0);
      }

      // Try to get profile from Supabase if exists
      try {
        final supabaseProfile = await _userDb.getUserProfile();
        if (supabaseProfile != null) {
          existingProfile = supabaseProfile;
        }
      } catch (e) {
        print('Could not fetch from Supabase: $e');
      }

      final profile = UserProfile(
        name: name,
        email: email,
        phone: existingProfile?.phone,
        dailyBudget: existingProfile?.dailyBudget,
        allergies: existingProfile?.allergies ?? [],
        medicalConditions: existingProfile?.medicalConditions ?? [],
        foodPreferences: existingProfile?.foodPreferences ?? [],
        isPremium: existingProfile?.isPremium ?? false,
      );

      // Save to Hive (local)
      await box.clear();
      await box.add(profile);

      // Save to Supabase (cloud)
      try {
        await _userDb.saveUserProfile(profile);
      } catch (e) {
        print('Could not save to Supabase: $e');
      }
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  // Handle Supabase Auth exceptions
  String _handleAuthException(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Email atau password salah.';
      case 'Email not confirmed':
        return 'Email belum dikonfirmasi. Cek inbox kamu.';
      case 'User already registered':
        return 'Email sudah terdaftar. Silakan login.';
      default:
        if (e.message.contains('Password')) {
          return 'Password terlalu lemah. Minimal 6 karakter.';
        }
        if (e.message.contains('email')) {
          return 'Format email tidak valid.';
        }
        return e.message;
    }
  }
}
