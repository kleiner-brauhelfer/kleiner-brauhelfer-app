import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Popup {
    default property alias contents: placeholder.children
    property int margin: 20
    property int maxWidth: 500

    id: popup
    parent: page

    width: Math.min(maxWidth, parent.width - margin)
    height: Math.min(flickable.contentHeight + 2 * padding, parent.height - margin)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true

    onOpened: forceActiveFocus()
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
        MouseAreaCatcher { }
        Item {
            id: placeholder
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 0
        }
    }
}
