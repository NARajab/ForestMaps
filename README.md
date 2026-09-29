# Forest Maps — Windows-ready iOS Offline GeoPDF v0.7

Forest Maps adalah prototype aplikasi iOS native SwiftUI untuk membuka GeoPDF secara offline, menampilkan GPS iPhone di atas peta, waypoint, navigasi, KML/KMZ, pengukuran jarak/luas, dan GPS track survey.

## Baru di v0.7

- **Background GPS tracking**: track dapat tetap direkam saat aplikasi berada di background atau layar iPhone dikunci.
- Meminta izin lokasi **Always** saat tracking background dibutuhkan.
- Menampilkan indikator kesiapan background GPS.
- **Atribut survey track**: Petak, Plot, Kegiatan, dan Catatan.
- Metadata survey ikut diekspor ke KML melalui `ExtendedData`.
- Active track disimpan berkala ke file lokal agar data terakhir tidak mudah hilang jika aplikasi terhenti.
- Active track yang tersimpan dapat dipulihkan saat aplikasi dibuka kembali.

> Catatan iOS: background location tetap tunduk pada kebijakan iOS. Jika pengguna melakukan force-quit aplikasi dari app switcher, iOS dapat menghentikan delivery lokasi sampai aplikasi dibuka kembali.

## Workflow Windows

1. Extract folder ini dan replace isi project lama.
2. Dari PowerShell:

```powershell
cd F:\ForestMaps_iOS_WindowsReady
git status
git add .
git commit -m "Forest Maps v0.7 background tracking and survey attributes"
git push origin main
```

3. Buka GitHub → **Actions** → **iOS Build Check**.
4. Pastikan job **Build Forest Maps on macOS** berstatus `Success`.

## Background capability

`project.yml` sudah mengaktifkan:

- `UIBackgroundModes: location`
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

Ketika nanti project ditandatangani dan dipasang ke iPhone, iOS akan menampilkan permintaan izin lokasi sesuai aturan sistem.

## Sample

Sample bawaan: `Peta Upd Agustus 2026.pdf`.


## IPA test build dari Windows

Versi ini menyertakan workflow GitHub Actions **iOS IPA Test Build** yang membuat `ForestMaps-Unsigned.ipa` untuk uji sideload di iPhone. Lihat `docs/IPA_TEST_WINDOWS.md` untuk langkah lengkap.
