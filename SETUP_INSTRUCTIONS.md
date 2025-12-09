# Setup Instruksi untuk FoodMind App

## 📝 Fitur Baru yang Telah Ditambahkan:

### 1. ✅ **Input Budget**
- Pengguna bisa memasukkan budget makan harian
- Rekomendasi akan disesuaikan dengan budget
- Tampil di halaman input sebelum preferensi personal

### 2. ✅ **Profile dengan Login**
- Halaman profile lengkap dengan form data diri
- Menyimpan preferensi alergi dan kondisi kesehatan  
- Status premium user dan usage tracking
- Bottom navigation bar dengan 4 tab: Rekomendasi, Riwayat, Chat AI, Profile

### 3. ✅ **Informasi Nutrisi (Perkiraan)**
- Estimasi kalori, protein, karbohidrat, lemak
- Health score (A, B, C, D) dengan penjelasan
- Tampil di hasil rekomendasi setelah main food card
- Menggunakan algoritma estimasi berdasarkan jenis makanan

### 4. ✅ **Preferensi Kondisi Kesehatan**
- Pilihan kondisi: Diabetes, Hipertensi, Kolesterol, Asam Lambung, Maag, dll
- Filter chip interface yang mudah digunakan
- Otomatis mempengaruhi rekomendasi makanan

### 5. ✅ **Chatbot AI untuk Konsultasi Makanan (Gemini API)**
- 24/7 AI assistant untuk pertanyaan kuliner
- Rate limiting: Free users (5 chat/hari), Premium users (unlimited)  
- Quick responses untuk pertanyaan umum
- Konteks berdasarkan profil user (alergi, kondisi kesehatan, budget)

### 6. ✅ **Refresh Rekomendasi**
- Tombol refresh di AppBar hasil rekomendasi
- Mendapatkan rekomendasi alternatif jika tidak cocok
- Loading indicator saat memuat rekomendasi baru

## 🔧 Setup yang Dibutuhkan:

### 1. Gemini API Key
File: `lib/services/gemini_chat_service.dart`
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; // GANTI INI!
```

**Cara mendapatkan Gemini API Key:**
1. Buka [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Login dengan Google Account
3. Klik "Create API Key"  
4. Copy API key dan paste ke file di atas

### 2. Dependencies Tambahan
Sudah ditambahkan di pubspec.yaml:
- geolocator (dipindah ke dependencies)
- Semua package lain sudah tersedia

### 3. Hive Database Setup
Otomatis diinisialisasi di main.dart:
- FoodHistory untuk riwayat makanan
- UserProfile untuk data profil user

## 🚀 Cara Testing:

### 1. **Test Input Budget & Health**
- Buka tab "Rekomendasi"
- Isi budget (contoh: 25000)
- Pilih kondisi kesehatan
- Lanjut dengan preferensi lainnya

### 2. **Test Profile**  
- Buka tab "Profile"
- Isi data lengkap (nama, email, budget, alergi, kondisi kesehatan)
- Save profile

### 3. **Test Chat AI**
- Buka tab "Chat AI"  
- Tanyakan: "Rekomendasi makanan sehat"
- Tanyakan: "Makanan untuk diabetes"
- Cek limit usage (5x untuk free user)

### 4. **Test Refresh Rekomendasi**
- Dapatkan rekomendasi makanan
- Klik tombol refresh di kanan atas
- Lihat rekomendasi baru

### 5. **Test Nutrisi Info**
- Lihat hasil rekomendasi
- Scroll ke bawah setelah main food card  
- Cek informasi nutrisi dan health score

## 📱 Navigasi Aplikasi:

```
Bottom Navigation:
├── 🔍 Rekomendasi (Input + Budget + Health)
├── 📜 Riwayat (History existing)  
├── 🤖 Chat AI (Gemini chatbot)
└── 👤 Profile (Login + Preferences)
```

## ⚠️ Catatan Penting:

1. **API Key Gemini**: Wajib diganti untuk chat AI berfungsi
2. **Rate Limiting**: Chat dibatasi 5x/hari untuk free user
3. **Data Persistence**: Semua data tersimpan lokal dengan Hive
4. **Offline Mode**: Nutrisi dan quick responses tetap bisa diakses offline
5. **Responsiveness**: UI dioptimalkan untuk mobile dan web

## 🔄 Status Implementasi:

- ✅ Input Budget: **SELESAI**  
- ✅ Profile Login: **SELESAI**
- ✅ Nutrisi Info: **SELESAI**
- ✅ Health Preferences: **SELESAI**  
- ✅ Chatbot AI: **SELESAI** (perlu API key)
- ✅ Refresh Feature: **SELESAI**

**Total Progress: 100% COMPLETE** 🎉

Semua fitur telah berhasil diimplementasikan dan siap untuk testing!