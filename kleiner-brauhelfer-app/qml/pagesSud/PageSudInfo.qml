import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Info")
    icon: "ic_info_outline.png"
    enabled: Brauhelfer.sud.loaded

    component: Flickable {
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
                label: LabelSubheader {
                    text: Brauhelfer.sud.Sudname
                }
                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Gespeichert")
                    }
                    LabelDateTime {
                        date: Brauhelfer.sud.Gespeichert
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Erstellt")
                    }
                    LabelDate {
                        date: Brauhelfer.sud.Erstellt
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Gebraut")
                    }
                    LabelDate {
                        date: Brauhelfer.sud.BierWurdeGebraut ? Brauhelfer.sud.Braudatum : new Date("")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Angestellt")
                    }
                    LabelDate {
                        date: Brauhelfer.sud.BierWurdeGebraut ? Brauhelfer.sud.Anstelldatum : new Date("")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Abgefüllt")
                    }
                    LabelDate {
                        date: Brauhelfer.sud.BierWurdeAbgefuellt ? Brauhelfer.sud.Abfuelldatum : new Date("")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: repeaterMalz.count > 0
                label: LabelSubheader {
                    text: qsTr("Malz")
                }
                ColumnLayout {
                    anchors.fill: parent
                    Repeater {
                        id: repeaterMalz
                        model: Brauhelfer.sud.modelMalzschuettung
                        delegate: RowLayout{
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            Item {
                                Layout.preferredWidth: 80
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 2
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                text: qsTr("kg")
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: repeaterHopfen.count > 0
                label: LabelSubheader {
                    text: qsTr("Hopen")
                }
                ColumnLayout {
                    anchors.fill: parent
                    Repeater {
                        id: repeaterHopfen
                        model:Brauhelfer.sud.modelHopfengaben
                        delegate: RowLayout{
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            LabelPrim {
                                Layout.preferredWidth: 80
                                text: model.Vorderwuerze ? qsTr("VWH") : ""
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 2
                                value: model.erg_Menge
                            }
                            LabelUnit {
                                text: qsTr("g")
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: repeaterWZutaten.count > 0
                label: LabelSubheader {
                    text: qsTr("Weitere Zutaten")
                }
                ColumnLayout {
                    anchors.fill: parent
                    Repeater {
                        id: repeaterWZutaten
                        model:Brauhelfer.sud.modelWeitereZutatenGaben
                        delegate: RowLayout{
                            Layout.leftMargin: 8
                            LabelPrim {
                                Layout.fillWidth: true
                                text: model.Name
                            }
                            LabelPrim {
                                Layout.preferredWidth: 80
                                text: {
                                    switch (model.Zeitpunkt)
                                    {
                                    case 0: qsTr("Gärung"); break;
                                    case 1: qsTr("Kochen"); break;
                                    case 2: qsTr("Maischen"); break;
                                    }
                                }
                            }
                            LabelNumber {
                                Layout.preferredWidth: 60
                                precision: 2
                                value: model.Einheit === 0 ? model.erg_Menge/1000 : model.erg_Menge
                            }
                            LabelUnit {
                                text: model.Einheit === 0 ? qsTr("kg") : qsTr("g")
                            }
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                visible: Brauhelfer.sud.AuswahlHefe !== ""
                label: LabelSubheader {
                    text: qsTr("Hefe")
                }
                ColumnLayout {
                    anchors.fill: parent
                    RowLayout {
                        Layout.leftMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            text: Brauhelfer.sud.AuswahlHefe
                        }
                        LabelNumber {
                            Layout.preferredWidth: 60
                            precision: 0
                            value: Brauhelfer.sud.HefeAnzahlEinheiten
                        }
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                label: LabelSubheader {
                    text: qsTr("Abschluss")
                }
                Switch {
                    text: qsTr("Sud verbraucht")
                    checked: Brauhelfer.sud.BierWurdeVerbraucht
                    onClicked: Brauhelfer.sud.BierWurdeVerbraucht = checked
                }
            }
        }
    }
}
