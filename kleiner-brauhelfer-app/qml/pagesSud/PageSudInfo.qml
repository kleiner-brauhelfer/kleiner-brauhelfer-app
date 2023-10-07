import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import "../common"
import brauhelfer

PageBase {
    id: page
    title: qsTr("Sudinfo")
    icon: "ic_info_outline.png"
    enabled: Brauhelfer.sud.isLoaded
    readOnly: Brauhelfer.readonly || app.settings.readonly

    Flickable {
        anchors.fill: parent
        anchors.margins: 8
        clip: true
        contentHeight: layout.height + 8
        boundsBehavior: Flickable.OvershootBounds
        ScrollIndicator.vertical: ScrollIndicator { }
        MouseAreaCatcher {}
        ColumnLayout {
            id: layout
            spacing: 8
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8

            TextFieldBase {
                Layout.fillWidth: true
                enabled: !page.readOnly
                placeholderText: qsTr("Sudname")
                text: Brauhelfer.sud.Sudname
                onTextChanged: if (activeFocus) Brauhelfer.sud.Sudname = text
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Sudnummer")
                }
                SpinBoxReal {
                    Layout.fillWidth: true
                    enabled: !page.readOnly
                    decimals: 0
                    max: 9999
                    realValue: Brauhelfer.sud.Sudnummer
                    onNewValue: (value) => Brauhelfer.sud.Sudnummer = value
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Kategorie")
                }
                ComboBoxBase {
                    Layout.fillWidth: true
                    enabled: !page.readOnly
                    model: Brauhelfer.modelKategorien
                    textRole: "Name"
                    currentIndex: Qt.binding(findme)
                    onActivated: Brauhelfer.sud.Kategorie = currentText
                    Component.onCompleted: {
                        currentIndex = Qt.binding(function(){return find(Brauhelfer.sud.Kategorie)})
                    }
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Anlage")
                }
                LabelPrim {
                    text: Brauhelfer.sud.Anlage
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Status")
                }
                LabelPrim {
                    Layout.fillWidth: true
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
                SwitchBase {
                    Layout.fillWidth: true
                    enabled: !page.readOnly && app.brewForceEditable
                    text: qsTr("Gebraut")
                    checked: Brauhelfer.sud.Status >= Brauhelfer.Gebraut
                    onClicked: Brauhelfer.sud.Status = checked ? Brauhelfer.Gebraut : Brauhelfer.Rezept
                }
                LabelDate {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    date: Brauhelfer.sud.Braudatum
                }
                SwitchBase {
                    Layout.fillWidth: true
                    enabled: !page.readOnly && app.brewForceEditable
                    text: qsTr("Abgefüllt")
                    checked: Brauhelfer.sud.Status >= Brauhelfer.Abgefuellt
                    onClicked: Brauhelfer.sud.Status = checked ? Brauhelfer.Abgefuellt : Brauhelfer.Gebraut
                }
                LabelDate {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    date: Brauhelfer.sud.Abfuelldatum
                }
                SwitchBase {
                    Layout.fillWidth: true
                    enabled: !page.readOnly && (Brauhelfer.sud.Status >= Brauhelfer.Abgefuellt || app.brewForceEditable)
                    text: qsTr("Verbraucht")
                    checked: Brauhelfer.sud.Status >= Brauhelfer.Verbraucht
                    onClicked: Brauhelfer.sud.Status = checked ? Brauhelfer.Verbraucht : Brauhelfer.Abgefuellt
                }
                LabelPrim {
                    Layout.fillWidth: true
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Erstellt")
                }
                LabelDate {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    date: Brauhelfer.sud.Erstellt
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Gespeichert")
                }
                LabelDateTime {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    date: Brauhelfer.sud.Gespeichert
                }
                LabelPrim {
                    Layout.fillWidth: true
                    visible: Brauhelfer.sud.BewertungMittel > 0
                    text: qsTr("Bewertung")
                }
                Flow {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    visible: Brauhelfer.sud.BewertungMittel > 0
                    Image {
                        width: 16
                        height: 16
                        source: Brauhelfer.sud.BewertungMittel > 0 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                    Image {
                        width: 16
                        height: 16
                        source: Brauhelfer.sud.BewertungMittel > 1 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                    Image {
                        width: 16
                        height: 16
                        source: Brauhelfer.sud.BewertungMittel > 2 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                    Image {
                        width: 16
                        height: 16
                        source: Brauhelfer.sud.BewertungMittel > 3 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                    Image {
                        width: 16
                        height: 16
                        source: Brauhelfer.sud.BewertungMittel > 4 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                }
            }

            HorizontalDivider {
                Layout.columnSpan: 4
                Layout.fillWidth: true
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 4
                columnSpacing: 16

                LabelPrim {
                    Layout.fillWidth: true
                    visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                    text: " "
                }
                LabelPrim {
                    visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    text: qsTr("Sud")
                }
                LabelPrim {
                    visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    text: qsTr("Rezept")
                }
                LabelUnit {
                    visible: Brauhelfer.sud.Status !== Brauhelfer.Rezept
                    text: " "
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Menge")
                }
                LabelNumber {
                    precision: 1
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.Menge : Brauhelfer.sud.MengeIst
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 1
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.Menge
                }
                LabelUnit {
                    text: qsTr("L")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Stammwürze")
                }
                LabelPlato {
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.SW : Brauhelfer.sud.SWIst
                }
                LabelPlato {
                    opacity: app.config.textOpacityHalf
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.SW
                }
                LabelUnit {
                    text: qsTr("°P")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Sudhausausbeute")
                }
                LabelNumber {
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.Sudhausausbeute : Brauhelfer.sud.erg_EffektiveAusbeute
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.Sudhausausbeute
                }
                LabelUnit {
                    text: qsTr("%")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Vergärungsgrad")
                }
                LabelNumber {
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.Vergaerungsgrad : BierCalc.vergaerungsgrad(Brauhelfer.sud.SWIst, Brauhelfer.sud.SREIst)
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.Vergaerungsgrad
                }
                LabelUnit {
                    text: qsTr("%")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Restextrakt")
                }
                LabelPlato {
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? BierCalc.sreAusVergaerungsgrad(Brauhelfer.sud.SW, Brauhelfer.sud.Vergaerungsgrad) : Brauhelfer.sud.SREIst
                }
                LabelPlato {
                    opacity: app.config.textOpacityHalf
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : BierCalc.sreAusVergaerungsgrad(Brauhelfer.sud.SW, Brauhelfer.sud.Vergaerungsgrad)
                }
                LabelUnit {
                    text: qsTr("°P")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Alkoholgehalt")
                }
                LabelNumber {
                    precision: 1
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.AlkoholSoll : Brauhelfer.sud.erg_Alkohol
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.AlkoholSoll
                }
                LabelUnit {
                    text: qsTr("%vol")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Bittere")
                }
                LabelNumber {
                    precision: 0
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.IBU : Brauhelfer.sud.IbuIst
                }
                LabelNumber {
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
                    precision: 0
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.erg_Farbe : Brauhelfer.sud.FarbeIst
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.erg_Farbe
                }
                LabelUnit {
                    text: qsTr("EBC")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Karbonisierung (CO2)")
                }
                LabelNumber {
                    precision: 1
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.CO2 : Brauhelfer.sud.CO2Ist
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 1
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.CO2
                }
                LabelUnit {
                    text: qsTr("g/l")
                }

                LabelPrim {
                    visible: Brauhelfer.sud.RestalkalitaetSoll !== 0
                    Layout.fillWidth: true
                    text: qsTr("Restalkalität")
                }
                LabelNumber {
                    visible: Brauhelfer.sud.RestalkalitaetSoll !== 0
                    precision: 1
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ?  Brauhelfer.sud.RestalkalitaetSoll : Brauhelfer.sud.RestalkalitaetIst
                }
                LabelNumber {
                    visible: Brauhelfer.sud.RestalkalitaetSoll !== 0
                    opacity: app.config.textOpacityHalf
                    precision: 1
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.RestalkalitaetSoll
                }
                LabelUnit {
                    visible: Brauhelfer.sud.RestalkalitaetSoll !== 0
                    text: qsTr("°dH")
                }

                LabelPrim {
                    visible: tbPh.value > 0
                    Layout.fillWidth: true
                    text: qsTr("pH-Wert")
                }
                LabelNumber {
                    id: tbPh
                    visible: tbPh.value > 0
                    precision: 1
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ?  Brauhelfer.sud.PhMaischeSoll : Brauhelfer.sud.PhMaische
                }
                LabelNumber {
                    visible: tbPh.value > 0
                    opacity: app.config.textOpacityHalf
                    precision: 1
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.PhMaischeSoll
                }
                LabelUnit {
                    visible: tbPh.value > 0
                    text: ""
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Reifezeit")
                }
                LabelNumber {
                    precision: 0
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Brauhelfer.sud.Reifezeit : Number.NaN
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Brauhelfer.sud.Status === Brauhelfer.Rezept ? Number.NaN : Brauhelfer.sud.Reifezeit
                }
                LabelUnit {
                    text: qsTr("Wochen")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Gesamtkosten")
                }
                LabelNumber {
                    Layout.columnSpan: 2
                    precision: 2
                    value: Brauhelfer.sud.erg_Preis
                }
                LabelUnit {
                    text: Qt.locale().currencySymbol() + "/" + qsTr("L")
                }
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }

            TextAreaBase {
                Layout.fillWidth: true
                opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                wrapMode: TextArea.Wrap
                placeholderText: qsTr("Bemerkung Rezept")
                textFormat: Text.RichText
                text: Brauhelfer.sud.Kommentar
                onLinkActivated: (link) => Qt.openUrlExternally(link)
                onTextChanged: if (activeFocus) Brauhelfer.sud.Kommentar = text
            }
        }
    }
}
