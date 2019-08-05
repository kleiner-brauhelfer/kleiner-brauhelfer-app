import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Dialogs 1.3

import "../common"
import brauhelfer 1.0
import ProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff Wasser")
    icon: "water.png"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TextFieldBase {
            id: tfFilter
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            placeholderText: qsTr("Suche")
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhLowercaseOnly
            onTextChanged: listView.model.setFilterString(text)
        }

        ListView {
            id: listView
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            boundsBehavior: Flickable.OvershootBounds
            model: ProxyModel {
                sourceModel: Brauhelfer.modelWasser
                sortOrder: Qt.AscendingOrder
                sortColumn: fieldIndex("Name")
                filterKeyColumn: fieldIndex("Name")
            }
            headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
            ScrollIndicator.vertical: ScrollIndicator {}
            header: Rectangle {
                z: 2
                width: parent.width
                height: header.height
                color: Material.background
                ColumnLayout {
                    id: header
                    width: parent.width
                    spacing: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Wasserprofil")
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var col = listView.model.fieldIndex("Name")
                                    if (listView.model.sortColumn === col) {
                                        if (listView.model.sortOrder === Qt.AscendingOrder)
                                            listView.model.sortOrder = Qt.DescendingOrder
                                        else
                                            listView.model.sortOrder = Qt.AscendingOrder
                                    }
                                    else {
                                        listView.model.sortColumn = col
                                    }
                                }
                            }
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            font.bold: true
                            text: qsTr("Restalkalität")
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var col = listView.model.fieldIndex("Restalkalitaet")
                                    if (listView.model.sortColumn === col) {
                                        if (listView.model.sortOrder === Qt.AscendingOrder)
                                            listView.model.sortOrder = Qt.DescendingOrder
                                        else
                                            listView.model.sortOrder = Qt.AscendingOrder
                                    }
                                    else {
                                        listView.model.sortColumn = col
                                    }
                                }
                            }
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                        height: 2
                    }
                }
            }
            delegate: ItemDelegate {
                id: rowDelegate
                width: parent.width
                height: dataColumn.implicitHeight
                padding: 0
                text: " "
                onClicked: {
                    listView.currentIndex = index
                    popuploader.active = true
                }

                NumberAnimation {
                    property int index : listView.currentIndex
                    id: removeFake
                    target: rowDelegate
                    property: "height"
                    to: 0
                    easing.type: Easing.InOutQuad
                    onStopped: {
                        rowDelegate.visible = false
                        listView.model.removeRow(index)
                    }
                }

                function remove() {
                    popuploader.active = false
                    removeFake.start()
                }

                ColumnLayout {
                    id: dataColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            text: model.Name
                        }
                        LabelNumber {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            precision: 2
                            unit: qsTr("°dH")
                            value: model.Restalkalitaet
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                }
            }

            Loader {
                id: popuploader
                active: false
                onLoaded: item.open()
                sourceComponent: PopupBase {
                    onClosed: popuploader.active = false
                    SwipeView {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        spacing: 16
                        height: contentChildren[currentIndex].implicitHeight + 2 * anchors.margins
                        clip: true
                        currentIndex: listView.currentIndex
                        onCurrentIndexChanged: listView.currentIndex = currentIndex
                        Repeater {
                            model: listView.model
                            Loader {
                                active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                                sourceComponent: Item {
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
                                        columns: 3
                                        columnSpacing: 0
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.columnSpan: 3

                                            Item {
                                                width: btnRemove.width
                                            }

                                            Item {
                                                property bool editing: false
                                                id: itBeschreibung
                                                Layout.fillWidth: true
                                                height: children[1].height
                                                LabelSubheader {
                                                    anchors.fill: parent
                                                    visible: !itBeschreibung.editing
                                                    text: model.Name
                                                    horizontalAlignment: Text.AlignHCenter
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        onClicked: itBeschreibung.editing = true
                                                    }
                                                }
                                                TextFieldBase {
                                                    anchors.fill: parent
                                                    visible: itBeschreibung.editing
                                                    horizontalAlignment: Text.AlignHCenter
                                                    text: model.Name
                                                    onTextChanged: if (activeFocus) model.Name = text
                                                    onEditingFinished: itBeschreibung.editing = false
                                                    onVisibleChanged: if (visible) forceActiveFocus()
                                                }

                                                Component.onCompleted: if (model.Name === "") editing = true
                                            }

                                            ToolButton {
                                                id: btnRemove
                                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                                onClicked: listView.currentItem.remove()
                                                contentItem: Image {
                                                    source: "qrc:/images/ic_delete.png"
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Calcium")
                                        }

                                        SpinBoxReal {
                                            decimals: 2
                                            realValue: model.Calcium
                                            onNewValue: model.Calcium = value
                                        }

                                        LabelUnit {
                                            text: qsTr("mg/l")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: ""
                                        }

                                        SpinBoxReal {
                                            decimals: 3
                                            realValue: model.CalciumMmol
                                            onNewValue: model.CalciumMmol = value
                                        }

                                        LabelUnit {
                                            text: qsTr("mmol/l")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Calciumhärte")
                                        }

                                        LabelNumber {
                                            Layout.alignment: Qt.AlignHCenter
                                            precision: 2
                                            value: model.Calciumhaerte
                                        }

                                        LabelUnit {
                                            text: qsTr("°dH")
                                        }

                                        HorizontalDivider {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Magnesium")
                                        }

                                        SpinBoxReal {
                                            decimals: 2
                                            realValue: model.Magnesium
                                            onNewValue: model.Magnesium = value
                                        }

                                        LabelUnit {
                                            text: qsTr("mg/l")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: ""
                                        }

                                        SpinBoxReal {
                                            decimals: 3
                                            realValue: model.MagnesiumMmol
                                            onNewValue: model.MagnesiumMmol = value
                                        }

                                        LabelUnit {
                                            text: qsTr("mmol/l")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Magnesiumhärte")
                                        }

                                        LabelNumber {
                                            Layout.alignment: Qt.AlignHCenter
                                            precision: 2
                                            value: model.Magnesiumhaerte
                                        }

                                        LabelUnit {
                                            text: qsTr("°dH")
                                        }

                                        HorizontalDivider {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Säurekapazität")
                                        }

                                        SpinBoxReal {
                                            decimals: 2
                                            realValue: model.Saeurekapazitaet
                                            onNewValue: model.Saeurekapazitaet = value
                                        }

                                        LabelUnit {
                                            text: qsTr("mmol/l")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Carbonathärte")
                                        }

                                        SpinBoxReal {
                                            decimals: 2
                                            realValue: model.Carbonathaerte
                                            onNewValue: model.Carbonathaerte = value
                                        }

                                        LabelUnit {
                                            text: qsTr("°dH")
                                        }

                                        HorizontalDivider {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Restalkalität")
                                        }

                                        LabelNumber {
                                            Layout.alignment: Qt.AlignHCenter
                                            precision: 2
                                            value: model.Restalkalitaet
                                        }

                                        LabelUnit {
                                            text: qsTr("°dH")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            FloatingButton {
                id: btnAdd
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.bottom: listView.bottom
                anchors.bottomMargin: 8
                imageSource: "qrc:/images/ic_add_white.png"
                visible: !page.readOnly
                onClicked: {
                    tfFilter.text = ""
                    listView.currentIndex = listView.model.append()
                    popuploader.active = true
                }
            }
        }
    }
}
