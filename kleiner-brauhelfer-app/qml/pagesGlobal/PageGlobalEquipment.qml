import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import "../common"
import brauhelfer
import ProxyModel

PageBase {
    id: page
    title: qsTr("Ausrüstung")
    icon: "equipment.png"
    readOnly: Brauhelfer.readonly || app.settings.readonly

    ListView {
        id: listView
        clip: true
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        model: Brauhelfer.modelAusruestung
        headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
        ScrollIndicator.vertical: ScrollIndicator {}
        header: Rectangle {
            property int widthCol1: headerLabel1.width
            property int widthCol2: headerLabel2.width
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
                        text: qsTr("Vermögen (l)")
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
                                implicitHeight: layout.height + 16
                                MouseAreaCatcher { }
                                ColumnLayout {
                                    id: layout
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    spacing: 8
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
                                        enabled: !page.readOnly
                                        onActivated: _model.Typ = model.get(currentIndex).value
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        focusPolicy: Qt.StrongFocus
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
                                                enabled: !page.readOnly
                                                realValue: model.Sudhausausbeute
                                                onNewValue: (value) => model.Sudhausausbeute = value
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
                                                enabled: !page.readOnly
                                                realValue: model.Verdampfungsrate
                                                onNewValue: (value) => model.Verdampfungsrate = value
                                            }
                                            LabelUnit {
                                                text: qsTr("l/h")
                                            }
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        focusPolicy: Qt.StrongFocus
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
                                                enabled: !page.readOnly
                                                realValue: model.KorrekturWasser
                                                onNewValue: (value) => model.KorrekturWasser = value
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
                                                enabled: !page.readOnly
                                                realValue: model.KorrekturFarbe
                                                onNewValue: (value) => model.KorrekturFarbe = value
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
                                                enabled: !page.readOnly
                                                realValue: model.KorrekturMenge
                                                onNewValue: (value) => model.KorrekturMenge = value
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
                                                enabled: !page.readOnly
                                                realValue: model.Kosten
                                                onNewValue: (value) => model.Kosten = value
                                            }
                                            LabelUnit {
                                                text: Qt.locale().currencySymbol()
                                            }
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        focusPolicy: Qt.StrongFocus
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
                                                enabled: !page.readOnly
                                                realValue: model.Maischebottich_Durchmesser
                                                onNewValue: (value) => model.Maischebottich_Durchmesser = value
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
                                                enabled: !page.readOnly
                                                realValue: model.Maischebottich_Hoehe
                                                onNewValue: (value) => model.Maischebottich_Hoehe = value
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
                                                enabled: !page.readOnly
                                                realValue: model.Maischebottich_MaxFuellhoehe
                                                onNewValue: (value) => model.Maischebottich_MaxFuellhoehe = value
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
                                        focusPolicy: Qt.StrongFocus
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
                                                enabled: !page.readOnly
                                                realValue: model.Sudpfanne_Durchmesser
                                                onNewValue: (value) => model.Sudpfanne_Durchmesser = value
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
                                                enabled: !page.readOnly
                                                realValue: model.Sudpfanne_Hoehe
                                                onNewValue: (value) => model.Sudpfanne_Hoehe = value
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
                                                enabled: !page.readOnly
                                                realValue: model.Sudpfanne_MaxFuellhoehe
                                                onNewValue: (value) => model.Sudpfanne_MaxFuellhoehe = value
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
                                        focusPolicy: Qt.StrongFocus
                                        label: LabelHeader {
                                            text: qsTr("Bemerkung")
                                        }
                                        TextAreaBase {
                                            anchors.fill: parent
                                            wrapMode: TextArea.Wrap
                                            textFormat: Text.RichText
                                            enabled: !page.readOnly
                                            text: model.Bemerkung
                                            onLinkActivated: (link) => Qt.openUrlExternally(link)
                                            onTextChanged: if (activeFocus) model.Bemerkung = text
                                        }
                                    }

                                    GroupBox {
                                        Layout.fillWidth: true
                                        focusPolicy: Qt.StrongFocus
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
                                                    filterRegularExpression: new RegExp(anlagenID)
                                                }
                                                delegate: RowLayout {
                                                    Layout.leftMargin: 8
                                                    visible: !model.deleted
                                                    TextFieldBase {
                                                        Layout.fillWidth: true
                                                        enabled: !page.readOnly
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
                                                        visible: !page.readOnly
                                                        onClicked: repeater.model.removeRow(index)
                                                    }
                                                }
                                            }
                                            RowLayout {
                                                Layout.leftMargin: 8
                                                TextFieldBase {
                                                    id: tfNewGear
                                                    Layout.fillWidth: true
                                                    enabled: !page.readOnly
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
                                                    visible: !page.readOnly
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
            visible: !page.readOnly
            onClicked: {
                listView.model.append()
                listView.currentIndex = listView.count - 1
                popuploader.active = true
            }
        }
    }
}
