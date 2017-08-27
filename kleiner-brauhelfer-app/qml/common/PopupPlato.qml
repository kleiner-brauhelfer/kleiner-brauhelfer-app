import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import brauhelfer 1.0

Popup {
    property double sw: 0.0
    property alias value: tfPlato.value

    parent: page
    width: 240
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    focus: true

    function edit(value) {
        tfPlato.focus = true
        tfPlato.value = value
        tfDensity.value = Brauhelfer.calc.platoToDichte(tfPlato.value)
        tfBrix.value = (sw === 0.0) ? Brauhelfer.calc.platoToBrix(tfPlato.value) : ""
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

        Image {
            source: "qrc:/images/refractometer.png"
        }

        TextFieldNumber {
            id: tfBrix
            min: 0.0
            max: 99.9
            precision: 2
            onNewValue: {
                this.value = value
                if (tfBrix.focus) {
                    if (sw === 0.0) {
                        tfPlato.value = Brauhelfer.calc.brixToPlato(tfBrix.value)
                        tfDensity.value = Brauhelfer.calc.platoToDichte(tfPlato.value)
                    }
                    else {
                        tfDensity.value = Brauhelfer.calc.brixToDichte(sw, tfBrix.value)
                        tfPlato.value = Brauhelfer.calc.dichteToPlato(tfDensity.value)
                    }
                }
            }
        }

        LabelPrim {
            text: qsTr("°Brix")
            Layout.fillWidth: true
        }

        Image {
            source: "qrc:/images/spindel.png"
        }

        TextFieldNumber {
            id: tfDensity
            min: 0.0
            max: 99.9
            precision: 4
            onNewValue: {
                this.value = value
                if (tfDensity.focus) {
                    tfPlato.value = Brauhelfer.calc.dichteToPlato(tfDensity.value)
                    tfBrix.value = (sw === 0.0) ? Brauhelfer.calc.platoToBrix(tfPlato.value) : ""
                }
            }
        }

        LabelPrim {
            text: qsTr("g/ml")
            Layout.fillWidth: true
        }

        Image {
            source: "qrc:/images/sugar.png"
        }

        TextFieldNumber {
            id: tfPlato
            min: 0.0
            max: 99.9
            precision: 2
            onNewValue: {
                this.value = value
                if (tfPlato.focus) {
                    tfDensity.value = Brauhelfer.calc.platoToDichte(tfPlato.value)
                    tfBrix.value = (sw === 0.0) ? Brauhelfer.calc.platoToBrix(tfPlato.value) : ""
                }
            }
        }

        LabelPrim {
            text: qsTr("°P")
            Layout.fillWidth: true
        }
    }
}
