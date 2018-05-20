import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

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
            onTextChanged: listView.model.filterRegExp = new RegExp(text + "(.*)", "i")
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            focus: false
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

            delegate: Item {
                property bool active: Brauhelfer.sud.id === model.ID

                width: parent.width
                height: row.height + divider.height

                Behavior on height {
                    PropertyAnimation {
                        duration: 150
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    anchors.margins: 0
                    onClicked: page.clicked(ID)
                }

                Rectangle {
                    anchors.fill: parent
                    color: Material.background
                }

                Rectangle {
                    id: colorRect
                    anchors.top: parent.top
                    anchors.left: parent.left
                    height: parent.height - 2
                    width: 8
                    color: active ? Material.color(Material.accent, Material.Shade300) : listView.getColor(model)
                }

                ColumnLayout {
                    id: row
                    anchors.top: parent.top
                    anchors.left: colorRect.right
                    anchors.right: expander.left
                    spacing: 0

                    Item {
                        id: itemTitle
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 16
                        implicitHeight: layoutItemTitle.height

                        GridLayout {
                            id: layoutItemTitle
                            columns: 2
                            rows: 2
                            width: parent.width
                            columnSpacing: 0
                            rowSpacing: 8

                            LabelPrim {
                                Layout.columnSpan: 2
                                text: model.Sudname
                                Layout.fillWidth: true
                                color: active ? Material.primary : Material.foreground
                                opacity: active ? 1.00 : 0.87
                                font.bold: active
                                font.pixelSize: 16
                            }

                            LabelSec {
                                Layout.preferredWidth: parent.width * 0.6
                                text: model.BierWurdeGebraut ? qsTr("Gebraut ") + Qt.formatDate(model.Braudatum) : qsTr("Rezept")
                            }

                            LabelSec {
                                Layout.fillWidth: true
                                font.italic: true
                                text: listView.getStatus(model)
                            }
                        }
                    }

                    Item {
                        id: itemDetails
                        visible: false
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 16
                        height: layoutItemDetails.height

                        ColumnLayout {
                            id: layoutItemDetails
                            anchors.left: parent.left
                            anchors.right: parent.right

                            RowLayout {
                                Layout.fillWidth: true

                                Item {
                                    width: 100
                                    height: width

                                    Rectangle
                                    {
                                        anchors.fill: parent
                                        color: Brauhelfer.calc.ebcToColor(model.erg_Farbe)
                                    }

                                    Image {
                                        anchors.fill: parent
                                        source: "qrc:/images/glass.png"
                                    }
                                }

                                GridLayout {
                                    columns: 3
                                    Layout.fillWidth: true
                                    columnSpacing: 8

                                    LabelPrim {
                                        text: qsTr("Menge")
                                    }

                                    LabelNumber {
                                        precision: 1
                                        value: model.BierWurdeGebraut ? model.erg_AbgefuellteBiermenge : model.Menge
                                    }

                                    LabelPrim {
                                        text: qsTr("Liter")
                                    }

                                    LabelPrim {
                                        text: qsTr("Stammwürze")
                                    }

                                    LabelPlato {
                                        value: model.BierWurdeGebraut ? model.SWIst : model.SW
                                    }


                                    LabelPrim {
                                        text: qsTr("°P")
                                    }

                                    LabelPrim {
                                        text: qsTr("Alkohol")
                                    }

                                    LabelNumber {
                                        precision: 1
                                        value: model.BierWurdeGebraut ? model.erg_Alkohol : 0.0
                                    }

                                    LabelPrim {
                                        text: qsTr("%")
                                    }

                                    LabelPrim {
                                        text: qsTr("Bittere")
                                    }

                                    LabelNumber {
                                        precision: 0
                                        value: model.IBU
                                    }

                                    LabelPrim {
                                        text: qsTr("IBU")
                                    }

                                    LabelPrim {
                                        text: qsTr("Farbe")
                                    }

                                    LabelNumber {
                                        precision: 0
                                        value: model.erg_Farbe
                                    }


                                    LabelPrim {
                                        text: qsTr("EBC")
                                    }

                                    LabelPrim {
                                        text: qsTr("CO2")
                                    }

                                    LabelNumber {
                                        precision: 1
                                        value: model.BierWurdeGebraut ? model.CO2Ist : model.CO2
                                    }

                                    LabelPrim {
                                        text: qsTr("g/Liter")
                                    }
                                }
                            }

                            HorizontalDivider { }

                            GridLayout {
                                columns: 2
                                Layout.fillWidth: true
                                columnSpacing: 8
                                LabelPrim {
                                    text: qsTr("Erstellt")
                                }
                                LabelDate {
                                    date: model.Erstellt
                                }
                                LabelPrim {
                                    text: qsTr("Zuletzt gespeichert")
                                }
                                LabelDate {
                                    date: model.Gespeichert
                                }
                                LabelPrim {
                                    visible: model.BierWurdeGebraut
                                    text: qsTr("Braudatum")
                                }
                                LabelDate {
                                    visible: model.BierWurdeGebraut
                                    date: model.Braudatum
                                }
                                LabelPrim {
                                    visible: model.BierWurdeAbgefuellt
                                    text: qsTr("Abfülldatum")
                                }
                                LabelDate {
                                    visible: model.BierWurdeAbgefuellt
                                    date: model.Abfuelldatum
                                }
                            }
                        }
                    }
                }

                Item {
                    id: expander
                    width: 60
                    height: parent.height
                    anchors.top: parent.top
                    anchors.right: parent.right

                    Image {
                        opacity: 0.54
                        anchors.top: parent.top
                        anchors.topMargin: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: itemDetails.visible ? "qrc:/images/ic_expand_less.png" : "qrc:/images/ic_expand_more.png"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: itemDetails.visible = !itemDetails.visible
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: mouseArea.pressed ? Material.listHighlightColor : "transparent"
                }

                HorizontalDivider {
                    id: divider
                    anchors.top: row.bottom
                }
            }

            function getStatus(model)
            {
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
