import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import QtCharts 2.2

import "../common"
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Schnellgärung")
    icon: "schnellgaerverlauf.png"
    readOnly: Brauhelfer.readonly || ((!Brauhelfer.sud.BierWurdeGebraut || Brauhelfer.sud.BierWurdeAbgefuellt || !Brauhelfer.sud.SchnellgaerprobeAktiv) && !app.brewForceEditable)

    component: ColumnLayout {
        property alias listView: listView
        anchors.fill: parent

        Chart {
            id: chart
            implicitHeight: parent.height / 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title1: qsTr("Alkohol")
            color1: "#741EA6"
            title2: qsTr("Extrakt")
            color2: "#2E4402"
            title3: qsTr("Temp")
            color3: "#780000"
            legend.visible: false
            VXYModelMapper {
                model: listView.model
                series: chart.series1
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Alc")
            }
            VXYModelMapper {
                model: listView.model
                series: chart.series2
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("SW")
            }
            VXYModelMapper {
                model: listView.model
                series: chart.series3
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Temp")
            }
        }

        ListView {
            id: listView
            clip: true
            anchors.top: chart.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            boundsBehavior: Flickable.OvershootBounds
            model: Brauhelfer.sud.modelSchnellgaerverlauf
            headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
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
                            text: qsTr("Datum")
                        }
                        LabelPrim {
                            Layout.preferredWidth: 70
                            font.bold: true
                            text: chart.title2
                        }
                        LabelPrim {
                            Layout.preferredWidth: 70
                            font.bold: true
                            text: chart.title3
                        }
                        LabelPrim {
                            Layout.preferredWidth: 70
                            font.bold: true
                            text: chart.title1
                        }
                    }
                    HorizontalDivider {}
                }
            }

            footerPositioning: ListView.InlineFooter
            footer: Item {
                height: !page.readOnly ? btnAdd.height + 12 : 0
            }

            delegate: ItemDelegate {
                property variant values: model
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
                    if (!page.readOnly)
                        popuploader.active = true
                }

                function remove() {
                    removeFake.start()
                    chart.removeFake(index)
                    listView.model.remove(index)
                }

                ColumnLayout {
                    id: dataColumn
                    parent: rowDelegate.contentItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    RowLayout {
                        Layout.fillWidth: true
                        LabelDateTime {
                            Layout.fillWidth: true
                            leftPadding: 8
                            date: Zeitstempel
                        }
                        LabelPlato {
                            Layout.preferredWidth: 70
                            unit: "°P"
                            value: model.SW
                            color: chart.color2
                        }
                        LabelNumber {
                            Layout.preferredWidth: 70
                            precision: 1
                            unit: "°C"
                            value: model.Temp
                            color: chart.color3
                        }
                        LabelNumber {
                            Layout.preferredWidth: 70
                            precision: 1
                            unit: "%"
                            value: model.Alc
                            color: chart.color1
                        }
                    }
                    HorizontalDivider {}
                }
            }
        }

        Loader {
            id: popuploader
            active: false
            focus: true
            onLoaded: item.open()
            sourceComponent: PopupBase {
                property variant model: listView.currentItem.values
                maxWidth: 240
                y: page.height * 0.1
                onOpened: tfSW.forceActiveFocus()
                onClosed: popuploader.active = false

                function remove() {
                    listView.currentItem.remove()
                    close()
                }

                GridLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    columns: 3
                    columnSpacing: 16

                    Image {
                        source: "qrc:/images/ic_schedule.png"
                    }

                    TextFieldDate {
                        id: tfDate
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        date: model.Zeitstempel
                        onNewDate: model.Zeitstempel = date
                    }

                    Image {
                        source: "qrc:/images/refractometer.png"
                    }

                    TextFieldPlato {
                        id: tfBrix
                        onNewValue: {
                            this.value = value
                            var brix = value
                            if (!isNaN(brix)) {
                                var density = Brauhelfer.calc.brixToDichte(Brauhelfer.sud.SWIst, brix)
                                var sre = Brauhelfer.calc.dichteToPlato(density)
                                tfDensity.value = density
                                model.SW = sre
                            }
                            else {
                                tfDensity.value = NaN
                                model.SW = NaN
                            }
                        }
                    }

                    LabelPrim {
                        text: "°Brix"
                        Layout.fillWidth: true
                    }

                    Image {
                        source: "qrc:/images/spindel.png"
                    }

                    TextFieldNumber {
                        id: tfDensity
                        min: 0.0
                        max: 2.0
                        precision: 4
                        value: Brauhelfer.calc.platoToDichte(model.SW)
                        onNewValue: {
                            this.value = value
                            var density = value
                            if (!isNaN(density)) {
                                model.SW = Brauhelfer.calc.dichteToPlato(density)
                            }
                            else {
                                model.SW = NaN
                            }
                            tfBrix.value = NaN
                        }
                    }

                    LabelPrim {
                        text: "g/ml"
                        Layout.fillWidth: true
                    }

                    Image {
                        source: "qrc:/images/sugar.png"
                    }

                    TextFieldPlato {
                        id: tfSW
                        value: model.SW
                        onNewValue: {
                            model.SW = value
                            var sre = value
                            if (!isNaN(sre)) {
                                tfDensity.value = Brauhelfer.calc.platoToDichte(sre)
                            }
                            else {
                                tfDensity.value = NaN
                            }
                            tfBrix.value = NaN
                        }
                    }

                    LabelPrim {
                        text: "°P"
                        Layout.fillWidth: true
                    }

                    Image {
                        source: "qrc:/images/temperature.png"
                    }

                    TextFieldTemperature {
                        value: model.Temp
                        onNewValue: model.Temp = value
                    }

                    LabelPrim {
                        text: "°C"
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        Layout.columnSpan: 3
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        onClicked: remove()
                        contentItem: Image {
                            source: "qrc:/images/ic_delete.png"
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }

        FloatingButton {
            id: btnAdd
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.bottom: listView.bottom
            anchors.bottomMargin: 8
            imageSource: "qrc:/images/ic_add_white.png"
            visible: !page.readOnly
            onClicked: {
                listView.model.append()
                listView.currentIndex = listView.count - 1
                popuploader.active = true
            }
        }
    }
}
