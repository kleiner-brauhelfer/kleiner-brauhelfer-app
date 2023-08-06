import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.platform

import "../common"
import qmlutils
import brauhelfer

PageBase {
    title: qsTr("Einstellungen")
    icon: "ic_settings.png"

    Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentHeight: layout.height
        boundsBehavior: Flickable.OvershootBounds
        ScrollIndicator.vertical: ScrollIndicator {}

        ColumnLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            function tryConnect() {
                switch (SyncService.serviceId)
                {
                case SyncService.Local:
                    if (SyncService.syncServiceLocal.filePathLocal !== "")
                        app.connect()
                    break
                case SyncService.Dropbox:
                    if (SyncService.syncServiceDropbox.appKey !== "" &&
                        SyncService.syncServiceDropbox.appSecret !== "" &&
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
                case SyncService.Google:
                    if (SyncService.syncServiceGoogle.clientId !== "" &&
                        SyncService.syncServiceGoogle.clientSecret !== "" &&
                        SyncService.syncServiceGoogle.fileId !== "")
                        app.connect()
                    break
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Datenbank")
                }
                ColumnLayout {
                    anchors.fill: parent
                    RowLayout {
                        Layout.fillWidth: true
                        ComboBoxBase {
                            Layout.fillWidth: true
                            model: [qsTr("Lokal"), qsTr("Dropbox"), qsTr("WebDav"), qsTr("Google Drive")]
                            currentIndex: SyncService.serviceId
                            onCurrentIndexChanged: {
                                if (activeFocus) {
                                    SyncService.serviceId = currentIndex
                                    layout.tryConnect()
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
                        spacing: 16
                        visible: SyncService.serviceId === SyncService.Local
                        LabelPrim {
                            Layout.fillWidth: true
                            font.italic: true
                            text: qsTr("Benötigt Berechtigung für den Speicher.")
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            TextFieldBase {
                                property bool wasEdited: false
                                id: tfDatabasePathLocal
                                Layout.fillWidth: true
                                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase
                                placeholderText: qsTr("Pfad")
                                text: SyncService.syncServiceLocal.filePathLocal
                                selectByMouse: true
                                onTextChanged: {
                                    if (activeFocus)
                                        wasEdited = true
                                }
                                onEditingFinished: {
                                    if (wasEdited)
                                    {
                                        SyncService.syncServiceLocal.filePathLocal = text
                                        layout.tryConnect()
                                        wasEdited = false
                                    }
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
                                        tfDatabasePathLocal.text = Utils.toLocalFile(decodeURIComponent(file))
                                        SyncService.syncServiceLocal.filePathLocal = tfDatabasePathLocal.text
                                        layout.tryConnect()
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: SyncService.serviceId === SyncService.Dropbox
                        LabelPrim {
                            Layout.fillWidth: true
                            font.italic: true
                            text: qsTr("Benötigt eine <a href=\"http://www.dropbox.com/developers/apps\">Dropbox App</a>.")
                            onLinkActivated: (link) => Qt.openUrlExternally(link)
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("App key")
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: SyncService.syncServiceDropbox.appKey
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceDropbox.appKey = text
                                    wasEdited = false
                                }
                            }
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("App secret")
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            echoMode: TextInput.Password
                            text: SyncService.syncServiceDropbox.appSecret
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceDropbox.appSecret = text
                                    wasEdited = false
                                }
                            }
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("Pfad auf Server")
                            text: SyncService.syncServiceDropbox.filePathServer
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceDropbox.filePathServer = text
                                    wasEdited = false
                                }
                            }
                        }
                        ButtonBase {
                            Layout.fillWidth: true
                            text: qsTr("Zugriff erlauben")
                            onClicked: {
                                Brauhelfer.disconnectDatabase()
                                SyncService.syncServiceDropbox.grantAccess()
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: SyncService.serviceId === SyncService.WebDav
                        LabelPrim {
                            Layout.fillWidth: true
                            font.italic: true
                            text: qsTr("Benötigt einen WebDav Server.")
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("URL")
                            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                            text: SyncService.syncServiceWebDav.filePathServer
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceWebDav.filePathServer = text
                                    layout.tryConnect()
                                    wasEdited = false
                                }
                            }
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("Benutzername")
                            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase
                            text: SyncService.syncServiceWebDav.user
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceWebDav.user = text
                                    layout.tryConnect()
                                    wasEdited = false
                                }
                            }
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("Passwort")
                            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase
                            text: SyncService.syncServiceWebDav.password
                            echoMode: TextInput.Password
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceWebDav.password = text
                                    layout.tryConnect()
                                    wasEdited = false
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: SyncService.serviceId === SyncService.Google
                        LabelPrim {
                            Layout.fillWidth: true
                            font.italic: true
                            text: qsTr("Benötigt ein <a href=\"http://console.cloud.google.com\">Google Cloud-Projekt</a>.")
                            onLinkActivated: (link) => Qt.openUrlExternally(link)
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("Client ID")
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            text: SyncService.syncServiceGoogle.clientId
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceGoogle.clientId = text
                                    wasEdited = false
                                }
                            }
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("Client secret")
                            inputMethodHints: Qt.ImhNoAutoUppercase
                            echoMode: TextInput.Password
                            text: SyncService.syncServiceGoogle.clientSecret
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceGoogle.clientSecret = text
                                    wasEdited = false
                                }
                            }
                        }
                        ButtonBase {
                            Layout.fillWidth: true
                            text: qsTr("Zugriff erlauben")
                            onClicked: {
                                Brauhelfer.disconnectDatabase()
                                SyncService.syncServiceGoogle.grantAccess()
                            }
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("Dateiname")
                            text: SyncService.syncServiceGoogle.fileName
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceGoogle.fileName = text
                                    wasEdited = false
                                }
                            }
                        }
                        TextFieldBase {
                            property bool wasEdited: false
                            Layout.fillWidth: true
                            placeholderText: qsTr("Datei ID")
                            text: SyncService.syncServiceGoogle.fileId
                            selectByMouse: true
                            onTextChanged: {
                                if (activeFocus)
                                    wasEdited = true
                            }
                            onEditingFinished: {
                                if (wasEdited)
                                {
                                    SyncService.syncServiceGoogle.fileId = text
                                    wasEdited = false
                                }
                            }
                        }
                        ButtonBase {
                            Layout.fillWidth: true
                            text: qsTr("Datei ID ermitteln")
                            onClicked: {
                                Brauhelfer.disconnectDatabase()
                                SyncService.syncServiceGoogle.retrieveFileId()
                            }
                        }
                    }

                    CheckBoxBase {
                        Layout.fillWidth: true
                        text: qsTr("schreibgeschützt")
                        checked: app.settings.readonly
                        onClicked: app.settings.readonly = checked
                    }
                    ButtonBase {
                        Layout.fillWidth: true
                        text: qsTr("Cache leeren")
                        onClicked: {
                            Brauhelfer.disconnectDatabase()
                            SyncService.clearCache()
                            layout.tryConnect()
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Sprache")
                }
                ComboBoxBase {
                    anchors.fill: parent
                    model: ["Deutsch", "English"]
                    currentIndex: app.settings.languageIndex
                    onCurrentIndexChanged: {
                        if (activeFocus) {
                            app.settings.languageIndex = currentIndex
                            app.updateLanguage()
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Skalierung")
                }
                RowLayout {
                    anchors.fill: parent
                    Slider {
                        id: slider
                        Layout.fillWidth: true
                        from: 0.25
                        to: 3
                        stepSize: 0.01
                        value: app.settings.scalingfactor
                        onPressedChanged: if (!pressed) app.settings.scalingfactor = value
                    }
                    LabelPrim {
                        text: Math.round(slider.value*100) + "%";
                    }
                }
            }
        }
    }
}
