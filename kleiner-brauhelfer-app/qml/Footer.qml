import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "common"

Pane {

    property var swipeView : null

    signal clickedLeft()
    signal clickedRight()

    z: 1
    Material.elevation: 8
    height: layout.height
    padding: 0

    MouseAreaCatcher { }

    RowLayout {
        id: layout
        height: 24
        anchors.fill: parent

        Item {
            width: 4
        }

        ToolButton {
            implicitWidth: parent.height
            implicitHeight: parent.height
            onClicked: clickedLeft()
            enabled: swipeView.currentIndex > 0
            contentItem: Image {
                anchors.fill: parent
                visible: parent.enabled
                source: "qrc:/images/ic_chevron_left.png"
                opacity: 0.87
            }
        }

        Item {
            Layout.fillWidth: true
            PageIndicator {
                id: pageIndicator
                count: swipeView.count
                currentIndex: swipeView.currentIndex
                anchors.centerIn: parent
                delegate: Rectangle {
                    implicitWidth: 8
                    implicitHeight: 8
                    radius: width / 2
                    color: Material.primary
                    opacity: index === pageIndicator.currentIndex ? 1 : 0.45
                }
            }
        }

        ToolButton {
            implicitWidth: parent.height
            implicitHeight: parent.height
            onClicked: clickedRight()
            enabled: swipeView.currentIndex < swipeView.count - 1
            contentItem: Image {
                anchors.fill: parent
                visible: parent.enabled
                source: "qrc:/images/ic_chevron_right.png"
                opacity: 0.87
            }
        }

        Item {
            width: 4
        }
    }
}
