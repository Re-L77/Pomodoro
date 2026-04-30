import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.15

Window {
    id: dbWin
    property var timerBackend
    visible: false
    width: 640
    height: 480
    title: "Session Records"
    flags: Qt.Window
    color: "transparent"

    Rectangle {
        id: dbBackground
        anchors.fill: parent
        color: "#252540"
        radius: 12
        opacity: timerBackend.windowOpacity

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Session Records"; font.pixelSize: 20; font.bold: true; color: "#ffffff" }
            Item { Layout.fillWidth: true }
            Button { 
                text: "Reload"
                background: Rectangle { color: "#D5E8F7"; radius: 8; border.color: "#B8D5E8"; border.width: 1 }
                contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true; font.pixelSize: 11 }
                onClicked: reload()
            }
            Button { 
                text: "Clear History"
                background: Rectangle { color: "#E8B8C5"; radius: 8; border.color: "#E89BA8"; border.width: 1 }
                contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true; font.pixelSize: 11 }
                onClicked: { timerBackend.clearHistory(); reload() }
            }
            Button { 
                text: "Export CSV"
                background: Rectangle { color: "#D5B8E8"; radius: 8; border.color: "#C5A8D8"; border.width: 1 }
                contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true; font.pixelSize: 11 }
                onClicked: fileDialog.open()
            }
            Button { 
                text: "Close"
                background: Rectangle { color: "#555566"; radius: 8; border.color: "#666677"; border.width: 1 }
                contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true; font.pixelSize: 11 }
                onClicked: dbWin.close()
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: []
            delegate: Rectangle {
                width: listView.width
                color: "transparent"
                height: implicitHeight + 8
                Column {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    Text { text: "#" + model.id + " " + model.from_state + " → " + model.to_state; color: "#ffffff"; font.bold: true }
                    Text { text: "Started: " + model.started_at + "  Ended: " + model.ended_at; color: "#cccccc"; font.pixelSize: 11 }
                    Text { text: "Cycle: " + model.cycle + "  Duration(s): " + model.duration_seconds + "  Completed: " + (model.completed == 1 ? "yes" : "no"); color: "#aaaaaa"; font.pixelSize: 11 }
                    Rectangle { height: 1; color: "#2a2a3e"; anchors.left: parent.left; anchors.right: parent.right; anchors.topMargin: 4 }
                }
            }
        }
    }
    }

    FileDialog { id: fileDialog; title: "Export CSV"; nameFilters: ["CSV files (*.csv)"]; onAccepted: { if (fileUrl) { timerBackend.exportHistoryCsv(fileUrl); } } }

    function reload() {
        var data = timerBackend.recentSessionRecords(500)
        listView.model = data
    }

    Component.onCompleted: reload()
}
