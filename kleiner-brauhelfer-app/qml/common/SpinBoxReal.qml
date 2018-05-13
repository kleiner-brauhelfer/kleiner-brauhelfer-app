import QtQuick 2.9
import QtQuick.Controls 2.2

SpinBox {
    property real realValue: Number.NaN
    property int decimals: 1

    from: 0
    to: 999999
    editable: true

    stepSize: decimals === 0 ? 1 : 10
    value: realValue * Math.pow(10, decimals)

    validator: DoubleValidator {
        bottom: Math.min(from, to)
        top:  Math.max(from, to)
        decimals: decimals
        notation: DoubleValidator.StandardNotation
    }

    textFromValue: function(value, locale) {
        return Number(value / Math.pow(10, decimals)).toLocaleString(locale, 'f', decimals)
    }

    valueFromText: function(text, locale) {
        return Number.fromLocaleString(locale, text) * Math.pow(10, decimals)
    }

    onValueModified: {
        var _value = value / Math.pow(10, decimals)
        if (realValue !== _value)
            realValue = _value
    }
}
