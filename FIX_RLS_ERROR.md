# 🔧 Quick Fix: Disable RLS untuk Testing

## ⚠️ MASALAH: "User not logged in" atau RLS Policy Error

Jika console menampilkan:
```
❌ Cannot save profile: User not logged in (currentUserId is null)
```

Atau:
```
❌ Failed to save profile: new row violates row-level security policy
```

**Penyebabnya:** Row Level Security (RLS) blocking insert karena `auth.uid()` belum ter-update atau null.

---

## ✅ SOLUSI CEPAT (Untuk Testing)

### Step 1: Disable RLS Sementara

Buka **Supabase Dashboard** → **SQL Editor**, jalankan:

```sql
-- Temporary disable RLS untuk testing
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;
```

Klik **Run**

### Step 2: Test Register Lagi

1. Restart app
2. Register user baru
3. Data harus masuk ke table `users`

### Step 3: Re-enable RLS (Setelah Testing Selesai)

**PENTING:** Jangan lupa enable kembali untuk security!

```sql
-- Re-enable RLS untuk production
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
```

---

## 🔐 SOLUSI PERMANENT: Fix RLS Policy

RLS policy yang benar untuk table `users`:

```sql
-- Drop old policies
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can delete own data" ON users;

-- CREATE policies yang lebih permissive untuk testing
CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own data"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete own data"
  ON users FOR DELETE
  TO authenticated
  USING (auth.uid() = id);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
```

---

## 🧪 Test Step-by-Step

### Test 1: Cek Table Exists

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'users';
```

**Expected:** 1 row dengan `table_name = users`

### Test 2: Cek RLS Status

```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'users';
```

**Expected:** `rowsecurity = false` (jika disabled) atau `true` (jika enabled)

### Test 3: Cek Policies

```sql
SELECT policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'users';
```

**Expected:** 4 policies (SELECT, INSERT, UPDATE, DELETE)

### Test 4: Manual Insert (Test RLS)

```sql
-- Set role to simulate authenticated user
SET ROLE authenticated;
SET request.jwt.claim.sub = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'; -- User ID

-- Try insert
INSERT INTO users (id, name, email)
VALUES (
  'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', -- Same user ID
  'Test User',
  'test@test.com'
);

-- Reset role
RESET ROLE;
```

**Expected:** Insert berhasil tanpa error

---

## 📊 Monitoring

### Lihat Auth Users

```sql
SELECT id, email, created_at 
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 10;
```

### Lihat Users Table

```sql
SELECT * FROM users ORDER BY created_at DESC;
```

### Join Auth + Users

```sql
SELECT 
  a.id,
  a.email as auth_email,
  a.created_at as auth_created,
  u.name,
  u.email as profile_email,
  u.created_at as profile_created
FROM auth.users a
LEFT JOIN users u ON a.id = u.id
ORDER BY a.created_at DESC;
```

**Expected:** Setiap user di `auth.users` harus ada corresponding row di `users`

---

## ❌ Troubleshooting

### Error: "permission denied for table users"

**Solusi:**
```sql
-- Grant permissions to authenticated role
GRANT ALL ON users TO authenticated;
GRANT ALL ON posts TO authenticated;
```

### Error: "duplicate key value violates unique constraint"

User sudah ada di database.

**Solusi:**
```sql
-- Delete existing user
DELETE FROM users WHERE email = 'test@test.com';
```

Atau gunakan email lain untuk test.

### Error: "null value in column 'name' violates not-null constraint"

Data tidak lengkap.

**Solusi:** Pastikan semua required fields diisi (name, email)

---

## 🎯 Quick Command Reference

```sql
-- Disable RLS (testing)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Enable RLS (production)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Check RLS status
SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'users';

-- List all policies
SELECT * FROM pg_policies WHERE tablename = 'users';

-- Drop all policies
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can delete own data" ON users;

-- View auth users
SELECT id, email, created_at FROM auth.users ORDER BY created_at DESC;

-- View users table
SELECT * FROM users ORDER BY created_at DESC;

-- Delete test data
DELETE FROM users WHERE email LIKE '%test%';
DELETE FROM auth.users WHERE email LIKE '%test%';
```

---

**Last Updated:** December 10, 2025
