import QtQuick
import QtQuick.Controls

SpinBox {

    signal newValue(real value)

    property real realValue: Number.NaN
    property int decimals: 1
    property real min: 0.0
    property real max: 999.9
    readonly property int factor: Math.pow(10, decimals)

    editable: true
    implicitWidth: 160

    focusPolicy: Qt.StrongFocus

    stepSize: decimals === 0 ? 1 : 10
    from: min * factor
    to: max * factor
    value: realValue * factor

    font.pointSize: 14 * app.settings.scalingfactor

    validator: DoubleValidator {
        bottom: Math.min(from, to)
        top: Math.max(from, to)
        decimals: decimals
        notation: DoubleValidator.StandardNotation
    }

    textFromValue: function(value, locale) {
        return Number(value / factor).toLocaleString(locale, 'f', decimals)
    }

    valueFromText: function(text, locale) {
        return Number.fromLocaleString(locale, text) * factor
    }

    onValueModified: {
        var _value = value / factor
        if (realValue !== _value)
            newValue(_value)
    }
}
