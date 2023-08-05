import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

// https://material.google.com/components/dividers.html#dividers-types-of-dividers

Rectangle {
    property alias color: rect.color

    id: rect
    width: parent.width
    height: 1
    color: Material.foreground
    opacity: 0.12
}
