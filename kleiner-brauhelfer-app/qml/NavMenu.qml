import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Drawer {
    property alias model: repeater.model

    z: 1
    leftPadding: 0    
    width: Math.min(240, Math.min(app.width, app.height) * 2 / 3)
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
            anchors.right: parent.right
            spacing: 0

            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 60

                Rectangle {
                    anchors.fill: parent
                    color: Material.primary
                    MouseArea {
                       anchors.fill: parent
                       onClicked: close()
                    }
                }

                GridLayout{
                    anchors.fill: parent
                    columns: 2
                    rows: 2

                    Item {
                        Layout.rowSpan: 2
                        width: 48
                        height: width
                        Image {
                            width: parent.width
                            height: parent.height
                            source: "qrc:/images/logo.png"
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignBottom
                        text: Qt.application.name
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Material.background
                    }

                    Label {
                        Layout.fillWidth: true
                        Layout.rightMargin: 8
                        Layout.bottomMargin: 4
                        horizontalAlignment: Text.AlignRight
                        text: "v" + Qt.application.version
                        color: Material.background
                    }
                }
            }

            Item {
                height: 8
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
