$ErrorActionPreference = "Stop"
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Host "Perintah 'code' belum tersedia. Install Visual Studio Code lalu aktifkan command line PATH." -ForegroundColor Yellow
    exit 1
}
code .
