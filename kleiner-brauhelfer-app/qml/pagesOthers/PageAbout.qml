import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0

PageBase {
    title: qsTr("Über")
    icon: "ic_help.png"

    Flickable {
        anchors.fill: parent
        anchors.margins: 8
        boundsBehavior: Flickable.OvershootBounds
        contentHeight: layout.height
        clip: true
        onMovementStarted: forceActiveFocus()
        ScrollIndicator.vertical: ScrollIndicator {}

        ColumnLayout {
            id: layout
            spacing: 8
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            LabelSubheader {
                text: Qt.application.name + " v" + Qt.application.version
                Layout.fillWidth: true
                horizontalAlignment: Label.AlignHCenter
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Diese App dient als Ergänzung zum Programm <a href=\"https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-2\">kleiner-brauhelfer-2</a>.")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Informationen und letzte Version <a href=\"https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app\">kleiner-brauhelfer-app</a>.")
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}
