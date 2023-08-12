import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import brauhelfer

TextFieldPlato {

    property bool useDialog: true
    property real sw: 0.0

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
                tfBrix.value = 0.0
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
                    text: qsTr("Restextrakt")
                }
                HorizontalDivider {
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                }

                LabelPrim {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("SW")
                }
                TextFieldPlato {
                    id: tfSw
                    value: sw
                    Layout.alignment: Qt.AlignHCenter
                    readOnly: true
                }
                LabelUnit {
                    text: qsTr("°P")
                }

                HorizontalDivider {
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                }

                ComboBoxBase {
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                    model: [qsTr("Spindel"), qsTr("Refraktometer"), qsTr("Anderes")]
                    currentIndex: app.settings.restextraktMethode
                    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                    onCurrentIndexChanged: app.settings.restextraktMethode = currentIndex
                }

                Item {
                    Layout.fillWidth: true
                    visible: app.settings.restextraktMethode == 1
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/images/refractometer.png"
                    }
                }
                ComboBoxBase {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    visible: app.settings.restextraktMethode == 1
                    model: [qsTr("Terrill"), qsTr("Terrill Linear"), qsTr("Standard"), qsTr("Novotny")]
                    currentIndex: app.settings.refractometerIndex
                    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                    onCurrentIndexChanged: {
                        app.settings.refractometerIndex = currentIndex
                        tfPlato.value = BierCalc.dichteToPlato(BierCalc.brixToDichte(Brauhelfer.sud.SWIst, tfBrix.value, app.settings.refractometerIndex))
                    }
                }
                Item {
                    visible: app.settings.restextraktMethode == 1
                }
                TextFieldPlato {
                    id: tfBrix
                    Layout.alignment: Qt.AlignHCenter
                    enabled: !page.readOnly
                    visible: app.settings.restextraktMethode == 1
                    onNewValue: (value) => {
                        this.value = value
                        tfPlato.value = BierCalc.dichteToPlato(BierCalc.brixToDichte(Brauhelfer.sud.SWIst, value, app.settings.refractometerIndex))
                    }
                }
                LabelUnit {
                    text: qsTr("°Brix")
                    visible: app.settings.restextraktMethode == 1
                }

                Item {
                    Layout.fillWidth: true
                    visible: app.settings.restextraktMethode == 0
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/images/spindel.png"
                    }
                }
                TextFieldNumber {
                    id: tfDensity
                    Layout.alignment: Qt.AlignHCenter
                    enabled: !page.readOnly
                    visible: app.settings.restextraktMethode == 0
                    min: 0.0
                    max: 2.0
                    precision: 4
                    onNewValue: (value) => {
                        this.value = value
                        tfPlato.value = BierCalc.spindelKorrektur(BierCalc.dichteToPlato(value), tfTemp.value, 20)
                    }
                }
                LabelUnit {
                    text: qsTr("g/ml")
                    visible: app.settings.restextraktMethode == 0
                }
                Item {
                    Layout.fillWidth: true
                    visible: app.settings.restextraktMethode == 0
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/images/temperature.png"
                    }
                }
                TextFieldTemperature {
                    id: tfTemp
                    Layout.alignment: Qt.AlignHCenter
                    enabled: !page.readOnly
                    visible: app.settings.restextraktMethode == 0
                    value: 20
                    onNewValue: (value) => {
                        this.value = value
                        tfPlato.value = BierCalc.spindelKorrektur(BierCalc.dichteToPlato(tfDensity.value), value, 20)
                    }
                }
                LabelUnit {
                    text: qsTr("°C")
                    visible: app.settings.restextraktMethode == 0
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
                    Layout.alignment: Qt.AlignHCenter
                    enabled: !page.readOnly
                    readOnly: app.settings.restextraktMethode != 2
                    onNewValue: (value) => this.value = value
                }
                LabelUnit {
                    text: qsTr("°P")
                }
            }
        }
    }
}
