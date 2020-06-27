import QtQuick 2.15
import QtQuick.Controls 2.15

TextFieldBase {

    signal newDate(date date)

    property date date

    function formatedText() {
        return isNaN(date) ? "" : date.toLocaleDateString(Locale.ShortFormat)
    }

    id: tf
    implicitWidth: 100
    wrapMode: TextArea.Wrap
    inputMethodHints: Qt.ImhDate
    horizontalAlignment: Text.AlignHCenter
    onActiveFocusChanged: text = activeFocus ? formatedText() : Qt.binding(formatedText)
    text: formatedText()
    onTextChanged: {
        if (activeFocus && acceptableInput) {
            var _date = Date.fromLocaleDateString(Qt.locale(), text, Locale.ShortFormat)
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
