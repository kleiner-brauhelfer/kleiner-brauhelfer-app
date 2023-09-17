import QtQuick

QtObject {
    readonly property var einheiten: [
        qsTr("kg"),
        qsTr("g"),
        qsTr("mg"),
        qsTr("Stk."),
        qsTr("L"),
        qsTr("mL")]

    readonly property var einheitenDivider: [
        1/1000,
        1,
        1000,
        1,
        1/1000,
        1000]

    readonly property var zusatzTypname: [
        qsTr("Honig"),
        qsTr("Zucker"),
        qsTr("Gewürz"),
        qsTr("Frucht"),
        qsTr("Sonstiges"),
        qsTr("Kraut"),
        qsTr("Wasseraufbereitung"),
        qsTr("Klärmittel")]
}
