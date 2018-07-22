import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Ausrüstung")
    icon: "equipment.png"

    ListView {
        id: listView
        clip: true
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        model: Brauhelfer.modelAusruestung
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
                        text: qsTr("Brauanlage")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                        text: qsTr("Vermögen")
                    }
                }
                HorizontalDivider {
                    Layout.fillWidth: true
                    height: 2
                }
            }
        }
        footerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackFooter : ListView.OverlayFooter
        footer: Item {
            height: btnAdd.height + 12
        }

        delegate: ItemDelegate {
            id: rowDelegate
            width: parent.width
            height: dataColumn.implicitHeight
            padding: 0
            visible: !model.deleted
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
                listView.model.remove(index)
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
                        Layout.fillWidth: true
                        text: model.Name
                    }
                    LabelNumber {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        precision: 0
                        unit: qsTr("l")
                        value: model.Vermoegen
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

                function remove() {
                    listView.currentItem.remove()
                    close()
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
                            property var anlagenID: model.AnlagenID
                            active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                            sourceComponent: Item {
                                implicitHeight: layout.height
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: 0
                                    onClicked: forceActiveFocus()
                                }
                                ColumnLayout {
                                    id: layout
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
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
                                            TextField {
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
                                            onClicked: remove()
                                            contentItem: Image {
                                                source: "qrc:/images/ic_delete.png"
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        label: LabelSubheader {
                                            text: qsTr("Korrekturwerte")
                                        }

                                        GridLayout {
                                            anchors.fill: parent
                                            columns: 3
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Sudhausausbeute")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                stepSize: 1
                                                realValue: model.Sudhausausbeute
                                                onNewValue: model.Sudhausausbeute = value
                                            }
                                            LabelUnit {
                                                text: qsTr("%")
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Verdampfungsziffer")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                stepSize: 1
                                                realValue: model.Verdampfungsziffer
                                                onNewValue: model.Verdampfungsziffer = value
                                            }
                                            LabelUnit {
                                                text: qsTr("%")
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Nachguss")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                stepSize: 1
                                                realValue: model.KorrekturWasser
                                                onNewValue: model.KorrekturWasser = value
                                            }
                                            LabelUnit {
                                                text: qsTr("l")
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Farbwert")
                                            }
                                            SpinBoxReal {
                                                decimals: 0
                                                realValue: model.KorrekturFarbe
                                                onNewValue: model.KorrekturFarbe = value
                                            }
                                            LabelUnit {
                                                text: qsTr("EBC")
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Kosten")
                                            }
                                            SpinBoxReal {
                                                decimals: 2
                                                realValue: model.Kosten
                                                onNewValue: model.Kosten = value
                                            }
                                            LabelUnit {
                                                text: Qt.locale().currencySymbol()
                                            }
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        label: LabelSubheader {
                                            text: qsTr("Maischekessel")
                                        }
                                        GridLayout {
                                            anchors.fill: parent
                                            columns: 3
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Durchmesser")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                realValue: model.Maischebottich_Durchmesser
                                                onNewValue: model.Maischebottich_Durchmesser = value
                                            }
                                            LabelUnit {
                                                text: qsTr("cm")
                                            }
                                            HorizontalDivider {
                                                Layout.fillWidth: true
                                                Layout.columnSpan: 3
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Höhe")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                realValue: model.Maischebottich_Hoehe
                                                onNewValue: model.Maischebottich_Hoehe = value
                                            }
                                            LabelUnit {
                                                text: qsTr("cm")
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Volumen")
                                            }
                                            LabelNumber {
                                                Layout.alignment: Qt.AlignHCenter
                                                precision: 1
                                                value: model.Maischebottich_Volumen
                                            }
                                            LabelUnit {
                                                text: qsTr("l")
                                            }
                                            HorizontalDivider {
                                                Layout.fillWidth: true
                                                Layout.columnSpan: 3
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Nutzbar Höhe")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                max: model.Maischebottich_Hoehe
                                                realValue: model.Maischebottich_MaxFuellhoehe
                                                onNewValue: model.Maischebottich_MaxFuellhoehe = value
                                            }
                                            LabelUnit {
                                                text: qsTr("cm")
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Nutzbares Volumen")
                                            }
                                            LabelNumber {
                                                Layout.alignment: Qt.AlignHCenter
                                                precision: 1
                                                value: model.Maischebottich_MaxFuelvolumen
                                            }
                                            LabelUnit {
                                                text: qsTr("l")
                                            }
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        label: LabelSubheader {
                                            text: qsTr("Sudpfanne")
                                        }
                                        GridLayout {
                                            anchors.fill: parent
                                            columns: 3
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Durchmesser")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                realValue: model.Sudpfanne_Durchmesser
                                                onNewValue: model.Sudpfanne_Durchmesser = value
                                            }
                                            LabelUnit {
                                                text: qsTr("cm")
                                            }
                                            HorizontalDivider {
                                                Layout.fillWidth: true
                                                Layout.columnSpan: 3
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Höhe")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                realValue: model.Sudpfanne_Hoehe
                                                onNewValue: model.Sudpfanne_Hoehe = value
                                            }
                                            LabelUnit {
                                                text: qsTr("cm")
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Volumen")
                                            }
                                            LabelNumber {
                                                Layout.alignment: Qt.AlignHCenter
                                                precision: 1
                                                value: model.Sudpfanne_Volumen
                                            }
                                            LabelUnit {
                                                text: qsTr("l")
                                            }
                                            HorizontalDivider {
                                                Layout.fillWidth: true
                                                Layout.columnSpan: 3
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Nutzbar Höhe")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                max: model.Sudpfanne_Hoehe
                                                realValue: model.Sudpfanne_MaxFuellhoehe
                                                onNewValue: model.Sudpfanne_MaxFuellhoehe = value
                                            }
                                            LabelUnit {
                                                text: qsTr("cm")
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Nutzbares Volumen")
                                            }
                                            LabelNumber {
                                                Layout.alignment: Qt.AlignHCenter
                                                precision: 1
                                                value: model.Sudpfanne_MaxFuelvolumen
                                            }
                                            LabelUnit {
                                                text: qsTr("l")
                                            }
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        label: LabelSubheader {
                                            text: qsTr("Geräte")
                                        }
                                        ColumnLayout {
                                            anchors.fill: parent
                                            Repeater {
                                                id: repeater
                                                model: SortFilterProxyModel {
                                                    sourceModel: Brauhelfer.modelGeraete
                                                    filterKeyColumn: sourceModel.fieldIndex("AusruestungAnlagenID")
                                                    filterRegExp: new RegExp(anlagenID)
                                                }
                                                delegate: RowLayout{
                                                    Layout.leftMargin: 8
                                                    visible: !model.deleted
                                                    LabelPrim {
                                                        Layout.fillWidth: true
                                                        text: model.Bezeichnung
                                                    }
                                                    /*
                                                    Button {
                                                        Layout.preferredWidth: 48
                                                        contentItem: Image {
                                                            source: "qrc:/images/ic_remove.png"
                                                            anchors.centerIn: parent
                                                        }
                                                        onClicked: repeater.model.sourceModel.remove(repeater.model.mapRowToSource(index))
                                                    }
                                                    */
                                                }
                                            }
                                            /*
                                            Button {
                                                Layout.preferredWidth: 48
                                                contentItem: Image {
                                                    source: "qrc:/images/ic_add.png"
                                                    anchors.centerIn: parent
                                                }
                                                onClicked: repeater.model.sourceModel.append({"AusruestungAnlagenID": anlagenID, "Bezeichnung": qsTr("Gerät")})
                                            }
                                            */
                                        }
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
            onClicked: {
                listView.model.append()
                listView.currentIndex = listView.count - 1
                popuploader.active = true
            }
        }
    }
}
