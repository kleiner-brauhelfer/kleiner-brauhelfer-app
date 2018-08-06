import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import brauhelfer 1.0

TextFieldNumber {

    property bool useDialog: false
    property real temp1: 100.0
    property real temp2: 20.0
    property bool temp1Fix: false
    property bool temp2Fix: true

    id: textfield
    min: 0.0
    max: 999.9
    precision: 1

    onPressed: if (useDialog) popuploader.active = true

    Loader {
        id: popuploader
        active: false
        focus: true
        onLoaded: item.open()
        sourceComponent: PopupBase {
            maxWidth: 240
            onOpened: {
                tfV1.value = Brauhelfer.calc.volumenWasser(textfield.temp2, textfield.temp1, textfield.value)
                tfV2.value = textfield.value
                tfV2.forceActiveFocus()
            }
            onClosed: {
                if (tfV2.value !== textfield.value)
                    newValue(tfV2.value)
                textfield.focus = false
                popuploader.active = false
            }

            GridLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                columns: 3
                columnSpacing: 16

                LabelPrim {
                    text: qsTr("Temperatur 1")
                }

                TextFieldTemperature {
                    id: tfT1
                    value: textfield.temp1
                    readOnly: textfield.temp1Fix
                    onNewValue: {
                        this.value = value
                        tfV2.value = Brauhelfer.calc.volumenWasser(textfield.temp1, textfield.temp2, tfV1.value)
                    }
                }

                LabelPrim {
                    text: qsTr("°C")
                    Layout.fillWidth: true
                }

                LabelPrim {
                    text: qsTr("Volumen 1")
                }

                TextFieldNumber {
                    id: tfV1
                    min: textfield.min
                    max: textfield.max
                    precision: textfield.precision
                    onNewValue: {
                        this.value = value
                        tfV2.value = Brauhelfer.calc.volumenWasser(textfield.temp1, textfield.temp2, value)
                    }
                }

                LabelPrim {
                    text: qsTr("l")
                    Layout.fillWidth: true
                }

                HorizontalDivider {
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                }

                LabelPrim {
                    text: qsTr("Temperatur 2")
                }

                TextFieldTemperature {
                    id: tfT2
                    value: textfield.temp2
                    readOnly: textfield.temp2Fix
                    onNewValue: {
                        this.value = value
                        tfV2.value = Brauhelfer.calc.volumenWasser(textfield.temp1, textfield.temp2, tfV1.value)
                    }
                }

                LabelPrim {
                    text: qsTr("°C")
                    Layout.fillWidth: true
                }

                LabelPrim {
                    text: qsTr("Volumen 2")
                }

                TextFieldNumber {
                    id: tfV2
                    min: textfield.min
                    max: textfield.max
                    precision: textfield.precision
                    onNewValue: {
                        this.value = value
                        tfV1.value = Brauhelfer.calc.volumenWasser(textfield.temp2, textfield.temp1, value)
                    }
                }

                LabelPrim {
                    text: qsTr("l")
                    Layout.fillWidth: true
                }
            }
        }
    }
}
