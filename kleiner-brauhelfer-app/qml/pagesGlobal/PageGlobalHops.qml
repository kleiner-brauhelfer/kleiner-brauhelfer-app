import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff Hopfen")
    icon: "hops.png"

    component: ListView {
        id: listView
        clip: true
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        model: SortFilterProxyModel {
            id: myModel
            sourceModel: Brauhelfer.modelHopfen
            filterKeyColumn: sourceModel.fieldIndex("Menge")
        }
        headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
        Component.onCompleted: positionViewAtEnd()
        ScrollIndicator.vertical: ScrollIndicator {}
        header: Rectangle {
            z: 2
            width: parent.width
            height: header.height
            color: Material.background
            ColumnLayout {
                id: header
                width: parent.width
                RowLayout {
                    Layout.fillWidth: true
                    LabelPrim {
                        Layout.fillWidth: true
                        leftPadding: 8
                        font.bold: true
                        text: qsTr("Beschreibung")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        rightPadding: 8
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                        text: qsTr("Menge")
                    }
                }
                HorizontalDivider {}
            }
        }
        footerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackFooter : ListView.OverlayFooter
        footer: Rectangle {
            z: 2
            width: parent.width
            height: layoutFilter.height
            color: Material.background
            Flow {
                id: layoutFilter
                width: parent.width
                RadioButton {
                    checked: true
                    text: qsTr("alle")
                    onClicked: myModel.filterRegExp = /(?:)/
                }
                RadioButton {
                    text: qsTr("verfügbar")
                    onClicked: myModel.filterRegExp = /[^0]+/
                }
            }
        }
        delegate: ItemDelegate {
            property variant values: model
            id: rowDelegate
            width: parent.width
            height: dataColumn.implicitHeight
            padding: 0
            text: " "
            onClicked: {
                listView.currentIndex = index
                popuploader.active = true
            }
            ColumnLayout {
                id: dataColumn
                parent: rowDelegate.contentItem
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                RowLayout {
                    Layout.fillWidth: true
                    LabelPrim {
                        Layout.fillWidth: true
                        leftPadding: 8
                        text: model.Beschreibung
                    }
                    LabelNumber {
                        Layout.fillWidth: true
                        rightPadding: 8
                        horizontalAlignment: Text.AlignRight
                        precision: 0
                        unit: qsTr("g")
                        value: model.Menge
                    }
                }
                HorizontalDivider {}
            }
        }

        Loader {
            id: popuploader
            active: false
            onLoaded: item.open()
            sourceComponent: PopupBase {
                property variant _model: listView.currentItem.values
                onClosed: popuploader.active = false
                GridLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    columns: 3
                    columnSpacing: 16

                    Item {
                        property bool editing: false
                        id: itBeschreibung
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        height: children[1].height
                        LabelSubheader {
                            anchors.fill: parent
                            visible: !itBeschreibung.editing
                            text: _model.Beschreibung
                            horizontalAlignment: Text.AlignHCenter
                            MouseArea {
                                anchors.fill: parent
                                onClicked: itBeschreibung.editing = true
                            }
                        }
                        TextField {
                            anchors.fill: parent
                            visible: itBeschreibung.editing
                            horizontalAlignment: Text.AlignHCenter
                            text: _model.Beschreibung
                            onTextChanged: _model.Beschreibung = text
                            onEditingFinished: itBeschreibung.editing = false
                            onVisibleChanged: if (visible) forceActiveFocus()
                        }
                    }

                    LabelPrim {
                        text: qsTr("Menge")
                        Layout.fillWidth: true
                    }

                    TextFieldNumber {
                        Layout.preferredWidth: 60
                        min: 0.0
                        precision: 0
                        value: _model.Menge
                        onNewValue: _model.Menge = value
                    }

                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: qsTr("g")
                        Layout.fillWidth: true
                    }

                    LabelPrim {
                        text: qsTr("Alphasäure")
                        Layout.fillWidth: true
                    }

                    TextFieldNumber {
                        Layout.preferredWidth: 60
                        min: 0.0
                        precision: 1
                        value: _model.Alpha
                        onNewValue: _model.Alpha = value
                    }

                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: qsTr("%")
                        Layout.fillWidth: true
                    }

                    LabelPrim {
                        text: qsTr("Pellets")
                        Layout.fillWidth: true
                    }

                    CheckBox {
                        Layout.columnSpan: 2
                        Layout.alignment: Qt.AlignLeft
                        checked: _model.Pellets
                        onClicked: _model.Pellets = checked
                    }

                    LabelPrim {
                        text: qsTr("Typ")
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        model: ["", qsTr("Aroma"), qsTr("Bitter"), qsTr("Universal")]
                        currentIndex: _model.Typ
                        onActivated: _model.Typ = index
                    }

                    LabelPrim {
                        text: qsTr("Eigenschaften")
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }

                    TextArea {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Eigenschaften")
                        text: _model.Eigenschaften
                        onTextChanged: _model.Eigenschaften = text
                    }

                    LabelPrim {
                        text: qsTr("Bemerkung")
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                    }

                    TextArea {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: _model.Bemerkung
                        onTextChanged: _model.Bemerkung = text
                    }

                    LabelPrim {
                        text: qsTr("Preis")
                        Layout.fillWidth: true
                    }

                    TextFieldNumber {
                        Layout.preferredWidth: 60
                        min: 0.0
                        precision: 2
                        value: _model.Preis
                        onNewValue: _model.Preis = value
                    }

                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: Qt.locale().currencySymbol() + "/" + qsTr("kg")
                        Layout.fillWidth: true
                    }

                    LabelPrim {
                        text: qsTr("Eingelagert")
                        Layout.fillWidth: true
                    }

                    TextFieldDate {
                        Layout.columnSpan: 2
                        date: _model.Eingelagert
                        onNewDate: _model.Eingelagert = date
                    }

                    LabelPrim {
                        text: qsTr("Mindesthaltbar")
                        Layout.fillWidth: true
                    }

                    TextFieldDate {
                        Layout.columnSpan: 2
                        date: _model.Mindesthaltbar
                        onNewDate: _model.Mindesthaltbar = date
                    }
                }
            }
        }
    }
}
