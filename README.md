# Forest Maps — Windows-ready iOS Offline GeoPDF MVP

Forest Maps adalah prototype aplikasi iOS native SwiftUI untuk membuka **GeoPDF offline**, menampilkan **GPS iPhone di atas peta**, dan menyimpan peta lokal tanpa internet.

Sample yang disertakan: `Peta Upd Agustus 2026.pdf`.

## Khusus pengguna Windows

Project ini sekarang sudah disiapkan dengan workflow **Windows → GitHub → macOS cloud build**.

Anda tidak perlu Mac untuk mengedit source code. Gunakan Visual Studio Code dan Git dari Windows. Setiap push ke GitHub dapat diperiksa/di-build otomatis menggunakan GitHub Actions pada runner macOS.

Mulai dari:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\windows-first-setup.ps1
```

Panduan lengkap: `docs/WINDOWS.md`.

## Fitur MVP

- Import PDF dari Files iPhone.
- Validasi metadata georeference ArcGIS (`GPTS` + `BBox`).
- Penyimpanan PDF ke Documents/OfflineMaps.
- Viewer PDF menggunakan PDFKit.
- GPS realtime menggunakan CoreLocation.
- Marker GPS di atas GeoPDF.
- Status di dalam/di luar cakupan peta.
- Tombol recenter.
- Sample peta Agustus 2026 disertakan.

## Cloud build

Workflow: `.github/workflows/ios-build.yml`

Workflow akan:

1. Menjalankan macOS runner.
2. Menginstall XcodeGen.
3. Membuat `ForestMaps.xcodeproj` dari `project.yml`.
4. Menjalankan `xcodebuild` untuk iOS Simulator tanpa code signing.
5. Mengunggah build log dan artifact simulator.

## Instal ke iPhone

Build iPhone asli membutuhkan Apple code signing. Jadi tahap berikutnya setelah build-check stabil adalah menambahkan distribusi cloud/TestFlight dengan Apple Developer Account. Anda tetap dapat mengelola semuanya dari Windows; proses Xcode/signing berjalan di cloud macOS.

## Roadmap

- v0.2: waypoint + nama petak/plot + local storage.
- v0.3: navigasi titik (jarak + bearing) dan track log.
- v0.4: import/export KML/KMZ/GeoJSON.
- v0.5: ukur garis/polygon + luas hektar.
- v0.6: foto geotag + form PMA/Monev.
- v1.0: offline-first database + sinkronisasi.

## v0.2 — Waypoint & Navigasi Offline

Versi ini menambahkan fungsi lapangan yang tetap berjalan tanpa internet:

- Simpan waypoint dari posisi GPS iPhone saat ini.
- Field nama titik, Petak, Plot, dan catatan.
- Waypoint disimpan permanen lokal dalam `Application Support/waypoints.json`.
- Marker waypoint tampil di atas GeoPDF.
- Daftar waypoint offline pada tab **Waypoint**.
- Pilih waypoint sebagai target navigasi.
- Tampilkan jarak, bearing, arah mata angin, dan panah relatif terhadap heading iPhone.
- Hapus waypoint dengan swipe.

### Update dari Windows

Setelah mengganti folder project dengan versi ini, jalankan dari PowerShell:

```powershell
git add .
git commit -m "Forest Maps v0.2 waypoint and offline navigation"
git push origin main
```

Push ke `main` akan memicu workflow GitHub Actions untuk melakukan build check pada macOS.
