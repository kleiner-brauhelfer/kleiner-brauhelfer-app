import QtQuick 2.9
import QtQuick.Controls 2.2

import brauhelfer 1.0

Page {
    property string icon: ""
    property bool readOnly: false
    default property alias component: loader.sourceComponent

    enabled: true
    padding: 0
    spacing: 0
    onFocusChanged: loader.active |= (app.loaded && focus)
    onVisibleChanged: loader.active |= (app.loaded && focus)

    function unload() {
        if (loader.active) {
            loader.active = false
            Brauhelfer.message("Page unloaded: " + title)
        }
    }

    MouseAreaCatcher { }

    Loader {
        id: loader
        active: false
        anchors.fill: parent
        onLoaded: Brauhelfer.message("Page loaded: " + title)
    }
}
