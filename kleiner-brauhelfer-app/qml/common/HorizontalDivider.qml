import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

// https://material.google.com/components/dividers.html#dividers-types-of-dividers

Rectangle {
    property alias color: rect.color

    id: rect
    height: 1
    anchors.left: parent.left
    anchors.right: parent.right
    color: Material.foreground
    opacity: 0.12
}
