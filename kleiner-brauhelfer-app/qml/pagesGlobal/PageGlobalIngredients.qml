import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff w. Zutaten")
    icon: "ingredients.png"

    component: ListView {
        id: listView
        clip: true
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        model: SortFilterProxyModel {
            sourceModel: Brauhelfer.modelWeitereZutaten
            filterKeyColumn: sourceModel.fieldIndex("Menge")
            filterRegExp: app.settings.ingredientsFilter === 0 ? /(?:)/ : /[^0]+/
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
                    checked: app.settings.ingredientsFilter === 0
                    text: qsTr("alle")
                    onClicked: app.settings.ingredientsFilter = 0
                }
                RadioButton {
                    checked: app.settings.ingredientsFilter === 1
                    text: qsTr("vorhanden")
                    onClicked: app.settings.ingredientsFilter = 1
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
                        opacity: model.Menge > 0 ? app.config.textOpacityFull : app.config.textOpacityHalf
                        text: model.Beschreibung
                    }
                    LabelNumber {
                        Layout.fillWidth: true
                        rightPadding: 8
                        horizontalAlignment: Text.AlignRight
                        opacity: model.Menge > 0 ? app.config.textOpacityFull : app.config.textOpacityHalf
                        precision: 2
                        unit: model.Einheiten === 0 ? qsTr("kg") : qsTr("g")
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
                        rightPadding: 8
                        text: qsTr("Menge")
                        font.weight: Font.DemiBold
                    }

                    SpinBoxReal {
                        Layout.fillWidth: true
                        decimals: 2
                        realValue: _model.Menge
                        onRealValueChanged: _model.Menge = realValue
                    }

                    ComboBox {
                        Layout.preferredWidth: 70
                        model: [qsTr("kg"), qsTr("g")]
                        currentIndex: _model.Einheiten
                        onActivated: _model.Einheiten = index
                    }

                    LabelPrim {
                        rightPadding: 8
                        text: qsTr("Typ")
                        font.weight: Font.DemiBold
                    }

                    ComboBox {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        model: [ qsTr("Honig"), qsTr("Zucker"), qsTr("Gewürz"), qsTr("Frucht"), qsTr("Sonstiges")]
                        currentIndex: _model.Typ
                        onActivated: _model.Typ = index
                    }

                    LabelPrim {
                        rightPadding: 8
                        text: qsTr("Ausbeute")
                        font.weight: Font.DemiBold
                    }

                    SpinBoxReal {
                        Layout.fillWidth: true
                        decimals: 0
                        realValue: _model.Ausbeute
                        onRealValueChanged: _model.Ausbeute = realValue
                    }

                    LabelSec {
                        text: qsTr("%")
                    }

                    LabelPrim {
                        rightPadding: 8
                        text: qsTr("Farbe")
                        font.weight: Font.DemiBold
                    }

                    SpinBoxReal {
                        Layout.fillWidth: true
                        decimals: 1
                        realValue: _model.EBC
                        onRealValueChanged: _model.EBC = realValue
                    }

                    LabelSec {
                        text: qsTr("EBC")
                    }

                    LabelPrim {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        rightPadding: 8
                        text: qsTr("Bemerkung")
                        font.weight: Font.DemiBold
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
                        rightPadding: 8
                        text: qsTr("Preis")
                        font.weight: Font.DemiBold
                    }

                    SpinBoxReal {
                        Layout.fillWidth: true
                        decimals: 2
                        realValue: _model.Preis
                        onRealValueChanged: _model.Preis = realValue
                    }

                    LabelSec {
                        text: Qt.locale().currencySymbol()
                    }

                    LabelPrim {
                        rightPadding: 8
                        text: qsTr("Eingelagert")
                        font.weight: Font.DemiBold
                    }

                    TextFieldDate {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        date: _model.Eingelagert
                        onNewDate: _model.Eingelagert = date
                    }

                    LabelPrim {
                        rightPadding: 8
                        text: qsTr("Haltbar")
                        font.weight: Font.DemiBold
                    }

                    TextFieldDate {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
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
