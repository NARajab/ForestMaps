param(
    [string]$GitHubRepo = ""
)

$ErrorActionPreference = "Stop"
Write-Host "Forest Maps - Windows-first setup" -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git belum ditemukan." -ForegroundColor Yellow
    Write-Host "Install Git for Windows: https://git-scm.com/download/win"
    exit 1
}

if (-not (Test-Path "project.yml")) {
    Write-Host "Jalankan script ini dari folder ForestMaps_iOS_WindowsReady." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path ".git")) {
    git init
    git branch -M main
}

git add .
$status = git status --porcelain
if ($status) {
    try {
        git commit -m "Prepare Forest Maps for Windows + cloud iOS build"
    } catch {
        Write-Host "Commit belum berhasil. Jika Git meminta nama/email, jalankan:" -ForegroundColor Yellow
        Write-Host '  git config --global user.name "Nama Anda"'
        Write-Host '  git config --global user.email "email@anda.com"'
        Write-Host "Lalu jalankan script ini lagi."
        exit 1
    }
}

if ($GitHubRepo) {
    $existing = git remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0) {
        git remote set-url origin $GitHubRepo
    } else {
        git remote add origin $GitHubRepo
    }
    git push -u origin main
    Write-Host "Source code sudah dikirim ke GitHub." -ForegroundColor Green
    Write-Host "Buka tab Actions pada repository, lalu pilih 'iOS Build Check'."
} else {
    Write-Host "Setup lokal selesai." -ForegroundColor Green
    Write-Host "Buat repository GitHub kosong, lalu jalankan:" -ForegroundColor Cyan
    Write-Host '.\scripts\windows-first-setup.ps1 -GitHubRepo "https://github.com/USERNAME/ForestMaps.git"'
}
