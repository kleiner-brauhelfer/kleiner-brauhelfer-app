import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Drawer {
    property alias model: repeater.model

    z: 1
    leftPadding: 0    
    width: layout.width
    height: app.height

    Flickable {
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        contentHeight: layout.height
        clip: true

        ColumnLayout {
            id: layout
            focus: false
            anchors.top: parent.top
            anchors.left: parent.left
            spacing: 0

            Rectangle {
                Layout.preferredWidth: childrenRect.width
                Layout.preferredHeight: childrenRect.height
                color: Material.primary
                MouseArea {
                   anchors.fill: parent
                   onClicked: close()
                }
                RowLayout {
                    Item {
                        width: 48 * app.settings.scalingfactor
                        height: width
                        Image {
                            width: parent.width
                            height: parent.height
                            source: "qrc:/images/logo.png"
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.margins: 4
                        Label {
                            text: Qt.application.name
                            font.pointSize: 14 * app.settings.scalingfactor
                            font.weight: Font.Bold
                            color: Material.background
                        }
                        Label {
                            text: "v" + Qt.application.version
                            font.pointSize: 12 * app.settings.scalingfactor
                            color: Material.background
                        }
                    }
                }
            }

            Repeater {
                id: repeater
                Loader {
                    Layout.fillWidth: true
                    source: model.type
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator {}
    }
}
