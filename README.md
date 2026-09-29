# Forest Maps — Windows-ready iOS Offline GeoPDF MVP v0.5

Forest Maps adalah aplikasi iOS SwiftUI offline-first untuk GeoPDF, GPS, waypoint, navigasi lapangan, pertukaran KML/KMZ dengan QGIS, serta pengukuran jarak dan luas langsung pada peta.

## Baru di v0.5 — Measure Tool
- **Ukur Jarak**: ketuk titik-titik di GeoPDF dan aplikasi menghitung total panjang garis.
- **Ukur Luas**: ketuk minimal 3 titik untuk membentuk polygon.
- Luas tampil otomatis dalam **m²** atau **Ha**.
- Keliling polygon juga dihitung.
- Titik ukur dan garis/polygon tampil langsung di atas GeoPDF.
- Tombol **Undo**, **Hapus**, dan **Selesai**.
- Semua proses pengukuran bekerja **offline**.

## Fitur yang tetap tersedia
- GeoPDF offline + GPS iPhone.
- Waypoint offline dengan Nama, Petak, Plot, dan Catatan.
- Marker waypoint interaktif di atas GeoPDF.
- Navigasi offline: jarak, bearing, arah mata angin dan panah relatif terhadap heading iPhone.
- Import KML/KMZ dari QGIS.
- Export waypoint ke KML/KMZ.
- Workflow pengembangan Windows -> GitHub -> macOS GitHub Actions.

## Update dari v0.4 di Windows
Extract ZIP v0.5 dan salin seluruh isinya ke folder repo lokal ForestMaps. Pilih **Replace files in destination**, lalu:

```powershell
cd F:\ForestMaps_iOS_WindowsReady
git status
git add .
git commit -m "Forest Maps v0.5 measure distance and area"
git push origin main
```

Setelah push, buka **GitHub -> ForestMaps -> Actions** dan pastikan `iOS Build Check` berstatus hijau.

## Cara memakai Measure Tool
1. Buka salah satu GeoPDF.
2. Tekan ikon **ruler** di toolbar.
3. Pilih **Ukur Jarak** atau **Ukur Luas**.
4. Ketuk peta untuk menambahkan vertex.
5. Hasil dihitung otomatis pada kartu pengukuran.
6. Gunakan **Undo** bila titik terakhir salah, atau **Hapus** untuk mengulang.
7. Tekan **Selesai** agar tap pada peta kembali berfungsi normal.

> Catatan: perhitungan luas memakai proyeksi bidang lokal yang sesuai untuk polygon lapangan berskala beberapa kilometer. GeoPDF tetap menjadi referensi posisi utama.
