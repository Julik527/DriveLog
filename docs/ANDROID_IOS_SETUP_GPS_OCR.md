# Android/iOS Setup für GPS und OCR

Diese App enthält Code für GPS und OCR. Damit Android/iOS alles erlauben, müssen nach `flutter create --project-name drivelog .` eventuell Plattformdateien geprüft werden.

## Android

Datei:

```text
android/app/src/main/AndroidManifest.xml
```

Innerhalb von `<manifest>` sollten diese Berechtigungen stehen:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
```

Für ML Kit Text Recognition ist außerdem wichtig:

- `minSdkVersion` mindestens 21
- bei neuen Versionen häufig `compileSdkVersion` 35 und `targetSdkVersion` 35

## iOS

Datei:

```text
ios/Runner/Info.plist
```

Dort braucht man Beschreibungen für Kamera, Fotos und Standort, z. B.:

```xml
<key>NSCameraUsageDescription</key>
<string>DriveLog nutzt die Kamera zum Scannen von Tankbelegen.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>DriveLog nutzt die Galerie zum Auswählen von Tankbeleg-Fotos.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>DriveLog nutzt Standortdaten zum Messen von GPS-Fahrten.</string>
```

## Schulhinweis

Für die Präsentation reicht es sauber zu erklären:

- GPS braucht Standortberechtigung.
- OCR braucht Kamera/Galerie und funktioniert hauptsächlich auf Android/iOS.
- Windows bleibt als Vorführplattform stabil, nutzt aber bei OCR den manuellen Fallback.
