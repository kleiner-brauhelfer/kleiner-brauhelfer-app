import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.Dialogs 1.3

import "../common"
import brauhelfer 1.0
import ProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff Wasser")
    icon: "water.png"

    ListView {
        id: listView
        //clip: true
        anchors.fill: parent
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
            width: listView.width
            height: header.height
            color: Material.background
            ColumnLayout {
                id: header
                width: listView.width
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
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignHCenter
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
            width: listView.width
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
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignHCenter
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
                                            id: itName
                                            Layout.fillWidth: true
                                            height: children[1].height
                                            LabelSubheader {
                                                anchors.fill: parent
                                                visible: !itName.editing
                                                text: model.Name
                                                horizontalAlignment: Text.AlignHCenter
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: itName.editing = true
                                                }
                                            }
                                            TextFieldBase {
                                                anchors.fill: parent
                                                visible: itName.editing
                                                horizontalAlignment: Text.AlignHCenter
                                                text: model.Name
                                                onTextChanged: if (activeFocus) model.Name = text
                                                onEditingFinished: itName.editing = false
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
                                        text: ""
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        min: 0
                                        max: 99
                                        realValue: model.CalciumHaerte
                                        onNewValue: model.CalciumHaerte = value
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
                                        text: ""
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        min: 0
                                        max: 99
                                        realValue: model.MagnesiumHaerte
                                        onNewValue: model.MagnesiumHaerte = value
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
                                        text: qsTr("Hydrogencarbonat")
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        realValue: model.Hydrogencarbonat
                                        onNewValue: model.Hydrogencarbonat = value
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
                                        realValue: model.HydrogencarbonatMmol
                                        onNewValue: model.HydrogencarbonatMmol = value
                                    }

                                    LabelUnit {
                                        text: qsTr("mmol/l")
                                    }

                                    LabelPrim {
                                        Layout.fillWidth: true
                                        rightPadding: 8
                                        text: ""
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        min: 0
                                        max: 99
                                        realValue: model.CarbonatHaerte
                                        onNewValue: model.CarbonatHaerte = value
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
                                        text: qsTr("Sulfat")
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        realValue: model.Sulfat
                                        onNewValue: model.Sulfat = value
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
                                        realValue: model.SulfatMmol
                                        onNewValue: model.SulfatMmol = value
                                    }

                                    LabelUnit {
                                        text: qsTr("mmol/l")
                                    }

                                    HorizontalDivider {
                                        Layout.columnSpan: 3
                                        Layout.fillWidth: true
                                    }

                                    LabelPrim {
                                        Layout.fillWidth: true
                                        rightPadding: 8
                                        text: qsTr("Chlorid")
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        realValue: model.Chlorid
                                        onNewValue: model.Chlorid = value
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
                                        realValue: model.ChloridMmol
                                        onNewValue: model.ChloridMmol = value
                                    }

                                    LabelUnit {
                                        text: qsTr("mmol/l")
                                    }

                                    HorizontalDivider {
                                        Layout.columnSpan: 3
                                        Layout.fillWidth: true
                                    }

                                    LabelPrim {
                                        Layout.fillWidth: true
                                        rightPadding: 8
                                        text: qsTr("Natrium")
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        realValue: model.Natrium
                                        onNewValue: model.Natrium = value
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
                                        realValue: model.NatriumMmol
                                        onNewValue: model.NatriumMmol = value
                                    }

                                    LabelUnit {
                                        text: qsTr("mmol/l")
                                    }

                                    HorizontalDivider {
                                        Layout.columnSpan: 3
                                        Layout.fillWidth: true
                                    }

                                    LabelPrim {
                                        Layout.fillWidth: true
                                        rightPadding: 8
                                        text: qsTr("Korrektur")
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        min: -99
                                        max: 99
                                        realValue: model.RestalkalitaetAdd
                                        onNewValue: model.RestalkalitaetAdd = value
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
                listView.currentIndex = listView.model.append()
                popuploader.active = true
            }
        }
    }
}
