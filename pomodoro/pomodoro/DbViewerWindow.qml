import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.15

Window {
    id: dbWin
    property var timerBackend

    visible: false
    width: 780
    height: 580
    title: "Session Records"
    flags: Qt.Window
    color: "#1C1B1F"

    // MD3 tokens
    readonly property color md3Surface: "#1C1B1F"
    readonly property color md3SurfaceContainer: "#211F26"
    readonly property color md3SurfaceContainerHigh: "#2B2930"
    readonly property color md3OnSurface: "#E6E1E5"
    readonly property color md3OnSurfaceVariant: "#CAC4D0"
    readonly property color md3Primary: "#D0BCFF"
    readonly property color md3PrimaryContainer: "#4F378B"
    readonly property color md3Outline: "#938F99"
    readonly property color md3OutlineVariant: "#49454F"
    readonly property color md3Error: "#F2B8B5"
    readonly property color md3ErrorContainer: "#8C1D18"

    property int currentTab: 0 // 0 = Sessions, 1 = Events

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        // ── Header + Tab bar ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "📋 Logs"
                font.pixelSize: 20
                font.bold: true
                color: md3OnSurface
            }

            // Tab pills
            RowLayout {
                spacing: 4

                Repeater {
                    model: ["Sessions", "Events"]
                    Button {
                        required property int index
                        required property string modelData
                        implicitHeight: 28
                        background: Rectangle {
                            color: currentTab === index ? md3PrimaryContainer : (parent.hovered ? md3SurfaceContainerHigh : "transparent")
                            radius: 14
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        contentItem: Text {
                            text: modelData
                            color: currentTab === index ? md3Primary : md3OnSurfaceVariant
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            leftPadding: 14; rightPadding: 14
                        }
                        onClicked: { currentTab = index; reload() }
                    }
                }
            }

            // Count badge
            Rectangle {
                implicitWidth: countText.implicitWidth + 16
                implicitHeight: 22
                radius: 11
                color: md3PrimaryContainer

                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: currentTab === 0 ? sessionListView.count + "" : eventListView.count + ""
                    color: md3Primary
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            Item { Layout.fillWidth: true }

            // Reload
            Button {
                implicitWidth: 36; implicitHeight: 32
                background: Rectangle {
                    color: parent.hovered ? md3SurfaceContainerHigh : "transparent"
                    radius: 6
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                contentItem: Text {
                    text: "↻"; color: md3Primary; font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                ToolTip.visible: hovered; ToolTip.text: "Reload"
                onClicked: reload()
            }

            // Clear
            Button {
                implicitWidth: 80; implicitHeight: 32
                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(0.95, 0.29, 0.27, 0.3) : Qt.rgba(0.95, 0.29, 0.27, 0.1)
                    radius: 6
                    border.color: Qt.rgba(0.95, 0.29, 0.27, 0.3)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                contentItem: Text {
                    text: "🗑 Clear"; color: md3Error; font.pixelSize: 12; font.bold: true
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: confirmClearDialog.open()
            }

            // Export
            Button {
                implicitWidth: 90; implicitHeight: 32
                visible: currentTab === 0
                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(0.09, 0.64, 0.37, 0.3) : Qt.rgba(0.09, 0.64, 0.37, 0.1)
                    radius: 6
                    border.color: Qt.rgba(0.09, 0.64, 0.37, 0.3)
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
                    color: parent.hovered ? md3SurfaceContainerHigh : "transparent"
                    radius: 6
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                contentItem: Text {
                    text: "✕"; color: md3Outline; font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: dbWin.close()
            }
        }

        // ══════════════════════════════════════════
        // TAB 0: Sessions
        // ══════════════════════════════════════════
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: currentTab === 0

            ColumnLayout {
                anchors.fill: parent
                spacing: 4

                // Column headers
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    color: md3SurfaceContainer
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10; anchors.rightMargin: 10
                        spacing: 0

                        Text { text: "#"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 40 }
                        Text { text: "TRANSITION"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 180 }
                        Text { text: "STARTED"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 180 }
                        Text { text: "CYCLE"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 50 }
                        Text { text: "DURATION"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 70 }
                        Text { text: "STATUS"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                    }
                }

                ListView {
                    id: sessionListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: []
                    spacing: 1

                    Text {
                        anchors.centerIn: parent
                        text: "No session logs yet."
                        color: md3OutlineVariant
                        font.pixelSize: 13
                        visible: sessionListView.count === 0
                    }

                    delegate: Rectangle {
                        width: sessionListView.width
                        height: 30
                        color: {
                            var base = index % 2 === 0 ? md3SurfaceContainer : md3Surface
                            return sHover.containsMouse ? md3SurfaceContainerHigh : base
                        }
                        radius: 2
                        Behavior on color { ColorAnimation { duration: 80 } }

                        MouseArea { id: sHover; anchors.fill: parent; hoverEnabled: true }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10; anchors.rightMargin: 10
                            spacing: 0

                            Text { text: modelData.id; color: md3OutlineVariant; font.pixelSize: 12; font.family: "monospace"; Layout.preferredWidth: 40 }
                            Text { text: modelData.from_state + " → " + modelData.to_state; color: md3OnSurface; font.pixelSize: 12; Layout.preferredWidth: 180; elide: Text.ElideRight }
                            Text { text: modelData.started_at; color: md3OnSurfaceVariant; font.pixelSize: 11; font.family: "monospace"; Layout.preferredWidth: 180; elide: Text.ElideRight }
                            Text { text: modelData.cycle; color: md3Primary; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignHCenter }
                            Text { text: modelData.duration_seconds + "s"; color: md3OnSurface; font.pixelSize: 12; font.family: "monospace"; Layout.preferredWidth: 70 }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                implicitWidth: sLabel.implicitWidth + 16
                                implicitHeight: 18
                                radius: 9
                                color: modelData.completed == 1 ? Qt.rgba(0.09, 0.64, 0.37, 0.2) : Qt.rgba(0.95, 0.29, 0.27, 0.2)

                                Text {
                                    id: sLabel
                                    anchors.centerIn: parent
                                    text: modelData.completed == 1 ? "✓ done" : "✗ skip"
                                    color: modelData.completed == 1 ? "#4ade80" : md3Error
                                    font.pixelSize: 10; font.bold: true
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar { active: true; policy: ScrollBar.AsNeeded }
                }
            }
        }

        // ══════════════════════════════════════════
        // TAB 1: Events
        // ══════════════════════════════════════════
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: currentTab === 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 4

                // Column headers
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    color: md3SurfaceContainer
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10; anchors.rightMargin: 10
                        spacing: 0

                        Text { text: "#"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 40 }
                        Text { text: "ACTION"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 120 }
                        Text { text: "DETAIL"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 240 }
                        Text { text: "CYCLE"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.preferredWidth: 50 }
                        Text { text: "TIMESTAMP"; color: md3Outline; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                    }
                }

                ListView {
                    id: eventListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: []
                    spacing: 1

                    Text {
                        anchors.centerIn: parent
                        text: "No events yet. Interact with the timer."
                        color: md3OutlineVariant
                        font.pixelSize: 13
                        visible: eventListView.count === 0
                    }

                    delegate: Rectangle {
                        width: eventListView.width
                        height: 30
                        color: {
                            var base = index % 2 === 0 ? md3SurfaceContainer : md3Surface
                            return eHover.containsMouse ? md3SurfaceContainerHigh : base
                        }
                        radius: 2
                        Behavior on color { ColorAnimation { duration: 80 } }

                        MouseArea { id: eHover; anchors.fill: parent; hoverEnabled: true }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10; anchors.rightMargin: 10
                            spacing: 0

                            Text { text: modelData.id; color: md3OutlineVariant; font.pixelSize: 12; font.family: "monospace"; Layout.preferredWidth: 40 }

                            // Action badge
                            Rectangle {
                                implicitWidth: actionLabel.implicitWidth + 12
                                implicitHeight: 18
                                radius: 9
                                Layout.preferredWidth: 120
                                color: {
                                    var a = modelData.action
                                    if (a === "start" || a === "resume") return Qt.rgba(0.09, 0.64, 0.37, 0.2)
                                    if (a === "pause") return Qt.rgba(0.95, 0.73, 0.13, 0.2)
                                    if (a === "reset" || a === "skip") return Qt.rgba(0.95, 0.29, 0.27, 0.2)
                                    if (a === "transition") return Qt.rgba(0.35, 0.42, 0.76, 0.2)
                                    if (a === "config_save") return Qt.rgba(0.49, 0.46, 0.90, 0.2)
                                    return Qt.rgba(1,1,1,0.05)
                                }

                                Text {
                                    id: actionLabel
                                    anchors.centerIn: parent
                                    text: modelData.action
                                    font.pixelSize: 10; font.bold: true
                                    color: {
                                        var a = modelData.action
                                        if (a === "start" || a === "resume") return "#4ade80"
                                        if (a === "pause") return "#fde047"
                                        if (a === "reset" || a === "skip") return md3Error
                                        if (a === "transition") return "#818cf8"
                                        if (a === "config_save") return md3Primary
                                        return md3OnSurfaceVariant
                                    }
                                }
                            }

                            Text { text: modelData.detail || ""; color: md3OnSurface; font.pixelSize: 12; Layout.preferredWidth: 240; elide: Text.ElideRight }
                            Text { text: modelData.cycle; color: md3Primary; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignHCenter }
                            Text { text: modelData.timestamp; color: md3OnSurfaceVariant; font.pixelSize: 11; font.family: "monospace"; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                    }

                    ScrollBar.vertical: ScrollBar { active: true; policy: ScrollBar.AsNeeded }
                }
            }
        }

        // ── Footer ──
        Rectangle {
            Layout.fillWidth: true
            height: 24
            color: md3SurfaceContainer
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10; anchors.rightMargin: 10

                Text {
                    text: (currentTab === 0 ? sessionListView.count : eventListView.count) + " entries"
                    color: md3OutlineVariant
                    font.pixelSize: 11
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: timerBackend ? timerBackend.databasePath() : ""
                    color: md3Outline
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
            color: md3SurfaceContainer
            radius: 14
            border.color: Qt.rgba(0.95, 0.29, 0.27, 0.3)
            border.width: 1
        }

        contentItem: ColumnLayout {
            id: confirmContent
            spacing: 14

            Text {
                text: "⚠  Delete all records?"
                color: md3Error
                font.pixelSize: 17; font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: currentTab === 0 ? "All session records will be deleted." : "All event logs will be deleted."
                color: md3OnSurfaceVariant
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
                        color: parent.hovered ? md3SurfaceContainerHigh : "transparent"
                        radius: 20
                        border.color: md3Outline; border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    contentItem: Text {
                        text: parent.text; color: md3Primary; font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: confirmClearDialog.close()
                }

                Button {
                    text: "Delete All"
                    implicitWidth: 110; implicitHeight: 34
                    background: Rectangle {
                        color: parent.hovered ? "#ef4444" : "#dc2626"
                        radius: 20
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    contentItem: Text {
                        text: parent.text; color: "#ffffff"; font.pixelSize: 13; font.bold: true
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (currentTab === 0) {
                            timerBackend.clearHistory()
                        } else {
                            timerBackend.clearEventLogs()
                        }
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
        width: 240; height: 40
        modal: false
        closePolicy: Popup.CloseOnPressOutside

        background: Rectangle {
            color: Qt.rgba(0.09, 0.64, 0.37, 0.9)
            radius: 8
        }

        contentItem: Text {
            text: "✓  Records cleared"
            color: "#ffffff"; font.pixelSize: 13; font.bold: true
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
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
        sessionListView.model = timerBackend.recentSessionRecords(500)
        eventListView.model = timerBackend.recentEventLogs(500)
    }

    Component.onCompleted: reload()
}
