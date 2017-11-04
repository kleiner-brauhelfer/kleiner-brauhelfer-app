import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Zugabe")
    icon: "ic_merge_type.png"

    component:  Flickable {
        anchors.fill: parent
        anchors.margins: 8
        boundsBehavior: Flickable.OvershootBounds
        clip: true
        contentHeight: layout.height
        ScrollIndicator.vertical: ScrollIndicator {}

        ColumnLayout {
            id: layout
            spacing: 8
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 20

                LabelPrim {
                    text: qsTr("Gewünschte Temperatur")
                }

                TextFieldTemperature {
                    id: tfTShould
                    value: 78.0
                    onNewValue: this.value = value
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("°C")
                }

                LabelPrim {
                    text: qsTr("Anfangstemperatur")
                }

                TextFieldTemperature {
                    id: tfT0
                    value: 60.0
                    onNewValue: this.value = value
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("°C")
                }

                LabelPrim {
                    text: qsTr("Temperatur Zugabe")
                }

                TextFieldTemperature {
                    id: tfT1
                    value: 100.0
                    onNewValue: this.value = value
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("°C")
                }

                LabelPrim {
                    text: qsTr("Anfangsvolumen")
                }

                TextFieldVolume {
                    id: tfV0
                    value: 20.0
                    onNewValue: this.value = value
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Liter")
                }

                HorizontalDivider {
                    Layout.columnSpan: 3
                }

                LabelPrim {
                    text: qsTr("Zugabe")
                }

                LabelNumber {
                    Layout.preferredWidth: tfV0.implicitWidth
                    font.bold: true
                    value: tfV0.value * ((tfT0.value - tfTShould.value)/(tfTShould.value - tfT1.value))
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Liter")
                }
            }
        }
    }
}
