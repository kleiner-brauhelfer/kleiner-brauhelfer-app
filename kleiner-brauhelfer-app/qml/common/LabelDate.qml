LabelPrim {
    property date date
    text: isNaN(date) ? "" : date.toLocaleDateString(Locale.ShortFormat)
    horizontalAlignment: Text.AlignHCenter
}
