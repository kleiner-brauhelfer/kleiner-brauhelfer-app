import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

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
