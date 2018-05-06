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
    title: qsTr("Info")
    icon: "ic_info_outline.png"
    enabled: Brauhelfer.sud.loaded
    readOnly: Brauhelfer.readonly || !app.brewForceEditable

    component: Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentHeight: layout.height
        boundsBehavior: Flickable.OvershootBounds
        ScrollIndicator.vertical: ScrollIndicator {}
        ColumnLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: Brauhelfer.sud.Sudname
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Gespeichert")
                    }
                    LabelDateTime {
                        date: Brauhelfer.sud.Gespeichert
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Erstellt")
                    }
                    LabelDate {
                        date: Brauhelfer.sud.Erstellt
                    }
                    Switch {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        enabled: !page.readOnly
                        text: qsTr("Gebraut")
                        checked: Brauhelfer.sud.BierWurdeGebraut
                        onClicked: Brauhelfer.sud.BierWurdeGebraut = checked
                    }
                    LabelDate {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        date: Brauhelfer.sud.Braudatum
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        Layout.fillWidth: true
                        text: qsTr("Angestellt")
                    }
                    LabelDate {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        date: Brauhelfer.sud.Anstelldatum
                    }
                    Switch {
                        visible: Brauhelfer.sud.BierWurdeAbgefuellt
                        enabled: !page.readOnly
                        text: qsTr("Abgefüllt")
                        checked: Brauhelfer.sud.BierWurdeAbgefuellt
                        onClicked: Brauhelfer.sud.BierWurdeAbgefuellt = checked
                    }
                    LabelDate {
                        visible: Brauhelfer.sud.BierWurdeAbgefuellt
                        date: Brauhelfer.sud.Abfuelldatum
                    }
                    Switch {
                        visible: Brauhelfer.sud.BierWurdeAbgefuellt
                        text: qsTr("Verbraucht")
                        checked: Brauhelfer.sud.BierWurdeVerbraucht
                        onClicked: Brauhelfer.sud.BierWurdeVerbraucht = checked
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: Brauhelfer.sud.BierWurdeGebraut ? qsTr("Zusammenfassung") : qsTr("Rezept")
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Status")
                    }
                    LabelPrim {
                        Layout.columnSpan: 2
                        text: {
                            if (!Brauhelfer.sud.BierWurdeGebraut)
                                return qsTr("nicht gebraut")
                            if (Brauhelfer.sud.BierWurdeVerbraucht)
                                return qsTr("verbraucht")
                            if (!Brauhelfer.sud.BierWurdeAbgefuellt)
                                return qsTr("nicht abgefüllt")
                            var tage = Brauhelfer.sud.ReifezeitDelta
                            if (tage > 0)
                                return qsTr("reif in") + " " + tage + " " + qsTr("Tage")
                            else
                                return qsTr("reif seit") + " " + (-tage) + " " + qsTr("Tage")
                        }
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Anlage")
                    }
                    LabelPrim {
                        Layout.columnSpan: 2
                        text: Brauhelfer.sud.AuswahlBrauanlageName
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Menge")
                    }
                    LabelNumber {
                        precision: 1
                        value: Brauhelfer.sud.BierWurdeGebraut ? Brauhelfer.sud.erg_AbgefuellteBiermenge : Brauhelfer.sud.Menge
                    }
                    LabelUnit {
                        text: qsTr("Liter")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Stammwürze")
                    }
                    LabelPlato {
                        value: Brauhelfer.sud.BierWurdeGebraut ? Brauhelfer.sud.SWIst : Brauhelfer.sud.SW
                    }
                    LabelUnit {
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        Layout.fillWidth: true
                        text: qsTr("Restextrakt")
                    }
                    LabelPlato {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        value: Brauhelfer.sud.SREIst
                    }
                    LabelUnit {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        Layout.fillWidth: true
                        text: qsTr("Vergärungsgrad (scheinbar)")
                    }
                    LabelNumber {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        value: Brauhelfer.calc.vergaerungsgrad(Brauhelfer.sud.SWIst, Brauhelfer.sud.SREIst)
                    }
                    LabelUnit {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        text: qsTr("%")
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        Layout.fillWidth: true
                        text: qsTr("Alkohol")
                    }
                    LabelNumber {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        precision: 1
                        value: Brauhelfer.sud.erg_Alkohol
                    }
                    LabelUnit {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        text: qsTr("%")
                    }
                    LabelPrim {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        Layout.fillWidth: true
                        text: qsTr("Ausbeute")
                    }
                    LabelNumber {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        value: Brauhelfer.sud.erg_EffektiveAusbeute
                    }
                    LabelUnit {
                        visible: Brauhelfer.sud.BierWurdeGebraut
                        text: qsTr("%")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Bittere")
                    }
                    LabelNumber {
                        precision: 0
                        value: Brauhelfer.sud.IBU
                    }
                    LabelUnit {
                        text: qsTr("IBU")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Farbe")
                    }
                    LabelNumber {
                        precision: 0
                        value: Brauhelfer.sud.erg_Farbe
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
                        visible: Brauhelfer.sud.RestalkalitaetSoll > 0.0
                        precision: 2
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
                        precision: 1
                        value: Brauhelfer.sud.BierWurdeGebraut ? Brauhelfer.sud.CO2Ist : Brauhelfer.sud.CO2
                    }
                    LabelUnit {
                        text: qsTr("g/Liter")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Preis")
                    }
                    LabelNumber {
                        precision: 2
                        value: Brauhelfer.sud.erg_Preis
                    }
                    LabelUnit {
                        text: Qt.locale().currencySymbol() + "/" + qsTr("Liter")
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
                        delegate: RowLayout{
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
                    text: qsTr("Hopen")
                }
                ColumnLayout {
                    anchors.fill: parent
                    Repeater {
                        id: repeaterHopfen
                        model:Brauhelfer.sud.modelHopfengaben
                        delegate: RowLayout{
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
                                precision: 2
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
                        model:Brauhelfer.sud.modelWeitereZutatenGaben
                        delegate: RowLayout{
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            LabelPrim {
                                Layout.preferredWidth: 80
                                text: {
                                    switch (model.Zeitpunkt)
                                    {
                                    case 0: qsTr("Gärung"); break;
                                    case 1: qsTr("Kochen"); break;
                                    case 2: qsTr("Maischen"); break;
                                    }
                                }
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 2
                                value: model.Einheit === 0 ? model.erg_Menge/1000 : model.erg_Menge
                            }
                            LabelUnit {
                                text: model.Einheit === 0 ? qsTr("kg") : qsTr("g")
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: Brauhelfer.sud.AuswahlHefe !== ""
                label: LabelSubheader {
                    text: qsTr("Hefe")
                }
                ColumnLayout {
                    anchors.fill: parent
                    RowLayout {
                        Layout.leftMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            text: Brauhelfer.sud.AuswahlHefe
                        }
                        LabelNumber {
                            Layout.preferredWidth: 60
                            precision: 0
                            value: Brauhelfer.sud.HefeAnzahlEinheiten
                        }
                    }
                }
            }
        }
    }
}
