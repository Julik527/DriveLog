# DriveLog Feature-Update: Autocomplete und intelligente Vorschläge

## Ziel

DriveLog wurde um professionelle Eingabevorschläge erweitert. Dadurch fühlt sich die App mehr wie eine echte Fuhrpark- oder Karten-App an.

## Neue Funktionen

### 1. Anklickbare Vorschläge

Die Vorschläge sind jetzt nicht nur sichtbar, sondern direkt anklickbar. Beim Klick wird der Wert sofort ins Eingabefeld übernommen.

Das ist besonders für Windows/Desktop wichtig, weil dort ein Textfeld beim Anklicken anderer Elemente schnell den Fokus verliert. Die App übernimmt den Vorschlag deshalb direkt beim Anklicken.

### 2. Ortsvorschläge bei Start und Ziel

Beim Eintragen einer Fahrt zeigen Startort und Zielort passende Vorschläge an.

Beispiel:

Wenn man `L` tippt, erscheinen passende Orte wie:

- Leutkirch im Allgäu
- Leutkirch Bahnhof
- Lindau
- Lindau Insel
- weitere Orte aus der Umgebung oder aus der Online-Suche

Die App nutzt zwei Ebenen:

1. lokale Standardvorschläge für schnelle Bedienung
2. Online-Vorschläge über OpenStreetMap/Nominatim, wenn Internet verfügbar ist

Falls kein Internet vorhanden ist, funktionieren die lokalen Vorschläge trotzdem.

### 3. Kontextbezogene Vorschläge

Die App zeigt nicht überall die gleichen Vorschläge. Sie unterscheidet den fachlichen Kontext.

Beispiele:

- Fahrten: Orte, Bahnhöfe, Städte, häufige Ziele
- Werkstattsuche: Werkstatt Leutkirch, Autohaus Leutkirch, Reifenservice Leutkirch
- Fahrzeuganlage: Marken, Modelle, Reifen, Öl, Kraftstoff
- Tankbelege: Tankstellen in der Region
- Problemberichte: Fahrwerk, Bremse, Motor, Reifen und passende Problemtexte

### 4. Suchbare Fahrzeugauswahl

Die Fahrzeugauswahl ist nicht mehr nur ein einfaches Dropdown.

Man kann jetzt suchen nach:

- Marke
- Modell
- Kennzeichen
- VIN / Fahrgestellnummer
- Kraftstoffart

Das ist für einen Fuhrpark wichtig, weil mehrere Fahrzeuge vorhanden sein können und man nicht jedes Fahrzeug sofort am Kennzeichen erkennt.

### 5. Vorschläge bei Fahrzeugdaten

Beim Anlegen eines Fahrzeugs gibt es Vorschläge für:

- Marke
- Modell passend zur Marke
- Kraftstoffart
- Reifengröße passend zu Marke/Modell
- Öl-Spezifikation passend zu Marke/Kraftstoff
- bekannte Beschädigungen oder Hinweise
- Fahrzeugschein-Notizen

Beispiel:

- Ford -> Focus Cabrio, Kuga, Transit Custom
- Porsche -> 911 Carrera, Cayenne, Panamera, Macan
- Diesel -> Low-SAPS/DPF-Hinweis beim Öl

### 6. Vorschläge bei Tankbelegen

Bei Tankbelegen gibt es Vorschläge für bekannte Tankstellen, zum Beispiel:

- Aral Leutkirch
- Shell Leutkirch
- AVIA Leutkirch
- JET Leutkirch

OCR bleibt weiterhin möglich. Die Vorschläge helfen zusätzlich, wenn der Nutzer manuell korrigieren muss.

### 7. Vorschläge bei Problemberichten

Beim Melden eines Problems gibt es Vorschläge für:

- Kurztitel
- Bauteil / Bereich
- Beschreibung

Beispiele:

- Fahrwerk -> Poltern vorne rechts, Klackern beim Lenken
- Bremse -> Bremsen quietschen, Bremspedal vibriert
- Motor -> Motor ruckelt, Ölverlust sichtbar

## Technische Umsetzung

Wichtige Dateien:

```text
lib/services/place_autocomplete_service.dart
lib/services/form_suggestion_service.dart
lib/widgets/location_autocomplete_field.dart
lib/widgets/suggestion_text_form_field.dart
lib/widgets/vehicle_autocomplete_field.dart
```

## Warum diese Lösung gut für die Schule ist

Die Funktion wirkt professionell, bleibt aber erklärbar:

- einfache lokale Listen für Standardvorschläge
- ein Service für Online-Ortssuche
- eigene Widgets für wiederverwendbare Eingabefelder
- kontextbezogene Vorschläge ohne komplizierte KI-Logik
- keine übertriebene Architektur
- Fallback ohne Internet

## Wichtig

Die Ortssuche braucht für Online-Vorschläge Internet. Ohne Internet zeigt DriveLog lokale Beispielorte an.

Fahrzeugdaten wie Öl, Reifen oder zulässige Werte müssen in einer echten Anwendung immer mit Fahrzeugschein, CoC, Handbuch oder Herstellerdaten abgeglichen werden. Die Vorschläge helfen bei der Eingabe, ersetzen aber keine offizielle Prüfung.
