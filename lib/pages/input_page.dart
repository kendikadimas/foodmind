import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../theme.dart';
import '../widgets/bubble_tag.dart';

class InputPage extends ConsumerStatefulWidget {
  const InputPage({super.key});

  @override
  ConsumerState<InputPage> createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<InputPage> {
  final List<String> tasteTags = ['Asin', 'Pedas', 'Manis', 'Gurih', 'Segar', 'Bingung'];
  final List<String> styleTags = ['Berkuah', 'Kering', 'Pakai Nasi', 'Bingung'];
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
  final TextEditingController _budgetController = TextEditingController();

  // State untuk fitur lokasi
  bool _useLocation = false;
  bool _isGettingLocation = false;
  Position? _currentPosition;
  String _locationMessage = 'Aktifkan untuk rekomendasi sekitar';
  String? _locationName;

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
      
      // Reverse geocoding untuk mendapatkan nama lokasi
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String locationName = '';
          
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            locationName = place.subLocality!;
          } else if (place.locality != null && place.locality!.isNotEmpty) {
            locationName = place.locality!;
          }
          
          if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
            locationName += ', ${place.subAdministrativeArea}';
          } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            locationName += ', ${place.administrativeArea}';
          }
          
          setState(() {
            _currentPosition = position;
            _isGettingLocation = false;
            _locationName = locationName.isNotEmpty ? locationName : null;
            _locationMessage = _locationName ?? 'Lokasi ditemukan';
          });
        } else {
          setState(() {
            _currentPosition = position;
            _isGettingLocation = false;
            _locationName = null;
            _locationMessage = 'Lokasi ditemukan';
          });
        }
      } catch (e) {
        setState(() {
          _currentPosition = position;
          _isGettingLocation = false;
          _locationName = null;
          _locationMessage = 'Lokasi ditemukan';
        });
      }

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
        title: const Text('Mau Makan Apa Nih?'),
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
              'Lagi Pengen Rasa Apa? 😋',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Pilih aja yang kamu pengen, boleh lebih dari satu kok!',
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
              'Vibes Makannya Gimana? 🍴',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Mau santai atau formal? Pilih yang sesuai mood!',
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

            // Budget Section
            Text(
              'Budget Makan',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan budget untuk rekomendasi yang sesuai',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(
                labelText: 'Budget (Rp)',
                prefixText: 'Rp ',
                hintText: 'Contoh: 25000',
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
            const SizedBox(height: 8),
            Text(
              'Rekomendasi dalam radius 10 km dari lokasimu',
              style: AppTheme.bodySmall,
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
                    child: Row(
                      children: [
                        if (_isGettingLocation)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            _locationMessage,
                            style: AppTheme.bodySmall.copyWith(
                              color: _useLocation ? AppTheme.black : AppTheme.darkGray,
                            ),
                          ),
                        ),
                      ],
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
                          _locationName = null;
                          _locationMessage = 'Aktifkan untuk rekomendasi sekitar';
                        }
                      });
                    },
                    activeThumbColor: AppTheme.primaryOrange,
                  ),
                ],
              ),
            ),
            if (_useLocation && _locationName != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppTheme.primaryOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationName!,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            'taste': selectedTastes.join(', '),
                            'style': selectedStyles.join(', '),
                            'weather': selectedWeather,
                            'position': _currentPosition,
                            'locationName': _locationName,
                            'maxDistance': 10.0, // 10 km radius
                            'allergies': _allergiesController.text,
                            'likes': _likesController.text,
                            'budget': _budgetController.text,
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
                  'Cari Makanannya Dong!',
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
