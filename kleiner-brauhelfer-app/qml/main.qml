import QtQuick
import QtQuick.Controls
import Qt.labs.platform
import QtCore

import "common"
import "pagesGlobal"
import "pagesSud"
import "pagesTools"
import "pagesOthers"

import languageSelector
import brauhelfer
import ProxyModelSud

ApplicationWindow {

    property bool loaded: false
    property bool brewForceEditable: false
    property alias config: config
    property alias settings: settings
    property alias defs: defs

    id: app
    title: Qt.application.name
    width: 360
    height: 640
    visible: true

    Config {
        id: config
    }

    Defines {
        id: defs
    }

    Settings {
        id: settings
        category: "App"
        property int languageIndex: 0
        property int brewsFilter: ProxyModelSud.Alle
        property int brewsSortColumn: 5
        property bool brewsMerklisteFilter: false
        property int ingredientsFilter: 0
        property real sugarFactor: 1.0
        property real scalingfactor: 1.0
        property int restextraktMethode: 0
        property int refractometerIndex: 2
        property bool readonly: false
    }

    Connections {
        target: SyncService
        function onMessage(type, txt) {
            messageDialog.text = txt
            messageDialog.open()
        }
    }
    Connections {
        target: SyncService.syncServiceDropbox
        function onAccessGranted() {
            connect()
            messageDialog.text = qsTr("Zugang gewährt.")
            messageDialog.open()
        }
    }
    Connections {
        target: SyncService.syncServiceGoogle
        function onAccessGranted() {
            connect()
            messageDialog.text = qsTr("Zugang gewährt.")
            messageDialog.open()
        }
    }

    // scheduler to do stuff in the background, use run() or runExt()
    Timer {
        // tasks
        readonly property int connect: 0
        readonly property int save: 1
        readonly property int discard: 2
        readonly property int loadBrew: 3
        readonly property int saveAndQuit: 4

        property int schedule: -1
        property var param: null

        id: scheduler
        interval: 10
        onTriggered: {
            switch (schedule) {
            case connect:
                SyncService.download()
                Brauhelfer.databasePath = SyncService.filePath
                Brauhelfer.connectDatabase()
                app.loaded = true

                // build navigation menu
                buildMenus()

                // trigger focus to load content of first page, after app.loaded is set
                navPane.currentItem.currentItem.focus = false
                navPane.currentItem.currentItem.focus = true

                // synchronization message
                switch (SyncService.syncState)
                {
                case SyncService.UpToDate:
                    toast.start(qsTr("Datenbank aktuell."))
                    break;
                case SyncService.Updated:
                    toast.start(qsTr("Datenbank aktualisiert."))
                    break;
                case SyncService.Offline:
                    toast.start(qsTr("Synchronisationsdienst nicht erreichbar."))
                    break;
                case SyncService.NotFound:
                    toast.start(qsTr("Datenbank nicht gefunden."))
                    break;
                case SyncService.OutOfSync:
                    toast.start(qsTr("Datenbank nicht synchron."))
                    break;
                case SyncService.Failed:
                    toast.start(qsTr("Synchronisation fehlgeschlagen."))
                    break;
                }

                // check if everything ok
                if (Brauhelfer.readonly) {
                    messageDialogReadonly.open()
                }
                if (!Brauhelfer.connected) {
                    if (!pageSettings.visible)
                        messageDialogGotoSettings.open()
                }
                else if (Brauhelfer.databaseVersion < 0) {
                    messageDialogUnsupportedDatabaseVersion.informativeText = qsTr("Die Datenbank ist ungültig.")
                    messageDialogUnsupportedDatabaseVersion.open()
                    Brauhelfer.disconnectDatabase()
                }
                else if (Brauhelfer.databaseVersion < 2000) {
                    messageDialogUnsupportedDatabaseVersion.informativeText = qsTr("Die Datenbank kann nur mit der App v1.x.x geöffnet werden.")
                    messageDialogUnsupportedDatabaseVersion.open()
                    Brauhelfer.disconnectDatabase()
                }
                else if (Brauhelfer.databaseVersion < Brauhelfer.databaseVersionSupported) {
                    messageDialogUnsupportedDatabaseVersion.informativeText = qsTr("Die Datenbank ist zu alt für die App und muss zuerst mit dem kleinen-brauhelfer aktualisiert werden.")
                    messageDialogUnsupportedDatabaseVersion.open()
                    Brauhelfer.disconnectDatabase()
                }
                else if (Brauhelfer.databaseVersion > Brauhelfer.databaseVersionSupported) {
                    messageDialogUnsupportedDatabaseVersion.informativeText = qsTr("Die App ist zu alt für diese Datenbank und muss zuerst aktualisiert werden.")
                    messageDialogUnsupportedDatabaseVersion.open()
                    Brauhelfer.disconnectDatabase()
                }
                break
            case save:
                Brauhelfer.save()
                SyncService.upload()
                brewForceEditable = false
                break
            case discard:
                Brauhelfer.discard()
                brewForceEditable = false
                break
            case loadBrew:
                Brauhelfer.sud.load(param)
                buildMenus()
                navPane.goTo(viewSud, 0)
                brewForceEditable = false
                pageToolBieranalyse.takeValuesFromBrew()
                break
            case saveAndQuit:
                Brauhelfer.save()
                SyncService.upload()
                brewForceEditable = false
                Qt.quit()
                break;
            }
            schedule = -1
            busyIndicator.running = false
        }

        function run(_schedule) {
            schedule = _schedule
            busyIndicator.running = true
            start()
        }

        function runExt(_schedule, _param) {
            param = _param
            run(_schedule)
        }
    }

    function updateLanguage() {
        switch (settings.languageIndex) {
        case 0:
            LanguageSelector.selectLanguage("de")
            break
        case 1:
            LanguageSelector.selectLanguage("en")
            break
        }
    }

    function connect() {
        scheduler.run(scheduler.connect)
    }

    function save() {
        scheduler.run(scheduler.save)
    }

    function discard() {
        scheduler.run(scheduler.discard)
    }

    function loadBrew(id) {
        if (Brauhelfer.sud.id !== id) {
            loadBrewNow(id)
        }
        else {
            navPane.goTo(viewSud, 0)
        }
    }

    function loadBrewNow(id) {
        busyIndicator.running = true
        navPane.goHome()
        for (var i = 0; i < viewSud.count; ++i)
            viewSud.itemAt(i).unload()
        scheduler.runExt(scheduler.loadBrew, id)
    }

    function saveAndQuit() {
        scheduler.run(scheduler.saveAndQuit)
    }

    function buildMenus() {
        viewSud.build()
        navigation.build()
    }

    function checkSsl() {
        if (!SyncService.supportsSsl())
            messageDialogSslError.open()
    }

    Component.onCompleted: {
        updateLanguage()
        checkSsl()
        connect()
    }

    // toast messages
    Toast {
        id: toast
    }

    // general message dialog
    MessageDialog {
        id: messageDialog
    }

    // message dialog to show readonly message
    MessageDialog {
        id: messageDialogReadonly
        text: qsTr("Synchronisationsdienst ist nicht verfügbar.")
        informativeText: qsTr("Datenbank wird nur lesend geöffnet.")
    }

    // message dialog going to the settings
    MessageDialog {
        id: messageDialogGotoSettings
        text: qsTr("Verbindung mit der Datenbank fehlgeschlagen.")
        informativeText: qsTr("Einstellungen überprüfen.")
        onOkClicked: navPane.goSettings()
    }

    // message dialog for unsupported database version
    MessageDialog {
        id: messageDialogUnsupportedDatabaseVersion
        text: qsTr("Diese Datenbank wird nicht unterstüzt.")
        onOkClicked: navPane.goSettings()
    }

    // message dialog for unsupported database version
    MessageDialog {
        id: messageDialogSslError
        text: qsTr("SSL nicht unterstüzt")
        informativeText: qsTr("Version benötigt: %1\nVersion installiert: %2").arg(SyncService.sslLibraryBuildVersionString()).arg(SyncService.sslLibraryVersionString())
    }

    // message dialog to ask for quit
    MessageDialog {
        id: messageDialogQuit
        text: qsTr("Soll das Programm geschlossen werden?")
        buttons: MessageDialog.Ok | MessageDialog.Cancel
        onOkClicked: Qt.quit()
    }

    // message dialog to ask for save and quit
    MessageDialog {
        id: messageDialogQuitSave
        text: qsTr("Änderungen vor dem Schliessen speichern?")
        buttons: MessageDialog.Save | MessageDialog.Discard | MessageDialog.Cancel
        onSaveClicked: app.saveAndQuit()
        onDiscardClicked: Qt.quit()
    }

    // header
    header: Header {
        text: navPane.currentItem.currentItem.title
        textSub: {
            if (Brauhelfer.sud.isLoaded) {
                var n = Brauhelfer.sud.Sudnummer
                if (n > 0)
                    return Brauhelfer.sud.Sudname + " (#" + n + ")"
                else
                    return Brauhelfer.sud.Sudname
            }
            else {
                return Qt.application.name
            }
        }
        iconLeft: "ic_menu_white.png"
        onClickedLeft: navigation.open()
        iconRight: navPane.isHome() ? "" : "ic_home_white.png"
        onClickedRight: navPane.goHome()
        Keys.onReleased: (event) => navPane.keyPressed(event)
    }

    // global pages
    SwipeView {
        id: viewGlobal
        visible: false
        PageGlobalAuswahl { onClicked: (id) => loadBrew(id) }
        PageGlobalMalt { }
        PageGlobalHops { }
        PageGlobalYeast { }
        PageGlobalIngredients { }
        PageGlobalEquipment { }
        PageGlobalWater { }
    }

    // brew pages
    SwipeView {
        id: viewSud
        visible: false
        function build() {
            while (count > 0)
                takeItem(0)
            if (Brauhelfer.sud.isLoaded) {
                addItem(pageSudHome)
                addItem(pageSudInfo)
                addItem(pageSudBrauen)
                addItem(pageSudGaerverlauf_1)
                addItem(pageSudGaerverlauf_2)
                addItem(pageSudAbfuellen)
                addItem(pageSudGaerverlauf_3)
                addItem(pageSudGaerung)
                addItem(pageSudBewertung)
            }
            if (count > 0)
                itemAt(0).unload()
        }
    }
    PageSudHome { id: pageSudHome }
    PageSudInfo { id: pageSudInfo }
    PageSudBrauen { id: pageSudBrauen }
    PageSudGaerverlauf_1 { id: pageSudGaerverlauf_1 }
    PageSudGaerverlauf_2 { id: pageSudGaerverlauf_2 }
    PageSudAbfuellen { id: pageSudAbfuellen }
    PageSudGaerverlauf_3 { id: pageSudGaerverlauf_3 }
    PageSudGaerung { id: pageSudGaerung }
    PageSudBewertung { id: pageSudBewertung }

    // tools pages
    SwipeView {
        id: viewTools
        visible: false
        PageToolBieranalyse {id: pageToolBieranalyse }
    }

    // other pages
    SwipeView {
        id: viewOthers
        visible: false
        PageSettings {id: pageSettings}
        PageAbout {id: pageAbout}
    }

    // main view containing the swipe views
    StackView {

        property var lastView : null
        property int lastIndex : -1

        id: navPane
        anchors.fill: parent
        initialItem: viewGlobal
        focus: true

        Keys.onReleased: (event) => keyPressed(event)

        function keyPressed(event) {
            if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
                if (isHome()) {
                    if (Brauhelfer.modified)
                        messageDialogQuitSave.open()
                    else
                        messageDialogQuit.open()
                }
                if (lastView === null || currentItem == viewGlobal || currentItem == viewSud) {
                    goHome()
                }
                else {
                    goTo(lastView, lastIndex)
                    lastView = null
                    lastIndex = -1
                }
                event.accepted = true
            }
        }

        function goTo(view, index)
        {
            lastView = currentItem
            lastIndex = currentItem.currentIndex
            if (index >= 0)
                view.currentIndex = index
            if (currentItem !== view) {
                pop(viewGlobal)
                if (view !== viewGlobal)
                    push(view)
            }
            setFocus()
        }

        function next()
        {
            if (currentItem.currentIndex < currentItem.count - 1)
                currentItem.currentIndex = currentItem.currentIndex + 1
            setFocus()
        }

        function previous()
        {
            if (currentItem.currentIndex > 0)
                currentItem.currentIndex = currentItem.currentIndex - 1
            setFocus()
        }

        function goHome()
        {
            lastView = null
            lastIndex = -1
            if (currentItem == viewSud && viewSud.currentIndex !== 0) {
                viewSud.currentIndex = 0
            }
            else {
                viewGlobal.currentIndex = 0
                if (currentItem != viewGlobal)
                    pop(viewGlobal)
            }
            setFocus()
        }

        function goSettings()
        {
            goTo(viewOthers, 0)
        }

        function isCurrentPage(view, index)
        {
            return currentItem === view && view.currentIndex === index
        }

        function isHome()
        {
            return isCurrentPage(viewGlobal, 0)
        }

        function setFocus()
        {
            focus = true
            header.forceActiveFocus()
        }
    }

    // footer
    footer: Footer {
        swipeView: navPane.currentItem
        onClickedLeft: navPane.previous()
        onClickedRight: navPane.next()
        Keys.onReleased: (event) => navPane.keyPressed(event)
    }

    // busy indicator
    BusyIndicator {
        id: busyIndicator
        running: false
        anchors.centerIn: parent
    }

    // discard button
    FloatingButton {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        visible: Brauhelfer.modified
        imageSource: "qrc:/images/ic_clear_white.png"
        onClicked: {
            navPane.setFocus()
            app.discard()
        }
    }

    // save button
    FloatingButton {
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        visible: Brauhelfer.modified
        imageSource: "qrc:/images/ic_save_white.png"
        onClicked: {
            navPane.setFocus()
            app.save()
        }
    }

    // navigation menu
    NavMenu {
        id: navigation
        model: ListModel {}
        onClosed: navPane.setFocus()
        function build()
        {
            var i
            model.clear()
            if (Brauhelfer.connected) {
                for (i = 0; i < viewGlobal.count; ++i)
                    model.append({"type": "NavMenuItem.qml",
                                  "view": viewGlobal,
                                  "index": i})
                if (viewSud.count > 0)
                    model.append({"type": "NavMenuDivider.qml"})
                for (i = 0; i < viewSud.count; ++i)
                    model.append({"type": "NavMenuItem.qml",
                                  "view": viewSud,
                                  "index": i})
                if (viewTools.count > 0)
                    model.append({"type": "NavMenuDivider.qml"})
                for (i = 0; i < viewTools.count; ++i)
                    model.append({"type": "NavMenuItem.qml",
                                  "view": viewTools,
                                  "index": i})
                if (viewOthers.count > 0)
                    model.append({"type": "NavMenuDivider.qml"})
            }
            for (i = 0; i < viewOthers.count; ++i)
                model.append({"type": "NavMenuItem.qml",
                              "view": viewOthers,
                              "index": i})
        }
    }
}
