import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
import QtCharts

import "../common"
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Nachgärung")
    icon: "nachgaerung.png"
    readOnly: Brauhelfer.readonly || app.settings.readonly || (Brauhelfer.sud.Status !== Brauhelfer.Abgefuellt && !app.brewForceEditable)

    ColumnLayout {
        property alias listView: listView
        anchors.fill: parent

        Chart {
            id: chart
            Layout.fillWidth: true
            Layout.fillHeight: true
            title1: qsTr("CO2")
            color1: "#741EA6"
            should1: Brauhelfer.sud.CO2
            title2: qsTr("Druck")
            color2: "#2E4402"
            title3: qsTr("Temp")
            color3: "#780000"
            legend.visible: false
            VXYModelMapper {
                model: listView.model
                series: chart.series1
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("CO2")
            }
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
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.OvershootBounds
            model: Brauhelfer.sud.modelNachgaerverlauf
            //headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
            Component.onCompleted: if (!readOnly) positionViewAtEnd()
            ScrollIndicator.vertical: ScrollIndicator {}
            header: Rectangle {
                property var widthCol1: headerLabel1.width
                property var widthCol2: headerLabel2.width
                property var widthCol3: headerLabel3.width
                z: 2
                width: listView.width
                height: header.height
                color: Material.background

                ColumnLayout {
                    id: header
                    width: parent.width
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            leftPadding: 8
                            font.bold: true
                            text: qsTr("Datum")
                        }
                        LabelPrim {
                            id: headerLabel1
                            font.bold: true
                            text: qsTr("Druck [bar]")
                        }
                        LabelPrim {
                            id: headerLabel2
                            font.bold: true
                            text: qsTr("Temp [°C]")
                        }
                        LabelPrim {
                            id: headerLabel3
                            font.bold: true
                            text: qsTr("CO2 [g/ml]")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                        height: 2
                    }
                }
            }

            footerPositioning: ListView.InlineFooter
            footer: Item {
                height: !page.readOnly ? btnAdd.height + 12 : 0
            }

            delegate: ItemDelegate {
                property variant values: model
                id: rowDelegate
                width: listView.width
                height: dataColumn.implicitHeight
                padding: 0
                visible: !model.deleted
                text: " "

                NumberAnimation {
                    property int index : listView.currentIndex
                    id: removeFake
                    target: rowDelegate
                    property: "height"
                    to: 0
                    easing.type: Easing.InOutQuad
                    onStopped: {
                        rowDelegate.visible = false
                        listView.model.removeRow(index)
                    }
                }

                onClicked: {
                    listView.currentIndex = index
                    popuploader.active = true
                }

                function remove() {
                    popuploader.active = false
                    removeFake.start()
                    chart.removeFake(index)
                }

                ColumnLayout {
                    id: dataColumn
                    parent: rowDelegate.contentItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                        LabelDateTime {
                            Layout.fillWidth: true
                            leftPadding: 8
                            date: Zeitstempel
                        }
                        LabelPrim {
                            text: model.Bemerkung === "" ? " " : "*"
                        }
                        LabelNumber {
                            Layout.preferredWidth: listView.headerItem.widthCol1
                            horizontalAlignment: Text.AlignHCenter
                            value: model.Druck
                            color: chart.color2
                        }
                        LabelNumber {
                            Layout.preferredWidth: listView.headerItem.widthCol2
                            horizontalAlignment: Text.AlignHCenter
                            precision: 1
                            value: model.Temp
                            color: chart.color3
                        }
                        LabelNumber {
                            Layout.preferredWidth: listView.headerItem.widthCol3
                            horizontalAlignment: Text.AlignHCenter
                            value: model.CO2
                            color: chart.color1
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                }
            }

            FloatingButton {
                id: btnAdd
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                imageSource: "qrc:/images/ic_add_white.png"
                visible: !page.readOnly
                onClicked: {
                    listView.model.append({"SudID": Brauhelfer.sud.id})
                    listView.currentIndex = listView.count - 1
                    popuploader.active = true
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
                onOpened: tfDruck.forceActiveFocus()
                onClosed: popuploader.active = false
                GridLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    columns: 3
                    columnSpacing: 16

                    Image {
                        source: "qrc:/images/baseline_date_range.png"
                    }

                    TextFieldDate {
                        id: tfDate
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        enabled: !page.readOnly
                        date: model.Zeitstempel
                        onNewDate: model.Zeitstempel = date
                    }

                    Image {
                        source: "qrc:/images/pressure.png"
                    }

                    TextFieldNumber {
                        id: tfDruck
                        Layout.alignment: Qt.AlignHCenter
                        enabled: !page.readOnly
                        min: 0.0
                        max: 99.9
                        precision: 2
                        value: model.Druck
                        onNewValue: model.Druck = value
                    }

                    LabelUnit {
                        text: qsTr("bar")
                    }

                    Image {
                        source: "qrc:/images/temperature.png"
                    }

                    TextFieldTemperature {
                        Layout.alignment: Qt.AlignHCenter
                        enabled: !page.readOnly
                        value: model.Temp
                        onNewValue: model.Temp = value
                    }

                    LabelUnit {
                        text: qsTr("°C")
                    }

                    TextAreaBase {
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        enabled: !page.readOnly
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.Bemerkung
                        onTextChanged: if (activeFocus) model.Bemerkung = text
                    }

                    ToolButton {
                        Layout.columnSpan: 3
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        visible: !page.readOnly
                        onClicked: listView.currentItem.remove()
                        contentItem: Image {
                            source: "qrc:/images/ic_delete.png"
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }
}
