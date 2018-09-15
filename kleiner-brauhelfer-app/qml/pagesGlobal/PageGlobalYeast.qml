import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Dialogs 1.3

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff Hefe")
    icon: "yeast.png"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TextFieldBase {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            placeholderText: qsTr("Suche")
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhLowercaseOnly
            onTextChanged: listView.model.filterRegExp = new RegExp(text + "(.*)", "i")
        }

        ListView {
            id: listView
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            boundsBehavior: Flickable.OvershootBounds
            model: SortFilterProxyModel {
                sourceModel: Brauhelfer.modelHefe
                filterKeyColumn: sourceModel.fieldIndex("Beschreibung")
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
                        Layout.topMargin: 8
                        Layout.bottomMargin: 4
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        LabelPrim {
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("Beschreibung")
                        }
                        LabelPrim {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            font.bold: true
                            text: qsTr("Menge")
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
                width: parent.width
                height: btnAdd.height + 12
                color: Material.background
                Flow {
                    anchors.verticalCenter: parent.verticalCenter
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
                id: rowDelegate
                visible: (app.settings.ingredientsFilter === 0 || model.Menge > 0) && !model.deleted
                width: parent.width
                height: visible ? dataColumn.implicitHeight : 0
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
                    listView.model.sourceModel.remove(listView.model.mapRowToSource(index))
                }

                ColumnLayout {
                    id: dataColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 4
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        LabelPrim {
                            id: tfBeschreibung
                            Layout.fillWidth: true
                            opacity: model.Menge > 0 ? app.config.textOpacityFull : app.config.textOpacityHalf
                            text: model.Beschreibung
                            states: State {
                                when: model.Menge > 0 && model.Mindesthaltbar < new Date()
                                PropertyChanges { target: tfBeschreibung; color: Material.accent }
                            }
                        }
                        LabelNumber {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
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
                icon: MessageDialog.Warning
                text: qsTr("Rohstoff kann nicht gelöscht werden.")
                informativeText: qsTr("Der Rohstoff wird von einem nichtgebrauten Sud verwendet.")
            }

            Loader {
                id: popuploader
                active: false
                onLoaded: item.open()
                sourceComponent: PopupBase {
                    onClosed: popuploader.active = false

                    function tryRemove(ingredient) {
                        if (Brauhelfer.allowedToDeleteIngredient(Brauhelfer.IngredientTypeYeast, ingredient)) {
                            listView.currentItem.remove()
                            close()
                        }
                        else {
                            messageDialogDelete.open()
                        }
                    }

                    SwipeView {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        spacing: 16
                        height: contentChildren[currentIndex].implicitHeight + 2 * anchors.margins
                        clip: true
                        currentIndex: listView.currentIndex
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
                                            }

                                            Item {
                                                property bool editing: false
                                                id: itBeschreibung
                                                Layout.fillWidth: true
                                                height: children[1].height
                                                LabelSubheader {
                                                    anchors.fill: parent
                                                    visible: !itBeschreibung.editing
                                                    text: model.Beschreibung
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
                                                    text: model.Beschreibung
                                                    onTextChanged: if (activeFocus) model.Beschreibung = text
                                                    onEditingFinished: itBeschreibung.editing = false
                                                    onVisibleChanged: if (visible) forceActiveFocus()
                                                }

                                                Component.onCompleted: if (model.Beschreibung === "") editing = true
                                            }

                                            ToolButton {
                                                id: btnRemove
                                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                                onClicked: tryRemove(model.Beschreibung)
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
                                            realValue: model.Menge
                                            onNewValue: model.Menge = value
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
                                            realValue: model.Wuerzemenge
                                            onNewValue: model.Wuerzemenge = value
                                        }

                                        LabelUnit {
                                            text: qsTr("l")
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("OG / UG")
                                        }

                                        ComboBox {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            Layout.rightMargin: 4
                                            model: [ "", qsTr("obergärig"), qsTr("untergärig")]
                                            currentIndex: _model.TypOGUG
                                            onActivated: _model.TypOGUG = index
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Trocken / flüssig")
                                        }

                                        ComboBox {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            Layout.rightMargin: 4
                                            model: [ "", qsTr("trocken"), qsTr("flüssig")]
                                            currentIndex: _model.TypTrFl
                                            onActivated: _model.TypTrFl = index
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Verpackung")
                                        }

                                        TextFieldBase {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            text: model.Verpackungsmenge
                                            onTextChanged: if (activeFocus) model.Verpackungsmenge = text
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Sedimentation")
                                        }

                                        ComboBox {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
                                            Layout.rightMargin: 4
                                            model: [ "", qsTr("hoch"), qsTr("mittel"), qsTr("niedrig")]
                                            currentIndex: _model.SED
                                            onActivated: _model.SED = index
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Vergärungsgrad")
                                        }

                                        TextFieldBase {
                                            Layout.columnSpan: 2
                                            Layout.fillWidth: true
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
                                            text: model.Temperatur
                                            onTextChanged: if (activeFocus) model.Temperatur = text
                                        }

                                        LabelPrim {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Eigenschaften")
                                        }

                                        TextArea {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            wrapMode: TextArea.Wrap
                                            placeholderText: qsTr("Eigenschaften")
                                            text: model.Eigenschaften
                                            onTextChanged: if (activeFocus) model.Eigenschaften = text
                                        }

                                        LabelPrim {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Bemerkung")
                                        }

                                        TextArea {
                                            Layout.columnSpan: 3
                                            Layout.fillWidth: true
                                            wrapMode: TextArea.Wrap
                                            placeholderText: qsTr("Bemerkung")
                                            text: model.Bemerkung
                                            onTextChanged: if (activeFocus) model.Bemerkung = text
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Preis")
                                        }

                                        SpinBoxReal {
                                            decimals: 2
                                            realValue: model.Preis
                                            onNewValue: model.Preis = value
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
                                            Layout.alignment: Qt.AlignHCenter
                                            enabled: model.Menge > 0
                                            date: model.Eingelagert
                                            onNewDate: model.Eingelagert = date
                                        }

                                        LabelPrim {
                                        }

                                        LabelPrim {
                                            Layout.fillWidth: true
                                            rightPadding: 8
                                            text: qsTr("Haltbar")
                                        }

                                        TextFieldDate {
                                            id: tfMindesthaltbar
                                            Layout.alignment: Qt.AlignHCenter
                                            enabled: model.Menge > 0
                                            date: model.Mindesthaltbar
                                            onNewDate: model.Mindesthaltbar = date
                                            states: State {
                                                when: tfMindesthaltbar.enabled && tfMindesthaltbar.date < new Date()
                                                PropertyChanges { target: tfMindesthaltbar; color: Material.accent }
                                            }
                                        }

                                        LabelPrim {
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
                    app.settings.ingredientsFilter = 0
                    listView.model.sourceModel.append()
                    listView.currentIndex = listView.count - 1
                    popuploader.active = true
                }
            }
        }
    }
}
