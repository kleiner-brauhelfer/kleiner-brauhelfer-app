import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import QtCharts 2.2
import QtQuick.Dialogs 1.3

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Hauptgärung")
    icon: "hauptgaerung.png"
    readOnly: Brauhelfer.readonly || ((!Brauhelfer.sud.BierWurdeGebraut || Brauhelfer.sud.BierWurdeAbgefuellt) && !app.brewForceEditable)

    component: ColumnLayout {
        property alias listView: listView
        anchors.fill: parent

        Chart {
            id: chart
            implicitHeight: parent.height / 2
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title1: qsTr("Alkohol")
            color1: "#741EA6"
            title2: qsTr("Extrakt")
            color2: "#2E4402"
            should2: Brauhelfer.sud.SchnellgaerprobeAktiv ? Brauhelfer.sud.Gruenschlauchzeitpunkt : null
            title3: qsTr("Temp")
            color3: "#780000"
            legend.visible: false
            VXYModelMapper {
                model: listView.model
                series: chart.series1
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Alc")
            }
            VXYModelMapper {
                model: listView.model
                series: chart.series2
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("SW")
            }
            VXYModelMapper {
                model: listView.model
                series: chart.series3
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Temp")
            }
        }

        ListView {
            id: listView
            clip: true
            anchors.top: chart.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: layoutIngredients.top
            boundsBehavior: Flickable.OvershootBounds
            model: Brauhelfer.sud.modelHauptgaerverlauf
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
                            text: qsTr("Datum")
                        }
                        LabelPrim {
                            Layout.preferredWidth: 70
                            font.bold: true
                            text: chart.title2
                        }
                        LabelPrim {
                            Layout.preferredWidth: 70
                            font.bold: true
                            text: chart.title3
                        }
                        LabelPrim {
                            Layout.preferredWidth: 70
                            font.bold: true
                            text: chart.title1
                        }
                    }
                    HorizontalDivider {}
                }
            }

            footerPositioning: ListView.InlineFooter
            footer: Item {
                height: !page.readOnly ? btnAdd.height + 12 : 0
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
                    if (!page.readOnly)
                        popuploader.active = true
                }

                function remove() {
                    removeFake.start()
                    chart.removeFake(index)
                    listView.model.remove(index)
                }

                ColumnLayout {
                    id: dataColumn
                    parent: rowDelegate.contentItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    RowLayout {
                        Layout.fillWidth: true
                        LabelDateTime {
                            Layout.fillWidth: true
                            leftPadding: 8
                            date: Zeitstempel
                        }
                        LabelPlato {
                            Layout.preferredWidth: 70
                            unit: "°P"
                            value: model.SW
                            color: chart.color2
                        }
                        LabelNumber {
                            Layout.preferredWidth: 70
                            precision: 1
                            unit: "°C"
                            value: model.Temp
                            color: chart.color3
                        }
                        LabelNumber {
                            Layout.preferredWidth: 70
                            precision: 1
                            unit: "%"
                            value: model.Alc
                            color: chart.color1
                        }
                    }
                    HorizontalDivider {}
                }
            }
        }
        ColumnLayout {
            id: layoutIngredients
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            HorizontalDivider {
                visible: layoutIngredientsList.count > 0
            }
            LabelSubheader {
                Layout.fillWidth: true
                Layout.leftMargin: 4
                Layout.rightMargin: 4
                visible: layoutIngredientsList.count > 0
                text: qsTr("Weitere Zutaten")
            }
            ListView {

                function addIngredient(item, date) {
                    item.Zeitpunkt_von = date
                    item.Zugabestatus = 1
                    messageDialog.item = item
                    messageDialog.open()
                }

                function removeIngredient(item, date, date2) {
                    item.Zeitpunkt_bis = date
                    item.Zugabestatus = 2
                    item.Zugabedauer = (Math.ceil(date.getTime() / 1440 / 60000) - Math.floor(date2.getTime() / 1440 / 60000)) * 1440
                }

                // message dialog
                MessageDialog {
                    property var item: null
                    id: messageDialog
                    icon: StandardIcon.Question
                    text: qsTr("Rohstoff vom Bestand abziehen?")
                    standardButtons: StandardButton.Yes | StandardButton.No
                    //buttons: MessageDialog.Yes | MessageDialog.No
                    onYes: Brauhelfer.sud.substractIngredient(item.Name, item.Typ, item.erg_Menge)
                }

                id: layoutIngredientsList
                clip: true
                snapMode: ListView.SnapOneItem
                Layout.fillWidth: true
                Layout.leftMargin: 4
                Layout.rightMargin: 4
                height: 92
                visible: layoutIngredientsList.count > 0
                boundsBehavior: Flickable.OvershootBounds
                model: SortFilterProxyModel {
                    sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                    filterKeyColumn: sourceModel.fieldIndex("Zeitpunkt")
                    filterRegExp: /0/
                }
                ScrollIndicator.vertical: ScrollIndicator {}
                Component.onCompleted: height = count > 0 ? itemAt(0, 0).height : 0
                delegate: ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    RowLayout {
                        Layout.fillWidth: true
                        LabelPrim {
                            Layout.fillWidth: true
                            text: model.Name
                        }
                        LabelNumber {
                            value: model.Einheit === 0 ? model.erg_Menge/1000 : model.erg_Menge
                        }
                        LabelPrim {
                            text: model.Einheit === 0 ? qsTr("kg") : qsTr("g")
                        }
                        Item {
                            Layout.preferredWidth: 10
                            visible: model.Entnahmeindex !== 1
                        }
                        LabelNumber {
                            visible: model.Entnahmeindex !== 1
                            precision: 0
                            value: model.Zugabedauer / 1440
                        }
                        LabelPrim {
                            visible: model.Entnahmeindex !== 1
                            text: qsTr("Tage")
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        LabelPrim {
                            text: qsTr("von")
                        }
                        TextFieldDate {
                            id: tfDateAdded
                            Layout.fillWidth: true
                            enabled: !page.readOnly
                            readOnly: model.Zugabestatus !== 0
                            date: model.Zugabestatus === 0 ? new Date() : model.Zeitpunkt_von
                            onNewDate: {
                                this.date = date
                                model.Zeitpunkt_von = date
                            }
                        }
                        LabelPrim {
                            visible: model.Entnahmeindex !== 1
                            text: qsTr("bis")
                        }
                        TextFieldDate {
                            function addDays(date, days) {
                              var result = new Date(date);
                              result.setDate(result.getDate() + days);
                              return result;
                            }
                            id: tfDateRemoved
                            Layout.fillWidth: true
                            enabled: !page.readOnly
                            visible: model.Entnahmeindex !== 1
                            readOnly: model.Zugabestatus !== 1
                            date: model.Zugabestatus === 0 ? addDays(tfDateAdded.date, model.Zugabedauer / 1440) : model.Zugabestatus === 1 ? new Date() : model.Zeitpunkt_bis
                            onNewDate: {
                                this.date = date
                                model.Zeitpunkt_bis = date
                            }
                        }
                        RoundButton {
                            visible: !page.readOnly && (model.Zugabestatus === 0 || (model.Zugabestatus === 1 && model.Entnahmeindex !== 1))
                            contentItem: Image {
                                source: model.Zugabestatus === 0 ? "qrc:/images/ic_add.png" : "qrc:/images/ic_remove.png"
                                anchors.centerIn: parent
                            }
                            enabled: !page.readOnly
                            onClicked: {
                                if (model.Zugabestatus === 0) {
                                    layoutIngredientsList.addIngredient(model, tfDateAdded.date)
                                }
                                else if (model.Zugabestatus === 1) {
                                    layoutIngredientsList.removeIngredient(model, tfDateRemoved.date, tfDateAdded.date)
                                }
                            }
                        }
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        text: model.Bemerkung
                    }
                }
            }
        }

        Loader {
            id: popuploader
            active: false
            focus: true
            onLoaded: item.open()
            sourceComponent: PopupBase {
                property variant model: listView.currentItem.values
                maxWidth: 240
                y: page.height * 0.1
                onOpened: tfSW.forceActiveFocus()
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

                    Image {
                        source: "qrc:/images/ic_schedule.png"
                    }

                    TextFieldDate {
                        id: tfDate
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        date: model.Zeitstempel
                        onNewDate: model.Zeitstempel = date
                    }

                    Image {
                        source: "qrc:/images/refractometer.png"
                    }

                    TextFieldPlato {
                        id: tfBrix
                        onNewValue: {
                            this.value = value
                            var brix = value
                            if (!isNaN(brix)) {
                                var density = Brauhelfer.calc.brixToDichte(Brauhelfer.sud.SWIst, brix)
                                var sre = Brauhelfer.calc.dichteToPlato(density)
                                tfDensity.value = density
                                model.SW = sre
                            }
                            else {
                                tfDensity.value = NaN
                                model.SW = NaN
                            }
                        }
                    }

                    LabelPrim {
                        text: "°Brix"
                        Layout.fillWidth: true
                    }

                    Image {
                        source: "qrc:/images/spindel.png"
                    }

                    TextFieldNumber {
                        id: tfDensity
                        min: 0.0
                        max: 2.0
                        precision: 4
                        value: Brauhelfer.calc.platoToDichte(model.SW)
                        onNewValue: {
                            this.value = value
                            var density = value
                            if (!isNaN(density)) {
                                model.SW = Brauhelfer.calc.dichteToPlato(density)
                            }
                            else {
                                model.SW = NaN
                            }
                            tfBrix.value = NaN
                        }
                    }

                    LabelPrim {
                        text: "g/ml"
                        Layout.fillWidth: true
                    }

                    Image {
                        source: "qrc:/images/sugar.png"
                    }

                    TextFieldPlato {
                        id: tfSW
                        value: model.SW
                        onNewValue: {
                            model.SW = value
                            var sre = value
                            if (!isNaN(sre)) {
                                tfDensity.value = Brauhelfer.calc.platoToDichte(sre)
                            }
                            else {
                                tfDensity.value = NaN
                            }
                            tfBrix.value = NaN
                        }
                    }

                    LabelPrim {
                        text: "°P"
                        Layout.fillWidth: true
                    }

                    Image {
                        source: "qrc:/images/temperature.png"
                    }

                    TextFieldTemperature {
                        value: model.Temp
                        onNewValue: model.Temp = value
                    }

                    LabelPrim {
                        text: "°C"
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        Layout.columnSpan: 3
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        onClicked: remove()
                        contentItem: Image {
                            source: "qrc:/images/ic_delete.png"
                            anchors.centerIn: parent
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
