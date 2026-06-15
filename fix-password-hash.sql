-- ===================================================
-- FIX PASSWORD HASH UNTUK DATABASE TOKOKU
-- ===================================================
-- Jalankan script ini di phpMyAdmin untuk memperbaiki password hash
-- SHA-256 hash harus 64 karakter (256 bits = 32 bytes = 64 hex chars)

USE tokoku;

-- Password hash yang benar untuk demo accounts:
-- admin123 -> 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
-- kasir123 -> 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92

-- Update admin password (admin123)
UPDATE users 
SET password_hash = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'
WHERE username = 'admin';

-- Update kasir1 password (kasir123)
UPDATE users 
SET password_hash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'
WHERE username = 'kasir1';

-- Update kasir2 password (kasir123)
UPDATE users 
SET password_hash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'
WHERE username = 'kasir2';

-- Verifikasi hasil update (hash harus 64 karakter)
SELECT 
    username, 
    password_hash,
    LENGTH(password_hash) as hash_length,
    CASE 
        WHEN LENGTH(password_hash) = 64 THEN 'OK ✓'
        ELSE 'ERROR ✗'
    END as status
FROM users
ORDER BY id;

-- ===================================================
-- SETELAH JALANKAN SCRIPT INI:
-- Login dengan:
-- - Username: admin, Password: admin123
-- - Username: kasir1, Password: kasir123
-- - Username: kasir2, Password: kasir123
-- ===================================================
