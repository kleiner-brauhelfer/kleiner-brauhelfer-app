import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff Hefe")
    icon: "yeast.png"

    component: ListView {
        id: listView
        clip: true
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        model: SortFilterProxyModel {
            id: myModel
            sourceModel: Brauhelfer.modelHefe
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
            height: btnAdd.height + 12
            color: Material.background
            Flow {
                width: parent.width
                RadioButton {
                    checked: true
                    text: qsTr("alle")
                    onClicked: myModel.filterRegExp = /(?:)/
                }
                RadioButton {
                    text: qsTr("vorhanden")
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

            NumberAnimation {
                id: removeFake
                target: rowDelegate
                property: "height"
                to: 0
                easing.type: Easing.InOutQuad
                onStopped: rowDelegate.visible = false
            }

            function remove() {
                removeFake.start()
                listView.model.sourceModel.remove(index)
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
                onOpened: if (_model.Beschreibung !== "") tfMenge.forceActiveFocus()
                onClosed: popuploader.active = false

                function remove() {
                    listView.currentItem.remove()
                    close()
                }

                GridLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    columns: 3
                    columnSpacing: 16

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
                                onTextChanged: if (activeFocus) _model.Beschreibung = text
                                onEditingFinished: itBeschreibung.editing = false
                                onVisibleChanged: if (visible) forceActiveFocus()
                            }

                            Component.onCompleted: if (_model.Beschreibung === "") editing = true
                        }

                        ToolButton {
                            id: btnRemove
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            onClicked: remove()
                            contentItem: Image {
                                source: "qrc:/images/ic_delete.png"
                                anchors.centerIn: parent
                            }
                        }
                    }

                    LabelPrim {
                        text: qsTr("Menge")
                        Layout.fillWidth: true
                    }

                    TextFieldNumber {
                        id: tfMenge
                        Layout.preferredWidth: 60
                        min: 0.0
                        precision: 0
                        value: _model.Menge
                        onNewValue: _model.Menge = value
                    }

                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: ""
                        Layout.fillWidth: true
                    }

                    LabelPrim {
                        text: qsTr("Würzemenge")
                        Layout.fillWidth: true
                    }

                    TextFieldNumber {
                        Layout.preferredWidth: 60
                        min: 0.0
                        precision: 0
                        value: _model.Wuerzemenge
                        onNewValue: _model.Wuerzemenge = value
                    }

                    LabelPrim {
                        Layout.preferredWidth: 70
                        text: qsTr("Liter")
                        Layout.fillWidth: true
                    }

                    LabelPrim {
                        text: qsTr("OG / UG")
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        model: [ "", qsTr("obergärig"), qsTr("untergärig")]
                        currentIndex: _model.TypOGUG
                        onActivated: _model.TypOGUG = index
                    }

                    LabelPrim {
                        text: qsTr("Trocken / flüssig")
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        model: [ "", qsTr("trocken"), qsTr("flüssig")]
                        currentIndex: _model.TypTrFl
                        onActivated: _model.TypTrFl = index
                    }

                    LabelPrim {
                        text: qsTr("Verpackungsmenge")
                        Layout.fillWidth: true
                    }

                    TextField {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        text: _model.Verpackungsmenge
                        onTextChanged: if (activeFocus) _model.Verpackungsmenge = text
                    }

                    LabelPrim {
                        text: qsTr("Sedimentation")
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        model: [ "", qsTr("hoch"), qsTr("mittel"), qsTr("niedrig")]
                        currentIndex: _model.SED
                        onActivated: _model.SED = index
                    }

                    LabelPrim {
                        text: qsTr("Vergärungsgrad")
                        Layout.fillWidth: true
                    }

                    TextField {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        text: _model.EVG
                        onTextChanged: if (activeFocus) _model.EVG = text
                    }

                    LabelPrim {
                        text: qsTr("Temperaturbereich")
                        Layout.fillWidth: true
                    }

                    TextField {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        text: _model.Temperatur
                        onTextChanged: if (activeFocus) _model.Temperatur = text
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
                        onTextChanged: if (activeFocus) _model.Eigenschaften = text
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
                        onTextChanged: if (activeFocus) _model.Bemerkung = text
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

        FloatingButton {
            id: btnAdd
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.bottom: listView.bottom
            anchors.bottomMargin: 8
            imageSource: "qrc:/images/ic_add_white.png"
            visible: !page.readOnly
            onClicked: {
                listView.model.sourceModel.append()
                listView.currentIndex = listView.count - 1
                popuploader.active = true
            }
        }
    }
}
