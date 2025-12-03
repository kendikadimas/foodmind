import 'package:flutter/material.dart';
import '../theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      _buildCard(
                        0,
                        '🍽️',
                        'Bingung Mau Makan Apa?',
                        'FoodMind membantu Anda menemukan rekomendasi makanan\nyang sempurna untuk setiap momen.',
                      ),
                      const SizedBox(height: 24),
                      _buildCard(
                        1,
                        '🧠',
                        'AI yang Cerdas',
                        'Teknologi AI dari OpenAI memberikan rekomendasi\nbermakna berdasarkan preferensi Anda.',
                      ),
                      const SizedBox(height: 24),
                      _buildCard(
                        2,
                        '💾',
                        'Riwayat Tersimpan',
                        'Semua rekomendasi Anda tersimpan di perangkat\nuntuk dilihat kembali kapan saja.',
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/input');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mulai',
                    style: AppTheme.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index, String emoji, String title, String description) {
    final delay = index * 200.0;
    final animation = Tween<Offset>(
      begin: const Offset(0, 50),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          delay / 1200,
          (delay + 400) / 1200,
          curve: Curves.easeOut,
        ),
      ),
    );

    final opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          delay / 1200,
          (delay + 400) / 1200,
          curve: Curves.easeOut,
        ),
      ),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTheme.bodyMedium,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
