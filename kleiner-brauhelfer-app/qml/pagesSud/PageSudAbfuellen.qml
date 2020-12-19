import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0
import ProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Abfüllen")
    icon: "abfuellen.png"
    readOnly: Brauhelfer.readonly || (Brauhelfer.sud.Status !== Brauhelfer.Gebraut && !app.brewForceEditable)

    Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentHeight: layout.height
        boundsBehavior: Flickable.OvershootBounds
        onMovementStarted: forceActiveFocus()
        ScrollIndicator.vertical: ScrollIndicator {}

        function abgefuellt() {
            var bereit = true;
            if (!Brauhelfer.sud.AbfuellenBereitZutaten) {
                bereit = false;
            }
            else if (Brauhelfer.sud.SchnellgaerprobeAktiv) {
                if (Brauhelfer.sud.SWJungbier > Brauhelfer.sud.Gruenschlauchzeitpunkt)
                    bereit = false;
                else if (Brauhelfer.sud.SWJungbier < Brauhelfer.sud.SWSchnellgaerprobe)
                    bereit = false;
            }
            if (bereit) {
                Brauhelfer.sud.Abfuelldatum = tfAbfuelldatum.date
                Brauhelfer.sud.Status = Brauhelfer.Abgefuellt
                var values = {"SudID": Brauhelfer.sud.id,
                              "Zeitstempel": Brauhelfer.sud.Abfuelldatum,
                              "Temp": Brauhelfer.sud.TemperaturJungbier }
                if (Brauhelfer.sud.modelNachgaerverlauf.rowCount() === 0)
                    Brauhelfer.sud.modelNachgaerverlauf.append(values)
            }
        }

        ColumnLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            GroupBox {
                visible: listViewWeitereZutaten.count > 0
                Layout.fillWidth: true
                contentHeight: contentLayout.height
                label: LabelHeader {
                    text: qsTr("Weitere Zutaten")
                }
                ColumnLayout {
                    id: contentLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    ListView {
                        id: listViewWeitereZutaten
                        Layout.fillWidth: true
                        height: contentHeight
                        interactive: false
                        model: ProxyModel {
                            sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                            filterKeyColumn: fieldIndex("Zeitpunkt")
                            filterRegExp: /0/
                        }
                        delegate: ItemDelegate {
                            enabled: !page.readOnly
                            width: listViewWeitereZutaten.width
                            height: dataColumn.implicitHeight
                            onClicked: {
                                listViewWeitereZutaten.currentIndex = index
                                popuploaderWeitereZutaten.active = true
                            }
                            ColumnLayout {
                                id: dataColumn
                                anchors.left: parent.left
                                anchors.right: parent.right
                                RowLayout {
                                    spacing: 16
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
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.Status === Brauhelfer.Gebraut && !Brauhelfer.sud.AbfuellenBereitZutaten
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.accent
                        text: qsTr("Zutaten noch nicht zugegeben oder entnommen.")
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

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Restextrakt Schnellgärprobe")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    SwitchBase {
                        id: ctrlSGPen
                        Layout.columnSpan: 3
                        text: qsTr("Aktiviert")
                        enabled: !page.readOnly
                        checked: Brauhelfer.sud.SchnellgaerprobeAktiv
                        onClicked: Brauhelfer.sud.SchnellgaerprobeAktiv = checked
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: ctrlSGPen.checked
                        text: qsTr("Scheinbar")
                    }
                    TextFieldPlato {
                        enabled: !page.readOnly && ctrlSGPen.checked
                        visible: ctrlSGPen.checked
                        useDialog: true
                        sw: Brauhelfer.sud.SWIst
                        value: Brauhelfer.sud.SWSchnellgaerprobe
                        onNewValue: Brauhelfer.sud.SWSchnellgaerprobe = value
                    }
                    LabelUnit {
                        visible: ctrlSGPen.checked
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: ctrlSGPen.checked
                        text: qsTr("Tatsächlich")
                    }
                    LabelPlato {
                        visible: ctrlSGPen.checked
                        value: BierCalc.toTRE(Brauhelfer.sud.SWIst, Brauhelfer.sud.SWSchnellgaerprobe)
                    }
                    LabelUnit {
                        visible: ctrlSGPen.checked
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: ctrlSGPen.checked
                        text: qsTr("Grünschlauchzeitpunkt")
                    }
                    LabelPlato {
                        id: ctrlGS
                        horizontalAlignment: Text.AlignHCenter
                        visible: ctrlSGPen.checked
                        value: Brauhelfer.sud.Gruenschlauchzeitpunkt
                    }
                    LabelUnit {
                        visible: ctrlSGPen.checked
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        visible: ctrlSGPen.checked && Brauhelfer.sud.SWJungbier < Brauhelfer.sud.SWSchnellgaerprobe
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.accent
                        text: qsTr("Jungbier liegt tiefer als Schnellgärprobe.")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Restextrakt Jungbier")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Scheinbar")
                    }
                    TextFieldPlato {
                        enabled: !page.readOnly
                        useDialog: true
                        sw: Brauhelfer.sud.SWIst
                        value: Brauhelfer.sud.SWJungbier
                        onNewValue: Brauhelfer.sud.SWJungbier = value
                    }
                    LabelUnit {
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        text: qsTr("Erwartet")
                    }
                    LabelPlato {
                        value: BierCalc.sreAusVergaerungsgrad(Brauhelfer.sud.SWIst, Brauhelfer.sud.Vergaerungsgrad)
                    }
                    LabelUnit {
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Tatsächlich")
                    }
                    LabelPlato {
                        value: BierCalc.toTRE(Brauhelfer.sud.SWIst, Brauhelfer.sud.SWJungbier)
                    }
                    LabelUnit {
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        visible: ctrlSGPen.checked && Brauhelfer.sud.SWJungbier > Brauhelfer.sud.Gruenschlauchzeitpunkt
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.accent
                        text: qsTr("Grünschlauchzeitpunkt noch nicht erreicht.")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Bierwerte")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Stammwürze")
                    }
                    LabelPlato {
                        horizontalAlignment: Text.AlignHCenter
                        value: Brauhelfer.sud.SWIst
                    }
                    LabelUnit {
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Vergärungsgrad scheinbar")
                    }
                    LabelNumber {
                        value: BierCalc.vergaerungsgrad(Brauhelfer.sud.SWIst, Brauhelfer.sud.SREIst)
                    }
                    LabelUnit {
                        text: qsTr("%")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Vergärungsgrad tatsächlich")
                    }
                    LabelNumber {
                        value: BierCalc.vergaerungsgrad(Brauhelfer.sud.SWIst, BierCalc.toTRE(Brauhelfer.sud.SWIst, Brauhelfer.sud.SREIst))
                    }
                    LabelUnit {
                        text: qsTr("%")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Alkohol")
                    }
                    LabelNumber {
                        id: ctrlAlc
                        precision: 1
                        value: Brauhelfer.sud.erg_Alkohol
                    }
                    LabelUnit {
                        text: qsTr("%vol")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        text: qsTr("Erwartet")
                    }
                    LabelNumber {
                        precision: 1
                        value: Brauhelfer.sud.Alkohol
                    }
                    LabelUnit {
                        text: qsTr("%vol")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Spundungsdruck")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Temperatur Jungbier")
                    }
                    TextFieldTemperature {
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.TemperaturJungbier
                        onNewValue: Brauhelfer.sud.TemperaturJungbier = value
                    }
                    LabelUnit {
                        text: qsTr("°C")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Spundungsdruck")
                    }
                    LabelNumber {
                        precision: 2
                        value: Brauhelfer.sud.Spundungsdruck
                    }
                    LabelUnit {
                        text: qsTr("bar")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Karbonisierung")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 5
                    SwitchBase {
                        id: ctrlSpunden
                        Layout.columnSpan: 5
                        text: qsTr("Spunden")
                        enabled: !page.readOnly
                        checked: Brauhelfer.sud.Spunden
                        onClicked: Brauhelfer.sud.Spunden = checked
                    }

                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        text: qsTr("Temperatur")
                    }
                    TextFieldTemperature {
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.TemperaturKarbonisierung
                        onNewValue: Brauhelfer.sud.TemperaturKarbonisierung = value
                    }
                    LabelUnit {
                        text: qsTr("°C")
                    }

                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        visible: tbZuckerAnteil.visible
                        text: qsTr("Süsskraft Zucker")
                    }
                    TextFieldNumber {
                        Layout.columnSpan: 2
                        visible: tbZuckerAnteil.visible
                        min: 0.0
                        max: 2.0
                        precision: 2
                        enabled: !page.readOnly
                        value: app.settings.sugarFactor
                        onNewValue: app.settings.sugarFactor = value
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        visible: !ctrlSpunden.checked
                        text: qsTr("Wasser Zuckerlösung")
                    }
                    TextFieldNumber {
                        visible: !ctrlSpunden.checked
                        precision: 2
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.VerschneidungAbfuellen
                        onNewValue: Brauhelfer.sud.VerschneidungAbfuellen = value
                    }
                    LabelUnit {
                        visible: !ctrlSpunden.checked
                        text: qsTr("l")
                    }

                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        visible: !ctrlSpunden.checked
                        text: qsTr("Abgefüllte Speisemenge")
                    }
                    TextFieldNumber {
                        visible: !ctrlSpunden.checked
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.Speisemenge
                        onNewValue: Brauhelfer.sud.Speisemenge = value
                    }
                    LabelUnit {
                        visible: !ctrlSpunden.checked
                        text: qsTr("l")
                    }



                    LabelPrim {
                        Layout.fillWidth: true
                        visible: tbSpeiseAnteil.visible
                        text: qsTr("Speiseanteil")
                    }
                    LabelNumber {
                        id: tbSpeiseAnteil
                        visible: !ctrlSpunden.checked
                        precision: 0
                        value: Brauhelfer.sud.SpeiseAnteil
                    }
                    LabelUnit {
                        visible: tbSpeiseAnteil.visible
                        text: qsTr("ml")
                    }
                    LabelNumber {
                        horizontalAlignment: Text.AlignHCenter
                        visible: tbSpeiseAnteil.visible
                        precision: 1
                        value: Brauhelfer.sud.JungbiermengeAbfuellen > 0.0 ? Brauhelfer.sud.SpeiseAnteil / Brauhelfer.sud.JungbiermengeAbfuellen : 0.0
                    }
                    LabelUnit {
                        visible: tbSpeiseAnteil.visible
                        text: qsTr("ml/l")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: tbZuckerAnteil.visible
                        text: qsTr("Zuckeranteil")
                    }
                    LabelNumber {
                        id: tbZuckerAnteil
                        visible: !ctrlSpunden.checked && value > 0.0
                        precision: 0
                        value: Brauhelfer.sud.ZuckerAnteil / app.settings.sugarFactor
                    }
                    LabelUnit {
                        visible: tbZuckerAnteil.visible
                        text: qsTr("g")
                    }
                    LabelNumber {
                        horizontalAlignment: Text.AlignHCenter
                        visible: tbZuckerAnteil.visible
                        precision: 1
                        value: Brauhelfer.sud.JungbiermengeAbfuellen > 0.0 ? tbZuckerAnteil.value / Brauhelfer.sud.JungbiermengeAbfuellen : 0.0
                    }
                    LabelUnit {
                        visible: tbZuckerAnteil.visible
                        text: qsTr("g/l")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Menge")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Jungbiermenge")
                    }
                    TextFieldVolume {
                        id: ctrlJungbiermenge
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.JungbiermengeAbfuellen
                        onNewValue: Brauhelfer.sud.JungbiermengeAbfuellen = value
                    }
                    LabelUnit {
                        text: qsTr("l")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Verlust seit Anstellen")
                    }
                    LabelNumber {
                        value: Brauhelfer.sud.WuerzemengeAnstellen - Brauhelfer.sud.JungbiermengeAbfuellen
                    }
                    LabelUnit {
                        text: qsTr("l")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: !ctrlSpunden.checked
                        text: qsTr("Speise")
                    }
                    LabelNumber {
                        visible: !ctrlSpunden.checked
                        value: Brauhelfer.sud.SpeiseAnteil / 1000
                    }
                    LabelUnit {
                        visible: !ctrlSpunden.checked
                        text: qsTr("l")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: !ctrlSpunden.checked
                        text: qsTr("Biermenge")
                    }
                    TextFieldVolume {
                        id: ctrlBiermenge
                        visible: !ctrlSpunden.checked
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.erg_AbgefuellteBiermenge
                        onNewValue: Brauhelfer.sud.erg_AbgefuellteBiermenge = value
                    }
                    LabelUnit {
                        visible: !ctrlSpunden.checked
                        text: qsTr("l")
                    }
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
                        text: qsTr("Abfülldatum")
                    }
                    TextFieldDateTime {
                        id: tfAbfuelldatum
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        enabled: !page.readOnly
                        date: Brauhelfer.sud.Status >= Brauhelfer.Abgefuellt ? Brauhelfer.sud.Abfuelldatum : new Date()
                        onNewDate: {
                            this.date = date
                        }
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
                    ButtonBase {
                        id: ctrlAbgefuellt
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        text: qsTr("Sud abgefüllt")
                        enabled: !page.readOnly
                        onClicked: abgefuellt()
                    }
                }
            }
        }
    }
}
