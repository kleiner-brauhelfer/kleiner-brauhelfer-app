import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0
import ProxyModel 1.0

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
            property var widthCol1: headerLabel1.width
            property var widthCol2: headerLabel2.width
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
                        text: qsTr("Brauanlage")
                    }
                    LabelPrim {
                        id: headerLabel1
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        text: qsTr("Vermögen [l]")
                    }
                    LabelPrim {
                        id: headerLabel2
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        text: qsTr("Sude")
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
            width: listView.width
            height: dataColumn.implicitHeight
            padding: 0
            visible: !model.deleted
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
                        precision: 0
                        value: model.Vermoegen
                    }
                    LabelNumber {
                        Layout.preferredWidth: listView.headerItem.widthCol2
                        horizontalAlignment: Text.AlignHCenter
                        precision: 0
                        value: model.AnzahlSude
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
                            property var anlagenID: model.ID
                            active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                            sourceComponent: Item {
                                property variant _model: model
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
                                            LabelHeader {
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

                                    ComboBoxBase {
                                        Layout.fillWidth: true
                                        textRole: "key"
                                        model: ListModel {
                                            ListElement { key: qsTr("Standard"); value: Brauhelfer.AnlageTyp.Standard}
                                            ListElement { key: qsTr("Grainfather G30"); value: Brauhelfer.AnlageTyp.GrainfatherG30}
                                            ListElement { key: qsTr("Grainfather G70"); value: Brauhelfer.AnlageTyp.GrainfatherG70}
                                            ListElement { key: qsTr("Braumeister 10L"); value: Brauhelfer.AnlageTyp.Braumeister10}
                                            ListElement { key: qsTr("Braumeister 20L"); value: Brauhelfer.AnlageTyp.Braumeister20}
                                            ListElement { key: qsTr("Braumeister 50L"); value: Brauhelfer.AnlageTyp.Braumeister50}
                                            ListElement { key: qsTr("Braumeister 200L"); value: Brauhelfer.AnlageTyp.Braumeister200}
                                            ListElement { key: qsTr("Braumeister 500L"); value: Brauhelfer.AnlageTyp.Braumeister500}
                                            ListElement { key: qsTr("Braumeister 1000L"); value: Brauhelfer.AnlageTyp.Braumeister1000}
                                            ListElement { key: qsTr("Brauheld Pro 30L"); value: Brauhelfer.AnlageTyp.BrauheldPro30}
                                        }
                                        currentIndex: switch(_model.Typ) {
                                                        case Brauhelfer.AnlageTyp.Standard: return 0;
                                                        case Brauhelfer.AnlageTyp.GrainfatherG30: return 1;
                                                        case Brauhelfer.AnlageTyp.GrainfatherG70: return 2;
                                                        case Brauhelfer.AnlageTyp.Braumeister10: return 3;
                                                        case Brauhelfer.AnlageTyp.Braumeister20: return 4;
                                                        case Brauhelfer.AnlageTyp.Braumeister50: return 5;
                                                        case Brauhelfer.AnlageTyp.Braumeister200: return 6;
                                                        case Brauhelfer.AnlageTyp.Braumeister500: return 7;
                                                        case Brauhelfer.AnlageTyp.Braumeister1000: return 8;
                                                        case Brauhelfer.AnlageTyp.BrauheldPro30: return 9;
                                                      }
                                        onActivated: _model.Typ = model.get(currentIndex).value
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        label: LabelHeader {
                                            text: qsTr("Kernwerte")
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
                                                text: qsTr("Verdampfungsrate")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                stepSize: 1
                                                realValue: model.Verdampfungsrate
                                                onNewValue: model.Verdampfungsrate = value
                                            }
                                            LabelUnit {
                                                text: qsTr("l/h")
                                            }
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        label: LabelHeader {
                                            text: qsTr("Korrekturwerte")
                                        }

                                        GridLayout {
                                            anchors.fill: parent
                                            columns: 3
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
                                                text: qsTr("Sollmenge")
                                            }
                                            SpinBoxReal {
                                                decimals: 1
                                                realValue: model.KorrekturMenge
                                                onNewValue: model.KorrekturMenge = value
                                            }
                                            LabelUnit {
                                                text: qsTr("l")
                                            }
                                            LabelPrim {
                                                Layout.fillWidth: true
                                                text: qsTr("Betriebskosten")
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
                                        label: LabelHeader {
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
                                                value: model.Maischebottich_MaxFuellvolumen
                                            }
                                            LabelUnit {
                                                text: qsTr("l")
                                            }
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        label: LabelHeader {
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
                                                value: model.Sudpfanne_MaxFuellvolumen
                                            }
                                            LabelUnit {
                                                text: qsTr("l")
                                            }
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        label: LabelHeader {
                                            text: qsTr("Bemerkung")
                                        }
                                        TextAreaBase {
                                            anchors.fill: parent
                                            wrapMode: TextArea.Wrap
                                            placeholderText: qsTr("Bemerkung")
                                            text: model.Bemerkung
                                            onTextChanged: if (activeFocus) model.Bemerkung = text
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        label: LabelHeader {
                                            text: qsTr("Geräte")
                                        }
                                        ColumnLayout {
                                            anchors.fill: parent
                                            Repeater {
                                                id: repeater
                                                model: ProxyModel {
                                                    sourceModel: Brauhelfer.modelGeraete
                                                    filterKeyColumn: fieldIndex("AusruestungAnlagenID")
                                                    filterRegExp: new RegExp(anlagenID)
                                                }
                                                delegate: RowLayout {
                                                    Layout.leftMargin: 8
                                                    visible: !model.deleted
                                                    TextFieldBase {
                                                        Layout.fillWidth: true
                                                        text: model.Bezeichnung
                                                        onTextChanged: if (activeFocus) model.Bezeichnung = text
                                                    }
                                                    ToolButton {
                                                        Layout.preferredWidth: 40
                                                        contentItem: Image {
                                                            fillMode: Image.PreserveAspectFit
                                                            source: "qrc:/images/ic_remove.png"
                                                            anchors.centerIn: parent
                                                        }
                                                        onClicked: repeater.model.removeRow(index)
                                                    }
                                                }
                                            }
                                            RowLayout {
                                                Layout.leftMargin: 8
                                                TextFieldBase {
                                                    id: tfNewGear
                                                    Layout.fillWidth: true
                                                    placeholderText: qsTr("Neues Gerät")
                                                }
                                                ToolButton {
                                                    Layout.preferredWidth: 40
                                                    contentItem: Image {
                                                        fillMode: Image.PreserveAspectFit
                                                        source: "qrc:/images/ic_add.png"
                                                        anchors.centerIn: parent
                                                        layer.enabled: !parent.enabled
                                                        layer.effect: ColorOverlay {
                                                            color: "gray"
                                                        }
                                                    }
                                                    enabled: tfNewGear.text !== ""
                                                    onClicked: {
                                                        repeater.model.append({"AusruestungAnlagenID": anlagenID, "Bezeichnung": tfNewGear.text})
                                                        tfNewGear.text = ""
                                                    }
                                                }
                                            }
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
