import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.0

ToolButton {

    property var page: model.view.itemAt(model.index)
    property bool currentPage: navPane.isCurrentPage(model.view, model.index)

    onClicked: {
        navPane.goTo(model.view, model.index)
        navigation.close()
    }

    Rectangle {
        anchors.fill: parent
        visible: currentPage
        color: Material.listHighlightColor
    }

    RowLayout {
        spacing: 16
        anchors.verticalCenter: parent.verticalCenter

        Item {
            Layout.leftMargin: 8
            width: 24
            height: 24

            Image {
                id: icon
                anchors.fill: parent
                visible: page.icon !== ""
                opacity: currentPage ? 1.0 : enabled ? 0.87 : 0.37
                source: visible ? "qrc:/images/" + page.icon : ""
            }

            ColorOverlay {
                visible: currentPage && icon.visible
                anchors.fill: icon
                source: icon
                color: Material.primary
            }
        }

        Label {
            text: page.title
            opacity: currentPage ? 1.0 : enabled ? 0.87 : 0.37
            color: currentPage ? Material.primary : Material.foreground
            font.pixelSize: 16
            font.bold: currentPage
            elide: Text.ElideRight
        }
    }
}
