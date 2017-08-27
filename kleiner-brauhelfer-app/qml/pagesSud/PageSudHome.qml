import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Auswahl")
    icon: "ic_view_module.png"
    enabled: Brauhelfer.sud.loaded

    component: ColumnLayout {
        anchors.fill: parent

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            boundsBehavior: Flickable.OvershootBounds
            cellWidth: 120
            cellHeight: 120

            Component.onCompleted: {
                for (var i = 1; i < viewSud.count; ++i)
                    model.append({"view": viewSud, "index": i})
            }

            model: ListModel { }

            delegate: ToolButton {

                property var page: model.view.itemAt(model.index)

                implicitWidth: 120
                implicitHeight: 120
                onClicked:  navPane.goTo(model.view, model.index)

                Rectangle {
                    id: rectangle
                    color: Qt.lighter(Material.primary)
                    anchors.margins: 2
                    anchors.fill: parent
                    border.width: 1
                    Image {
                        id: image
                        width: 48
                        height: 48
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "qrc:/images/" + page.icon
                    }
                    LabelPrim {
                        text: page.title
                        verticalAlignment: Text.AlignTop
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            ScrollIndicator.vertical: ScrollIndicator {}
        }

        Switch {
            text: qsTr("Eingabefelder entsperren")
            checked: app.brewForceEditable
            onCheckedChanged: app.brewForceEditable = checked
        }
    }
}
