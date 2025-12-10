# Cara Mendapatkan Gemini API Key Baru

## ❌ Masalah: 403 Forbidden Error

Jika Anda mendapat error `403 Forbidden` saat mencari rekomendasi makanan, artinya:
- API key Gemini sudah expired/revoked
- API key tidak valid
- API key tidak memiliki akses ke model Gemini

## ✅ Solusi: Buat API Key Baru

### Langkah 1: Buka Google AI Studio
1. Buka browser, kunjungi: **https://aistudio.google.com/apikey**
2. Login dengan akun Google Anda

### Langkah 2: Create API Key
1. Klik tombol **"Create API key"** atau **"Get API key"**
2. Pilih salah satu opsi:
   - **Create API key in new project** (Recommended untuk project baru)
   - **Create API key in existing project** (Jika sudah ada project)
3. Tunggu beberapa detik sampai API key ter-generate

### Langkah 3: Copy API Key
1. API key akan muncul seperti: `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
2. Klik tombol **Copy** atau manual select dan copy
3. **JANGAN share API key ke siapapun!**

### Langkah 4: Update di FoodMind App

#### **Opsi A: Via Environment Variable (Recommended - Lebih Aman)**

1. Buka file `dart-defines.json` di root project
2. Ganti `YOUR_NEW_GEMINI_API_KEY_HERE` dengan API key baru Anda:

```json
{
  "SUPABASE_URL": "https://yzlemkwmqzatcawvslyf.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "GEMINI_API_KEY": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}
```

3. Save file
4. Restart aplikasi (Stop + Run lagi di VS Code)

#### **Opsi B: Hardcode di Source Code (Tidak Recommended - Testing Only)**

1. Buka file `lib/services/openai_service.dart`
2. Cari baris:
```dart
static const String geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);
```

3. Ganti dengan:
```dart
static const String geminiApiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // 👈 Paste API key Anda
```

4. Save dan hot reload

⚠️ **WARNING:** Jangan commit file ini ke Git jika pakai Opsi B!

### Langkah 5: Test Aplikasi
1. Restart aplikasi
2. Buka Input Page
3. Isi preferensi makanan
4. Klik "Cari Makanannya Dong!"
5. Harusnya sekarang berhasil tanpa error 403

---

## 🔒 Keamanan API Key

### ✅ DO's (Yang Harus Dilakukan):
- ✅ Gunakan environment variable (`dart-defines.json`)
- ✅ Tambahkan `dart-defines.json` ke `.gitignore`
- ✅ Regenerate API key jika terlanjur ter-commit
- ✅ Set API restrictions di Google Cloud Console

### ❌ DON'Ts (Yang JANGAN Dilakukan):
- ❌ Hardcode API key langsung di source code
- ❌ Commit API key ke Git/GitHub
- ❌ Share API key di public forum/chat
- ❌ Gunakan API key di production tanpa restrictions

---

## 🔧 Troubleshooting

### Error Masih 403 Setelah Ganti API Key?

**Cek 1: API Key Format**
- Harus dimulai dengan `AIza`
- Panjang sekitar 39 karakter
- Tidak ada spasi atau karakter aneh

**Cek 2: API Enabled**
1. Buka https://console.cloud.google.com/apis/
2. Pastikan **"Generative Language API"** sudah enabled
3. Jika belum, klik Enable

**Cek 3: Quota/Limit**
1. Buka https://aistudio.google.com/apikey
2. Cek usage/quota API key Anda
3. Free tier Gemini: **60 requests per minute**

**Cek 4: Model Access**
- Pastikan API key punya akses ke model `gemini-2.5-flash`
- Jika tidak, coba ganti model di `openai_service.dart` ke `gemini-1.5-flash`

```dart
final url = Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey'
);
```

### Error 429 (Rate Limit)?

Berarti terlalu banyak request. Solusi:
- Tunggu 1 menit
- App sudah ada rate limiter: 3 request/menit
- Upgrade ke paid tier jika perlu unlimited

### Error 400 (Bad Request)?

Berarti ada masalah di request body/prompt. Solusi:
- Cek input tidak mengandung karakter aneh
- Cek panjang prompt tidak terlalu panjang (max 8K tokens)

---

## 📊 Gemini API Limits (Free Tier)

| Feature | Limit |
|---------|-------|
| Requests per minute (RPM) | 60 |
| Requests per day (RPD) | 1,500 |
| Tokens per minute (TPM) | 32,000 |
| Model | gemini-1.5-flash, gemini-2.0-flash-exp |
| Cost | **FREE** |

**Paid Tier (Pay-as-you-go):**
- RPM: Unlimited
- Cost: $0.075 per 1M input tokens
- $0.30 per 1M output tokens

---

## 🆘 Butuh Bantuan?

**Google AI Studio Documentation:**
- https://ai.google.dev/gemini-api/docs

**Gemini API Pricing:**
- https://ai.google.dev/pricing

**Support:**
- Stack Overflow: Tag `google-gemini-api`
- GitHub Issues: https://github.com/kendikadimas/foodmind/issues

---

**Last Updated:** December 10, 2025
