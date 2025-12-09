import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../models/user_profile.dart';
import '../models/food_history.dart';
import '../services/auth_service.dart';
import '../services/user_database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _budgetController = TextEditingController();
  final _authService = AuthService();
  final _userDb = UserDatabaseService();
  
  List<String> selectedAllergies = [];
  List<String> selectedMedicalConditions = [];
  
  final List<String> commonAllergies = [
    'Kacang', 'Seafood', 'Telur', 'Susu', 'Gluten', 'Kedelai', 'MSG'
  ];
  
  final List<String> commonMedicalConditions = [
    'Diabetes', 'Hipertensi', 'Kolesterol Tinggi', 'Asam Lambung', 
    'Maag', 'Jantung', 'Ginjal', 'Tidak Ada'
  ];

  UserProfile? currentUser;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final box = await Hive.openBox<UserProfile>('userProfile');
    if (box.isNotEmpty) {
      setState(() {
        currentUser = box.getAt(0);
        isLoggedIn = true;
        _populateFields();
      });
    }
  }

  void _populateFields() {
    if (currentUser != null) {
      _nameController.text = currentUser!.name ?? '';
      _emailController.text = currentUser!.email ?? '';
      _phoneController.text = currentUser!.phone ?? '';
      _budgetController.text = currentUser!.dailyBudget?.toString() ?? '';
      selectedAllergies = List.from(currentUser!.allergies);
      selectedMedicalConditions = List.from(currentUser!.medicalConditions);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dailyBudget: double.tryParse(_budgetController.text.trim()),
        allergies: selectedAllergies,
        medicalConditions: selectedMedicalConditions,
        isPremium: currentUser?.isPremium ?? false,
      );

      try {
        // Save to Hive (local)
        final box = await Hive.openBox<UserProfile>('userProfile');
        await box.clear();
        await box.add(profile);

        // Save to Firestore (cloud)
        await _userDb.saveUserProfile(profile);

        setState(() {
          currentUser = profile;
          isLoggedIn = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil disimpan ke cloud! \u2601\ufe0f'),
              backgroundColor: AppTheme.primaryOrange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal nyimpan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    try {
      // Logout from Firebase
      await _authService.signOut();
      
      // Clear Hive data
      final box = await Hive.openBox<UserProfile>('userProfile');
      await box.clear();
      
      if (mounted) {
        setState(() {
          currentUser = null;
          isLoggedIn = false;
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _budgetController.clear();
          selectedAllergies.clear();
          selectedMedicalConditions.clear();
        });
        
        // Navigate to landing page
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user needs to login first
    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        appBar: AppBar(
          backgroundColor: AppTheme.white,
          elevation: 0,
          title: const Text(
            'Profile',
            style: AppTheme.headingMedium,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppTheme.primaryOrange.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Login Required',
                  style: AppTheme.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan login untuk mengakses dan mengelola profil Anda.',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    'Login Sekarang',
                    style: AppTheme.buttonText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: AppTheme.headingMedium,
        ),
        actions: [
          if (isLoggedIn)
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              color: AppTheme.primaryOrange,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isLoggedIn ? 'Edit Profile' : 'Buat Profile',
                      style: AppTheme.headingSmall,
                    ),
                    if (isLoggedIn && currentUser != null)
                      Text(
                        'Halo, ${currentUser!.name ?? 'User'}!',
                        style: AppTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Basic Information
              const Text('Informasi Dasar', style: AppTheme.headingSmall),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 24),
              
              // Budget
              const Text('Budget Makan Harian', style: AppTheme.headingSmall),
              const SizedBox(height: 8),
              Text(
                'Masukkan budget harian untuk rekomendasi yang sesuai',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _budgetController,
                decoration: InputDecoration(
                  labelText: 'Budget (Rp)',
                  prefixText: 'Rp ',
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
              
              // Allergies
              const Text('Alergi Makanan', style: AppTheme.headingSmall),
              const SizedBox(height: 16),
              
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
                        if (selected) {
                          selectedAllergies.add(allergy);
                        } else {
                          selectedAllergies.remove(allergy);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryOrange,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Medical Conditions
              const Text('Kondisi Kesehatan', style: AppTheme.headingSmall),
              const SizedBox(height: 16),
              
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
                        if (selected) {
                          if (condition == 'Tidak Ada') {
                            selectedMedicalConditions.clear();
                            selectedMedicalConditions.add(condition);
                          } else {
                            selectedMedicalConditions.remove('Tidak Ada');
                            if (selected) {
                              selectedMedicalConditions.add(condition);
                            } else {
                              selectedMedicalConditions.remove(condition);
                            }
                          }
                        } else {
                          selectedMedicalConditions.remove(condition);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryOrange,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLoggedIn ? 'Update Profile' : 'Simpan Profile',
                    style: AppTheme.buttonText,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Premium Status
              if (isLoggedIn)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentUser?.isPremium == true 
                        ? AppTheme.primaryOrange.withOpacity(0.1)
                        : AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentUser?.isPremium == true 
                          ? AppTheme.primaryOrange
                          : AppTheme.mediumGray,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        currentUser?.isPremium == true ? Icons.star : Icons.star_border,
                        color: currentUser?.isPremium == true 
                            ? AppTheme.primaryOrange
                            : AppTheme.mediumGray,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentUser?.isPremium == true ? 'Premium User' : 'Free User',
                        style: AppTheme.headingSmall,
                      ),
                      if (currentUser?.isPremium != true)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Member ${currentUser?.isPremium == true ? 'Premium' : 'Gratis'}',
                              style: AppTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                // TODO: Implement premium upgrade
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur upgrade premium coming soon!'),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryOrange,
                                side: const BorderSide(color: AppTheme.primaryOrange),
                              ),
                              child: const Text('Upgrade ke Premium'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // History Section
              if (isLoggedIn) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Riwayat & Favorit', style: AppTheme.headingSmall),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FullHistoryPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Lihat Semua'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder(
                  valueListenable: Hive.box<FoodHistory>('foodHistory').listenable(),
                  builder: (context, Box<FoodHistory> box, _) {
                    if (box.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada riwayat',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final recentHistory = box.values.toList().reversed.take(5).toList();

                    return Column(
                      children: recentHistory.map((history) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: AppTheme.primaryOrange,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      history.mainFood,
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${history.timestamp.day}/${history.timestamp.month}/${history.timestamp.year}',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (history.reasoning.contains('Favorit'))
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 20,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Logout Button
              if (isLoggedIn)
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              _logout();
                              Navigator.pop(context);
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Logout'),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}

class FullHistoryPage extends StatelessWidget {
  const FullHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const Text('Riwayat & Favorit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FoodHistory>('foodHistory').listenable(),
        builder: (context, Box<FoodHistory> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat',
                    style: AppTheme.headingSmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final allHistory = box.values.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allHistory.length,
            itemBuilder: (context, index) {
              final history = allHistory[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: AppTheme.primaryOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            history.mainFood,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${history.timestamp.day}/${history.timestamp.month}/${history.timestamp.year} - ${history.timestamp.hour}:${history.timestamp.minute.toString().padLeft(2, '0')}',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (history.reasoning.contains('Favorit'))
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}