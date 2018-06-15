import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0

PageBase {
    property real brixStart: 12.0
    property real brixEnd: 6.0

    id: page
    title: qsTr("Bieranalyse")
    icon: "ic_colorize.png"

    function takeValuesFromBrew() {
        var value = Brauhelfer.sud.SW
        if (Brauhelfer.sud.BierWurdeGebraut)
            value = Brauhelfer.sud.SWAnstellen
        brixStart = Brauhelfer.calc.platoToBrix(value)
        brixEnd = brixStart
    }

    component: Flickable {
        anchors.margins: 8
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        contentHeight: layout.height
        clip: true
        ScrollIndicator.vertical: ScrollIndicator {}

        ColumnLayout {
            id: layout
            spacing: 8
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            LabelSubheader {
                Layout.fillWidth: true
                horizontalAlignment: Label.AlignHCenter
                text: qsTr("Bieranalyse mit dem Refraktometer") 
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 20

                LabelPrim {
                    text: qsTr("Formel")
                }

                ComboBox {
                    id: cbFormel
                    Layout.columnSpan: 2
                    model: [ "Terrill", "Terrill Linear", "Standard" ]
                    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                    onCurrentIndexChanged: navPane.setFocus()
                }

                HorizontalDivider {
                    Layout.fillWidth: true
                    Layout.columnSpan: 3
                }

                LabelPrim {
                    text: qsTr("Vor der Vergärung")
                }

                TextFieldPlato {
                    id: tfVor
                    value: brixStart
                    onNewValue: this.value = value
                }

                LabelUnit {
                    Layout.fillWidth: true
                    text: qsTr("°Brix")
                }

                LabelPrim {
                    text: qsTr("Nach der Vergärung")
                }

                TextFieldPlato {
                    id: tfNach
                    value: brixEnd
                    onNewValue: this.value = value
                }

                LabelUnit {
                    text: qsTr("°Brix")
                }

                HorizontalDivider {
                    Layout.fillWidth: true
                    Layout.columnSpan: 3
                }

                LabelPrim {
                    text: qsTr("Stammwürze")
                }

                LabelPlato {
                    id: lblSW
                    Layout.alignment: Qt.AlignRight
                    value: Brauhelfer.calc.brixToPlato(tfVor.value)
                }

                LabelUnit {
                    text: qsTr("°P")
                }

                LabelPrim {
                    text: qsTr("Dichte")
                }

                LabelNumber {
                    id: lblDichte
                    Layout.alignment: Qt.AlignRight
                    precision: 4
                    value: Brauhelfer.calc.brixToDichte(lblSW.value, tfNach.value, cbFormel.currentIndex)
                }

                LabelUnit {
                    text: qsTr("g/ml")
                }

                LabelPrim {
                    text: qsTr("Restextrakt scheinbar")
                }

                LabelPlato {
                    id: lblSRE
                    Layout.alignment: Qt.AlignRight
                    value: Brauhelfer.calc.dichteToPlato(lblDichte.value)
                }

                LabelUnit {
                    text: qsTr("°P")
                }

                LabelPrim {
                    text: qsTr("Vergärungsgrad scheinbar")
                }

                LabelNumber {
                    id: lblSVG
                    Layout.alignment: Qt.AlignRight
                    value: Brauhelfer.calc.vergaerungsgrad(lblSW.value, lblSRE.value)
                }

                LabelUnit {
                    text: qsTr("%")
                }

                LabelPrim {
                    text: qsTr("Restextrakt wirklich")
                }

                LabelPlato {
                    id: lblTRE
                    Layout.alignment: Qt.AlignRight
                    value: Brauhelfer.calc.toTRE(lblSW.value, lblSRE.value)
                }

                LabelUnit {
                    text: qsTr("°P")
                }

                LabelPrim {
                    text: qsTr("Vergärungsgrad wirklich")
                }

                LabelNumber {
                    id: lblTVG
                    Layout.alignment: Qt.AlignRight
                    value: Brauhelfer.calc.vergaerungsgrad(lblSW.value, lblTRE.value)
                }

                LabelUnit {
                    text: qsTr("%")
                }

                LabelPrim {
                    text: qsTr("Alkohol")
                }

                LabelNumber {
                    id: lblAlcVol
                    Layout.alignment: Qt.AlignRight
                    value: Brauhelfer.calc.alkohol(lblSW.value, lblSRE.value)
                }

                LabelUnit {
                    text: qsTr("vol%")
                }
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }

            LabelPrim {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.italic: true
                text: qsTr("Die Terrill-Formel arbeitet in endvergorenen Proben genauer, in wenig oder unvergorenen Proben zum Teil nicht zu gebrauchen.")
            }

            LabelPrim {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.italic: true
                text: qsTr("Die Terrill-Linear-Formel ist eine linearisierte Version der Terrill-Formel.")
            }

            LabelPrim {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.italic: true
                text: qsTr("Die Standardformel liefert gleichmässig gute Werte, in endvergorenen Proben aber etwas zu hoch.")
            }
        }
    }
}
