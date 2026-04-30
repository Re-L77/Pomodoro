import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.15

Window {
    id: settingsWin
    property var timerBackend
    visible: false
    width: 520
    height: 420
    title: "Settings"
    flags: Qt.Window
    color: "transparent"

    Rectangle {
        id: settingsBackground
        anchors.fill: parent
        color: "#252540"
        radius: 12
        opacity: timerBackend.windowOpacity

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Settings"; font.pixelSize: 22; font.bold: true; color: "#ffffff" }
            Item { Layout.fillWidth: true }
            Button { 
                text: "Close"
                background: Rectangle { color: "#D5B8E8"; radius: 8; border.color: "#C5A8D8"; border.width: 1 }
                contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true }
                onClicked: settingsWin.close()
            }
        }

        // Timers section
        GroupBox { 
            title: "Timers"
            Layout.fillWidth: true
            background: Rectangle { color: "#2a2a3e"; radius: 12; border.color: "#D5B8E8"; border.width: 1; opacity: 0.8 }
            label: Text { text: parent.title; color: "#D5B8E8"; font.bold: true; font.pixelSize: 13 }
            ColumnLayout { spacing: 8; anchors.margins: 12;
                RowLayout { spacing: 8; Layout.fillWidth: true;
                    Text { text: "Focus (s):"; color: "#ffffff"; font.bold: true }
                    SpinBox { id: sFocus; from:1; to:3600; stepSize:60; value: timerBackend.focusDurationSeconds }
                    Text { text: "Short (s):"; color: "#ffffff"; font.bold: true }
                    SpinBox { id: sShort; from:1; to:3600; stepSize:60; value: timerBackend.shortBreakDurationSeconds }
                }
                RowLayout { spacing: 8; Layout.fillWidth: true;
                    Text { text: "Long (s):"; color: "#ffffff"; font.bold: true }
                    SpinBox { id: sLong; from:1; to:3600; stepSize:60; value: timerBackend.longBreakDurationSeconds }
                }
            }
        }

        // Assets section
        GroupBox { 
            title: "Assets"
            Layout.fillWidth: true
            background: Rectangle { color: "#2a2a3e"; radius: 12; border.color: "#D5B8E8"; border.width: 1; opacity: 0.8 }
            label: Text { text: parent.title; color: "#D5B8E8"; font.bold: true; font.pixelSize: 13 }
            ColumnLayout { spacing: 8; anchors.margins: 12;
                RowLayout { spacing: 8;
                    Button { 
                        text: "Choose Focus GIF"
                        background: Rectangle { color: "#D5E8F7"; radius: 8; border.color: "#B8D5E8"; border.width: 1 }
                        contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; font.bold: true; font.pixelSize: 11 }
                        onClicked: fdFocus.open()
                    }
                    Button { 
                        text: "Choose Short GIF"
                        background: Rectangle { color: "#D5E8F7"; radius: 8; border.color: "#B8D5E8"; border.width: 1 }
                        contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; font.bold: true; font.pixelSize: 11 }
                        onClicked: fdShort.open()
                    }
                    Button { 
                        text: "Choose Long GIF"
                        background: Rectangle { color: "#D5E8F7"; radius: 8; border.color: "#B8D5E8"; border.width: 1 }
                        contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; font.bold: true; font.pixelSize: 11 }
                        onClicked: fdLong.open()
                    }
                }
                RowLayout { spacing: 8; Layout.fillWidth: true;
                    Text { text: "Focus: " + timerBackend.focusGifSource; elide: Text.ElideRight; color: "#cccccc" }
                }
            }
        }

        // Notifications
        GroupBox { 
            title: "Notifications"
            Layout.fillWidth: true
            background: Rectangle { color: "#2a2a3e"; radius: 12; border.color: "#D5B8E8"; border.width: 1; opacity: 0.8 }
            label: Text { text: parent.title; color: "#D5B8E8"; font.bold: true; font.pixelSize: 13 }
            RowLayout { anchors.margins: 12; spacing: 8;
                Text { text: "Sound:"; color: "#ffffff"; font.bold: true }
                Switch { id: sSound; checked: timerBackend.notificationSoundEnabled }
            }
        }

        // Transparency
        GroupBox { 
            title: "Appearance"
            Layout.fillWidth: true
            background: Rectangle { color: "#2a2a3e"; radius: 12; border.color: "#D5B8E8"; border.width: 1; opacity: 0.8 }
            label: Text { text: parent.title; color: "#D5B8E8"; font.bold: true; font.pixelSize: 13 }
            ColumnLayout { anchors.margins: 12; spacing: 8;
                RowLayout { spacing: 8; Layout.fillWidth: true;
                    Text { text: "Window Transparency:"; color: "#ffffff"; font.bold: true }
                    Slider {
                        id: transparencySlider
                        from: 0.5
                        to: 1.0
                        value: timerBackend.windowOpacity
                        stepSize: 0.01
                        Layout.fillWidth: true
                    }
                    Text { text: Math.round(transparencySlider.value * 100) + "%"; color: "#ffffff"; font.bold: true; width: 40 }
                }
            }
        }

        // Actions
        RowLayout { Layout.fillWidth: true; spacing: 8; anchors.margins: 8;
            Button {
                text: "Save"
                background: Rectangle { color: "#D5B8E8"; radius: 8; border.color: "#E8B8C5"; border.width: 1 }
                contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true }
                onClicked: {
                    timerBackend.setFocusDurationSeconds(sFocus.value)
                    timerBackend.setShortBreakDurationSeconds(sShort.value)
                    timerBackend.setLongBreakDurationSeconds(sLong.value)
                    timerBackend.notificationSoundEnabled = sSound.checked
                    timerBackend.windowOpacity = transparencySlider.value
                    timerBackend.saveConfiguration()
                    settingsWin.close()
                }
            }
            Button { 
                text: "Cancel"
                background: Rectangle { color: "#555566"; radius: 8; border.color: "#666677"; border.width: 1 }
                contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true }
                onClicked: settingsWin.close() 
            }
        }
    }
    }

    FileDialog { id: fdFocus; title: "Select Focus GIF"; nameFilters: ["GIF files (*.gif)"]; onAccepted: timerBackend.setAssetSources(fileUrl, timerBackend.shortBreakGifSource, timerBackend.longBreakGifSource, timerBackend.startGifSource, timerBackend.pauseGifSource) }
    FileDialog { id: fdShort; title: "Select Short Break GIF"; nameFilters: ["GIF files (*.gif)"]; onAccepted: timerBackend.setAssetSources(timerBackend.focusGifSource, fileUrl, timerBackend.longBreakGifSource, timerBackend.startGifSource, timerBackend.pauseGifSource) }
    FileDialog { id: fdLong; title: "Select Long Break GIF"; nameFilters: ["GIF files (*.gif)"]; onAccepted: timerBackend.setAssetSources(timerBackend.focusGifSource, timerBackend.shortBreakGifSource, fileUrl, timerBackend.startGifSource, timerBackend.pauseGifSource) }
}
