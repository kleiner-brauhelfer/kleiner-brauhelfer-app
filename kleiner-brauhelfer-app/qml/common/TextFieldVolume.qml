import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import brauhelfer

TextFieldNumber {

    property bool useDialog: true

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
            maxWidth: 320
            onOpened: {
                tfV2.value = textfield.value
                tfV1.value = BierCalc.volumenWasser(tfT2.value, tfT1.value, tfV2.value)
                tfV1.forceActiveFocus()
            }
            onClosed: {
                if (tfV2.value !== textfield.value)
                    newValue(tfV2.value)
                active = false
                textfield.forceActiveFocus()
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
                    value: 100
                    onNewValue: (value) => {
                        this.value = value
                        tfV2.value = BierCalc.volumenWasser(tfT1.value, tfT2.value, tfV1.value)
                    }
                }

                LabelUnit {
                    text: qsTr("°C")
                }

                LabelPrim {
                    text: qsTr("Volumen 1")
                }

                TextFieldNumber {
                    id: tfV1
                    min: textfield.min
                    max: textfield.max
                    precision: textfield.precision
                    onNewValue: (value) => {
                        this.value = value
                        tfV2.value = BierCalc.volumenWasser(tfT1.value, tfT2.value, tfV1.value)
                    }
                }

                LabelUnit {
                    text: qsTr("l")
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
                    value: 20
                    readOnly: true
                    onNewValue: (value) => {
                        this.value = value
                        tfV2.value = BierCalc.volumenWasser(tfT1.value, tfT2.value, tfV1.value)
                    }
                }

                LabelUnit {
                    text: qsTr("°C")
                }

                LabelPrim {
                    text: qsTr("Volumen 2")
                }

                TextFieldNumber {
                    id: tfV2
                    min: textfield.min
                    max: textfield.max
                    precision: textfield.precision
                    readOnly: true
                    onNewValue: (value) => {
                        this.value = value
                        tfV2.value = BierCalc.volumenWasser(tfT1.value, tfT2.value, tfV1.value)
                    }
                }

                LabelUnit {
                    text: qsTr("l")
                }
            }
        }
    }
}
