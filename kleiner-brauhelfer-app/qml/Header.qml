import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

ToolBar {

    property alias text: lblMain.text
    property alias textSub: lblSub.text
    property string iconLeft: ""
    property string iconRight: ""

    signal clickedLeft()
    signal clickedRight()

    RowLayout {
        anchors.fill: parent

        Item {
            width: 4
        }

        ToolButton {
            onClicked: clickedLeft()
            enabled: iconLeft !== ""
            contentItem: Image {
                source: parent.enabled ? "qrc:/images/" + iconLeft : ""
                anchors.centerIn: parent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            Label {
                id: lblMain
                horizontalAlignment: Label.AlignHCenter
                Layout.fillWidth: true
                color: Material.background
                font.pixelSize: 20
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                id: lblSub
                horizontalAlignment: Label.AlignHCenter
                Layout.fillWidth: true
                color: Material.background
                font.pixelSize: 16
                elide: Text.ElideRight
            }
        }

        ToolButton {
            onClicked: clickedRight()
            enabled: iconRight !== ""
            contentItem: Image {
                source: parent.enabled ? "qrc:/images/" + iconRight : ""
                anchors.centerIn: parent
            }
        }

        Item {
            width: 4
        }
    }
}
