import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme.dart';
import '../widgets/bubble_tag.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final List<String> tasteTags = ['Asin', 'Pedas', 'Manis', 'Gurih', 'Segar'];
  final List<String> styleTags = ['Berkuah', 'Kering', 'Pakai Nasi'];
  final List<String> weatherOptions = [
    'Cerah',
    'Mendung',
    'Hujan',
    'Panas Terik',
    'Dingin'
  ];

  Set<String> selectedTastes = {};
  Set<String> selectedStyles = {};
  String? selectedWeather;

  // Controller untuk preferensi personal
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _likesController = TextEditingController();

  // State untuk fitur lokasi
  bool _useLocation = false;
  bool _isGettingLocation = false;
  Position? _currentPosition;
  String _locationMessage = 'Aktifkan untuk rekomendasi sekitar';

  /// Meminta izin dan mendapatkan lokasi pengguna
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationMessage = 'Mencari lokasi...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isGettingLocation = false;
            _useLocation = false; // Matikan switch jika izin ditolak
            _locationMessage = 'Izin lokasi ditolak.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isGettingLocation = false;
          _useLocation = false;
          _locationMessage = 'Izin lokasi diblokir permanen.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
        _locationMessage = 'Lokasi ditemukan!';
      });

    } catch (e) {
      setState(() {
        _isGettingLocation = false;
        _useLocation = false;
        _locationMessage = 'Gagal mendapatkan lokasi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Cari Rekomendasi'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        foregroundColor: AppTheme.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rasa
            Text(
              'Rasa Pilihan',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Pilih satu atau lebih rasa yang kamu inginkan',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: tasteTags.map((taste) {
                return BubbleTag(
                  label: taste,
                  initialSelected: selectedTastes.contains(taste),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedTastes.add(taste);
                      } else {
                        selectedTastes.remove(taste);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Gaya
            Text(
              'Gaya Makan',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Pilih satu atau lebih gaya makan',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: styleTags.map((style) {
                return BubbleTag(
                  label: style,
                  initialSelected: selectedStyles.contains(style),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedStyles.add(style);
                      } else {
                        selectedStyles.remove(style);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Cuaca
            Text(
              'Cuaca Saat Ini',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Pilih kondisi cuaca untuk rekomendasi yang lebih akurat',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryOrange, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedWeather,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Pilih cuaca...'),
                  ),
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.arrow_drop_down,
                        color: AppTheme.primaryOrange),
                  ),
                  items: weatherOptions.map((weather) {
                    return DropdownMenuItem(
                      value: weather,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(weather),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedWeather = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Preferensi Personal (Alergi & Kesukaan)
            Text(
              'Preferensi Personal',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Beri tahu kami makanan/bahan yang harus dihindari atau yang kamu sukai.',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            // Input Alergi
            TextField(
              controller: _allergiesController,
              decoration: InputDecoration(
                labelText: 'Alergi (opsional)',
                hintText: 'Contoh: udang, kacang, susu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Input Kesukaan
            TextField(
              controller: _likesController,
              decoration: InputDecoration(
                labelText: 'Makanan/Bahan Favorit (opsional)',
                hintText: 'Contoh: ayam, keju, bawang putih',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Lokasi
            Text(
              'Gunakan Lokasi Terkini',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryOrange, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _locationMessage,
                      style: AppTheme.bodySmall.copyWith(
                        color: _useLocation ? AppTheme.black : AppTheme.darkGray,
                      ),
                    ),
                  ),
                  Switch(
                    value: _useLocation,
                    onChanged: (value) {
                      setState(() {
                        _useLocation = value;
                        if (_useLocation) {
                          _getCurrentLocation();
                        } else {
                          _currentPosition = null;
                          _locationMessage = 'Aktifkan untuk rekomendasi sekitar';
                        }
                      });
                    },
                    activeColor: AppTheme.primaryOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit()
                    ? () {
                        Navigator.pushNamed(
                          context,
                          '/reasoning',
                          arguments: {
                            'taste':
                                selectedTastes.join(', '),
                            'style':
                                selectedStyles.join(', '),
                            'weather': selectedWeather,
                            'position': _currentPosition, // Kirim data posisi
                            'allergies': _allergiesController.text,
                            'likes': _likesController.text,
                          },
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSubmit()
                      ? AppTheme.primaryOrange
                      : AppTheme.mediumGray,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cari Rekomendasi',
                  style: AppTheme.buttonText,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _likesController.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    return selectedTastes.isNotEmpty &&
        selectedStyles.isNotEmpty &&
        selectedWeather != null;
  }
}
