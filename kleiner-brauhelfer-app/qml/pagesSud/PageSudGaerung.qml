import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0
import ProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Gärung")
    icon: "gaerung.png"
    readOnly: Brauhelfer.readonly || app.settings.readonly || (Brauhelfer.sud.Status !== Brauhelfer.Abgefuellt && !app.brewForceEditable)

    Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentHeight: layout.height
        boundsBehavior: Flickable.OvershootBounds
        onMovementStarted: forceActiveFocus()
        ScrollIndicator.vertical: ScrollIndicator {}

        ColumnLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right


            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Bemerkung Gärung")
                }
                TextAreaBase {
                    anchors.fill: parent
                    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                    wrapMode: TextArea.Wrap
                    placeholderText: qsTr("Bemerkung")
                    textFormat: Text.RichText
                    text: Brauhelfer.sud.BemerkungGaerung
                    onTextChanged: if (activeFocus) Brauhelfer.sud.BemerkungGaerung = text
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelHeader {
                    text: qsTr("Abschluss")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Beginn Reifung")
                    }
                    TextFieldDate {
                        id: tfAbfuelldatum
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        enabled: !(Brauhelfer.readonly || app.settings.readonly || (Brauhelfer.sud.Status !== Brauhelfer.Abgefuellt && !app.brewForceEditable))
                        date: Brauhelfer.sud.ReifungStart
                        onNewDate: {
                            Brauhelfer.sud.ReifungStart = date
                        }
                    }
                    ButtonBase {
                        id: ctrlAbgefuellt
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        text: qsTr("Sud verbraucht")
                        enabled: !page.readOnly
                        onClicked: Brauhelfer.sud.Status = Brauhelfer.Verbraucht
                    }
                }
            }
        }
    }
}
