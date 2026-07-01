# DriveLog Release-Plan

Dieser Plan erklärt, wie DriveLog von einem Schulprojekt zu einer nutzbaren App wird.

## Klare Empfehlung

Für die erste echte Veröffentlichung ist Android der beste Weg.

Reihenfolge:

1. App lokal sauber starten
2. Android-Version auf echtem Handy testen
3. Release-APK für Testnutzer bauen
4. Fehler beheben
5. Privacy Policy und Store-Texte vorbereiten
6. Google Play Console erstellen
7. Closed Test durchführen
8. App als Produktion veröffentlichen

## Plattformen

### Android APK

Geeignet für:

- schnelle Testversion
- Freunde, Mitschüler, Lehrer
- interne Vorführung

Vorteil:

- am schnellsten
- kein Store-Review nötig
- gut für Schulprojekt

Nachteil:

- Nutzer müssen APK manuell installieren
- wirkt weniger offiziell als Play Store

### Google Play Store

Geeignet für:

- öffentliche Nutzung
- professionelle Veröffentlichung
- echte App-Verteilung

Benötigt:

- Google Play Console Konto
- App Bundle `.aab`
- App-Signierung
- Store-Texte
- Screenshots
- Datenschutzangaben
- Closed Test, falls neues persönliches Entwicklerkonto

### Microsoft Store / Windows

Geeignet für:

- Windows-Laptops
- Schulvorführung
- Desktop-Nutzung

Benötigt:

- Windows-Build
- Microsoft-Entwicklerkonto
- Store-Paket oder Installer

### iOS App Store

Geeignet für:

- iPhone-Nutzer

Benötigt:

- Mac oder Cloud-Build-Umgebung
- Apple Developer Program
- App Store Connect
- TestFlight
- deutlich mehr Aufwand

## Was vor Release fertig sein muss

### Technisch

- App startet ohne Fehler
- Fahrten speichern und laden funktioniert
- Fahrzeuge speichern und laden funktioniert
- GPS-Fahrt ist stabil
- Tankbeleg-Fallback funktioniert auch ohne OCR
- Autocomplete ist anklickbar
- TÜV-Hinweise funktionieren
- Tests laufen mit `flutter test`
- Android-Berechtigungen sind korrekt gesetzt
- App-Version ist gesetzt
- Paketname ist eindeutig, z. B. `de.drivelog.app`

### Datenschutz

DriveLog kann sensible Daten enthalten:

- Standortdaten
- Fahrten
- Fahrzeugdaten
- Kennzeichen
- VIN
- Tankbelege
- Problemberichte

Deshalb braucht die App vor einer öffentlichen Veröffentlichung eine klare Datenschutzerklärung.

### Inhaltlich

- keine Testdaten im Release
- keine Schülernamen im Code
- keine privaten Kennzeichen in Screenshots
- keine echten VINs in Screenshots
- klare Erklärung, dass gespeicherte Daten lokal verarbeitet werden, sofern keine Cloud eingebaut ist

## Empfohlener Veröffentlichungspfad

### Woche 1: Schulversion

- Windows-Version starten
- Android-Test auf einem Handy
- Präsentation halten
- Dokumentation abgeben

### Woche 2: Interne Testversion

- APK bauen
- an 5 bis 10 Tester geben
- Feedback sammeln
- Bugs beheben

### Woche 3: Play Store Vorbereitung

- App-Icon erstellen
- Screenshots erstellen
- Store-Beschreibung schreiben
- Privacy Policy online stellen
- Data-Safety-Angaben vorbereiten

### Woche 4: Closed Test

- Tester einladen
- reale Nutzung prüfen
- Abstürze und Feedback auswerten

### Danach: Veröffentlichung

- App Bundle hochladen
- Produktionszugang beantragen
- Store Review abwarten
- Version 1.0 veröffentlichen

## Wichtig

DriveLog sollte nicht direkt als öffentliche App veröffentlicht werden, wenn GPS, OCR und Fahrzeugdaten noch nicht auf mehreren Geräten getestet wurden. Erst testen, dann veröffentlichen. Das wirkt professioneller und verhindert schlechte Bewertungen.
