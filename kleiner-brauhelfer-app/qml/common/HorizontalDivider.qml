import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

// https://material.google.com/components/dividers.html#dividers-types-of-dividers

Rectangle {
    property alias color: rect.color

    id: rect
    width: parent.width
    height: 1
    color: Material.foreground
    opacity: 0.12
}
