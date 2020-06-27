import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

// https://material.google.com/components/dividers.html#dividers-types-of-dividers

Rectangle {
    property alias color: rect.color

    id: rect
    width: parent.width
    height: 1
    color: Material.foreground
    opacity: 0.12
}
