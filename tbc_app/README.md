# TBC App - Backend API (Laravel)

REST API backend untuk aplikasi pemantauan dan kepatuhan pengobatan Tuberkulosis (TBC Digital).

## Fitur Utama Backend
- **Autentikasi & Autorisasi**: Multi-role (Pasien, Petugas Puskesmas, Kepala Puskesmas / Manajemen) berbasis Laravel Sanctum.
- **Manajemen Pasien & Pengobatan**: Pencatatan log minum obat harian, upload bukti minum obat, dan monitoring kepatuhan.
- **Monitoring Kesehatan**: Pencatatan riwayat kesehatan, berat badan, indeks massa tubuh (BMI), dan progress pengobatan.
- **Push Notification & Chat**: Integrasi Firebase Cloud Messaging (FCM) untuk pengingat minum obat otomatis dan notifikasi chat.
- **Manajemen Wilayah & Desa**: Pelaporan data kepatuhan per wilayah/desa binaan.

## Persyaratan Sistem
- PHP >= 8.0
- Composer >= 2.x
- MySQL >= 5.7 / MariaDB >= 10.3
- Extension PHP: BCMath, Ctype, Fileinfo, JSON, Mbstring, OpenSSL, PDO, pdo_mysql, Tokenizer, XML

## Langkah Instalasi

1. **Masuk ke direktori backend**:
   ```bash
   cd tbc_app
   ```

2. **Instal dependensi Composer**:
   ```bash
   composer install
   ```

3. **Konfigurasi Environment**:
   Salin `.env.example` ke `.env`:
   ```bash
   cp .env.example .env
   # Di Windows PowerShell:
   Copy-Item .env.example .env
   ```
   Sesuaikan konfigurasi database di file `.env`:
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=tbc_db
   DB_USERNAME=root
   DB_PASSWORD=
   ```

4. **Generate Application Key**:
   ```bash
   php artisan key:generate
   ```

5. **Konfigurasi Firebase Admin (Service Account)**:
   - Unduh credentials Service Account Firebase Anda dari Google Cloud / Firebase Console.
   - Letakkan file di: `storage/firebase/firebase.json` (Gunakan `storage/firebase/firebase.json.example` sebagai acuan format).

6. **Migrasi Database & Seeder**:
   ```bash
   php artisan migrate --seed
   ```

7. **Storage Link**:
   ```bash
   php artisan storage:link
   ```

8. **Menjalankan Server Lokal**:
   ```bash
   php artisan serve
   ```
   Akses API di `http://127.0.0.1:8000/api`.

## Lisensi
Open-source di bawah lisensi MIT.