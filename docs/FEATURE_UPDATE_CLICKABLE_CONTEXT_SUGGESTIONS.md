# Update: Klickbare und kontextbezogene Vorschläge

## Ziel

Die App soll sich mehr wie eine echte professionelle Fuhrpark-App anfühlen. Deshalb wurden Eingabefelder erweitert, damit passende Vorschläge angezeigt und direkt übernommen werden können.

## Was wurde verbessert?

### 1. Vorschläge sind anklickbar

Vorher wurden Vorschläge angezeigt, aber auf Desktop konnte es so wirken, als wären sie nicht richtig anklickbar. Der Grund ist ein typisches UI-Problem: Wenn ein Textfeld den Fokus verliert, können Vorschläge verschwinden, bevor der Klick sauber verarbeitet wird.

Jetzt wird der Wert direkt beim Anklicken übernommen. Dadurch funktioniert das Verhalten auf Windows/Desktop zuverlässiger.

Betroffene Widgets:

```text
lib/widgets/location_autocomplete_field.dart
lib/widgets/suggestion_text_form_field.dart
lib/widgets/vehicle_autocomplete_field.dart
```

### 2. Orte sind kontextbezogen

Die App unterscheidet jetzt zwischen normalen Fahrten und Werkstattsuche.

Beispiele:

- Start/Ziel: Leutkirch im Allgäu, Bad Saulgau, Ravensburg, Lindau, Aulendorf Bahnhof
- Werkstatt: Werkstatt Leutkirch, Reifenservice Leutkirch, Autohaus Leutkirch

Die Online-Suche nutzt weiterhin OpenStreetMap/Nominatim, aber die lokalen Vorschläge sind sofort verfügbar.

### 3. Fahrzeug-Vorschläge sind professioneller

Bei der Fahrzeugauswahl kann nach diesen Daten gesucht werden:

- Marke
- Modell
- Kennzeichen
- VIN
- Kraftstoffart

Beim Fahrzeug anlegen passen die Modellvorschläge zur Marke.

Beispiele:

- Ford -> Focus Cabrio, Kuga, Transit Custom
- Porsche -> 911 Carrera, Cayenne, Panamera, Macan
- Volkswagen -> Golf, Passat, Tiguan, Transporter

### 4. Technische Fahrzeugdaten sind thematisch passender

Die Vorschläge für Reifen und Öl werden anhand von Marke, Modell und Kraftstoffart angepasst.

Beispiele:

- Porsche -> Porsche C30, Porsche A40, 0W-40, 5W-40
- Ford -> Ford WSS-M2C913-C/D, 5W-30
- Diesel -> DPF/Low-SAPS-Hinweis
- Elektro -> Hinweis, dass kein Motoröl nötig ist

Wichtig: Diese Vorschläge ersetzen keine echten Herstellerdaten. In der echten Anwendung müsste man die Werte aus Fahrzeugschein, CoC, Handbuch oder Herstellerdaten prüfen.

### 5. Problemberichte sind besser passend

Wenn als Bauteil „Fahrwerk“ ausgewählt wird, kommen passendere Vorschläge wie:

- Poltern vorne rechts
- Klackern beim Lenken
- Fahrzeug liegt unruhig

Wenn „Bremse“ ausgewählt wird, kommen Vorschläge wie:

- Bremsen quietschen
- Bremspedal vibriert
- Bremsweg wirkt länger

## Warum ist das gut für die Präsentation?

Die App wirkt nicht mehr wie ein einfaches Formular. Sie unterstützt den Nutzer aktiv bei der Eingabe. Gleichzeitig bleibt der Code erklärbar, weil die Vorschläge zentral in einer Service-Datei gesammelt sind.

## Wichtige Erklärung für den Lehrer

Die Vorschläge sind keine geheime KI im Hintergrund. Es sind bewusst gepflegte Listen und einfache Suchlogik. Das ist für ein Schulprojekt sinnvoll, weil es stabil, erklärbar und testbar bleibt.
