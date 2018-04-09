import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff Hefe")
    icon: "yeast.png"

    component: ListView {
        id: listView
        clip: true
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        model: SortFilterProxyModel {
            id: myModel
            sourceModel: Brauhelfer.modelHefe
            filterKeyColumn: sourceModel.fieldIndex("Menge")
        }
        headerPositioning: isLandscape? ListView.PullBackHeader : ListView.OverlayHeader
        Component.onCompleted: positionViewAtEnd()
        ScrollIndicator.vertical: ScrollIndicator {}
        header: Rectangle {
            z: 2
            width: parent.width
            height: header.height
            color: Material.background
            ColumnLayout {
                id: header
                width: parent.width
                RowLayout {
                    Layout.fillWidth: true
                    LabelPrim {
                        Layout.fillWidth: true
                        leftPadding: 8
                        font.bold: true
                        text: qsTr("Beschreibung")
                    }
                    LabelPrim {
                        Layout.preferredWidth: 70
                        font.bold: true
                        text: qsTr("Menge")
                    }
                }
                HorizontalDivider {}
            }
        }
        footerPositioning: isLandscape? ListView.PullBackFooter : ListView.OverlayFooter
        footer: Rectangle {
            z: 2
            width: parent.width
            height: layoutFilter.height
            color: Material.background
            Flow {
                id: layoutFilter
                width: parent.width
                RadioButton {
                    checked: true
                    text: qsTr("alle")
                    onClicked: myModel.filterRegExp = /(?:)/
                }
                RadioButton {
                    text: qsTr("verfügbar")
                    onClicked: myModel.filterRegExp = /[^0]+/
                }
            }
        }
        delegate: ItemDelegate {
            id: rowDelegate
            width: parent.width
            height: dataColumn.implicitHeight
            padding: 0
            text: " "

            NumberAnimation {
                id: removeFake
                target: rowDelegate
                property: "height"
                to: 0
                easing.type: Easing.InOutQuad
                onStopped: rowDelegate.visible = false
            }

            onClicked: {
                listView.currentIndex = index
                popupEdit.openIndex(listView.currentIndex)
            }

            function remove() {
                removeFake.start()
                chart.removeFake(index)
                Brauhelfer.sud.modelSchnellgaerverlauf.remove(index)
            }

            ColumnLayout {
                id: dataColumn
                parent: rowDelegate.contentItem
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                RowLayout {
                    Layout.fillWidth: true
                    LabelPrim {
                        Layout.fillWidth: true
                        leftPadding: 8
                        text: model.Beschreibung
                    }
                    LabelNumber {
                        Layout.preferredWidth: 70
                        precision: 0
                        value: model.Menge
                    }
                }
                HorizontalDivider {}
            }
        }
    }
}
