# 🛒 CIOMART - Aplikasi Kasir & Manajemen Minimarket (Mobile POS)

Selamat datang di repositori resmi **CIOMART**, aplikasi kasir dan manajemen minimarket modern berbasis mobile. Proyek ini merupakan pembaruan dan migrasi lengkap dari aplikasi berbasis web JSP/Servlet lama menjadi aplikasi perangkat bergerak lintas platform (**Flutter**) dengan server backend berbasis **Dart Shelf API** dan database **MySQL**.

Proyek ini dirancang dan dikembangkan untuk memenuhi **Tugas Akhir Mata Kuliah Aplikasi Perangkat Bergerak**.

---

## 🏆 Kesesuaian Kriteria Penilaian Dosen (Bobot 75%)

Aplikasi **CIOMART** telah sepenuhnya memenuhi semua kriteria penilaian tugas akhir yang ditetapkan oleh dosen pengampu dengan rincian implementasi teknis sebagai berikut:

### 1. Desain UI Menarik dengan Minimal 5 Halaman (Bobot 15%)
UI dikembangkan menggunakan bahasa desain modern dengan skema warna premium (*Brand Orange*, *Yellow*, dan *Cream*) yang responsif dan interaktif. Terdapat **9 Halaman Utama** yang fungsional:
*   🔑 **Halaman Sign In (Login):** Autentikasi pengguna berbasis peran (*Admin* & *Kasir*).
*   📝 **Halaman Sign Up (Register):** Pendaftaran akun staf baru.
*   📊 **Dashboard Admin:** Panel kontrol utama admin untuk memantau ringkasan statistik toko.
*   💼 **Dashboard Kasir:** Panel kontrol awal untuk kasir sebelum memulai transaksi.
*   🛒 **Halaman Transaksi POS:** Sistem keranjang belanja interaktif kasir dengan pencarian produk, perhitungan subtotal, PPN (10%), diskon transaksi, input pembayaran, kembalian, dan validasi stok.
*   📦 **Kelola Produk (CRUD):** Halaman manajemen produk barang (SKU, Nama, Kategori, Harga, Stok, Diskon Produk).
*   🗂️ **Kelola Kategori (CRUD):** Halaman pengelolaan kategori produk.
*   👥 **Kelola Pengguna (CRUD):** Halaman manajemen akun staf toko (Admin & Kasir).
*   📅 **Laporan Penjualan:** Riwayat transaksi penjualan terperinci dengan filter tanggal.

### 2. CRUD ke Database Menggunakan Network (Bobot 20%)
Aplikasi memisahkan sisi Client (Flutter) dan Server (Dart Backend) yang berkomunikasi via **REST API (Network)** melalui protokol HTTP.
*   Semua data disimpan di database relasional **MySQL** (di-host melalui XAMPP).
*   Operasi CRUD produk, kategori, user, dan checkout transaksi dikirim secara asinkronus menggunakan paket `http` dari Flutter ke endpoint API server Dart.

### 3. Fungsi Sign In, Sign Up, & Tampilan User Aktif (Bobot 10%)
*   **Sign In:** Memvalidasi akun menggunakan password terenkripsi hash SHA-256.
*   **Sign Up:** Menyediakan form pendaftaran akun baru dengan enkripsi SHA-256 langsung di sisi server untuk menjamin keamanan.
*   **User Aktif:** Nama pengguna beserta perannya (*ADMIN* / *CASHIER*) selalu ditampilkan dengan jelas di header atas dashboard dan panel menu sebagai identitas sesi aktif.

### 4. Menerapkan MVVM dan State Management (Bobot 20%)
Arsitektur kode Flutter dipisahkan secara ketat menggunakan pola desain **Model-View-ViewModel (MVVM)** bersama **Provider** sebagai State Management:
*   **Model:** Representasi entitas data (`user.dart`, `product.dart`, `category.dart`, `cart.dart`, `sale.dart`).
*   **View:** UI Widget Flutter murni tanpa logika bisnis (`screens/`, `widgets/`).
*   **ViewModel:** Pengatur state aplikasi yang mewarisi `ChangeNotifier` (`viewmodels/auth_viewmodel.dart` dan `viewmodels/transaction_viewmodel.dart`). ViewModel berfungsi menjembatani komunikasi data dari REST API ke UI secara reaktif.

### 5. Membuat APK dari Aplikasi (Bobot 10%)
Aplikasi telah di-build ke dalam format rilis Android Package (APK) yang siap di-install langsung di smartphone fisik.
*   **Path File APK:** `ciomart_flutter/build/app/outputs/flutter-apk/app-release.apk`

---

## 🛠️ Stack Teknologi

*   **Frontend Mobile:** Flutter SDK & Dart Language
*   **State Management:** Flutter Provider
*   **Backend REST API:** Dart Shelf, Shelf Router
*   **Database Engine:** MySQL Client (MySQL via XAMPP)
*   **Enkripsi Keamanan:** SHA-256 Password Hashing

---

## 📂 Struktur Proyek

```text
Ciomart/
├── ciomart_flutter/          # Source Code Client (Aplikasi Mobile Flutter)
│   ├── android/              # Konfigurasi platform Android
│   ├── lib/
│   │   ├── models/           # Model data (Entitas OOP)
│   │   ├── screens/          # View (Halaman UI Flutter)
│   │   ├── services/         # Service Network API (HTTP Request)
│   │   ├── utils/            # Konstanta API & Skema Warna
│   │   ├── viewmodels/       # ViewModel (Logika Bisnis & State Management)
│   │   └── widgets/          # Komponen UI Reusable
│   └── pubspec.yaml          # Dependensi Flutter (provider, http, dll.)
│
├── server/                   # Source Code REST API Backend (Dart Server)
│   ├── bin/
│   │   └── server.dart       # Titik masuk utama HTTP Server & Router API
│   ├── lib/
│   │   ├── db_connection.dart# Konfigurasi koneksi MySQL Database Pool
│   │   └── repositories/     # Akses Query SQL (User, Product, Category, Sale)
│   └── pubspec.yaml          # Dependensi Server (shelf, mysql_client, dll.)
│
├── database_schema.sql       # Schema awal database MySQL
├── add-product-discount.sql  # SQL Alter Table untuk kolom diskon produk
└── fix-password-hash.sql     # SQL Perbaikan hash password akun pengujian
```

---

## 🚀 Panduan Menjalankan Aplikasi

Ikuti langkah-langkah di bawah ini untuk menjalankan backend dan frontend secara lokal:

### Langkah 1: Setup Database MySQL (XAMPP)
1. Aktifkan modul **Apache** dan **MySQL** pada **XAMPP Control Panel**.
2. Buka **phpMyAdmin** (`http://localhost/phpmyadmin`).
3. Buat database baru dengan nama `tokoku`.
4. Import file SQL berikut secara berurutan ke database `tokoku`:
   - `database_schema.sql` (Skema tabel awal dan data sampel)
   - `add-product-discount.sql` (Menambahkan kolom diskon per produk)
   - `fix-password-hash.sql` (Mengatur password default menjadi SHA-256)

### Langkah 2: Jalankan Dart Backend Server
1. Buka terminal atau Command Prompt baru.
2. Navigasikan ke dalam direktori `server`:
   ```bash
   cd server
   ```
3. Unduh package dependensi:
   ```bash
   dart pub get
   ```
4. Jalankan server backend:
   ```bash
   dart run bin/server.dart
   ```
   Server akan berjalan secara default pada port `8082`: `http://localhost:8082`.

### Langkah 3: Konfigurasi IP Jaringan & Koneksi HP Fisik (Jika Uji Coba Langsung)
> [!IMPORTANT]
> Jika Anda menjalankan aplikasi Flutter di emulator Android, Anda bisa menggunakan `http://10.0.2.2:8082`. Namun, jika Anda menjalankannya menggunakan **HP Android Fisik via Wi-Fi/Hotspot**, Anda wajib menyamakan IP server.

1. Hubungkan Laptop dan HP Android dalam satu jaringan Wi-Fi/Hotspot yang sama.
2. Cari tahu IP Lokal Laptop Anda melalui Command Prompt:
   ```cmd
   ipconfig
   ```
   *(Contoh IPv4 Address: `10.142.39.172`)*.
3. Buka file `ciomart_flutter/lib/utils/constants.dart` dan perbarui `baseUrl` sesuai IP laptop Anda:
   ```dart
   class ApiConstants {
     static const String baseUrl = 'http://IP_LAPTOP_ANDA:8082/api';
   }
   ```
4. **Penting:** Matikan sementara **Windows Defender Firewall** pada laptop agar HP Android dapat mengakses server API Dart pada port `8082`.

### Langkah 4: Jalankan Aplikasi Flutter
1. Buka terminal baru.
2. Navigasikan ke direktori `ciomart_flutter`:
   ```bash
   cd ciomart_flutter
   ```
3. Unduh package dependensi Flutter:
   ```bash
   flutter pub get
   ```
4. Jalankan aplikasi di emulator atau perangkat fisik yang terhubung:
   ```bash
   flutter run
   ```

---

## 🔑 Akun Pengujian Default

Gunakan kredensial berikut untuk menguji login pada aplikasi:

| Peran (Role) | Username | Password | Fitur Utama |
| :--- | :--- | :--- | :--- |
| **ADMIN** | `admin` | `admin123` | Akses Dashboard Admin, CRUD Produk, Kategori, User, & Laporan Penjualan |
| **KASIR** | `kasir1` | `kasir123` | Akses Dashboard Kasir & POS (Transaksi Penjualan) |
| **KASIR** | `kasir2` | `kasir123` | Akses Dashboard Kasir & POS (Transaksi Penjualan) |

---

## 📐 Konsep Pemrograman Berorientasi Objek (OOP) & Desain Pola

Aplikasi ini mengadopsi prinsip-prinsip Clean Code dan OOP:
1. **Encapsulation (Enkapsulasi):** Penyembunyian data internal model menggunakan properti privat dengan metode getter/setter untuk validasi.
2. **Inheritance (Pewarisan):** Penggunaan model dasar `User` yang diwariskan ke entitas spesifik.
3. **Polymorphism (Polimorfisme):** Perhitungan diskon menggunakan antarmuka atau metode hitung dinamis tergantung jenis strategi diskon transaksi (Tanpa diskon, diskon persentase nominal, diskon produk).
4. **Strategy Pattern:** Fleksibilitas dalam menerapkan kebijakan diskon saat transaksi kasir berlangsung.
5. **Repository Pattern:** Abstraksi query database SQL di sisi backend server menggunakan class repository khusus (`UserRepository`, `ProductRepository`, dsb) agar struktur program rapi dan terorganisir.

---

**© 2026 CIOMART - Kelompok 1 APB | Siap Dipresentasikan! 🚀**
