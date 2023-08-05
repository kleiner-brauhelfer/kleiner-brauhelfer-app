import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt.labs.platform

import "../common"
import brauhelfer
import ProxyModelRohstoff

PageBase {
    id: page
    title: qsTr("Rohstoff Hopfen")
    icon: "hops.png"
    readOnly: Brauhelfer.readonly || app.settings.readonly

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
            model: ProxyModelRohstoff {
                sourceModel: Brauhelfer.modelHopfen
                sortOrder: Qt.AscendingOrder
                sortColumn: fieldIndex("Name")
                filter: app.settings.ingredientsFilter
            }
            //headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
            ScrollIndicator.vertical: ScrollIndicator {}
            header: Rectangle {
                property int widthCol1: headerLabel1.width
                z: 2
                width: listView.width
                height: header.height
                color: Material.background
                ColumnLayout {
                    id: header
                    width: parent.width
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
                            text: qsTr("Name")
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
                            text: qsTr("Menge [g]")
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var col = listView.model.fieldIndex("Menge")
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
            footerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackFooter : ListView.OverlayFooter
            footer: Rectangle {
                z: 2
                width: listView.width
                height: btnAdd.height + 12
                color: Material.background
                Flow {
                    anchors.verticalCenter: parent.verticalCenter
                    RadioButton {
                        checked: app.settings.ingredientsFilter === ProxyModelRohstoff.Alle
                        text: qsTr("alle")
                        onClicked: app.settings.ingredientsFilter = ProxyModelRohstoff.Alle
                    }
                    RadioButton {
                        checked: app.settings.ingredientsFilter === ProxyModelRohstoff.Vorhanden
                        text: qsTr("vorhanden")
                        onClicked: app.settings.ingredientsFilter = ProxyModelRohstoff.Vorhanden
                    }
                    RadioButton {
                        checked: app.settings.ingredientsFilter === ProxyModelRohstoff.InGebrauch
                        text: qsTr("in Gebrauch")
                        onClicked: app.settings.ingredientsFilter = ProxyModelRohstoff.InGebrauch
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
                            id: tfName
                            Layout.fillWidth: true
                            opacity: model.Menge > 0 ? app.config.textOpacityFull : app.config.textOpacityHalf
                            text: model.Name
                            font.italic: model.InGebrauch
                            states: State {
                                when: model.Menge > 0 && model.Mindesthaltbar < new Date()
                                PropertyChanges { target: tfName; color: Material.accent }
                            }
                        }
                        LabelNumber {
                            Layout.preferredWidth: listView.headerItem.widthCol1
                            horizontalAlignment: Text.AlignHCenter
                            opacity: model.Menge > 0 ? app.config.textOpacityFull : app.config.textOpacityHalf
                            precision: 1
                            value: model.Menge
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                }
            }

            MessageDialog {
                id: messageDialogDelete
                text: qsTr("Rohstoff kann nicht gelöscht werden.")
                informativeText: qsTr("Der Rohstoff wird von einem nichtgebrauten Sud verwendet.")
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
                                        columns: 3
                                        columnSpacing: 0
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
                                                    font.italic: model.InGebrauch
                                                    horizontalAlignment: Text.AlignHCenter
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
                                                onClicked: {
                                                    if (model.InGebrauch)
                                                        messageDialogDelete.open()
                                                    else
                                                        listView.currentItem.remove()
                                                }
                                                contentItem: Image {
                                                    source: "qrc:/images/ic_delete.png"
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Menge")
                                        }

                                        SpinBoxReal {
                                            decimals: 1
                                            enabled: !page.readOnly
                                            realValue: model.Menge
                                            onNewValue: model.Menge = value
                                        }

                                        LabelUnit {
                                            text: qsTr("g")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Alpha")
                                        }

                                        SpinBoxReal {
                                            decimals: 1
                                            enabled: !page.readOnly
                                            realValue: model.Alpha
                                            onNewValue: model.Alpha = value
                                        }

                                        LabelUnit {
                                            text: qsTr("%")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Pellets")
                                        }

                                        CheckBoxBase {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignLeft
                                            enabled: !page.readOnly
                                            checked: model.Pellets
                                            onClicked: model.Pellets = checked
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Typ")
                                        }

                                        ComboBoxBase {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            Layout.rightMargin: 4
                                            model: ["", qsTr("Aroma"), qsTr("Bitter"), qsTr("Universal")]
                                            enabled: !page.readOnly
                                            currentIndex: _model.Typ
                                            onActivated: _model.Typ = index
                                        }

                                        HorizontalDivider {
                                            Layout.fillWidth: true
                                            Layout.columnSpan: 3
                                        }

                                        LabelPrim {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Eigenschaften")
                                        }

                                        TextAreaBase {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            wrapMode: TextArea.Wrap
                                            placeholderText: qsTr("Eigenschaften")
                                            enabled: !page.readOnly
                                            text: model.Eigenschaften
                                            onTextChanged: if (activeFocus) model.Eigenschaften = text
                                        }

                                        LabelPrim {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Bemerkung")
                                        }

                                        TextAreaBase {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            wrapMode: TextArea.Wrap
                                            placeholderText: qsTr("Bemerkung")
                                            enabled: !page.readOnly
                                            text: model.Bemerkung
                                            onTextChanged: if (activeFocus) model.Bemerkung = text
                                        }

                                        LabelPrim {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Alternativen")
                                        }

                                        TextAreaBase {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            wrapMode: TextArea.Wrap
                                            placeholderText: qsTr("Alternativen")
                                            enabled: !page.readOnly
                                            text: model.Alternativen
                                            onTextChanged: if (activeFocus) model.Alternativen = text
                                        }

                                        HorizontalDivider {
                                            Layout.fillWidth: true
                                            Layout.columnSpan: 3
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Preis")
                                        }

                                        SpinBoxReal {
                                            decimals: 2
                                            enabled: !page.readOnly
                                            realValue: model.Preis
                                            onNewValue: model.Preis = value
                                        }

                                        LabelUnit {
                                            text: Qt.locale().currencySymbol() + "/" + qsTr("kg")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Eingelagert")
                                        }

                                        TextFieldDate {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignHCenter
                                            Layout.columnSpan: 2
                                            enabled: model.Menge > 0 && !page.readOnly
                                            date: model.Eingelagert
                                            onNewDate: model.Eingelagert = date
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Haltbar")
                                        }

                                        TextFieldDate {
                                            id: tfMindesthaltbar
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignHCenter
                                            Layout.columnSpan: 2
                                            enabled: model.Menge > 0 && !page.readOnly
                                            date: model.Mindesthaltbar
                                            onNewDate: model.Mindesthaltbar = date
                                            states: State {
                                                when: tfMindesthaltbar.enabled && tfMindesthaltbar.date < new Date()
                                                PropertyChanges { target: tfMindesthaltbar; color: Material.accent }
                                            }
                                        }

                                        HorizontalDivider {
                                            Layout.fillWidth: true
                                            Layout.columnSpan: 3
                                        }

                                        TextFieldBase {
                                            Layout.fillWidth: true
                                            Layout.columnSpan: 3
                                            placeholderText: qsTr("Link")
                                            text: model.Link
                                            onTextChanged: if (activeFocus) model.Link = text
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
                    app.settings.ingredientsFilter = ProxyModelRohstoff.Alle
                    tfFilter.text = ""
                    listView.currentIndex = listView.model.append()
                    popuploader.active = true
                }
            }
        }
    }
}
