# 🚀 CARA MENJALANKAN APLIKASI CIOMART

## ❌ ERROR 404 - SOLUSI

### Masalah:
Akses `http://localhost:8080/Lady/` menghasilkan **HTTP 404 - Not Found**

### Penyebab:
URL yang salah! Nama artifact di `pom.xml` adalah `Lady-1.0-SNAPSHOT`

---

## ✅ SOLUSI - URL YANG BENAR

### **URL Login:**
```
http://localhost:8080/Lady-1.0-SNAPSHOT/login.jsp
```

### **Atau gunakan index redirect:**
```
http://localhost:8080/Lady-1.0-SNAPSHOT/
```
(Akan otomatis redirect ke login.jsp)

---

## 📝 LANGKAH-LANGKAH MENJALANKAN

### 1. **Setup Database** ✅

#### A. Buat Database
```sql
CREATE DATABASE tokoku CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### B. Import Schema
Di phpMyAdmin atau MySQL Workbench, import file:
- `database_schema.sql`

#### C. Tambah Kolom Diskon
```sql
USE tokoku;
ALTER TABLE products 
ADD COLUMN discount_percentage INT DEFAULT 0 
COMMENT 'Diskon produk dalam persen (0-100)';
```

#### D. Fix Password Hash
```sql
-- Admin: admin / admin123
UPDATE users SET password_hash = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9' 
WHERE username = 'admin';

-- Kasir: kasir1 / 123456
UPDATE users SET password_hash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92' 
WHERE username = 'kasir1';

-- Kasir: kasir2 / 123456
UPDATE users SET password_hash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92' 
WHERE username = 'kasir2';
```

---

### 2. **Build Project di NetBeans** 🔨

#### A. Clean and Build
1. Klik kanan pada project **Lady**
2. Pilih **Clean and Build**
3. Tunggu sampai **BUILD SUCCESS**

Output akan ada di:
```
target/Lady-1.0-SNAPSHOT.war
```

---

### 3. **Deploy ke Tomcat** 🚀

#### A. Via NetBeans (Otomatis)
1. Klik kanan project **Lady**
2. Pilih **Run**
3. NetBeans akan otomatis deploy ke Tomcat
4. Browser akan terbuka otomatis

#### B. Manual Deploy
1. Copy file `target/Lady-1.0-SNAPSHOT.war`
2. Paste ke folder Tomcat: `webapps/`
3. Start Tomcat
4. Tunggu deployment selesai

---

### 4. **Akses Aplikasi** 🌐

#### **Pilihan 1: Langsung ke Login**
```
http://localhost:8080/Lady-1.0-SNAPSHOT/login.jsp
```

#### **Pilihan 2: Via Index (Auto Redirect)**
```
http://localhost:8080/Lady-1.0-SNAPSHOT/
```

---

## 🔑 LOGIN CREDENTIALS

### **Admin Account:**
- **Username:** `admin`
- **Password:** `admin123`
- **Access:** 
  - Kelola Produk (dengan fitur set diskon!)
  - Kelola Kategori
  - Kelola User
  - Lihat Laporan Penjualan

### **Kasir Account 1:**
- **Username:** `kasir1`
- **Password:** `123456`
- **Access:** 
  - Transaksi Penjualan (diskon otomatis!)

### **Kasir Account 2:**
- **Username:** `kasir2`
- **Password:** `123456`
- **Access:** 
  - Transaksi Penjualan

---

## 🎯 FLOW PENGGUNAAN

### **Sebagai Admin:**

1. **Login** → `http://localhost:8080/Lady-1.0-SNAPSHOT/login.jsp`
   - Username: `admin`
   - Password: `admin123`

2. **Kelola Produk:**
   - Klik menu **"Kelola Produk"**
   - Klik **"➕ Tambah Produk"**
   - Isi form:
     - SKU: `P001`
     - Nama: `Indomie Goreng`
     - Kategori: `Makanan`
     - Harga: `3500`
     - Stok: `100`
     - **Diskon: `10`** ← Fitur baru!
   - Klik **Simpan**

3. **Kelola Kategori:**
   - Klik menu **"Kelola Kategori"**
   - Tambah kategori baru (Makanan, Minuman, Snack, dll)

4. **Kelola User:**
   - Klik menu **"Kelola User"**
   - Tambah kasir baru jika diperlukan

5. **Lihat Laporan:**
   - Klik menu **"Laporan Penjualan"**
   - Filter berdasarkan tanggal
   - Lihat total penjualan, jumlah transaksi, dll

---

### **Sebagai Kasir:**

1. **Login** → `http://localhost:8080/Lady-1.0-SNAPSHOT/login.jsp`
   - Username: `kasir1`
   - Password: `123456`

2. **Mulai Transaksi:**
   - Otomatis masuk ke halaman transaksi
   - Lihat daftar produk di sebelah kiri

3. **Pilih Produk:**
   - **Klik** produk untuk menambahkan ke keranjang
   - Produk dengan diskon akan tampil:
     - ~~Harga asli~~ (dicoret)
     - **Harga diskon** (hijau)
     - Badge **10%** (contoh)

4. **Atur Quantity:**
   - Klik **+** atau **-** untuk ubah jumlah
   - Klik **🗑️** untuk hapus item

5. **Pilih Diskon Transaksi:**
   - Tanpa Diskon
   - Diskon 10%
   - Diskon 20%

6. **Bayar:**
   - Masukkan jumlah uang dibayar
   - Sistem akan hitung kembalian otomatis
   - Klik **💰 Proses Pembayaran**
   - Konfirmasi **OK**

7. **Selesai:**
   - Transaksi berhasil disimpan
   - Stok otomatis berkurang
   - Keranjang kosong kembali

---

## 🔧 TROUBLESHOOTING

### **1. Error 404 - Not Found**
**Penyebab:** URL salah

**Solusi:**
- ❌ SALAH: `http://localhost:8080/Lady/`
- ✅ BENAR: `http://localhost:8080/Lady-1.0-SNAPSHOT/login.jsp`

---

### **2. Tomcat Not Running**
**Penyebab:** Tomcat belum start

**Solusi:**
- Di NetBeans: Klik tab **Services** → Servers → Tomcat → **Start**
- Atau manual: Jalankan `startup.bat` di folder Tomcat

---

### **3. Database Connection Error**
**Penyebab:** MySQL belum running atau konfigurasi salah

**Solusi:**
1. Start MySQL/XAMPP
2. Cek file `DBConnection.java`:
   ```java
   private static final String URL = "jdbc:mysql://localhost:3306/tokoku";
   private static final String USER = "root";
   private static final String PASSWORD = ""; // sesuaikan
   ```

---

### **4. Login Gagal - Password Salah**
**Penyebab:** Password hash belum diupdate

**Solusi:**
Jalankan SQL ini di phpMyAdmin:
```sql
UPDATE users SET password_hash = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9' WHERE username = 'admin';
UPDATE users SET password_hash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92' WHERE username IN ('kasir1', 'kasir2');
```

---

### **5. Halaman Kosong/Hitam (transaction.jsp)**
**Penyebab:** JavaScript error atau cache browser

**Solusi:**
1. **Hard Refresh:** `Ctrl + Shift + R` atau `Ctrl + F5`
2. **Clear Cache:** Bersihkan cache browser
3. **Console Check:** Buka Developer Tools (F12) → Console tab
4. **Rebuild:** Clean and Build project di NetBeans

---

### **6. Kolom discount_percentage Not Found**
**Penyebab:** Belum jalankan ALTER TABLE

**Solusi:**
```sql
USE tokoku;
ALTER TABLE products 
ADD COLUMN discount_percentage INT DEFAULT 0;
```

---

## 📊 FITUR-FITUR UTAMA

### ✅ **Yang Sudah Berfungsi:**

1. **Login & Authentication** ✅
   - SHA-256 password hashing
   - Role-based access (Admin/Cashier)
   - Session management

2. **Admin - Kelola Produk** ✅
   - CRUD produk
   - Set diskon per produk (0-100%)
   - Upload gambar (optional)
   - Validasi input

3. **Admin - Kelola Kategori** ✅
   - CRUD kategori
   - One-to-many relationship dengan produk

4. **Admin - Kelola User** ✅
   - CRUD user (Admin/Cashier)
   - Password auto-hash SHA-256

5. **Admin - Laporan Penjualan** ✅
   - Filter by date
   - Total penjualan
   - Jumlah transaksi
   - Detail per transaksi

6. **Kasir - Transaksi** ✅
   - Pilih produk (klik)
   - **Diskon produk otomatis!** 🎁
   - Keranjang belanja
   - Ubah quantity (+/-)
   - Hapus item
   - Pilih strategi diskon (No/10%/20%)
   - Hitung PPN 10% otomatis
   - Input uang dibayar
   - Hitung kembalian otomatis
   - Validasi stok
   - Simpan transaksi
   - Update stok otomatis

---

## 🎯 KONSEP OOP YANG DIIMPLEMENTASIKAN

### 1. **Encapsulation** ✅
- Semua atribut private
- Akses via getter/setter
- Validasi di setter

### 2. **Inheritance** ✅
- `User` (abstract) → `Admin` & `Cashier`

### 3. **Abstraction** ✅
- `User` abstract class
- `DiscountPolicy` interface

### 4. **Polymorphism** ✅
- `DiscountPolicy.apply()` berbeda implementasi
- Runtime binding pada strategi diskon

### 5. **Composition** ✅
- `Cart` ◆→ `CartItem`

### 6. **Aggregation** ✅
- `Product` ◇→ `Category`
- `Sale` ◇→ `User`

### 7. **Design Patterns** ✅
- **Strategy:** DiscountPolicy
- **Facade:** SaleService
- **Repository:** ProductRepository, SaleRepository

---

## 📞 SUPPORT

Jika masih ada error, cek:
1. **Console Log:** Developer Tools (F12) → Console
2. **Tomcat Log:** NetBeans → Output → Tomcat
3. **Database:** Pastikan MySQL running dan data sudah ada

---

**© 2025 CIOMART - Kelompok 9 | Siap Digunakan!** 🚀
