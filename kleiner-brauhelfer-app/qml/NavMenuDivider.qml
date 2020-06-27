import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

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
