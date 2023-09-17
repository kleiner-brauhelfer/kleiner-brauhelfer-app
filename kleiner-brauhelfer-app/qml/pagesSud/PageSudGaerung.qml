import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import "../common"
import brauhelfer
import ProxyModel

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
        ScrollIndicator.vertical: ScrollIndicator {}

        ColumnLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
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
                        onNewDate: (date) => {
                            Brauhelfer.sud.ReifungStart = date
                        }
                    }
                    TextAreaBase {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                        placeholderText: qsTr("Bemerkung Gärung")
                        textFormat: Text.RichText
                        text: Brauhelfer.sud.BemerkungGaerung
                        onLinkActivated: (link) => Qt.openUrlExternally(link)
                        onTextChanged: if (activeFocus) Brauhelfer.sud.BemerkungGaerung = text
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
