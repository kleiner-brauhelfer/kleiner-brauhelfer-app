import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

import brauhelfer 1.0

TextFieldNumber {

    property bool useDialog: false
    property real sw: 0.0

    id: textfield
    min: 0.0
    max: 99.9
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
                tfPlato.value = textfield.value
                tfDensity.value = BierCalc.platoToDichte(tfPlato.value)
                tfBrix.value = (textfield.sw === 0.0) ? BierCalc.platoToBrix(tfPlato.value) : ""
                tfPlato.forceActiveFocus()
            }
            onClosed: {
                if (tfPlato.value !== textfield.value)
                    newValue(tfPlato.value)
                textfield.focus = false
                popuploader.active = false
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
                            if (textfield.sw === 0.0) {
                                tfPlato.value = BierCalc.brixToPlato(tfBrix.value)
                                tfDensity.value = BierCalc.platoToDichte(tfPlato.value)
                            }
                            else {
                                tfDensity.value = BierCalc.brixToDichte(textfield.sw, tfBrix.value)
                                tfPlato.value = BierCalc.dichteToPlato(tfDensity.value)
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
                            tfPlato.value = BierCalc.dichteToPlato(tfDensity.value)
                            tfBrix.value = (textfield.sw === 0.0) ? BierCalc.platoToBrix(tfPlato.value) : ""
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
                            tfDensity.value = BierCalc.platoToDichte(tfPlato.value)
                            tfBrix.value = (textfield.sw === 0.0) ? BierCalc.platoToBrix(tfPlato.value) : ""
                        }
                    }
                }

                LabelPrim {
                    text: qsTr("°P")
                    Layout.fillWidth: true
                }
            }
        }
    }
}
