import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../models/community_post.dart';
import '../models/user_profile.dart';
import '../providers/service_providers.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  
  UserProfile? currentUser;
  Set<String> selectedAllergies = {};
  Set<String> selectedPreferences = {};
  bool isLoading = false;

  final List<String> commonAllergies = [
    'Kacang', 'Seafood', 'Telur', 'Susu', 'Gluten', 'Kedelai', 'MSG'
  ];

  final List<String> foodPreferences = [
    'Makanan Sehat', 'Street Food', 'Makanan Tradisional', 'Fast Food',
    'Vegetarian', 'Seafood', 'Pedas', 'Manis', 'Berkuah', 'Kering'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    print('🔍 Loading user profile from Hive...');
    final box = await Hive.openBox<UserProfile>('userProfile');
    print('📦 Hive box opened. Items count: ${box.length}');
    
    if (box.isNotEmpty) {
      final user = box.getAt(0);
      print('✅ User loaded: ${user?.name} (${user?.email})');
      
      setState(() {
        currentUser = user;
        // Pre-fill with user's existing preferences
        if (currentUser!.allergies.isNotEmpty) {
          selectedAllergies = currentUser!.allergies.toSet();
        }
        if (currentUser!.foodPreferences.isNotEmpty) {
          selectedPreferences = currentUser!.foodPreferences.toSet();
        }
        if (currentUser!.dailyBudget != null) {
          _budgetController.text = currentUser!.dailyBudget!.toInt().toString();
        }
      });
    } else {
      print('❌ Hive box is empty - user not logged in');
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate() || currentUser == null) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final post = CommunityPost(
        id: '0', // Temporary, will be replaced by Supabase auto-generated id
        authorName: currentUser!.name ?? '',
        authorEmail: currentUser!.email ?? '',
        content: _contentController.text.trim(),
        location: _locationController.text.trim().isNotEmpty 
            ? _locationController.text.trim() 
            : null,
        budget: _budgetController.text.trim().isNotEmpty 
            ? double.tryParse(_budgetController.text.trim()) 
            : null,
        allergies: selectedAllergies.toList(),
        medicalConditions: currentUser!.medicalConditions,
        preferences: selectedPreferences.toList(),
        createdAt: DateTime.now(),
      );

      // Save to Supabase
      await ref.read(postDatabaseServiceProvider).createPost(post);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post berhasil disimpan ke cloud! ☁️'),
            backgroundColor: AppTheme.primaryOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal buat post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If user not logged in after loading, show error
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Buat Post'),
          backgroundColor: AppTheme.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppTheme.primaryOrange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Login',
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan login terlebih dahulu untuk membuat post',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
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
          'Buat Post Baru',
          style: AppTheme.headingMedium,
        ),
        actions: [
          if (!isLoading)
            TextButton(
              onPressed: _submitPost,
              child: const Text(
                'Post',
                style: TextStyle(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                      child: Text(
                        (currentUser!.name?.isNotEmpty ?? false) 
                            ? currentUser!.name![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Posting sebagai ${currentUser!.name ?? 'User'}',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Posting sebagai ${currentUser!.name}',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Post content
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Apa yang ingin Anda tanyakan?',
                  hintText: 'Ceritakan tentang makanan yang Anda cari, suasana hati, atau kondisi khusus...',
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
                    return 'Harap isi konten post Anda';
                  }
                  if (value.trim().length < 10) {
                    return 'Post minimal 10 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Location (optional)
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Lokasi (Opsional)',
                  hintText: 'Contoh: Jakarta Selatan, Bandung, dll.',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Budget (optional)
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Budget (Opsional)',
                  hintText: 'Contoh: 50000',
                  prefixText: 'Rp ',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Allergies section
              const Text(
                'Alergi (Opsional)',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
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

              // Preferences section
              const Text(
                'Preferensi Makanan (Opsional)',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: foodPreferences.map((preference) {
                  final isSelected = selectedPreferences.contains(preference);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(preference),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedPreferences.add(preference);
                        } else {
                          selectedPreferences.remove(preference);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryOrange,
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Submit button (full width)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Buat Post',
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

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}