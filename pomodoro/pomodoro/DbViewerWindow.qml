import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.15

Window {
    id: dbWin
    property var timerBackend

    visible: false
    width: 750
    height: 560
    title: "Session Records"
    flags: Qt.Window
    color: "#0d0d1a"
    opacity: timerBackend && timerBackend.transparencyEnabled ? timerBackend.windowOpacity : 1.0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        // ── Header ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "📋 Session Logs"
                font.pixelSize: 20
                font.bold: true
                color: "#e0e0e0"
            }

            // Record count badge
            Rectangle {
                implicitWidth: countText.implicitWidth + 16
                implicitHeight: 22
                radius: 11
                color: Qt.rgba(0.49, 0.46, 0.90, 0.3)
                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: listView.count + ""
                    color: "#a5b4fc"
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            Item { Layout.fillWidth: true }

            // Reload
            Button {
                implicitWidth: 36; implicitHeight: 32
                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(1,1,1,0.12) : Qt.rgba(1,1,1,0.05)
                    radius: 6
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                contentItem: Text {
                    text: "↻"; color: "#a5b4fc"; font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                ToolTip.visible: hovered; ToolTip.text: "Reload"
                onClicked: reload()
            }
            // Clear
            Button {
                implicitWidth: 80; implicitHeight: 32
                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(0.86, 0.15, 0.15, 0.5) : Qt.rgba(0.86, 0.15, 0.15, 0.2)
                    radius: 6
                    border.color: Qt.rgba(0.86, 0.15, 0.15, 0.4)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                contentItem: Text {
                    text: "🗑 Clear"; color: "#fca5a5"; font.pixelSize: 12; font.bold: true
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: confirmClearDialog.open()
            }

            // Export
            Button {
                implicitWidth: 90; implicitHeight: 32
                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(0.09, 0.64, 0.37, 0.5) : Qt.rgba(0.09, 0.64, 0.37, 0.2)
                    radius: 6
                    border.color: Qt.rgba(0.09, 0.64, 0.37, 0.4)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                contentItem: Text {
                    text: "📄 Export"; color: "#86efac"; font.pixelSize: 12; font.bold: true
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: fileDialog.open()
            }

            // Close
            Button {
                implicitWidth: 32; implicitHeight: 32
                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(1,1,1,0.15) : Qt.rgba(1,1,1,0.05)
                    radius: 6
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                contentItem: Text {
                    text: "✕"; color: "#999"; font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: dbWin.close()
            }
        }

        // ── Column headers ──
        Rectangle {
            Layout.fillWidth: true
            height: 28
            color: Qt.rgba(1, 1, 1, 0.03)
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 0

                Text { text: "#"; color: "#666"; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 40 }
                Text { text: "TRANSITION"; color: "#666"; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 180 }
                Text { text: "STARTED"; color: "#666"; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 180 }
                Text { text: "CYCLE"; color: "#666"; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 50 }
                Text { text: "DURATION"; color: "#666"; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 70 }
                Text { text: "STATUS"; color: "#666"; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
            }
        }

        // ── Log list ──
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: []
            spacing: 1

            // Empty state
            Text {
                anchors.centerIn: parent
                text: "No logs yet. Complete a session to see data."
                color: "#444466"
                font.pixelSize: 13
                visible: listView.count === 0
            }

            delegate: Rectangle {
                width: listView.width
                height: 30
                color: {
                    var base = index % 2 === 0 ? Qt.rgba(1,1,1, 0.02) : Qt.rgba(0,0,0, 0.1)
                    return logHover.containsMouse ? Qt.rgba(0.3, 0.3, 0.6, 0.15) : base
                }
                radius: 2

                Behavior on color { ColorAnimation { duration: 80 } }

                MouseArea {
                    id: logHover
                    anchors.fill: parent
                    hoverEnabled: true
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 0

                    // ID
                    Text {
                        text: modelData.id
                        color: "#555577"
                        font.pixelSize: 12
                        font.family: "monospace"
                        Layout.preferredWidth: 40
                    }

                    // Transition
                    Text {
                        text: modelData.from_state + " → " + modelData.to_state
                        color: "#c0c0e0"
                        font.pixelSize: 12
                        Layout.preferredWidth: 180
                        elide: Text.ElideRight
                    }

                    // Started at
                    Text {
                        text: modelData.started_at
                        color: "#8888aa"
                        font.pixelSize: 11
                        font.family: "monospace"
                        Layout.preferredWidth: 180
                        elide: Text.ElideRight
                    }

                    // Cycle
                    Text {
                        text: modelData.cycle
                        color: "#a5b4fc"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.preferredWidth: 50
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Duration
                    Text {
                        text: modelData.duration_seconds + "s"
                        color: "#e0e0e0"
                        font.pixelSize: 12
                        font.family: "monospace"
                        Layout.preferredWidth: 70
                    }

                    // Status badge
                    Rectangle {
                        implicitWidth: statusLabel.implicitWidth + 12
                        implicitHeight: 18
                        radius: 9
                        color: modelData.completed == 1
                            ? Qt.rgba(0.09, 0.64, 0.37, 0.2)
                            : Qt.rgba(0.86, 0.15, 0.15, 0.2)
                        Layout.fillWidth: true

                        Text {
                            id: statusLabel
                            anchors.centerIn: parent
                            text: modelData.completed == 1 ? "✓ done" : "✗ skip"
                            color: modelData.completed == 1 ? "#4ade80" : "#fca5a5"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
            }
        }

        // ── Footer ──
        Rectangle {
            Layout.fillWidth: true
            height: 24
            color: Qt.rgba(1, 1, 1, 0.02)
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Text {
                    text: listView.count + " entries"
                    color: "#555577"
                    font.pixelSize: 11
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: timerBackend ? timerBackend.databasePath() : ""
                    color: "#444466"
                    font.pixelSize: 10
                    font.family: "monospace"
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: 400
                }
            }
        }
    }

    // ── Confirmation popup ──
    Popup {
        id: confirmClearDialog
        modal: true
        anchors.centerIn: parent
        width: 360
        height: confirmContent.implicitHeight + 40
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#1a1a30"
            radius: 14
            border.color: Qt.rgba(0.86, 0.15, 0.15, 0.4)
            border.width: 1
        }

        contentItem: ColumnLayout {
            id: confirmContent
            spacing: 14

            Text {
                text: "⚠  Delete all records?"
                color: "#fca5a5"
                font.pixelSize: 17
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: "This action cannot be undone."
                color: "#999"
                font.pixelSize: 13
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Item { Layout.fillWidth: true }

                Button {
                    text: "Cancel"
                    implicitWidth: 90; implicitHeight: 34
                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(1,1,1,0.12) : Qt.rgba(1,1,1,0.06)
                        radius: 8
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    contentItem: Text {
                        text: parent.text; color: "#ccc"; font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: confirmClearDialog.close()
                }

                Button {
                    text: "Delete All"
                    implicitWidth: 110; implicitHeight: 34
                    background: Rectangle {
                        color: parent.hovered ? "#ef4444" : "#dc2626"
                        radius: 8
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    contentItem: Text {
                        text: parent.text; color: "#ffffff"; font.pixelSize: 13; font.bold: true
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        timerBackend.clearHistory()
                        reload()
                        confirmClearDialog.close()
                        clearNotification.open()
                    }
                }
            }
        }
    }

    // ── Success toast ──
    Popup {
        id: clearNotification
        x: (parent.width - width) / 2
        y: parent.height - height - 20
        width: 240
        height: 40
        modal: false
        closePolicy: Popup.CloseOnPressOutside

        background: Rectangle {
            color: Qt.rgba(0.09, 0.64, 0.37, 0.9)
            radius: 8
        }

        contentItem: Text {
            text: "✓  History cleared"
            color: "#ffffff"
            font.pixelSize: 13
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Timer {
            running: clearNotification.visible
            interval: 2000
            onTriggered: clearNotification.close()
        }
    }

    FileDialog {
        id: fileDialog
        title: "Export CSV"
        nameFilters: ["CSV files (*.csv)"]
        onAccepted: {
            if (fileUrl) {
                timerBackend.exportHistoryCsv(fileUrl)
            }
        }
    }

    function reload() {
        var data = timerBackend.recentSessionRecords(500)
        listView.model = data
    }

    Component.onCompleted: reload()
}
