import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Sudinfo")
    icon: "ic_info_outline.png"
    enabled: Brauhelfer.sud.isLoaded
    readOnly: Brauhelfer.readonly

    Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentHeight: layout.height
        boundsBehavior: Flickable.OvershootBounds
        onMovementStarted: forceActiveFocus()
        ScrollIndicator.vertical: ScrollIndicator { }
        ColumnLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: qsTr("Info")
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    TextFieldBase {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        enabled: !page.readOnly
                        placeholderText: qsTr("Sudname")
                        text: Brauhelfer.sud.Sudname
                        onTextChanged: if (activeFocus) Brauhelfer.sud.Sudname = text
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Sudnummer")
                    }
                    SpinBoxReal {
                        enabled: !page.readOnly
                        decimals: 0
                        realValue: Brauhelfer.sud.Sudnummer
                        onNewValue: Brauhelfer.sud.Sudnummer = value
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Status")
                    }
                    LabelPrim {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            switch (Brauhelfer.sud.Status) {
                            case Brauhelfer.Rezept:
                                return qsTr("nicht gebraut")
                            case Brauhelfer.Gebraut:
                                return qsTr("nicht abgefüllt")
                            case Brauhelfer.Abgefuellt:
                                var tage = Brauhelfer.sud.ReifezeitDelta
                                if (tage > 0)
                                    return qsTr("reif in") + " " + tage + " " + qsTr("Tage")
                                else
                                    return qsTr("reif seit") + " " + Math.floor(-tage / 7) + " " + qsTr("Wochen")
                            case Brauhelfer.Verbraucht:
                                return qsTr("verbraucht")
                            }
                        }
                    }
                    Switch {
                        enabled: !page.readOnly && app.brewForceEditable
                        text: qsTr("Gebraut")
                        checked: Brauhelfer.sud.Status >= Brauhelfer.Gebraut
                        onClicked: Brauhelfer.sud.Status = checked ? Brauhelfer.Gebraut : Brauhelfer.Rezept
                    }
                    LabelDate {
                        Layout.alignment: Qt.AlignHCenter
                        date: Brauhelfer.sud.Braudatum
                    }
                    Switch {
                        enabled: !page.readOnly && app.brewForceEditable
                        text: qsTr("Abgefüllt")
                        checked: Brauhelfer.sud.Status >= Brauhelfer.Abgefuellt
                        onClicked: Brauhelfer.sud.Status = checked ? Brauhelfer.Abgefuellt : Brauhelfer.Gebraut
                    }
                    LabelDate {
                        Layout.alignment: Qt.AlignHCenter
                        date: Brauhelfer.sud.Abfuelldatum
                    }
                    Switch {
                        enabled: !page.readOnly && (Brauhelfer.sud.Status >= Brauhelfer.Abgefuellt || app.brewForceEditable)
                        text: qsTr("Verbraucht")
                        checked: Brauhelfer.sud.Status >= Brauhelfer.Verbraucht
                        onClicked: Brauhelfer.sud.Status = checked ? Brauhelfer.Verbraucht : Brauhelfer.Abgefuellt
                    }
                    Text {
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Erstellt")
                    }
                    LabelDate {
                        Layout.alignment: Qt.AlignHCenter
                        date: Brauhelfer.sud.Erstellt
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Gespeichert")
                    }
                    LabelDateTime {
                        Layout.alignment: Qt.AlignHCenter
                        date: Brauhelfer.sud.Gespeichert
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: Brauhelfer.sud.Status === Brauhelfer.Rezept ? qsTr("Rezept") : qsTr("Zusammenfassung")
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 4
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Anlage")
                    }
                    LabelPrim {
                        Layout.columnSpan: 3
                        text: Brauhelfer.sud.Anlage
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Wasserprofil")
                    }
                    LabelPrim {
                        Layout.columnSpan: 3
                        text: Brauhelfer.sud.Wasserprofil
                    }
                    HorizontalDivider {
                        Layout.columnSpan: 4
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Menge")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        precision: 1
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.Menge : Brauhelfer.sud.MengeIst
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        opacity: app.config.textOpacityHalf
                        precision: 1
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.Menge
                    }
                    LabelUnit {
                        text: qsTr("l")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Stammwürze")
                    }
                    LabelPlato {
                        Layout.preferredWidth: 60
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.SW : Brauhelfer.sud.SWIst
                    }
                    LabelPlato {
                        Layout.preferredWidth: 60
                        opacity: app.config.textOpacityHalf
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.SW
                    }
                    LabelUnit {
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        Layout.fillWidth: true
                        text: qsTr("Restextrakt")
                    }
                    LabelPlato {
                        Layout.preferredWidth: 60
                        Layout.columnSpan: 2
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        value: Brauhelfer.sud.SREIst
                    }
                    LabelUnit {
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        Layout.fillWidth: true
                        text: qsTr("Vergärungsgrad (scheinbar)")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        Layout.columnSpan: 2
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        value: Brauhelfer.calc.vergaerungsgrad(Brauhelfer.sud.SWIst, Brauhelfer.sud.SREIst)
                    }
                    LabelUnit {
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        text: qsTr("%")
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        Layout.fillWidth: true
                        text: qsTr("Alkohol")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        Layout.columnSpan: 2
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        precision: 1
                        value: Brauhelfer.sud.erg_Alkohol
                    }
                    LabelUnit {
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        text: qsTr("%")
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        Layout.fillWidth: true
                        text: qsTr("Ausbeute")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        Layout.columnSpan: 2
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        value: Brauhelfer.sud.erg_EffektiveAusbeute
                    }
                    LabelUnit {
                        visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                        text: qsTr("%")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Bittere")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        precision: 0
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.IBU : Brauhelfer.sud.IbuIst
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        opacity: app.config.textOpacityHalf
                        precision: 0
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.IBU
                    }
                    LabelUnit {
                        text: qsTr("IBU")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Farbe")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        precision: 0
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.erg_Farbe : Brauhelfer.sud.FarbeIst
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        opacity: app.config.textOpacityHalf
                        precision: 0
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.erg_Farbe
                    }
                    LabelUnit {
                        text: qsTr("EBC")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                        text: qsTr("Restalkalität")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        Layout.columnSpan: 2
                        visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                        precision: 1
                        value: Brauhelfer.sud.RestalkalitaetSoll
                    }
                    LabelUnit {
                        visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                        text: qsTr("°dH")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("CO2")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        precision: 1
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.CO2 : Brauhelfer.sud.CO2Ist
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        opacity: app.config.textOpacityHalf
                        precision: 1
                        value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.CO2
                    }
                    LabelUnit {
                        text: qsTr("g/l")
                    }
                    HorizontalDivider {
                        Layout.columnSpan: 4
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Reifezeit")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        Layout.columnSpan: 2
                        precision: 0
                        value: Brauhelfer.sud.Reifezeit
                    }
                    LabelUnit {
                        text: qsTr("Wochen")
                    }
                    HorizontalDivider {
                        Layout.columnSpan: 4
                        Layout.fillWidth: true
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Preis")
                    }
                    LabelNumber {
                        Layout.preferredWidth: 60
                        Layout.columnSpan: 2
                        precision: 2
                        value: Brauhelfer.sud.erg_Preis
                    }
                    LabelUnit {
                        text: Qt.locale().currencySymbol() + "/" + qsTr("l")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: qsTr("Bemerkung")
                }
                TextArea {
                    anchors.fill: parent
                    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                    wrapMode: TextArea.Wrap
                    placeholderText: qsTr("Bemerkung")
                    text: Brauhelfer.sud.Kommentar
                    onTextChanged: if (activeFocus) Brauhelfer.sud.Kommentar = text
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: repeaterMalz.count > 0
                label: LabelSubheader {
                    text: qsTr("Malz")
                }
                ColumnLayout {
                    anchors.fill: parent
                    Repeater {
                        id: repeaterMalz
                        model: Brauhelfer.sud.modelMalzschuettung
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            Item {
                                Layout.preferredWidth: 80
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 2
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                text: qsTr("kg")
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: repeaterHopfen.count > 0
                label: LabelSubheader {
                    text: qsTr("Hopfen")
                }
                ColumnLayout {
                    anchors.fill: parent
                    Repeater {
                        id: repeaterHopfen
                        model: Brauhelfer.sud.modelHopfengaben
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            LabelPrim {
                                Layout.preferredWidth: 80
                                text: model.Vorderwuerze ? qsTr("VWH") : ""
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                text: qsTr("g")
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: repeaterWZutaten.count > 0
                label: LabelSubheader {
                    text: qsTr("Weitere Zutaten")
                }
                ColumnLayout {
                    anchors.fill: parent
                    Repeater {
                        id: repeaterWZutaten
                        model: Brauhelfer.sud.modelWeitereZutatenGaben
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            LabelPrim {
                                Layout.preferredWidth: 80
                                text: {
                                    switch (model.Zeitpunkt) {
                                    case 0:
                                        qsTr("Gärung")
                                        break
                                    case 1:
                                        qsTr("Kochen")
                                        break
                                    case 2:
                                        qsTr("Maischen")
                                        break
                                    }
                                }
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: model.Einheit === 0 ? 2 : 0
                                value: model.Einheit === 0 ? model.erg_Menge / 1000 : model.erg_Menge
                            }
                            LabelUnit {
                                text: switch(model.Einheit) {case 0: return qsTr("kg"); case 1: return qsTr("g"); case 2: return qsTr("mg"); case 3: return qsTr("Stk");}
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: repeaterHefe.count > 0
                label: LabelSubheader {
                    text: qsTr("Hefe")
                }
                ColumnLayout {
                    anchors.fill: parent
                    Repeater {
                        id: repeaterHefe
                        model: Brauhelfer.sud.modelHefegaben
                        delegate: RowLayout {
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 0
                                value: model.Menge
                            }
                        }
                    }
                }
            }
        }
    }
}
