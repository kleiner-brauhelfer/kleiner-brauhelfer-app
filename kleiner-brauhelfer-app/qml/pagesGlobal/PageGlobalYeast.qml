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
    title: qsTr("Rohstoff Hefe")
    icon: "yeast.png"
    readOnly: Brauhelfer.readonly || app.settings.readonly

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TextFieldBase {
            id: tfFilter
            Layout.fillWidth: true
            Layout.margins: 8
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
            onMovementStarted: forceActiveFocus()
            model: ProxyModelRohstoff {
                sourceModel: Brauhelfer.modelHefe
                sortOrder: Qt.AscendingOrder
                sortColumn: fieldIndex("Name")
                filter: app.settings.ingredientsFilter
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
                                    forceActiveFocus();
                                }
                            }
                        }
                        LabelPrim {
                            id: headerLabel1
                            horizontalAlignment: Text.AlignHCenter
                            font.bold: true
                            text: qsTr("Menge")
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
                                    forceActiveFocus();
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
                height: layoutFooter.height
                color: Material.background
                RowLayout {
                    id: layoutFooter
                    spacing: 8
                    RadioButtonBase {
                        Layout.leftMargin: 8
                        checked: app.settings.ingredientsFilter === ProxyModelRohstoff.Alle
                        text: qsTr("alle")
                        onClicked: app.settings.ingredientsFilter = ProxyModelRohstoff.Alle
                    }
                    RadioButtonBase {
                        checked: app.settings.ingredientsFilter === ProxyModelRohstoff.Vorhanden
                        text: qsTr("vorhanden")
                        onClicked: app.settings.ingredientsFilter = ProxyModelRohstoff.Vorhanden
                    }
                    RadioButtonBase {
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
                            precision: 0
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
                                                    font.italic: model.InGebrauch
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
                                            decimals: 0
                                            enabled: !page.readOnly
                                            realValue: model.Menge
                                            onNewValue: (value) => model.Menge = value
                                        }

                                        LabelUnit {
                                            text: ""
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Würzemenge")
                                        }

                                        SpinBoxReal {
                                            decimals: 0
                                            enabled: !page.readOnly
                                            realValue: model.Wuerzemenge
                                            onNewValue: (value) => model.Wuerzemenge = value
                                        }

                                        LabelUnit {
                                            text: qsTr("l")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("OG / UG")
                                        }

                                        ComboBoxBase {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            Layout.rightMargin: 4
                                            model: [ "", qsTr("obergärig"), qsTr("untergärig")]
                                            enabled: !page.readOnly
                                            currentIndex: _model.TypOGUG
                                            onActivated: (index) => _model.TypOGUG = index
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Trocken / flüssig")
                                        }

                                        ComboBoxBase {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            Layout.rightMargin: 4
                                            model: [ "", qsTr("trocken"), qsTr("flüssig")]
                                            enabled: !page.readOnly
                                            currentIndex: _model.TypTrFl
                                            onActivated: (index) =>_model.TypTrFl = index
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Sedimentation")
                                        }

                                        TextFieldBase {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            enabled: !page.readOnly
                                            text: model.Sedimentation
                                            onTextChanged: if (activeFocus) model.Sedimentation = text
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Vergärungsgrad")
                                        }

                                        TextFieldBase {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            enabled: !page.readOnly
                                            text: model.EVG
                                            onTextChanged: if (activeFocus) model.EVG = text
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Temperatur")
                                        }

                                        TextFieldBase {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            enabled: !page.readOnly
                                            text: model.Temperatur
                                            onTextChanged: if (activeFocus) model.Temperatur = text
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

                                        TextAreaBase {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            wrapMode: TextArea.Wrap
                                            placeholderText: qsTr("Bemerkung")
                                            enabled: !page.readOnly
                                            text: model.Bemerkung
                                            onTextChanged: if (activeFocus) model.Bemerkung = text
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

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Preis")
                                        }

                                        SpinBoxReal {
                                            decimals: 2
                                            enabled: !page.readOnly
                                            realValue: model.Preis
                                            onNewValue: (value) => model.Preis = value
                                        }

                                        LabelUnit {
                                            text: Qt.locale().currencySymbol()
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
                                            onNewDate: (date) => model.Eingelagert = date
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
                                            onNewDate: (date) => model.Mindesthaltbar = date
                                            states: State {
                                                when: tfMindesthaltbar.enabled && tfMindesthaltbar.date < new Date()
                                                PropertyChanges { target: tfMindesthaltbar; color: Material.accent }
                                            }
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
