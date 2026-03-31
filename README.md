# Rima Konveksi - Management System

Sistem manajemen konveksi fullstack yang dibangun menggunakan **Laravel 11** (Backend API) dan **Flutter** (Frontend App). Aplikasi ini dirancang untuk mempermudah pengelolaan data pelanggan, ukuran pakaian, stok produk, dan status transaksi pesanan.

## 🚀 Fitur Utama

- **Authentication & Role-Based Access**:
  - **Admin**: Akses penuh (Tambah, Edit, Hapus) untuk semua data Pelanggan, Produk, Katalog, dan Transaksi.
  - **Karyawan**: Akses terbatas (Hanya Lihat/View-Only) untuk status orderan dan katalog.
- **Manajemen Pelanggan**: Pencatatan ukuran mendetail (Baju, Celana, Rok) sesuai form fisik penjahit.
- **Manajemen Produk**: Pengelolaan stok kain/pakaian dengan foto.
- **Katalog Model**: Galeri foto model pakaian untuk referensi pelanggan (Kompatibel dengan Web).
- **Workflow Transaksi**:
  - **Pesanan Dibuat**: Status awal pemesanan.
  - **Sedang Dalam Pengerjaan**: Status saat penjahit mulai mengerjakan.
  - **Pesanan Selesai**: Tahap akhir di mana Admin menginput harga total pesanan.

---

## 🛠️ Tech Stack

- **Backend**: Laravel 11, Laravel Sanctum (API Auth), MySQL.
- **Frontend**: Flutter (3.x), Provider/Services Pattern, HTTP, Image Picker.

---

## ⚙️ Cara Instalasi (Setup)

### 1. Persiapan Backend (Laravel)
1. Masuk ke folder backend: `cd backend`.
2. Install dependencies: `composer install`.
3. Duplikat file .env: `cp .env.example .env`.
4. Sesuaikan konfigurasi database di `.env` (DB_DATABASE, DB_USERNAME, DB_PASSWORD).
5. Buat folder storage: `php artisan storage:link`.
6. Jalankan migrasi: `php artisan migrate`.
7. Jalankan server: `php artisan serve`.

### 2. Persiapan Frontend (Flutter)
1. Masuk ke root direktori: `cd ..`.
2. Install dependencies: `flutter pub get`.
3. Sesuaikan URL API di `lib/constants/api_constants.dart` (Pastikan IP 127.0.0.1:8000 sesuai dengan lokasi server Laravel).
4. Jalankan aplikasi: `flutter run -d chrome` (untuk Web) atau gunakan Emulator.

---

## 📡 Dokumentasi API (Endpoints)

Semua rute dilindungi oleh **Laravel Sanctum** (kecuali Login & Register).

### Authentication
- `POST /api/register` : Pendaftaran akun baru (Admin/Karyawan).
- `POST /api/login` : Mendapatkan Token akses.

### Pelanggan
- `GET /api/pelanggan` : Daftar semua pelanggan.
- `POST /api/pelanggan` : Tambah pelanggan baru.
- `PUT /api/pelanggan/{id}` : Update data & ukuran pelanggan.
- `DELETE /api/pelanggan/{id}` : Hapus pelanggan.

### Transaksi & Workflow Status
- `GET /api/transaksi` : Daftar semua orderan.
- `POST /api/transaksi` : Buat pesanan baru (Hanya Pelanggan, Produk, Jumlah).
- `PUT /api/transaksi/{id}` : Update status (`Sedang Dalam Pengerjaan` / `Pesanan Selesai`).
- **Catatan**: Input harga pesanan dilakukan saat update status menjadi **"Pesanan Selesai"**.

---

## 📸 Katalog & Media
Aplikasi ini mendukung upload gambar di Web. Gambar disimpan di folder `storage/app/public/katalog` (Backend) dan diakses melalui `/storage/katalog/filename.jpg`.

---

## ✍️ Kontributor
- **Suci Indrawati** (Developer)
