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

    ColumnLayout {
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

        HorizontalDivider {
            Layout.fillWidth: true
        }

        Flickable {
            id: flickable
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            contentHeight: layout.height
            boundsBehavior: Flickable.OvershootBounds
            onMovementStarted: forceActiveFocus()
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
                Brauhelfer.sud.Braudatum = tfBraudatum.date
                Brauhelfer.sud.Anstelldatum = tfAnstelldatum.date
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
                        TextFieldBase {
                            Layout.fillWidth: true
                            enabled: !Brauhelfer.readonly
                            placeholderText: qsTr("Sudname")
                            text: Brauhelfer.sud.Sudname
                            onTextChanged: if (activeFocus) Brauhelfer.sud.Sudname = text
                        }
                        RowLayout {
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Brauanlage")
                            }
                            LabelPrim {
                                Layout.preferredWidth: 80
                                horizontalAlignment: Text.AlignHCenter
                                text: Brauhelfer.sud.AuswahlBrauanlageName
                            }
                            Item {
                                Layout.preferredWidth: 60
                            }
                        }
                        HorizontalDivider {
                            Layout.fillWidth: true
                        }
                        GridLayout {
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Biermenge")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                value: Brauhelfer.sud.Menge
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Stammwürze")
                            }
                            LabelPlato {
                                Layout.preferredWidth: 80
                                value: Brauhelfer.sud.SW
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("°P")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Bittere")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                precision: 0
                                value: Brauhelfer.sud.IBU
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("IBU")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Farbe")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                precision: 0
                                value: Brauhelfer.sud.erg_Farbe
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("EBC")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("CO2")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                value: Brauhelfer.sud.CO2
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("g/l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("Restalkalität")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                precision: 2
                                value: Brauhelfer.sud.RestalkalitaetSoll
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("°dH")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                text: qsTr("High Gravity Faktor")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                precision: 0
                                value: Brauhelfer.sud.highGravityFaktor
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                text: qsTr("%")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Reifezeit")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                precision: 0
                                value: Brauhelfer.sud.Reifezeit
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("Wochen")
                            }
                        }
                        HorizontalDivider {
                            Layout.fillWidth: true
                        }
                        TextArea {
                            Layout.fillWidth: true
                            opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                            wrapMode: TextArea.Wrap
                            placeholderText: qsTr("Bemerkung")
                            text: Brauhelfer.sud.Kommentar
                            onTextChanged: if (activeFocus) Brauhelfer.sud.Kommentar = text
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
                            font.bold: true
                            text: qsTr("Hauptguss")
                        }
                        GridLayout {
                            columns: 3
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Faktor")
                            }
                            SpinBoxReal {
                                Layout.columnSpan: 2
                                Layout.preferredWidth: 140
                                enabled: !page.readOnly
                                decimals: 1
                                stepSize: 1
                                min: 1.0
                                max: 9.9
                                realValue: Brauhelfer.sud.FaktorHauptguss
                                onNewValue: Brauhelfer.sud.FaktorHauptguss = value
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Faktor Empfehlung")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                value: Brauhelfer.sud.FaktorHauptgussEmpfehlung
                            }
                            Item {
                                Layout.preferredWidth: 60
                            }

                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Menge")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                value: Brauhelfer.sud.erg_WHauptguss
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("Milchsäure 80%")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                precision: 2
                                value: Brauhelfer.sud.RestalkalitaetFaktor * Brauhelfer.sud.erg_WHauptguss
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("ml")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Temperatur")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                precision: 0
                                value: Brauhelfer.sud.EinmaischenTemp
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("°C")
                            }
                        }
                        HorizontalDivider {
                            Layout.fillWidth: true
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
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
                                    Layout.preferredWidth: 80
                                    precision: 2
                                    value: model.erg_Menge
                                }
                                LabelUnit {
                                    Layout.preferredWidth: 60
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
                                Layout.preferredWidth: 80
                                font.bold: true
                                precision: 2
                                value: Brauhelfer.sud.erg_S_Gesammt
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
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
                                font.bold: true
                                text: qsTr("Einmaischen")
                            }
                            TextFieldNumber {
                                Layout.preferredWidth: 40
                                enabled: !page.readOnly
                                precision: 0
                                value: Brauhelfer.sud.EinmaischenTemp
                                onNewValue: Brauhelfer.sud.EinmaischenTemp = value
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("°C")
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
                                        Layout.preferredWidth: 80
                                        precision: 2
                                        value: model.Einheit === 0 ? model.erg_Menge/1000 : model.erg_Menge
                                    }
                                    LabelUnit {
                                        Layout.preferredWidth: 60
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
                            delegate: RowLayout{
                                Layout.leftMargin: 8
                                LabelPrim {
                                    Layout.fillWidth: true
                                    text: model.RastName
                                }
                                TextFieldNumber {
                                    Layout.preferredWidth: 40
                                    enabled: !page.readOnly 
                                    precision: 0
                                    value: model.RastTemp
                                    onNewValue: model.RastTemp = value
                                }
                                LabelUnit {
                                    Layout.preferredWidth: 30
                                    text: qsTr("°C")
                                }
                                TextFieldNumber {
                                    Layout.preferredWidth: 40
                                    enabled: !page.readOnly
                                    precision: 0
                                    value: model.RastDauer
                                    onNewValue: model.RastDauer = value
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
                            font.bold: true
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
                                Layout.preferredWidth: 80
                                value: Brauhelfer.sud.erg_WNachguss
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("Milchsäure 80%")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                precision: 2
                                value: Brauhelfer.sud.RestalkalitaetFaktor * Brauhelfer.sud.erg_WNachguss
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                                text: qsTr("ml")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Temperatur")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                precision: 0
                                value: 78
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("°C")
                            }
                        }
                        HorizontalDivider {
                            Layout.fillWidth: true
                            visible: repVWH.countVisible > 0
                        }
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
                                    text: model.Name
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
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
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
                                Layout.preferredWidth: 80
                                value: Brauhelfer.calc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochbeginn)
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Stammwürze")
                            }
                            LabelPlato {
                                id: lblSwLaeutern
                                Layout.preferredWidth: 80
                                value: Brauhelfer.sud.SWSollLautern
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
                                value: Brauhelfer.calc.platoToBrix(lblSwLaeutern.value)
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
                                value: Brauhelfer.calc.platoToDichte(lblSwLaeutern.value)
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
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
                                value: Brauhelfer.calc.platoToBrix(lblSWSollKochbeginn.value)
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
                                value: Brauhelfer.calc.platoToDichte(lblSWSollKochbeginn.value)
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("g/ml")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Zielmenge bei 100°C")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                value: Brauhelfer.calc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochbeginn)
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
                                text: qsTr("Menge bei 20°C")
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
                        }
                        HorizontalDivider {
                            Layout.fillWidth: true
                        }
                        RowLayout{
                            LabelPrim {
                                Layout.fillWidth: true
                                font.bold: true
                                text: qsTr("Kochdauer")
                            }
                            TextFieldNumber {
                                property real tempValue: NaN
                                Layout.preferredWidth: 80
                                enabled: !page.readOnly
                                precision: 0
                                value: Brauhelfer.sud.KochdauerNachBitterhopfung
                                onNewValue: tempValue = value
                                onEditingFinished: Brauhelfer.sud.KochdauerNachBitterhopfung = tempValue
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
                                    LabelUnit {
                                        Layout.preferredWidth: 30
                                        text: model.Einheit === 0 ? qsTr("kg") : qsTr("g")
                                    }
                                    LabelNumber {
                                        Layout.preferredWidth: 40
                                        precision: 0
                                        value: model.Typ === 0 || model.Typ === 1 ? Brauhelfer.sud.KochdauerNachBitterhopfung : model.Zugabedauer
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
                                value: Brauhelfer.calc.platoToBrix(lblSWSollKochende.value)
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
                                value: Brauhelfer.calc.platoToDichte(lblSWSollKochende.value)
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
                                onNewValue: {
                                    Brauhelfer.sud.SWKochende = value
                                    Brauhelfer.sud.SWAnstellen = value
                                }
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
                                value: Brauhelfer.calc.volumenWasser(20.0, 100.0, Brauhelfer.sud.MengeSollKochende)
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
                                text: qsTr("Menge bei 20°C")
                            }
                            TextFieldVolume {
                                Layout.preferredWidth: 80
                                enabled: !page.readOnly
                                useDialog: true
                                max: Brauhelfer.sud.WuerzemengeVorHopfenseihen
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
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Verdampfung")
                        }
                        GridLayout {
                            Layout.leftMargin: 8
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Sud")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                value: Brauhelfer.calc.verdampfungsziffer(
                                           Brauhelfer.sud.WuerzemengeVorHopfenseihen,
                                           Brauhelfer.sud.WuerzemengeKochende,
                                           Brauhelfer.sud.KochdauerNachBitterhopfung)
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("%")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Anlage")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 80
                                value: Brauhelfer.sud.Verdampfungsziffer
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("%")
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
                                value: Brauhelfer.calc.platoToBrix(lblSWSollAnstellen.value)
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
                                value: Brauhelfer.calc.platoToDichte(lblSWSollAnstellen.value)
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("g/ml")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                visible: Brauhelfer.sud.highGravityFaktor > 0.0
                                text: qsTr("High Gravity Verschneidung")
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
                                value: Brauhelfer.calc.verschneidung(Brauhelfer.sud.SWAnstellen,
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
                                value: Brauhelfer.calc.speise(Brauhelfer.sud.CO2, Brauhelfer.sud.SWAnstellen, 3.0, 3.0, 20.0) * Brauhelfer.sud.WuerzemengeAnstellen
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
                                max: tfWuerzemenge.value
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
                        RowLayout {
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
                            font.bold: true
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
                                Layout.preferredWidth: 80
                                precision: 0
                                value: Brauhelfer.sud.HefeAnzahlEinheiten
                            }
                        }
                        HorizontalDivider {
                            Layout.fillWidth: true
                            visible: Brauhelfer.sud.AuswahlHefe !== "" && repeaterModelWeitereZutatenGabenGaerung.count > 0
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            visible: repeaterModelWeitereZutatenGabenGaerung.count > 0
                            font.bold: true
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
                                    LabelUnit {
                                        Layout.preferredWidth: 30
                                        text: model.Einheit === 0 ? qsTr("kg") : qsTr("g")
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
                    property alias name: label7.text
                    id: group7
                    Layout.fillWidth: true
                    label: LabelSubheader {
                        id: label7
                        text: qsTr("Abschluss")
                    }
                    GridLayout {
                        anchors.fill: parent
                        columns: 3
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Braudatum")
                        }
                        TextFieldDate {
                            id: tfBraudatum
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            enabled: !page.readOnly
                            date: Brauhelfer.sud.BierWurdeGebraut ? Brauhelfer.sud.Braudatum : new Date()
                            onNewDate: {
                                this.date = date
                                tfAnstelldatum.date = date
                            }
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            text: qsTr("Anstelldatum")
                        }
                        TextFieldDate {
                            id: tfAnstelldatum
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            enabled: !page.readOnly
                            date: Brauhelfer.sud.BierWurdeGebraut ? Brauhelfer.sud.Anstelldatum : new Date()
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
                            onClicked: flickable.gebraut()
                        }
                    }
                }
            }
        }
    }
}
