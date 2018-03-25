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
    title: qsTr("Nachgärung")
    icon: "nachgaerung.png"
    readOnly: Brauhelfer.readonly || ((!Brauhelfer.sud.BierWurdeAbgefuellt || Brauhelfer.sud.BierWurdeVerbraucht) && !app.brewForceEditable)

    component: ColumnLayout {
        property alias listView: listView
        anchors.fill: parent

        Chart {
            id: chart
            implicitHeight: parent.height / 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title1: qsTr("CO2")
            color1: "#741EA6"
            should1: Brauhelfer.sud.CO2
            title2: qsTr("Druck")
            color2: "#2E4402"
            title3: qsTr("Temp")
            color3: "#780000"
            legend.visible: false
            VXYModelMapper {
                model: Brauhelfer.sud.modelNachgaerverlauf
                series: chart.series1
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("CO2")
            }
            VXYModelMapper {
                model: Brauhelfer.sud.modelNachgaerverlauf
                series: chart.series2
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Druck")
            }
            VXYModelMapper {
                model: Brauhelfer.sud.modelNachgaerverlauf
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
            model: Brauhelfer.sud.modelNachgaerverlauf
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
                height: !page.readOnly ? btnAdd.height + 12 : 0
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
                    Brauhelfer.sud.modelNachgaerverlauf.remove(index)
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
                        LabelNumber {
                            Layout.preferredWidth: 70
                            unit: "bar"
                            value: model.Druck
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
                            unit: "g/ml"
                            value: model.CO2
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
                    tfDate.date = Brauhelfer.sud.modelNachgaerverlauf.data(index, "Zeitstempel")
                    tfDruck.value = Brauhelfer.sud.modelNachgaerverlauf.data(index, "Druck")
                    tfTemp.value = Brauhelfer.sud.modelNachgaerverlauf.data(index, "Temp")
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
                  Brauhelfer.sud.modelNachgaerverlauf.setData(popupEdit.index,
                                {"Zeitstempel": tfDate.date,
                                 "Druck": tfDruck.value,
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
                rows: 4
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
                    source: "qrc:/images/pressure.png"
                }

                TextFieldNumber {
                    id: tfDruck
                    min: 0.0
                    max: 99.9
                    precision: 2
                    onNewValue: {
                        this.value = value
                        popupEdit.valueChanged = true
                    }
                }

                LabelPrim {
                    text: "bar"
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
                Brauhelfer.sud.modelNachgaerverlauf.append()
                item.listView.currentIndex = item.listView.count - 1
                popupEdit.openIndex(item.listView.currentIndex)
            }
        }
    }
}
