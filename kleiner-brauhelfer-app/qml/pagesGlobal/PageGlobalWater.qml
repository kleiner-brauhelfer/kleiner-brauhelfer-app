import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt.labs.platform

import "../common"
import brauhelfer
import ProxyModel

PageBase {
    id: page
    title: qsTr("Wasserprofile")
    icon: "water.png"
    readOnly: Brauhelfer.readonly || app.settings.readonly

    ListView {
        id: listView
        clip: true
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
            property int widthCol1: headerLabel1.width
            z: 2
            width: listView.width
            height: header.height
            color: Material.background
            ColumnLayout {
                id: header
                width: listView.width
                spacing: 8
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
                        id: headerLabel1
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        text: qsTr("Restalkalität (°dH)")
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
                        Layout.preferredWidth: listView.headerItem.widthCol1
                        horizontalAlignment: Text.AlignHCenter
                        precision: 2
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
                    clip: true
                    currentIndex: listView.currentIndex
                    onCurrentIndexChanged: listView.currentIndex = currentIndex
                    Repeater {
                        model: listView.model
                        Loader {
                            active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                            sourceComponent: Item {
                                implicitHeight: layout.height + 16
                                MouseAreaCatcher { }
                                GridLayout {
                                    id: layout
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    columns: 3
                                    columnSpacing: 8
                                    rowSpacing: 16
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.columnSpan: 3

                                        Item {
                                            width: btnRemove.width
                                            visible: !page.readOnly
                                        }

                                        Item {
                                            property bool editing: false
                                            id: itName
                                            Layout.fillWidth: true
                                            height: children[1].height
                                            LabelHeader {
                                                anchors.fill: parent
                                                visible: !itName.editing
                                                text: model.Name
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                MouseArea {
                                                    anchors.fill: parent
                                                    enabled: !page.readOnly
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
                                            visible: !page.readOnly
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
                                        enabled: !page.readOnly
                                        realValue: model.Calcium
                                        onNewValue: (value) => model.Calcium = value
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
                                        enabled: !page.readOnly
                                        realValue: model.CalciumMmol
                                        onNewValue: (value) => model.CalciumMmol = value
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
                                        enabled: !page.readOnly
                                        realValue: model.CalciumHaerte
                                        onNewValue: (value) => model.CalciumHaerte = value
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
                                        enabled: !page.readOnly
                                        realValue: model.Magnesium
                                        onNewValue: (value) => model.Magnesium = value
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
                                        enabled: !page.readOnly
                                        realValue: model.MagnesiumMmol
                                        onNewValue: (value) => model.MagnesiumMmol = value
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
                                        enabled: !page.readOnly
                                        realValue: model.MagnesiumHaerte
                                        onNewValue: (value) => model.MagnesiumHaerte = value
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
                                        text: qsTr("Natrium")
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        enabled: !page.readOnly
                                        realValue: model.Natrium
                                        onNewValue: (value) => model.Natrium = value
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
                                        enabled: !page.readOnly
                                        realValue: model.NatriumMmol
                                        onNewValue: (value) => model.NatriumMmol = value
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
                                        text: qsTr("Sulfat")
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        enabled: !page.readOnly
                                        realValue: model.Sulfat
                                        onNewValue: (value) => model.Sulfat = value
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
                                        enabled: !page.readOnly
                                        realValue: model.SulfatMmol
                                        onNewValue: (value) => model.SulfatMmol = value
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
                                        enabled: !page.readOnly
                                        realValue: model.Chlorid
                                        onNewValue: (value) => model.Chlorid = value
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
                                        enabled: !page.readOnly
                                        realValue: model.ChloridMmol
                                        onNewValue: (value) => model.ChloridMmol = value
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
                                        text: qsTr("Hydrogencarbonat")
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        enabled: !page.readOnly
                                        realValue: model.Hydrogencarbonat
                                        onNewValue: (value) => model.Hydrogencarbonat = value
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
                                        enabled: !page.readOnly
                                        realValue: model.HydrogencarbonatMmol
                                        onNewValue: (value) => model.HydrogencarbonatMmol = value
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
                                        enabled: !page.readOnly
                                        realValue: model.CarbonatHaerte
                                        onNewValue: (value) => model.CarbonatHaerte = value
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
                                        text: qsTr("Korrektur")
                                    }

                                    SpinBoxReal {
                                        decimals: 2
                                        min: -99
                                        max: 99
                                        enabled: !page.readOnly
                                        realValue: model.RestalkalitaetAdd
                                        onNewValue: (value) => model.RestalkalitaetAdd = value
                                    }

                                    LabelUnit {
                                        text: qsTr("°dH")
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

                                    HorizontalDivider {
                                        Layout.columnSpan: 3
                                        Layout.fillWidth: true
                                    }

                                    TextAreaBase {
                                        Layout.columnSpan: 3
                                        Layout.fillWidth: true
                                        placeholderText: qsTr("Bemerkung")
                                        textFormat: Text.RichText
                                        enabled: !page.readOnly
                                        text: model.Bemerkung
                                        onLinkActivated: (link) => Qt.openUrlExternally(link)
                                        onTextChanged: if (activeFocus) model.Bemerkung = text
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
