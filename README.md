# Nusa Penida Travel Buddy

Aplikasi mobile berbasis Flutter untuk membantu pengguna menjelajahi destinasi wisata di Nusa Penida, Bali, serta mengelola rencana perjalanan dalam satu aplikasi.

## Fitur Aplikasi

- **Home:** Menampilkan halaman utama, destinasi populer, ringkasan itinerary, dan statistik perjalanan.
- **Explore Destinations:** Menampilkan daftar destinasi wisata dengan fitur pencarian dan tampilan Grid/List.
- **Destination Detail:** Menampilkan informasi detail destinasi dan menyediakan fitur untuk menambahkannya ke itinerary.
- **My Itinerary:** Mengelola rencana perjalanan dengan fitur tambah, lihat, edit, hapus, pencarian, dan filter status.
- **Favorites:** Menampilkan destinasi yang ditandai sebagai favorit.
- **Profile:** Menampilkan informasi profil dan ringkasan aktivitas perjalanan.

## Teknologi yang Digunakan

- **Flutter & Dart** – Pengembangan aplikasi mobile.
- **Provider** – State management menggunakan `ChangeNotifier`.
- **HTTP** – Komunikasi dengan REST API.
- **Supabase** – Database dan operasi CRUD itinerary.
- **MockAPI** – Penyedia data destinasi wisata.

## Arsitektur Aplikasi

Aplikasi menerapkan pemisahan tanggung jawab menggunakan pendekatan Clean Architecture sederhana:

```text
lib/
├── config/
│   └── supabase_config.dart
├── models/
│   ├── destination_model.dart
│   └── itinerary_model.dart
├── providers/
│   └── travel_provider.dart
├── repositories/
│   └── travel_repository.dart
├── screens/
│   ├── destination_detail_screen.dart
│   ├── destination_list_screen.dart
│   ├── favorite_screen.dart
│   ├── home_screen.dart
│   ├── main_navigation_screen.dart
│   ├── my_itinerary_screen.dart
│   └── profile_screen.dart
├── services/
│   ├── api_service.dart
│   └── supabase_service.dart
└── main.dart
```

### Alur Arsitektur

1. **UI / Screens:** Menampilkan halaman dan menerima interaksi pengguna.
2. **Provider:** Mengelola state aplikasi menggunakan `ChangeNotifier`.
3. **Repository:** Menjadi penghubung antara Provider dan Service.
4. **Services:** Mengelola komunikasi dengan REST API dan Supabase.
5. **Models:** Mendefinisikan struktur data destinasi dan itinerary.

## Sumber Data

### REST API – MockAPI

Data destinasi wisata diperoleh melalui REST API:

```text
https://6aed61a0fc3b911e6fd6220d.mockapi.io/destinations
```

API digunakan untuk mengambil daftar destinasi dan detail destinasi berdasarkan ID.

### Supabase

Supabase digunakan untuk menyimpan dan mengelola data itinerary pengguna.

Tabel yang digunakan:

**Nama tabel:** `my_itinerary`

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| id | UUID | Primary key |
| spot_name | TEXT | Nama destinasi |
| visit_date | DATE | Tanggal kunjungan |
| budget | NUMERIC(12,2) | Anggaran perjalanan |
| status | TEXT | Status perjalanan |
| notes | TEXT | Catatan perjalanan |
| created_at | TIMESTAMPTZ | Waktu pembuatan data |

Operasi database yang didukung:
- Create: Menambahkan itinerary.
- Read: Menampilkan daftar dan detail itinerary.
- Update: Mengubah data itinerary.
- Delete: Menghapus itinerary.

## Persiapan dan Instalasi

### 1. Persyaratan

Pastikan perangkat pengembangan telah memiliki:
- Flutter SDK
- Dart SDK
- Android Studio atau Visual Studio Code
- Android Emulator atau perangkat Android
- Koneksi internet

### 2. Clone Repository

```bash
git clone <URL_REPOSITORY>
```

Masuk ke direktori proyek:

```bash
cd nusa_penida_travel_buddy
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Konfigurasi Supabase

Buka file:

```text
lib/config/supabase_config.dart
```

Sesuaikan URL dan Publishable Key dengan informasi proyek Supabase milik sendiri:

```dart
class SupabaseConfig {
  static const String supabaseUrl =
      'https://YOUR_PROJECT_ID.supabase.co';

  static const String publishableKey =
      'YOUR_SUPABASE_PUBLISHABLE_KEY';
}
```

Gunakan **Publishable Key**, bukan Secret Key atau Service Role Key. Jangan memasukkan secret key ke dalam aplikasi Flutter.

Pastikan tabel `my_itinerary` dan kebijakan Row Level Security (RLS) telah dikonfigurasi pada proyek Supabase.

### 5. Jalankan Aplikasi

Pastikan emulator atau perangkat Android telah terhubung, kemudian jalankan:

```bash
flutter run
```

## Pengujian

Menjalankan pemeriksaan kode:

```bash
flutter analyze
```

Menjalankan pengujian:

```bash
flutter test
```

## Tujuan Pengembangan

Proyek ini dikembangkan sebagai bagian dari tugas Ujian Tengah Semester (UTS) untuk menerapkan pengembangan aplikasi mobile menggunakan Flutter, pengelolaan state dengan Provider, integrasi REST API, serta operasi database CRUD menggunakan Supabase.

---

**Nusa Penida Travel Buddy**  
Explore Nusa Penida, Plan Your Journey!
