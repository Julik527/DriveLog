# Feature-Update: Fuhrpark, Tankbelege und Werkstätten

## Ziel der Erweiterung

DriveLog wurde von einer einfachen Fahrtenbuch-App zu einer kleinen Fuhrpark-App erweitert.

Der Grund: In einem echten Fahrtenbuch gibt es oft mehrere Fahrzeuge. Nur das Kennzeichen reicht nicht immer aus, weil man bei mehreren Autos schnell den Überblick verlieren kann. Deshalb speichert DriveLog jetzt Marke, Modell, Kennzeichen und VIN.

## Neue Funktionen

### Fahrzeuge

Ein Fahrzeug besitzt folgende Daten:

- Marke
- Modell
- Kennzeichen
- VIN / Fahrgestellnummer
- optionale Notiz

Die VIN ist wichtig, weil sie ein Fahrzeug eindeutig identifiziert. Kennzeichen können sich ändern, die VIN bleibt beim Fahrzeug.

### Fahrten mit Fahrzeugzuordnung

Beim Eintragen einer Fahrt wird jetzt ein Fahrzeug ausgewählt.

Dadurch kann die App später berechnen:

- wie viele Kilometer insgesamt gefahren wurden
- wie viele Kilometer ein bestimmtes Fahrzeug gefahren ist
- welche Fahrten zu welchem Auto gehören

### Tankbelege

Tankbelege können digital erfasst werden.

Gespeichert werden:

- Fahrzeug
- Datum
- Tankstelle
- Liter
- Gesamtpreis
- Kilometerstand
- Belegtext oder Belegnummer

Die App berechnet daraus automatisch den Preis pro Liter.

### Werkstätten in der Nähe

Die App kann Werkstätten in der Nähe eines Ortes suchen.

Standard-Ort ist Leutkirch. Die Suche braucht Internet.

## Bewusste Vereinfachung

Eine echte Kamera-OCR für Tankbelege wurde nicht eingebaut.

Begründung:

- OCR braucht zusätzliche Pakete
- OCR braucht Kamera- und Dateiberechtigungen
- OCR ist für Windows und Android unterschiedlich aufwendig
- OCR würde das Projekt deutlich schwerer machen

Für das Schulprojekt ist die aktuelle Lösung besser, weil sie stabil, erklärbar und testbar ist.

## Neue Dateien

```text
models/vehicle.dart
models/fuel_receipt.dart
models/workshop.dart
services/vehicle_storage_service.dart
services/fuel_receipt_storage_service.dart
services/workshop_search_service.dart
screens/vehicle_list_screen.dart
screens/add_vehicle_screen.dart
screens/fuel_receipt_list_screen.dart
screens/add_fuel_receipt_screen.dart
screens/workshop_nearby_screen.dart
```

## Erklärung für die Präsentation

Wir haben DriveLog erweitert, weil ein echtes Fahrtenbuch nicht nur einzelne Fahrten speichert. In einem Fuhrpark muss klar sein, welches Fahrzeug gefahren wurde. Deshalb gibt es jetzt eine Fahrzeugverwaltung mit Marke, Modell, Kennzeichen und VIN. Fahrten und Tankbelege werden dem passenden Fahrzeug zugeordnet. Die Werkstattsuche ist eine Zusatzfunktion, die mit Internet öffentliche Kartendaten nutzt.
