import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import brauhelfer 1.0

TextFieldNumber {

    property bool useDialog: false
    property alias temp1: popup.temp1
    property alias temp1Fix: popup.temp1Fix
    property alias temp2: popup.temp2
    property alias temp2Fix: popup.temp2Fix

    id: textfield
    min: 0.0
    max: 999.9
    precision: 1

    onPressed: if (useDialog) popup.edit(value)

    Popup {

        property alias value: tfV2.value
        property double temp1: 100
        property double temp2: 20.0
        property bool temp1Fix: false
        property bool temp2Fix: true

        id: popup
        parent: page
        width: 240
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        focus: true

        onClosed: {
            if (value !== textfield.value)
                newValue(value)
            textfield.focus = false
        }

        function edit(value) {
            tfV1.value = Brauhelfer.calc.VolumenWasser(temp2, temp1, value)
            tfV2.value = value
            tfV2.focus = true
            open()
        }

        background: Rectangle {
            color: Material.background
            radius: 10
            MouseArea {
                anchors.fill: parent
                onClicked: forceActiveFocus()
            }
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
                value: temp1
                readOnly: temp1Fix
                onNewValue: {
                    temp1 = value
                    tfV2.value = Brauhelfer.calc.VolumenWasser(temp1, temp2, tfV1.value)
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
                    tfV2.value = Brauhelfer.calc.VolumenWasser(temp1, temp2, value)
                }
            }

            LabelPrim {
                text: qsTr("Liter")
                Layout.fillWidth: true
            }

            HorizontalDivider {
                Layout.columnSpan: 3
            }

            LabelPrim {
                text: qsTr("Temperatur 2")
            }

            TextFieldTemperature {
                id: tfT2
                value: temp2
                readOnly: temp2Fix
                onNewValue: {
                    temp2 = value
                    tfV2.value = Brauhelfer.calc.VolumenWasser(temp1, temp2, tfV1.value)
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
                    tfV1.value = Brauhelfer.calc.VolumenWasser(temp2, temp1, value)
                }
            }

            LabelPrim {
                text: qsTr("Liter")
                Layout.fillWidth: true
            }
        }
    }
}
