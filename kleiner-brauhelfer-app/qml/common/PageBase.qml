import QtQuick 2.9
import QtQuick.Controls 2.2

import brauhelfer 1.0

Page {
    property string icon: ""
    property bool readOnly: false
    default property alias component: loader.sourceComponent

    signal loaded()
    signal unloaded()

    id: page
    enabled: true
    bottomPadding: 6
    topPadding: 6
    onFocusChanged: loader.active = (app.loaded && focus) || loader.active
    onVisibleChanged: loader.active = (app.loaded && focus) || loader.active

    function unload() {
        if (loader.active) {
            page.unloaded()
            loader.active = false
            Brauhelfer.message("Page unloaded: " + title)
        }
    }

    Loader {
        id: loader
        active: false
        anchors.fill: parent
        onLoaded: {
            Brauhelfer.message("Page loaded: " + title)
            page.loaded()
        }
    }
}
