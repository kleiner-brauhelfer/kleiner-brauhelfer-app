import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    property bool sizeToContents : true
    property int modelWidth

    font.pointSize: 14 * app.settings.scalingfactor
    width: (sizeToContents) ? modelWidth + 2*leftPadding + 2*rightPadding : implicitWidth

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
