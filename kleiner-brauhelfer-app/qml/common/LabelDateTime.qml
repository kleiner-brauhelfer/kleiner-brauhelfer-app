import QtQuick
import QtQuick.Controls

LabelPrim {
    property date date
    text: isNaN(date) ? "" : date.toLocaleString(Locale.ShortFormat)
    horizontalAlignment: Text.AlignHCenter
}
