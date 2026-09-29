# Forest Maps dari Windows 11

Project ini tetap merupakan aplikasi iOS native SwiftUI. Windows dipakai untuk **mengedit source code, Git, dan GitHub**. Proses kompilasi iOS dijalankan otomatis pada komputer macOS milik GitHub Actions.

## Yang bisa dilakukan dari Windows

- Edit Swift dengan Visual Studio Code.
- Menambah PDF sample/resource.
- Commit dan push source code dengan Git.
- Menjalankan build-check iOS melalui GitHub Actions.
- Download log build dan hasil `.app` simulator dari GitHub Actions.

## Yang tidak bisa dilakukan langsung di Windows

- Menjalankan Xcode.
- Menjalankan iOS Simulator milik Apple.
- Menandatangani/install build ke iPhone secara lokal memakai Xcode.

Untuk memasang aplikasi pada iPhone tanpa Mac pribadi, tahap berikutnya adalah mengaktifkan cloud signing/distribution (misalnya TestFlight) dengan akun Apple Developer. Source project ini sudah dipisahkan dari proses signing supaya aman dikerjakan dari Windows.

## Setup pertama

1. Extract ZIP.
2. Install Git for Windows dan Visual Studio Code.
3. Buka PowerShell di folder project.
4. Jalankan:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\windows-first-setup.ps1
```

5. Buat repository kosong di GitHub, misalnya `ForestMaps`.
6. Jalankan lagi dengan URL repository:

```powershell
.\scripts\windows-first-setup.ps1 -GitHubRepo "https://github.com/USERNAME/ForestMaps.git"
```

7. Di GitHub buka **Actions > iOS Build Check > Run workflow**.
8. Jika build hijau, source code berhasil dikompilasi pada macOS walaupun Anda bekerja dari Windows.

## Edit aplikasi

Buka dari PowerShell:

```powershell
.\scripts\open-in-vscode.ps1
```

Folder utama:

- `ForestMaps/App` — entry aplikasi.
- `ForestMaps/Views` — tampilan.
- `ForestMaps/Services` — GPS, penyimpanan, parser GeoPDF.
- `ForestMaps/Models` — model data.
- `ForestMaps/Resources` — file PDF dan resource offline.
- `project.yml` — konfigurasi project XcodeGen.

## Setelah mengubah kode

```powershell
git add .
git commit -m "Update Forest Maps"
git push
```

GitHub Actions akan menjalankan build lagi secara otomatis.

## Tentang file dari GitHub Actions

Workflow saat ini menghasilkan build untuk **iOS Simulator** sebagai pemeriksaan bahwa code dapat dikompilasi. File tersebut bukan IPA yang bisa langsung dipasang di iPhone. Build iPhone membutuhkan Apple code signing. Ini sengaja dipisahkan agar development dari Windows tidak memerlukan certificate di source repository.

## v0.7 background location

Versi 0.7 mengaktifkan background location pada `project.yml`. Build-check simulator tetap dapat dilakukan via GitHub Actions. Untuk menguji background GPS sesungguhnya diperlukan build signed pada iPhone fisik karena simulator/cloud build tidak merepresentasikan perilaku background GPS lapangan secara penuh.
