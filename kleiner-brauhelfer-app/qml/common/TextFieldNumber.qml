import QtQuick 2.9
import QtQuick.Controls 2.2

TextFieldBase {

    signal newValue(real value)

    property real value: NaN
    property real min: 0
    property real max: Infinity
    property int precision: 1

    function formatedText() {
        return isNaN(value) ? "" : Number(value).toLocaleString(Qt.locale(), 'f', precision)
    }

    implicitWidth: 60
    wrapMode: TextArea.Wrap
    inputMethodHints: Qt.ImhFormattedNumbersOnly
    horizontalAlignment: Text.AlignHCenter
    validator: DoubleValidator {
        bottom: min
        top: max
        decimals: precision
        notation: DoubleValidator.StandardNotation
    }
    onActiveFocusChanged: text = activeFocus ? formatedText() : Qt.binding(formatedText)
    text: formatedText()
    onTextChanged: {
        if (activeFocus && acceptableInput) {
            var _value = Number.fromLocaleString(Qt.locale(), text)
            if (value !== _value)
                newValue(_value)
        }
    }
}
