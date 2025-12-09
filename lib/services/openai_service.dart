import 'dart:convert';
import 'dart:async';
import 'dart:collection';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import '../models/food_history.dart';

/// Rate limiter untuk handle pembatasan request API
class RateLimiter {
  final int maxRequests;
  final Duration timeWindow;
  final Queue<DateTime> _requestTimes = Queue();

  RateLimiter({
    required this.maxRequests,
    required this.timeWindow,
  });

  /// Check apakah request diizinkan
  bool canMakeRequest() {
    final now = DateTime.now();
    
    // Hapus request yang sudah di luar time window
    while (_requestTimes.isNotEmpty && 
           now.difference(_requestTimes.first).inMilliseconds > timeWindow.inMilliseconds) {
      _requestTimes.removeFirst();
    }
    
    // Jika belum mencapai limit, izinkan request
    if (_requestTimes.length < maxRequests) {
      _requestTimes.addLast(now);
      return true;
    }
    
    return false;
  }

  /// Hitung sisa waktu sebelum dapat request baru (dalam detik)
  int getWaitTimeSeconds() {
    if (_requestTimes.isEmpty) return 0;
    
    final oldestRequest = _requestTimes.first;
    final now = DateTime.now();
    final elapsed = now.difference(oldestRequest).inMilliseconds;
    final waitTime = (timeWindow.inMilliseconds - elapsed) ~/ 1000;
    
    return waitTime > 0 ? waitTime : 0;
  }
}

/// Service untuk AI Food Recommendation dengan rate limiting
class OpenAIService {
  // ⚠️ PENTING: Ganti API key Anda dari https://ai.google.dev/
  // 1. Buka https://ai.google.dev/
  // 2. Klik "Get API Key" → "Create API key"
  // 3. Copy API key dan paste di bawah ini
  static const String geminiApiKey = 'AIzaSyCVIw79wyi8_iNKvc3s0ofMBdNqy8Kd8cE'; // 👈 GANTI DENGAN API KEY ANDA

  // ✅ SERVICE API KEY dari Foursquare (untuk Places API baru)
  static const String foursquareApiKey = 'LVPO2Z2IJKELQ44BTJTZHP5PYETLDMDML44MQDS5KPO0CMKT';
  
  static const String openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  
  // Pilihan AI Provider: 'openai', 'gemini', 'ollama'
  static const String aiProvider = 'gemini'; // Gunakan Gemini (free tier)
  
  // Rate limiter: 3 request per menit (cocok untuk free tier)
  static final RateLimiter _rateLimiter = RateLimiter(
    maxRequests: 3,
    timeWindow: const Duration(minutes: 1),
  );
  
  // Cache untuk menghindari request duplicate
  static final Map<String, Map<String, dynamic>> _cache = {};
  static const int cacheExpiryMinutes = 30;

  /// Mengambil daftar makanan yang sering direkomendasikan dari Hive
  static Future<List<String>> _getFrequentlyEatenFoods() async {
    try {
      final box = await Hive.openBox<FoodHistory>('foodHistory');
      if (box.isEmpty) return [];

      final foodCounts = <String, int>{};
      for (var history in box.values) {
        foodCounts[history.mainFood] = (foodCounts[history.mainFood] ?? 0) + 1;
      }

      // Anggap "sering" jika sudah direkomendasikan lebih dari 2 kali
      final frequentFoods = foodCounts.entries
          .where((entry) => entry.value > 2)
          .map((entry) => entry.key)
          .toList();
      
      return frequentFoods;
    } catch (e) {
      print('Error reading food history: $e');
      return [];
    }
  }

  /// Generate cache key dari parameter
  static String _generateCacheKey(String taste, String style, String weather, Position? position, String allergies, String likes, List<String> frequentFoods) {
    final locationKey = position != null ? '${position.latitude},${position.longitude}' : 'no-location';
    final frequentFoodsKey = frequentFoods.join(',');
    return '$taste|$style|$weather|$locationKey|$allergies|$likes|$frequentFoodsKey';
  }

  /// Check apakah data ada di cache dan masih valid
  static bool _isCacheValid(String cacheKey) {
    if (!_cache.containsKey(cacheKey)) return false;
    
    final cacheData = _cache[cacheKey];
    if (cacheData == null) return false;
    
    final timestamp = cacheData['timestamp'] as DateTime;
    final now = DateTime.now();
    
    return now.difference(timestamp).inMinutes < cacheExpiryMinutes;
  }

  /// Main function untuk mendapatkan rekomendasi makanan
  static Future<Map<String, dynamic>> getFoodRecommendation({
    required String taste,
    required String style,
    required String weather,
    Position? position,
    String allergies = '',
    String likes = '',
    bool useCache = true,
  }) async {
    // Dapatkan daftar makanan yang harus dihindari
    final frequentFoods = await _getFrequentlyEatenFoods();
    final cacheKey = _generateCacheKey(taste, style, weather, position, allergies, likes, frequentFoods);
    
    // Cek cache terlebih dahulu
    if (useCache && _isCacheValid(cacheKey)) {
      return {
        'success': true,
        'data': _cache[cacheKey]!['data'],
        'fromCache': true,
      };
    }

    // Cek rate limit
    if (!_rateLimiter.canMakeRequest()) {
      final waitTime = _rateLimiter.getWaitTimeSeconds();
      return {
        'success': false,
        'error': 'Rate limit exceeded. Please wait ${waitTime}s before next request.',
        'waitTime': waitTime,
        'rateLimited': true,
      };
    }

    try {
      // Dapatkan daftar makanan terdekat jika ada lokasi
      List<String> nearbyFoods = [];
      Map<String, dynamic>? locationData;
      if (position != null) {
        final nearbyData = await _findNearbyFoods(position.latitude, position.longitude);
        nearbyFoods = nearbyData['places'] as List<String>;
        locationData = nearbyData['location_info'] as Map<String, dynamic>;
      }

      final result = switch (aiProvider) {
        'gemini' => await _callGeminiAPI(taste, style, weather, nearbyFoods, allergies, likes, frequentFoods),
        'ollama' => await _callOllamaAPI(taste, style, weather), // Perlu diupdate juga jika mau
        _ => await _callOpenAIAPI(taste, style, weather), // Perlu diupdate juga jika mau
      };

      // Simpan ke cache jika sukses
      if (result['success'] && useCache) {
        _cache[cacheKey] = {
          'data': result['data'],
          'timestamp': DateTime.now(),
        };
      }

      // Tambahkan informasi lokasi ke hasil
      if (locationData != null) {
        result['location_data'] = locationData;
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Error: ${e.toString()}',
      };
    }
  }

  /// Mencari makanan/restoran terdekat menggunakan Foursquare API
  static Future<Map<String, dynamic>> _findNearbyFoods(double latitude, double longitude) async {
    final uri = Uri.parse('https://places-api.foursquare.com/places/search'
        '?ll=$latitude,$longitude'
        '&radius=5000' // Radius 5km
        '&categories=13000' // Kategori Makanan & Restoran
        '&limit=20' // Batasi hingga 20 hasil
        '&fields=name,location'); // Ambil nama dan lokasi

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $foursquareApiKey',
          'accept': 'application/json',
          'X-Places-Api-Version': '2025-06-17',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        final places = results.map((place) => place['name'] as String).toList();
        
        // Buat informasi lokasi yang detail
        final locationInfo = {
          'coordinates': '$latitude, $longitude',
          'radius': '5 km',
          'source': 'Foursquare Places API',
          'total_found': results.length,
          'sample_places': results.take(3).map((place) {
            final name = place['name'] ?? 'Unknown';
            final address = place['location']?['address'] ?? 'Alamat tidak tersedia';
            return '$name ($address)';
          }).toList(),
        };
        
        return {
          'places': places,
          'location_info': locationInfo,
        };
      } else {
        // Gagal fetch data, kembalikan data kosong
        print('Foursquare API Error: ${response.statusCode} - ${response.body}');
        return {
          'places': <String>[],
          'location_info': {
            'coordinates': '$latitude, $longitude',
            'radius': '5 km',
            'source': 'Foursquare Places API',
            'error': 'Gagal mengambil data dari Foursquare (Status: ${response.statusCode})',
            'total_found': 0,
          },
        };
      }
    } catch (e) {
      print('Foursquare Request Error: $e');
      return {
        'places': <String>[],
        'location_info': {
          'coordinates': '$latitude, $longitude',
          'radius': '5 km',
          'source': 'Foursquare Places API',
          'error': 'Error koneksi: $e',
          'total_found': 0,
        },
      };
    }
  }

  /// Call OpenAI API (GPT-4o Mini)
  static Future<Map<String, dynamic>> _callOpenAIAPI(
    String taste,
    String style,
    String weather,
  ) async {
    final prompt = '''Kamu adalah sistem rekomendasi makanan.
Berdasarkan input berikut, berikan output DALAM FORMAT JSON KETAT:

Input:
Rasa: $taste
Gaya: $style
Cuaca: $weather

Format JSON:
{
  "main_food": "",
  "alternatives": [],
  "reasoning": []
}

Jawab hanya JSON saja.''';

    try {
      final response = await http.post(
        Uri.parse(openAIEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $geminiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final jsonResponse = jsonDecode(content);
        
        return {'success': true, 'data': jsonResponse};
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error': 'API rate limit exceeded',
          'rateLimited': true,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['error']['message'] ?? 'Unknown error occurred',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Call Gemini API
  static Future<Map<String, dynamic>> _callGeminiAPI(
    String taste,
    String style,
    String weather,
    List<String> nearbyFoods,
    String allergies,
    String likes,
    List<String> frequentFoods, // Tambahkan parameter
  ) async {
    final nearbyFoodList = nearbyFoods.isNotEmpty
        ? 'Berikut adalah daftar beberapa tempat makan yang ada di sekitar pengguna: ${nearbyFoods.join(', ')}. Utamakan merekomendasikan makanan yang mungkin tersedia dari daftar ini jika relevan.'
        : 'Tidak ada data lokasi, berikan rekomendasi umum.';

    final personalPreferences = '''
Preferensi Personal:
- Alergi atau bahan yang dihindari: ${allergies.isNotEmpty ? allergies : 'Tidak ada'}
- Makanan atau bahan yang disukai: ${likes.isNotEmpty ? likes : 'Tidak ada'}
''';

    final historyAvoidance = frequentFoods.isNotEmpty
        ? 'PENTING: Pengguna sudah terlalu sering makan ini, JANGAN rekomendasikan makanan berikut: ${frequentFoods.join(', ')}.'
        : '';

    final prompt = '''Kamu adalah sistem rekomendasi makanan yang cerdas, personal, dan tidak membosankan.
Berdasarkan input berikut, berikan output DALAM FORMAT JSON YANG KETAT (strict).

Input Pengguna:
- Rasa yang diinginkan: $taste
- Gaya masakan: $style
- Kondisi cuaca saat ini: $weather

$personalPreferences

Informasi Lokasi:
$nearbyFoodList

Aturan Tambahan:
$historyAvoidance

Tugas Kamu:
1. Analisis SEMUA input: preferensi rasa, gaya, cuaca, personal (alergi/suka), lokasi, dan riwayat makanan.
2. **ATURAN #1**: Jangan pernah merekomendasikan makanan yang mengandung bahan dari daftar alergi.
3. **ATURAN #2**: Jika ada, JANGAN merekomendasikan makanan dari daftar "terlalu sering makan".
4. Prioritaskan makanan yang mengandung bahan yang disukai pengguna.
5. Jika ada data lokasi, prioritaskan rekomendasi dari daftar makanan sekitar.
6. Berikan satu rekomendasi makanan utama ("main_food") yang paling sesuai.
7. Berikan beberapa makanan alternatif ("alternatives").
8. Jelaskan alasan ("reasoning") untuk setiap rekomendasi, hubungkan dengan SEMUA input yang relevan.
9. Pastikan output kamu HANYA berupa JSON, tanpa teks atau format lain.

Format JSON yang Diperlukan:
{
  "main_food": "Nama Makanan Utama",
  "alternatives": [
    "Nama Makanan Alternatif 1",
    "Nama Makanan Alternatif 2"
  ],
  "reasoning": [
    "Alasan untuk makanan utama...",
    "Alasan untuk alternatif 1...",
    "Alasan untuk alternatif 2..."
  ],
  "location_match": true/false 
}

Jawab HANYA dengan JSON.''';

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ]
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Membersihkan response dari markdown code block ```json ... ```
        final cleanedText = text.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonResponse = jsonDecode(cleanedText);
        
        return {'success': true, 'data': jsonResponse};
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error': 'API rate limit exceeded',
          'rateLimited': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Gemini API error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Call Ollama API
  static Future<Map<String, dynamic>> _callOllamaAPI(
    String taste,
    String style,
    String weather,
  ) async {
    const ollamaEndpoint = 'http://localhost:11434/api/generate';
    
    final prompt = '''Kamu adalah sistem rekomendasi makanan.
Berdasarkan input berikut, berikan output DALAM FORMAT JSON KETAT:

Input:
Rasa: $taste
Gaya: $style
Cuaca: $weather

Format JSON:
{
  "main_food": "",
  "alternatives": [],
  "reasoning": []
}

Jawab hanya JSON saja.''';

    try {
      final response = await http.post(
        Uri.parse(ollamaEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'mistral', // Atau gunakan 'neural-chat', 'llama2'
          'prompt': prompt,
          'stream': false,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final response_text = data['response'];
        
        // Extract JSON dari response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response_text);
        if (jsonMatch != null) {
          final jsonResponse = jsonDecode(jsonMatch.group(0)!);
          return {'success': true, 'data': jsonResponse};
        }
        
        return {
          'success': false,
          'error': 'Could not parse JSON response from Ollama',
        };
      } else {
        return {
          'success': false,
          'error': 'Ollama API error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ollama not available. Make sure Ollama is running on localhost:11434. Error: $e',
      };
    }
  }

  /// Get rate limit status
  static Map<String, dynamic> getRateLimitStatus() {
    return {
      'canMakeRequest': _rateLimiter.canMakeRequest(),
      'waitTimeSeconds': _rateLimiter.getWaitTimeSeconds(),
    };
  }

  /// Clear cache (opsional)
  static void clearCache() {
    _cache.clear();
  }
}
