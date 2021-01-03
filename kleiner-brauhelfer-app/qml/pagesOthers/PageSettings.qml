import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3

import "../common"
import qmlutils 1.0
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Einstellungen")
    icon: "ic_settings.png"

    Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentHeight: layout.height
        boundsBehavior: Flickable.OvershootBounds
        onMovementStarted: forceActiveFocus()
        ScrollIndicator.vertical: ScrollIndicator {}

        Connections {
            target: SyncService
            function onErrorOccurred(code, msg) {
                messageDialogError.text = msg
                messageDialogError.open()
            }
        }

        MessageDialog {
            id: messageDialogError
            icon: MessageDialog.Warning
        }

        MouseAreaCatcher {
            anchors.fill: parent
        }

        ColumnLayout {
            id: layout
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

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Datenbank")
                }
                ColumnLayout {
                    anchors.fill: parent
                    RowLayout {
                        Layout.fillWidth: true
                        ComboBoxBase {
                            Layout.fillWidth: true
                            Layout.preferredHeight: height
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
                        Image {
                            width: 24
                            height: 24
                            source: Brauhelfer.connected ? "qrc:/images/ic_check_circle.png" : "qrc:/images/ic_cancel.png"
                            layer.enabled: true
                            layer.effect: ColorOverlay {
                                color: Brauhelfer.connected ? "green" : "red"
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
                        LabelSubheader {
                            Layout.fillWidth: true
                            text: qsTr("Pfad zur lokalen Datenbank")
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            TextFieldBase {
                                property bool reconnect: false
                                id: tfDatabasePathLocal
                                Layout.fillWidth: true
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
                                width: 50
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
                        LabelSubheader {
                            Layout.fillWidth: true
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
                                if (reconnect && SyncService.syncServiceDropbox.filePathServer !== "")
                                    layout.connect()
                                reconnect = false
                            }
                        }
                        LabelSubheader {
                            Layout.fillWidth: true
                            text: qsTr("Pfad auf dem Server")
                        }
                        ComboBoxBase {
                            property bool reconnect: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: height
                            editable: true
                            model: SyncService.syncServiceDropbox.folderContent
                            textRole: "display"
                            Component.onCompleted: editText = SyncService.syncServiceDropbox.filePathServer
                            onEditTextChanged: {
                                if (activeFocus)
                                    reconnect = true
                            }
                            onFocusChanged: {
                                if (reconnect) {
                                    SyncService.syncServiceDropbox.filePathServer = editText
                                    layout.connect()
                                    navPane.setFocus()
                                }
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
                        LabelSubheader {
                            Layout.fillWidth: true
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
                        LabelSubheader {
                            Layout.fillWidth: true
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
                        LabelSubheader {
                            Layout.fillWidth: true
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
                    RowLayout {
                        Layout.fillWidth: true
                        LabelSubheader {
                            Layout.fillWidth: true
                            text: qsTr("Cache leeren")
                        }
                        ToolButton {
                            width: 50
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
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Sprache")
                }
                ColumnLayout {
                    anchors.fill: parent
                    ComboBoxBase {
                        Layout.fillWidth: true
                        Layout.preferredHeight: height
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
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Skalierung")
                }
                ColumnLayout {
                    anchors.fill: parent
                    RowLayout {
                        Layout.fillWidth: true
                        Slider {
                            Layout.fillWidth: true
                            from: 0.25
                            to: 3
                            stepSize: 0.01
                            value: app.settings.scalingfactor
                            onValueChanged: app.settings.scalingfactor = value
                        }
                        LabelPrim {
                            text: Math.round(app.settings.scalingfactor*100) + "%";
                        }
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: app.settings.scalingfactor != 1
                        font.italic: true
                        text: qsTr("Keine durchgängige korrekte Darstellung.")
                    }
                }
            }
        }
    }
}
