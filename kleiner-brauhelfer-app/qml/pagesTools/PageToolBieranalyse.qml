import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Bieranalyse")
    icon: "ic_colorize.png"

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

            HorizontalDivider {}

            GridLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                columns: 3
                columnSpacing: 20

                LabelPrim {
                    text: qsTr("Formel")
                }

                ComboBox {
                    id: cbFormel
                    Layout.columnSpan: 2
                    model: [ "Terril", "Terril Linear", "Standard" ]
                    opacity: {
                        if (enabled)
                            Material.theme === Material.Dark ? 1.00 : 0.87
                        else
                            Material.theme === Material.Dark ? 0.50 : 0.38
                    }
                }

                HorizontalDivider {
                    Layout.columnSpan: 3
                }

                LabelPrim {
                    text: qsTr("Vor der Vergärung")
                }

                TextFieldPlato {
                    id: tfVor
                    value: 12.0
                    onNewValue: this.value = value
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("°Brix")
                }

                LabelPrim {
                    text: qsTr("Nach der Vergärung")
                }

                TextFieldPlato {
                    id: tfNach
                    value: 6.0
                    onNewValue: this.value = value
                }

                LabelPrim {
                    text: qsTr("°Brix")
                }

                HorizontalDivider {
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

                LabelPrim {
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

                LabelPrim {
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

                LabelPrim {
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

                LabelPrim {
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

                LabelPrim {
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

                LabelPrim {
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

                LabelPrim {
                    text: qsTr("vol%")
                }
            }

            HorizontalDivider {}

            LabelPrim {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Die Terrill-Formel arbeitet in endvergorenen Proben genauer, in wenig oder unvergorenen Proben zum Teil nicht zu gebrauchen.")
            }

            LabelPrim {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Die Terrill-Linear-Formel ist eine linearisierte Version der Terrill-Formel.")
            }

            LabelPrim {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Standardformel liefert gleichmässig gute Werte, in endvergorenen Proben aber etwas zu hoch.")
            }
        }
    }
}
