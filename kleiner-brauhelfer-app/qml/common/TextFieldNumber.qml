import QtQuick
import QtQuick.Controls

TextFieldBase {

    signal newValue(real value)

    property real value: NaN
    property real min: 0
    property real max: Infinity
    property int precision: 1

    function formatedText() {
        return isNaN(value) ? "" : Number(value).toLocaleString(Qt.locale(), 'f', precision)
    }

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
        if (activeFocus) {
            if (Qt.locale().decimalPoint === ",")
                text = text.replace(".", ",")
            if (acceptableInput) {
                var _value = Number.fromLocaleString(Qt.locale(), text)
                if (value !== _value)
                    newValue(_value)
            }
        }
    }
}
