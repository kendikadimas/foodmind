import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../models/user_profile.dart';

class OnboardingPreferencesPage extends StatefulWidget {
  const OnboardingPreferencesPage({super.key});

  @override
  State<OnboardingPreferencesPage> createState() => _OnboardingPreferencesPageState();
}

class _OnboardingPreferencesPageState extends State<OnboardingPreferencesPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Budget
  final TextEditingController _budgetController = TextEditingController();
  
  // Allergies
  final List<String> commonAllergies = [
    'Kacang', 'Seafood', 'Telur', 'Susu', 'Gluten', 'Kedelai', 'MSG', 'Tidak Ada'
  ];
  Set<String> selectedAllergies = {};
  
  // Medical Conditions
  final List<String> commonMedicalConditions = [
    'Diabetes', 'Hipertensi', 'Kolesterol Tinggi', 'Asam Lambung', 
    'Maag', 'Jantung', 'Ginjal', 'Tidak Ada'
  ];
  Set<String> selectedMedicalConditions = {};
  
  // Food Preferences
  final List<String> foodTypes = [
    'Makanan Sehat', 'Street Food', 'Makanan Tradisional', 'Fast Food',
    'Vegetarian', 'Seafood', 'Pedas', 'Manis', 'Berkuah', 'Kering'
  ];
  Set<String> selectedFoodPreferences = {};

  Future<void> _savePreferencesAndComplete() async {
    try {
      // Get current user profile
      final box = await Hive.openBox<UserProfile>('userProfile');
      UserProfile? currentUser;
      
      if (box.isNotEmpty) {
        currentUser = box.getAt(0);
      }

      // Create updated profile with preferences
      final updatedProfile = UserProfile(
        name: currentUser?.name ?? '',
        email: currentUser?.email ?? '',
        phone: currentUser?.phone ?? '',
        dailyBudget: double.tryParse(_budgetController.text.trim()),
        allergies: selectedAllergies.toList(),
        medicalConditions: selectedMedicalConditions.toList(),
        foodPreferences: selectedFoodPreferences.toList(),
        isPremium: currentUser?.isPremium ?? false,
      );

      await box.clear();
      await box.add(updatedProfile);

      // Mark onboarding as completed
      final settingsBox = await Hive.openBox('settings');
      await settingsBox.put('onboarding_completed', true);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan preferensi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _savePreferencesAndComplete();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Setup Preferensi',
                        style: AppTheme.headingSmall,
                      ),
                      Text(
                        '${_currentPage + 1}/4',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / 4,
                    backgroundColor: AppTheme.lightGray,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primaryOrange),
                  ),
                ],
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(),
                  _buildBudgetPage(),
                  _buildHealthPage(),
                  _buildPreferencesPage(),
                ],
              ),
            ),
            
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primaryOrange),
                        ),
                        child: const Text('Sebelumnya'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentPage == 3 ? 'Selesai' : 'Lanjut',
                        style: AppTheme.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.favorite,
              color: AppTheme.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Personalisasi Pengalaman Anda',
            style: AppTheme.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Dengan mengisi preferensi Anda, kami dapat memberikan rekomendasi makanan yang lebih akurat dan sesuai dengan kebutuhan Anda.',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildFeatureItem(Icons.account_balance_wallet, 'Budget Harian', 'Rekomendasi sesuai budget'),
                const SizedBox(height: 12),
                _buildFeatureItem(Icons.health_and_safety, 'Kondisi Kesehatan', 'Makanan yang aman untuk Anda'),
                const SizedBox(height: 12),
                _buildFeatureItem(Icons.restaurant_menu, 'Preferensi Makanan', 'Sesuai selera dan kebutuhan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryOrange, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.bodyMedium),
              Text(subtitle, style: AppTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Icon(
              Icons.account_balance_wallet,
              color: AppTheme.primaryOrange,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Budget Makan Harian',
            style: AppTheme.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Berapa budget yang biasanya Anda siapkan untuk makan setiap hari? Ini akan membantu kami memberikan rekomendasi yang sesuai.',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          TextField(
            controller: _budgetController,
            decoration: InputDecoration(
              labelText: 'Budget Harian (Rp)',
              prefixText: 'Rp ',
              hintText: 'Contoh: 50000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 24),
          
          // Quick Budget Options
          const Text('Pilihan Cepat:', style: AppTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBudgetChip('25.000'),
              _buildBudgetChip('50.000'),
              _buildBudgetChip('75.000'),
              _buildBudgetChip('100.000'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChip(String amount) {
    return ActionChip(
      label: Text('Rp $amount'),
      onPressed: () {
        setState(() {
          _budgetController.text = amount.replaceAll('.', '');
        });
      },
      backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
    );
  }

  Widget _buildHealthPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Icon(
              Icons.health_and_safety,
              color: AppTheme.primaryOrange,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Kesehatan & Alergi',
            style: AppTheme.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Informasi ini penting untuk memberikan rekomendasi makanan yang aman dan sehat untuk Anda.',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Allergies Section
          const Text('Alergi Makanan:', style: AppTheme.headingSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonAllergies.map((allergy) {
              final isSelected = selectedAllergies.contains(allergy);
              return FilterChip(
                selected: isSelected,
                label: Text(allergy),
                onSelected: (selected) {
                  setState(() {
                    if (allergy == 'Tidak Ada') {
                      if (selected) {
                        selectedAllergies.clear();
                        selectedAllergies.add(allergy);
                      } else {
                        selectedAllergies.remove(allergy);
                      }
                    } else {
                      selectedAllergies.remove('Tidak Ada');
                      if (selected) {
                        selectedAllergies.add(allergy);
                      } else {
                        selectedAllergies.remove(allergy);
                      }
                    }
                  });
                },
                selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryOrange,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Medical Conditions Section
          const Text('Kondisi Kesehatan:', style: AppTheme.headingSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonMedicalConditions.map((condition) {
              final isSelected = selectedMedicalConditions.contains(condition);
              return FilterChip(
                selected: isSelected,
                label: Text(condition),
                onSelected: (selected) {
                  setState(() {
                    if (condition == 'Tidak Ada') {
                      if (selected) {
                        selectedMedicalConditions.clear();
                        selectedMedicalConditions.add(condition);
                      } else {
                        selectedMedicalConditions.remove(condition);
                      }
                    } else {
                      selectedMedicalConditions.remove('Tidak Ada');
                      if (selected) {
                        selectedMedicalConditions.add(condition);
                      } else {
                        selectedMedicalConditions.remove(condition);
                      }
                    }
                  });
                },
                selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryOrange,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Icon(
              Icons.restaurant_menu,
              color: AppTheme.primaryOrange,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Preferensi Makanan',
            style: AppTheme.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih jenis makanan yang Anda sukai. Ini akan membantu kami memberikan rekomendasi yang lebih sesuai dengan selera Anda.',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          const Text('Jenis Makanan Favorit:', style: AppTheme.headingSmall),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: foodTypes.map((type) {
                  final isSelected = selectedFoodPreferences.contains(type);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(type),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedFoodPreferences.add(type);
                        } else {
                          selectedFoodPreferences.remove(type);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryOrange,
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryOrange,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Siap Memulai!',
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Preferensi Anda telah lengkap dan siap untuk memberikan rekomendasi makanan yang personal.',
                  style: AppTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}