import QtQuick 2.9
import QtQuick.Controls 2.2

SpinBox {

    signal newValue(real value)

    property real realValue: Number.NaN
    property int decimals: 1
    property real min: 0.0
    property real max: 99999.9
    readonly property int factor: Math.pow(10, decimals)

    editable: true

    stepSize: decimals === 0 ? 1 : 10
    from: min * factor
    to: max * factor
    value: realValue * factor

    validator: DoubleValidator {
        bottom: Math.min(from, to)
        top:  Math.max(from, to)
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
