# Attendance App
### Flutter Developer Technical Test — HashMicro

---

## 👤 Author
**Adi Maulana**  
Flutter Developer

---

## 📱 Tentang Aplikasi

Aplikasi absensi mobile berbasis Flutter yang memungkinkan pengguna untuk melakukan manajemen lokasi dan absensi berbasis GPS dengan validasi radius.

---

## ✨ Fitur

### Manajemen Lokasi
- Tambah lokasi baru dengan nama
- Geotagging menggunakan GPS otomatis atau pilih manual di peta
- Tampilkan nama alamat berdasarkan koordinat (reverse geocoding)
- Hapus lokasi

### Absensi
- Check In & Check Out dengan slide button
- Validasi radius GPS maksimal **50 meter** dari titik lokasi
- Jika lebih dari 50 meter → absensi **ditolak (rejected)**
- Absensi yang ditolak hanya masuk riwayat, tidak mempengaruhi data absensi utama
- Menampilkan jarak user ke lokasi secara real-time

### Riwayat
- Riwayat semua aktivitas check in & check out
- Status approved / rejected per aktivitas
- Log tersimpan meski absensi ditolak

---

## 🏗️ Arsitektur

Aplikasi ini menggunakan **Clean Architecture** dengan pattern **BLoC (Business Logic Component)**.

```
lib/
├── core/
│   ├── constants/        # App constants & colors
│   ├── di/               # Dependency injection (get_it)
│   └── utils/            # Helper functions
├── data/
│   ├── datasources/      # SQLite local database
│   ├── models/           # Data models (fromMap/toMap)
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Business entities
│   ├── repositories/     # Abstract repository interfaces
│   └── usecases/         # Business logic use cases
├── presentation/
│   ├── blocs/            # BLoC (event, state, bloc)
│   ├── screens/          # UI screens
│   └── widgets/          # Reusable widgets
└── services/
    └── gps_service.dart  # GPS service
```

---

## 🛠️ Tech Stack

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework utama |
| flutter_bloc | State management |
| get_it | Dependency injection / Service locator |
| sqflite | Local database |
| geolocator | Mengambil koordinat GPS |
| flutter_osm_plugin | Peta OpenStreetMap |
| geocoding | Reverse geocoding (koordinat → alamat) |
| uuid | Generate unique ID |

---

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK >= 3.0.0
- Android SDK
- Device atau emulator Android (min SDK 21)

### Langkah

1. Clone atau extract source code
```bash
cd attendance_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Jalankan aplikasi
```bash
flutter run
```

4. Build APK
```bash
flutter build apk --release
```

APK tersedia di:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📋 Alur Penggunaan

1. **Tambah Lokasi** — Buka menu tambah lokasi, isi nama, pilih koordinat via GPS atau peta
2. **Pilih Lokasi** — Tap lokasi di list untuk masuk ke halaman absensi
3. **Check In** — Geser tombol ke kanan untuk check in (harus dalam radius 50m)
4. **Check Out** — Setelah check in, geser tombol untuk check out
5. **Riwayat** — Tap icon history untuk melihat riwayat absensi

---

## 📦 Struktur APK

File APK tersedia dalam folder Google Drive yang sama dengan source code.
