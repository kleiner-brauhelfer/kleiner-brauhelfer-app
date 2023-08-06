import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

ToolButton {

    property var page: model.view.itemAt(model.index)
    property bool isCurrentPage: navPane.isCurrentPage(model.view, model.index)

    onClicked: {
        navPane.goTo(model.view, model.index)
        navigation.close()
    }

    Rectangle {
        anchors.fill: parent
        visible: isCurrentPage
        color: Material.listHighlightColor
    }

    RowLayout {
        spacing: 16 * app.settings.scalingfactor
        anchors.verticalCenter: parent.verticalCenter
        Image {
            Layout.leftMargin: 8
            width: 24 * app.settings.scalingfactor
            height: width
            visible: page.icon
            opacity: isCurrentPage ? 1.0 : enabled ? 0.87 : 0.37
            source: visible ? "qrc:/images/" + page.icon : ""
            layer.enabled: isCurrentPage && parent.visible
            layer.effect: ColorOverlay {
                color: Material.primary
            }
        }
        Label {
            text: page.title
            opacity: isCurrentPage ? 1.0 : 0.87
            color: isCurrentPage ? Material.primary : Material.foreground
            font.pointSize: 16 * app.settings.scalingfactor
            font.bold: isCurrentPage
            elide: Text.ElideRight
        }
    }
}
