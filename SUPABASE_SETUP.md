# Setup Supabase untuk FoodMind

Panduan lengkap setup Supabase untuk aplikasi FoodMind.

## 📋 Prerequisites

- Akun Supabase (gratis di [supabase.com](https://supabase.com))
- Flutter SDK terinstall
- Project FoodMind sudah di-clone

## 🚀 Langkah Setup

### 1. Buat Project di Supabase

1. Buka [supabase.com](https://supabase.com) dan login
2. Klik **"New Project"**
3. Isi detail project:
   - **Name**: FoodMind (atau nama lain)
   - **Database Password**: Simpan password ini dengan aman!
   - **Region**: Pilih **Southeast Asia (Singapore)** untuk Indonesia
   - **Pricing Plan**: Free tier (cukup untuk development)
4. Klik **"Create new project"**
5. Tunggu beberapa menit sampai project selesai dibuat

### 2. Get Supabase Credentials

1. Di dashboard project, buka **Settings** (icon gear) di sidebar kiri
2. Pilih **API** di menu Settings
3. Copy 2 nilai ini:
   - **Project URL** (contoh: `https://xxxxx.supabase.co`)
   - **anon public** key (key yang panjang)

### 3. Update Kode FoodMind

Buka file `lib/services/supabase_service.dart` dan ganti:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Dengan URL dan key yang sudah di-copy:

```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGc...panjangbanget';
```

### 4. Buat Database Tables

#### Table: `users`

Di Supabase dashboard, buka **SQL Editor** dan jalankan query ini:

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  daily_budget NUMERIC,
  allergies TEXT[] DEFAULT '{}',
  medical_conditions TEXT[] DEFAULT '{}',
  food_preferences TEXT[] DEFAULT '{}',
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own data
CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can insert their own data
CREATE POLICY "Users can insert own data"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Policy: Users can update their own data
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Policy: Users can delete their own data
CREATE POLICY "Users can delete own data"
  ON users FOR DELETE
  USING (auth.uid() = id);
```

#### Table: `posts`

Jalankan query ini untuk table posts:

```sql
CREATE TABLE posts (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL,
  author_email TEXT NOT NULL,
  content TEXT NOT NULL,
  budget NUMERIC,
  location TEXT,
  allergies TEXT[] DEFAULT '{}',
  preferences TEXT[] DEFAULT '{}',
  likes_count INTEGER DEFAULT 0,
  liked_by TEXT[] DEFAULT '{}',
  responses JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read posts
CREATE POLICY "Anyone can read posts"
  ON posts FOR SELECT
  TO authenticated, anon
  USING (true);

-- Policy: Authenticated users can create posts
CREATE POLICY "Authenticated users can create posts"
  ON posts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own posts
CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own posts
CREATE POLICY "Users can delete own posts"
  ON posts FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Index untuk performa
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_user_id ON posts(user_id);
```

### 5. Enable Authentication

1. Di Supabase dashboard, buka **Authentication** di sidebar
2. Pilih **Providers**
3. **Email** sudah aktif by default ✅
4. Untuk **Google OAuth** (optional):
   - Toggle **Google** ke ON
   - Follow instruksi untuk:
     - Buat OAuth credentials di Google Cloud Console
     - Copy Client ID dan Client Secret
     - Paste ke Supabase
     - Add redirect URL dari Supabase ke Google Console

### 6. Setup Realtime (Optional tapi Recommended)

Untuk real-time updates di community feed:

1. Di Supabase dashboard, buka **Database** → **Replication**
2. Cari table `posts`
3. Enable **Realtime** dengan klik toggle

### 7. Test Connection

Jalankan app:

```bash
flutter pub get
flutter run -d chrome
```

Coba:
- ✅ Daftar akun baru
- ✅ Login
- ✅ Update profile
- ✅ Buat post di community
- ✅ Like dan comment
- ✅ Lihat real-time updates

## 🔒 Security Notes

### Environment Variables (Production)

Untuk production, **JANGAN hardcode credentials** di kode!

Gunakan environment variables:

```dart
// lib/services/supabase_service.dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'YOUR_DEFAULT_URL',
);
static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'YOUR_DEFAULT_KEY',
);
```

Run dengan:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJxxx
```

### Row Level Security (RLS)

RLS policies sudah aktif di tables untuk:
- Users hanya bisa CRUD data mereka sendiri
- Posts bisa dibaca semua orang, tapi hanya pemilik yang bisa edit/delete
- Responses di-manage lewat JSONB column dengan validation

## 📊 Database Structure

```
users
├── id (UUID, PK, FK to auth.users)
├── name
├── email (unique)
├── phone
├── daily_budget
├── allergies (array)
├── medical_conditions (array)
├── food_preferences (array)
├── is_premium
├── created_at
└── updated_at

posts
├── id (BIGSERIAL, PK)
├── user_id (UUID, FK to auth.users)
├── author_name
├── author_email
├── content
├── budget
├── location
├── allergies (array)
├── preferences (array)
├── likes_count
├── liked_by (array of emails)
├── responses (JSONB array)
│   └── [{
│       id,
│       author_name,
│       author_email,
│       content,
│       restaurant_name,
│       estimated_price,
│       created_at,
│       likes_count,
│       liked_by
│     }]
├── created_at
└── updated_at
```

## 🆚 Supabase vs Firebase

### Kelebihan Supabase:

✅ **PostgreSQL** - Database relational yang powerful
✅ **Row Level Security** - Security built-in di database level
✅ **Realtime** - WebSocket untuk live updates
✅ **Free Tier Generous** - 500MB database, 2GB bandwidth, 50MB storage
✅ **SQL Queries** - Direct SQL access, lebih flexible
✅ **Open Source** - Bisa self-host kalau mau
✅ **Dashboard** - UI admin yang modern dan lengkap

### Setup Lebih Simpel:

❌ No need Firebase Console
❌ No need firebase_options.dart
❌ No need FlutterFire CLI
✅ Cukup URL + Anon Key
✅ One SDK for everything (auth, database, storage, realtime)

## 🐛 Troubleshooting

### Error: "Invalid API key"
- Cek lagi URL dan Anon Key di `supabase_service.dart`
- Pastikan tidak ada spasi atau karakter hidden

### Error: "Row Level Security policy violation"
- Cek policies di table users dan posts
- Pastikan user sudah login (authenticated)

### Realtime tidak jalan
- Enable Realtime di Supabase dashboard → Database → Replication
- Pastikan table posts sudah di-enable

### Google Sign-In tidak jalan
- Lengkapi setup Google OAuth di Authentication → Providers
- Add redirect URL dari Supabase ke Google Cloud Console
- Update `redirectTo` di `auth_service.dart`

## 📚 Resources

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

## 🎉 Selesai!

Kalau semua setup sudah beres, aplikasi FoodMind sekarang:
- ✅ Menggunakan Supabase PostgreSQL untuk persistent storage
- ✅ Authentication dengan email/password dan Google OAuth
- ✅ Real-time community feed updates
- ✅ Secure dengan Row Level Security
- ✅ Free tier yang generous untuk development

Happy coding! 🚀
