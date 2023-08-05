import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

import brauhelfer

PopupBase {
    property variant model: null
    maxWidth: 320
    onClosed: active = false
    onOpened: {
        if (model.Temp === 20) {
            tfPlato.value = model.Restextrakt
            tfDensity.value = BierCalc.platoToDichte(model.Restextrakt)
        } else {
            tfPlato.value = 0
            tfDensity.value = 1.0
        }
        tfBrix.value = NaN
    }
    GridLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        columns: 3
        columnSpacing: 16

        Image {
            source: "qrc:/images/baseline_date_range.png"
        }

        TextFieldDate {
            id: tfDate
            Layout.columnSpan: 2
            Layout.fillWidth: true
            enabled: !page.readOnly
            date: model.Zeitstempel
            onNewDate: model.Zeitstempel = date
        }

        ComboBoxBase {
            Layout.columnSpan: 3
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            model: [qsTr("Spindel"), qsTr("Refraktometer"), qsTr("Anderes")]
            currentIndex: app.settings.restextraktMethode
            opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
            onCurrentIndexChanged: {
                app.settings.restextraktMethode = currentIndex
                navPane.setFocus()
            }
        }

        Image {
            source: "qrc:/images/refractometer.png"
            visible: app.settings.restextraktMethode == 1
        }

        ComboBoxBase {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            visible: app.settings.restextraktMethode == 1
            model: [qsTr("Terrill"), qsTr("Terrill Linear"), qsTr("Standard"), qsTr("Novotny")]
            currentIndex: app.settings.refractometerIndex
            opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
            onCurrentIndexChanged: {
                app.settings.refractometerIndex = currentIndex
                navPane.setFocus()
            }
        }

        Label {
            text: ""
            visible: app.settings.restextraktMethode == 1
        }

        TextFieldPlato {
            id: tfBrix
            Layout.alignment: Qt.AlignHCenter
            enabled: !page.readOnly
            visible: app.settings.restextraktMethode == 1
            onNewValue: {
                this.value = value
                var brix = value
                if (!isNaN(brix)) {
                    var density = BierCalc.brixToDichte(Brauhelfer.sud.SWIst, brix, app.settings.refractometerIndex)
                    var sre = BierCalc.dichteToPlato(density)
                    model.Restextrakt = sre
                }
                else {
                    model.Restextrakt = NaN
                }
            }
        }

        LabelUnit {
            text: qsTr("°Brix")
            visible: app.settings.restextraktMethode == 1
        }

        Image {
            source: "qrc:/images/spindel.png"
            visible: app.settings.restextraktMethode == 0
        }

        TextFieldNumber {
            id: tfDensity
            Layout.alignment: Qt.AlignHCenter
            enabled: !page.readOnly
            visible: app.settings.restextraktMethode == 0
            min: 0.0
            max: 2.0
            precision: 4
            onNewValue: {
                this.value = value
                var density = value
                if (!isNaN(density)) {
                    var plato = BierCalc.dichteToPlato(density)
                    tfPlato.value = plato
                    model.Restextrakt = BierCalc.spindelKorrektur(plato, model.Temp, 20)
                }
                else {
                    tfPlato.value = NaN
                    model.Restextrakt = NaN
                }
            }
        }

        LabelUnit {
            text: qsTr("g/ml")
            visible: app.settings.restextraktMethode == 0
        }

        Label {
            text: ""
            visible: app.settings.restextraktMethode == 0
        }

        TextFieldPlato {
            id: tfPlato
            Layout.alignment: Qt.AlignHCenter
            enabled: !page.readOnly
            visible: app.settings.restextraktMethode == 0
            onNewValue: {
                this.value = value
                var plato = value
                if (!isNaN(value)) {
                    tfDensity.value = BierCalc.platoToDichte(value)
                    model.Restextrakt = BierCalc.spindelKorrektur(plato, model.Temp, 20)
                }
                else {
                    tfDensity.value = NaN
                    model.Restextrakt = NaN
                }
            }
        }

        LabelUnit {
            text: qsTr("°P")
            visible: app.settings.restextraktMethode == 0
        }

        HorizontalDivider {
            Layout.columnSpan: 3
            Layout.fillWidth: true
        }

        Image {
            source: "qrc:/images/temperature.png"
        }

        TextFieldTemperature {
            Layout.alignment: Qt.AlignHCenter
            enabled: !page.readOnly
            value: model.Temp
            onNewValue: {
                model.Temp = value
                if (app.settings.restextraktMethode === 0) {
                    var plato = tfPlato.value
                    model.Restextrakt = BierCalc.spindelKorrektur(plato, model.Temp, 20)
                }
            }
        }

        LabelUnit {
            text: qsTr("°C")
        }

        HorizontalDivider {
            Layout.columnSpan: 3
            Layout.fillWidth: true
        }

        Image {
            source: "qrc:/images/sugar.png"
        }

        TextFieldPlato {
            Layout.alignment: Qt.AlignHCenter
            enabled: !page.readOnly && app.settings.restextraktMethode == 2
            value: model.Restextrakt
            onNewValue: model.Restextrakt = value
        }

        LabelUnit {
            text: qsTr("°P")
        }

        HorizontalDivider {
            Layout.columnSpan: 3
            Layout.fillWidth: true
        }

        TextAreaBase {
            Layout.fillWidth: true
            Layout.columnSpan: 3
            enabled: !page.readOnly
            wrapMode: TextArea.Wrap
            placeholderText: qsTr("Bemerkung")
            text: model.Bemerkung
            onTextChanged: if (activeFocus) model.Bemerkung = text
        }

        ToolButton {
            Layout.columnSpan: 3
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            visible: !page.readOnly
            onClicked: listView.currentItem.remove()
            contentItem: Image {
                source: "qrc:/images/ic_delete.png"
                anchors.centerIn: parent
            }
        }
    }
}
