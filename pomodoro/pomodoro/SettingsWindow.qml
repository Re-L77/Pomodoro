import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.15

Window {
    id: settingsWin
    property var timerBackend
    visible: false
    width: 560
    height: 640
    minimumHeight: 500
    minimumWidth: 400
    title: "Settings"
    flags: Qt.Window
    color: "#1C1B1F"
    opacity: timerBackend && timerBackend.transparencyEnabled ? timerBackend.windowOpacity : 1.0

    // ── MD3 Color Tokens ──
    readonly property color md3Surface: "#1C1B1F"
    readonly property color md3SurfaceContainer: "#211F26"
    readonly property color md3SurfaceContainerHigh: "#2B2930"
    readonly property color md3SurfaceContainerHighest: "#36343B"
    readonly property color md3OnSurface: "#E6E1E5"
    readonly property color md3OnSurfaceVariant: "#CAC4D0"
    readonly property color md3Primary: "#D0BCFF"
    readonly property color md3PrimaryContainer: "#4F378B"
    readonly property color md3OnPrimaryContainer: "#EADDFF"
    readonly property color md3SecondaryContainer: "#4A4458"
    readonly property color md3Outline: "#938F99"
    readonly property color md3OutlineVariant: "#49454F"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 0

        // ── Fixed Header ──
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 12
            Text {
                text: "Settings"
                font.pixelSize: 24
                color: md3OnSurface
            }
            Item { Layout.fillWidth: true }
            Button {
                implicitWidth: 40; implicitHeight: 40
                background: Rectangle {
                    color: parent.hovered ? md3SurfaceContainerHighest : "transparent"
                    radius: 20
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                contentItem: Text {
                    text: "✕"; color: md3OnSurfaceVariant; font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: settingsWin.close()
            }
        }

        // ── Scrollable cards ──
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: cardsColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
            }

            ColumnLayout {
                id: cardsColumn
                width: parent.width
                spacing: 10

                // ── Timers card ──
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: timersCol.implicitHeight + 32
                    radius: 12
                    color: md3SurfaceContainer
                    border.color: md3OutlineVariant
                    border.width: 1

                    ColumnLayout {
                        id: timersCol
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text { text: "Timers"; color: md3Primary; font.pixelSize: 14; font.bold: true }

                        GridLayout {
                            columns: 4
                            columnSpacing: 14
                            rowSpacing: 10
                            Layout.fillWidth: true

                            Text { text: "Focus (s):"; color: md3OnSurfaceVariant }
                            SpinBox { id: sFocus; from: 1; to: 3600; stepSize: 60; value: timerBackend ? timerBackend.focusDurationSeconds : 5 }
                            Text { text: "Short (s):"; color: md3OnSurfaceVariant }
                            SpinBox { id: sShort; from: 1; to: 3600; stepSize: 60; value: timerBackend ? timerBackend.shortBreakDurationSeconds : 5 }

                            Text { text: "Long (s):"; color: md3OnSurfaceVariant }
                            SpinBox { id: sLong; from: 1; to: 3600; stepSize: 60; value: timerBackend ? timerBackend.longBreakDurationSeconds : 10 }
                        }
                    }
                }

                // ── Assets card ──
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: assetsCol.implicitHeight + 32
                    radius: 12
                    color: md3SurfaceContainer
                    border.color: md3OutlineVariant
                    border.width: 1

                    ColumnLayout {
                        id: assetsCol
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text { text: "Assets"; color: md3Primary; font.pixelSize: 14; font.bold: true }

                        RowLayout {
                            spacing: 8
                            Repeater {
                                model: [
                                    { label: "Focus GIF", action: "focus" },
                                    { label: "Short GIF", action: "short" },
                                    { label: "Long GIF", action: "long" }
                                ]
                                Button {
                                    required property var modelData
                                    implicitHeight: 36
                                    background: Rectangle {
                                        color: parent.hovered ? md3PrimaryContainer : md3SecondaryContainer
                                        radius: 20
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                    contentItem: Text {
                                        text: modelData.label; color: md3OnPrimaryContainer
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                        leftPadding: 14; rightPadding: 14
                                    }
                                    onClicked: {
                                        if (modelData.action === "focus") fdFocus.open()
                                        else if (modelData.action === "short") fdShort.open()
                                        else fdLong.open()
                                    }
                                }
                            }
                        }

                        Text {
                            text: "Focus: " + (timerBackend ? timerBackend.focusGifSource : "")
                            elide: Text.ElideRight
                            color: md3Outline
                            font.pixelSize: 11
                            Layout.fillWidth: true
                        }
                    }
                }

                // ── Notifications card ──
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: notifCol.implicitHeight + 32
                    radius: 12
                    color: md3SurfaceContainer
                    border.color: md3OutlineVariant
                    border.width: 1

                    ColumnLayout {
                        id: notifCol
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text { text: "Notifications"; color: md3Primary; font.pixelSize: 14; font.bold: true }

                        RowLayout {
                            spacing: 12; Layout.fillWidth: true
                            Text { text: "Sound"; color: md3OnSurface }
                            Item { Layout.fillWidth: true }
                            Switch { id: sSound; checked: timerBackend ? timerBackend.notificationSoundEnabled : true }
                        }
                    }
                }

                // ── Appearance card ──
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: appearCol.implicitHeight + 32
                    radius: 12
                    color: md3SurfaceContainer
                    border.color: md3OutlineVariant
                    border.width: 1

                    ColumnLayout {
                        id: appearCol
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text { text: "Appearance"; color: md3Primary; font.pixelSize: 14; font.bold: true }

                        RowLayout {
                            spacing: 12; Layout.fillWidth: true
                            Text { text: "Enable transparency"; color: md3OnSurface }
                            Item { Layout.fillWidth: true }
                            Switch { id: transparencyEnabledSwitch; checked: timerBackend ? timerBackend.transparencyEnabled : false }
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: md3OutlineVariant }

                        RowLayout {
                            spacing: 12; Layout.fillWidth: true
                            Text { text: "Opacity"; color: md3OnSurface }
                            Slider {
                                id: transparencySlider
                                from: 0.3; to: 1.0
                                value: timerBackend ? timerBackend.windowOpacity : 1.0
                                stepSize: 0.01
                                enabled: transparencyEnabledSwitch.checked
                                Layout.fillWidth: true
                            }
                            Text {
                                text: Math.round(transparencySlider.value * 100) + "%"
                                color: md3OnSurfaceVariant
                                font.pixelSize: 13
                                Layout.preferredWidth: 40
                            }
                        }
                    }
                }
            }
        }

        // ── Fixed Actions (always visible at bottom) ──
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 14
            spacing: 12

            Item { Layout.fillWidth: true }

            // MD3 Outlined button
            Button {
                text: "Cancel"
                implicitWidth: 100; implicitHeight: 40
                background: Rectangle {
                    color: parent.hovered ? md3SurfaceContainerHigh : "transparent"
                    radius: 20
                    border.color: md3Outline
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                contentItem: Text {
                    text: parent.text; color: md3Primary; font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: settingsWin.close()
            }

            // MD3 Filled button
            Button {
                id: saveBtn
                text: "Save"
                implicitWidth: 120; implicitHeight: 40
                background: Rectangle {
                    color: saveBtn.hovered ? Qt.lighter(md3Primary, 1.1) : md3Primary
                    radius: 20
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                contentItem: Text {
                    text: parent.text; color: "#381E72"; font.pixelSize: 14; font.bold: true
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    timerBackend.setFocusDurationSeconds(sFocus.value)
                    timerBackend.setShortBreakDurationSeconds(sShort.value)
                    timerBackend.setLongBreakDurationSeconds(sLong.value)
                    timerBackend.transparencyEnabled = transparencyEnabledSwitch.checked
                    timerBackend.notificationSoundEnabled = sSound.checked
                    timerBackend.windowOpacity = transparencySlider.value
                    timerBackend.saveConfiguration()
                    saveNotification.open()
                }
            }
        }
    }

    // ── Save notification (MD3 Snackbar) ──
    Popup {
        id: saveNotification
        x: (parent.width - width) / 2
        y: parent.height - height - 70
        width: Math.min(parent.width - 48, 400)
        height: snackContent.implicitHeight + 28
        modal: false
        closePolicy: Popup.CloseOnPressOutside

        background: Rectangle {
            color: md3SurfaceContainerHighest
            radius: 8
            border.color: md3OutlineVariant
            border.width: 1
        }

        contentItem: RowLayout {
            id: snackContent
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "✓  Settings saved"
                    color: md3Primary
                    font.pixelSize: 14
                    font.bold: true
                }
                Text {
                    text: "Some changes will apply on next restart."
                    color: md3OnSurfaceVariant
                    font.pixelSize: 12
                }
            }

            Button {
                text: "OK"
                implicitWidth: 50; implicitHeight: 32
                background: Rectangle { color: "transparent" }
                contentItem: Text {
                    text: parent.text; color: md3Primary; font.pixelSize: 13; font.bold: true
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    saveNotification.close()
                    settingsWin.close()
                }
            }
        }

        Timer {
            running: saveNotification.visible
            interval: 4000
            onTriggered: {
                saveNotification.close()
                settingsWin.close()
            }
        }
    }

    FileDialog { id: fdFocus; title: "Select Focus GIF"; nameFilters: ["GIF files (*.gif)"]; onAccepted: timerBackend.setAssetSources(fileUrl, timerBackend.shortBreakGifSource, timerBackend.longBreakGifSource, timerBackend.startGifSource, timerBackend.pauseGifSource) }
    FileDialog { id: fdShort; title: "Select Short Break GIF"; nameFilters: ["GIF files (*.gif)"]; onAccepted: timerBackend.setAssetSources(timerBackend.focusGifSource, fileUrl, timerBackend.longBreakGifSource, timerBackend.startGifSource, timerBackend.pauseGifSource) }
    FileDialog { id: fdLong; title: "Select Long Break GIF"; nameFilters: ["GIF files (*.gif)"]; onAccepted: timerBackend.setAssetSources(timerBackend.focusGifSource, timerBackend.shortBreakGifSource, fileUrl, timerBackend.startGifSource, timerBackend.pauseGifSource) }
}
