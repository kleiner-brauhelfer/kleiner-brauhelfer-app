import QtQuick 2.9
import QtQuick.Controls 2.2

TextFieldNumber {

    property bool useDialog: false
    property alias sw: popup.sw

    id: textfield
    min: 0.0
    max: 99.9
    precision: 2

    onPressed: if (useDialog) popup.edit(value)

    PopupPlato {
        id: popup
        onClosed: {
            if (value !== textfield.value)
                newValue(value)
            textfield.focus = false
        }
    }
}
