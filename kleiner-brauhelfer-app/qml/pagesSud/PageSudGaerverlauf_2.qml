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
    title: qsTr("Hauptgärung")
    icon: "hauptgaerung.png"
    readOnly: Brauhelfer.readonly || ((!Brauhelfer.sud.BierWurdeGebraut || Brauhelfer.sud.BierWurdeAbgefuellt) && !app.brewForceEditable)

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
            should2: Brauhelfer.sud.SchnellgaerprobeAktiv ? Brauhelfer.sud.Gruenschlauchzeitpunkt : null
            title3: qsTr("Temp")
            color3: "#780000"
            legend.visible: false
            VXYModelMapper {
                model: Brauhelfer.sud.modelHauptgaerverlauf
                series: chart.series1
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Alc")
            }
            VXYModelMapper {
                model: Brauhelfer.sud.modelHauptgaerverlauf
                series: chart.series2
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("SW")
            }
            VXYModelMapper {
                model: Brauhelfer.sud.modelHauptgaerverlauf
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
            model: Brauhelfer.sud.modelHauptgaerverlauf
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
                height: btnAdd.height + 12
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
                    Brauhelfer.sud.modelHauptgaerverlauf.remove(index)
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
                            unit: " °P"
                            value: model.SW
                            color: chart.color2
                        }
                        LabelNumber {
                            Layout.preferredWidth: 70
                            precision: 1
                            unit: " °C"
                            value: model.Temp
                            color: chart.color3
                        }
                        LabelNumber {
                            Layout.preferredWidth: 70
                            precision: 1
                            unit: " %"
                            value: model.Alc
                            color: chart.color1
                        }
                    }
                    HorizontalDivider {}
                }
            }
        }

        Popup {
            property int index: -1
            property bool valueChanged: false

            id: popupEdit
            parent: page
            width: 240
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            function openIndex(index) {
                if (!page.readOnly) {
                    popupEdit.index = index
                    tfDate.date = Brauhelfer.sud.modelHauptgaerverlauf.data(index, "Zeitstempel")
                    tfSW.value = Brauhelfer.sud.modelHauptgaerverlauf.data(index, "SW")
                    tfDensity.value = Brauhelfer.calc.platoToDichte(tfSW.value)
                    tfTemp.value = Brauhelfer.sud.modelHauptgaerverlauf.data(index, "Temp")
                    valueChanged = false
                    open()
                }
            }

            function remove(index) {
                item.listView.currentItem.remove()
                close()
            }

            onClosed: {
                if (popupEdit.valueChanged && !isNaN(tfDate.date)) {
                    Brauhelfer.sud.modelHauptgaerverlauf.setData(popupEdit.index,
                                {"Zeitstempel": tfDate.date,
                                 "SW": tfSW.value,
                                 "Temp": tfTemp.value })
                }
                navPane.setFocus()
            }

            background: Rectangle {
                color: Material.background
                radius: 10
                MouseArea {
                    anchors.fill: parent
                    onClicked: forceActiveFocus()
                }
            }

            GridLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                columns: 3
                rows: 6
                columnSpacing: 16

                Image {
                    source: "qrc:/images/ic_schedule.png"
                }

                TextFieldDate {
                    id: tfDate
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    onNewDate: {
                        this.date = date
                        popupEdit.valueChanged = true
                    }
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
                            tfSW.value = sre
                        }
                        else {
                            tfDensity.value = NaN
                            tfSW.value = NaN
                        }
                        popupEdit.valueChanged = true
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
                    onNewValue: {
                        var density = value
                        if (!isNaN(density)) {
                            tfSW.value = Brauhelfer.calc.dichteToPlato(density)
                        }
                        else {
                            tfSW.value = NaN
                        }
                        tfBrix.value = NaN
                        popupEdit.valueChanged = true
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
                    onNewValue: {
                        this.value = value
                        var sre = value
                        if (!isNaN(sre)) {
                            tfDensity.value = Brauhelfer.calc.platoToDichte(sre)
                        }
                        else {
                            tfDensity.value = NaN
                        }
                        tfBrix.value = NaN
                        popupEdit.valueChanged = true
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
                    id: tfTemp
                    onNewValue: {
                        this.value = value
                        popupEdit.valueChanged = true
                    }
                }

                LabelPrim {
                    text: "°C"
                    Layout.fillWidth: true
                }

                ToolButton {
                    Layout.columnSpan: 3
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    onClicked: popupEdit.remove(popupEdit.index)
                    contentItem: Image {
                        source: "qrc:/images/ic_delete.png"
                        anchors.centerIn: parent
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
                Brauhelfer.sud.modelHauptgaerverlauf.append()
                item.listView.currentIndex = item.listView.count - 1
                popupEdit.openIndex(item.listView.currentIndex)
            }
        }
    }
}
