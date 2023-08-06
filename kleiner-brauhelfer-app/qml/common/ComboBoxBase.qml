import QtQuick
import QtQuick.Controls

ComboBox {
    font.pointSize: 14 * app.settings.scalingfactor
    popup.font.pointSize: 14 * app.settings.scalingfactor
    height: implicitHeight * app.settings.scalingfactor
    topInset: 0
    bottomInset: 0
    leftInset: 0
    rightInset: 0
}
