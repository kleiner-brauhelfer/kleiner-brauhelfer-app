import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Popup {
    default property alias contents: placeholder.children
    property int margin: 20

    id: popup
    parent: page

    width: parent.width - margin
    height: Math.min(placeholder.childrenRect.height + 2 * padding, parent.height - margin)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true

    onClosed: navPane.setFocus()

    background: Rectangle {
        color: Material.background
        radius: 10
        MouseArea {
            anchors.fill: parent
            onClicked: forceActiveFocus()
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: 0
        boundsBehavior: Flickable.OvershootBounds
        contentHeight: placeholder.childrenRect.height
        clip: true
        onVisibleChanged: contentY = 0
        ScrollIndicator.vertical: ScrollIndicator {}
        Item {
            id: placeholder
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 0
        }
    }
}
