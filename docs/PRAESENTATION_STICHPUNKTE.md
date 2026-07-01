# Präsentation DriveLog

## Folie 1: Titel

DriveLog  
Digitale Fahrtenbuch- und Fuhrpark-App mit Flutter und Dart

## Folie 2: Problem

- Fahrten werden oft unübersichtlich dokumentiert.
- Bei mehreren Fahrzeugen verliert man schnell den Überblick.
- Tankbelege, TÜV, Schäden und Fahrzeugdaten liegen oft getrennt.

## Folie 3: Lösung

DriveLog bündelt diese Informationen in einer App:

- Fahrtenbuch
- Fuhrpark
- Tankbelege
- GPS-Fahrten
- TÜV-Hinweise
- Problemberichte
- Statistik

## Folie 4: Technik

- Flutter
- Dart
- lokale Speicherung mit SharedPreferences
- GPS mit Geolocator
- OCR mit Image Picker und ML Kit
- Karten-/Routendaten über öffentliche Dienste

## Folie 5: KI-Agent

Ein KI-Agent ist ein Hilfssystem, das Aufgaben strukturiert unterstützt.

Bei DriveLog half der KI-Agent bei:

- Planung
- Code-Struktur
- Fehleranalyse
- Tests
- Dokumentation
- Präsentation

Wichtig: Die Gruppe muss den Code selbst verstehen und erklären.

## Folie 6: Funktionen

- Fahrzeug anlegen
- Fahrzeugschein-Daten speichern
- Fahrt manuell erfassen
- GPS-Fahrt starten
- Tankbeleg scannen
- Probleme melden
- Statistik anzeigen

## Folie 7: Vor-Fahrt-Hinweis

Vor einer GPS-Fahrt erscheint ein Hinweis:

- Fahrzeug auf Schäden kontrollieren
- TÜV prüfen
- bekannte Probleme beachten
- Öl-Spezifikation sehen
- Start erst nach Bestätigung

## Folie 8: OCR und Tankbelege

- Foto oder Bild auswählen
- OCR erkennt Text
- App schlägt Tankstelle, Liter und Preis vor
- Nutzer prüft und speichert

## Folie 9: Testen

Getestet werden:

- Speichern und Laden
- Löschen und Bearbeiten
- Berechnungen
- GPS-Kennzahlen
- TÜV-Status
- Tankkosten
- Problemberichte

## Folie 10: Fazit

DriveLog ist eine professionelle, aber noch erklärbare App. Sie zeigt echte App-Entwicklung mit Flutter und sinnvolle KI-Unterstützung.


## Update: Autocomplete und Vorschläge

Die App wurde um professionelle Vorschlagsfelder erweitert. Beim Eingeben von Orten erscheinen passende Vorschläge, zum Beispiel Leutkirch, Lindau, Ravensburg oder Bad Saulgau. Zusätzlich kann DriveLog mit Internet echte Ortsvorschläge über OpenStreetMap/Nominatim laden. Fahrzeuge können über Marke, Modell, Kennzeichen oder VIN gesucht werden. Weitere Vorschläge gibt es bei Fahrzeugdaten, Tankstellen und Problemberichten.

Diese Erweiterung verbessert die Bedienung, bleibt aber verständlich, weil sie über eigene kleine Services und Widgets umgesetzt wurde.
