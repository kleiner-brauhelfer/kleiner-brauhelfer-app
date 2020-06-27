import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.1

import "../common"
import qmlutils 1.0
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Einstellungen")
    icon: "ic_settings.png"

    Flickable {
        anchors.fill: parent
        anchors.margins: 8
        boundsBehavior: Flickable.OvershootBounds
        contentHeight: layout.height
        clip: true
        ScrollIndicator.vertical: ScrollIndicator {}

        MouseAreaCatcher {
            anchors.fill: parent
        }

        ColumnLayout {
            id: layout
            spacing: 8
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            function connect() {
                switch (SyncService.serviceId)
                {
                case SyncService.Local:
                    if (SyncService.syncServiceLocal.filePathLocal !== "")
                        app.connect()
                    break
                case SyncService.Dropbox:
                    if (SyncService.syncServiceDropbox.accessToken !== "" &&
                        SyncService.syncServiceDropbox.filePathServer !== "")
                        app.connect()
                    break
                case SyncService.WebDav:
                    if (SyncService.syncServiceWebDav.filePathServer !== "") {
                        if (SyncService.syncServiceWebDav.user === "" &&
                            SyncService.syncServiceWebDav.password === "")
                            app.connect()
                        else if (SyncService.syncServiceWebDav.user !== "" &&
                                 SyncService.syncServiceWebDav.password !== "")
                            app.connect()
                    }
                    break
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.topMargin: 8
                height: childrenRect.height

                LabelSubheader {
                    id: lblDatabase
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: imgDatabase.left
                    text: qsTr("Datenbank")
                }

                Image {
                    id: imgDatabase
                    width: 24
                    height: 24
                    anchors.right: parent.right
                    anchors.verticalCenter: lblDatabase.verticalCenter
                    source: Brauhelfer.connected ? "qrc:/images/ic_check_circle.png" : "qrc:/images/ic_cancel.png"
                    layer.enabled: true
                    layer.effect: ColorOverlay {
                        color: Brauhelfer.connected ? "green" : "red"
                    }
                }
            }

            ComboBox {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                model: [qsTr("Lokal"), qsTr("Dropbox"), qsTr("WebDav")]
                currentIndex: SyncService.serviceId
                onCurrentIndexChanged: {
                    if (activeFocus) {
                        SyncService.serviceId = currentIndex
                        layout.connect()
                        navPane.setFocus()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: SyncService.serviceId === SyncService.Local
                LabelPrim {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    font.italic: true
                    text: qsTr("Benötigt Berechtigung für den Speicher.")
                }
                Label {
                    Layout.fillWidth: true
                    color: Material.primary
                    text: qsTr("Pfad zur lokalen Datenbank")
                }
                Item {
                    Layout.fillWidth: true
                    height: tfDatabasePathLocal.height
                    TextFieldBase {
                        property bool reconnect: false
                        id: tfDatabasePathLocal
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: btnDatabasePathLocal.left
                        anchors.rightMargin: 8
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase
                        placeholderText: "kb_daten.sqlite"
                        text: SyncService.syncServiceLocal.filePathLocal
                        selectByMouse: true
                        onTextChanged: {
                            if (activeFocus)
                                reconnect = true
                        }
                        onEditingFinished: {
                            SyncService.syncServiceLocal.filePathLocal = text
                            if (reconnect)
                                layout.connect()
                            reconnect = false
                        }
                    }
                    ToolButton {
                        id: btnDatabasePathLocal
                        width: 50
                        anchors.right: parent.right
                        anchors.verticalCenter: tfDatabasePathLocal.verticalCenter
                        onClicked: openDialog.open()
                        contentItem: Image {
                            source: "qrc:/images/ic_folder.png"
                            anchors.centerIn: parent
                            opacity: parent.enabled ? 1 : 0.5
                        }
                        FileDialog {
                            id: openDialog
                            title: qsTr("Pfad zur Datenbank")
                            onAccepted: {
                                tfDatabasePathLocal.text = Utils.toLocalFile(openDialog.file)
                                SyncService.syncServiceLocal.filePathLocal = tfDatabasePathLocal.text
                                layout.connect()
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: SyncService.serviceId === SyncService.Dropbox
                LabelPrim {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    font.italic: true
                    text: qsTr("Benötigt eine Dropbox App.")
                }
                Label {
                    Layout.fillWidth: true
                    color: Material.primary
                    text: qsTr("Dropbox Access Token")
                }
                TextFieldBase {
                    property bool reconnect: false
                    Layout.fillWidth: true
                    placeholderText: "token"
                    inputMethodHints: Qt.ImhNoAutoUppercase
                    text: SyncService.syncServiceDropbox.accessToken
                    selectByMouse: true
                    onTextChanged: {
                        if (activeFocus)
                            reconnect = true
                    }
                    onEditingFinished: {
                        SyncService.syncServiceDropbox.accessToken = text
                        if (reconnect)
                            layout.connect()
                        reconnect = false
                    }
                }
                Label {
                    Layout.fillWidth: true
                    color: Material.primary
                    text: qsTr("Pfad auf dem Server")
                }
                TextFieldBase {
                    property bool reconnect: false
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase
                    placeholderText: "/kb_daten.sqlite"
                    text: SyncService.syncServiceDropbox.filePathServer
                    selectByMouse: true
                    onTextChanged: {
                        if (activeFocus)
                            reconnect = true
                    }
                    onEditingFinished: {
                        SyncService.syncServiceDropbox.filePathServer = text
                        if (reconnect)
                            layout.connect()
                        reconnect = false
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: SyncService.serviceId === SyncService.WebDav
                LabelPrim {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    font.italic: true
                    text: qsTr("Benötigt einen WebDav Server.")
                }
                Label {
                    Layout.fillWidth: true
                    color: Material.primary
                    text: qsTr("URL")
                }
                TextFieldBase {
                    property bool reconnect: false
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                    placeholderText: "http://server:port/kb_daten.sqlite"
                    text: SyncService.syncServiceWebDav.filePathServer
                    selectByMouse: true
                    onTextChanged: {
                        if (activeFocus)
                            reconnect = true
                    }
                    onEditingFinished: {
                        SyncService.syncServiceWebDav.filePathServer = text
                        if (reconnect)
                            layout.connect()
                        reconnect = false
                    }
                }

                Label {
                    Layout.fillWidth: true
                    color: Material.primary
                    text: qsTr("Benutzername")
                }

                TextFieldBase {
                    property bool reconnect: false
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase
                    text: SyncService.syncServiceWebDav.user
                    selectByMouse: true
                    onTextChanged: {
                        if (activeFocus)
                            reconnect = true
                    }
                    onEditingFinished: {
                        SyncService.syncServiceWebDav.user = text
                        if (reconnect)
                            layout.connect()
                        reconnect = false
                    }
                }

                Label {
                    Layout.fillWidth: true
                    color: Material.primary
                    text: qsTr("Passwort")
                }

                TextFieldBase {
                    property bool reconnect: false
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase
                    text: SyncService.syncServiceWebDav.password
                    echoMode: TextInput.Password
                    selectByMouse: true
                    onTextChanged: {
                        if (activeFocus)
                            reconnect = true
                    }
                    onEditingFinished: {
                        SyncService.syncServiceWebDav.password = text
                        if (reconnect)
                            layout.connect()
                        reconnect = false
                    }
                }
            }

            Item {
                height: 24
            }

            Item {
                Layout.fillWidth: true
                height: btnClearCache.height

                Label {
                    id: lblCache
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: btnClearCache.left
                    anchors.rightMargin: 8
                    color: Material.primary
                    text: qsTr("Cache leeren")
                }

                ToolButton {
                    id: btnClearCache
                    width: 50
                    anchors.right: parent.right
                    anchors.verticalCenter: lblCache.verticalCenter
                    onClicked: {
                        Brauhelfer.disconnectDatabase()
                        SyncService.clearCache()
                        connect()
                    }
                    contentItem: Image {
                        source: "qrc:/images/ic_delete.png"
                        anchors.centerIn: parent
                        opacity: parent.enabled ? 1 : 0.5
                    }
                }
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }

            LabelSubheader {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: qsTr("Sprache")
            }

            ComboBox {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                model: ["Deutsch", "English"]
                currentIndex: app.settings.languageIndex
                onCurrentIndexChanged: {
                    if (activeFocus) {
                        app.settings.languageIndex = currentIndex
                        app.updateLanguage()
                        navPane.setFocus()
                    }
                }
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }
        }
    }
}
