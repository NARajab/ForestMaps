# Forest Maps v0.7 — IPA test dari Windows

Project ini menambahkan workflow GitHub Actions **iOS IPA Test Build** untuk membuat paket IPA yang belum ditandatangani (`ForestMaps-Unsigned.ipa`). File ini ditujukan untuk uji sideload di iPhone menggunakan alat yang melakukan signing dengan Apple ID Anda, misalnya AltStore Classic/AltServer atau Sideloadly.

## 1. Update repository dari Windows

Salin/replace isi project ini ke folder repository Forest Maps Anda, lalu jalankan:

```powershell
cd F:\ForestMaps_iOS_WindowsReady
git status
git add .
git commit -m "Add unsigned IPA test build workflow"
git push origin main
```

## 2. Jalankan workflow

Di GitHub:

1. Buka repository `ForestMaps`.
2. Buka tab **Actions**.
3. Pilih **iOS IPA Test Build**.
4. Klik **Run workflow** > branch `main` > **Run workflow**.
5. Tunggu job **Build unsigned IPA for sideload testing** menjadi hijau.

Workflow juga otomatis berjalan ketika perubahan pada source aplikasi, `project.yml`, atau workflow ini di-push ke `main`.

## 3. Download IPA

Buka run yang sukses. Di bagian **Artifacts** unduh:

`ForestMaps-Unsigned-IPA`

GitHub mengunduh artifact sebagai ZIP. Extract ZIP tersebut. Di dalamnya ada:

`ForestMaps-Unsigned.ipa`

## 4. Install di iPhone

IPA ini **belum ditandatangani**. Itu disengaja. AltStore/Sideloadly akan menandatangani ulang aplikasi menggunakan Apple ID Anda saat sideload.

Untuk AltStore Classic:

1. Pastikan AltServer berjalan di Windows dan iPhone terhubung/terdeteksi.
2. Pastikan AltStore Classic sudah terpasang di iPhone.
3. Simpan `ForestMaps-Unsigned.ipa` ke iCloud Drive/Files atau transfer ke iPhone.
4. Di iPhone, buka AltStore > **My Apps** > tombol `+`.
5. Pilih `ForestMaps-Unsigned.ipa`.
6. Tunggu proses signing dan instalasi selesai.

Dengan Apple ID gratis, aplikasi sideload biasanya perlu di-refresh secara berkala. Kemampuan background location juga perlu diuji di perangkat fisik karena izin/capability runtime iOS tidak dapat divalidasi hanya dari GitHub Actions.

## Catatan

- Workflow ini tidak mengunggah aplikasi ke App Store Connect/TestFlight.
- Tidak ada certificate atau provisioning profile Apple yang disimpan di GitHub.
- Jangan memasukkan password Apple ID ke repository atau GitHub Actions secrets untuk workflow ini.
