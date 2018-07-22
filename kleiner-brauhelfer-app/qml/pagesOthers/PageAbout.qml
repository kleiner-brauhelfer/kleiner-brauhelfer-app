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

            HorizontalDivider {}

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("<p>Diese App dient als Ergänzung zum Programm
                    <a href=\"http://www.joerum.de/kleiner-brauhelfer\">kleiner-brauhelfer</a> von gremmel.</p>
                    <p>Die App wird von <a href=\"mailto:bourgeoislab@gmail.com\">BourgeoisLab</a> entwickelt.</p>")
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}
