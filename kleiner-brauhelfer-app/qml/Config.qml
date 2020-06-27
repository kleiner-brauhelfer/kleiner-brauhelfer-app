import QtQuick 2.15
import QtQuick.Controls.Material 2.15

QtObject {
    readonly property int headerFooterPositioningThresh: 500
    readonly property real textOpacityFull: Material.theme === Material.Dark ? 1.00 : 0.87
    readonly property real textOpacityHalf: Material.theme === Material.Dark ? 0.70 : 0.54
    readonly property real textOpacityDisabled: Material.theme === Material.Dark ? 0.50 : 0.38
}
