import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
import QtQuick.Dialogs

import "../common"
import brauhelfer 1.0
import ProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Brauen")
    icon: "brauen.png"
    readOnly: Brauhelfer.readonly || app.settings.readonly || (Brauhelfer.sud.Status > Brauhelfer.Rezept && !app.brewForceEditable)

    Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentHeight: layout.height
        boundsBehavior: Flickable.OvershootBounds
        onMovementStarted: forceActiveFocus()
        ScrollIndicator.vertical: ScrollIndicator {}

        function gebraut() {
            messageDialog.open()
            Brauhelfer.sud.Braudatum = tfBraudatum.date
            Brauhelfer.sud.Status = Brauhelfer.Gebraut
            var values = {"SudID": Brauhelfer.sud.id,
                          "Zeitstempel": Brauhelfer.sud.Braudatum,
                          "SW": Brauhelfer.sud.SWAnstellen,
                          "Temp": tfTemperature.value }
            if (Brauhelfer.sud.modelSchnellgaerverlauf.rowCount() === 0)
                Brauhelfer.sud.modelSchnellgaerverlauf.append(values)
            if (Brauhelfer.sud.modelHauptgaerverlauf.rowCount() === 0)
                Brauhelfer.sud.modelHauptgaerverlauf.append(values)
        }

        // message dialog
        MessageDialog {
            id: messageDialog
            text: qsTr("Verwendete Rohstoffe vom Bestand abziehen?")
            buttons: MessageDialog.Yes | MessageDialog.No
            onAccepted: Brauhelfer.sud.brauzutatenAbziehen()
        }

        ColumnLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Maischen")
                }
                ColumnLayout {
                    anchors.fill: parent
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Malz")
                    }
                    Repeater {
                        model: Brauhelfer.sud.modelMalzschuettung
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            spacing: 16
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            LabelNumber {
                                precision: 1
                                value: model.Prozent
                            }
                            LabelUnit {
                                text: qsTr("%")
                            }
                            LabelNumber {
                                precision: 2
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                text: qsTr("kg")
                            }
                        }
                    }
                    RowLayout {
                        Layout.leftMargin: 8
                        spacing: 16
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Gesamtschüttung")
                        }
                        LabelPrim {
                            text: ""
                        }
                        LabelPrim {
                            text: ""
                        }
                        LabelNumber {
                            font.bold: true
                            precision: 2
                            value: Brauhelfer.sud.erg_S_Gesamt
                        }
                        LabelUnit {
                            text: qsTr("kg")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                        visible: repeaterModelWeitereZutatenGabenMaischen.count > 0
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: repeaterModelWeitereZutatenGabenMaischen.count > 0
                        font.bold: true
                        text: qsTr("Weitere Zutaten")
                    }
                    Repeater {
                        id: repeaterModelWeitereZutatenGabenMaischen
                        model: ProxyModel {
                            sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                            filterKeyColumn: fieldIndex("Zeitpunkt")
                            filterRegularExpression: /2/
                        }
                        delegate: ColumnLayout {
                            Layout.leftMargin: 8
                            RowLayout {
                                spacing: 16
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    precision: 2
                                    value: model.erg_Menge * app.defs.einheitenDivider[model.Einheit]
                                }
                                LabelUnit {
                                    text: app.defs.einheiten[model.Einheit]
                                }
                            }
                            LabelPrim {
                                Layout.leftMargin: 8
                                visible: model.Bemerkung !== ""
                                text: model.Bemerkung
                            }
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Hauptguss")
                    }
                    ColumnLayout {
                        Layout.leftMargin: 8
                        RowLayout {
                            spacing: 16
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Wassermenge")
                            }
                            LabelNumber {
                                value: Brauhelfer.sud.erg_WHauptguss
                            }
                            LabelUnit {
                                text: qsTr("l")
                            }
                        }
                        Repeater {
                            model: Brauhelfer.sud.modelWasseraufbereitung
                            delegate: RowLayout {
                                spacing: 16
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    precision: 2
                                    value: model.Menge * Brauhelfer.sud.erg_WHauptguss
                                }
                                LabelUnit {
                                    text: app.defs.einheiten[model.Einheit]
                                }
                            }
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Maischplan")
                    }
                    Repeater {
                        model: Brauhelfer.sud.modelRasten
                        delegate: ColumnLayout {
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            GridLayout {
                                columns: 3
                                Layout.leftMargin: 8
                                columnSpacing: 16
                                visible: model.Typ === Brauhelfer.RastTyp.Einmaischen
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: qsTr("Wassermenge")
                                }
                                LabelNumber {
                                    precision: 1
                                    value: model.Menge
                                }
                                LabelUnit {
                                    text: qsTr("l")
                                }
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: qsTr("Wassertemperatur")
                                }
                                LabelNumber {
                                    precision: 0
                                    value: model.Param1
                                }
                                LabelUnit {
                                    text: qsTr("°C")
                                }
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: qsTr("Maischetemperatur")
                                }
                                LabelNumber {
                                    precision: 0
                                    value: model.Temp
                                }
                                LabelUnit {
                                    text: qsTr("°C")
                                }
                                LabelPrim {
                                    visible: model.Dauer > 0
                                    Layout.fillWidth: true
                                    text: qsTr("Rastdauer")
                                }
                                LabelNumber {
                                    visible: model.Dauer > 0
                                    precision: 0
                                    value: model.Dauer
                                }
                                LabelUnit {
                                    visible: model.Dauer > 0
                                    text: qsTr("min")
                                }
                            }
                            GridLayout {
                                Layout.leftMargin: 8
                                columnSpacing: 16
                                columns: 3
                                visible: model.Typ === Brauhelfer.RastTyp.Temperatur
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: qsTr("Temperatur")
                                }
                                LabelNumber {
                                    precision: 0
                                    value: model.Temp
                                }
                                LabelUnit {
                                    text: qsTr("°C")
                                }
                                LabelPrim {
                                    visible: model.Dauer > 0
                                    Layout.fillWidth: true
                                    text: qsTr("Rastdauer")
                                }
                                LabelNumber {
                                    visible: model.Dauer > 0
                                    precision: 0
                                    value: model.Dauer
                                }
                                LabelUnit {
                                    visible: model.Dauer > 0
                                    text: qsTr("min")
                                }
                            }
                            GridLayout {
                                Layout.leftMargin: 8
                                columnSpacing: 16
                                columns: 3
                                visible: model.Typ === Brauhelfer.RastTyp.Infusion
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: qsTr("Wassermenge")
                                }
                                LabelNumber {
                                    precision: 1
                                    value: model.Menge
                                }
                                LabelUnit {
                                    text: qsTr("l")
                                }
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: qsTr("Wassertemperatur")
                                }
                                LabelNumber {
                                    precision: 0
                                    value: model.Param1
                                }
                                LabelUnit {
                                    text: qsTr("°C")
                                }
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: qsTr("Maischetemperatur")
                                }
                                LabelNumber {
                                    precision: 0
                                    value: model.Temp
                                }
                                LabelUnit {
                                    text: qsTr("°C")
                                }
                                LabelPrim {
                                    visible: model.Dauer > 0
                                    Layout.fillWidth: true
                                    text: qsTr("Rastdauer")
                                }
                                LabelNumber {
                                    visible: model.Dauer > 0
                                    precision: 0
                                    value: model.Dauer
                                }
                                LabelUnit {
                                    visible: model.Dauer > 0
                                    text: qsTr("min")
                                }
                            }
                            GridLayout {
                                Layout.leftMargin: 8
                                columnSpacing: 16
                                columns: 3
                                visible: model.Typ === Brauhelfer.RastTyp.Dekoktion
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: qsTr("Maischemenge")
                                }
                                LabelNumber {
                                    precision: 1
                                    value: model.Menge
                                }
                                LabelUnit {
                                    text: qsTr("l")
                                }
                                LabelPrim {
                                    visible: model.Param3 > 0
                                    Layout.fillWidth: true
                                    text: qsTr("Teilmaischezusatzrast")
                                }
                                LabelNumber {
                                    visible: model.Param3 > 0
                                    precision: 0
                                    value: model.Param3
                                }
                                LabelUnit {
                                    visible: model.Param3 > 0
                                    text: qsTr("°C")
                                }
                                LabelPrim {
                                    visible: model.Param3 > 0 && model.Param4 > 0
                                    Layout.fillWidth: true
                                    text: qsTr("Teilmaischezusatzrastdauer")
                                }
                                LabelNumber {
                                    visible: model.Param3 > 0 && model.Param4 > 0
                                    precision: 0
                                    value: model.Param4
                                }
                                LabelUnit {
                                    visible: model.Param3 > 0 && model.Param4 > 0
                                    text: qsTr("min")
                                }
                                LabelPrim {
                                    visible: model.Param1 > 0
                                    Layout.fillWidth: true
                                    text: qsTr("Teilmaischerast")
                                }
                                LabelNumber {
                                    visible: model.Param1 > 0
                                    precision: 0
                                    value: model.Param1
                                }
                                LabelUnit {
                                    visible: model.Param1 > 0
                                    text: qsTr("°C")
                                }
                                LabelPrim {
                                    visible: model.Param1 > 0 && model.Param2 > 0
                                    Layout.fillWidth: true
                                    text: qsTr("Teilmaischerastdauer")
                                }
                                LabelNumber {
                                    visible: model.Param1 > 0 && model.Param2 > 0
                                    precision: 0
                                    value: model.Param2
                                }
                                LabelUnit {
                                    visible: model.Param1 > 0 && model.Param2 > 0
                                    text: qsTr("min")
                                }
                                LabelPrim {
                                    visible: model.Temp > 0
                                    Layout.fillWidth: true
                                    text: qsTr("Maischetemperatur")
                                }
                                LabelNumber {
                                    visible: model.Temp > 0
                                    precision: 0
                                    value: model.Temp
                                }
                                LabelUnit {
                                    visible: model.Temp > 0
                                    text: qsTr("°C")
                                }
                                LabelPrim {
                                    visible: model.Temp > 0 && model.Dauer > 0
                                    Layout.fillWidth: true
                                    text: qsTr("Absetzdauer")
                                }
                                LabelNumber {
                                    visible: model.Temp > 0 && model.Dauer > 0
                                    precision: 0
                                    value: model.Dauer
                                }
                                LabelUnit {
                                    visible: model.Temp > 0 && model.Dauer > 0
                                    text: qsTr("min")
                                }
                            }
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Jodprobe")
                    }
                    GridLayout {
                        Layout.leftMargin: 8
                        columnSpacing: 16
                        columns: 2
                        LabelPrim {
                            text: qsTr("lila bis schwarz")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("reichlich unvergärbare Stärke")
                        }
                        LabelPrim {
                            text: qsTr("rot bis braun")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("kaum noch unvergärbare Stärke")
                        }
                        LabelPrim {
                            text: qsTr("gelb bis hellorange")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("fertig (jodnormal)")
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Läutern")
                }
                ColumnLayout {
                    anchors.fill: parent
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Nachguss")
                    }
                    ColumnLayout {
                        Layout.leftMargin: 8
                        RowLayout {
                            spacing: 16
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Wassermenge")
                            }
                            LabelNumber {
                                value: Brauhelfer.sud.erg_WNachguss
                            }
                            LabelUnit {
                                text: qsTr("l")
                            }
                        }
                        Repeater {
                            model: Brauhelfer.sud.modelWasseraufbereitung
                            delegate: RowLayout {
                                spacing: 16
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    precision: 2
                                    value: model.Menge * Brauhelfer.sud.erg_WNachguss
                                }
                                LabelUnit {
                                    text: app.defs.einheiten[model.Einheit]
                                }
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Würzekochen")
                }
                ColumnLayout {
                    anchors.fill: parent
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: repVWH.countVisible > 0
                        font.bold: true
                        text: qsTr("Vorderwürzehopfung")
                    }
                    Repeater {
                        property int countVisible: 0
                        id: repVWH
                        model: Brauhelfer.sud.modelHopfengaben
                        onItemAdded: (index,item) => {if (item.visible) ++countVisible}
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            spacing: 16
                            visible: model.Vorderwuerze === Brauhelfer.HopfenZeitpunkt.Vorderwuerze
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name + " (" + model.Alpha + "%)"
                            }
                            LabelNumber {
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                text: qsTr("g")
                            }
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                        visible: repVWH.countVisible > 0
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Kochbeginn")
                    }
                    GridLayout {
                        Layout.leftMargin: 8
                        columnSpacing: 16
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielstammwürze")
                        }
                        LabelPlato {
                            id: lblSWSollKochbeginn
                            value: Brauhelfer.sud.SWSollKochbeginn
                        }
                        LabelUnit {
                            text: qsTr("°P")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            value: BierCalc.platoToBrix(lblSWSollKochbeginn.value)
                        }
                        LabelUnit {
                            text: qsTr("°Brix")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            precision: 4
                            value: BierCalc.platoToDichte(lblSWSollKochbeginn.value)
                        }
                        LabelUnit {
                            text: qsTr("g/ml")
                        }

                        LabelPrim {
                            Layout.fillWidth: true
                            visible: lblSWSollKochbeginnWz.value !== lblSWSollKochbeginn.value
                            text: qsTr("mit weiteren Zutaten")
                        }
                        LabelPlato {
                            id: lblSWSollKochbeginnWz
                            visible: lblSWSollKochbeginnWz.value !== lblSWSollKochbeginn.value
                            value: Brauhelfer.sud.SWSollKochbeginnMitWz
                        }
                        LabelUnit {
                            visible: lblSWSollKochbeginnWz.value !== lblSWSollKochbeginn.value
                            text: qsTr("°P")
                        }
                        Item {
                            Layout.fillWidth: true
                            visible: lblSWSollKochbeginnWz.value !== lblSWSollKochbeginn.value
                        }
                        LabelPlato {
                            visible: lblSWSollKochbeginnWz.value !== lblSWSollKochbeginn.value
                            value: BierCalc.platoToBrix(lblSWSollKochbeginnWz.value)
                        }
                        LabelUnit {
                            visible: lblSWSollKochbeginnWz.value !== lblSWSollKochbeginn.value
                            text: qsTr("°Brix")
                        }
                        Item {
                            Layout.fillWidth: true
                            visible: lblSWSollKochbeginnWz.value !== lblSWSollKochbeginn.value
                        }
                        LabelPlato {
                            visible: lblSWSollKochbeginnWz.value !== lblSWSollKochbeginn.value
                            precision: 4
                            value: BierCalc.platoToDichte(lblSWSollKochbeginnWz.value)
                        }
                        LabelUnit {
                            visible: lblSWSollKochbeginnWz.value !== lblSWSollKochbeginn.value
                            text: qsTr("g/ml")
                        }

                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Stammwürze")
                        }
                        TextFieldPlato {
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.SWKochbeginn
                            onNewValue: Brauhelfer.sud.SWKochbeginn = value
                        }
                        LabelUnit {
                            text: qsTr("°P")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielmenge bei 100°C")
                        }
                        LabelNumber {
                            value: BierCalc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochbeginn)
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielmenge bei 20°C")
                        }
                        LabelNumber {
                            value: Brauhelfer.sud.MengeSollKochbeginn
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Würzemenge bei 20°C")
                        }
                        TextFieldVolume {
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.WuerzemengeKochbeginn
                            onNewValue: Brauhelfer.sud.WuerzemengeKochbeginn = value
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        spacing: 16
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Kochdauer")
                        }
                        LabelNumber {
                            precision: 0
                            value: Brauhelfer.sud.Kochdauer
                        }
                        LabelUnit {
                            text: qsTr("min")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Hopfen")
                    }
                    Repeater {
                        model: Brauhelfer.sud.modelHopfengaben
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            spacing: 16
                            visible: model.Vorderwuerze !== Brauhelfer.HopfenZeitpunkt.Vorderwuerze && model.Zeit > 0
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name + " (" + model.Alpha + "%)"
                            }
                            LabelNumber {
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                text: qsTr("g")
                            }
                            LabelNumber {
                                precision: 0
                                value: model.Zeit
                            }
                            LabelUnit {
                                text: qsTr("min")
                            }
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                        visible: repeaterModelWeitereZutatenGabenKochen.count > 0
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: repeaterModelWeitereZutatenGabenKochen.count > 0
                        font.bold: true
                        text: qsTr("Weitere Zutaten")
                    }
                    Repeater {
                        id: repeaterModelWeitereZutatenGabenKochen
                        model: ProxyModel {
                            sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                            filterKeyColumn: fieldIndex("Zeitpunkt")
                            filterRegularExpression: /1/
                        }
                        delegate: ColumnLayout {
                            Layout.leftMargin: 8
                            RowLayout {
                                spacing: 16
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    precision: 2
                                    value: model.erg_Menge * app.defs.einheitenDivider[model.Einheit]
                                }
                                LabelUnit {
                                    text: app.defs.einheiten[model.Einheit]
                                }
                                LabelNumber {
                                    precision: 0
                                    value: model.Zugabedauer
                                }
                                LabelUnit {
                                    text: qsTr("min")
                                }
                            }
                            LabelPrim {
                                Layout.leftMargin: 8
                                visible: model.Bemerkung !== ""
                                text: model.Bemerkung
                            }
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Kochende")
                    }
                    GridLayout {
                        Layout.leftMargin: 8
                        columnSpacing: 16
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielstammwürze")
                        }
                        LabelPlato {
                            id: lblSWSollKochende
                            value: Brauhelfer.sud.SWSollKochende
                        }
                        LabelUnit {
                            text: qsTr("°P")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            value: BierCalc.platoToBrix(lblSWSollKochende.value)
                        }
                        LabelUnit {
                            text: qsTr("°Brix")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            precision: 4
                            value: BierCalc.platoToDichte(lblSWSollKochende.value)
                        }
                        LabelUnit {
                            text: qsTr("g/ml")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Stammwürze")
                        }
                        TextFieldPlato {
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.SWKochende
                            onNewValue: Brauhelfer.sud.SWKochende = value
                        }
                        LabelUnit {
                            text: qsTr("°P")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielmenge bei 100°C")
                        }
                        LabelNumber {
                            value: BierCalc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochende)
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielmenge bei 20°C")
                        }
                        LabelNumber {
                            value: Brauhelfer.sud.MengeSollKochende
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Würzemenge vor Hopfenseihen bei 20°C")
                        }
                        TextFieldVolume {
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.WuerzemengeVorHopfenseihen
                            onNewValue: Brauhelfer.sud.WuerzemengeVorHopfenseihen = value
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    GridLayout {
                        columnSpacing: 16
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Verdampfungsrate")
                        }
                        LabelNumber {
                            value: Brauhelfer.sud.VerdampfungsrateIst
                        }
                        LabelUnit {
                            text: qsTr("l/h")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            text: qsTr("Aus Rezept")
                        }
                        LabelNumber {
                            value: Brauhelfer.sud.Verdampfungsrate
                        }
                        LabelUnit {
                            text: qsTr("l/h")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    GridLayout {
                        columnSpacing: 16
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Sudhausausbeute")
                        }
                        LabelNumber {
                            value: Brauhelfer.sud.erg_Sudhausausbeute
                        }
                        LabelUnit {
                            text: qsTr("%")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            text: qsTr("Aus Rezept")
                        }
                        LabelNumber {
                            value: Brauhelfer.sud.Sudhausausbeute
                        }
                        LabelUnit {
                            text: qsTr("%")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        spacing: 16
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: Brauhelfer.sud.Nachisomerisierungszeit > 0.0
                            font.bold: true
                            text: qsTr("Nachisomerisierung")
                        }
                        LabelNumber {
                            visible: Brauhelfer.sud.Nachisomerisierungszeit > 0.0
                            precision: 0
                            value: Brauhelfer.sud.Nachisomerisierungszeit
                        }
                        LabelUnit {
                            visible: Brauhelfer.sud.Nachisomerisierungszeit > 0.0
                            text: qsTr("min")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                        visible: repeaterHopfengabenAusschlagen.count > 0
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: repeaterHopfengabenAusschlagen.count > 0
                        font.bold: true
                        text: qsTr("Hopfen Ausschlagen")
                    }
                    Repeater {
                        id: repeaterHopfengabenAusschlagen
                        model: Brauhelfer.sud.modelHopfengaben
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            spacing: 16
                            visible: model.Vorderwuerze !== Brauhelfer.HopfenZeitpunkt.Vorderwuerze && model.Zeit <= 0
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name + " (" + model.Alpha + "%)"
                            }
                            LabelNumber {
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                text: qsTr("g")
                            }
                            LabelNumber {
                                precision: 0
                                value: -model.Zeit
                            }
                            LabelUnit {
                                text: qsTr("min")
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Anstellen")
                }
                ColumnLayout {
                    anchors.fill: parent

                    LabelPrim {
                        Layout.fillWidth: true
                        visible: Brauhelfer.sud.highGravityFaktor > 0.0
                        font.bold: true
                        text: qsTr("High-Gravity Verdünnung")
                    }
                    ColumnLayout {
                        Layout.leftMargin: 8
                        visible: Brauhelfer.sud.highGravityFaktor > 0.0
                        RowLayout {
                            spacing: 16
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Wassermenge")
                            }
                            LabelNumber {
                                value: Brauhelfer.sud.WasserHgf
                            }
                            LabelUnit {
                                text: qsTr("l")
                            }
                        }
                        Repeater {
                            model: Brauhelfer.sud.modelWasseraufbereitung
                            delegate: RowLayout {
                                spacing: 16
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    precision: 2
                                    value: model.Menge * Brauhelfer.sud.WasserHgf
                                }
                                LabelUnit {
                                    text: app.defs.einheiten[model.Einheit]
                                }
                            }
                        }
                    }

                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Stammwürze")
                    }
                    GridLayout {
                        columns: 3
                        Layout.leftMargin: 8
                        columnSpacing: 16
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielstammwürze")
                        }
                        LabelPlato {
                            id: lblSWSollAnstellen
                            value: Brauhelfer.sud.SWSollAnstellen
                        }
                        LabelUnit {
                            text: qsTr("°P")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            value: BierCalc.platoToBrix(lblSWSollAnstellen.value)
                        }
                        LabelUnit {
                            text: qsTr("°Brix")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            precision: 4
                            value: BierCalc.platoToDichte(lblSWSollAnstellen.value)
                        }
                        LabelUnit {
                            text: qsTr("g/ml")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: lblWasserverschneidung.visible
                            text: qsTr("Wasserverschneidung")
                        }
                        LabelNumber {
                            id: lblWasserverschneidung
                            visible: value > 0
                            value: BierCalc.verschneidung(Brauhelfer.sud.SWAnstellen,
                                                                 Brauhelfer.sud.SWSollAnstellen,
                                                                 Brauhelfer.sud.WuerzemengeKochende * (1 + Brauhelfer.sud.highGravityFaktor/100))
                        }
                        LabelUnit {
                            visible: lblWasserverschneidung.visible
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Stammwürze")
                        }
                        TextFieldPlato {
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.SWAnstellen
                            onNewValue: Brauhelfer.sud.SWAnstellen = value
                        }
                        LabelUnit {
                            text: qsTr("°P")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Menge")
                    }
                    GridLayout {
                        columns: 3
                        Layout.leftMargin: 8
                        columnSpacing: 16
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Würzemenge nach Hopfenseihen")
                        }
                        TextFieldVolume {
                            enabled: !page.readOnly
                            value: Brauhelfer.sud.WuerzemengeKochende
                            onNewValue: Brauhelfer.sud.WuerzemengeKochende = value
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Verlust")
                        }
                        LabelNumber {
                            value: Brauhelfer.sud.WuerzemengeVorHopfenseihen - Brauhelfer.sud.WuerzemengeKochende
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Wassermenge für Verdünnung")
                        }
                        TextFieldVolume {
                            enabled: !page.readOnly
                            value: Brauhelfer.sud.VerduennungAnstellen
                            onNewValue: Brauhelfer.sud.VerduennungAnstellen = value
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Gesamtwürzemenge")
                        }
                        TextFieldVolume {
                            enabled: !page.readOnly
                            value: Brauhelfer.sud.WuerzemengeAnstellenTotal
                            onNewValue: Brauhelfer.sud.WuerzemengeAnstellenTotal = value
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Benötigte Speisemenge geschätzt (SRE 3°P, 20°C)")
                        }
                        LabelNumber {
                            value: {
                                var c = BierCalc.speise(Brauhelfer.sud.CO2, Brauhelfer.sud.SWAnstellen, 3.0, 3.0, 20.0)
                                return c * Brauhelfer.sud.WuerzemengeAnstellenTotal/(1+c)
                            }
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Abgefüllte Speisemenge")
                        }
                        TextFieldVolume {
                            enabled: !page.readOnly
                            value: Brauhelfer.sud.Speisemenge
                            onNewValue: Brauhelfer.sud.Speisemenge = value
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Anstellmenge")
                        }
                        TextFieldVolume {
                            enabled: !page.readOnly
                            value: Brauhelfer.sud.WuerzemengeAnstellen
                            onNewValue: Brauhelfer.sud.WuerzemengeAnstellen = value
                        }
                        LabelUnit {
                            text: qsTr("l")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    GridLayout {
                        columns: 3
                        columnSpacing: 16
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Effektive Sudhausausbeute")
                        }
                        LabelNumber {
                            value: Brauhelfer.sud.erg_EffektiveAusbeute
                        }
                        LabelUnit {
                            text: qsTr("%")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        spacing: 16
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Temperatur")
                        }
                        TextFieldTemperature {
                            id: tfTemperature
                            enabled: !page.readOnly
                            value: 20.0
                            onNewValue: this.value = value
                        }
                        LabelUnit {
                            text: qsTr("°C")
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Gärung")
                }
                ColumnLayout {
                    anchors.fill: parent
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: repeaterHefe.count > 0
                        font.bold: true
                        text: qsTr("Hefe")
                    }
                    Repeater {
                        id: repeaterHefe
                        model: Brauhelfer.sud.modelHefegaben
                        delegate: ColumnLayout {
                            Layout.leftMargin: 8
                            RowLayout {
                                spacing: 16
                                Layout.leftMargin: 8
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    precision: 0
                                    value: model.Menge
                                }
                                LabelUnit {
                                    text: "x"
                                }
                            }
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                        visible: repeaterHefe.count > 0 && repeaterModelWeitereZutatenGabenGaerung.count > 0
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: repeaterModelWeitereZutatenGabenGaerung.count > 0
                        font.bold: true
                        text: qsTr("Weitere Zutaten")
                    }
                    Repeater {
                        id: repeaterModelWeitereZutatenGabenGaerung
                        model: ProxyModel {
                            sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                            filterKeyColumn: fieldIndex("Zeitpunkt")
                            filterRegularExpression: /0/
                        }
                        delegate: ColumnLayout {
                            Layout.leftMargin: 8
                            RowLayout {
                                spacing: 16
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    precision: 2
                                    value: model.erg_Menge * app.defs.einheitenDivider[model.Einheit]
                                }
                                LabelUnit {
                                    text: app.defs.einheiten[model.Einheit]
                                }
                                LabelNumber {
                                    precision: 0
                                    value: model.Zugabedauer/ 1440
                                }
                                LabelUnit {
                                    text: qsTr("Tage")
                                }
                            }
                            LabelPrim {
                                Layout.leftMargin: 8
                                visible: model.Bemerkung !== ""
                                text: model.Bemerkung
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Bemerkung")
                }
                TextAreaBase {
                    anchors.fill: parent
                    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                    wrapMode: TextArea.Wrap
                    placeholderText: qsTr("Bemerkung")
                    textFormat: Text.RichText
                    text: Brauhelfer.sud.BemerkungBrauen
                    onLinkActivated: Qt.openUrlExternally(link)
                    onTextChanged: if (activeFocus) Brauhelfer.sud.BemerkungBrauen = text
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Abschluss")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Braudatum")
                    }
                    TextFieldDateTime {
                        id: tfBraudatum
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        enabled: !page.readOnly
                        date: Brauhelfer.sud.Status >= Brauhelfer.Gebraut ? Brauhelfer.sud.Braudatum : new Date()
                        onNewDate: this.date = date
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Zusätzliche Kosten")
                    }
                    TextFieldNumber {
                        enabled: !page.readOnly
                        precision: 2
                        value: Brauhelfer.sud.KostenWasserStrom
                        onNewValue: Brauhelfer.sud.KostenWasserStrom = value
                    }
                    LabelUnit {
                        text: Qt.locale().currencySymbol()
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Gesamtkosten")
                    }
                    LabelNumber {
                        precision: 2
                        value: Brauhelfer.sud.erg_Preis
                    }
                    LabelUnit {
                        text: Qt.locale().currencySymbol() + "/" + qsTr("l")
                    }
                    CheckBoxBase {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        enabled: !page.readOnly
                        text: qsTr("Sud für Durchschnittsberechnung ignorieren")
                        checked: Brauhelfer.sud.AusbeuteIgnorieren
                        onClicked: Brauhelfer.sud.AusbeuteIgnorieren = checked
                    }
                    ButtonBase {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        text: qsTr("Sud gebraut")
                        enabled: !page.readOnly
                        onClicked: gebraut()
                    }
                }
            }
        }
    }
}
