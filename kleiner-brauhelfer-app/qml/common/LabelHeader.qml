import QtQuick.Controls.Material

LabelPrim {
    font.pointSize: 16 * app.settings.scalingfactor
    font.bold: true
    color: Material.primary
    opacity: app.config.textOpacityFull
}
