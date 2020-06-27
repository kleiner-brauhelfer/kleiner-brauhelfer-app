import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

// https://material.io/guidelines/components/subheaders.html#subheaders-list-subheaders

Label {
    color: Material.primary
    font.pixelSize: 16
    font.bold: true
    wrapMode: Label.WordWrap
    elide: Label.ElideRight
    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
}
