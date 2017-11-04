import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Page {
    Flickable {
        anchors.fill: parent
        anchors.margins: 8
        boundsBehavior: Flickable.OvershootBounds
        clip: true
        contentHeight: layout.height
        ScrollIndicator.vertical: ScrollIndicator {}

        ColumnLayout {
            id: layout
            spacing: 8
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }
}
