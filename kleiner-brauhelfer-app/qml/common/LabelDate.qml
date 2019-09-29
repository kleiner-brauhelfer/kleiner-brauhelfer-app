import QtQuick 2.9
import QtQuick.Controls 2.2

LabelPrim {
    property date date
    text: isNaN(date) ? "" : date.toLocaleDateString(Locale.ShortFormat)
    horizontalAlignment: Text.AlignHCenter
}
