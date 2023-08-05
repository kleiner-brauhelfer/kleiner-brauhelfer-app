import QtQuick
import QtQuick.Controls

import brauhelfer

Page {
    property string icon: ""
    property bool readOnly: false
    default property alias component: loader.sourceComponent
    property alias loaderItem: loader.item

    enabled: true
    padding: 0
    spacing: 0
    onFocusChanged: loader.active |= (app.loaded && focus)
    onVisibleChanged: loader.active |= (app.loaded && focus)

    function unload() {
        if (loader.active) {
            loader.active = false
        }
    }

    MouseAreaCatcher { }

    Loader {
        id: loader
        active: false
        anchors.fill: parent
    }
}
