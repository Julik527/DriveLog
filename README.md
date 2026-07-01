# DriveLog


## Update 5.0: Klickbare und kontextbezogene Vorschläge

Die Vorschläge sind jetzt nicht nur sichtbar, sondern wirklich anklickbar. Beim Klick wird der Wert direkt in das Eingabefeld übernommen. Das wurde besonders für Windows/Desktop verbessert, damit der Fokuswechsel die Vorschläge nicht vorher ausblendet.

Außerdem sind die Vorschläge jetzt stärker zum jeweiligen Thema passend:

- Ortsfelder zeigen Fahrt-Orte wie Leutkirch, Lindau, Bad Saulgau, Ravensburg und Schul-/Bahnhof-Orte.
- Werkstattsuche zeigt Werkstatt-, Reifenservice- und Autohaus-Vorschläge.
- Fahrzeugauswahl ist anklickbar und sucht nach Marke, Modell, Kennzeichen, VIN und Kraftstoff.
- Fahrzeugmodelle passen zur Marke, z. B. Porsche -> 911/Cayenne/Panamera, Ford -> Focus/Kuga/Transit.
- Reifen- und Öl-Vorschläge passen stärker zu Marke, Modell und Kraftstoffart.
- Problemberichte zeigen passendere Vorschläge je nach Bauteil, z. B. Fahrwerk oder Bremse.
- Tankbelege zeigen regionale Tankstellen-Vorschläge für Leutkirch.

Neue/überarbeitete Dateien:

```text
lib/services/place_autocomplete_service.dart
lib/services/form_suggestion_service.dart
lib/widgets/location_autocomplete_field.dart
lib/widgets/suggestion_text_form_field.dart
lib/widgets/vehicle_autocomplete_field.dart
docs/FEATURE_UPDATE_CLICKABLE_CONTEXT_SUGGESTIONS.md
```


## Update 4.0: Autocomplete und professionelle Vorschläge

DriveLog enthält jetzt Eingabevorschläge wie bei modernen Karten- und Fuhrpark-Apps:

- Startort und Zielort mit Ortsvorschlägen
- lokale Vorschläge wie Leutkirch, Lindau, Ravensburg, Bad Saulgau
- Online-Ortssuche über OpenStreetMap/Nominatim, wenn Internet vorhanden ist
- suchbare Fahrzeugauswahl nach Marke, Modell, Kennzeichen oder VIN
- Vorschläge für Fahrzeugmarken, Modelle, Kraftstoff, Reifen und Öl
- Vorschläge für Tankstellen beim Tankbeleg
- Vorschläge für Problemberichte und Bauteile

Die Funktion ist in folgenden Dateien umgesetzt:

```text
lib/services/place_autocomplete_service.dart
lib/services/form_suggestion_service.dart
lib/widgets/location_autocomplete_field.dart
lib/widgets/suggestion_text_form_field.dart
lib/widgets/vehicle_autocomplete_field.dart
```


DriveLog ist eine echte Flutter-App mit Dart für ein Schulprojekt im Fach Programmiertechnik. Die App ist als digitales Fahrtenbuch und einfache Fuhrparkverwaltung aufgebaut.

## Ziel

DriveLog soll Fahrten, Fahrzeuge, Tankbelege, GPS-Daten, Werkstattinformationen und Fahrzeugprobleme lokal speichern und verständlich auswerten. Der Code bleibt bewusst schulgeeignet: sauber, kommentiert, nicht unnötig kompliziert.

## Neue Premium-Funktionen

- Premium-Dashboard im dunklen Porsche-inspirierten Design
- Fuhrparkverwaltung mit mehreren Fahrzeugen
- Marke, Modell, Kennzeichen und VIN pro Fahrzeug
- digitaler Fahrzeugschein mit Reifen, Höchstgeschwindigkeit, Anhängelast, Gewicht, Maßen und Öl-Spezifikation
- nächste Hauptuntersuchung / TÜV pro Fahrzeug
- Warnhinweise, wenn TÜV abgelaufen ist oder bald fällig wird
- Hinweisdialog vor GPS-Fahrten: Fahrzeug kontrollieren, Beschädigungen prüfen, TÜV beachten, Ölhinweis lesen
- GPS-Fahrt starten und beenden
- automatische Streckenmessung per GPS
- Dauer, Durchschnittsgeschwindigkeit und Höchstgeschwindigkeit
- Durchschnittsverbrauch, wenn verbrauchte Liter eingetragen werden
- Tankbelege mit Foto/OCR vorbereiten
- OCR-Vorschläge für Tankstelle, Liter und Preis auf Android/iOS
- manuelle Fallback-Eingabe für Windows
- Problem melden nach der Fahrt, z. B. Fahrwerk, Bremse, Motor, Reifen oder Geräusche
- Werkstätten in der Nähe suchen
- CSV-Export über Zwischenablage
- lokale Speicherung mit SharedPreferences

## Wichtiger technischer Hinweis

GPS und OCR sind echte App-Funktionen, aber sie brauchen Geräterechte und passende Plattformen. GPS funktioniert am besten auf einem echten Android-Gerät. ML-Kit-OCR funktioniert praktisch auf Android/iOS. Unter Windows bleibt die App stabil, aber OCR wird als manueller Fallback erklärt.

## Projekt starten

```powershell
cd "C:\Users\julik\OneDrive\Desktop\DriveLog_Flutter_Projekt\DriveLog"
flutter create --project-name drivelog .
flutter pub get
flutter run -d windows
```

Für Android:

```powershell
flutter devices
flutter run
```

## Tests

```powershell
flutter test
```

## Wichtig für die Präsentation

KI wurde genutzt, um Planung, Struktur, Code, Fehleranalyse, Tests und Dokumentation zu unterstützen. Die Schüler müssen trotzdem erklären können, wie die wichtigsten Dateien funktionieren:

- `main.dart`: startet die App
- `trip.dart`: Datenmodell für Fahrten
- `vehicle.dart`: Datenmodell für Fahrzeuge und Fahrzeugschein
- `fuel_receipt.dart`: Datenmodell für Tankbelege
- `issue_report.dart`: Datenmodell für Problemberichte
- `dashboard_screen.dart`: Startseite
- `gps_trip_screen.dart`: GPS-Tracking und Hinweis vor Fahrtbeginn
- `add_vehicle_screen.dart`: Fahrzeugdaten erfassen
- `add_fuel_receipt_screen.dart`: Tankbeleg erfassen und OCR starten
- `issue_report_list_screen.dart`: Probleme verwalten
- `trip_storage_service.dart`: Fahrten lokal speichern
- `receipt_ocr_service.dart`: Foto auswählen und Texterkennung ausführen

## Android/iOS Berechtigungen

Für GPS und OCR auf einem echten Handy nach dem Erstellen der Plattformdateien diese Datei lesen:

```text
docs/ANDROID_IOS_SETUP_GPS_OCR.md
```


## Release-Vorbereitung

Für eine echte Veröffentlichung wurden zusätzliche Release-Dateien ergänzt:

```text
docs/STORE_RELEASE_PLAN.md
docs/PLAY_STORE_LISTING_DRAFT.md
docs/PRIVACY_POLICY_DRAFT.md
docs/RELEASE_CHECKLIST.md
tools/build_android_release.ps1
tools/build_windows_release.ps1
```

Empfohlene Reihenfolge: Erst Android-APK intern testen, dann Google-Play-Closed-Test, danach Produktion. Windows kann zusätzlich als Desktop-Version gebaut werden.
