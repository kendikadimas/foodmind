import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../models/food_history.dart';

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

  @override
  void initState() {
    super.initState();
    mainFood = widget.foodData['main_food'] ?? 'Tidak ada makanan';
    alternatives = widget.foodData['alternatives'] ?? [];
    reasoning = widget.foodData['reasoning'] ?? [];
    locationMatch = widget.foodData['location_match'] ?? false;
    locationInfo = widget.locationInfo;

    _saveToHistory();
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
                      'Rekomendasi Utama',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mainFood,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
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
                        label: const Text('Lihat di Maps'),
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

              // Location Information Section (if available)
              if (locationInfo != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Detail Informasi Lokasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      _buildInfoRow(Icons.my_location, 'Koordinat GPS', locationInfo!['coordinates']),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.radar, 'Radius Pencarian', locationInfo!['radius']),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.cloud, 'Sumber Data', locationInfo!['source']),
                      const SizedBox(height: 8),
                      
                      if (locationInfo!['error'] != null)
                        _buildInfoRow(Icons.warning, 'Status', locationInfo!['error'], isError: true)
                      else
                        _buildInfoRow(Icons.check_circle, 'Status', 
                          'Ditemukan ${locationInfo!['total_found']} tempat makan terdekat', isSuccess: true),
                      
                      if (locationInfo!['sample_places'] != null && 
                          (locationInfo!['sample_places'] as List).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Contoh Tempat Makan Terdekat:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(locationInfo!['sample_places'] as List).map((place) => 
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ', style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    place.toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

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

              // Alternatives Section
              if (alternatives.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alternatif Lainnya',
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
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                ),

              const SizedBox(height: 32),

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
                        Navigator.pushNamed(context, '/history');
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

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isError = false, bool isSuccess = false}) {
    Color iconColor = Colors.blue.shade600;
    Color textColor = Colors.grey.shade700;
    
    if (isError) {
      iconColor = Colors.red.shade600;
      textColor = Colors.red.shade600;
    } else if (isSuccess) {
      iconColor = Colors.green.shade600;
      textColor = Colors.green.shade600;
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
