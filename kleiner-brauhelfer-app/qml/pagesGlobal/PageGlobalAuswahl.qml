import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0
import SortFilterProxyModelSud 1.0

PageBase {

    signal clicked(int id)

    id: page
    title: qsTr("Sudauswahl")
    icon: "ic_list.png"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TextField {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            placeholderText: qsTr("Suche")
            inputMethodHints: Qt.ImhNoPredictiveText
            onTextChanged: listView.model.filterRegExp = new RegExp(text + "(.*)", "i")
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.DragAndOvershootBounds
            model: SortFilterProxyModelSud {
                sourceModel: Brauhelfer.modelSudAuswahl
                filterKeyColumn: sourceModel.fieldIndex("Sudname")
                filterValue: app.settings.brewsFilter
                filterMerkliste: app.settings.brewsMerklisteFilter
            }

            ScrollIndicator.vertical: ScrollIndicator {}

            property bool canRefresh: false
            onMovementStarted: {
                forceActiveFocus()
                canRefresh = atYBeginning
            }
            onContentYChanged: {
                if (canRefresh) {
                    if (contentY < -0.2 * height) {
                        canRefresh = false
                        app.connect()
                    }
                    if (contentY  > 0) {
                        canRefresh = false
                    }
                }
            }

            delegate: ItemDelegate {
                property bool showdetails: false
                property bool selected: Brauhelfer.sud.id === model.ID

                width: parent.width
                height: row.height + divider.height
                clip: true
                onClicked: page.clicked(ID)

                Behavior on height {
                    PropertyAnimation {
                        duration: 150
                    }
                }

                Rectangle {
                    function getColor(model)
                    {
                        if (model.MerklistenID === 1)
                            return "#7AA3E9"
                        else if (model.BierWurdeVerbraucht)
                            return "#C8C8C8"
                        else if (model.BierWurdeAbgefuellt)
                            return "#C1E1B2"
                        else if (model.BierWurdeGebraut)
                            return "#E1D8B8"
                        else
                            return "#888888"
                    }
                    id: colorRect
                    anchors.top: parent.top
                    anchors.left: parent.left
                    height: row.height - 2
                    width: 8
                    color: selected ? Material.color(Material.accent, Material.Shade300) : getColor(model)
                }

                ColumnLayout {
                    id: row
                    anchors.top: parent.top
                    anchors.left: colorRect.right
                    anchors.right: expander.left
                    spacing: 0

                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 8
                        text: model.Sudname
                        color: selected ? Material.primary : Material.foreground
                        opacity: selected ? 1.00 : 0.87
                        font.bold: selected
                        font.pixelSize: 16
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 8
                        LabelSec {
                            Layout.fillWidth: true
                            text: model.BierWurdeGebraut ? qsTr("Gebraut ") + Qt.formatDate(model.Braudatum) : qsTr("Rezept")
                        }
                        LabelSec {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            font.italic: true
                            text: {
                                if (!model.BierWurdeGebraut)
                                    return qsTr("nicht gebraut")
                                if (model.BierWurdeVerbraucht)
                                    return qsTr("verbraucht")
                                if (!model.BierWurdeAbgefuellt)
                                    return qsTr("nicht abgefüllt")
                                var tage = model.ReifezeitDelta
                                if (tage > 0)
                                    return qsTr("reif in") + " " + tage + " " + qsTr("Tage")
                                else
                                    return qsTr("reif seit") + " " + (-tage) + " " + qsTr("Tage")
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 8
                        visible: showdetails

                        Item {
                            width: 100
                            height: width
                            Image {
                                anchors.fill: parent
                                source: "qrc:/images/glass_fill.png"
                                ColorOverlay {
                                    anchors.fill: parent
                                    source: parent
                                    color: Brauhelfer.calc.ebcToColor(model.erg_Farbe)
                                }
                            }
                            Image {
                                anchors.fill: parent
                                source: "qrc:/images/glass.png"
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            columnSpacing: 8

                            LabelPrim {
                                text: qsTr("Menge")
                            }
                            LabelNumber {
                                precision: 1
                                value: model.BierWurdeGebraut ? model.erg_AbgefuellteBiermenge : model.Menge
                            }
                            LabelUnit {
                                text: qsTr("Liter")
                            }

                            LabelPrim {
                                text: qsTr("Stammwürze")
                            }
                            LabelPlato {
                                value: model.BierWurdeGebraut ? model.SWIst : model.SW
                            }
                            LabelUnit {
                                text: qsTr("°P")
                            }

                            LabelPrim {
                                text: qsTr("Alkohol")
                            }
                            LabelNumber {
                                precision: 1
                                value: model.BierWurdeGebraut ? model.erg_Alkohol : 0.0
                            }
                            LabelUnit {
                                text: qsTr("%")
                            }

                            LabelPrim {
                                text: qsTr("Bittere")
                            }
                            LabelNumber {
                                precision: 0
                                value: model.IBU
                            }
                            LabelUnit {
                                text: qsTr("IBU")
                            }

                            LabelPrim {
                                text: qsTr("Farbe")
                            }
                            LabelNumber {
                                precision: 0
                                value: model.erg_Farbe
                            }
                            LabelUnit {
                                text: qsTr("EBC")
                            }

                            LabelPrim {
                                text: qsTr("CO2")
                            }
                            LabelNumber {
                                precision: 1
                                value: model.BierWurdeGebraut ? model.CO2Ist : model.CO2
                            }
                            LabelUnit {
                                text: qsTr("g/Liter")
                            }
                        }
                    }
                }

                Item {
                    id: expander
                    width: 60
                    height: row.height
                    anchors.top: parent.top
                    anchors.right: parent.right

                    Image {
                        opacity: 0.54
                        anchors.top: parent.top
                        anchors.topMargin: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: showdetails ? "qrc:/images/ic_expand_less.png" : "qrc:/images/ic_expand_more.png"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: showdetails = !showdetails
                    }
                }

                HorizontalDivider {
                    id: divider
                    anchors.top: row.bottom
                }
            } 
        }

        Flow {
            Layout.fillWidth: true
            Layout.margins: 8
            spacing: 8
            Repeater {
                model: ListModel {
                    ListElement {
                        text: qsTr("alle")
                        filter: SortFilterProxyModelSud.Alle
                    }
                    ListElement {
                        text: qsTr("nicht gebraut")
                        filter: SortFilterProxyModelSud.NichtGebraut
                    }
                    ListElement {
                        text: qsTr("nicht abgefüllt")
                        filter: SortFilterProxyModelSud.NichtAbgefuellt
                    }
                    ListElement {
                        text: qsTr("nicht verbraucht")
                        filter: SortFilterProxyModelSud.NichtVerbraucht
                    }
                    ListElement {
                        text: qsTr("verbraucht")
                        filter: SortFilterProxyModelSud.Verbraucht
                    }
                }
                RadioButton {
                    padding: 0
                    checked: app.settings.brewsFilter === model.filter
                    text: model.text
                    onClicked: app.settings.brewsFilter = model.filter
                }
            }
            CheckBox {
                padding: 0
                checked: app.settings.brewsMerklisteFilter
                text: qsTr("Merkliste")
                onClicked: app.settings.brewsMerklisteFilter = checked
            }
        }
    }
}
