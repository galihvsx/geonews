# GeoCam News

Aplikasi GeoCam News adalah aplikasi mobile berbasis Flutter yang menggabungkan fitur kamera, lokasi GPS, dan berita dalam satu aplikasi. App Challenge.

## Fitur Utama

### 1. Fitur GeoCam

- **Lokasi Pengguna**: Menampilkan lokasi pengguna (latitude & longitude) dengan izin lokasi
- **Kamera**: Mengambil foto dengan dua opsi - kamera Android native atau kamera custom UI
- **Penyimpanan Lokal**: Menyimpan lokasi dan foto ke penyimpanan lokal perangkat
- **Reset Data**: Menghapus data lokasi dan foto yang tersimpan

### 2. Fitur Berita

- **Daftar Berita**: Menampilkan daftar berita dari API JSONPlaceholder
- **Detail Berita**: Tampilan detail berita ketika item diklik
- **Bookmark**: Menyimpan berita favorit ke penyimpanan lokal
- **Pull-to-Refresh**: Menyegarkan daftar berita dengan gestur tarik ke bawah
- **Infinite Scroll**: Memuat lebih banyak berita saat pengguna mencapai akhir daftar

### 3. Fitur Tambahan (Bonus)

- **Dark Mode**: Tema gelap dan terang yang dapat diubah pengguna
- **Animasi UI**: Animasi transisi yang halus menggunakan flutter_staggered_animations
- **Error Handling**: Penanganan kesalahan yang komprehensif untuk izin, API, dan masalah lainnya

## Screenshot Aplikasi

[screenshot belum tersedia]

## Cara Menggunakan

### Prasyarat

- Flutter SDK 3.6.2 atau lebih tinggi
- Dart 3.0.0 atau lebih tinggi
- Android Studio / VS Code dengan ekstensi Flutter
- Perangkat Android 7.0+ / iOS 11.0+ (fisik atau emulator)

### Instalasi dan Menjalankan Aplikasi

1. **Clone repository**

   ```bash
   git clone https://github.com/galihvsx/geonews.git
   cd geocam_news
   ```

2. **Mengambil dependencies**

   ```bash
   flutter pub get
   ```

3. **Menjalankan aplikasi dalam mode debug**

   ```bash
   flutter run
   ```

4. **Build APK untuk Android**

   ```bash
   flutter build apk --release
   ```

   APK akan tersedia di `build/app/outputs/flutter-apk/app-release.apk`

## Library dan Teknologi

### State Management

- **Provider**: Untuk manajemen state aplikasi

### Fitur Kamera dan Lokasi

- **camera**: Plugin kamera Flutter untuk tampilan kamera kustom
- **image_picker**: Untuk mengambil gambar dari galeri atau kamera Android native
- **geolocator**: Untuk mendapatkan lokasi perangkat
- **permission_handler**: Untuk mengelola izin aplikasi (kamera, lokasi, penyimpanan)

### Penyimpanan Lokal

- **shared_preferences**: Untuk menyimpan data sederhana secara lokal
- **path_provider**: Untuk mendapatkan lokasi penyimpanan pada perangkat

### Jaringan dan API

- **dio**: HTTP client untuk berkomunikasi dengan API berita
- **http**: Alternatif HTTP client
- **cached_network_image**: Untuk loading dan caching gambar

### UI dan Animasi

- **flutter_staggered_animations**: Untuk animasi daftar dan transisi
- **shimmer**: Untuk efek loading placeholder
- **intl**: Untuk lokalisasi dan format tanggal

### Lainnya

- **share_plus**: Untuk berbagi berita

## Arsitektur dan Pola Desain

Aplikasi menggunakan arsitektur **MVVM** (Model-View-ViewModel) dengan struktur berikut:

- **Models**: Representasi data aplikasi (NewsModel, GeoCamModel)
- **Views**: Tampilan UI (NewsScreen, GeoCamScreen)
- **ViewModels**: Penghubung antara Model dan View, mengelola state dan logika bisnis
- **Services**: Layer untuk interaksi dengan API, penyimpanan lokal, dan perangkat

### Struktur Folder

```
lib/
├── models/          # Data models
├── services/        # API, storage, location, camera services
├── utils/           # Helper utilities
├── view_models/     # ViewModels untuk state management
├── views/           # UI screens
├── widgets/         # Reusable widgets
└── main.dart        # Entry point
```

## Workflow Pengembangan (SDLC)

Pengembangan aplikasi ini mengikuti proses Agile dengan tahapan berikut:

1. **Perencanaan**:
   - Analisis persyaratan dari dokumen PRD
   - Menyusun prioritas fitur

2. **Desain**:
   - Perancangan arsitektur aplikasi (MVVM)
   - Menentukan struktur data dan API

3. **Implementasi**:
   - Pengembangan fitur GeoCam (lokasi dan kamera)
   - Pengembangan fitur Berita
   - Integrasi API
   - Implementasi penyimpanan lokal

4. **Pengujian**:
   - Unit testing
   - Manual testing pada perangkat berbeda (Android 10-14)
   - Pengujian izin dan error handling

5. **Deployment**:
   - Build APK
   - Persiapan release

6. **Pemeliharaan**:
   - Perbaikan bug
   - Peningkatan performa

## Permissions

Aplikasi memerlukan beberapa izin untuk berfungsi:

- **Kamera**: Untuk mengambil foto
- **Lokasi**: Untuk mendapatkan lokasi pengguna
- **Penyimpanan**: Untuk menyimpan foto

Aplikasi menangani izin dengan strategi berikut:

- Meminta izin saat pertama kali diperlukan
- Menampilkan dialog penjelasan jika izin ditolak
- Menyediakan opsi untuk membuka pengaturan aplikasi jika izin ditolak secara permanen
