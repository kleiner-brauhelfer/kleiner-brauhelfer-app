import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0

PageBase {
    title: qsTr("Auswahl")
    icon: "ic_view_module.png"
    enabled: Brauhelfer.sud.isLoaded
    readOnly: Brauhelfer.readonly

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0

        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            boundsBehavior: Flickable.OvershootBounds
            snapMode: GridView.SnapToRow
            clip: true
            cellWidth: app.width / (Math.floor(app.width / (100 * app.settings.scalingfactor)))
            cellHeight: cellWidth
            ScrollIndicator.vertical: ScrollIndicator { }

            Component.onCompleted: {
                for (var i = 1; i < viewSud.count; ++i)
                    model.append({"view": viewSud, "index": i})
            }

            model: ListModel { }

            delegate: ToolButton {

                property var page: model.view.itemAt(model.index)

                implicitWidth: grid.cellWidth
                implicitHeight: grid.cellHeight
                onClicked: navPane.goTo(model.view, model.index)

                Rectangle {
                    id: rectangle
                    color: Qt.lighter(Material.primary)
                    anchors.margins: 2
                    anchors.fill: parent
                    border.width: 1
                    Image {
                        id: image
                        width: 48 * app.settings.scalingfactor
                        height: width
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
        }

        SwitchBase {
            Layout.fillWidth: true
            text: qsTr("Alle Eingabefelder entsperren")
            checked: app.brewForceEditable
            onCheckedChanged: app.brewForceEditable = checked
        }
    }
}
