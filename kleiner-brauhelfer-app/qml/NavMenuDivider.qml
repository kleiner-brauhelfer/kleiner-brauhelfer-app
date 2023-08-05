import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    height: 17
    anchors.left: parent.left
    anchors.right: parent.right
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 1
        color: Material.primary
    }
}
