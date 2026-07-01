# Mögliche Lehrerfragen und Antworten

## Was ist DriveLog?

DriveLog ist eine Flutter-App für digitales Fahrtenbuch und Fuhrparkverwaltung.

## Warum Flutter?

Flutter eignet sich für echte Apps und erlaubt eine saubere Oberfläche mit Dart-Code.

## Was ist ein Datenmodell?

Ein Datenmodell beschreibt, welche Eigenschaften ein Objekt hat. Beispiel: Ein Fahrzeug hat Marke, Modell, Kennzeichen und VIN.

## Warum nutzt ihr SharedPreferences?

Für das Schulprojekt ist es einfach erklärbar und reicht für lokale Speicherung. Eine große Datenbank wäre für eine Woche unnötig kompliziert.

## Wie funktioniert GPS?

Die App fragt Standortrechte ab und bekommt Positionsdaten. Zwischen zwei Punkten wird die Entfernung berechnet. Daraus entstehen Strecke, Dauer, Durchschnittsgeschwindigkeit und Höchstgeschwindigkeit.

## Warum gibt es vor der Fahrt einen Hinweis?

Damit der Fahrer wichtige Punkte bestätigt: TÜV, Beschädigungen, bekannte Probleme und Ölhinweise. Das macht die App realistischer für einen Fuhrpark.

## Wie funktioniert OCR?

Ein Foto wird ausgewählt oder aufgenommen. ML Kit erkennt Text im Bild. Die App übernimmt daraus nur Vorschläge, weil OCR Fehler machen kann.

## Warum funktioniert OCR nicht gleich gut auf Windows?

Das verwendete ML-Kit-Plugin ist praktisch für Android und iOS gedacht. Auf Windows wird deshalb manuell erfasst oder ein Fallback genutzt.

## Was passiert, wenn der TÜV abgelaufen ist?

Die App zeigt eine Warnung im Dashboard und im Hinweisdialog vor der Fahrt.

## Was ist eine VIN?

Die VIN ist die Fahrgestellnummer. Sie identifiziert ein Fahrzeug eindeutig.

## Warum sind Fahrzeugdaten manuell?

Weil Daten wie Reifen, Gewichte oder Öl-Spezifikation rechtlich und technisch korrekt aus Fahrzeugschein, Handbuch oder Herstellerdaten übernommen werden müssen.

## Wo wurde KI genutzt?

KI wurde für Planung, Struktur, Code, Tests, Dokumentation und Erklärung genutzt. Der Code muss trotzdem verstanden und geprüft werden.


## Update: Autocomplete und Vorschläge

Die App wurde um professionelle Vorschlagsfelder erweitert. Beim Eingeben von Orten erscheinen passende Vorschläge, zum Beispiel Leutkirch, Lindau, Ravensburg oder Bad Saulgau. Zusätzlich kann DriveLog mit Internet echte Ortsvorschläge über OpenStreetMap/Nominatim laden. Fahrzeuge können über Marke, Modell, Kennzeichen oder VIN gesucht werden. Weitere Vorschläge gibt es bei Fahrzeugdaten, Tankstellen und Problemberichten.

Diese Erweiterung verbessert die Bedienung, bleibt aber verständlich, weil sie über eigene kleine Services und Widgets umgesetzt wurde.
