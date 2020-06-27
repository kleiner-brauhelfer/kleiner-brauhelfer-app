import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

// https://material.google.com/style/color.html#color-color-schemes

LabelPrim {
    property double value: Number.NaN
    property int precision: 1
    property string unit: ""
    horizontalAlignment: Text.AlignHCenter
    text: isNaN(value) ? "" : (Number(value).toLocaleString(Qt.locale(), 'f', precision) + (unit != "" ? " " + unit : ""))
}
