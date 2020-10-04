import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtCharts 2.2

import "../common"
import brauhelfer 1.0
import ProxyModelSud 1.0

PageBase {

    signal clicked(int id)

    id: page
    title: qsTr("Brauübersicht")
    icon: "timeline.png"

    ColumnLayout {
        property var item1: selectionModel.get(app.settings.uebersichtIndex1)
        property var item2: selectionModel.get(app.settings.uebersichtIndex2)
        property alias listView: listView
        anchors.fill: parent
        spacing: 0

        Component.onCompleted: selectionModel.get(8).unit = Qt.locale().currencySymbol() + "/" + qsTr("l")

        ListModel {
            id: selectionModel
            ListElement {
                text: qsTr("Menge")
                field: "erg_AbgefuellteBiermenge"
                unit: qsTr("l")
                precision: 1
            }
            ListElement {
                text: qsTr("SW")
                field: "SWIst"
                unit: qsTr("°P")
                precision: 1
            }
            ListElement {
                text: qsTr("SHA")
                field: "erg_Sudhausausbeute"
                unit: qsTr("%")
                precision: 0
            }
            ListElement {
                text: qsTr("Eff. SHA")
                field: "erg_EffektiveAusbeute"
                unit: qsTr("%")
                precision: 0
            }
            ListElement {
                text: qsTr("Alkohol")
                field: "erg_Alkohol"
                unit: qsTr("%vol")
                precision: 1
            }
            ListElement {
                text: qsTr("SRE")
                field: "SREIst"
                unit: qsTr("°P")
                precision: 1
            }
            ListElement {
                text: qsTr("sEVG")
                field: "sEVG"
                unit: qsTr("%")
                precision: 0
            }
            ListElement {
                text: qsTr("tEVG")
                field: "tEVG"
                unit: qsTr("%")
                precision: 0
            }
            ListElement {
                text: qsTr("Kosten")
                field: "erg_Preis"
                unit: ""
                precision: 2
            }
        }

        // workaround for clip bug
        Item {
            z: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            Rectangle {
                anchors.fill: parent
                color: Material.background
            }

            Chart {
                id: chart
                anchors.fill: parent
                timeformat: "MM.yy"
                title1: item1.text
                color1: "#741EA6"
                title2: item2.text
                color2: "#2E4402"
                series2.width: 2
                legend.visible: false
                VXYModelMapper {
                    model: listView.model
                    series: chart.series1
                    xColumn: listView.model.fieldIndex("Braudatum")
                    yColumn: listView.model.fieldIndex(item1.field)
                }
                VXYModelMapper {
                    model: listView.model
                    series: chart.series2
                    xColumn: listView.model.fieldIndex("Braudatum")
                    yColumn: listView.model.fieldIndex(item2.field)
                }
                Component.onCompleted: listView.model.invalidate()
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            //clip: true
            boundsBehavior: Flickable.OvershootBounds
            model: ProxyModelSud {
                sourceModel: app.pageGlobalAuswahl.getModel()
                filterStatus: (ProxyModelSud.Abgefuellt | ProxyModelSud.Verbraucht)
                sortOrder: Qt.AscendingOrder
                sortColumn: fieldIndex("Braudatum")
            }
            headerPositioning: ListView.OverlayHeader
            ScrollIndicator.vertical: ScrollIndicator {}
            header: Rectangle {
                z: 2
                width: listView.width
                height: header.height
                color: Material.background
                ColumnLayout {
                    id: header
                    width: listView.width
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Braudatum")
                        }
                        ComboBoxBase {
                            Layout.preferredWidth: 120
                            flat: true
                            textRole: "text"
                            model: selectionModel
                            currentIndex: app.settings.uebersichtIndex1
                            onCurrentIndexChanged: {
                                app.settings.uebersichtIndex1 = currentIndex
                                navPane.setFocus()
                            }
                        }
                        ComboBoxBase {
                            Layout.preferredWidth: 120
                            flat: true
                            textRole: "text"
                            model: selectionModel
                            currentIndex: app.settings.uebersichtIndex2
                            onCurrentIndexChanged: {
                                app.settings.uebersichtIndex2 = currentIndex
                                navPane.setFocus()
                            }
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                        height: 2
                    }
                }
            }

            delegate: ItemDelegate {
                property variant values: model
                id: rowDelegate
                width: listView.width
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
                            Layout.preferredWidth: 120
                            color: chart.color1
                            precision: item1.precision
                            unit: item1.unit
                            value: model[item1.field]
                        }
                        LabelNumber {
                            Layout.preferredWidth: 120
                            color: chart.color2
                            precision: item2.precision
                            unit: item2.unit
                            value: model[item2.field]
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
