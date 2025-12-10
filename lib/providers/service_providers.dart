import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../services/user_database_service.dart';
import '../services/post_database_service.dart';
import '../services/openai_service.dart';

// Supabase Service Provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// User Database Service Provider
final userDatabaseServiceProvider = Provider<UserDatabaseService>((ref) {
  return UserDatabaseService();
});

// Post Database Service Provider
final postDatabaseServiceProvider = Provider<PostDatabaseService>((ref) {
  return PostDatabaseService();
});

// OpenAI Service Provider
final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});
