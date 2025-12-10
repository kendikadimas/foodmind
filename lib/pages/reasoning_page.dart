import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../theme.dart';
import '../services/openai_service.dart';
import 'result_page.dart';

class ReasoningPage extends ConsumerStatefulWidget {
  final String taste;
  final String style;
  final String weather;
  final Position? position;
  final String allergies;
  final String likes;
  final String budget;
  final String healthConditions;

  const ReasoningPage({
    super.key,
    required this.taste,
    required this.style,
    required this.weather,
    this.position,
    required this.allergies,
    required this.likes,
    this.budget = '',
    this.healthConditions = '',
  });

  @override
  ConsumerState<ReasoningPage> createState() => _ReasoningPageState();
}

class _ReasoningPageState extends ConsumerState<ReasoningPage> {
  late Future<Map<String, dynamic>> _foodRecommendation;

  @override
  void initState() {
    super.initState();
    _foodRecommendation = OpenAIService.getFoodRecommendation(
      taste: widget.taste,
      style: widget.style,
      weather: widget.weather,
      position: widget.position,
      allergies: widget.allergies + (widget.healthConditions.isNotEmpty ? '. Kondisi kesehatan: ${widget.healthConditions}' : ''),
      likes: widget.likes + (widget.budget.isNotEmpty ? '. Budget: Rp ${widget.budget}' : ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Sedang Berpikir...'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        foregroundColor: AppTheme.black,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _foodRecommendation,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            if (data['success'] == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultPage(
                        foodData: data['data'],
                        locationInfo: data['location_data'] as Map<String, dynamic>?,
                      ),
                    ),
                  );
                }
              });
              return _buildLoadingState();
            } else {
              return _buildErrorState(data['error'] ?? 'Unknown error');
            }
          }
          return _buildErrorState('No data received');
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading circle
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryOrange.withOpacity(0.3),
                      ),
                      strokeWidth: 4,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryOrange,
                      ),
                      strokeWidth: 4,
                    ),
                  ),
                  const Text(
                    '🤖',
                    style: TextStyle(fontSize: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Sedang Mencari Rekomendasi...',
              style: AppTheme.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'AI sedang menganalisis preferensi Anda',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferensi Anda:',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 12),
                  _buildPreferenceRow('Rasa', widget.taste),
                  const SizedBox(height: 8),
                  _buildPreferenceRow('Gaya', widget.style),
                  const SizedBox(height: 8),
                  _buildPreferenceRow('Cuaca', widget.weather),
                  if (widget.position != null) ...[
                    const SizedBox(height: 8),
                    _buildPreferenceRow('Lokasi', 'Aktif'),
                  ],
                  if (widget.allergies.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildPreferenceRow('Alergi', widget.allergies),
                  ],
                  if (widget.likes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildPreferenceRow('Suka', widget.likes),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    // Deteksi apakah error adalah API key issue
    final isApiKeyIssue = error.contains('403') || 
                         error.contains('Forbidden') || 
                         error.contains('API key') ||
                         error.contains('dikonfigurasi');
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isApiKeyIssue ? Icons.vpn_key_off : Icons.error_outline,
              size: 64,
              color: AppTheme.primaryOrange,
            ),
            const SizedBox(height: 24),
            Text(
              isApiKeyIssue ? '🔑 API Key Issue' : 'Terjadi Kesalahan',
              style: AppTheme.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.3),
                ),
              ),
              child: Text(
                error,
                style: AppTheme.bodySmall.copyWith(height: 1.5),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mediumGray,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Kembali',
                    style: AppTheme.buttonText,
                  ),
                ),
                if (isApiKeyIssue) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open browser to get API key (optional)
                      // launch('https://aistudio.google.com/apikey');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Buka https://aistudio.google.com/apikey di browser\n'
                            'Lalu update dart-defines.json',
                          ),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_browser, size: 20),
                    label: const Text('Get API Key'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
