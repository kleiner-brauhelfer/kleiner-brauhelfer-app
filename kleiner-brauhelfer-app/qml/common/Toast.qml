import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Popup {
    id: popup
    closePolicy: Popup.NoAutoClose
    bottomMargin: app.height / 10
    x: (app.width - width) / 2
    y: (app.height - height)

    function start(toastText) {
        toastLabel.text = toastText
        if(!toastTimer.running) {
            open()
        } else {
            toastTimer.restart()
        }
    }

    onAboutToShow: {
        toastTimer.start()
    }

    background: Rectangle{
        color: Material.primary
        radius: 24
    }

    Timer {
        id: toastTimer
        interval: 2000
        repeat: false
        onTriggered: popup.close()
    }

    LabelPrim {
        id: toastLabel
        leftPadding: 16
        rightPadding: 16
        font.pointSize: 16 * app.settings.scalingfactor
        color: Material.background
    }
}
