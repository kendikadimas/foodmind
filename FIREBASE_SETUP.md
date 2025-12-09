# Firebase Setup untuk FoodMind

## Langkah Setup Firebase Authentication

### 1. Buat Project Firebase
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add project" atau "Tambah project"
3. Beri nama project: `foodmind-app` (atau nama lainnya)
4. Ikuti wizard setup sampai selesai

### 2. Enable Authentication
1. Di Firebase Console, pilih project Anda
2. Klik "Authentication" di menu kiri
3. Klik tab "Sign-in method"
4. Enable metode berikut:
   - **Email/Password**: Klik, enable, lalu Save
   - **Google**: Klik, enable, isi support email, lalu Save

### 3. Register Web App
1. Di Project Overview, klik icon Web (</>) untuk menambahkan web app
2. Beri nama app: `FoodMind Web`
3. Centang "Also set up Firebase Hosting" (optional)
4. Klik "Register app"
5. Copy konfigurasi Firebase yang muncul

### 4. Update firebase_options.dart
Buka file `lib/firebase_options.dart` dan replace bagian `web` dengan konfigurasi Anda:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_HERE',
  appId: 'YOUR_APP_ID_HERE',
  messagingSenderId: 'YOUR_SENDER_ID_HERE',
  projectId: 'YOUR_PROJECT_ID_HERE',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

### 5. Setup Google Sign-In (Web)
1. Di Firebase Console, klik "Authentication" → "Sign-in method" → "Google"
2. Copy "Web client ID" yang ditampilkan
3. Jika perlu konfigurasi OAuth consent screen di Google Cloud Console

### 6. (Optional) Setup untuk Android
1. Di Firebase Console, klik icon Android untuk menambahkan Android app
2. Masukkan package name: `com.example.foodmind` (atau sesuai package Anda)
3. Download file `google-services.json`
4. Taruh file di folder `android/app/`
5. Update `firebase_options.dart` dengan konfigurasi Android

### 7. (Optional) Setup untuk iOS
1. Di Firebase Console, klik icon iOS untuk menambahkan iOS app
2. Masukkan bundle ID
3. Download file `GoogleService-Info.plist`
4. Taruh file di folder `ios/Runner/`
5. Update `firebase_options.dart` dengan konfigurasi iOS

## Testing Authentication

### Test di Chrome (Web)
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Cara Test:
1. Buka aplikasi, klik "Mulai Sekarang" di landing page
2. Di halaman login, pilih:
   - **Login** (jika sudah punya akun) atau **Daftar** (untuk buat akun baru)
3. Isi form:
   - Email: test@example.com
   - Password: minimal 6 karakter
   - Nama: (hanya untuk daftar)
4. Klik tombol "Masuk" atau "Daftar"
5. Atau klik "Lanjutkan dengan Google" untuk Google Sign-In

## Troubleshooting

### Error: "No Firebase App has been created"
- Pastikan `Firebase.initializeApp()` dipanggil di `main()` sebelum `runApp()`
- Pastikan `firebase_options.dart` sudah di-import

### Error Google Sign-In tidak muncul popup
- Untuk web, pastikan origin `http://localhost` sudah ditambahkan di Firebase Console → Authentication → Settings → Authorized domains

### Error: "API key not valid"
- Pastikan API key di `firebase_options.dart` sudah benar
- Copy ulang dari Firebase Console jika perlu

### Error: "Email already in use"
- Email sudah terdaftar, gunakan mode Login bukan Daftar
- Atau gunakan email lain untuk testing

## Security Rules (Production)

Setelah development, jangan lupa setup Firestore/Storage security rules di Firebase Console untuk melindungi data user.

## Fitur Authentication yang Tersedia

✅ Daftar dengan Email & Password
✅ Login dengan Email & Password  
✅ Login dengan Google (OAuth)
✅ Logout
✅ Password visibility toggle
✅ Form validation
✅ Error handling dengan pesan Indonesia
✅ Integrasi dengan Hive untuk local storage
✅ Auto-redirect setelah login sukses

## Files yang Dimodifikasi

- `lib/services/auth_service.dart` - Service layer untuk Firebase Auth
- `lib/pages/login_page.dart` - UI halaman login/register
- `lib/pages/profile_page.dart` - Logout functionality
- `lib/main.dart` - Firebase initialization
- `lib/firebase_options.dart` - Firebase configuration
- `pubspec.yaml` - Dependencies added

## Notes

- Password minimal 6 karakter (requirement Firebase)
- Email harus valid format
- Google Sign-In memerlukan setup OAuth consent screen
- User profile disimpan di Hive setelah login berhasil
- Logout akan clear Firebase session dan Hive data
