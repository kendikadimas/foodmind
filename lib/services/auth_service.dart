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
      // Normalize email: trim whitespace dan lowercase
      final normalizedEmail = email.trim().toLowerCase();
      final trimmedName = name.trim();
      
      // Validasi email format
      if (!_isValidEmail(normalizedEmail)) {
        throw 'Format email tidak valid. Gunakan format: nama@email.com';
      }
      
      // Validasi password
      if (password.length < 6) {
        throw 'Password minimal 6 karakter';
      }
      
      // Validasi name
      if (trimmedName.isEmpty) {
        throw 'Nama tidak boleh kosong';
      }
      
      if (trimmedName.length < 2) {
        throw 'Nama terlalu pendek (minimal 2 karakter)';
      }
      
      // Debug log (akan muncul di console)
      print('🔐 Attempting signup with:');
      print('  Email: $normalizedEmail');
      print('  Name: $trimmedName');
      print('  Password length: ${password.length}');
      
      // Create user account
      final response = await _supabase.client.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {'name': trimmedName},
      );
      
      print('✅ Signup response: User ID = ${response.user?.id}');

      if (response.user != null) {
        // Wait a bit for auth state to update
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Verify current user is set
        final currentUserId = _supabase.currentUserId;
        print('🔍 Current user ID after delay: $currentUserId');
        
        if (currentUserId == null) {
          print('⚠️ Warning: currentUserId still null, using response.user.id instead');
        }
        
        // Save to Hive and Supabase
        await _saveUserProfile(
          name: trimmedName,
          email: normalizedEmail,
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
      // Normalize email: trim whitespace dan lowercase
      final normalizedEmail = email.trim().toLowerCase();
      
      final response = await _supabase.client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      if (response.user != null) {
        // Save/update user profile
        await _saveUserProfile(
          name: response.user!.userMetadata?['name'] ?? 'User',
          email: normalizedEmail,
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
      print('✅ User profile saved to Hive (local)');

      // Save to Supabase (cloud)
      try {
        print('📤 Attempting to save user profile to Supabase...');
        
        // Use provided uid if currentUserId is null (timing issue)
        final userIdToUse = uid ?? currentUser?.id;
        
        if (userIdToUse == null) {
          throw 'Cannot determine user ID (both currentUser and uid are null)';
        }
        
        print('   Using User ID: $userIdToUse');
        await _userDb.saveUserProfileWithId(profile, userIdToUse);
        print('✅ User profile saved to Supabase successfully!');
        print('   - User ID: $userIdToUse');
        print('   - Name: $name');
        print('   - Email: $email');
      } catch (e) {
        print('❌ Could not save to Supabase: $e');
        print('⚠️ Check if:');
        print('   1. Table "users" exists in Supabase');
        print('   2. RLS policies are correct');
        print('   3. User is authenticated (ID: ${uid ?? currentUser?.id})');
      }
    } catch (e) {
      print('❌ Error saving user profile: $e');
    }
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email) && 
           email.length >= 5 && 
           email.length <= 100;
  }

  // Handle Supabase Auth exceptions
  String _handleAuthException(AuthException e) {
    final message = e.message.toLowerCase();
    
    // Cek berbagai error message dari Supabase
    if (message.contains('invalid login credentials')) {
      return 'Email atau password salah.';
    }
    
    if (message.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek inbox kamu.';
    }
    
    if (message.contains('user already registered') || 
        message.contains('already registered')) {
      return 'Email sudah terdaftar. Silakan login.';
    }
    
    if (message.contains('invalid email') || 
        message.contains('unable to validate email')) {
      return 'Format email tidak valid.\nGunakan format: nama@email.com';
    }
    
    if (message.contains('password') && 
        (message.contains('short') || message.contains('weak'))) {
      return 'Password terlalu lemah.\nMinimal 6 karakter.';
    }
    
    if (message.contains('rate limit')) {
      return 'Terlalu banyak percobaan.\nSilakan coba lagi nanti.';
    }
    
    if (message.contains('network') || message.contains('connection')) {
      return 'Koneksi internet bermasalah.\nCek koneksi Anda dan coba lagi.';
    }
    
    // Return original message if no match
    return 'Error: ${e.message}';
  }
}
