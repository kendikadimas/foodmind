import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/home_state.dart';

part 'home_view_model.g.dart';

/// ViewModel for Home feature
/// Handles business logic for greeting based on time of day
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    // Calculate initial state based on current time
    return _calculateGreetingState();
  }

  /// Calculate greeting state based on current time
  HomeState _calculateGreetingState() {
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    String emoji;
    String motivationalText;

    if (hour >= 4 && hour < 12) {
      greeting = 'Selamat Pagi';
      emoji = '🌅';
      motivationalText = 'Semangat pagi! Yuk mulai hari dengan sarapan yang enak~';
    } else if (hour >= 12 && hour < 15) {
      greeting = 'Selamat Siang';
      emoji = '☀️';
      motivationalText = 'Waktunya makan siang! Cobain menu spesial hari ini yuk!';
    } else if (hour >= 15 && hour < 18) {
      greeting = 'Selamat Sore';
      emoji = '🌤️';
      motivationalText = 'Sore-sore gini enak ngemil sambil ngopi, nih!';
    } else {
      greeting = 'Selamat Malam';
      emoji = '🌙';
      motivationalText = 'Malam-malam gini cocok makan yang hangat dan nyaman!';
    }

    return HomeState(
      greeting: greeting,
      greetingEmoji: emoji,
      motivationalText: motivationalText,
      currentTime: now,
    );
  }

  /// Refresh greeting state (useful when app comes back to foreground)
  void refreshGreeting() {
    state = _calculateGreetingState();
  }

  /// Get greeting text for display
  String getGreetingText() {
    return '${state.greeting} ${state.greetingEmoji}';
  }

  /// Get time-based recommendation type
  String getRecommendationType() {
    final hour = state.currentTime.hour;
    
    if (hour >= 4 && hour < 12) {
      return 'sarapan';
    } else if (hour >= 12 && hour < 15) {
      return 'makan_siang';
    } else if (hour >= 15 && hour < 18) {
      return 'cemilan_sore';
    } else {
      return 'makan_malam';
    }
  }
}
