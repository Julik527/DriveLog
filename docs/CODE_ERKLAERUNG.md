# Code-Erklärung DriveLog

## main.dart

Startet die App und lädt das Design aus `app_theme.dart`.

## vehicle.dart

Beschreibt ein Fahrzeug. Wichtige Felder:

- `brand`: Marke
- `model`: Modell
- `licensePlate`: Kennzeichen
- `vin`: Fahrgestellnummer
- `huDueDate`: nächster TÜV/HU-Termin
- `tireSizes`: zugelassene Reifen
- `oilSpecification`: geeignetes Öl
- `knownDamage`: bekannte Schäden

Wichtige Methoden:

- `huStatus()`: prüft, ob TÜV gültig, bald fällig oder abgelaufen ist
- `preTripWarnings()`: erzeugt Hinweise vor einer Fahrt
- `toJson()` und `fromJson()`: speichern und laden Fahrzeugdaten

## trip.dart

Beschreibt eine Fahrt. Neben Start, Ziel, Kilometer und Kategorie gibt es GPS-Werte:

- `durationSeconds`
- `maxSpeedKmh`
- `fuelUsedLiters`
- `createdByGps`

Wichtige Berechnungen:

- `averageSpeedKmh`
- `averageConsumptionL100km`

## gps_trip_screen.dart

Startet und beendet eine GPS-Fahrt.

Ablauf:

1. Fahrzeug auswählen
2. Hinweisdialog bestätigen
3. GPS-Berechtigung prüfen
4. Positionsdaten sammeln
5. Strecke und Geschwindigkeit berechnen
6. Fahrt speichern
7. optional Problem melden

## pre_trip_check_dialog.dart

Zeigt vor einer GPS-Fahrt die Sicherheits- und Fahrzeughinweise. Die Fahrt kann erst nach Bestätigung gestartet werden.

## add_vehicle_screen.dart

Formular zum Anlegen eines Fahrzeugs. Hier werden auch Fahrzeugschein-Daten wie Reifen, Gewichte, Maße, Öl und TÜV eingetragen.

## add_fuel_receipt_screen.dart

Tankbeleg erfassen. Der Nutzer kann manuell eintragen oder ein Foto/Bild auswählen. Auf Android/iOS kann OCR Text erkennen.

## receipt_ocr_service.dart

Kümmert sich um Fotoauswahl und Texterkennung. Die Methode `scanReceipt()` gibt OCR-Text und Vorschläge zurück.

## issue_report.dart

Beschreibt eine Problem-Meldung am Fahrzeug. Beispiele: Fahrwerk, Bremse, Reifen, Motor.

## issue_report_list_screen.dart

Zeigt alle Problemberichte und erlaubt Statusänderungen: offen, in Prüfung, erledigt.

## Storage-Services

Die Services speichern Daten lokal mit SharedPreferences:

- `TripStorageService`
- `VehicleStorageService`
- `FuelReceiptStorageService`
- `IssueReportStorageService`

Dadurch bleiben Daten nach dem Schließen der App erhalten.


## Update: Autocomplete und Vorschläge

Die App wurde um professionelle Vorschlagsfelder erweitert. Beim Eingeben von Orten erscheinen passende Vorschläge, zum Beispiel Leutkirch, Lindau, Ravensburg oder Bad Saulgau. Zusätzlich kann DriveLog mit Internet echte Ortsvorschläge über OpenStreetMap/Nominatim laden. Fahrzeuge können über Marke, Modell, Kennzeichen oder VIN gesucht werden. Weitere Vorschläge gibt es bei Fahrzeugdaten, Tankstellen und Problemberichten.

Diese Erweiterung verbessert die Bedienung, bleibt aber verständlich, weil sie über eigene kleine Services und Widgets umgesetzt wurde.
