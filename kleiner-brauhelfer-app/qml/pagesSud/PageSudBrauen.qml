import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3

import "../common"
import brauhelfer 1.0
import ProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Brauen")
    icon: "brauen.png"
    readOnly: Brauhelfer.readonly || (Brauhelfer.sud.Status > Brauhelfer.Rezept && !app.brewForceEditable)

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
            icon: StandardIcon.Question
            text: qsTr("Verwendete Rohstoffe vom Bestand abziehen?")
            standardButtons: StandardButton.Yes | StandardButton.No
            //buttons: MessageDialog.Yes | MessageDialog.No
            onYes: Brauhelfer.sud.brauzutatenAbziehen()
        }

        ColumnLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
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
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            LabelNumber {
                                Layout.preferredWidth: 40
                                precision: 1
                                value: model.Prozent
                            }
                            LabelUnit {
                                Layout.preferredWidth: 30
                                text: qsTr("%")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 40
                                precision: 2
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                Layout.preferredWidth: 30
                                text: qsTr("kg")
                            }
                        }
                    }
                    RowLayout {
                        Layout.leftMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Gesamtschüttung")
                        }
                        Label {
                            Layout.preferredWidth: 40
                            text: ""
                        }
                        Label {
                            Layout.preferredWidth: 30
                            text: ""
                        }
                        LabelNumber {
                            Layout.preferredWidth: 40
                            font.bold: true
                            precision: 2
                            value: Brauhelfer.sud.erg_S_Gesamt
                        }
                        LabelUnit {
                            Layout.preferredWidth: 30
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
                            filterRegExp: /2/
                        }
                        delegate: ColumnLayout {
                            Layout.leftMargin: 8
                            RowLayout {
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 80
                                    precision: 2
                                    value: model.erg_Menge * app.defs.einheitenDivider[model.Einheit]
                                }
                                LabelUnit {
                                    Layout.preferredWidth: 60
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
                    GridLayout {
                        columns: 3
                        Layout.leftMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Wassermenge")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.erg_WHauptguss
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Rasten")
                    }
                    Repeater {
                        model: Brauhelfer.sud.modelRasten
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            TextFieldNumber {
                                Layout.preferredWidth: 40
                                enabled: !page.readOnly
                                precision: 0
                                value: model.Temp
                                onNewValue: model.Temp = value
                            }
                            LabelUnit {
                                Layout.preferredWidth: 30
                                text: qsTr("°C")
                            }
                            TextFieldNumber {
                                Layout.preferredWidth: 40
                                enabled: !page.readOnly
                                precision: 0
                                value: model.Dauer
                                onNewValue: model.Dauer = value
                            }
                            LabelUnit {
                                Layout.preferredWidth: 30
                                text: qsTr("min")
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
                label: LabelSubheader {
                    text: qsTr("Läutern")
                }
                ColumnLayout {
                    anchors.fill: parent
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Nachguss")
                    }
                    GridLayout {
                        columns: 3
                        Layout.leftMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Wassermenge")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.erg_WNachguss
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
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
                        onItemAdded: if (item.visible) ++countVisible
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            visible: model.Vorderwuerze
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name + " (" + model.Alpha + "%)"
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
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
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielstammwürze")
                        }
                        LabelPlato {
                            id: lblSWSollKochbeginn
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.SWSollKochbeginn
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("°P")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            Layout.preferredWidth: 80
                            value: BierCalc.platoToBrix(lblSWSollKochbeginn.value)
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("°Brix")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            Layout.preferredWidth: 80
                            precision: 4
                            value: BierCalc.platoToDichte(lblSWSollKochbeginn.value)
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("g/ml")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Stammwürze")
                        }
                        TextFieldPlato {
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.SWKochbeginn
                            onNewValue: Brauhelfer.sud.SWKochbeginn = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("°P")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielmenge bei 100°C")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: BierCalc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochbeginn)
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielmenge bei 20°C")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.MengeSollKochbeginn
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Würzemenge bei 20°C")
                        }
                        TextFieldVolume {
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.WuerzemengeKochbeginn
                            onNewValue: Brauhelfer.sud.WuerzemengeKochbeginn = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Kochdauer")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            precision: 0
                            value: Brauhelfer.sud.Kochdauer
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
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
                            visible: !model.Vorderwuerze
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name + " (" + model.Alpha + "%)"
                            }
                            LabelNumber {
                                Layout.preferredWidth: 40
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                Layout.preferredWidth: 30
                                text: qsTr("g")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 40
                                precision: 0
                                value: model.Zeit
                            }
                            LabelUnit {
                                Layout.preferredWidth: 30
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
                            filterRegExp: /1/
                        }
                        delegate: ColumnLayout {
                            Layout.leftMargin: 8
                            RowLayout {
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 40
                                    precision: 2
                                    value: model.erg_Menge * app.defs.einheitenDivider[model.Einheit]
                                }
                                LabelUnit {
                                    Layout.preferredWidth: 30
                                    text: app.defs.einheiten[model.Einheit]
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 40
                                    precision: 0
                                    value: model.Typ === 0 || model.Typ === 1 ? Brauhelfer.sud.Kochdauer : model.Zugabedauer
                                }
                                LabelUnit {
                                    Layout.preferredWidth: 30
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
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielstammwürze")
                        }
                        LabelPlato {
                            id: lblSWSollKochende
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.SWSollKochende
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("°P")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            Layout.preferredWidth: 80
                            value: BierCalc.platoToBrix(lblSWSollKochende.value)
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("°Brix")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            Layout.preferredWidth: 80
                            precision: 4
                            value: BierCalc.platoToDichte(lblSWSollKochende.value)
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("g/ml")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Stammwürze")
                        }
                        TextFieldPlato {
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.SWKochende
                            onNewValue: Brauhelfer.sud.SWKochende = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("°P")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielmenge bei 100°C")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: BierCalc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochende)
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielmenge bei 20°C")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.MengeSollKochende
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Würzemenge vor Hopfenseihen bei 20°C")
                        }
                        TextFieldVolume {
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.WuerzemengeVorHopfenseihen
                            onNewValue: Brauhelfer.sud.WuerzemengeVorHopfenseihen = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Würzemenge nach Hopfenseihen bei 20°C")
                        }
                        TextFieldVolume {
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.WuerzemengeKochende
                            onNewValue: Brauhelfer.sud.WuerzemengeKochende = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    GridLayout {
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Verdampfungsrate")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.VerdampfungsrateIst
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l/h")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            text: "Ø " + qsTr("Anlage")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.AnlageVerdampfungsrate
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l/h")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        visible: Brauhelfer.sud.Nachisomerisierungszeit > 0.0
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Nachisomerisierung")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            precision: 0
                            value: Brauhelfer.sud.Nachisomerisierungszeit
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("min")
                        }
                    }
                    HorizontalDivider {
                        visible: Brauhelfer.sud.Nachisomerisierungszeit > 0.0
                        Layout.fillWidth: true
                    }
                    GridLayout {
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Sudhausausbeute")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.erg_Sudhausausbeute
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("%")
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: qsTr("Anstellen")
                }
                ColumnLayout {
                    anchors.fill: parent
                    LabelPrim {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Stammwürze")
                    }
                    GridLayout {
                        columns: 3
                        Layout.leftMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielstammwürze")
                        }
                        LabelPlato {
                            id: lblSWSollAnstellen
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.SWSollAnstellen
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("°P")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            Layout.preferredWidth: 80
                            value: BierCalc.platoToBrix(lblSWSollAnstellen.value)
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("°Brix")
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        LabelPlato {
                            Layout.preferredWidth: 80
                            precision: 4
                            value: BierCalc.platoToDichte(lblSWSollAnstellen.value)
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("g/ml")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: Brauhelfer.sud.highGravityFaktor > 0.0
                            text: qsTr("High-Gravity Verdünnung")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            visible: Brauhelfer.sud.highGravityFaktor > 0.0
                            value: Brauhelfer.sud.Menge - Brauhelfer.sud.MengeSollKochende
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            visible: Brauhelfer.sud.highGravityFaktor > 0.0
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: lblWasserverschneidung.visible
                            text: qsTr("Wasserverschneidung")
                        }
                        LabelNumber {
                            id: lblWasserverschneidung
                            Layout.preferredWidth: 80
                            visible: value > 0
                            value: BierCalc.verschneidung(Brauhelfer.sud.SWAnstellen,
                                                                 Brauhelfer.sud.SWSollAnstellen,
                                                                 Brauhelfer.sud.WuerzemengeKochende * (1 + Brauhelfer.sud.highGravityFaktor/100))
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            visible: lblWasserverschneidung.visible
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Stammwürze")
                        }
                        TextFieldPlato {
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            useDialog: true
                            value: Brauhelfer.sud.SWAnstellen
                            onNewValue: Brauhelfer.sud.SWAnstellen = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
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
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Würzemenge")
                        }
                        TextFieldVolume {
                            id: tfWuerzemenge
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            value: Brauhelfer.sud.WuerzemengeAnstellenTotal
                            onNewValue: Brauhelfer.sud.WuerzemengeAnstellenTotal = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Benötigte Speisemenge geschätzt (SRE 3°P, 20°C)")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: {
                                var c = BierCalc.speise(Brauhelfer.sud.CO2, Brauhelfer.sud.SWAnstellen, 3.0, 3.0, 20.0)
                                return c * Brauhelfer.sud.WuerzemengeAnstellenTotal/(1+c)
                            }
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Abgefüllte Speisemenge")
                        }
                        TextFieldVolume {
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            value: Brauhelfer.sud.Speisemenge
                            onNewValue: Brauhelfer.sud.Speisemenge = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Anstellmenge")
                        }
                        TextFieldVolume {
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            value: Brauhelfer.sud.WuerzemengeAnstellen
                            onNewValue: Brauhelfer.sud.WuerzemengeAnstellen = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("l")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    GridLayout {
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Effektive Sudhausausbeute")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.erg_EffektiveAusbeute
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("%")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            text: "Ø " + qsTr("Anlage")
                        }
                        LabelNumber {
                            Layout.preferredWidth: 80
                            value: Brauhelfer.sud.AnlageSudhausausbeute
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("%")
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Temperatur")
                        }
                        TextFieldTemperature {
                            id: tfTemperature
                            Layout.preferredWidth: 80
                            enabled: !page.readOnly
                            value: 20.0
                            onNewValue: this.value = value
                        }
                        LabelUnit {
                            Layout.preferredWidth: 60
                            text: qsTr("°C")
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
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
                                Layout.leftMargin: 8
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 80
                                    precision: 0
                                    value: model.Menge
                                }
                                LabelUnit {
                                    Layout.preferredWidth: 60
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
                            filterRegExp: /0/
                        }
                        delegate: ColumnLayout {
                            Layout.leftMargin: 8
                            RowLayout {
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 40
                                    precision: 2
                                    value: model.erg_Menge * app.defs.einheitenDivider[model.Einheit]
                                }
                                LabelUnit {
                                    Layout.preferredWidth: 30
                                    text: app.defs.einheiten[model.Einheit]
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 40
                                    precision: 0
                                    value: model.Zugabedauer/ 1440
                                }
                                LabelUnit {
                                    Layout.preferredWidth: 30
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
                label: LabelSubheader {
                    text: qsTr("Abschluss")
                }
                GridLayout {
                    anchors.fill: parent
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
                       Layout.preferredWidth: 60
                        text: Qt.locale().currencySymbol()
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Gesamtkosten")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 80
                        precision: 2
                        value: Brauhelfer.sud.erg_Preis
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: Qt.locale().currencySymbol() + "/" + qsTr("l")
                    }
                    CheckBox {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        enabled: !page.readOnly
                        text: qsTr("Ausbeute für Durchschnitt nicht einbeziehen")
                        checked: Brauhelfer.sud.AusbeuteIgnorieren
                        onClicked: Brauhelfer.sud.AusbeuteIgnorieren = checked
                    }
                    Button {
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
