# kleiner-brauhelfer-app
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kleiner-brauhelfer/kleiner-brauhelfer-app)](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app/releases/latest/)
[![GitHub Release Date](https://img.shields.io/github/release-date/kleiner-brauhelfer/kleiner-brauhelfer-app)](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app/releases/latest/)
[![GitHub Downlaods](https://img.shields.io/github/downloads/kleiner-brauhelfer/kleiner-brauhelfer-app/total)](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app/releases/latest/)

Die kleiner-brauhelfer-app ist eine App, welche die Software [kleiner-brauhelfer-2](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-2) ergänzt. Die App wird nur für Android Geräte kompiliert, sollte aber auch mit anderen Betriebssysteme kompatibel sein.

**Diskussionsthread:**

https://hobbybrauer.de/forum/viewtopic.php?f=3&t=17466

## Download letzte Version
- [Version 2.x.x](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app/releases/latest) passend zum [kleinen-brauhelfer-2](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-2)
- [Version 1.0.0](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app/releases/tag/v1.0.0) passend zum [kleinen-brauhelfer bis 1.4.4.6](https://github.com/Gremmel/kleiner-brauhelfer)

## Änderungen & Erweiterungen
Siehe [Changelog](CHANGELOG.md).

## Screenshots
![Screenshot 01](doc/Screenshot_01.png)
![Screenshot 02](doc/Screenshot_02.png)
![Screenshot 03](doc/Screenshot_03.png)
![Screenshot 04](doc/Screenshot_04.png)
![Screenshot 05](doc/Screenshot_05.png)
![Screenshot 06](doc/Screenshot_06.png)
![Screenshot 07](doc/Screenshot_07.png)

## Setup
### Synchronization mit Dropbox
1. *Dropbox developer area* aufrufen https://www.dropbox.com/developers.
2. Oben rechts auf *App Console* klicken.
3. Auf *Create your app* klicken.
4. *Scoped access* auswählen.
5. *App folder* auswählen.
6. App Name wählen.
7. Auf *Create app* klicken.
8. Oben auf den *Permissions* Reiter wechseln.
9. Folgende Berechtigungen aktivieren: *files.metadata.write*, *files.metadata.read*, *files.content.write* und *files.content.read*
10. Einstellungen mit *Submit* bestätigen.
11. Zurück zum *Settings* Reiter wechseln.
12. Bei *Redirect URIs* *http://127.0.0.1:5476/* eintragen.
13. Die Dropbox Seite aufrufen https://www.dropbox.com und dabei die *Dropbox developer area* offen lassen.
14. Bei den Dateien sollte es jetzt einen Unterordner *App* und darin einen weiteren Unterordner mit dem App Name geben.
15. Datenbankdatei (*kb_daten.sqlite*) dorthin platzieren.
16. *kleiner-brauhelfer-app* starten und zu den Einstellungen wechseln.
17. *App key* und *App secret* aus der *Dropbox developer area* kopieren.
18. Unter *Pfad* den Pfad zur Datenbank inklusive Dateiname eingeben. Befindet sich die Datei direkt im Hauptordner des erstellten Dropboxordner, dann lautet der Pfad */kb_daten.sqlite*.
19. Auf *Zugriff erlauben* klicken und die Berechtigung erlauben. Die App sollte mit *Access granted!* die Zugriffberechtigung bestätigen.
20. Die App sollte sich dann mit Dropbox verbinden. Möglicherweise ist ein Neustart der App erforderlich.
21. Nicht vergessen im Desktopprogramm *kleiner-brauhelfer* die Datenbank vom entsprechenden Dropbox Ordner auszuwählen.
