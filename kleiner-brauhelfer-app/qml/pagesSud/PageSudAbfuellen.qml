import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Abfüllen")
    icon: "abfuellen.png"
    readOnly: Brauhelfer.readonly || ((!Brauhelfer.sud.BierWurdeGebraut || Brauhelfer.sud.BierWurdeAbgefuellt) && !app.brewForceEditable)

    component: Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentHeight: layout.height
        boundsBehavior: Flickable.OvershootBounds
        ScrollIndicator.vertical: ScrollIndicator {}

        property bool bereit: false

        Component.onCompleted: updateStatus()

        Connections {
            target: Brauhelfer.sud
            onModified: updateStatus()
        }

        function updateStatus() {
            bereit = true;
            if (!Brauhelfer.sud.AbfuellenBereitZutaten) {
                ctrlStatus.text = qsTr("Zutaten noch nicht zugegeben oder entnommen.")
                bereit = false;
            }
            else if (Brauhelfer.sud.SchnellgaerprobeAktiv) {
                if (Brauhelfer.sud.SWJungbier > Brauhelfer.sud.Gruenschlauchzeitpunkt) {
                    ctrlStatus.text = qsTr("Grünschlauchzeitpunkt noch nicht erreicht.")
                    bereit = false;
                }
                else if (Brauhelfer.sud.SWJungbier < Brauhelfer.sud.SWSchnellgaerprobe) {
                    ctrlStatus.text = qsTr("Schnellgärprobe liegt tiefer als Jungbier.")
                    bereit = false;
                }
            }
            ctrlStatus.visible = !bereit;
        }

        function abgefuellt() {
            if (bereit) {
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
                property alias name: label0.text
                id: group0
                Layout.fillWidth: true
                label: LabelSubheader {
                    id: label0
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
                    LabelPrim {
                        Layout.preferredWidth: 70
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
                    LabelPrim {
                        Layout.preferredWidth: 70
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
                    LabelPrim {
                        Layout.preferredWidth: 70
                        visible: ctrlSGPen.checked
                        text: qsTr("°P")
                    }
                }
            }

            GroupBox {
                property alias name: label1.text
                id: group1
                Layout.fillWidth: true
                label: LabelSubheader {
                    id: label1
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
                    LabelPrim {
                        Layout.preferredWidth: 70
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
                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: qsTr("°P")
                    }
                }
            }

            GroupBox {
                property alias name: label2.text
                id: group2
                Layout.fillWidth: true
                label: LabelSubheader {
                    id: label2
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
                    LabelPrim {
                        Layout.preferredWidth: 70
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
                    LabelPrim {
                        Layout.preferredWidth: 70
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
                    LabelPrim {
                        Layout.preferredWidth: 70
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
                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: qsTr("%")
                    }
                }
            }

            GroupBox {
                property alias name: label3.text
                id: group3
                Layout.fillWidth: true
                label: LabelSubheader {
                    id: label3
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
                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: qsTr("°C")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Spundungsdruck")
                    }
                    LabelNumber {
                        id: ctrlSpund
                        Layout.preferredWidth: 60
                        value: Brauhelfer.sud.Spundungsdruck
                    }
                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: qsTr("bar")
                    }
                }
            }

            GroupBox {
                property alias name: label4.text
                id: group4
                Layout.fillWidth: true
                label: LabelSubheader {
                    id: label4
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
                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: qsTr("Liter")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Biermenge")
                    }
                    TextFieldVolume {
                        id: ctrlBiermenge
                        Layout.preferredWidth: 60
                        enabled: !page.readOnly
                        value: Brauhelfer.sud.erg_AbgefuellteBiermenge
                        onNewValue: Brauhelfer.sud.erg_AbgefuellteBiermenge = value
                    }
                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: qsTr("Liter")
                    }
                }
            }

            GroupBox {
                property alias name: label5.text
                id: group5
                Layout.fillWidth: true
                label: LabelSubheader {
                    id: label5
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
                        id: ctrlFaktor
                        Layout.columnSpan: 2
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked
                        min: 0.0
                        max: 2.0
                        precision: 2
                        enabled: !page.readOnly
                        value: 1.0
                        onNewValue: this.value = value
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: !ctrlSpunden.checked
                        text: qsTr("Speise")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked
                        precision: 0
                        value: Brauhelfer.sud.SpeiseAnteil
                    }
                    LabelPrim {
                        Layout.preferredWidth: 30
                        visible: !ctrlSpunden.checked
                        text: qsTr("ml")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignHCenter
                        visible: !ctrlSpunden.checked
                        precision: 0
                        value: Brauhelfer.sud.JungbiermengeAbfuellen > 0.0 ? Brauhelfer.sud.SpeiseAnteil / Brauhelfer.sud.JungbiermengeAbfuellen : 0.0
                    }
                    LabelPrim {
                        Layout.preferredWidth: 70
                        visible: !ctrlSpunden.checked
                        text: qsTr("ml/Liter")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: !ctrlSpunden.checked
                        text: qsTr("Zucker")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        visible: !ctrlSpunden.checked
                        precision: 1
                        value: Brauhelfer.sud.ZuckerAnteil / ctrlFaktor.value
                    }
                    LabelPrim {
                        Layout.preferredWidth: 30
                        visible: !ctrlSpunden.checked
                        text: qsTr("g")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignHCenter
                        visible: !ctrlSpunden.checked
                        precision: 1
                        value: Brauhelfer.sud.JungbiermengeAbfuellen > 0.0 ? Brauhelfer.sud.ZuckerAnteil / ctrlFaktor.value / Brauhelfer.sud.JungbiermengeAbfuellen : 0.0
                    }
                    LabelPrim {
                        Layout.preferredWidth: 70
                        visible: !ctrlSpunden.checked
                        text: qsTr("g/Liter")
                    }
                }
            }

            GroupBox {
                property alias name: label6.text
                id: group6
                Layout.fillWidth: true
                label: LabelSubheader {
                    id: label6
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
                        Layout.columnSpan: 2
                        enabled: !page.readOnly
                        date: Brauhelfer.sud.BierWurdeAbgefuellt ? Brauhelfer.sud.Abfuelldatum : new Date()
                        onNewDate: {
                            this.date = date
                            Brauhelfer.sud.Abfuelldatum = date
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
                    LabelPrim {
                       Layout.preferredWidth: 70
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
                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: Qt.locale().currencySymbol() + "/" + qsTr("Liter")
                    }
                    Button {
                        id: ctrlAbgefuellt
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        text: qsTr("Abgefüllt")
                        enabled: !page.readOnly
                        onClicked: abgefuellt()
                    }
                    LabelPrim {
                        id: ctrlStatus
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.accent
                    }
                }
            }
        }
    }
}
