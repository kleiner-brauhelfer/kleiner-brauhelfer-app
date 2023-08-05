import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import "common"

ToolBar {

    property alias text: lblMain.text
    property alias textSub: lblSub.text
    property string iconLeft: ""
    property string iconRight: ""

    signal clickedLeft()
    signal clickedRight()

    height: layout.implicitHeight

    MouseAreaCatcher { }

    RowLayout {
        id: layout
        anchors.fill: parent
        Layout.leftMargin: 4
        Layout.rightMargin: 4

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
                font.pointSize: 20 * app.settings.scalingfactor
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                id: lblSub
                horizontalAlignment: Label.AlignHCenter
                Layout.fillWidth: true
                color: Material.background
                font.pointSize: 16 * app.settings.scalingfactor
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
    }
}
