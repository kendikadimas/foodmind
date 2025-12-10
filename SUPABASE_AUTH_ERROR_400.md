# Troubleshooting: Error 400 Bad Request saat Register

## ❌ Masalah

Saat mencoba register user baru, muncul error:
```
POST https://yzlemkwmqzatcawvslyf.supabase.co/auth/v1/signup? 400 (Bad Request)
```

Error message: **"Invalid email"** atau **"Unable to validate email address"**

---

## 🔍 Penyebab Umum

### 1. **Email Provider Belum Diaktifkan di Supabase**

**Ini penyebab paling umum!**

Supabase secara default **DISABLE** email/password authentication untuk keamanan.

### 2. **Format Email Tidak Valid**

- Email mengandung karakter khusus yang tidak diizinkan
- Email terlalu pendek/panjang
- Tidak ada @ atau domain

### 3. **Confirm Email Setting di Supabase**

Jika "Confirm Email" enabled, user harus konfirmasi email dulu sebelum bisa login.

### 4. **Rate Limiting**

Terlalu banyak percobaan dalam waktu singkat.

---

## ✅ Solusi

### **Solusi 1: Enable Email Provider di Supabase (PALING PENTING!)**

1. **Buka Supabase Dashboard:** https://supabase.com/dashboard

2. **Pilih project:** `foodmind` atau project Anda

3. **Klik menu Authentication** (sidebar kiri)

4. **Klik tab "Providers"**

5. **Cari "Email"** di list providers

6. **ENABLE Email Provider:**
   - Toggle switch **"Enable Email Provider"** → **ON** (hijau)
   - **Confirm email:** 
     - ✅ **Disable** (untuk testing) → User bisa langsung login
     - ⚠️ **Enable** (untuk production) → User harus konfirmasi email
   - **Secure email change:** Enable (recommended)
   - **Secure password change:** Enable (recommended)

7. **Klik "Save"**

8. **Restart aplikasi** Flutter Anda

---

### **Solusi 2: Cek Email Confirmation Settings**

Jika "Confirm Email" **enabled**, Supabase akan kirim email konfirmasi ke user.

**Untuk Development/Testing:**
- **Disable "Confirm email"** di Supabase → Authentication → Providers → Email
- User bisa langsung login tanpa konfirmasi

**Untuk Production:**
- **Enable "Confirm email"**
- Setup email template di Supabase
- Configure SMTP (optional, default menggunakan Supabase email)

---

### **Solusi 3: Setup Redirect URLs (Jika Pakai Email Confirmation)**

1. **Buka Supabase Dashboard** → Authentication → **URL Configuration**

2. **Site URL:** `http://localhost:3000` (untuk development)

3. **Redirect URLs:** Tambahkan:
   ```
   http://localhost:3000/**
   http://localhost:*/**
   com.foodmind://**
   https://yourdomain.com/**
   ```

4. **Save**

---

### **Solusi 4: Validasi Format Email (Sudah Diperbaiki di Code)**

Code sudah diupdate dengan validasi email yang lebih ketat:

```dart
// lib/services/auth_service.dart
bool _isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  return emailRegex.hasMatch(email) && 
         email.length >= 5 && 
         email.length <= 100;
}
```

**Email yang valid:**
- ✅ `user@example.com`
- ✅ `test.user+tag@domain.co.id`
- ✅ `name_123@gmail.com`

**Email yang TIDAK valid:**
- ❌ `user@` (tidak ada domain)
- ❌ `@example.com` (tidak ada username)
- ❌ `user@domain` (tidak ada TLD)
- ❌ `user @example.com` (ada spasi)

---

### **Solusi 5: Test dengan Email Asli (Bukan Temporary Email)**

Supabase mungkin block temporary/disposable email providers seperti:
- ❌ `temp-mail.org`
- ❌ `10minutemail.com`
- ❌ `guerrillamail.com`

**Gunakan email asli:**
- ✅ Gmail
- ✅ Yahoo
- ✅ Outlook
- ✅ Email institusi

---

## 🧪 Testing

### **Test 1: Cek Apakah Email Provider Enabled**

1. Buka Supabase Dashboard
2. Authentication → Providers
3. Pastikan **Email toggle = ON (hijau)**

### **Test 2: Test Register dengan Valid Email**

Gunakan format email yang jelas valid:
```
Email: test123@gmail.com
Password: password123
Name: Test User
```

### **Test 3: Cek Console Log**

Setelah code diupdate, console akan menampilkan:
```
🔐 Attempting signup with:
  Email: test123@gmail.com
  Name: Test User
  Password length: 11
✅ Signup response: User ID = ...
```

Atau error message yang lebih jelas.

### **Test 4: Cek Supabase Dashboard**

Setelah register berhasil:
1. Supabase Dashboard → Authentication → **Users**
2. User baru harus muncul di list
3. Cek status: **Confirmed** atau **Unconfirmed**

---

## 🔧 Debugging

### **Check 1: Lihat Network Tab di Browser DevTools**

1. Buka DevTools (F12)
2. Tab **Network**
3. Cari request: `POST /auth/v1/signup`
4. Klik request → **Payload** → Lihat data yang dikirim
5. **Response** → Lihat error message detail

**Contoh payload yang benar:**
```json
{
  "email": "test@gmail.com",
  "password": "password123",
  "data": {
    "name": "Test User"
  }
}
```

**Contoh error response:**
```json
{
  "error": "Unable to validate email address: invalid format",
  "error_description": "..."
}
```

### **Check 2: Test Direct API Call**

Test langsung ke Supabase API dengan curl:

```bash
curl -X POST 'https://yzlemkwmqzatcawvslyf.supabase.co/auth/v1/signup' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@gmail.com",
    "password": "password123",
    "data": {"name": "Test"}
  }'
```

Jika ini juga error 400, berarti masalah di **Supabase configuration**, bukan di Flutter code.

---

## 📋 Checklist Solusi

Ikuti checklist ini step-by-step:

- [ ] **1. Enable Email Provider di Supabase** (Authentication → Providers → Email → ON)
- [ ] **2. Disable "Confirm Email"** untuk testing (bisa enable lagi nanti)
- [ ] **3. Restart Flutter app** (Stop + Run lagi)
- [ ] **4. Test register dengan email valid** (format: nama@gmail.com)
- [ ] **5. Cek console log** untuk debug message
- [ ] **6. Cek Supabase Dashboard** → Users → Lihat apakah user ter-create
- [ ] **7. Jika masih error**, cek Network tab di browser untuk error detail
- [ ] **8. Jika masih error**, test direct API call dengan curl

---

## 🎯 Quick Fix (90% Kasus Terselesaikan)

**TL;DR - Ini yang paling sering jadi masalah:**

1. Buka https://supabase.com/dashboard
2. Pilih project → Authentication → Providers
3. **Enable Email provider** (toggle switch)
4. **Disable "Confirm email"** (untuk testing)
5. Save
6. Restart app
7. Test register lagi

---

## 📞 Masih Belum Berhasil?

Jika sudah coba semua solusi di atas tapi masih error 400:

1. **Screenshot error di Network tab** (DevTools)
2. **Screenshot Supabase Authentication settings**
3. **Copy error message lengkap** dari console
4. Buka issue di GitHub dengan informasi di atas

---

**Last Updated:** December 10, 2025
