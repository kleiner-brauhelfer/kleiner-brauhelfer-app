import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.Dialogs 1.3

import brauhelfer 1.0

PopupBase {
    property alias model: repeater.model
    property alias currentIndex: swipeView.currentIndex
    maxWidth: 320
    SwipeView {
        id: swipeView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        spacing: 16
        height: contentChildren[currentIndex].implicitHeight + 2 * anchors.margins
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

                        LabelSubheader {
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
                            onNewDate: {
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
                            onNewDate: model.EntnahmeDatum = date
                        }

                        TextArea {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            wrapMode: TextArea.Wrap
                            placeholderText: qsTr("Bemerkung")
                            text: model.Bemerkung
                            onTextChanged: if (activeFocus) model.Bemerkung = text
                        }

                        Button {
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
                                icon: StandardIcon.Question
                                text: qsTr("Rohstoff vom Bestand abziehen?")
                                standardButtons: StandardButton.Yes | StandardButton.No
                                //buttons: MessageDialog.Yes | MessageDialog.No
                                onYes: Brauhelfer.rohstoffAbziehen(
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
