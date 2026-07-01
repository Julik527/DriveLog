# Projektdokumentation DriveLog

## 1. Projektidee

DriveLog ist eine digitale Fahrtenbuch- und Fuhrpark-App. Sie wurde mit Flutter und Dart entwickelt und ist als echte App geplant, nicht als Web-App.

Die App soll Fahrten erfassen, Fahrzeuge verwalten, Tankbelege speichern, GPS-Fahrten messen, Probleme melden und wichtige Fahrzeugdaten anzeigen.

## 2. Zielgruppe

DriveLog eignet sich für kleine Fuhrparks, Schulprojekte, Familienfahrzeuge oder Betriebe, die mehrere Fahrzeuge übersichtlich dokumentieren möchten.

## 3. Hauptfunktionen

### Fahrtenbuch

- Fahrt manuell eintragen
- Startort und Zielort speichern
- Kilometer speichern
- Kategorie auswählen
- Fahrt bearbeiten
- Fahrt löschen
- Fahrtenliste durchsuchen und filtern
- CSV-Daten in Zwischenablage kopieren

### Fuhrpark

- mehrere Fahrzeuge anlegen
- Marke, Modell, Kennzeichen und VIN speichern
- digitaler Fahrzeugschein
- TÜV-Datum speichern
- Warnung bei abgelaufenem oder bald fälligem TÜV
- Öl-Spezifikation und Ölmenge speichern

### GPS

- GPS-Fahrt starten
- Hinweisdialog vor Fahrtbeginn bestätigen
- Strecke messen
- Dauer messen
- Durchschnittsgeschwindigkeit berechnen
- Höchstgeschwindigkeit speichern
- optional verbrauchte Liter eintragen
- Durchschnittsverbrauch berechnen

### Tankbelege

- Tankbeleg manuell erfassen
- Belegfoto über Kamera oder Galerie auswählen
- OCR-Texterkennung auf Android/iOS
- erkannte Werte als Vorschlag übernehmen
- Preis pro Liter berechnen

### Problemberichte

- Fahrzeugproblem melden
- Bauteil/Bereich eintragen
- Beschreibung speichern
- Dringlichkeit setzen
- Status: offen, in Prüfung, erledigt

## 4. Projektstruktur

```text
lib/
├── main.dart
├── models/
│   ├── trip.dart
│   ├── vehicle.dart
│   ├── fuel_receipt.dart
│   ├── issue_report.dart
│   └── workshop.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── add_trip_screen.dart
│   ├── gps_trip_screen.dart
│   ├── trip_list_screen.dart
│   ├── add_vehicle_screen.dart
│   ├── vehicle_list_screen.dart
│   ├── add_fuel_receipt_screen.dart
│   ├── fuel_receipt_list_screen.dart
│   ├── add_issue_report_screen.dart
│   ├── issue_report_list_screen.dart
│   ├── statistics_screen.dart
│   └── workshop_nearby_screen.dart
├── services/
│   ├── trip_storage_service.dart
│   ├── vehicle_storage_service.dart
│   ├── fuel_receipt_storage_service.dart
│   ├── issue_report_storage_service.dart
│   ├── gps_tracking_service.dart
│   ├── receipt_ocr_service.dart
│   ├── route_distance_service.dart
│   └── workshop_search_service.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    ├── action_tile.dart
    ├── pre_trip_check_dialog.dart
    ├── premium_panel.dart
    ├── stat_card.dart
    └── trip_card.dart
```

## 5. KI-Nutzung

KI wurde als Projekt-Agent genutzt. Sie hat geholfen bei:

- Planung
- Projektstruktur
- Code-Erstellung
- Code-Erklärung
- Testplanung
- Fehlersuche
- Dokumentation
- Präsentationsvorbereitung

Wichtig: Die KI ersetzt nicht das eigene Verständnis. Der Code wurde in kleine Dateien aufgeteilt, damit die Funktionen erklärbar bleiben.

## 6. Technische Entscheidungen

### Lokale Speicherung

DriveLog nutzt `shared_preferences`. Dadurch bleiben Daten nach dem Schließen der App erhalten. Für ein Schulprojekt ist das verständlicher als eine große Datenbank.

### GPS

GPS wird mit `geolocator` umgesetzt. Die App fragt Standortrechte ab und misst Positionsänderungen.

### OCR

OCR wird mit `image_picker` und `google_mlkit_text_recognition` umgesetzt. Die Funktion ist besonders für Android/iOS geeignet. Auf Windows gibt es einen manuellen Fallback.

### Design

Das Design ist dunkel, hochwertig und klar. Es orientiert sich an einem Premium-Auto-Stil: Schwarz, Gold, klare Karten, starke Kontraste.

## 7. Grenzen

- OCR ist nicht immer perfekt.
- Fahrzeugdaten müssen manuell aus echten Dokumenten übernommen werden.
- Die App ersetzt keine technische Prüfung und keine Werkstatt.
- GPS ist auf echten Geräten zuverlässiger als auf Desktop.

## 8. Fazit

DriveLog ist realistisch, erklärbar und trotzdem professionell. Die App zeigt, wie man mit Flutter ein echtes Projekt strukturiert entwickelt und sinnvoll mit KI unterstützt.


## Update: Autocomplete und Vorschläge

Die App wurde um professionelle Vorschlagsfelder erweitert. Beim Eingeben von Orten erscheinen passende Vorschläge, zum Beispiel Leutkirch, Lindau, Ravensburg oder Bad Saulgau. Zusätzlich kann DriveLog mit Internet echte Ortsvorschläge über OpenStreetMap/Nominatim laden. Fahrzeuge können über Marke, Modell, Kennzeichen oder VIN gesucht werden. Weitere Vorschläge gibt es bei Fahrzeugdaten, Tankstellen und Problemberichten.

Diese Erweiterung verbessert die Bedienung, bleibt aber verständlich, weil sie über eigene kleine Services und Widgets umgesetzt wurde.
