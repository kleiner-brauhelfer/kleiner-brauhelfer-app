LabelPrim {
    property double value: Number.NaN
    property int precision: 1
    property string unit: ""
    horizontalAlignment: Text.AlignHCenter
    text: isNaN(value) ? "" : (Number(value).toLocaleString(Qt.locale(), 'f', precision) + (unit != "" ? " " + unit : ""))
}
