import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.0

import "../common"
import qmlutils 1.0
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Einstellungen")
    icon: "ic_settings.png"

    component: Flickable {
        anchors.margins: 8
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        contentHeight: layout.height
        clip: true

        ColumnLayout {
            id: layout
            spacing: 0
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Item {
                Layout.fillWidth: true
                height: lblDatabase.height

                Label {
                    id: lblDatabase
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: imgDatabase.left
                    text: qsTr("Datenbank")
                    color: Material.primary
                    font.pixelSize: 16
                    font.bold: true
                }

                Image {
                    id: imgDatabase
                    width: 24
                    height: 24
                    anchors.right: parent.right
                    anchors.verticalCenter: lblDatabase.verticalCenter
                    source: Brauhelfer.connected ? "qrc:/images/ic_check_circle.png" : "qrc:/images/ic_cancel.png"
                }

                ColorOverlay {
                    anchors.fill: imgDatabase
                    source: imgDatabase
                    color: Brauhelfer.connected ? "green" : "red"
                }
            }

            RadioButton {
                id: radioLocal
                Layout.fillWidth: true
                text: qsTr("Lokale Datenbank")
                checked: SyncService.serviceId === SyncService.Local
                onClicked: {
                    SyncService.serviceId = SyncService.Local
                    app.connect()
                }
            }

            Label {
                Layout.fillWidth: true
                color: Material.primary
                text: qsTr("Pfad zur Datenbank") + ":"
            }

            Item {
                Layout.fillWidth: true
                height: tfDatabasePathLocal.height

                TextField {
                    property bool reconnect: false
                    id: tfDatabasePathLocal
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: btnDatabasePathLocal.left
                    anchors.rightMargin: 8
                    text: SyncService.syncServiceLocal.filePathLocal
                    selectByMouse: true
                    enabled: radioLocal.checked
                    onTextChanged: {
                        if (focus)
                            reconnect = true
                    }
                    onEditingFinished: {
                        SyncService.syncServiceLocal.filePathLocal = text
                        if (reconnect)
                            app.connect()
                        reconnect = false
                    }
                }

                ToolButton {
                    id: btnDatabasePathLocal
                    width: 50
                    anchors.right: parent.right
                    anchors.verticalCenter: tfDatabasePathLocal.verticalCenter
                    enabled: radioLocal.checked
                    onClicked: openDialog.open()
                    contentItem: Image {
                        source: "qrc:/images/ic_folder.png"
                        anchors.centerIn: parent
                        opacity: parent.enabled ? 1 : 0.5
                    }

                    FileDialog {
                        id: openDialog
                        title: qsTr("Pfad zur Datenbank")
                        nameFilters: [qsTr("Datenbank") +  " (*.sqlite)", qsTr("Alle Dateien") + " (*)"]
                        onAccepted: {
                            tfDatabasePathLocal.text = Utils.toLocalFile(openDialog.file)
                            SyncService.syncServiceLocal.filePathLocal = tfDatabasePathLocal.text
                            app.connect()
                        }
                    }
                }
            }

            RadioButton {
                id: radioRemote
                Layout.fillWidth: true
                text: qsTr("Datenbank auf Dropbox")
                checked: SyncService.serviceId === SyncService.Dropbox
                onClicked: {
                    SyncService.serviceId = SyncService.Dropbox
                    app.connect()
                }
            }

            Label {
                Layout.fillWidth: true
                color: Material.primary
                text: qsTr("Dropbox Access Token") + ":"
            }

            TextField {
                property bool reconnect: false
                Layout.fillWidth: true
                text: SyncService.syncServiceDropbox.accessToken
                selectByMouse: true
                enabled: radioRemote.checked
                onTextChanged: {
                    if (focus)
                        reconnect = true
                }
                onEditingFinished: {
                    SyncService.syncServiceDropbox.accessToken = text
                    if (reconnect)
                        app.connect()
                    reconnect = false
                }
            }

            Label {
                Layout.fillWidth: true
                color: Material.primary
                text: qsTr("Pfad auf Server") + ":"
            }

            TextField {
                property bool reconnect: false
                Layout.fillWidth: true
                text: SyncService.syncServiceDropbox.filePathServer
                selectByMouse: true
                enabled: radioRemote.checked
                onTextChanged: {
                    if (focus)
                        reconnect = true
                }
                onEditingFinished: {
                    SyncService.syncServiceDropbox.filePathServer = text
                    if (reconnect)
                        app.connect()
                    reconnect = false
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
                    onClicked: Brauhelfer.clearCache()
                    contentItem: Image {
                        source: "qrc:/images/ic_delete.png"
                        anchors.centerIn: parent
                        opacity: parent.enabled ? 1 : 0.5
                    }
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator {}
    }
}
