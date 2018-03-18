# kleiner-brauhelfer-app
This is a cross platform app (Android, iOS) that goes along with the brewing software  [kleiner-brauhelfer](https://github.com/Gremmel/kleiner-brauhelfer).
###  What can you do with the app?
- Overview of the brews
- Add data and measurements during the brewing process
- Add data and measurements during the bottling process
- Add measurements during the fermentation process
- Add brew ratings
### What can't you do with the app (yet)?
- Create database file
- Create a recipe
- Manage the ingredient inventory
- Manage the equipment
### Screenshots
![Screenshot 01](doc/Screenshot_01.png)
![Screenshot 02](doc/Screenshot_02.png)
![Screenshot 03](doc/Screenshot_03.png)
![Screenshot 04](doc/Screenshot_04.png)
![Screenshot 05](doc/Screenshot_05.png)
![Screenshot 06](doc/Screenshot_06.png)
![Screenshot 07](doc/Screenshot_07.png)
## Setup
### Synchronizing with Dropbox
1. Access the Dropbox developer area https://www.dropbox.com/developers.

![Dropbox 01](doc/Dropbox_01.png)

2. Log in with your Dropbox account.
3. Click on "Create your app".
4. Select "Dropbox API".

![Dropbox 01](doc/Dropbox_02.png)

5. You can select both "App folder" or "Full Dropbox", but "Full Dropbox" is easier to start with.
6. Define an app name.
7. Click on "Create app."
8. On the next page click on "Generate" just below "Generated access token".

![Dropbox 01](doc/Dropbox_03.png)

9. If you've chosen "App folder" before place the database file "kb_daten.sqlite" in this folder or subfolder.
10. Locate the database file "kb_daten.sqlite" in your Dropbox.

![Dropbox 01](doc/Dropbox_04.png)

11. Open the app "kleiner-brauhelfer-app" and go to the settings page.

![Dropbox 01](doc/Dropbox_05.png)

12. Enter the access token (!).
13. Enter the relative path to the databse file, e.g. /Apps/kleiner-brauhelfer/kb_daten.sqlite.
14. The app should connect as soon as you finished editing both fields.
15. If you are sure the field are correct but the app is not synchronizing try to restart the app.
