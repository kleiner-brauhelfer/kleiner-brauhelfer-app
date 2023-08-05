import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
import QtCharts
import Qt.labs.platform

import "../common"
import brauhelfer 1.0
import ProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Hauptgärung")
    icon: "hauptgaerung.png"
    readOnly: Brauhelfer.readonly || app.settings.readonly || (Brauhelfer.sud.Status !== Brauhelfer.Gebraut && !app.brewForceEditable)

    ColumnLayout {
        property alias listView: listView
        anchors.fill: parent

        Chart {
            id: chart
            Layout.fillWidth: true
            Layout.fillHeight: true
            title1: qsTr("Alkohol")
            color1: "#741EA6"
            title2: qsTr("Extrakt")
            color2: "#2E4402"
            should2: Brauhelfer.sud.SchnellgaerprobeAktiv ? Brauhelfer.sud.Gruenschlauchzeitpunkt : null
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
                yColumn: model.fieldIndex("Restextrakt")
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
            model: Brauhelfer.sud.modelHauptgaerverlauf
            //headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
            Component.onCompleted: if (!readOnly) positionViewAtEnd()
            ScrollIndicator.vertical: ScrollIndicator {}
            header: Rectangle {
                property int widthCol1: headerLabel1.width
                property int widthCol2: headerLabel2.width
                property int widthCol3: headerLabel3.width
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
                            text: qsTr("SRE [°P]")
                        }
                        LabelPrim {
                            id: headerLabel2
                            font.bold: true
                            text: qsTr("Temp [°C]")
                        }
                        LabelPrim {
                            id: headerLabel3
                            font.bold: true
                            text: qsTr("Alk [%]")
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
                        LabelPlato {
                            Layout.preferredWidth: listView.headerItem.widthCol1
                            horizontalAlignment: Text.AlignHCenter
                            value: model.Restextrakt
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
                            precision: 1
                            value: model.Alc
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

        HorizontalDivider {
            Layout.fillWidth: true
            visible: listViewWeitereZutaten.count > 0
        }
        LabelHeader {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            visible: listViewWeitereZutaten.count > 0
            text: qsTr("Weitere Zutaten")
        }
        ListView {
            id: listViewWeitereZutaten
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            height: Math.min(contentHeight, 80)
            //clip: true
            boundsBehavior: Flickable.OvershootBounds
            ScrollIndicator.vertical: ScrollIndicator {}
            model: ProxyModel {
                sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                filterKeyColumn: fieldIndex("Zeitpunkt")
                filterRegularExpression: /0/
            }
            delegate: ItemDelegate {
                width: listView.width
                height: dataColumn2.implicitHeight
                enabled: !page.readOnly
                onClicked: {
                    listViewWeitereZutaten.currentIndex = index
                    popuploaderWeitereZutaten.active = true
                }
                ColumnLayout {
                    id: dataColumn2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    RowLayout {
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                        Layout.fillWidth: true
                        LabelPrim {
                            Layout.fillWidth: true
                            text: model.Name
                        }
                        LabelPrim {
                            text: {
                                switch (model.Zugabestatus)
                                {
                                case 0: return qsTr("nicht zugegeben")
                                case 1: return model.Entnahmeindex === 0 ? qsTr("zugegeben seit") : qsTr("zugegeben")
                                case 2: return qsTr("entnommen nach")
                                default: return ""
                                }
                            }
                        }
                        LabelNumber {
                            visible: model.Zugabestatus > 0 && model.Entnahmeindex === 0
                            precision: 0
                            value: {
                                switch (model.Zugabestatus)
                                {
                                case 1: return (new Date().getTime() - model.ZugabeDatum.getTime()) / 1440 / 60000
                                case 2: return model.Zugabedauer/ 1440
                                default: return 0.0
                                }
                            }
                            unit: qsTr("Tage")
                        }
                    }
                }
            }

            Loader {
                id: popuploaderWeitereZutaten
                active: false
                onLoaded: item.open()
                sourceComponent: PopupWeitereZutatenGaben {
                    model: listViewWeitereZutaten.model
                    currentIndex: listViewWeitereZutaten.currentIndex
                    onClosed: popuploaderWeitereZutaten.active = false
                }
            }
        }

        Loader {
            id: popuploader
            active: false
            focus: true
            onLoaded: item.open()
            sourceComponent: PopupRestextrakt {
                model: listView.currentItem.values
            }
        }
    }
}
