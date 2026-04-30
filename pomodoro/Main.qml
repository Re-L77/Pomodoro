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
    flags: Qt.FramelessWindowHint | Qt.Window
    opacity: timerBackend.transparencyEnabled ? timerBackend.windowOpacity : 1.0

    Connections {
        target: root
        function onClosing(close) {
            settingsWindow.close()
            dbWindow.close()
            Qt.quit()
        }
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

                    Repeater {
                        model: [
                            { icon: "⚙", action: "settings", size: 18 },
                            { icon: "DB", action: "db", size: 13 },
                            { icon: "−", action: "minimize", size: 20 },
                            { icon: "✕", action: "close", size: 16 }
                        ]
                        Button {
                            required property var modelData
                            width: 35; height: 35
                            background: Rectangle {
                                color: parent.hovered ? Qt.rgba(1,1,1,0.1) : "transparent"
                                radius: 8
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }
                            contentItem: Text {
                                text: modelData.icon; color: "#ffffff"; font.pixelSize: modelData.size
                                font.bold: modelData.action === "db"
                                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (modelData.action === "settings") settingsWindow.show()
                                else if (modelData.action === "db") dbWindow.show()
                                else if (modelData.action === "minimize") root.visibility = Window.Minimized
                                else Qt.quit()
                            }
                        }
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

                    // Botones de control — square, icon + label below
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 14

                        // Reset
                        ColumnLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignHCenter
                            Button {
                                Layout.preferredWidth: 64
                                Layout.preferredHeight: 64
                                Layout.alignment: Qt.AlignHCenter
                                background: Rectangle {
                                    color: parent.hovered ? "#EF5350" : "#D32F2F"
                                    radius: 14
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                contentItem: Text {
                                    text: "✕"
                                    color: "#ffffff"
                                    font.pixelSize: 22
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: timerBackend.resetAll()
                            }
                            Text {
                                text: "Reset"
                                color: "#CAC4D0"
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        // Start / Pause
                        ColumnLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignHCenter

                            property string btnText: timerBackend.controlButtonText
                            property bool isPaused: btnText.indexOf("Pause") >= 0

                            Button {
                                Layout.preferredWidth: 64
                                Layout.preferredHeight: 64
                                Layout.alignment: Qt.AlignHCenter
                                background: Rectangle {
                                    color: parent.hovered ? "#5C6BC0" : "#9eb6f2"
                                    radius: 14
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                contentItem: Text {
                                    text: parent.parent.isPaused ? "❚❚" : "▶"
                                    color: "#19192c"
                                    font.pixelSize: 22
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: timerBackend.startTimer()
                            }
                            Text {
                                text: parent.isPaused ? "Pause" : "Start"
                                color: "#CAC4D0"
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        // Skip
                        ColumnLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignHCenter
                            Button {
                                Layout.preferredWidth: 64
                                Layout.preferredHeight: 64
                                Layout.alignment: Qt.AlignHCenter
                                background: Rectangle {
                                    color: parent.hovered ? "#78909C" : "#546E7A"
                                    radius: 14
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                contentItem: Text {
                                    text: "⏭"
                                    color: "#ffffff"
                                    font.pixelSize: 22
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: timerBackend.skipTimer()
                            }
                            Text {
                                text: "Skip"
                                color: "#CAC4D0"
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }


                }
            }
        }
    }

}
