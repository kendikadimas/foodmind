import 'package:flutter/material.dart';
import 'package:foodmind/pages/main_scaffold.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:foodmind/models/food_history.dart';
import 'package:foodmind/models/user_profile.dart';
import 'package:foodmind/models/community_post.dart';
import 'package:foodmind/services/supabase_service.dart';
import 'pages/onboarding_page.dart';
import 'pages/input_page.dart';
import 'pages/reasoning_page.dart';
import 'pages/result_page.dart';
import 'pages/login_page.dart';
import 'pages/onboarding_preferences_page.dart';
import 'pages/community_page.dart';
import 'pages/create_post_page.dart';
import 'pages/landing_page.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(FoodHistoryAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(CommunityPostAdapter());
  Hive.registerAdapter(PostResponseAdapter());
  await Hive.openBox<FoodHistory>('foodHistory');
  await Hive.openBox<UserProfile>('userProfile');
  await Hive.openBox<CommunityPost>('communityPosts');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodMind',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // Landing page selalu ditampilkan pertama kali
      home: const LandingPage(), 
      routes: {
        '/landing': (context) => const LandingPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/onboarding-preferences': (context) => const OnboardingPreferencesPage(),
        '/community': (context) => const CommunityPage(),
        '/create-post': (context) => const CreatePostPage(),
        '/input': (context) => const InputPage(), // Tetap ada untuk navigasi internal
        '/main': (context) => const MainScaffold(),
        '/reasoning': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ReasoningPage(
            taste: args['taste'] ?? '',
            style: args['style'] ?? '',
            weather: args['weather'] ?? '',
            position: args['position'] as Position?,
            allergies: args['allergies'] ?? '',
            likes: args['likes'] ?? '',
            budget: args['budget'] ?? '',
            healthConditions: args['healthConditions'] ?? '',
          );
        },
        '/result': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ResultPage(foodData: args);
        },
      },
    );
  }
}

