import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

// https://material.google.com/style/color.html#color-color-schemes

Label {
    font.pointSize: 14 * app.settings.scalingfactor
    wrapMode: Label.WordWrap
    elide: Label.ElideRight
    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
}
