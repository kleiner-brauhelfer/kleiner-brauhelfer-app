import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

// https://material.google.com/style/color.html#color-color-schemes

Label {
    wrapMode: Label.WordWrap
    elide: Label.ElideRight
    opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
}
