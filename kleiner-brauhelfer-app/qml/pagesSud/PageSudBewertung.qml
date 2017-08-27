import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../common"
import brauhelfer 1.0

PageBase {
    id: page
    title: qsTr("Bewertung")
    icon: "ic_star.png"
    readOnly: Brauhelfer.readonly || (!Brauhelfer.sud.BierWurdeAbgefuellt && !app.brewForceEditable)

    component: ListView {
        id: listView
        clip: true
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds

        model: Brauhelfer.sud.modelBewertungen

        headerPositioning: isLandscape? ListView.PullBackHeader : ListView.OverlayHeader
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
                        text: qsTr("Datum")
                    }
                    LabelPrim {
                        Layout.preferredWidth: 80
                        horizontalAlignment: Qt.AlignHCenter
                        font.bold: true
                        text: qsTr("Woche")
                    }
                    LabelPrim {
                        Layout.preferredWidth: 150
                        horizontalAlignment: Qt.AlignHCenter
                        font.bold: true
                        text: qsTr("Bewertung")
                    }
                }
                HorizontalDivider {}
            }
        }

        footerPositioning: ListView.InlineFooter
        footer: Item {
            height: btnAdd.height + 12
        }

        delegate: ItemDelegate {

            property var modelItem: model

            id: rowDelegate
            width: parent.width
            height: dataColumn.implicitHeight
            padding: 0
            text: " "

            NumberAnimation {
                id: removeFake
                target: rowDelegate
                property: "height"
                to: 0
                easing.type: Easing.InOutQuad
                onStopped: rowDelegate.visible = false
            }

            onClicked: {
                listView.currentIndex = index
                popupEdit.open()
            }

            function remove() {
                removeFake.start()
                Brauhelfer.sud.modelBewertungen.remove(index)
            }

            ColumnLayout {
                id: dataColumn
                parent: rowDelegate.contentItem
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                RowLayout {
                    Layout.fillWidth: true
                    LabelDate {
                        Layout.fillWidth: true
                        leftPadding: 8
                        verticalAlignment: Qt.AlignVCenter
                        date: model.Datum
                    }
                    LabelPrim {
                        Layout.preferredWidth: 80
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        text: model.Woche
                    }
                    Flow {
                        Layout.preferredWidth: 150
                        Layout.alignment: Qt.AlignHCenter
                        Image {
                            source: model.Sterne > 0 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                        }
                        Image {
                            source: model.Sterne > 1 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                        }
                        Image {
                            source: model.Sterne > 2 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                        }
                        Image {
                            source: model.Sterne > 3 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                        }
                        Image {
                            source: model.Sterne > 4 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                        }
                    }
                }
                HorizontalDivider { }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator { }

        Popup {
            id: popupEdit
            parent: page
            width: parent.width - 20
            height: parent.height - 20
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            function remove() {
                listView.currentItem.remove()
                close()
            }

            background: Rectangle {
                color: Material.background
                radius: 10
                MouseArea {
                    anchors.fill: parent
                    onClicked: forceActiveFocus()
                }
            }

            Flickable {
                anchors.margins: 8
                anchors.fill: parent
                boundsBehavior: Flickable.OvershootBounds
                contentHeight: layout.height
                clip: true
                onVisibleChanged: contentY = 0

                ColumnLayout {

                    property var model: listView.currentIndex >= 0 ? listView.currentItem.modelItem : null
                    property bool modelValid: model

                    id: layout
                    spacing: 4
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    RowLayout {
                        Layout.fillWidth: true
                        TextFieldDate {
                            Layout.fillWidth: true
                            date: layout.modelValid ? layout.model.Datum : new Date()
                            onNewDate: if (layout.modelValid) layout.model.Datum = date
                            //date: layout.model.Datum
                            //onNewDate: layout.model.Datum = date
                        }
                        ToolButton {
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            onClicked: popupEdit.remove()
                            contentItem: Image {
                                source: "qrc:/images/ic_delete.png"
                                anchors.centerIn: parent
                            }
                        }
                    }

                    Flow {
                        Layout.alignment: Qt.AlignHCenter
                        ToolButton {
                            contentItem: Image {
                                source: (layout.modelValid && layout.model.Sterne > 0) ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: layout.model.Sterne > 0 ? layout.model.Sterne = 0 : layout.model.Sterne = 1
                        }
                        ToolButton {
                            contentItem: Image {
                                source: (layout.modelValid && layout.model.Sterne > 1) ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: layout.model.Sterne = 2
                        }
                        ToolButton {
                            contentItem: Image {
                                source: (layout.modelValid && layout.model.Sterne > 2) ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: layout.model.Sterne = 3
                        }
                        ToolButton {
                            contentItem: Image {
                                source: (layout.modelValid && layout.model.Sterne > 3) ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: layout.model.Sterne = 4
                        }
                        ToolButton {
                            contentItem: Image {
                                source: (layout.modelValid && layout.model.Sterne > 4) ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: layout.model.Sterne = 5
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: layout.modelValid ? layout.model.Bemerkung : ""
                        onTextChanged: if (focus && layout.modelValid) layout.model.Bemerkung = text
                    }

                    HorizontalDivider { Layout.fillWidth: true }

                    LabelPrim {
                        text: qsTr("Gesamteindruck")
                        color: Material.primary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("toll, macht Lust auf mehr")
                                checked: layout.modelValid ? layout.model.Gesamteindruck & (1 << 0) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("gutes, typisches Bier")
                                checked: layout.modelValid ? layout.model.Gesamteindruck & (1 << 1) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("interessant")
                                checked: layout.modelValid ? layout.model.Gesamteindruck & (1 << 2) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("überraschend, ungewöhnlich")
                                checked: layout.modelValid ? layout.model.Gesamteindruck & (1 << 3) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 3)
                            }
                            RadioButton {
                                text: qsTr("kreativ, mutig")
                                checked: layout.modelValid ? layout.model.Gesamteindruck & (1 << 4) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("unauffälig, gewöhnlich")
                                checked: layout.modelValid ? layout.model.Gesamteindruck & (1 << 5) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("einmal ist genug, langweilig")
                                checked: layout.modelValid ? layout.model.Gesamteindruck & (1 << 6) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 6)
                            }
                            RadioButton {
                                text: qsTr("nicht trinkbar, problematisch")
                                checked: layout.modelValid ? layout.model.Gesamteindruck & (1 << 7) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 7)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: layout.modelValid ? layout.model.GesamteindruckBemerkung : ""
                        onTextChanged: if (focus && layout.modelValid) layout.model.GesamteindruckBemerkung = text
                    }

                    HorizontalDivider { Layout.fillWidth: true }

                    LabelPrim {
                        text: qsTr("Farbe & Klarheit")
                        color: Material.primary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("hellgelb, lichtgelb")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 4) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("gelb")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 5) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("golden")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 6) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 6)
                            }
                            RadioButton {
                                text: qsTr("bernstein")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 7) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 7)
                            }
                            RadioButton {
                                text: qsTr("kupferrot, amber")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 8) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 8)
                            }
                            RadioButton {
                                text: qsTr("braun, tiefbraun")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 9) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 9)
                            }
                            RadioButton {
                                text: qsTr("schwarz, tief dunkel")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 10) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 10)
                            }
                        }
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("satt, intensiv")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 0) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("glänzend")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 1) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("matt, blass")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 2) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("gräulich, fahl")
                                checked: layout.modelValid ? layout.model.Farbe & (1 << 3) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 3)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: layout.modelValid ? layout.model.FarbeBemerkung : ""
                        onTextChanged: if (focus && layout.modelValid) layout.model.FarbeBemerkung = text
                    }

                    HorizontalDivider { Layout.fillWidth: true }

                    LabelPrim {
                        text: qsTr("Schaum")
                        color: Material.primary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("feinporig, fest")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 0) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("grobporig, schwach")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 1) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 1)
                            }
                        }
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("gut haftend")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 2) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("schlecht haftend")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 3) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 3)
                            }
                        }
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("gute Haltbarkeit")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 4) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("mässige Haltbarkeit")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 5) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("keine Haltbarkeit")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 6) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 6)
                            }
                        }
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("geringes Volumen")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 7) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 7)
                            }
                            RadioButton {
                                text: qsTr("kräftiges Volumen")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 8) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 8)
                            }
                            RadioButton {
                                text: qsTr("sehr voluminös, mächtig")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 9) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 9)
                            }
                            RadioButton {
                                text: qsTr("überschäumend")
                                checked: layout.modelValid ? layout.model.Schaum & (1 << 10) : false
                                onClicked: layout.model.Gesamteindruck = (1 << 10)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: layout.modelValid ? layout.model.SchaumBemerkung : ""
                        onTextChanged: if (focus && layout.modelValid) layout.model.SchaumBemerkung = text
                    }

                    HorizontalDivider { Layout.fillWidth: true }

                    LabelPrim {
                        text: qsTr("Geruch")
                        color: Material.primary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            CheckBox {
                                text: qsTr("rein, abgerundet")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 0) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 0) :  layout.model.Geruch &= ~(1 << 0)
                            }
                            CheckBox {
                                text: qsTr("frisch")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 1) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 1) :  layout.model.Geruch &= ~(1 << 1)
                            }
                            CheckBox {
                                text: qsTr("wohlriechend")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 2) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 2) :  layout.model.Geruch &= ~(1 << 2)
                            }
                            CheckBox {
                                text: qsTr("unangenehm, unausgewogen")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 3) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 3) :  layout.model.Geruch &= ~(1 << 3)
                            }
                            CheckBox {
                                text: qsTr("hopfenaromatisch, hopfig")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 4) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 4) :  layout.model.Geruch &= ~(1 << 4)
                            }
                            CheckBox {
                                text: qsTr("malzaromatisch, malzig")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 5) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 5) :  layout.model.Geruch &= ~(1 << 5)
                            }
                            CheckBox {
                                text: qsTr("süsslich, nach Würze")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 6) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 6) :  layout.model.Geruch &= ~(1 << 6)
                            }
                            CheckBox {
                                text: qsTr("heftig")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 7) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 7) :  layout.model.Geruch &= ~(1 << 7)
                            }
                            CheckBox {
                                text: qsTr("fruchtig")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 8) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 8) :  layout.model.Geruch &= ~(1 << 8)
                            }
                            CheckBox {
                                text: qsTr("gewürzig")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 9) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 9) :  layout.model.Geruch &= ~(1 << 9)
                            }
                            CheckBox {
                                text: qsTr("säuerlich")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 10) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 10) :  layout.model.Geruch &= ~(1 << 10)
                            }
                            CheckBox {
                                text: qsTr("Geruchsfehler")
                                checked: layout.modelValid ? layout.model.Geruch & (1 << 11) : false
                                onClicked: checked ? layout.model.Geruch |= (1 << 11) :  layout.model.Geruch &= ~(1 << 11)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: layout.modelValid ? layout.model.GeruchBemerkung : ""
                        onTextChanged: if (focus && layout.modelValid) layout.model.GeruchBemerkung = text
                    }

                    HorizontalDivider { Layout.fillWidth: true }

                    LabelPrim {
                        text: qsTr("Geschmack")
                        color: Material.primary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            CheckBox {
                                text: qsTr("rein")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 0) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 0) :  layout.model.Geschmack &= ~(1 << 0)
                            }
                            CheckBox {
                                text: qsTr("ausgewogen, rund")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 1) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 1) :  layout.model.Geschmack &= ~(1 << 1)
                            }
                            CheckBox {
                                text: qsTr("gehaltsvoll")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 2) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 2) :  layout.model.Geschmack &= ~(1 << 2)
                            }
                            CheckBox {
                                text: qsTr("unausgewogen, kantig")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 3) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 3) :  layout.model.Geschmack &= ~(1 << 3)
                            }
                            CheckBox {
                                text: qsTr("unreif, unrein")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 4) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 4) :  layout.model.Geschmack &= ~(1 << 4)
                            }
                            CheckBox {
                                text: qsTr("hopfenaromatisch, hopfig")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 5) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 5) :  layout.model.Geschmack &= ~(1 << 5)
                            }
                            CheckBox {
                                text: qsTr("malzaromatisch, malzig")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 6) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 6) :  layout.model.Geschmack &= ~(1 << 6)
                            }
                            CheckBox {
                                text: qsTr("süsslich, klebrig")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 7) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 7) :  layout.model.Geschmack &= ~(1 << 7)
                            }
                            CheckBox {
                                text: qsTr("säuerlich")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 8) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 8) :  layout.model.Geschmack &= ~(1 << 8)
                            }
                            CheckBox {
                                text: qsTr("gewürzig")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 9) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 9) :  layout.model.Geschmack &= ~(1 << 9)
                            }
                            CheckBox {
                                text: qsTr("fruchtig")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 10) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 10) :  layout.model.Geschmack &= ~(1 << 10)
                            }
                            CheckBox {
                                text: qsTr("heftig")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 11) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 11) :  layout.model.Geschmack &= ~(1 << 11)
                            }
                            CheckBox {
                                text: qsTr("Geschmacksfehler")
                                checked: layout.modelValid ? layout.model.Geschmack & (1 << 12) : false
                                onClicked: checked ? layout.model.Geschmack |= (1 << 12) :  layout.model.Geschmack &= ~(1 << 12)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: layout.modelValid ? layout.model.GeschmackBemerkung : ""
                        onTextChanged: if (focus && layout.modelValid) layout.model.GeschmackBemerkung = text
                    }

                    HorizontalDivider { Layout.fillWidth: true }

                    LabelPrim {
                        text: qsTr("Antrunk")
                        color: Material.primary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("angenehm rezent")
                                checked: layout.modelValid ? layout.model.Antrunk & (1 << 0) : false
                                onClicked: layout.model.Antrunk = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("rezent, fein perlend")
                                checked: layout.modelValid ? layout.model.Antrunk & (1 << 1) : false
                                onClicked: layout.model.Antrunk = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("gut eingebunden")
                                checked: layout.modelValid ? layout.model.Antrunk & (1 << 2) : false
                                onClicked: layout.model.Antrunk = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("prickelnd")
                                checked: layout.modelValid ? layout.model.Antrunk & (1 << 3) : false
                                onClicked: layout.model.Antrunk = (1 << 3)
                            }
                            RadioButton {
                                text: qsTr("stark prickelnd, aufdrindlich")
                                checked: layout.modelValid ? layout.model.Antrunk & (1 << 4) : false
                                onClicked: layout.model.Antrunk = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("wenig rezent")
                                checked: layout.modelValid ? layout.model.Antrunk & (1 << 5) : false
                                onClicked: layout.model.Antrunk = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("schal")
                                checked: layout.modelValid ? layout.model.Antrunk & (1 << 6) : false
                                onClicked: layout.model.Antrunk = (1 << 6)
                            }
                            RadioButton {
                                text: qsTr("sehr schal")
                                checked: layout.modelValid ? layout.model.Antrunk & (1 << 7) : false
                                onClicked: layout.model.Antrunk = (1 << 7)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: layout.modelValid ? layout.model.AntrunkBemerkung : ""
                        onTextChanged: if (focus && layout.modelValid) layout.model.AntrunkBemerkung = text
                    }

                    HorizontalDivider { Layout.fillWidth: true }

                    LabelPrim {
                        text: qsTr("Haupttrunk")
                        color: Material.primary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("wässrig, leer, dünn")
                                checked: layout.modelValid ? layout.model.Haupttrunk & (1 << 0) : false
                                onClicked: layout.model.Haupttrunk = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("etwas leer")
                                checked: layout.modelValid ? layout.model.Haupttrunk & (1 << 1) : false
                                onClicked: layout.model.Haupttrunk = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("schlank")
                                checked: layout.modelValid ? layout.model.Haupttrunk & (1 << 2) : false
                                onClicked: layout.model.Haupttrunk = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("vollmundig")
                                checked: layout.modelValid ? layout.model.Haupttrunk & (1 << 3) : false
                                onClicked: layout.model.Haupttrunk = (1 << 3)
                            }
                            RadioButton {
                                text: qsTr("mastig, breit")
                                checked: layout.modelValid ? layout.model.Haupttrunk & (1 << 4) : false
                                onClicked: layout.model.Haupttrunk = (1 << 4)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: layout.modelValid ? layout.model.HaupttrunkBemerkung : ""
                        onTextChanged: if (focus && layout.modelValid) layout.model.HaupttrunkBemerkung = text
                    }

                    HorizontalDivider { Layout.fillWidth: true }

                    LabelPrim {
                        text: qsTr("Nachtrunk")
                        color: Material.primary
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("sehr fein")
                                checked: layout.modelValid ? layout.model.Nachtrunk & (1 << 0) : false
                                onClicked: layout.model.Nachtrunk = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("angenehm, ausgewogen")
                                checked: layout.modelValid ? layout.model.Nachtrunk & (1 << 1) : false
                                onClicked: layout.model.Nachtrunk = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("nicht anhängend")
                                checked: layout.modelValid ? layout.model.Nachtrunk & (1 << 2) : false
                                onClicked: layout.model.Nachtrunk = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("nachhängend")
                                checked: layout.modelValid ? layout.model.Nachtrunk & (1 << 3) : false
                                onClicked: layout.model.Nachtrunk = (1 << 3)
                            }
                            RadioButton {
                                text: qsTr("stark nachhängend")
                                checked: layout.modelValid ? layout.model.Nachtrunk & (1 << 4) : false
                                onClicked: layout.model.Nachtrunk = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("wenig herb, unterentwickelt")
                                checked: layout.modelValid ? layout.model.Nachtrunk & (1 << 5) : false
                                onClicked: layout.model.Nachtrunk = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("sehr herb, kräftig betont")
                                checked: layout.modelValid ? layout.model.Nachtrunk & (1 << 6) : false
                                onClicked: layout.model.Nachtrunk = (1 << 6)
                            }
                            RadioButton {
                                text: qsTr("nicht/kaum warnehmbar")
                                checked: layout.modelValid ? layout.model.Nachtrunk & (1 << 7) : false
                                onClicked: layout.model.Nachtrunk = (1 << 7)
                            }
                            RadioButton {
                                text: qsTr("unangenehm")
                                checked: layout.modelValid ? layout.model.Nachtrunk & (1 << 8) : false
                                onClicked: layout.model.Nachtrunk = (1 << 8)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: layout.modelValid ? layout.model.NachtrunkBemerkung : ""
                        onTextChanged: if (focus && layout.modelValid) layout.model.NachtrunkBemerkung = text
                    }
                }
            }
        }

        FloatingButton {
            id: btnAdd
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            imageSource: "qrc:/images/ic_add_white.png"
            visible: !page.readOnly
            onClicked: {
                Brauhelfer.sud.modelBewertungen.append()
                listView.currentIndex = listView.count - 1
                popupEdit.open()
            }
        }
    }
}
