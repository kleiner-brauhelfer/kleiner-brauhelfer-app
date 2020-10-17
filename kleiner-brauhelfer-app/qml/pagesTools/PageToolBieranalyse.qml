import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

import "../common"
import brauhelfer 1.0

PageBase {
    property real brixStart: 12.0
    property real brixEnd: 6.0

    id: page
    title: qsTr("Bieranalyse")
    icon: "refractometer.png"

    function takeValuesFromBrew() {
        var value = Brauhelfer.sud.SW
        if (Brauhelfer.sud.Status !== Brauhelfer.Rezept)
            value = Brauhelfer.sud.SWAnstellen
        brixStart = BierCalc.platoToBrix(value)
        brixEnd = brixStart
    }

    Flickable {
        anchors.margins: 8
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        contentHeight: layout.height
        clip: true
        onMovementStarted: forceActiveFocus()
        ScrollIndicator.vertical: ScrollIndicator {}

        ColumnLayout {
            id: layout
            spacing: 8
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            LabelHeader {
                Layout.fillWidth: true
                horizontalAlignment: Label.AlignHCenter
                text: qsTr("Bieranalyse mit dem Refraktometer") 
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Formel")
                }
                ComboBoxBase {
                    id: cbFormel
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    model: [qsTr("Terrill"), qsTr("Terrill Linear"), qsTr("Standard")]
                    currentIndex: 2
                    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                    onCurrentIndexChanged: navPane.setFocus()
                }
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                columns: 3
                LabelPrim {
                    text: qsTr("Vor Vergärung")
                }
                SpinBoxReal {
                    Layout.fillWidth: true
                    decimals: 1
                    stepSize: 1
                    min: 0.0
                    max: 50.0
                    realValue: brixStart
                    onNewValue: brixStart = value
                }
                LabelUnit {
                    text: qsTr("°Brix")
                }

                LabelPrim {
                    text: qsTr("Nach Vergärung")
                }
                SpinBoxReal {
                    Layout.fillWidth: true
                    decimals: 1
                    stepSize: 1
                    min: 0.0
                    max: brixStart
                    realValue: brixEnd
                    onNewValue: brixEnd = value
                }
                LabelUnit {
                    text: qsTr("°Brix")
                }
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                columns: 3
                LabelPrim {
                    text: qsTr("Stammwürze")
                }
                LabelPlato {
                    id: lblSW
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    value: BierCalc.brixToPlato(brixStart)
                }
                LabelUnit {
                    text: qsTr("°P")
                }
                LabelPrim {
                    text: qsTr("Dichte")
                }
                LabelNumber {
                    id: lblDichte
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    precision: 4
                    value: BierCalc.brixToDichte(lblSW.value, brixEnd, cbFormel.currentIndex)
                }
                LabelUnit {
                    text: qsTr("g/ml")
                }
                LabelPrim {
                    Layout.columnSpan: 3
                    text: qsTr("Scheinbar")
                }
                LabelPrim {
                    Layout.leftMargin: 8
                    text: qsTr("Restextrakt")
                }
                LabelPlato {
                    id: lblSRE
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    value: BierCalc.dichteToPlato(lblDichte.value)
                }
                LabelUnit {
                    text: qsTr("°P")
                }
                LabelPrim {
                    Layout.leftMargin: 8
                    text: qsTr("Vergärungsgrad")
                }
                LabelNumber {
                    id: lblSVG
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    value: BierCalc.vergaerungsgrad(lblSW.value, lblSRE.value)
                }
                LabelUnit {
                    text: qsTr("%")
                }
                LabelPrim {
                    Layout.columnSpan: 3
                    text: qsTr("Tatsächlich")
                }
                LabelPrim {
                    Layout.leftMargin: 8
                    text: qsTr("Restextrakt")
                }
                LabelPlato {
                    id: lblTRE
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    value: BierCalc.toTRE(lblSW.value, lblSRE.value)
                }
                LabelUnit {
                    text: qsTr("°P")
                }
                LabelPrim {
                    Layout.leftMargin: 8
                    text: qsTr("Vergärungsgrad")
                }
                LabelNumber {
                    id: lblTVG
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    value: BierCalc.vergaerungsgrad(lblSW.value, lblTRE.value)
                }
                LabelUnit {
                    text: qsTr("%")
                }
                LabelPrim {
                    text: qsTr("Alkohol")
                }
                LabelNumber {
                    id: lblAlcVol
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    value: BierCalc.alkohol(lblSW.value, lblSRE.value)
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
