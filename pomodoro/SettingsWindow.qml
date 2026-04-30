import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: settingsWin
    property var timerBackend
    visible: false
    width: 520
    height: 420
    title: "Settings"
    flags: Qt.Window
    opacity: 0.95

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Settings"; font.pixelSize: 20; color: "#ffffff" }
            Item { Layout.fillWidth: true }
            Button { text: "Close"; onClicked: settingsWin.close() }
        }

        // Timers section
        GroupBox { title: "Timers"; Layout.fillWidth: true;
            ColumnLayout { spacing: 8; anchors.margins: 8;
                RowLayout { spacing: 8; Layout.fillWidth: true;
                    Text { text: "Focus (s):"; color: "#cccccc" }
                    SpinBox { id: sFocus; from:1; to:3600; stepSize:60; value: timerBackend.focusDurationSeconds }
                    Text { text: "Short (s):"; color: "#cccccc" }
                    SpinBox { id: sShort; from:1; to:3600; stepSize:60; value: timerBackend.shortBreakDurationSeconds }
                }
                RowLayout { spacing: 8; Layout.fillWidth: true;
                    Text { text: "Long (s):"; color: "#cccccc" }
                    SpinBox { id: sLong; from:1; to:3600; stepSize:60; value: timerBackend.longBreakDurationSeconds }
                }
            }
        }

        // Assets section
        GroupBox { title: "Assets"; Layout.fillWidth: true;
            ColumnLayout { spacing: 8; anchors.margins: 8;
                RowLayout { spacing: 8;
                    Button { text: "Choose Focus GIF"; onClicked: fdFocus.open() }
                    Button { text: "Choose Short GIF"; onClicked: fdShort.open() }
                    Button { text: "Choose Long GIF"; onClicked: fdLong.open() }
                }
                RowLayout { spacing: 8; Layout.fillWidth: true;
                    Text { text: "Focus: " + timerBackend.focusGifSource; elide: Text.ElideRight; color: "#aaaaaa" }
                }
            }
        }

        // Notifications
        GroupBox { title: "Notifications"; Layout.fillWidth: true;
            RowLayout { anchors.margins: 8; spacing: 8;
                Text { text: "Sound:" }
                Switch { id: sSound; checked: timerBackend.notificationSoundEnabled }
            }
        }

        // Actions
        RowLayout { Layout.fillWidth: true; spacing: 8; anchors.margins: 8;
            Button {
                text: "Save"
                onClicked: {
                    timerBackend.setFocusDurationSeconds(sFocus.value)
                    timerBackend.setShortBreakDurationSeconds(sShort.value)
                    timerBackend.setLongBreakDurationSeconds(sLong.value)
                    timerBackend.notificationSoundEnabled = sSound.checked
                    timerBackend.saveConfiguration()
                    settingsWin.close()
                }
            }
            Button { text: "Cancel"; onClicked: settingsWin.close() }
        }

    }

    FileDialog { id: fdFocus; title: "Select Focus GIF"; nameFilters: ["GIF files (*.gif)"]; onAccepted: timerBackend.setAssetSources(fileUrl, timerBackend.shortBreakGifSource, timerBackend.longBreakGifSource, timerBackend.startGifSource, timerBackend.pauseGifSource) }
    FileDialog { id: fdShort; title: "Select Short Break GIF"; nameFilters: ["GIF files (*.gif)"]; onAccepted: timerBackend.setAssetSources(timerBackend.focusGifSource, fileUrl, timerBackend.longBreakGifSource, timerBackend.startGifSource, timerBackend.pauseGifSource) }
    FileDialog { id: fdLong; title: "Select Long Break GIF"; nameFilters: ["GIF files (*.gif)"]; onAccepted: timerBackend.setAssetSources(timerBackend.focusGifSource, timerBackend.shortBreakGifSource, fileUrl, timerBackend.startGifSource, timerBackend.pauseGifSource) }
}
