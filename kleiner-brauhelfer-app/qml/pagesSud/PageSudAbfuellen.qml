import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Abfüllen")
    icon: "abfuellen.png"
    readOnly: Brauhelfer.readonly || ((!Brauhelfer.sud.BierWurdeGebraut || Brauhelfer.sud.BierWurdeAbgefuellt) && !app.brewForceEditable)

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
                Brauhelfer.sud.BierWurdeAbgefuellt = true
                Brauhelfer.sud.modelNachgaerverlauf.append({"Temp": ctrlTemp.text })
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
                label: LabelSubheader {
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
                        model: SortFilterProxyModel {
                            sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                            filterKeyColumn: sourceModel.fieldIndex("Zeitpunkt")
                            filterRegExp: /0/
                        }
                        delegate: ItemDelegate {
                            width: parent.width
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
                                            case 1: return (new Date().getTime() - model.Zeitpunkt_von.getTime()) / 1440 / 60000
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
                        id: statuss
                        visible: !Brauhelfer.sud.AbfuellenBereitZutaten
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
                label: LabelSubheader {
                    text: qsTr("Restextrakt Schnellgärprobe")
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    Switch {
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
                        Layout.preferredWidth: 60
                        enabled: !page.readOnly && ctrlSGPen.checked
                        visible: ctrlSGPen.checked
                        useDialog: true
                        sw: Brauhelfer.sud.SWIst
                        value: Brauhelfer.sud.SWSchnellgaerprobe
                        onNewValue: Brauhelfer.sud.SWSchnellgaerprobe = value
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        visible: ctrlSGPen.checked
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: ctrlSGPen.checked
                        text: qsTr("Tatsächlich")
                    }
                    LabelPlato {
                        Layout.preferredWidth: 60
                        visible: ctrlSGPen.checked
                        value: Brauhelfer.calc.toTRE(Brauhelfer.sud.SWIst, Brauhelfer.sud.SWSchnellgaerprobe)
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
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
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignHCenter
                        visible: ctrlSGPen.checked
                        value: Brauhelfer.sud.Gruenschlauchzeitpunkt
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        visible: ctrlSGPen.checked
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        visible: ctrlSGPen.checked && Brauhelfer.sud.SWJungbier < Brauhelfer.sud.SWSchnellgaerprobe
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.accent
                        text: qsTr("Schnellgärprobe liegt tiefer als Jungbier.")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: qsTr("Restextrakt Jungbier")
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Scheinbar")
                    }
                    TextFieldPlato {
                        Layout.preferredWidth: 60
                        enabled: !page.readOnly
                        useDialog: true
                        sw: Brauhelfer.sud.SWIst
                        value: Brauhelfer.sud.SWJungbier
                        onNewValue: Brauhelfer.sud.SWJungbier = value
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Tatsächlich")
                    }
                    LabelPlato {
                        Layout.preferredWidth: 60
                        value: Brauhelfer.calc.toTRE(Brauhelfer.sud.SWIst, Brauhelfer.sud.SWJungbier)
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
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
                label: LabelSubheader {
                    text: qsTr("Bierwerte")
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Stammwürze")
                    }
                    LabelPlato {
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignHCenter
                        value: Brauhelfer.sud.SWIst
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Vergärungsgrad scheinbar")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        value: Brauhelfer.calc.vergaerungsgrad(Brauhelfer.sud.SWIst, Brauhelfer.sud.SREIst)
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: qsTr("%")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Vergärungsgrad tatsächlich")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        value: Brauhelfer.calc.vergaerungsgrad(Brauhelfer.sud.SWIst, Brauhelfer.calc.toTRE(Brauhelfer.sud.SWIst, Brauhelfer.sud.SREIst))
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: qsTr("%")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Alkohol")
                    }
                    LabelNumber {
                        id: ctrlAlc
                        Layout.preferredWidth: 60
                        precision: 1
                        value: Brauhelfer.sud.erg_Alkohol
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: qsTr("%")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: qsTr("Druck")
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Temperatur Jungbier")
                    }
                    TextFieldTemperature {
                        id: ctrlTemp
                        Layout.preferredWidth: 60
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.TemperaturJungbier
                        onNewValue: Brauhelfer.sud.TemperaturJungbier = value
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: qsTr("°C")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Spundungsdruck")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        value: Brauhelfer.sud.Spundungsdruck
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: qsTr("bar")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: qsTr("Menge")
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Jungbiermenge")
                    }
                    TextFieldVolume {
                        id: ctrlJungbiermenge
                        Layout.preferredWidth: 60
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.JungbiermengeAbfuellen
                        onNewValue: Brauhelfer.sud.JungbiermengeAbfuellen = value
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: qsTr("l")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: !ctrlSpunden.checked
                        text: qsTr("Speise")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked
                        value: Brauhelfer.sud.SpeiseAnteil / 1000
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
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
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.erg_AbgefuellteBiermenge
                        onNewValue: Brauhelfer.sud.erg_AbgefuellteBiermenge = value
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked
                        text: qsTr("l")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: qsTr("Speise & Zucker")
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 5
                    Switch {
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
                        visible: !ctrlSpunden.checked
                        text: qsTr("Zuckerfaktor")
                    }
                    TextFieldNumber {
                        Layout.columnSpan: 2
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked
                        min: 0.0
                        max: 2.0
                        precision: 2
                        enabled: !page.readOnly
                        value: app.settings.sugarFactor
                        onNewValue: app.settings.sugarFactor = value
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: !ctrlSpunden.checked
                        text: qsTr("Speise")
                    }
                    LabelNumber {
                        id: tbSpeiseTotal
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked
                        precision: 0
                        value: Brauhelfer.sud.SpeiseNoetig
                    }
                    LabelUnit {
                        Layout.preferredWidth: 30
                        visible: !ctrlSpunden.checked
                        text: qsTr("ml")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignHCenter
                        visible: !ctrlSpunden.checked
                        precision: 0
                        value: Brauhelfer.sud.JungbiermengeAbfuellen > 0.0 ? Brauhelfer.sud.SpeiseNoetig / Brauhelfer.sud.JungbiermengeAbfuellen : 0.0
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked
                        text: qsTr("ml/l")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: tbSpeiseAnteil.visible
                        text: qsTr("Speiseanteil")
                    }
                    LabelNumber {
                        id: tbSpeiseAnteil
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked && value < tbSpeiseTotal.value
                        precision: 0
                        value: Brauhelfer.sud.SpeiseAnteil
                    }
                    LabelUnit {
                        Layout.preferredWidth: 30
                        visible: tbSpeiseAnteil.visible
                        text: qsTr("ml")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignHCenter
                        visible: tbSpeiseAnteil.visible
                        precision: 0
                        value: Brauhelfer.sud.JungbiermengeAbfuellen > 0.0 ? Brauhelfer.sud.SpeiseAnteil / Brauhelfer.sud.JungbiermengeAbfuellen : 0.0
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
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
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked && value > 0.0
                        precision: 1
                        value: Brauhelfer.sud.ZuckerAnteil / app.settings.sugarFactor
                    }
                    LabelUnit {
                        Layout.preferredWidth: 30
                        visible: tbZuckerAnteil.visible
                        text: qsTr("g")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignHCenter
                        visible: tbZuckerAnteil.visible
                        precision: 1
                        value: Brauhelfer.sud.JungbiermengeAbfuellen > 0.0 ? tbZuckerAnteil.value / Brauhelfer.sud.JungbiermengeAbfuellen : 0.0
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        visible: tbZuckerAnteil.visible
                        text: qsTr("g/l")
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
                        text: qsTr("Abfülldatum")
                    }
                    TextFieldDate {
                        id: tfAbfuelldatum
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        enabled: !page.readOnly
                        date: Brauhelfer.sud.BierWurdeAbgefuellt ? Brauhelfer.sud.Abfuelldatum : new Date()
                        onNewDate: {
                            this.date = date
                        }
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Nebenkosten")
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
                        text: qsTr("Preis")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        precision: 2
                        value: Brauhelfer.sud.erg_Preis
                    }
                    LabelUnit {
                        Layout.preferredWidth: 60
                        text: Qt.locale().currencySymbol() + "/" + qsTr("l")
                    }
                    Button {
                        id: ctrlAbgefuellt
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        text: qsTr("Abgefüllt")
                        enabled: !page.readOnly
                        onClicked: abgefuellt()
                    }
                }
            }
        }
    }
}
