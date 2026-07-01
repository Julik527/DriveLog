# DriveLog Release-Checkliste

## A. Vor dem Build

- [ ] Flutter läuft mit `flutter doctor`
- [ ] Projekt startet mit `flutter run`
- [ ] Tests laufen mit `flutter test`
- [ ] keine privaten Testdaten im Projekt
- [ ] App-Version in `pubspec.yaml` gesetzt
- [ ] Paketname nicht mehr `com.example...`
- [ ] App-Name korrekt gesetzt
- [ ] App-Icon vorhanden
- [ ] Android-Berechtigungen geprüft
- [ ] Datenschutzerklärung vorbereitet
- [ ] Store-Texte vorbereitet

## B. Android-Testversion

- [ ] Android-Gerät angeschlossen
- [ ] GPS auf echtem Gerät getestet
- [ ] Tankbeleg-Foto getestet
- [ ] OCR getestet oder Fallback geprüft
- [ ] Fahrt speichern/löschen getestet
- [ ] Fahrzeug speichern/löschen getestet
- [ ] TÜV-Hinweis getestet
- [ ] Problembericht getestet
- [ ] Autocomplete getestet

## C. Release-Dateien

- [ ] APK für direkte Tests gebaut
- [ ] AAB für Play Store gebaut
- [ ] Keystore sicher gespeichert
- [ ] Keystore-Passwort sicher notiert
- [ ] Build-Dateien geprüft

## D. Play Store

- [ ] Google Play Console Konto erstellt
- [ ] App angelegt
- [ ] App Bundle hochgeladen
- [ ] Store-Beschreibung eingetragen
- [ ] Screenshots hochgeladen
- [ ] App-Icon hochgeladen
- [ ] Privacy Policy verlinkt
- [ ] Data-Safety-Formular ausgefüllt
- [ ] App-Berechtigungen erklärt
- [ ] Closed Test gestartet
- [ ] Testerfeedback gesammelt
- [ ] Produktionszugang beantragt

## E. Qualität vor Veröffentlichung

- [ ] App stürzt nicht ab
- [ ] GPS fragt sauber nach Berechtigung
- [ ] App funktioniert ohne Internet eingeschränkt weiter
- [ ] manuelle Eingabe ist immer möglich
- [ ] keine falschen rechtlichen Versprechen
- [ ] klare Hinweise zu Datenschutz und lokaler Speicherung
