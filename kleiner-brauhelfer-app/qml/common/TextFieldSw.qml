import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import brauhelfer

TextFieldPlato {

    property bool useDialog: true

    id: textfield

    onPressed: if (useDialog) popuploader.active = true

    Loader {
        id: popuploader
        active: false
        focus: true
        onLoaded: item.open()
        sourceComponent: PopupBase {
            maxWidth: 320
            onOpened: {
                tfPlato.value = textfield.value
                tfDensity.value = BierCalc.platoToDichte(tfPlato.value)
                tfBrix.value = BierCalc.platoToBrix(tfPlato.value)
                tfPlato.forceActiveFocus()
            }
            onClosed: {
                if (tfPlato.value !== textfield.value)
                    newValue(tfPlato.value)
                active = false
                textfield.forceActiveFocus()
            }

            GridLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                columns: 3
                columnSpacing: 16

                LabelHeader {
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Stammwürze")
                }
                HorizontalDivider {
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/images/refractometer.png"
                    }
                }
                TextFieldPlato {
                    id: tfBrix
                    onNewValue: (value) => {
                        this.value = value
                        tfPlato.value = BierCalc.brixToPlato(value)
                        tfDensity.value = BierCalc.platoToDichte(tfPlato.value)
                        tfTemp.value = 20.0
                    }
                }
                LabelUnit {
                    text: qsTr("°Brix")
                }
                HorizontalDivider {
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                }
                Item {
                    Layout.fillWidth: true
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/images/spindel.png"
                    }
                }
                TextFieldNumber {
                    id: tfDensity
                    min: 0.0
                    max: 99.9
                    precision: 3
                    onNewValue: (value) => {
                        this.value = value
                        tfPlato.value = BierCalc.spindelKorrektur(BierCalc.dichteToPlato(value), tfTemp.value, 20)
                        tfBrix.value = BierCalc.platoToBrix(tfPlato.value)
                    }
                }
                LabelUnit {
                    text: qsTr("g/ml")
                }
                Item {
                    Layout.fillWidth: true
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/images/temperature.png"
                    }
                }
                TextFieldTemperature {
                    id: tfTemp
                    value: 20.0
                    onNewValue: (value) => {
                        this.value = value
                        tfPlato.value = BierCalc.spindelKorrektur(BierCalc.dichteToPlato(tfDensity.value), value, 20)
                        tfBrix.value = BierCalc.platoToBrix(tfPlato.value)
                    }
                }
                LabelUnit {
                    text: qsTr("°C")
                }
                HorizontalDivider {
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                }
                Item {
                    Layout.fillWidth: true
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/images/sugar.png"
                    }
                }
                TextFieldPlato {
                    id: tfPlato
                    onNewValue: (value) => {
                        this.value = value
                        tfBrix.value = BierCalc.platoToBrix(value)
                        tfDensity.value = BierCalc.platoToDichte(value)
                        tfTemp.value = 20.0
                    }
                }
                LabelUnit {
                    text: qsTr("°P")
                }
            }
        }
    }
}
