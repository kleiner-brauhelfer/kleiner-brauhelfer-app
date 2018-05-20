import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.2

import "../common"
import brauhelfer 1.0
import SortFilterProxyModelSud 1.0

PageBase {

    signal clicked(int id)

    id: page
    title: qsTr("Brauübersicht")
    icon: "timeline.png"

    ColumnLayout {
        property alias listView: listView
        anchors.fill: parent

        Chart {
            id: chart
            Layout.fillWidth: true
            Layout.fillHeight: true
            timeformat: "MM.yy"
            title1: qsTr("Menge")
            color1: "#741EA6"
            //title2: qsTr("Druck")
            //color2: "#2E4402"
            //title3: qsTr("Temp")
            //color3: "#780000"
            legend.visible: false
            VXYModelMapper {
                model: listView.model
                series: chart.series1
                xColumn: listView.model.sourceModel.fieldIndex("Braudatum")
                yColumn: listView.model.sourceModel.fieldIndex("erg_AbgefuellteBiermenge")
                //model: Brauhelfer.modelSudAuswahl
                //xColumn: model.fieldIndex("Braudatum")
                //yColumn: model.fieldIndex("erg_AbgefuellteBiermenge")
            }
            /*
            VXYModelMapper {
                model: listView.model
                series: chart.series2
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Druck")
            }
            VXYModelMapper {
                model: listView.model
                series: chart.series3
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Temp")
            }
            */
            Component.onCompleted: listView.model.invalidate()
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.OvershootBounds
            model: SortFilterProxyModelSud {
                sourceModel: Brauhelfer.modelSudAuswahl
                filterValue: SortFilterProxyModelSud.Abgefuellt
            }
            headerPositioning: ListView.OverlayHeader
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
                            text: qsTr("Braudatum")
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

            delegate: ItemDelegate {
                property variant values: model
                id: rowDelegate
                width: parent.width
                height: dataColumn.implicitHeight
                padding: 0
                text: " "

                onClicked: page.clicked(ID)

                ColumnLayout {
                    id: dataColumn
                    parent: rowDelegate.contentItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        text: model.Sudname
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        LabelDate {
                            Layout.fillWidth: true
                            date: model.Braudatum
                        }
                        LabelNumber {
                            Layout.preferredWidth: 70
                            precision: 1
                            unit: qsTr("Liter")
                            value: model.erg_AbgefuellteBiermenge
                        }
                    }
                    HorizontalDivider {}
                }
            }
        }
    }
}
