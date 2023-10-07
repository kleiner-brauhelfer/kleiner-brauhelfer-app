import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt.labs.platform

import brauhelfer

PopupBase {
    property alias model: repeater.model
    property alias currentIndex: swipeView.currentIndex
    maxWidth: 320
    SwipeView {
        id: swipeView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 16
        clip: true
        Repeater {
            id: repeater
            Loader {
                active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                sourceComponent: Item {
                    property variant _model: model
                    implicitHeight: layout.height
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: 0
                        onClicked: forceActiveFocus()
                    }
                    GridLayout {
                        id: layout
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        columns: 2

                        LabelHeader {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            text: model.Name
                            horizontalAlignment: Text.AlignHCenter
                        }

                        LabelPrim {
                            rightPadding: 8
                            text: qsTr("Menge")
                        }
                        LabelNumber {
                            Layout.fillWidth: true
                            precision: 2
                            unit: app.defs.einheiten[model.Einheit]
                            value: model.erg_Menge * app.defs.einheitenDivider[model.Einheit]
                        }
                        LabelPrim {
                            rightPadding: 8
                            text: qsTr("Zugegeben")
                        }
                        TextFieldDate {
                            id: tfDateFrom
                            Layout.fillWidth: true
                            readOnly: model.Zugabestatus !== 0
                            date: model.Zugabestatus === 0 ? new Date() : model.ZugabeDatum
                            onNewDate: (date) => {
                                if (model.Zugabestatus === 0)
                                    this.date = date
                                else
                                    model.ZugabeDatum = date
                            }
                        }

                        LabelPrim {
                            rightPadding: 8
                            visible: model.Zugabestatus > 0 && model.Entnahmeindex === 0
                            text: qsTr("Entnommen")
                        }
                        TextFieldDate {
                            id: tfDateTo
                            Layout.fillWidth: true
                            visible: model.Zugabestatus > 0 && model.Entnahmeindex === 0
                            readOnly: model.Zugabestatus !== 1
                            date: model.EntnahmeDatum
                            onNewDate: (date) => model.EntnahmeDatum = date
                        }

                        TextAreaBase {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true

                            placeholderText: qsTr("Bemerkung")
                            text: model.Bemerkung
                            onTextChanged: if (activeFocus) model.Bemerkung = text
                        }

                        ButtonBase {
                            function addIngredient() {
                                model.ZugabeDatum = tfDateFrom.date
                                model.Zugabestatus = 1
                                messageDialog.open()
                            }

                            function removeIngredient() {
                                model.EntnahmeDatum = tfDateTo.date
                                model.Zugabestatus = 2
                            }

                            MessageDialog {
                                property var item: null
                                id: messageDialog
                                text: qsTr("Rohstoff vom Bestand abziehen?")
                                buttons: MessageDialog.Yes | MessageDialog.No
                                onYesClicked: Brauhelfer.rohstoffAbziehen(
                                           model.Typ === Brauhelfer.ZusatzTyp.Hopfen ? Brauhelfer.RohstoffTyp.Hopfen : Brauhelfer.RohstoffTyp.Zusatz,
                                           model.Name,
                                           model.erg_Menge)
                            }

                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            visible: model.Zugabestatus === 0 || (model.Zugabestatus === 1 && model.Entnahmeindex === 0)
                            text: model.Zugabestatus === 0 ? qsTr("Zugeben") : qsTr("Entnehmen")
                            onClicked: model.Zugabestatus === 0 ? addIngredient() : removeIngredient()
                        }
                    }
                }
            }
        }
    }
}
