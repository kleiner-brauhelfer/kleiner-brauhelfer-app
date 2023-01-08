import QtQuick
import QtQuick.Controls
import QtCharts

ChartView {
    property alias timeformat: dAxisX.format
    property alias series1: series1
    property alias title1: series1.name
    property alias color1: series1.color
    property var should1: null
    property alias series2: series2
    property alias title2: series2.name
    property alias color2: series2.color
    property var should2: null
    property alias series3: series3
    property alias title3: series3.name
    property alias color3: series3.color
    property var should3: null

    antialiasing: true
    legend.visible: true
    legend.alignment: Qt.AlignBottom
    backgroundColor: "transparent"
    backgroundRoundness: 0.0
    margins.top: 0
    margins.left: 0
    margins.right: 0
    margins.bottom: 0
    animationOptions: ChartView.NoAnimation

    Component.onCompleted: {
        buildAxis(series1, axisY1)
        buildAxis(series2, axisY2)
        buildAxis(series3, axisY3)
    }

    DateTimeAxis {
        id: dAxisX
        format: "dd.MM"
        tickCount: 4
    }

    LineSeries {
        id: series1
        width: 2
        visible: title1 !== ""
        axisX: dAxisX
        axisY: ValueAxis {
            id: axisY1
            visible: series1.visible
            color: series1.color
            labelsColor: color
            titleBrush: color
            labelFormat: "%.1f"
        }
        onPointAdded: buildAxis(series1, axisY1)
        onPointReplaced: buildAxis(series1, axisY1)
        onPointRemoved: buildAxis(series1, axisY1)
    }

    LineSeries {
        id: series1Should
        color: series1.color
        width: series1.width
        style: Qt.DashLine
        visible: should1 !== null
        axisX: series1.axisX
        axisY: series1.axisY
    }

    LineSeries {
        id: series2
        visible: title2 !== ""
        axisX: dAxisX
        axisYRight: ValueAxis {
            id: axisY2
            visible: series2.visible
            color: series2.color
            labelsColor: color
            titleBrush: color
            labelFormat: "%.1f"
        }
        onPointAdded: buildAxis(series2, axisY2)
        onPointReplaced: buildAxis(series2, axisY2)
        onPointRemoved: buildAxis(series2, axisY2)
    }

    LineSeries {
        id: series2Should
        color: series2.color
        width: series2.width
        style: Qt.DashLine
        visible: should2 !== null
        axisX: series2.axisX
        axisYRight: series2.axisYRight
    }

    LineSeries {
        id: series3
        visible: title3 !== ""
        axisX: dAxisX
        axisYRight: ValueAxis {
            id: axisY3
            visible: series3.visible
            color: series3.color
            labelsColor: color
            titleBrush: color
            labelFormat: "%.1f"
        }
        onPointAdded: buildAxis(series3, axisY3)
        onPointReplaced: buildAxis(series3, axisY3)
        onPointRemoved: buildAxis(series3, axisY3)
    }

    LineSeries {
        id: series3Should
        color: series3.color
        width: series3.width
        style: Qt.DashLine
        visible: should3 !== null
        axisX: series3.axisX
        axisYRight: series3.axisYRight
    }

    function toMsecsSinceEpoch(date) {
        return date.getTime()
    }

    function fromMsecsSinceEpoch(msecs) {
        return new Date(msecs)
    }

    function buildAxis(series, axisY) {
        var index = 0
        var pt
        var minX, maxX, minY, maxY

        // first point: x
        pt = series.at(index)
        minX = pt.x;
        maxX = pt.x + 1; // add one day

        // first point: y
        minY = Math.floor(pt.y)
        maxY = Math.ceil(pt.y) + 1
        if (minY === maxY)
            maxY = minY + 1 // add 1

        for (index = 1; index < series.count; ++index) {
            pt = series.at(index)
            if (pt.x < minX)
                minX = pt.x
            if (pt.x > maxX)
                maxX = pt.x
            if (pt.y < minY)
                minY = Math.floor(pt.y)
            if (pt.y > maxY)
                maxY = Math.ceil(pt.y)
        }

        if (series === series1 && should1 !== null) {
            series1Should.clear()
            series1Should.append(minX, should1)
            series1Should.append(maxX, should1)
            if (should1 < minY)
                minY = Math.floor(should1)
            if (should1 > maxY)
                maxY = Math.ceil(should1)
        }
        if (series === series2 && should2 !== null) {
            series2Should.clear()
            series2Should.append(minX, should2)
            series2Should.append(maxX, should2)
            if (should2 < minY)
                minY = Math.floor(should2)
            if (should2 > maxY)
                maxY = Math.ceil(should2)
        }
        if (series === series3 && should3 !== null) {
            series3Should.clear()
            series3Should.append(minX, should3)
            series3Should.append(maxX, should3)
            if (should3 < minY)
                minY = Math.floor(should3)
            if (should3 > maxY)
                maxY = Math.ceil(should3)
        }

        dAxisX.min = fromMsecsSinceEpoch(minX)
        dAxisX.max = fromMsecsSinceEpoch(maxX)
        axisY.min = minY
        axisY.max = maxY
    }

    function removeFake(index) {
        if (index > 0) {
            var p, p0
            if (title1 !== "") {
                p0 = series1.at(index - 1)
                p = series1.at(index)
                series1.replace(p.x, p.y, p0.x, p0.y)
            }
            if (title2 !== "") {
                p0 = series2.at(index - 1)
                p = series2.at(index)
                series2.replace(p.x, p.y, p0.x, p0.y)
            }
            if (title3 !== "") {
                p0 = series3.at(index - 1)
                p = series3.at(index)
                series3.replace(p.x, p.y, p0.x, p0.y)
            }
        }
    }
}
