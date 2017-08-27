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

    component: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0
            Repeater {
                model: 7
                ToolButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    opacity: Material.theme === Material.Dark ? 1.00 : 0.87
                    visible: flickable.groupID(index).visible
                    text: flickable.groupID(index).name.substr(0, 1)
                    onClicked: flickable.contentY = flickable.groupID(index).y
                }
            }
        }

        HorizontalDivider { }

        Flickable {
            id: flickable
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            contentHeight: layout.height
            boundsBehavior: Flickable.OvershootBounds
            ScrollIndicator.vertical: ScrollIndicator {}

            Behavior on contentY {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            function groupID(group) {
                switch (group)
                {
                    case 0: return group0
                    case 1: return group1
                    case 2: return group2
                    case 3: return group3
                    case 4: return group4
                    case 5: return group5
                    case 6: return group6
                }
                return null
            }

            property bool bereit: false

            Component.onCompleted: flickable.updateStatus()

            Connections {
                target: Brauhelfer.sud
                onModified: flickable.updateStatus()
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
                            enabled: !page.readOnly
                            date: Brauhelfer.sud.BierWurdeAbgefuellt ? Brauhelfer.sud.Abfuelldatum : new Date()
                            onNewDate: {
                                this.date = date
                                Brauhelfer.sud.Abfuelldatum = date
                            }
                        }
                        Item {
                            Layout.preferredWidth: 70
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
                            text: qsTr("CHF")
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
                            text: qsTr("CHF/Liter")
                        }
                        Button {
                            id: ctrlAbgefuellt
                            Layout.columnSpan: 3
                            Layout.fillWidth: true
                            text: qsTr("Abgefüllt")
                            enabled: !page.readOnly
                            onClicked: flickable.abgefuellt()
                        }
                        LabelPrim {
                            id:ctrlStatus
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
}
