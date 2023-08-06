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

    z: 1
    Material.elevation: 4
    height: layout.implicitHeight
    padding: 0
    focusPolicy: Qt.StrongFocus

    RowLayout {
        id: layout
        anchors.fill: parent

        ToolButton {
            Layout.leftMargin: 4
            onClicked: clickedLeft()
            enabled: iconLeft
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
            Layout.rightMargin: 4
            onClicked: clickedRight()
            enabled: iconRight
            contentItem: Image {
                source: parent.enabled ? "qrc:/images/" + iconRight : ""
                anchors.centerIn: parent
            }
        }
    }
}
