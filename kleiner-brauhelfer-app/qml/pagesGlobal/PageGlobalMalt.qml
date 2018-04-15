import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff Malz")
    icon: "malt.png"

    component: ListView {
        id: listView
        clip: true
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        model: SortFilterProxyModel {
            id: myModel
            sourceModel: Brauhelfer.modelMalz
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
                popupEdit.open()
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
                        precision: 2
                        unit: qsTr("kg")
                        value: model.Menge
                    }
                }
                HorizontalDivider {}
            }
        }

        Popup {
            id: popupEdit
            parent: page
            width: parent.width - 40
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            onClosed: navPane.setFocus()

            background: Rectangle {
                color: Material.background
                radius: 10
                MouseArea {
                    anchors.fill: parent
                    onClicked: forceActiveFocus()
                }
            }

            GridLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                columns: 3
                //rows: 6
                //columnSpacing: 16

                LabelPrim {
                    Layout.fillWidth: true
                    Layout.columnSpan: 3
                    text: listView.currentItem.values.Beschreibung
                }

                LabelPrim {
                    text: qsTr("Menge")
                    Layout.fillWidth: true
                }

                TextFieldNumber {
                    Layout.preferredWidth: 60
                    min: 0.0
                    precision: 2
                    value: listView.currentItem.values.Menge
                    onNewValue: listView.currentItem.values.Menge = value
                }

                LabelPrim {
                    Layout.preferredWidth: 70
                    text: qsTr("kg")
                    Layout.fillWidth: true
                }

                LabelPrim {
                    text: qsTr("Farbe")
                    Layout.fillWidth: true
                }

                TextFieldNumber {
                    Layout.preferredWidth: 60
                    min: 0.0
                    precision: 2
                    value: listView.currentItem.values.Farbe
                    onNewValue: listView.currentItem.values.Farbe = value
                }

                LabelPrim {
                    Layout.preferredWidth: 70
                    text: qsTr("ebc")
                    Layout.fillWidth: true
                }

                LabelPrim {
                    text: qsTr("MaxProzent")
                    Layout.fillWidth: true
                }

                TextFieldNumber {
                    Layout.preferredWidth: 60
                    min: 0.0
                    precision: 2
                    value: listView.currentItem.values.MaxProzent
                    onNewValue: listView.currentItem.values.MaxProzent = value
                }

                LabelPrim {
                    Layout.preferredWidth: 70
                    text: qsTr("kg")
                    Layout.fillWidth: true
                }

                LabelPrim {
                    text: qsTr("Preis")
                    Layout.fillWidth: true
                }

                TextFieldNumber {
                    Layout.preferredWidth: 60
                    min: 0.0
                    precision: 2
                    value: listView.currentItem.values.Preis
                    onNewValue: listView.currentItem.values.Preis = value
                }

                LabelPrim {
                    Layout.preferredWidth: 70
                    text: qsTr("kg")
                    Layout.fillWidth: true
                }

                LabelPrim {
                    text: qsTr("Bemerkung")
                    Layout.fillWidth: true
                }

                TextField {
                    Layout.columnSpan: 2
                    text: listView.currentItem.values.Bemerkung
                    onTextChanged: {
                        listView.currentItem.values.Bemerkung = text
                        if (!activeFocus)
                            cursorPosition = 0
                    }
                }

                LabelPrim {
                    text: qsTr("Anwendung")
                    Layout.fillWidth: true
                }

                TextField {
                    Layout.columnSpan: 2
                    text: listView.currentItem.values.Anwendung
                    onTextChanged: {
                        listView.currentItem.values.Anwendung = text
                        if (!activeFocus)
                            cursorPosition = 0
                    }
                }

                LabelPrim {
                    text: qsTr("Eingelagert")
                    Layout.fillWidth: true
                }

                TextFieldDate {
                    Layout.columnSpan: 2
                    date: listView.currentItem.values.Eingelagert
                    onNewDate: listView.currentItem.values.Eingelagert = date
                }

                LabelPrim {
                    text: qsTr("Mindesthaltbar")
                    Layout.fillWidth: true
                }

                TextFieldDate {
                    Layout.columnSpan: 2
                    date: listView.currentItem.values.Mindesthaltbar
                    onNewDate: listView.currentItem.values.Mindesthaltbar = date
                }
            }
        }
    }
}
