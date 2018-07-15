import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff Wasser")
    icon: "water.png"

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

            Repeater {
                model: Brauhelfer.modelWasser
                ColumnLayout {
                    GroupBox {
                        Layout.fillWidth: true
                        label: LabelSubheader {
                            text: qsTr("Calcium")
                        }
                        GridLayout {
                            anchors.fill: parent
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Calcium")
                            }
                            SpinBoxReal {
                                decimals: 2
                                realValue: model.Calcium
                                onNewValue: model.Calcium = value
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("mg/l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                            }
                            SpinBoxReal {
                                decimals: 3
                                realValue: model.CalciumMmol
                                onNewValue: model.CalciumMmol = value
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("mmol/l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Härtegrad")
                            }
                            LabelNumber {
                                Layout.alignment: Qt.AlignHCenter
                                precision: 2
                                value: model.Calciumhaerte
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("°dH")
                            }
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true
                        label: LabelSubheader {
                            text: qsTr("Magnesium")
                        }
                        GridLayout {
                            anchors.fill: parent
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Magnesium")
                            }
                            SpinBoxReal {
                                decimals: 2
                                realValue: model.Magnesium
                                onNewValue: model.Magnesium = value
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("mg/l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                            }
                            SpinBoxReal {
                                decimals: 3
                                realValue: model.MagnesiumMmol
                                onNewValue: model.MagnesiumMmol = value
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("mmol/l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Härtegrad")
                            }
                            LabelNumber {
                                Layout.alignment: Qt.AlignHCenter
                                precision: 2
                                value: model.Magnesiumhaerte
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("°dH")
                            }
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true
                        label: LabelSubheader {
                            text: qsTr("Carbonhärte")
                        }
                        GridLayout {
                            anchors.fill: parent
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Säurekapazität")
                            }
                            SpinBoxReal {
                                decimals: 2
                                realValue: model.Saeurekapazitaet
                                onNewValue: model.Saeurekapazitaet = value
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("mmol/l")
                            }
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Carbonhärte")
                            }
                            SpinBoxReal {
                                decimals: 2
                                realValue: model.Carbonathaerte
                                onNewValue: model.Carbonathaerte = value
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("°dH")
                            }
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true
                        label: LabelSubheader {
                            text: qsTr("Restalkalität")
                        }
                        GridLayout {
                            anchors.fill: parent
                            columns: 3
                            LabelPrim {
                                Layout.fillWidth: true
                                text: qsTr("Restalkalität")
                            }
                            LabelNumber {
                                Layout.preferredWidth: 160
                                precision: 2
                                value: model.Restalkalitaet
                            }
                            LabelUnit {
                                Layout.preferredWidth: 60
                                text: qsTr("°dH")
                            }
                        }
                    }
                }
            }
        }
    }
}
