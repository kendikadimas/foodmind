class HomeState {
  final String greeting;
  final String greetingEmoji;
  final String motivationalText;
  final DateTime currentTime;

  const HomeState({
    required this.greeting,
    required this.greetingEmoji,
    required this.motivationalText,
    required this.currentTime,
  });

  factory HomeState.initial() => HomeState(
        greeting: 'Selamat Pagi',
        greetingEmoji: '🌅',
        motivationalText: 'Tenang, kita bantuin kamu nemuin makanan yang pas banget buat hari ini!',
        currentTime: DateTime.now(),
      );

  HomeState copyWith({
    String? greeting,
    String? greetingEmoji,
    String? motivationalText,
    DateTime? currentTime,
  }) {
    return HomeState(
      greeting: greeting ?? this.greeting,
      greetingEmoji: greetingEmoji ?? this.greetingEmoji,
      motivationalText: motivationalText ?? this.motivationalText,
      currentTime: currentTime ?? this.currentTime,
    );
  }
}
