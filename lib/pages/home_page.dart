import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../features/home/view_models/home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the ViewModel to get greeting state
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryOrange,
                    AppTheme.primaryOrange.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${homeState.greeting} ${homeState.greetingEmoji}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppTheme.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Laper Nih, Makan Apa Ya? 🤔',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    homeState.motivationalText,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.white.withOpacity(0.95),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Call to Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yuk, Gaskeun! 🚀',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryOrange.withOpacity(0.1),
                          AppTheme.primaryOrange.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryOrange.withOpacity(0.3),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: AppTheme.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cari Makanan Yuk',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tinggal pilih mood & budget, langsung dapet rekomennya!',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.primaryOrange,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Features Section
                  Text(
                    'Kenapa Harus Pakai FoodMind? 👀',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 16),
                  _FeatureCard(
                    icon: Icons.explore,
                    title: 'AI yang Ngerti Kamu',
                    description: 'AI-nya beneran pinter! Bisa analisa selera, cuaca, sama budget kamu buat kasih rekomendasi yang pas',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    icon: Icons.location_on,
                    title: 'Deket dari Sini',
                    description: 'Ga usah jauh-jauh! Cari tempat makan yang deket aja, maksimal 10 km dari lokasi kamu sekarang',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    icon: Icons.people,
                    title: 'Sharing Bareng Squad',
                    description: 'Share pengalaman jajan kamu, atau stalk rekomendasi makanan dari orang lain. Seru kan?',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    icon: Icons.history,
                    title: 'Simpan yang Enak',
                    description: 'Nemu makanan enak? Save dulu! Biar nanti gampang dicari lagi kalau laper',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 32),

                  // Statistics or Info
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryOrange,
                          AppTheme.primaryOrange.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Udah Siap Nemuin Makanan Enak? 🍴',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to recommendation tab
                            DefaultTabController.of(context).animateTo(1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.white,
                            foregroundColor: AppTheme.primaryOrange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Gas Lah!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
