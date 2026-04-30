import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: dbWin
    property var timerBackend
    visible: false
    width: 640
    height: 480
    title: "Session Records"
    flags: Qt.Window
    opacity: 0.95

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout { Layout.fillWidth: true; spacing: 8;
            Text { text: "Session Records"; font.pixelSize: 18; color: "#ffffff" }
            Item { Layout.fillWidth: true }
            Button { text: "Reload"; onClicked: reload() }
            Button { text: "Clear History"; onClicked: { timerBackend.clearHistory(); reload(); } }
            Button { text: "Export CSV"; onClicked: { fileDialog.open() } }
            Button { text: "Close"; onClicked: dbWin.close() }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: []
            delegate: Rectangle {
                width: listView.width
                color: "transparent"
                Column {
                    spacing: 2
                    Text { text: "#" + model.id + " " + model.from_state + " → " + model.to_state; color: "#ffffff" }
                    Text { text: "Started: " + model.started_at + "  Ended: " + model.ended_at; color: "#aaaaaa"; font.pixelSize: 12 }
                    Text { text: "Cycle: " + model.cycle + "  Duration(s): " + model.duration_seconds + "  Completed: " + (model.completed == 1 ? "yes" : "no"); color: "#888888"; font.pixelSize: 12 }
                    Rectangle { height: 1; color: "#2a2a2a"; Layout.fillWidth: true }
                }
            }
        }
    }

    FileDialog { id: fileDialog; title: "Export CSV"; selectExisting: false; folder: Qt.homeDir(); onAccepted: { if (fileUrl) { timerBackend.exportHistoryCsv(fileUrl); } } }

    function reload() {
        var data = timerBackend.recentSessionRecords(500)
        listView.model = data
    }

    Component.onCompleted: reload()
}
