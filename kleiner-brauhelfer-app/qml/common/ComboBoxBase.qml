import QtQuick
import QtQuick.Controls

ComboBox {
    property bool sizeToContents : true
    property int modelWidth

    font.pointSize: 14 * app.settings.scalingfactor
    popup.font.pointSize: 14 * app.settings.scalingfactor
    width: (sizeToContents) ? modelWidth + 2*leftPadding + 2*rightPadding : implicitWidth
    height: implicitHeight * app.settings.scalingfactor

    TextMetrics {
        id: textMetrics
    }

    onModelChanged: {
        textMetrics.font = font
        for(var i = 0; i < model.length; i++){
            textMetrics.text = model[i]
            modelWidth = Math.max(textMetrics.width, modelWidth)
        }
    }
}
