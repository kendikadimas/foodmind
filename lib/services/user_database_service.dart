import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

class UserDatabaseService {
  final SupabaseService _supabase = SupabaseService();

  // Get current user ID
  String? get currentUserId => _supabase.currentUserId;

  // Create or update user profile in Supabase
  Future<void> saveUserProfile(UserProfile profile) async {
    if (currentUserId == null) {
      throw 'User belum login';
    }

    try {
      final now = DateTime.now().toIso8601String();
      
      await _supabase.client.from('users').upsert({
        'id': currentUserId,
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
        'daily_budget': profile.dailyBudget,
        'allergies': profile.allergies,
        'medical_conditions': profile.medicalConditions,
        'food_preferences': profile.foodPreferences,
        'is_premium': profile.isPremium,
        'updated_at': now,
      });
    } catch (e) {
      throw 'Gagal menyimpan profil: $e';
    }
  }

  // Get user profile from Supabase
  Future<UserProfile?> getUserProfile() async {
    if (currentUserId == null) return null;

    try {
      final response = await _supabase.client
          .from('users')
          .select()
          .eq('id', currentUserId!)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile(
        name: response['name'] as String?,
        email: response['email'] as String?,
        phone: response['phone'] as String?,
        dailyBudget: (response['daily_budget'] as num?)?.toDouble(),
        allergies: List<String>.from(response['allergies'] ?? []),
        medicalConditions: List<String>.from(response['medical_conditions'] ?? []),
        foodPreferences: List<String>.from(response['food_preferences'] ?? []),
        isPremium: response['is_premium'] as bool? ?? false,
      );
    } catch (e) {
      throw 'Gagal mengambil profil: $e';
    }
  }

  // Stream user profile for real-time updates
  Stream<UserProfile?> streamUserProfile() {
    if (currentUserId == null) {
      return Stream.value(null);
    }

    return _supabase.client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', currentUserId!)
        .map((data) {
          if (data.isEmpty) return null;

          final profile = data.first;
          return UserProfile(
            name: profile['name'] as String?,
            email: profile['email'] as String?,
            phone: profile['phone'] as String?,
            dailyBudget: (profile['daily_budget'] as num?)?.toDouble(),
            allergies: List<String>.from(profile['allergies'] ?? []),
            medicalConditions: List<String>.from(profile['medical_conditions'] ?? []),
            foodPreferences: List<String>.from(profile['food_preferences'] ?? []),
            isPremium: profile['is_premium'] as bool? ?? false,
          );
        });
  }

  // Update specific fields
  Future<void> updateUserField(String field, dynamic value) async {
    if (currentUserId == null) {
      throw 'User belum login';
    }

    try {
      await _supabase.client.from('users').update({
        field: value,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUserId!);
    } catch (e) {
      throw 'Gagal update $field: $e';
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile() async {
    if (currentUserId == null) return;

    try {
      await _supabase.client.from('users').delete().eq('id', currentUserId!);
    } catch (e) {
      throw 'Gagal menghapus profil: $e';
    }
  }

  // Check if user profile exists
  Future<bool> userProfileExists() async {
    if (currentUserId == null) return false;

    try {
      final response = await _supabase.client
          .from('users')
          .select('id')
          .eq('id', currentUserId!)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }
}
