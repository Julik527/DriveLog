# DriveLog Windows Release Build
# Baut eine Windows-Release-Version. Visual Studio mit Desktop development with C++ wird benoetigt.

Write-Host "DriveLog Windows Release Build" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "Flutter wurde nicht gefunden. Bitte zuerst Flutter installieren." -ForegroundColor Red
  exit 1
}

flutter doctor
flutter pub get
flutter test
flutter build windows --release

Write-Host "Fertig." -ForegroundColor Green
Write-Host "Windows-Build: build\windows\x64\runner\Release"
