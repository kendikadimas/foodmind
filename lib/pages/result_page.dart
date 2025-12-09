import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../models/food_history.dart';
import '../services/openai_service.dart';

class ResultPage extends StatefulWidget {
  final Map<String, dynamic> foodData;
  final Map<String, dynamic>? locationInfo;

  const ResultPage({
    super.key,
    required this.foodData,
    this.locationInfo,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late String mainFood;
  late List<dynamic> alternatives;
  late List<dynamic> reasoning;
  late bool locationMatch;
  Map<String, dynamic>? locationInfo;
  bool isRefreshing = false;
  bool isMainFoodFavorite = false;
  List<bool> alternativesFavorite = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _saveToHistory();
  }

  void _loadData() {
    mainFood = widget.foodData['main_food'] ?? 'Tidak ada makanan';
    alternatives = widget.foodData['alternatives'] ?? [];
    reasoning = widget.foodData['reasoning'] ?? [];
    locationMatch = widget.foodData['location_match'] ?? false;
    locationInfo = widget.locationInfo;
    alternativesFavorite = List.generate(alternatives.length, (_) => false);
  }

  Future<void> _refreshRecommendation() async {
    setState(() {
      isRefreshing = true;
    });

    try {
      // Get original search parameters from Navigator arguments
      final arguments = widget.foodData;
      
      // Call OpenAI service to get new recommendation with useCache=false
      final response = await OpenAIService.getFoodRecommendation(
        taste: arguments['taste'] ?? '',
        style: arguments['style'] ?? '',
        weather: arguments['weather'] ?? '',
        position: arguments['position'],
        allergies: arguments['allergies'] ?? '',
        likes: arguments['likes'] ?? '',
        useCache: false, // Force new recommendation
      );
      
      final newRecommendation = response['data'];

      setState(() {
        mainFood = newRecommendation['main_food'] ?? mainFood;
        alternatives = newRecommendation['alternatives'] ?? alternatives;
        reasoning = newRecommendation['reasoning'] ?? reasoning;
        isRefreshing = false;
      });

      // Save new recommendation to history
      _saveToHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rekomendasi berhasil diperbarui!'),
          backgroundColor: AppTheme.primaryOrange,
        ),
      );
    } catch (e) {
      setState(() {
        isRefreshing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui rekomendasi. Coba lagi nanti.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveToHistory() async {
    try {
      final box = Hive.box<FoodHistory>('foodHistory');
      final history = FoodHistory(
        mainFood: mainFood,
        alternatives: List<String>.from(alternatives),
        reasoning: List<String>.from(reasoning),
        taste: 'Dari preferensi',
        style: 'Dari preferensi',
        weather: 'Dari preferensi',
        timestamp: DateTime.now(),
      );
      await box.add(history);
    } catch (e) {
      debugPrint('Error saving to history: $e');
    }
  }

  Future<void> _toggleFavorite(String foodName, int index, bool isMain) async {
    try {
      final box = Hive.box<FoodHistory>('foodHistory');
      
      // State sudah berubah saat fungsi ini dipanggil
      // Jika state sekarang true (filled heart), berarti baru ditambahkan
      if (isMain ? isMainFoodFavorite : alternativesFavorite[index]) {
        // Add to favorites
        final history = FoodHistory(
          mainFood: foodName,
          alternatives: [],
          reasoning: ['Favorit'],
          taste: 'Dari preferensi',
          style: 'Dari preferensi',
          weather: 'Dari preferensi',
          timestamp: DateTime.now(),
        );
        await box.add(history);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$foodName ditambahkan ke favorit'),
              backgroundColor: AppTheme.primaryOrange,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        // Remove from favorites
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$foodName dihapus dari favorit'),
              backgroundColor: Colors.grey,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> _openMaps() async {
    final query = '$mainFood terdekat';
    final url = Uri.parse('https://www.google.com/maps/search/$query');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/input');
      },
      child: Scaffold(
        backgroundColor: AppTheme.white,
        appBar: AppBar(
          title: const Text('Rekomendasi Makanan'),
          backgroundColor: AppTheme.white,
          elevation: 0,
          foregroundColor: AppTheme.black,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: isRefreshing ? null : _refreshRecommendation,
              icon: isRefreshing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: 'Cari rekomendasi lain',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Food Card
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
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ini Dia Pilihannya! 🎉',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mainFood,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isMainFoodFavorite = !isMainFoodFavorite;
                            });
                            _toggleFavorite(mainFood, 0, true);
                          },
                          icon: Icon(
                            isMainFoodFavorite ? Icons.favorite : Icons.favorite_border,
                            color: AppTheme.white,
                            size: 28,
                          ),
                          tooltip: 'Tambah ke favorit',
                        ),
                      ],
                    ),
                    if (locationMatch) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, color: AppTheme.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Sesuai Lokasi Anda',
                              style: TextStyle(color: AppTheme.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openMaps,
                        icon: const Icon(Icons.map),
                        label: const Text('Cari Lokasinya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.white,
                          foregroundColor: AppTheme.primaryOrange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Alternatives Section
              if (alternatives.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilihan Lainnya Nih 👀',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 12),
                    ...alternatives
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGray,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryOrange.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryOrange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(
                                          color: AppTheme.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.value.toString(),
                                      style: AppTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        alternativesFavorite[entry.key] = !alternativesFavorite[entry.key];
                                      });
                                      _toggleFavorite(entry.value.toString(), entry.key, false);
                                    },
                                    icon: Icon(
                                      alternativesFavorite[entry.key] ? Icons.favorite : Icons.favorite_border,
                                      color: AppTheme.primaryOrange,
                                    ),
                                    tooltip: 'Tambah ke favorit',
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final query = '${entry.value} terdekat';
                                      final url = Uri.parse('https://www.google.com/maps/search/$query');
                                      
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.map),
                                    color: AppTheme.primaryOrange,
                                    tooltip: 'Lihat di Maps',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 32),
                  ],
                ),

              // Reasoning Section
              if (reasoning.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mengapa Rekomendasi Ini?',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryOrange.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: reasoning
                            .map(
                              (reason) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '• ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.primaryOrange,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        reason.toString(),
                                        style: AppTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),

              const SizedBox(height: 8),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/input');
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Cari Lagi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryOrange,
                        side: const BorderSide(
                          color: AppTheme.primaryOrange,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/main');
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('Riwayat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
