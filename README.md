# Forest Maps v0.6 — Windows-ready iOS Offline GeoPDF

Forest Maps adalah prototype aplikasi iOS native SwiftUI untuk pekerjaan lapangan offline menggunakan GeoPDF, GPS, waypoint, navigasi, KML/KMZ, pengukuran jarak/luas, dan perekaman track GPS.

## Baru di v0.6 — GPS Track Recorder

- Mulai/Stop perekaman track langsung dari layar GeoPDF.
- Nama track sebelum mulai merekam.
- Garis track tampil realtime di atas GeoPDF.
- Jarak tempuh dan durasi tampil selama perekaman.
- Filter sederhana untuk mengurangi titik GPS buruk/berulang.
- Track tersimpan lokal/offline di iPhone.
- Tab **Track** untuk melihat riwayat.
- Export setiap track ke **KML** agar dapat dibuka kembali di QGIS/Google Earth.

> Catatan: v0.6 merekam saat aplikasi/layar peta aktif. Background GPS penuh akan ditambahkan pada versi lanjutan karena memerlukan capability dan kebijakan penggunaan lokasi tambahan.

## Fitur dari versi sebelumnya

- Import dan simpan GeoPDF offline.
- Posisi GPS di atas GeoPDF.
- Waypoint offline, detail Petak/Plot/Catatan, navigasi jarak + bearing.
- Import/export KML dan KMZ.
- Marker waypoint interaktif.
- Ukur jarak dan polygon luas dalam m²/Ha.

## Workflow Windows

1. Edit source di Windows/VS Code.
2. Commit dan push ke GitHub.
3. GitHub Actions menjalankan build check pada macOS runner.
4. Setelah fitur stabil, tambahkan Apple signing/TestFlight untuk instalasi iPhone.

Untuk update repo yang sudah ada:

```powershell
cd F:\ForestMaps_iOS_WindowsReady
git status
git add .
git commit -m "Forest Maps v0.6 GPS track recorder"
git push origin main
```

## Sample map

Project tetap menyertakan `Peta Upd Agustus 2026.pdf` sebagai sample GeoPDF.
