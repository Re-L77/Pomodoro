import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Qt.labs.platform 1.1
import pomodoro
Window {
    id: root
    width: 850
    height: 550
    visible: true
    title: "Pomodoro"
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    onClosing: {
        settingsWindow.close()
        dbWindow.close()
        Qt.quit()
    }

    PomodoroTimer {
        id: timerBackend
    }

    // instantiate separate windows (non-modal)
    SettingsWindow { id: settingsWindow; timerBackend: timerBackend }
    DbViewerWindow { id: dbWindow; timerBackend: timerBackend }

    // El contenedor principal (Pane) que define el fondo de toda la aplicación
    Pane {
        id: mainPane
        anchors.fill: parent
        padding: 0

        background: Rectangle {
            id: mainBackground
            color: "#1a1a2e"
            radius: 12
            opacity: 0.88
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ==========================================
            // 1. BARRA SUPERIOR (ToolBar conceptual)
            // ==========================================
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 45

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    onPressed: root.startSystemMove()
                }

                Text {
                    text: "Pomodoro"
                    color: "#ffffff"
                    font.pixelSize: 18
                    anchors.centerIn: parent
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10
                    spacing: 5

                    Button {
                        text: "⚙"
                        width: 35; height: 35
                        background: Rectangle { color: "transparent" }
                        contentItem: Text {
                            text: parent.text; color: "#ffffff"; font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: settingsWindow.show()
                    }
                    Button {
                        text: "DB"
                        width: 40; height: 35
                        background: Rectangle { color: "transparent" }
                        contentItem: Text { text: parent.text; color: "#ffffff"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: dbWindow.show()
                    }

                    Button {
                        text: "−"
                        width: 35; height: 35
                        background: Rectangle { color: "transparent" }
                        contentItem: Text {
                            text: parent.text; color: "#ffffff"; font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: root.showMinimized()
                    }
                    Button {
                        text: "✕"
                        width: 35; height: 35
                        background: Rectangle { color: "transparent" }
                        contentItem: Text {
                            text: parent.text; color: "#ffffff"; font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: Qt.quit()
                    }
                }

            }

            // ==========================================
            // 2. CUERPO PRINCIPAL (Dos columnas)
            // ==========================================
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 26
                spacing: 40

                // --- COLUMNA IZQUIERDA ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 420
                    Layout.minimumWidth: 320
                    Layout.fillHeight: true
                    spacing: 0

                    // Espacio para la imagen
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        AnimatedImage {
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            anchors.margins: 12
                            source: timerBackend.currentGifSource
                            fillMode: Image.PreserveAspectFit
                            playing: true
                        }
                    }
                }

                // --- COLUMNA DERECHA ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 380
                    Layout.minimumWidth: 320
                    Layout.fillHeight: true
                    spacing: 18

                    // Anillo de progreso y tiempo
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // El fondo del anillo (gris oscuro)
                        Shape {
                            id: ringShape
                            anchors.centerIn: parent
                            width: Math.min(parent.width, parent.height) * 0.86
                            height: width
                            layer.enabled: true
                            layer.samples: 4 // Antialiasing

                            ShapePath {
                                fillColor: "transparent"
                                strokeColor: "#333544"
                                strokeWidth: 14
                                capStyle: ShapePath.RoundCap
                                PathAngleArc {
                                    centerX: ringShape.width / 2
                                    centerY: ringShape.height / 2
                                    radiusX: ringShape.width * 0.44
                                    radiusY: ringShape.height * 0.44
                                    startAngle: 0; sweepAngle: 360
                                }
                            }

                            // El anillo de progreso (azul claro)
                            ShapePath {
                                fillColor: "transparent"
                                strokeColor: "#a6c0ff"
                                strokeWidth: 14
                                capStyle: ShapePath.RoundCap
                                PathAngleArc {
                                    centerX: ringShape.width / 2
                                    centerY: ringShape.height / 2
                                    radiusX: ringShape.width * 0.44
                                    radiusY: ringShape.height * 0.44
                                    startAngle: -90
                                    sweepAngle: timerBackend.sweepAngle
                                    Behavior on sweepAngle {
                                        NumberAnimation {
                                            duration: 500 // Medio segundo de transición
                                            easing.type: Easing.OutQuint // Curva de desaceleración suave
                                        }
                                    }
                                }

                            }
                        }

                        // Texto central
                        Column {
                            anchors.centerIn: parent
                            spacing: 2
                            Text {
                                text: timerBackend.timeDisplay
                                color: "#ffffff"
                                font.pixelSize: 48
                                font.bold: false
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: timerBackend.statusText
                                color: "#aaaaaa"
                                font.pixelSize: 16
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        // Círculo indicador ("1")
                        Rectangle {
                            width: 48; height: 48
                            radius: 100
                            color: "#222224"
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 16
                            Text {
                                text: timerBackend.currentCycle.toString()
                                color: "#ffffff"
                                font.pixelSize: 16
                                anchors.centerIn: parent
                            }
                        }
                    }

                    // Botones de control
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        spacing: 12

                        Button {
                            text: "✕\nReset"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 68
                            background: Rectangle { color: "#c93c3c"; radius: 12 }
                            contentItem: Text {
                                text: parent.text; color: "white"; font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: timerBackend.resetAll()
                        }

                        Button {
                            text: timerBackend.controlButtonText
                            Layout.fillWidth: true
                            Layout.preferredHeight: 68
                            background: Rectangle { color: "#e4eaf5"; radius: 12 }
                            contentItem: Text {
                                text: parent.text; color: "#2d2d30"; font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: timerBackend.startTimer()
                        }

                        Button {
                            text: "⏭\nSkip"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 68
                            background: Rectangle { color: "#6b7280"; radius: 12 }
                            contentItem: Text {
                                text: parent.text; color: "white"; font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: timerBackend.skipTimer()
                        }
                    }

                    // settings popup (opened by toolbar button)
                    Popup {
                        id: settingsDialog
                        modal: true
                        x: parent.width/2 - width/2
                        y: parent.height/2 - height/2
                        visible: false

                        contentItem: ColumnLayout {
                            width: 520
                            spacing: 10
                            anchors.fill: parent
                            anchors.margins: 12
                            // Title bar
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: "Settings"; color: "#ffffff"; font.pixelSize: 18 }
                                Item { Layout.fillWidth: true }
                                Button { text: "✕"; onClicked: settingsDialog.close() }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                color: "#1a1a1f"
                                radius: 8
                                height: 8
                                opacity: 0.0
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: "Focus (s):"; color: "#cccccc" }
                                SpinBox { id: dlgFocus; from:1; to:3600; value: timerBackend.focusDurationSeconds; stepSize:60 }
                                Text { text: "Short break (s):"; color: "#cccccc" }
                                SpinBox { id: dlgShort; from:1; to:3600; value: timerBackend.shortBreakDurationSeconds; stepSize:60 }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: "Long break (s):"; color: "#cccccc" }
                                SpinBox { id: dlgLong; from:1; to:3600; value: timerBackend.longBreakDurationSeconds; stepSize:60 }
                                Text { text: "Sound:"; color: "#cccccc" }
                                Switch { id: dlgSound; checked: timerBackend.notificationSoundEnabled }
                            }

                            // GIF selectors
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Button { text: "Choose Focus GIF"; onClicked: focusFileDialog.open() }
                                Button { text: "Choose Short GIF"; onClicked: shortFileDialog.open() }
                                Button { text: "Choose Long GIF"; onClicked: longFileDialog.open() }
                            }

                            FileDialog {
                                id: focusFileDialog
                                title: "Select Focus GIF"
                                nameFilters: ["GIF files (*.gif)"]
                                onAccepted: {
                                    timerBackend.setAssetSources(fileUrl, timerBackend.shortBreakGifSource, timerBackend.longBreakGifSource, timerBackend.startGifSource, timerBackend.pauseGifSource)
                                }
                            }

                            FileDialog {
                                id: shortFileDialog
                                title: "Select Short Break GIF"
                                nameFilters: ["GIF files (*.gif)"]
                                onAccepted: {
                                    timerBackend.setAssetSources(timerBackend.focusGifSource, fileUrl, timerBackend.longBreakGifSource, timerBackend.startGifSource, timerBackend.pauseGifSource)
                                }
                            }

                            FileDialog {
                                id: longFileDialog
                                title: "Select Long Break GIF"
                                nameFilters: ["GIF files (*.gif)"]
                                onAccepted: {
                                    timerBackend.setAssetSources(timerBackend.focusGifSource, timerBackend.shortBreakGifSource, fileUrl, timerBackend.startGifSource, timerBackend.pauseGifSource)
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Button {
                                    text: "Save"
                                    background: Rectangle { color: "#7c4dff"; radius: 8 }
                                    onClicked: {
                                        timerBackend.setFocusDurationSeconds(dlgFocus.value);
                                        timerBackend.setShortBreakDurationSeconds(dlgShort.value);
                                        timerBackend.setLongBreakDurationSeconds(dlgLong.value);
                                        timerBackend.notificationSoundEnabled = dlgSound.checked;
                                        timerBackend.saveConfiguration();
                                        settingsDialog.close();
                                    }
                                }
                                Button { text: "Cancel"; onClicked: settingsDialog.close() }
                                Button { text: "View DB"; onClicked: dbDialog.open() }
                                Label { text: "DB: " + timerBackend.databasePath(); color: "#888888" }
                            }
                        }
                    }

                    // DB viewer popup
                    Popup {
                        id: dbDialog
                        modal: true
                        visible: false
                        x: parent.width/2 - width/2
                        y: parent.height/2 - height/2

                        contentItem: ColumnLayout {
                            width: 520
                            spacing: 8
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Database - Recent Sessions"; color: "#ffffff"; font.pixelSize: 16 }
                                Item { Layout.fillWidth: true }
                                Button { text: "✕"; onClicked: dbDialog.close() }
                            }
                            ListView {
                                id: dbList
                                model: timerBackend.recentSessionRecords(50)
                                delegate: Rectangle {
                                    width: dbList.width
                                    height: implicitHeight
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
                    }
                }
            }
        }
    }

}
