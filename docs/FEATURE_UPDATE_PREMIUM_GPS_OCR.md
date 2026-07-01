# Feature-Update: Premium Fuhrpark, GPS und OCR

## Was wurde erweitert?

DriveLog wurde von einer einfachen Fahrtenbuch-App zu einer kleinen Fuhrpark-App erweitert.

## Neue Funktionen

### 1. GPS-Fahrt

Eine Fahrt kann per GPS gestartet und beendet werden. Die App misst:

- Strecke
- Dauer
- Durchschnittsgeschwindigkeit
- Höchstgeschwindigkeit

Vor dem Start erscheint ein Hinweisdialog. Der Fahrer muss bestätigen, dass er Fahrzeugdaten und Warnungen gelesen hat.

### 2. Hinweis vor Fahrtbeginn

Vor einer GPS-Fahrt werden angezeigt:

- Fahrzeug auf Beschädigungen prüfen
- TÜV-Status
- bekannte Schäden oder Probleme
- Öl-Spezifikation
- allgemeiner Hinweis, dass die App keine technische Prüfung ersetzt

### 3. Digitaler Fahrzeugschein

Zu jedem Fahrzeug können wichtige Werte hinterlegt werden:

- Marke
- Modell
- Kennzeichen
- VIN
- Höchstgeschwindigkeit
- Reifen
- Anhängelast
- Leergewicht
- zulässiges Gesamtgewicht
- Länge, Breite, Höhe
- Öl-Spezifikation
- Ölmenge
- TÜV-Datum

### 4. Tankbeleg-OCR

Der Nutzer kann einen Tankbeleg per Kamera oder Galerie erfassen. Auf Android/iOS kann ML Kit den Text erkennen. Die App übernimmt nur Vorschläge. Der Nutzer prüft die Werte.

### 5. Problem melden

Nach einer Fahrt oder direkt über das Dashboard kann ein Problem gemeldet werden. Beispiele:

- Fahrwerk klackert
- Bremse schleift
- Reifen verliert Luft
- Motor macht Geräusche
- Beschädigung am Fahrzeug

Jede Meldung hat einen Status: offen, in Prüfung oder erledigt.

## Warum ist das professionell?

Die App denkt wie ein kleines Fuhrpark-System: Fahrzeugdaten, Fahrten, Belege, Warnungen und Schäden hängen zusammen. Gleichzeitig bleibt der Code für Schüler erklärbar, weil jede Funktion in eigenen Dateien sauber getrennt ist.
