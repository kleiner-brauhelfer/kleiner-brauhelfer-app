import QtQuick
import QtQuick.Controls

TextFieldBase {

    signal newDate(date date)

    property date date

    function formatedText() {
        return isNaN(date) ? "" : date.toLocaleString(Locale.ShortFormat)
    }

    id: tf
    implicitWidth: 150
    wrapMode: TextArea.Wrap
    inputMethodHints: Qt.ImhDate | Qt.ImhTime
    horizontalAlignment: Text.AlignHCenter
    onActiveFocusChanged: text = activeFocus ? formatedText() : Qt.binding(formatedText)
    text: formatedText()
    onTextChanged: {
        if (activeFocus && acceptableInput) {
            var _date = Date.fromLocaleString(Qt.locale(), tf.text, Locale.ShortFormat)
            var year = _date.getFullYear()
            if (year < 2000)
                _date.setFullYear(year + 100)
            if (isNaN(_date)) {
                state = "invalid"
            }
            else {
                state = ""
                if (date.getTime() !== _date.getTime()) {
                    newDate(_date)
                }
            }
        }
    }

    states: [
        State {
            name: "invalid"
            PropertyChanges { target: tf; color: "red" }
        }
    ]
}
