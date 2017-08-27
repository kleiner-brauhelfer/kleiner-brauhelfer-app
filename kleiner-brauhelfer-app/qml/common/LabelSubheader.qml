import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

// https://material.io/guidelines/components/subheaders.html#subheaders-list-subheaders

Label {
    color: Material.primary
    font.pixelSize: 16
    font.bold: true
    wrapMode: Label.WordWrap
    elide: Label.ElideRight
    opacity: Material.theme === Material.Dark ? 1.00 : 0.87
}
