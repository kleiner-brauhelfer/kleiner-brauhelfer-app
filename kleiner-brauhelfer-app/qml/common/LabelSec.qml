import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

// https://material.google.com/style/color.html#color-color-schemes

Label {
    wrapMode: Label.WordWrap
    elide: Label.ElideRight
    opacity: enabled ? app.config.textOpacityHalf : app.config.textOpacityDisabled
}
