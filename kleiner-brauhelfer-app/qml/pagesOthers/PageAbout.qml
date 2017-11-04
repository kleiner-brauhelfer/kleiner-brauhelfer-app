import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Über")
    icon: "ic_help.png"

    component: Flickable {
        anchors.margins: 8
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        contentHeight: layout.height
        clip: true
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
                text: qsTr("<p>Diese App dient als Ergänzung zum Program
                    <a href=\"http://www.joerum.de/kleiner-brauhelfer\">kleiner-brauhelfer</a> von gremmel.</p>
                    <p>Um beide Programme parallel benuzten zu können, muss die Datenbank synchronisiert werden.
                    Zurzeit kann zwischen einer Synchronisation via lokale Datei und einer automatischen Synchronisation
                    via Dropbox ausgewählt werden. Weitere Informationen zur Dropbox Synchronisation gibt es
                    <a href=\"http://www.dropbox.com/developers\">hier</a>.</p>
                    <p>Die App wird von <a href=\"mailto:bourgeoislab@gmail.com\">BourgeoisLab</a> entwickelt.</p>
                ")
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}
