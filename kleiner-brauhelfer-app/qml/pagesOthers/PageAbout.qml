import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

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

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                text: Qt.application.name + "\nv" + Qt.application.version
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Diese App dient als Ergänzung zum Programm <a href=\"http://kleiner-brauhelfer.github.io\">kleiner-brauhelfer-2</a>.")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Informationen und letzte Version auf <a href=\"https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app\">kleiner-brauhelfer-app</a>.")
                onLinkActivated: Qt.openUrlExternally(link)
            }

        }
    }
}
