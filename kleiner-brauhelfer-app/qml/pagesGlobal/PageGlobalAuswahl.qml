import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../common"
import qmlutils 1.0
import brauhelfer 1.0
import ProxyModelSud 1.0

PageBase {

    signal clicked(int id)

    function getModel() {
        return loaderItem.modelAuswahl
    }

    id: page
    title: qsTr("Sudauswahl")
    icon: "ic_list.png"

    ColumnLayout {
        property alias modelAuswahl: listView.model
        anchors.fill: parent
        spacing: 0

        RowLayout {
            TextFieldBase {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                placeholderText: qsTr("Suche")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhLowercaseOnly
                onTextChanged: listView.model.filterText = text
            }
            ComboBox {
                property string sortFieldName: ""
                property int sortOrder: Qt.DescendingOrder
                id: sortComboBox
                Layout.preferredWidth: 150
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                flat: true
                model: [
                    qsTr("Sudname") + "  \u2193",
                    qsTr("Sudname") + "  \u2191",
                    qsTr("Sudnummer") + "  \u2193",
                    qsTr("Sudnummer") + "  \u2191",
                    qsTr("Braudatum") + "  \u2193",
                    qsTr("Braudatum") + "  \u2191",
                    qsTr("Gespeichert") + "  \u2193",
                    qsTr("Gespeichert") + "  \u2191",
                    qsTr("Erstellt") + "  \u2193",
                    qsTr("Erstellt") + "  \u2191"
                ]
                currentIndex: app.settings.brewsSortColumn
                onCurrentIndexChanged: {
                    app.settings.brewsSortColumn = currentIndex
                    switch (currentIndex) {
                        case 0: sortFieldName = "Sudname"; sortOrder = Qt.AscendingOrder; break;
                        case 1: sortFieldName = "Sudname"; sortOrder = Qt.DescendingOrder; break;
                        case 2: sortFieldName = "Sudnummer"; sortOrder = Qt.AscendingOrder; break;
                        case 3: sortFieldName = "Sudnummer"; sortOrder = Qt.DescendingOrder; break;
                        case 4: sortFieldName = "Braudatum"; sortOrder = Qt.AscendingOrder; break;
                        case 5: sortFieldName = "Braudatum"; sortOrder = Qt.DescendingOrder; break;
                        case 6: sortFieldName = "Gespeichert"; sortOrder = Qt.AscendingOrder; break;
                        case 7: sortFieldName = "Gespeichert"; sortOrder = Qt.DescendingOrder; break;
                        case 8: sortFieldName = "Erstellt"; sortOrder = Qt.AscendingOrder; break;
                        case 9: sortFieldName = "Erstellt"; sortOrder = Qt.DescendingOrder; break;
                        default: sortFieldName = ""; sortOrder = Qt.DescendingOrder; break;
                    }
                    navPane.setFocus()
                }
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.DragAndOvershootBounds
            model: ProxyModelSud {
                sourceModel: Brauhelfer.modelSud
                filterStatus: app.settings.brewsFilter
                filterMerkliste: app.settings.brewsMerklisteFilter
                sortOrder: sortComboBox.sortOrder
                sortColumn: fieldIndex(sortComboBox.sortFieldName)
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
                        text: model.Sudname + (model.Sudnummer > 0 ? " (#" + model.Sudnummer +  ")" : "")
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
                            text: model.BierWurdeGebraut ? qsTr("Gebraut") + " " + Qt.formatDate(model.Braudatum) : qsTr("Rezept")
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
                                    return qsTr("reif seit") + " " + Math.floor(-tage/7) + " " + qsTr("Wochen")
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
                                    cached: true
                                    color: Utils.toColor(Brauhelfer.calc.ebcToColor(model.FarbeIst))
                                }
                            }
                            Image {
                                anchors.fill: parent
                                source: "qrc:/images/glass.png"
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: model.BierWurdeGebraut ? 4 : 3
                            columnSpacing: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Menge")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.BierWurdeGebraut
                                precision: 1
                                value: model.MengeIst
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                opacity: model.BierWurdeGebraut ?  app.config.textOpacityHalf : app.config.textOpacityFull
                                precision: 1
                                value: model.Menge
                            }
                            LabelUnit {
                                Layout.fillWidth: true
                                text: qsTr("l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("SW")
                            }
                            LabelPlato {
                                Layout.fillWidth: true
                                visible: model.BierWurdeGebraut
                                value: model.SWIst
                            }
                            LabelPlato {
                                Layout.fillWidth: true
                                opacity: model.BierWurdeGebraut ?  app.config.textOpacityHalf : app.config.textOpacityFull
                                value: model.SW
                            }
                            LabelUnit {
                                Layout.fillWidth: true
                                text: qsTr("°P")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: model.BierWurdeGebraut
                                text: qsTr("Alkohol")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.BierWurdeGebraut
                                precision: 1
                                value: model.BierWurdeGebraut ? model.erg_Alkohol : 0.0
                            }
                            Label {
                                Layout.fillWidth: true
                                visible: model.BierWurdeGebraut
                                text: ""
                            }
                            LabelUnit {
                                Layout.fillWidth: true
                                visible: model.BierWurdeGebraut
                                text: qsTr("%")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Bittere")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.BierWurdeGebraut
                                precision: 0
                                value: model.IbuIst
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                opacity: model.BierWurdeGebraut ?  app.config.textOpacityHalf : app.config.textOpacityFull
                                precision: 0
                                value: model.IBU
                            }
                            LabelUnit {
                                Layout.fillWidth: true
                                text: qsTr("IBU")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Farbe")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.BierWurdeGebraut
                                precision: 0
                                value: model.FarbeIst
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                opacity: model.BierWurdeGebraut ?  app.config.textOpacityHalf : app.config.textOpacityFull
                                precision: 0
                                value: model.erg_Farbe
                            }
                            LabelUnit {
                                Layout.fillWidth: true
                                text: qsTr("EBC")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("CO2")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.BierWurdeGebraut
                                precision: 1
                                value: model.CO2Ist
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                opacity: model.BierWurdeGebraut ?  app.config.textOpacityHalf : app.config.textOpacityFull
                                precision: 1
                                value: model.CO2
                            }
                            LabelUnit {
                                Layout.fillWidth: true
                                text: qsTr("g/l")
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
                        filter: ProxyModelSud.Alle
                    }
                    ListElement {
                        text: qsTr("nicht gebraut")
                        filter: ProxyModelSud.NichtGebraut
                    }
                    ListElement {
                        text: qsTr("nicht abgefüllt")
                        filter: ProxyModelSud.GebrautNichtAbgefuellt
                    }
                    ListElement {
                        text: qsTr("nicht verbraucht")
                        filter: ProxyModelSud.NichtVerbraucht
                    }
                    ListElement {
                        text: qsTr("verbraucht")
                        filter: ProxyModelSud.Verbraucht
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
