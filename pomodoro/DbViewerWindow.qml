import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: dbWin
    property var timerBackend
    visible: false
    width: 700
    height: 520
    title: "Session Records"
    flags: Qt.Window
    color: "transparent"
    opacity: timerBackend && timerBackend.transparencyEnabled ? timerBackend.windowOpacity : 1.0

    Rectangle {
        id: windowBg
        anchors.fill: parent
        color: "#1a1a2e"
        radius: 12
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Session Records"
                font.pixelSize: 20
                font.bold: true
                color: "#ffffff"
            }
            Item { Layout.fillWidth: true }

            // Styled Reload button
            Button {
                text: "↻  Reload"
                implicitWidth: 100
                implicitHeight: 36
                background: Rectangle {
                    color: parent.hovered ? "#5a5fcc" : "#4a4faa"
                    radius: 8
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: reload()
            }

            // Styled Clear History button
            Button {
                text: "🗑  Clear"
                implicitWidth: 100
                implicitHeight: 36
                background: Rectangle {
                    color: parent.hovered ? "#d14545" : "#c93c3c"
                    radius: 8
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: { timerBackend.clearHistory(); reload(); }
            }

            // Styled Export CSV button
            Button {
                text: "📄  Export"
                implicitWidth: 100
                implicitHeight: 36
                background: Rectangle {
                    color: parent.hovered ? "#3da86b" : "#2e9957"
                    radius: 8
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: { fileDialog.open() }
            }

            // Styled Close button
            Button {
                text: "✕  Close"
                implicitWidth: 100
                implicitHeight: 36
                background: Rectangle {
                    color: parent.hovered ? "#555566" : "#3d3d50"
                    radius: 8
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: dbWin.close()
            }
        }

        // Separator line
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333555"
        }

        // Session list
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: []
            spacing: 4

            // "No records" placeholder
            Text {
                anchors.centerIn: parent
                text: "No session records yet.\nComplete a pomodoro cycle to see records here."
                color: "#666688"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                visible: listView.count === 0
            }

            delegate: Rectangle {
                width: listView.width
                height: delegateCol.implicitHeight + 16
                color: delegateArea.containsMouse ? "#252545" : "#20203a"
                radius: 8
                border.color: "#2a2a4a"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }

                MouseArea {
                    id: delegateArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Column {
                    id: delegateCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 12
                    spacing: 4

                    Text {
                        text: "#" + modelData.id + "  " + modelData.from_state + " → " + modelData.to_state
                        color: "#e0e0ff"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Text {
                        text: "Started: " + modelData.started_at + "   Ended: " + modelData.ended_at
                        color: "#9999bb"
                        font.pixelSize: 12
                    }
                    Text {
                        text: "Cycle: " + modelData.cycle + "   Duration: " + modelData.duration_seconds + "s   Completed: " + (modelData.completed == 1 ? "✓ yes" : "✗ no")
                        color: "#7777aa"
                        font.pixelSize: 12
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
            }
        }

        // Footer with record count
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: listView.count + " record(s)"
                color: "#666688"
                font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "DB: " + (timerBackend ? timerBackend.databasePath() : "")
                color: "#555577"
                font.pixelSize: 11
                elide: Text.ElideMiddle
                Layout.maximumWidth: 400
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
