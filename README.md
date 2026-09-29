# Forest Maps — Windows-ready iOS Offline GeoPDF MVP v0.3

Forest Maps adalah aplikasi iOS SwiftUI offline-first untuk GeoPDF, GPS, waypoint dan pertukaran data dengan QGIS.

## v0.3
- Import waypoint **KML** dari Files iPhone.
- Import **KMZ** dan membaca file KML di dalamnya.
- Export seluruh waypoint ke **KML**.
- Export seluruh waypoint ke **KMZ**.
- Field `petak`, `plot`, dan `notes` dipertahankan melalui KML `ExtendedData`.
- Tetap offline; import/export tidak membutuhkan internet.
- Tetap mendukung workflow Windows -> GitHub -> macOS GitHub Actions.

## Update dari v0.2 di Windows
Salin isi ZIP v0.3 ke folder repo lokal ForestMaps, lalu:

```powershell
git add .
git commit -m "Forest Maps v0.3 KML KMZ import export"
git push origin main
```

Setelah push, cek tab **Actions** di GitHub dan pastikan `iOS Build Check` berstatus hijau.

## Workflow QGIS
### QGIS -> iPhone
Export titik dari QGIS sebagai KML/KMZ, kirim ke iPhone/Files, lalu Forest Maps -> Waypoints -> menu `...` -> Import KML/KMZ.

### iPhone -> QGIS
Forest Maps -> Waypoints -> menu `...` -> Export KML atau Export KMZ. File hasil dapat dibuka kembali di QGIS.
