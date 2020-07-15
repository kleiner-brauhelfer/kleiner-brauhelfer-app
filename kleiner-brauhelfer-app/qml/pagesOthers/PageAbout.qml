import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

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
                text: qsTr("Informationen und letzte Version auf <a href=\"https://github.com/kleiner-brauhelfer/kleiner-brauhelfer-app\">kleiner-brauhelfer-app</a>.")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Der kleine-brauhelfer-2 ist als angepasste <a href=\"https://de.wikipedia.org/wiki/Beerware\">Beerware</a> lizenziert.");
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("<em>Während die Nutzung generell kostenlos ist, erbittet der Autor von Beerware vom Nutzer dem Autor<br/>- bei Gelegenheit ein Bier auszugeben oder<br/>- ein Bier auf das Wohl des Autors zu trinken oder<br/>- dem Autor ein <strong>selbstgebrautes Bier zu schicken</<strong>.</em>")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Die Einhaltung dieser Lizenzierungsbestimmung erfolgt auf freiwilliger Basis.")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("<strong>Anschrift Deutschland:<br/></strong>Bourgeois Frédéric<br/>c/o LAS Burg 12002<br/>Hauptstraße 396<br/>D-79576 Weil am Rhein")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("<strong>Anschrift Schweiz:<br/></strong>Bourgeois Frédéric<br/>Lehenmattstrasse 158<br/>CH-4052 Basel")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            LabelPrim {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Ich würde mich über ein leckeres Bier sehr freuen!")
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}
