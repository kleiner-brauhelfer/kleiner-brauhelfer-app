import QtQuick
import QtQuick.Controls

TextField {
    font.pointSize: 14 * app.settings.scalingfactor
    Component.onCompleted: cursorPosition = 0
}
