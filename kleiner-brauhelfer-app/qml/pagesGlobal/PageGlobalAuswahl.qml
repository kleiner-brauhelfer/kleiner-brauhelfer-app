import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import "../common"
import qmlutils
import brauhelfer
import ProxyModelSud

PageBase {

    signal clicked(int id)

    id: page
    title: qsTr("Sudauswahl")
    icon: "ic_list.png"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ProxyModelSud {
            id: proxy
            sourceModel: Brauhelfer.modelSud
            filterStatus: app.settings.brewsFilter
            filterMerkliste: app.settings.brewsMerklisteFilter
            sortOrder: sortComboBox.sortOrder
            sortColumn: sortComboBox.sortColumn
            Component.onCompleted: sortComboBox.update()
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 8
            spacing: 8
            TextFieldBase {
                Layout.fillWidth: true
                placeholderText: qsTr("Suche")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhLowercaseOnly
                onTextChanged: listView.model.filterText = text
            }
            ComboBoxBase {
                property int sortColumn: -1
                property int sortOrder: Qt.DescendingOrder
                id: sortComboBox
                implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
                model: [
                    qsTr("Sudname") + "  \u2191 ",
                    qsTr("Sudname") + "  \u2193 ",
                    qsTr("Sudnummer") + "  \u2191 ",
                    qsTr("Sudnummer") + "  \u2193 ",
                    qsTr("Kategorie") + "  \u2191 ",
                    qsTr("Kategorie") + "  \u2193 ",
                    qsTr("Braudatum") + "  \u2191 ",
                    qsTr("Braudatum") + "  \u2193 ",
                    qsTr("Gespeichert") + "  \u2191 ",
                    qsTr("Gespeichert") + "  \u2193 ",
                    qsTr("Erstellt") + "  \u2191 ",
                    qsTr("Erstellt") + "  \u2193 "
                ]
                function update() {
                    switch (currentIndex) {
                        case 0: sortColumn = proxy.fieldIndex("Sudname"); sortOrder = Qt.AscendingOrder; break;
                        case 1: sortColumn = proxy.fieldIndex("Sudname"); sortOrder = Qt.DescendingOrder; break;
                        case 2: sortColumn = proxy.fieldIndex("Sudnummer"); sortOrder = Qt.AscendingOrder; break;
                        case 3: sortColumn = proxy.fieldIndex("Sudnummer"); sortOrder = Qt.DescendingOrder; break;
                        case 4: sortColumn = proxy.fieldIndex("Kategorie"); sortOrder = Qt.AscendingOrder; break;
                        case 5: sortColumn = proxy.fieldIndex("Kategorie"); sortOrder = Qt.DescendingOrder; break;
                        case 6: sortColumn = proxy.fieldIndex("Braudatum"); sortOrder = Qt.AscendingOrder; break;
                        case 7: sortColumn = proxy.fieldIndex("Braudatum"); sortOrder = Qt.DescendingOrder; break;
                        case 8: sortColumn = proxy.fieldIndex("Gespeichert"); sortOrder = Qt.AscendingOrder; break;
                        case 9: sortColumn = proxy.fieldIndex("Gespeichert"); sortOrder = Qt.DescendingOrder; break;
                        case 10: sortColumn = proxy.fieldIndex("Erstellt"); sortOrder = Qt.AscendingOrder; break;
                        case 11: sortColumn = proxy.fieldIndex("Erstellt"); sortOrder = Qt.DescendingOrder; break;
                        default: sortColumn = -1; sortOrder = Qt.DescendingOrder; break;
                    }
                    proxy.invalidate()
                }
                currentIndex: app.settings.brewsSortColumn
                onCurrentIndexChanged: {
                    app.settings.brewsSortColumn = currentIndex
                    update()
                }
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.DragAndOvershootBounds
            model: proxy

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

                width: listView.width
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
                        else if (model.Status === Brauhelfer.Verbraucht)
                            return "#C8C8C8"
                        else if (model.Status === Brauhelfer.Abgefuellt)
                            return "#C1E1B2"
                        else if (model.Status === Brauhelfer.Gebraut)
                            return "#E1D8B8"
                        else
                            return "#888888"
                    }
                    id: colorRect
                    anchors.top: parent.top
                    anchors.left: parent.left
                    height: row.height - 2
                    width: 8
                    color: selected ? Material.color(Material.accent, Material.Shade400) : getColor(model)
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
                        Layout.leftMargin: 8
                        text: model.Sudname + (model.Sudnummer > 0 ? " (#" + model.Sudnummer +  ")" : "")
                        color: selected ? Material.primary : Material.foreground
                        opacity: selected ? 1.00 : 0.87
                        font.bold: selected
                        font.pointSize: 16 * app.settings.scalingfactor
                    }

                    LabelSec {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        visible: model.Kategorie !== ""
                        text: model.Kategorie
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 8
                        LabelSec {
                            Layout.fillWidth: true
                            text: model.Status === Brauhelfer.Rezept ? qsTr("Rezept") : qsTr("Gebraut") + " " + Qt.formatDate(model.Braudatum)
                        }
                        LabelSec {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            font.italic: true
                            text: {
                                switch (model.Status) {
                                case Brauhelfer.Rezept:
                                    return qsTr("nicht gebraut")
                                case Brauhelfer.Gebraut:
                                    return qsTr("nicht abgefüllt")
                                case Brauhelfer.Abgefuellt:
                                    var tage = model.ReifezeitDelta
                                    if (tage > 0)
                                        return qsTr("reif in") + " " + tage + " " + qsTr("Tage")
                                    else
                                        return model.Woche + ". " + qsTr("Woche")
                                case Brauhelfer.Verbraucht:
                                    return qsTr("verbraucht")
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 8
                        visible: showdetails

                        ColumnLayout {
                            Item {
                                width: 100
                                height: width
                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/images/glass_fill.png"
                                    layer.enabled: true
                                    layer.effect: ColorOverlay {
                                        cached: true
                                        color: Utils.toColor(BierCalc.ebcToColor(model.FarbeIst))
                                    }
                                }
                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/images/glass.png"
                                }
                            }
                            Flow {
                                Layout.columnSpan: model.Status === Brauhelfer.Rezept ? 3 : 4
                                Layout.alignment: Qt.AlignHCenter
                                visible: model.BewertungMittel > 0
                                Image {
                                    width: 16
                                    height: 16
                                    source: model.BewertungMittel > 0 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                }
                                Image {
                                    width: 16
                                    height: 16
                                    source: model.BewertungMittel > 1 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                }
                                Image {
                                    width: 16
                                    height: 16
                                    source: model.BewertungMittel > 2 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                }
                                Image {
                                    width: 16
                                    height: 16
                                    source: model.BewertungMittel > 3 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                }
                                Image {
                                    width: 16
                                    height: 16
                                    source: model.BewertungMittel > 4 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                }
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: model.Status === Brauhelfer.Rezept ? 3 : 4
                            columnSpacing: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: model.Status !== Brauhelfer.Rezept
                                text: ""
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: model.Status !== Brauhelfer.Rezept
                                text: qsTr("Sud")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: model.Status !== Brauhelfer.Rezept
                                text: qsTr("Rezept")
                            }
                            LabelUnit {
                                visible: model.Status !== Brauhelfer.Rezept
                                text: ""
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Menge")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.Status !== Brauhelfer.Rezept
                                precision: 1
                                value: model.MengeIst
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                opacity: model.Status === Brauhelfer.Rezept ? app.config.textOpacityFull : app.config.textOpacityHalf
                                precision: 1
                                value: model.Menge
                            }
                            LabelUnit {
                                text: qsTr("l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("SW")
                            }
                            LabelPlato {
                                Layout.fillWidth: true
                                visible: model.Status !== Brauhelfer.Rezept
                                value: model.SWIst
                            }
                            LabelPlato {
                                Layout.fillWidth: true
                                opacity: model.Status === Brauhelfer.Rezept ? app.config.textOpacityFull : app.config.textOpacityHalf
                                value: model.SW
                            }
                            LabelUnit {
                                text: qsTr("°P")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Alkohol")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.Status !== Brauhelfer.Rezept
                                precision: 1
                                value: model.Status === Brauhelfer.Rezept ? 0.0 : model.erg_Alkohol
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                opacity: model.Status === Brauhelfer.Rezept ? app.config.textOpacityFull : app.config.textOpacityHalf
                                precision: 1
                                value: model.AlkoholSoll
                            }
                            LabelUnit {
                                text: qsTr("%vol")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Bittere")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.Status !== Brauhelfer.Rezept
                                precision: 0
                                value: model.IbuIst
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                opacity: model.Status === Brauhelfer.Rezept ? app.config.textOpacityFull : app.config.textOpacityHalf
                                precision: 0
                                value: model.IBU
                            }
                            LabelUnit {
                                text: qsTr("IBU")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Farbe")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.Status !== Brauhelfer.Rezept
                                precision: 0
                                value: model.FarbeIst
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                opacity: model.Status === Brauhelfer.Rezept ? app.config.textOpacityFull : app.config.textOpacityHalf
                                precision: 0
                                value: model.erg_Farbe
                            }
                            LabelUnit {
                                text: qsTr("EBC")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("CO2")
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                visible: model.Status !== Brauhelfer.Rezept
                                precision: 1
                                value: model.CO2Ist
                            }
                            LabelNumber {
                                Layout.fillWidth: true
                                opacity: model.Status === Brauhelfer.Rezept ? app.config.textOpacityFull : app.config.textOpacityHalf
                                precision: 1
                                value: model.CO2
                            }
                            LabelUnit {
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
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            spacing: 8
            Repeater {
                model: ListModel {
                    ListElement {
                        text: qsTr("Rezept")
                        filter: ProxyModelSud.Rezept
                    }
                    ListElement {
                        text: qsTr("gebraut")
                        filter: ProxyModelSud.Gebraut
                    }
                    ListElement {
                        text: qsTr("abgefüllt")
                        filter: ProxyModelSud.Abgefuellt
                    }
                    ListElement {
                        text: qsTr("verbraucht")
                        filter: ProxyModelSud.Verbraucht
                    }
                }
                CheckBoxBase {
                    text: model.text
                    checked: app.settings.brewsFilter & model.filter
                    onClicked: {
                        if (checked)
                            app.settings.brewsFilter |= model.filter
                        else
                            app.settings.brewsFilter &= ~model.filter
                    }
                }
            }
            CheckBoxBase {
                id: cbAlle
                text: qsTr("alle")
                tristate: true
                checkState: app.settings.brewsFilter === ProxyModelSud.Alle ? Qt.Checked :
                                     app.settings.brewsFilter === ProxyModelSud.Keine ? Qt.Unchecked : Qt.PartiallyChecked
                onClicked: {
                    if (checkState === Qt.Unchecked)
                        app.settings.brewsFilter = ProxyModelSud.Keine
                    else
                        app.settings.brewsFilter = ProxyModelSud.Alle
                }
            }
            VerticalDivider {
                width: 2
                height: cbAlle.height
            }
            CheckBoxBase {
                text: qsTr("Merkliste")
                checked: app.settings.brewsMerklisteFilter
                onClicked: app.settings.brewsMerklisteFilter = checked
            }
        }
    }
}
