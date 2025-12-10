# 🍽️ FoodMind - AI Food Recommendation App

**Tagline:** "Udah Laper? Bingung Mau Makan Apa? Tenang aja! Kita bantu cari makanan yang cocok sama selera kamu kok~"

AI-powered food recommendation system yang membantu kamu memilih makanan berdasarkan preferensi, budget, kondisi kesehatan, dan lokasi.

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Setup Gemini API Key (PENTING!)

**⚠️ Error 403 Forbidden? API key belum dikonfigurasi!**

1. Buka https://aistudio.google.com/apikey
2. Create API key baru (FREE)
3. Copy API key
4. Update file `dart-defines.json`:
```json
{
  "SUPABASE_URL": "https://yzlemkwmqzatcawvslyf.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "GEMINI_API_KEY": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}
```
5. Restart aplikasi

📖 **Panduan lengkap:** [GEMINI_API_SETUP.md](GEMINI_API_SETUP.md)

### 3. Setup Supabase (Optional - untuk Auth & Database)

Lihat panduan: [SUPABASE_SETUP.md](SUPABASE_SETUP.md)

### 4. Run App
```bash
flutter run -d chrome --dart-define-from-file=dart-defines.json
```

Atau gunakan VS Code launch configuration (F5)

---

## ✨ Features

- 🤖 **AI Food Recommendation** - Powered by Google Gemini
- 🔐 **Authentication** - Email/Password + Google OAuth via Supabase
- 📍 **Location-Based** - GPS + Google Maps integration
- 💰 **Budget-Aware** - Rekomendasi sesuai budget
- 🏥 **Health-Conscious** - Pertimbangan alergi & kondisi kesehatan
- 👥 **Community Feed** - Share & like rekomendasi makanan
- 📊 **History Tracking** - Riwayat makanan favorit

---

## 🛠️ Tech Stack

- **Frontend:** Flutter 3.x
- **Backend:** Supabase (PostgreSQL + Auth)
- **AI:** Google Gemini API (gemini-2.5-flash)
- **Maps:** Google Maps API + Geolocator
- **Local Storage:** Hive
- **State Management:** StatefulWidget

---

## 📁 Project Structure

```
lib/
├── main.dart                 # Entry point
├── theme.dart               # App theme
├── models/                  # Data models
│   ├── food_history.dart
│   └── food_history.g.dart
├── pages/                   # UI screens
│   ├── landing_page.dart
│   ├── login_page.dart
│   ├── onboarding_page.dart
│   ├── input_page.dart
│   ├── reasoning_page.dart
│   ├── result_page.dart
│   ├── community_page.dart
│   └── profile_page.dart
├── services/                # Business logic
│   ├── supabase_service.dart
│   ├── auth_service.dart
│   ├── openai_service.dart
│   ├── user_database_service.dart
│   └── post_database_service.dart
└── widgets/                 # Reusable components
    └── bubble_tag.dart
```

---

## 🔧 Troubleshooting

### ❌ Error 403 Forbidden saat mencari rekomendasi?

**Penyebab:** Gemini API key tidak valid/expired

**Solusi:**
1. Buka https://aistudio.google.com/apikey
2. Create API key baru
3. Update `dart-defines.json`
4. Restart app

📖 Lihat: [GEMINI_API_SETUP.md](GEMINI_API_SETUP.md)

### ❌ Error Supabase Connection?

**Penyebab:** Supabase project belum disetup

**Solusi:**
1. Create project di https://supabase.com
2. Run SQL migrations (lihat SUPABASE_SETUP.md)
3. Update credentials di `dart-defines.json`

### ❌ Overflow error di Onboarding Page?

**Sudah diperbaiki!** Pull latest code.

---

## 📚 Documentation

- **Setup Supabase:** [SUPABASE_SETUP.md](SUPABASE_SETUP.md)
- **Setup Gemini API:** [GEMINI_API_SETUP.md](GEMINI_API_SETUP.md)
- **Presentation Slides:** [PRESENTATION_SLIDES.md](PRESENTATION_SLIDES.md)

---

## 🔐 Security

- ✅ Environment variables (`dart-defines.json`)
- ✅ Row Level Security (RLS) di Supabase
- ✅ OAuth 2.0 authentication
- ✅ API key tidak di-commit ke Git

**⚠️ JANGAN commit file `dart-defines.json` ke Git!**

---

## 🚦 Development

### Run in Debug Mode
```bash
flutter run -d chrome --dart-define-from-file=dart-defines.json --web-browser-flag=--disable-web-security
```

### Build for Production
```bash
flutter build web --dart-define-from-file=dart-defines.json
```

### Build Android APK
```bash
flutter build apk --dart-define-from-file=dart-defines.json
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

---

## 👨‍💻 Developer

**GitHub:** [@kendikadimas](https://github.com/kendikadimas)

**Repository:** [github.com/kendikadimas/foodmind](https://github.com/kendikadimas/foodmind)

---

## 🆘 Support

- **Issues:** https://github.com/kendikadimas/foodmind/issues
- **Discussions:** https://github.com/kendikadimas/foodmind/discussions

---

**Last Updated:** December 10, 2025
