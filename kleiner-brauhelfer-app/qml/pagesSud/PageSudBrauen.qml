import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Brauen")
    icon: "brauen.png"
    readOnly: Brauhelfer.readonly || (Brauhelfer.sud.BierWurdeGebraut && !app.brewForceEditable)

    component: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0
            Repeater {
                model: 8
                ToolButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    opacity: app.config.textOpacityFull
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
                    case 7: return group7
                }
                return null
            }

            function gebraut() {
                messageDialog.open()
                Brauhelfer.sud.BierWurdeGebraut = true
                Brauhelfer.sud.modelSchnellgaerverlauf.append({"SW": Brauhelfer.sud.SWAnstellen, "Temp": tfTemperature.value })
                Brauhelfer.sud.modelHauptgaerverlauf.append({"SW": Brauhelfer.sud.SWAnstellen, "Temp": tfTemperature.value })
            }

            // message dialog
            MessageDialog {
                id: messageDialog
                icon: StandardIcon.Question
                text: qsTr("Verwendete Rohstoffe vom Bestand abziehen?")
                standardButtons: StandardButton.Yes | StandardButton.No
                //buttons: MessageDialog.Yes | MessageDialog.No
                onYes: Brauhelfer.sud.substractBrewIngredients()
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
                        text: qsTr("Rezept")
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        GridLayout {
                            columns: 2
                            LabelPrim {
                                Layout.preferredWidth: 100
                                text: qsTr("Sudname")
                            }
                            TextField {
                                Layout.fillWidth: true
                                enabled: !page.readOnly
                                placeholderText: qsTr("Sudname")
                                text: Brauhelfer.sud.Sudname
                                onTextChanged: if (activeFocus) Brauhelfer.sud.Sudname = text
                            }
                            LabelPrim {
                                text: qsTr("Erstellt")
                            }
                            LabelDate {
                                date: Brauhelfer.sud.Erstellt
                            }
                            LabelPrim {
                                text: qsTr("Brauanlage")
                            }
                            LabelPrim {
                                text: Brauhelfer.sud.AuswahlBrauanlageName
                            }
                        }
                        HorizontalDivider { }
                        GridLayout {
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Biermenge")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.Menge
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Stammwürze")
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.SW
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°P")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Bittere")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: Brauhelfer.sud.IBU
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("IBU")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Farbe")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: Brauhelfer.sud.erg_Farbe
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("EBC")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("CO2")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.CO2
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("g/Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("Restalkalität")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                precision: 2
                                value: Brauhelfer.sud.RestalkalitaetSoll
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("°dH")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                text: qsTr("High Gravity Faktor")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                precision: 0
                                value: Brauhelfer.sud.highGravityFaktor
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                text: qsTr("%")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Reifezeit")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: Brauhelfer.sud.Reifezeit
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Wochen")
                            }
                        }
                        HorizontalDivider { }
                        RowLayout {
                            LabelPrim {
                                Layout.preferredWidth: 100
                                text: qsTr("Bemerkung")
                            }
                            TextArea {
                                Layout.fillWidth: true
                                opacity: {
                                    if (enabled)
                                        Material.theme === Material.Dark ? 1.00 : 0.87
                                    else
                                        Material.theme === Material.Dark ? 0.50 : 0.38
                                }
                                wrapMode: TextArea.Wrap
                                placeholderText: qsTr("Bemerkung")
                                text: Brauhelfer.sud.Kommentar
                                onTextChanged: if (activeFocus) Brauhelfer.sud.Kommentar = text
                            }
                        }
                    }
                }

                GroupBox {
                    property alias name: label1.text
                    id: group1
                    Layout.fillWidth: true
                    label: LabelSubheader {
                        id: label1
                        text: qsTr("Vorbereitung")
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Hauptguss")
                        }
                        GridLayout {
                            columns: 3
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Faktor")
                            }
                            TextFieldNumber {
                                Layout.preferredWidth: 60
                                enabled: !page.readOnly
                                min: 1.0
                                max: 10.0
                                value: Brauhelfer.sud.FaktorHauptguss
                                onNewValue: Brauhelfer.sud.FaktorHauptguss = value
                            }
                            Item {
                                Layout.preferredWidth: 70
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Faktor Empfehlung")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.FaktorHauptgussEmpfehlung
                            }
                            Item {
                                Layout.preferredWidth: 70
                            }

                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Menge")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.erg_WHauptguss
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("Michlsäure 80%")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                precision: 2
                                value: Brauhelfer.sud.RestalkalitaetFaktor * Brauhelfer.sud.erg_WHauptguss
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("ml")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Temperatur")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: Brauhelfer.sud.EinmaischenTemp
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°C")
                            }
                        }
                        HorizontalDivider { }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Malz schroten")
                        }
                        Repeater {
                            model:Brauhelfer.sud.modelMalzschuettung
                            delegate: RowLayout{
                                Layout.leftMargin: 8
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 60
                                    precision: 2
                                    value: model.erg_Menge
                                }
                                LabelPrim {
                                    Layout.preferredWidth: 70
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
                            LabelNumber {
                                Layout.preferredWidth: 60
                                font.bold: true
                                precision: 2
                                value: Brauhelfer.sud.erg_S_Gesammt
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("kg")
                            }
                        }
                    }
                }

                GroupBox {
                    property alias name: label2.text
                    id: group2
                    Layout.fillWidth: true
                    label: LabelSubheader {
                        id: label2
                        text: qsTr("Maischen")
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        RowLayout{
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Einmaischen")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: Brauhelfer.sud.EinmaischenTemp
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°C")
                            }
                        }
                        HorizontalDivider {
                            visible: repeaterModelWeitereZutatenGabenMaischen.count > 0
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: repeaterModelWeitereZutatenGabenMaischen.count > 0
                            text: qsTr("Weitere Zutaten")
                        }
                        Repeater {
                            id: repeaterModelWeitereZutatenGabenMaischen
                            model: SortFilterProxyModel {
                                sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                                filterKeyColumn: sourceModel.fieldIndex("Zeitpunkt")
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
                                        Layout.preferredWidth: 60
                                        precision: 2
                                        value: model.Einheit === 0 ? model.erg_Menge/1000 : model.erg_Menge
                                    }
                                    LabelPrim {
                                        Layout.preferredWidth: 70
                                        text: model.Einheit === 0 ? qsTr("kg") : qsTr("g")
                                    }
                                }
                                LabelPrim {
                                    Layout.leftMargin: 8
                                    visible: model.Bemerkung !== ""
                                    text: model.Bemerkung
                                }
                            }
                        }
                        HorizontalDivider { }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Rasten")
                        }
                        Repeater {
                            model: Brauhelfer.sud.modelRasten
                            delegate: RowLayout{
                                Layout.leftMargin: 8
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.RastName
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 40
                                    precision: 0
                                    value: model.RastTemp
                                }
                                LabelPrim {
                                    Layout.preferredWidth: 30
                                    text: qsTr("°C")
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 40
                                    precision: 0
                                    value: model.RastDauer
                                }
                                LabelPrim {
                                    Layout.preferredWidth: 30
                                    text: qsTr("min")
                                }
                            }
                        }
                        HorizontalDivider { }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Jodprobe")
                        }
                        GridLayout {
                            Layout.leftMargin: 8
                            columns: 2
                            LabelPrim {
                                text: qsTr("Lila bis schwarz")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("reichlich unvergärbare Stärke")
                            }
                            LabelPrim {
                                text: qsTr("Rot bis braun")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("kaum noch unvergärbare Stärke")
                            }
                            LabelPrim {
                                text: qsTr("Gelb bis hellorange")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("fertig (jodnormal)")
                            }
                        }
                    }
                }

                GroupBox {
                    property alias name: label3.text
                    id: group3
                    Layout.fillWidth: true
                    label: LabelSubheader {
                        id: label3
                        text: qsTr("Läutern")
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Nachguss")
                        }
                        GridLayout {
                            columns: 3
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Menge")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.erg_WNachguss
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("Michlsäure 80%")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                precision: 2
                                value: Brauhelfer.sud.RestalkalitaetFaktor * Brauhelfer.sud.erg_WNachguss
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("ml")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Temperatur")
                            }

                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: 78
                            }

                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°C")
                            }
                        }
                        HorizontalDivider {
                            visible: repVWH.countVisible > 0
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: repVWH.countVisible > 0
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
                                    text: model.Name
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 60
                                    value: model.erg_Menge
                                }
                                LabelPrim {
                                    Layout.preferredWidth: 70
                                    text: qsTr("g")
                                }
                            }
                        }
                        HorizontalDivider { }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Zielwerte")
                        }
                        GridLayout {
                            columns: 3
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Würzemenge 100°C")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.calc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochbegin)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Stammwürze")
                            }
                            LabelPlato {
                                id: lblSwLaeutern
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.SWSollLautern
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°P")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.calc.platoToBrix(lblSwLaeutern.value)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°Brix")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                precision: 4
                                value: Brauhelfer.calc.platoToDichte(lblSwLaeutern.value)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("g/ml")
                            }
                        }
                    }
                }

                GroupBox {
                    property alias name: label4.text
                    id: group4
                    Layout.fillWidth: true
                    label: LabelSubheader {
                        id: label4
                        text: qsTr("Würzekochen")
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Hopfen")
                        }
                        Repeater {
                            model:Brauhelfer.sud.modelHopfengaben
                            delegate: RowLayout {
                                Layout.leftMargin: 8
                                visible: !model.Vorderwuerze
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.Name
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 40
                                    value: model.erg_Menge
                                }
                                LabelPrim {
                                    Layout.preferredWidth: 30
                                    text: qsTr("g")
                                }
                                LabelNumber {
                                    Layout.preferredWidth: 40
                                    precision: 0
                                    value: model.Zeit
                                }
                                LabelPrim {
                                    Layout.preferredWidth: 30
                                    text: qsTr("min")
                                }
                            }
                        }
                        HorizontalDivider {
                            visible: repeaterModelWeitereZutatenGabenKochen.count > 0
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: repeaterModelWeitereZutatenGabenKochen.count > 0
                            text: qsTr("Weitere Zutaten")
                        }
                        Repeater {
                            id: repeaterModelWeitereZutatenGabenKochen
                            model: SortFilterProxyModel {
                                sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                                filterKeyColumn: sourceModel.fieldIndex("Zeitpunkt")
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
                                        value: model.Einheit === 0 ? model.erg_Menge/1000 : model.erg_Menge
                                    }
                                    LabelPrim {
                                        Layout.preferredWidth: 30
                                        text: model.Einheit === 0 ? qsTr("kg") : qsTr("g")
                                    }
                                    LabelNumber {
                                        Layout.preferredWidth: 40
                                        precision: 0
                                        value: model.Typ === 0 || model.Typ === 1 ? Brauhelfer.sud.KochdauerNachBitterhopfung : model.Zugabedauer
                                    }
                                    LabelPrim {
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
                        HorizontalDivider { }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Kochbegin")
                        }
                        GridLayout {
                            Layout.leftMargin: 8
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Zielstammwürze")
                            }
                            LabelPlato {
                                id: lblSWSollKochbegin
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.SWSollKochbegin
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°P")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.calc.platoToBrix(lblSWSollKochbegin.value)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°Brix")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                precision: 4
                                value: Brauhelfer.calc.platoToDichte(lblSWSollKochbegin.value)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("g/ml")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Zielmenge bei 100°C")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.calc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochbegin)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Zielmenge bei 20°C")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.MengeSollKochbegin
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Menge bei 20°C")
                            }
                            TextFieldVolume {
                                Layout.preferredWidth: 60
                                enabled: !page.readOnly
                                useDialog: true
                                value: Brauhelfer.sud.WuerzemengeVorHopfenseihen
                                onNewValue: {
                                    Brauhelfer.sud.WuerzemengeVorHopfenseihen = value
                                    tfWuerzemengeKochende.setValue(value)
                                }
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                        }
                        HorizontalDivider { }
                        RowLayout{
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Kochdauer")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: Brauhelfer.sud.KochdauerNachBitterhopfung
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("min")
                            }
                        }
                        RowLayout {
                            visible: Brauhelfer.sud.Nachisomerisierungszeit > 0.0
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Nachisomerisierung")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: Brauhelfer.sud.Nachisomerisierungszeit
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("min")
                            }
                        }
                        HorizontalDivider { }
                        LabelPrim {
                            Layout.fillWidth: true
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
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.SWSollKochende
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°P")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.calc.platoToBrix(lblSWSollKochende.value)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°Brix")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                precision: 4
                                value: Brauhelfer.calc.platoToDichte(lblSWSollKochende.value)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("g/ml")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Stammwürze")
                            }
                            TextFieldPlato {
                                Layout.preferredWidth: 60
                                enabled: !page.readOnly
                                useDialog: true
                                value: Brauhelfer.sud.SWKochende
                                onNewValue: {
                                    Brauhelfer.sud.SWKochende = value
                                    Brauhelfer.sud.SWAnstellen = value
                                }
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°P")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Zielmenge bei 100°C")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.calc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochende)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Zielmenge bei 20°C")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.MengeSollKochende
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Menge bei 20°C")
                            }
                            TextFieldVolume {
                                id: tfWuerzemengeKochende
                                Layout.preferredWidth: 60
                                enabled: !page.readOnly
                                useDialog: true
                                max: Brauhelfer.sud.WuerzemengeVorHopfenseihen
                                value: Brauhelfer.sud.WuerzemengeKochende
                                onNewValue: setValue(value)
                                function setValue(value) {
                                    Brauhelfer.sud.WuerzemengeKochende = value
                                    tfWuerzemenge.setValue(Brauhelfer.sud.WuerzemengeKochende * (1 + Brauhelfer.sud.highGravityFaktor/100))
                                }
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                        }
                        HorizontalDivider { }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Verdampfungsziffer")
                        }
                        GridLayout {
                            Layout.leftMargin: 8
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Sud")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.calc.verdampfungsziffer(
                                           Brauhelfer.sud.WuerzemengeVorHopfenseihen,
                                           Brauhelfer.sud.WuerzemengeKochende,
                                           Brauhelfer.sud.KochdauerNachBitterhopfung)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("%")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Anlage")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.Verdampfungsziffer
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("%")
                            }
                        }
                        HorizontalDivider { }
                        GridLayout {
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Sudhausausbeute")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.erg_Sudhausausbeute
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("%")
                            }
                        }
                    }
                }

                GroupBox {
                    property alias name: label5.text
                    id: group5
                    Layout.fillWidth: true
                    label: LabelSubheader {
                        id: label5
                        text: qsTr("Anstellen")
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        LabelPrim {
                            Layout.fillWidth: true
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
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.SWSollAnstellen
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°P")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.calc.platoToBrix(lblSWSollAnstellen.value)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°Brix")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                precision: 4
                                value: Brauhelfer.calc.platoToDichte(lblSWSollAnstellen.value)
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("g/ml")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Kochende")
                            }
                            LabelPlato {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.SWKochende
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°P")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                text: qsTr("High Gravity Verschneidung")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                value: Brauhelfer.sud.Menge - Brauhelfer.sud.MengeSollKochende
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Wasserverschneidung")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.calc.verschneidung(Brauhelfer.sud.SWAnstellen,
                                                                     Brauhelfer.sud.SWSollAnstellen,
                                                                     Brauhelfer.sud.WuerzemengeKochende * (1 + Brauhelfer.sud.highGravityFaktor/100))
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Stammwürze")
                            }
                            TextFieldPlato {
                                Layout.preferredWidth: 60
                                enabled: !page.readOnly
                                useDialog: true
                                value: Brauhelfer.sud.SWAnstellen
                                onNewValue: Brauhelfer.sud.SWAnstellen = value
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°P")
                            }
                        }
                        HorizontalDivider { }
                        LabelPrim {
                            Layout.fillWidth: true
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
                                Layout.preferredWidth: 60
                                enabled: !page.readOnly
                                value: 0
                                onNewValue: setValue(value)
                                function setValue(value) {
                                    var factor = Brauhelfer.calc.speise(Brauhelfer.sud.CO2, Brauhelfer.sud.SWAnstellen, 3.0, 3.0, 20.0)
                                    this.value = value
                                    tfSpeise.value = factor * value / (factor + 1)
                                    Brauhelfer.sud.WuerzemengeAnstellen = value - tfSpeise.value
                                }
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Benötigte Speisemenge geschätzt (SRE 3°P, 20°C)")
                            }
                            LabelNumber {
                                id: tfSpeise
                                Layout.preferredWidth: 60
                                value: 0
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Anstellmenge")
                            }
                            TextFieldVolume {
                                Layout.preferredWidth: 60
                                enabled: !page.readOnly
                                value: Brauhelfer.sud.WuerzemengeAnstellen
                                onNewValue: {
                                    var factor = Brauhelfer.calc.speise(Brauhelfer.sud.CO2, Brauhelfer.sud.SWAnstellen, 3.0, 3.0, 20.0)
                                    Brauhelfer.sud.WuerzemengeAnstellen = value
                                    Brauhelfer.sud.JungbiermengeAbfuellen = value
                                    tfSpeise.value = factor * value
                                    tfWuerzemenge.value = value + tfSpeise.value
                                }
                                Component.onCompleted: {
                                    var factor = Brauhelfer.calc.speise(Brauhelfer.sud.CO2, Brauhelfer.sud.SWAnstellen, 3.0, 3.0, 20.0)
                                    tfSpeise.value = factor * value
                                    tfWuerzemenge.value = value + tfSpeise.value
                                }
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("Liter")
                            }
                        }
                        HorizontalDivider { }
                        RowLayout {
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Effektive Sudhausausbeute")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                value: Brauhelfer.sud.erg_EffektiveAusbeute
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("%")
                            }
                        }
                        HorizontalDivider { }
                        RowLayout {
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Temperatur")
                            }
                            TextFieldTemperature {
                                id: tfTemperature
                                Layout.preferredWidth: 60
                                enabled: !page.readOnly
                                value: 20.0
                                onNewValue: this.value = value
                            }
                            LabelPrim {
                                Layout.preferredWidth: 70
                                text: qsTr("°C")
                            }
                        }
                    }
                }
                GroupBox {
                    property alias name: label6.text
                    id: group6
                    Layout.fillWidth: true
                    label: LabelSubheader {
                        id: label6
                        text: qsTr("Gärung")
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: Brauhelfer.sud.AuswahlHefe !== ""
                            text: qsTr("Hefe")
                        }
                        RowLayout {
                            Layout.leftMargin: 8
                            visible: Brauhelfer.sud.AuswahlHefe !== ""
                            LabelPrim {
                                Layout.fillWidth: true
                                text: Brauhelfer.sud.AuswahlHefe
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: Brauhelfer.sud.HefeAnzahlEinheiten
                            }
                            Item {
                                Layout.preferredWidth: 70
                            }
                        }
                        HorizontalDivider {
                            visible: Brauhelfer.sud.AuswahlHefe !== "" && repeaterModelWeitereZutatenGabenGaerung.count > 0
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: repeaterModelWeitereZutatenGabenGaerung.count > 0
                            text: qsTr("Weitere Zutaten")
                        }
                        Repeater {
                            id: repeaterModelWeitereZutatenGabenGaerung
                            model: SortFilterProxyModel {
                                sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                                filterKeyColumn: sourceModel.fieldIndex("Zeitpunkt")
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
                                        value: model.Einheit === 0 ? model.erg_Menge/1000 : model.erg_Menge
                                    }
                                    LabelPrim {
                                        Layout.preferredWidth: 30
                                        text: model.Einheit === 0 ? qsTr("kg") : qsTr("g")
                                    }
                                    LabelNumber {
                                        Layout.preferredWidth: 40
                                        precision: 0
                                        value: model.Zugabedauer/ 1440
                                    }
                                    LabelPrim {
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
                    property alias name: label7.text
                    id: group7
                    Layout.fillWidth: true
                    label: LabelSubheader {
                        id: label7
                        text: qsTr("Abschluss")
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        GridLayout {
                            columns: 2
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Braudatum")
                            }
                            TextFieldDate {
                                enabled: !page.readOnly
                                date: Brauhelfer.sud.BierWurdeGebraut ? Brauhelfer.sud.Braudatum : new Date()
                                onNewDate: {
                                    this.date = date
                                    Brauhelfer.sud.Braudatum = date
                                    tfAnstelldatum.date = date
                                    Brauhelfer.sud.Anstelldatum = date
                                }
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Anstelldatum")
                            }
                            TextFieldDate {
                                id: tfAnstelldatum
                                enabled: !page.readOnly
                                date: Brauhelfer.sud.BierWurdeGebraut ? Brauhelfer.sud.Anstelldatum : new Date()
                                onNewDate: {
                                    this.date = date
                                    Brauhelfer.sud.Anstelldatum = date
                                }
                            }
                        }
                        GridLayout {
                            columns: 3
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
                        }
                        CheckBox {
                            Layout.fillWidth: true
                            enabled: !page.readOnly
                            text: qsTr("Ausbeute für Durchschnitt nicht einbeziehen")
                            checked: Brauhelfer.sud.AusbeuteIgnorieren
                            onClicked: Brauhelfer.sud.AusbeuteIgnorieren = checked
                        }
                        Button {
                            Layout.fillWidth: true
                            text: qsTr("Sud gebraut")
                            enabled: !page.readOnly
                            onClicked: flickable.gebraut()
                        }
                    }
                }
            }
        }
    }
}
