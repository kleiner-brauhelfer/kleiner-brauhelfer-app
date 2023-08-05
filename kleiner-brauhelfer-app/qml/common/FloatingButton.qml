import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

RoundButton {

    property alias imageSource: contentImage.source

    id: button
    z:1

    contentItem: Image {
        id: contentImage
        height: 24
        width: 24
    }

    background: Rectangle {
        implicitWidth: 48
        implicitHeight: 48
        color: Material.color(Material.accent, button.pressed ? Material.Shade300 : Material.Shade500)
        radius: width / 2
        layer.enabled: button.enabled
        layer.effect: DropShadow {
            verticalOffset: 3
            horizontalOffset: 1
            color: Material.dropShadowColor
            samples: button.pressed ? 20 : 10
            spread: 0.5
        }
    }

}
