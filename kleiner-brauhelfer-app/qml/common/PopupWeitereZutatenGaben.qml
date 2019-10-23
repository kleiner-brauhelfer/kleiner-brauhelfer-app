import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
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

                        RowLayout {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            Layout.bottomMargin: 8
                            Image {
                                id: imgType
                                source: {
                                    switch (model.Typ) {
                                    case 0: return "qrc:/images/ewz_typ_0.png"
                                    case 1: return "qrc:/images/ewz_typ_1.png"
                                    case 2: return "qrc:/images/ewz_typ_2.png"
                                    case 3: return "qrc:/images/ewz_typ_3.png"
                                    case 4: return "qrc:/images/ewz_typ_4.png"
                                    case 100: return "qrc:/images/ewz_typ_100.png"
                                    default: return ""
                                    }
                                }
                            }
                            LabelSubheader {
                                Layout.fillWidth: true
                                text: model.Name
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Item {
                                width: imgType.width
                            }
                        }

                        LabelPrim {
                            rightPadding: 8
                            text: qsTr("Menge")
                        }
                        LabelNumber {
                            Layout.fillWidth: true
                            unit: switch(model.Einheit) {case 0: return qsTr("kg"); case 1: return qsTr("g"); case 2: return qsTr("mg"); case 3: return qsTr("Stk");}
                            value: switch(model.Einheit) {case 0: return model.erg_Menge/1000; case 1: return model.erg_Menge; case 2: return model.erg_Menge*1000; case 3: return model.erg_Menge;}
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
                                onYes: Brauhelfer.sud.zutatAbziehen(model.Name, model.Typ === 100 ? 0 : 2, model.erg_Menge)
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
