# kleiner-brauhelfer-app
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kleiner-brauhelfer/kleiner-brauhelfer-app)](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app/releases/latest/)
[![GitHub Release Date](https://img.shields.io/github/release-date/kleiner-brauhelfer/kleiner-brauhelfer-app)](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app/releases/latest/)
[![GitHub Downlaods](https://img.shields.io/github/downloads/kleiner-brauhelfer/kleiner-brauhelfer-app/total)](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app/releases/latest/)

Die Android App *kleiner-brauhelfer-app* ergänzt das Desktopprogramm [kleiner-brauhelfer-2](https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-2).

**Diskussion auf Hobbybrauer.de:**

https://hobbybrauer.de/forum/viewtopic.php?f=3&t=17466

## Download
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
![Screenshot 07](doc/Screenshot_07.png)

## Setup
### Synchronization mit Dropbox
1. *Dropbox developer area* aufrufen (http://www.dropbox.com/developers)
2. Auf *App Console* klicken
3. Auf *Create app* klicken
4. *Scoped access* auswählen
5. *App folder* auswählen
6. App Name wählen
7. Auf *Create app* klicken
8. Zum *Permissions* Reiter wechseln
9. Folgende Berechtigungen aktivieren:
   - *files.metadata.write*
   - *files.metadata.read*
   - *files.content.write*
   - *files.content.read*
10. Einstellungen mit *Submit* bestätigen
11. Zurück zum *Settings* Reiter wechseln
12. Bei *Redirect URIs* "*http://127.0.0.1:5476/*" eintragen
13. Dropbox Seite aufrufen http://www.dropbox.com und dabei die *Dropbox developer area* offen lassen
14. Ein Ordner *Apps* und ein Unterordner mit dem App Name sollten automatisch erstellt worden sein
15. Die Datenbankdatei (*kb_daten.sqlite*) im Unterordner hochladen
16. *kleiner-brauhelfer-app* starten und zu den Einstellungen wechseln
17. *App key* und *App secret* aus der *Dropbox developer area* kopieren
18. Unter *Pfad* "*/kb_daten.sqlite*" eingeben. Eintrag entsprechend anpassen, falls die Datenbank in einem Unterordner platziert oder anders benannt wurde.
19. Auf *Zugriff erlauben* klicken und die Berechtigung erlauben. Die App sollte mit *Zugang gewährt.* die Zugriffberechtigung bestätigen.
20. Die App sollte sich nun mit Dropbox verbinden. Möglicherweise ist ein Neustart der App erforderlich.
21. Achten, dass das Desktopprogramm *kleiner-brauhelfer* auch auf die Datenbank aus dem Dropbox Ordner zugreift

### Synchronization mit Google Drive
1. *Google Cloud Platform Console* aufrufen (http://console.cloud.google.com)
2. Neues Projekt mit beliebigem Name anlegen und selektieren
3. Linkes Panel öffnen und *APIs & services* selektieren
4. Auf *Enable APIs and Services* (oder *Library*) klicken
5. *Google Drive API* auswählen und auf *Enable* klicken
6. Auf der linken Seite auf *OAuth consent screen* klicken
7. User Type *External* auswählen und auf *Create* klicken
8. Formular ausfüllen (App name, User support email & developer contact information) und auf *Save and continue* klicken
9. *Scopes* und *Test users* leer lassen und mit Klick auf *Save and continue* bestätigen
10. *Summary* mit Klick auf *Back to dashboard* bestätigen
11. *Publishing status* mit Klick auf *Publish App* ändern
12. Auf der linken Seite auf *Credentials* klicken
13. Auf *Create credentials* klicken und *OAuth client ID* wählen
14. Als *Application type* *Web application* wählen
15. Unter *Authorised redirect URIs* "*http://127.0.0.1:5477/*" eintragen
16. Auf *Create* klicken
17. *Client ID* und *Client secret* in der *kleiner-brauhelfer-app* eintragen
18. Auf *Zugriff erlauben* klicken und die Berechtigung erlauben. Die App sollte mit *Zugang gewährt.* die Zugriffberechtigung bestätigen.
19. Die Datenbankdatei (*kb_daten.sqlite*) im Google Drive (https://www.google.com/drive) hochladen
20. Dateiname in der *kleiner-brauhelfer-app* eintragen und auf *Datei ID ermitteln* klicken
21. Kann die richtige ID nicht ermittelt werden kann so vorgegangen werden:
    1. Google Drive aufrufen (https://www.google.com/drive)
    2. Rechtsklick auf die Datenbankdatei und *Get Link* wählen
    3. Link mit *Copy link* kopieren und in einem Texteditor einfügen
    4. Die ID ist der Teil zwischen "*../d/*" und "*/view...*"
     Z.B. Link: https://drive.google.com/file/d/1eXmIGOU9Wzo7qtqYTOaUV-TTpEDaL-ON/view?usp=share_link
	 ID: 1eXmIGOU9Wzo7qtqYTOaUV-TTpEDaL-ON
    5. ID in der *kleiner-brauhelfer-app* eintragen
22. Noch einmal auf *Zugriff erlauben* klicken. Dieses Mal sollte der Zugang gewährt werden und die Datenbank heruntergeladen werden.
