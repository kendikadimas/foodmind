# 🗄️ Setup Database Supabase - FoodMind

## ⚠️ PENTING: Jalankan SQL Ini Dulu!

Jika table kosong/tidak ada data, berarti **database belum dibuat**. Ikuti langkah ini:

---

## 🚀 Quick Setup (5 Menit)

### Step 1: Buka SQL Editor di Supabase

1. Login ke https://supabase.com/dashboard
2. Pilih project FoodMind Anda
3. Klik **SQL Editor** di sidebar kiri
4. Klik **"New query"**

### Step 2: Jalankan SQL untuk Table `users`

**Copy-paste SQL ini ke SQL Editor:**

```sql
-- =============================================
-- TABLE: users
-- Menyimpan profile user
-- =============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  daily_budget NUMERIC DEFAULT 0,
  allergies TEXT[] DEFAULT '{}',
  medical_conditions TEXT[] DEFAULT '{}',
  food_preferences TEXT[] DEFAULT '{}',
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies jika ada (untuk avoid error)
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can delete own data" ON users;

-- Policy: Users can SELECT their own data
CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can INSERT their own data
CREATE POLICY "Users can insert own data"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Policy: Users can UPDATE their own data
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Policy: Users can DELETE their own data
CREATE POLICY "Users can delete own data"
  ON users FOR DELETE
  USING (auth.uid() = id);

-- Trigger untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_users_updated_at ON users;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Index untuk performa
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
```

**Klik "Run" atau tekan Ctrl+Enter**

✅ **Hasil:** Akan muncul "Success. No rows returned"

---

### Step 3: Jalankan SQL untuk Table `posts`

**Copy-paste SQL ini ke SQL Editor:**

```sql
-- =============================================
-- TABLE: posts
-- Menyimpan community posts
-- =============================================

CREATE TABLE IF NOT EXISTS posts (
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

-- Drop existing policies jika ada
DROP POLICY IF EXISTS "Anyone can read posts" ON posts;
DROP POLICY IF EXISTS "Authenticated users can create posts" ON posts;
DROP POLICY IF EXISTS "Users can update own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete own posts" ON posts;

-- Policy: Anyone can SELECT (read) posts
CREATE POLICY "Anyone can read posts"
  ON posts FOR SELECT
  TO authenticated, anon
  USING (true);

-- Policy: Authenticated users can INSERT posts
CREATE POLICY "Authenticated users can create posts"
  ON posts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can UPDATE their own posts
CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Users can DELETE their own posts
CREATE POLICY "Users can delete own posts"
  ON posts FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Trigger untuk auto-update updated_at
DROP TRIGGER IF EXISTS update_posts_updated_at ON posts;

CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Index untuk performa
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
```

**Klik "Run"**

✅ **Hasil:** "Success. No rows returned"

---

### Step 4: Verifikasi Table Sudah Dibuat

1. Di Supabase Dashboard, klik **Table Editor** (sidebar kiri)
2. Anda harus melihat 2 tables:
   - ✅ **users** (0 rows)
   - ✅ **posts** (0 rows)
3. Klik masing-masing table untuk lihat structure-nya

**Screenshot contoh:**
```
Table Editor
├── users (0 rows)
│   ├── id (uuid)
│   ├── name (text)
│   ├── email (text)
│   └── ...
└── posts (0 rows)
    ├── id (bigint)
    ├── user_id (uuid)
    ├── author_name (text)
    └── ...
```

---

## 🧪 Test Data Masuk ke Supabase

### Test 1: Register User Baru

1. Restart aplikasi Flutter
2. Buka halaman Register
3. Isi data:
   ```
   Name: Test User
   Email: test@gmail.com
   Password: password123
   ```
4. Klik Register

**Cek di Supabase:**
1. Dashboard → Authentication → **Users**
2. Harus ada user baru dengan email `test@gmail.com`
3. Dashboard → Table Editor → **users**
4. Harus ada 1 row dengan data user

### Test 2: Buat Post

1. Login dengan user yang tadi dibuat
2. Buka Community tab
3. Buat post baru
4. Submit

**Cek di Supabase:**
1. Table Editor → **posts**
2. Harus ada 1 row dengan post yang baru dibuat

---

## 🔍 Troubleshooting

### ❌ Error: "relation 'users' does not exist"

**Penyebab:** Table belum dibuat

**Solusi:** Jalankan SQL untuk create table `users` di Step 2

### ❌ Error: "new row violates row-level security policy"

**Penyebab:** RLS policy salah atau belum dibuat

**Solusi:** 
1. Jalankan ulang SQL policy (DROP POLICY + CREATE POLICY)
2. Atau disable RLS temporary: `ALTER TABLE users DISABLE ROW LEVEL SECURITY;`

### ❌ Error: "permission denied for table users"

**Penyebab:** User tidak punya akses ke table

**Solusi:**
1. Cek apakah RLS enabled: `SELECT * FROM pg_tables WHERE tablename = 'users';`
2. Cek policies: `SELECT * FROM pg_policies WHERE tablename = 'users';`
3. Pastikan policy menggunakan `auth.uid() = id`

### ❌ Data tidak muncul di table

**Penyebab:** 
- User belum login (auth.uid() = null)
- RLS policy block akses
- Error saat insert (cek console log)

**Solusi:**
1. Cek console Flutter untuk error message
2. Cek Supabase Logs: Dashboard → Logs → API Logs
3. Temporary disable RLS untuk test:
   ```sql
   ALTER TABLE users DISABLE ROW LEVEL SECURITY;
   ```
4. Test insert manual:
   ```sql
   -- Di SQL Editor, test insert langsung
   INSERT INTO users (id, name, email)
   VALUES (
     'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',  -- UUID user dari auth.users
     'Test',
     'test@test.com'
   );
   ```

---

## 📊 Monitoring Data

### Lihat Data di Table Editor

1. Dashboard → **Table Editor**
2. Klik table **users** atau **posts**
3. Akan muncul grid dengan semua data

### Query Manual di SQL Editor

```sql
-- Lihat semua users
SELECT * FROM users;

-- Lihat users dengan email tertentu
SELECT * FROM users WHERE email LIKE '%gmail%';

-- Lihat semua posts
SELECT * FROM posts ORDER BY created_at DESC;

-- Lihat posts dari user tertentu
SELECT p.*, u.name 
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE u.email = 'test@gmail.com';

-- Count total users
SELECT COUNT(*) FROM users;

-- Count total posts
SELECT COUNT(*) FROM posts;
```

---

## 🔐 Security Best Practices

### Enable RLS (Row Level Security)

**SELALU enable RLS di production:**
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
```

### Test RLS Policies

Coba query sebagai anonymous user:
```sql
-- Set role to anon (simulate unauthenticated user)
SET ROLE anon;
SELECT * FROM users; -- Should return 0 rows

-- Reset role
RESET ROLE;
```

### Review Policies Regularly

```sql
-- List all policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
ORDER BY tablename, policyname;
```

---

## 📚 Dokumentasi Table

### Table: `users`

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NO | - | Primary key, FK ke auth.users |
| name | TEXT | NO | - | Nama lengkap user |
| email | TEXT | NO | - | Email (unique) |
| phone | TEXT | YES | NULL | Nomor HP |
| daily_budget | NUMERIC | YES | 0 | Budget harian (Rupiah) |
| allergies | TEXT[] | YES | {} | List alergi |
| medical_conditions | TEXT[] | YES | {} | Kondisi kesehatan |
| food_preferences | TEXT[] | YES | {} | Preferensi makanan |
| is_premium | BOOLEAN | YES | FALSE | Status premium |
| created_at | TIMESTAMPTZ | NO | NOW() | Waktu dibuat |
| updated_at | TIMESTAMPTZ | NO | NOW() | Waktu diupdate |

### Table: `posts`

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | BIGSERIAL | NO | AUTO | Primary key |
| user_id | UUID | YES | NULL | FK ke auth.users |
| author_name | TEXT | NO | - | Nama author |
| author_email | TEXT | NO | - | Email author |
| content | TEXT | NO | - | Isi post |
| budget | NUMERIC | YES | NULL | Budget |
| location | TEXT | YES | NULL | Lokasi |
| allergies | TEXT[] | YES | {} | Alergi |
| preferences | TEXT[] | YES | {} | Preferensi |
| likes_count | INTEGER | YES | 0 | Jumlah likes |
| liked_by | TEXT[] | YES | {} | User IDs yang like |
| responses | JSONB | YES | [] | Array responses |
| created_at | TIMESTAMPTZ | NO | NOW() | Waktu dibuat |
| updated_at | TIMESTAMPTZ | NO | NOW() | Waktu diupdate |

---

## ✅ Checklist

Sebelum test aplikasi, pastikan:

- [ ] Table `users` sudah dibuat
- [ ] Table `posts` sudah dibuat
- [ ] RLS enabled di kedua table
- [ ] Policies sudah dibuat (4 policies per table)
- [ ] Trigger `update_updated_at` sudah dibuat
- [ ] Index sudah dibuat
- [ ] Test query manual berhasil
- [ ] Email Provider enabled di Authentication
- [ ] Supabase URL & anon key sudah di-update di `dart-defines.json`

Jika semua ✅, restart app dan test register!

---

**Last Updated:** December 10, 2025
