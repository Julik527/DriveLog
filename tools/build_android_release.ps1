# DriveLog Android Release Build
# Dieses Skript baut eine APK fuer Tests und ein AAB fuer Google Play.
# Vorher muss Flutter installiert sein.

Write-Host "DriveLog Android Release Build" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "Flutter wurde nicht gefunden. Bitte zuerst Flutter installieren." -ForegroundColor Red
  exit 1
}

flutter doctor
flutter pub get
flutter test

Write-Host "Baue Test-APK..." -ForegroundColor Cyan
flutter build apk --release

Write-Host "Baue Play-Store-App-Bundle..." -ForegroundColor Cyan
flutter build appbundle --release

Write-Host "Fertig." -ForegroundColor Green
Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk"
Write-Host "AAB: build\app\outputs\bundle\release\app-release.aab"
