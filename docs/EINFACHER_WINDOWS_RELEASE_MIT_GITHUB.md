# Einfacher Windows-Release mit GitHub Actions

## Grundidee

Die App wird nicht auf jedem privaten PC gebaut. Das macht ein Build-Server.
In diesem Projekt übernimmt **GitHub Actions** diesen Job.

Das ist professioneller als jedes Mal lokal mit PowerShell zu kämpfen.

## Ablauf

1. Projekt auf GitHub hochladen
2. Reiter **Actions** öffnen
3. Workflow **Build DriveLog Windows Release** starten
4. GitHub baut die Windows-App automatisch
5. Fertige ZIP aus **Releases** herunterladen
6. ZIP entpacken und `drivelog.exe` starten

## Was Nutzer später tun müssen

Nutzer brauchen kein Flutter, kein Dart und kein Git.

Sie machen nur:

1. ZIP herunterladen
2. ZIP entpacken
3. `drivelog.exe` starten

## Warum nicht nur eine einzelne EXE?

Eine Flutter-Windows-App besteht nicht nur aus einer EXE. Sie braucht daneben zusätzliche Dateien und DLLs. Deshalb wird immer der komplette Release-Ordner als ZIP verteilt.

## Hinweis zu Windows SmartScreen

Bei nicht signierten Schulprojekt-Apps kann Windows warnen. Dann klickt man auf:

1. **Weitere Informationen**
2. **Trotzdem ausführen**

Für eine echte Firma würde man später Code Signing verwenden.
