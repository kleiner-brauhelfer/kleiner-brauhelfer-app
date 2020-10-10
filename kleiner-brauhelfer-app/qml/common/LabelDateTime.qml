import QtQuick 2.15
import QtQuick.Controls 2.15

LabelPrim {
    property date date
    text: isNaN(date) ? "" : date.toLocaleString(Locale.ShortFormat)
    horizontalAlignment: Text.AlignHCenter
}
