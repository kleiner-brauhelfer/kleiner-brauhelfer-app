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

        headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
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
            property variant values: model

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
                popuploader.active = true
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

        Loader {
            id: popuploader
            active: false
            focus: true
            onLoaded: item.open()
            sourceComponent: PopupBase {
                property variant model: listView.currentItem.values
                onClosed: popuploader.active = false

                function remove() {
                    listView.currentItem.remove()
                    close()
                }

                ColumnLayout {
                    spacing: 4
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    RowLayout {
                        Layout.fillWidth: true
                        TextFieldDate {
                            Layout.fillWidth: true
                            date: model.Datum
                            onNewDate: model.Datum = date
                        }
                        ToolButton {
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            onClicked: remove()
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
                                source: model.Sterne > 0 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: model.Sterne > 0 ? model.Sterne = 0 : model.Sterne = 1
                        }
                        ToolButton {
                            contentItem: Image {
                                source: model.Sterne > 1 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: model.Sterne = 2
                        }
                        ToolButton {
                            contentItem: Image {
                                source: model.Sterne > 2 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: model.Sterne = 3
                        }
                        ToolButton {
                            contentItem: Image {
                                source: model.Sterne > 3 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: model.Sterne = 4
                        }
                        ToolButton {
                            contentItem: Image {
                                source: model.Sterne > 4 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                                anchors.centerIn: parent
                            }
                            onClicked: model.Sterne = 5
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.Bemerkung
                        onTextChanged: model.Bemerkung = text
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
                                checked: model.Gesamteindruck & (1 << 0)
                                onClicked: model.Gesamteindruck = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("gutes, typisches Bier")
                                checked: model.Gesamteindruck & (1 << 1)
                                onClicked: model.Gesamteindruck = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("interessant")
                                checked: model.Gesamteindruck & (1 << 2)
                                onClicked: model.Gesamteindruck = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("überraschend, ungewöhnlich")
                                checked: model.Gesamteindruck & (1 << 3)
                                onClicked: model.Gesamteindruck = (1 << 3)
                            }
                            RadioButton {
                                text: qsTr("kreativ, mutig")
                                checked: model.Gesamteindruck & (1 << 4)
                                onClicked: model.Gesamteindruck = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("unauffälig, gewöhnlich")
                                checked: model.Gesamteindruck & (1 << 5)
                                onClicked: model.Gesamteindruck = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("einmal ist genug, langweilig")
                                checked: model.Gesamteindruck & (1 << 6)
                                onClicked: model.Gesamteindruck = (1 << 6)
                            }
                            RadioButton {
                                text: qsTr("nicht trinkbar, problematisch")
                                checked: model.Gesamteindruck & (1 << 7)
                                onClicked: model.Gesamteindruck = (1 << 7)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.GesamteindruckBemerkung
                        onTextChanged: model.GesamteindruckBemerkung = text
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
                                checked: model.Farbe & (1 << 4)
                                onClicked: model.Farbe = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("gelb")
                                checked: model.Farbe & (1 << 5)
                                onClicked: model.Farbe = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("golden")
                                checked: model.Farbe & (1 << 6)
                                onClicked: model.Farbe = (1 << 6)
                            }
                            RadioButton {
                                text: qsTr("bernstein")
                                checked: model.Farbe & (1 << 7)
                                onClicked: model.Farbe = (1 << 7)
                            }
                            RadioButton {
                                text: qsTr("kupferrot, amber")
                                checked: model.Farbe & (1 << 8)
                                onClicked: model.Farbe = (1 << 8)
                            }
                            RadioButton {
                                text: qsTr("braun, tiefbraun")
                                checked: model.Farbe & (1 << 9)
                                onClicked: model.Farbe = (1 << 9)
                            }
                            RadioButton {
                                text: qsTr("schwarz, tief dunkel")
                                checked: model.Farbe & (1 << 10)
                                onClicked: model.Farbe = (1 << 10)
                            }
                        }
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("satt, intensiv")
                                checked: model.Farbe & (1 << 0)
                                onClicked: model.Farbe = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("glänzend")
                                checked: model.Farbe & (1 << 1)
                                onClicked: model.Farbe = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("matt, blass")
                                checked: model.Farbe & (1 << 2)
                                onClicked: model.Farbe = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("gräulich, fahl")
                                checked: model.Farbe & (1 << 3)
                                onClicked: model.Farbe = (1 << 3)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.FarbeBemerkung
                        onTextChanged: model.FarbeBemerkung = text
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
                                checked: model.Schaum & (1 << 0)
                                onClicked: model.Schaum = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("grobporig, schwach")
                                checked: model.Schaum & (1 << 1)
                                onClicked: model.Schaum = (1 << 1)
                            }
                        }
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("gut haftend")
                                checked: model.Schaum & (1 << 2)
                                onClicked: model.Schaum = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("schlecht haftend")
                                checked: model.Schaum & (1 << 3)
                                onClicked: model.Schaum = (1 << 3)
                            }
                        }
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("gute Haltbarkeit")
                                checked: model.Schaum & (1 << 4)
                                onClicked: model.Schaum = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("mässige Haltbarkeit")
                                checked: model.Schaum & (1 << 5)
                                onClicked: model.Schaum = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("keine Haltbarkeit")
                                checked: model.Schaum & (1 << 6)
                                onClicked: model.Schaum = (1 << 6)
                            }
                        }
                    }

                    Frame {
                        Layout.fillWidth: true
                        Flow {
                            anchors.fill: parent
                            RadioButton {
                                text: qsTr("geringes Volumen")
                                checked: model.Schaum & (1 << 7)
                                onClicked: model.Schaum = (1 << 7)
                            }
                            RadioButton {
                                text: qsTr("kräftiges Volumen")
                                checked: model.Schaum & (1 << 8)
                                onClicked: model.Schaum = (1 << 8)
                            }
                            RadioButton {
                                text: qsTr("sehr voluminös, mächtig")
                                checked: model.Schaum & (1 << 9)
                                onClicked: model.Schaum = (1 << 9)
                            }
                            RadioButton {
                                text: qsTr("überschäumend")
                                checked: model.Schaum & (1 << 10)
                                onClicked: model.Schaum = (1 << 10)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.SchaumBemerkung
                        onTextChanged: model.SchaumBemerkung = text
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
                                checked: model.Geruch & (1 << 0)
                                onClicked: checked ? model.Geruch |= (1 << 0) : model.Geruch &= ~(1 << 0)
                            }
                            CheckBox {
                                text: qsTr("frisch")
                                checked: model.Geruch & (1 << 1)
                                onClicked: checked ? model.Geruch |= (1 << 1) : model.Geruch &= ~(1 << 1)
                            }
                            CheckBox {
                                text: qsTr("wohlriechend")
                                checked: model.Geruch & (1 << 2)
                                onClicked: checked ? model.Geruch |= (1 << 2) : model.Geruch &= ~(1 << 2)
                            }
                            CheckBox {
                                text: qsTr("unangenehm, unausgewogen")
                                checked: model.Geruch & (1 << 3)
                                onClicked: checked ? model.Geruch |= (1 << 3) : model.Geruch &= ~(1 << 3)
                            }
                            CheckBox {
                                text: qsTr("hopfenaromatisch, hopfig")
                                checked: model.Geruch & (1 << 4)
                                onClicked: checked ? model.Geruch |= (1 << 4) : model.Geruch &= ~(1 << 4)
                            }
                            CheckBox {
                                text: qsTr("malzaromatisch, malzig")
                                checked: model.Geruch & (1 << 5)
                                onClicked: checked ? model.Geruch |= (1 << 5) : model.Geruch &= ~(1 << 5)
                            }
                            CheckBox {
                                text: qsTr("süsslich, nach Würze")
                                checked: model.Geruch & (1 << 6)
                                onClicked: checked ? model.Geruch |= (1 << 6) : model.Geruch &= ~(1 << 6)
                            }
                            CheckBox {
                                text: qsTr("heftig")
                                checked: model.Geruch & (1 << 7)
                                onClicked: checked ? model.Geruch |= (1 << 7) : model.Geruch &= ~(1 << 7)
                            }
                            CheckBox {
                                text: qsTr("fruchtig")
                                checked: model.Geruch & (1 << 8)
                                onClicked: checked ? model.Geruch |= (1 << 8) : model.Geruch &= ~(1 << 8)
                            }
                            CheckBox {
                                text: qsTr("gewürzig")
                                checked: model.Geruch & (1 << 9)
                                onClicked: checked ? model.Geruch |= (1 << 9) : model.Geruch &= ~(1 << 9)
                            }
                            CheckBox {
                                text: qsTr("säuerlich")
                                checked: model.Geruch & (1 << 10)
                                onClicked: checked ? model.Geruch |= (1 << 10) : model.Geruch &= ~(1 << 10)
                            }
                            CheckBox {
                                text: qsTr("Geruchsfehler")
                                checked: model.Geruch & (1 << 11)
                                onClicked: checked ? model.Geruch |= (1 << 11) : model.Geruch &= ~(1 << 11)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.GeruchBemerkung
                        onTextChanged: model.GeruchBemerkung = text
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
                                checked: model.Geschmack & (1 << 0)
                                onClicked: checked ? model.Geschmack |= (1 << 0) : model.Geschmack &= ~(1 << 0)
                            }
                            CheckBox {
                                text: qsTr("ausgewogen, rund")
                                checked: model.Geschmack & (1 << 1)
                                onClicked: checked ? model.Geschmack |= (1 << 1) : model.Geschmack &= ~(1 << 1)
                            }
                            CheckBox {
                                text: qsTr("gehaltsvoll")
                                checked: model.Geschmack & (1 << 2)
                                onClicked: checked ? model.Geschmack |= (1 << 2) : model.Geschmack &= ~(1 << 2)
                            }
                            CheckBox {
                                text: qsTr("unausgewogen, kantig")
                                checked: model.Geschmack & (1 << 3)
                                onClicked: checked ? model.Geschmack |= (1 << 3) : model.Geschmack &= ~(1 << 3)
                            }
                            CheckBox {
                                text: qsTr("unreif, unrein")
                                checked: model.Geschmack & (1 << 4)
                                onClicked: checked ? model.Geschmack |= (1 << 4) : model.Geschmack &= ~(1 << 4)
                            }
                            CheckBox {
                                text: qsTr("hopfenaromatisch, hopfig")
                                checked: model.Geschmack & (1 << 5)
                                onClicked: checked ? model.Geschmack |= (1 << 5) : model.Geschmack &= ~(1 << 5)
                            }
                            CheckBox {
                                text: qsTr("malzaromatisch, malzig")
                                checked: model.Geschmack & (1 << 6)
                                onClicked: checked ? model.Geschmack |= (1 << 6) : model.Geschmack &= ~(1 << 6)
                            }
                            CheckBox {
                                text: qsTr("süsslich, klebrig")
                                checked: model.Geschmack & (1 << 7)
                                onClicked: checked ? model.Geschmack |= (1 << 7) : model.Geschmack &= ~(1 << 7)
                            }
                            CheckBox {
                                text: qsTr("säuerlich")
                                checked: model.Geschmack & (1 << 8)
                                onClicked: checked ? model.Geschmack |= (1 << 8) : model.Geschmack &= ~(1 << 8)
                            }
                            CheckBox {
                                text: qsTr("gewürzig")
                                checked: model.Geschmack & (1 << 9)
                                onClicked: checked ? model.Geschmack |= (1 << 9) : model.Geschmack &= ~(1 << 9)
                            }
                            CheckBox {
                                text: qsTr("fruchtig")
                                checked: model.Geschmack & (1 << 10)
                                onClicked: checked ? model.Geschmack |= (1 << 10) : model.Geschmack &= ~(1 << 10)
                            }
                            CheckBox {
                                text: qsTr("heftig")
                                checked: model.Geschmack & (1 << 11)
                                onClicked: checked ? model.Geschmack |= (1 << 11) : model.Geschmack &= ~(1 << 11)
                            }
                            CheckBox {
                                text: qsTr("Geschmacksfehler")
                                checked: model.Geschmack & (1 << 12)
                                onClicked: checked ? model.Geschmack |= (1 << 12) : model.Geschmack &= ~(1 << 12)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.GeschmackBemerkung
                        onTextChanged: model.GeschmackBemerkung = text
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
                                checked: model.Antrunk & (1 << 0)
                                onClicked: model.Antrunk = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("rezent, fein perlend")
                                checked: model.Antrunk & (1 << 1)
                                onClicked: model.Antrunk = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("gut eingebunden")
                                checked: model.Antrunk & (1 << 2)
                                onClicked: model.Antrunk = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("prickelnd")
                                checked: model.Antrunk & (1 << 3)
                                onClicked: model.Antrunk = (1 << 3)
                            }
                            RadioButton {
                                text: qsTr("stark prickelnd, aufdrindlich")
                                checked: model.Antrunk & (1 << 4)
                                onClicked: model.Antrunk = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("wenig rezent")
                                checked: model.Antrunk & (1 << 5)
                                onClicked: model.Antrunk = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("schal")
                                checked: model.Antrunk & (1 << 6)
                                onClicked: model.Antrunk = (1 << 6)
                            }
                            RadioButton {
                                text: qsTr("sehr schal")
                                checked: model.Antrunk & (1 << 7)
                                onClicked: model.Antrunk = (1 << 7)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.AntrunkBemerkung
                        onTextChanged: model.AntrunkBemerkung = text
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
                                checked: model.Haupttrunk & (1 << 0)
                                onClicked: model.Haupttrunk = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("etwas leer")
                                checked: model.Haupttrunk & (1 << 1)
                                onClicked: model.Haupttrunk = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("schlank")
                                checked: model.Haupttrunk & (1 << 2)
                                onClicked: model.Haupttrunk = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("vollmundig")
                                checked: model.Haupttrunk & (1 << 3)
                                onClicked: model.Haupttrunk = (1 << 3)
                            }
                            RadioButton {
                                text: qsTr("mastig, breit")
                                checked: model.Haupttrunk & (1 << 4)
                                onClicked: model.Haupttrunk = (1 << 4)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.HaupttrunkBemerkung
                        onTextChanged: model.HaupttrunkBemerkung = text
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
                                checked: model.Nachtrunk & (1 << 0)
                                onClicked: model.Nachtrunk = (1 << 0)
                            }
                            RadioButton {
                                text: qsTr("angenehm, ausgewogen")
                                checked: model.Nachtrunk & (1 << 1)
                                onClicked: model.Nachtrunk = (1 << 1)
                            }
                            RadioButton {
                                text: qsTr("nicht anhängend")
                                checked: model.Nachtrunk & (1 << 2)
                                onClicked: model.Nachtrunk = (1 << 2)
                            }
                            RadioButton {
                                text: qsTr("nachhängend")
                                checked: model.Nachtrunk & (1 << 3)
                                onClicked: model.Nachtrunk = (1 << 3)
                            }
                            RadioButton {
                                text: qsTr("stark nachhängend")
                                checked: model.Nachtrunk & (1 << 4)
                                onClicked: model.Nachtrunk = (1 << 4)
                            }
                            RadioButton {
                                text: qsTr("wenig herb, unterentwickelt")
                                checked: model.Nachtrunk & (1 << 5)
                                onClicked: model.Nachtrunk = (1 << 5)
                            }
                            RadioButton {
                                text: qsTr("sehr herb, kräftig betont")
                                checked: model.Nachtrunk & (1 << 6)
                                onClicked: model.Nachtrunk = (1 << 6)
                            }
                            RadioButton {
                                text: qsTr("nicht/kaum warnehmbar")
                                checked: model.Nachtrunk & (1 << 7)
                                onClicked: model.Nachtrunk = (1 << 7)
                            }
                            RadioButton {
                                text: qsTr("unangenehm")
                                checked: model.Nachtrunk & (1 << 8)
                                onClicked: model.Nachtrunk = (1 << 8)
                            }
                        }
                    }

                    TextArea {
                        Layout.fillWidth: true
                        wrapMode: TextArea.Wrap
                        placeholderText: qsTr("Bemerkung")
                        text: model.NachtrunkBemerkung
                        onTextChanged: model.NachtrunkBemerkung = text
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
                popuploader.active = true
            }
        }
    }
}
