import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import pomodoro
Window {
    id: root
    width: 850
    height: 550
    visible: true
    title: "Pomodoro"
    color: "transparent"
    //color: "#121316"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    PomodoroTimer {
        id: timerBackend
    }

    // El contenedor principal (Pane) que define el fondo de toda la aplicación
    Pane {
        anchors.fill: parent
        padding: 0

        background: Rectangle {
            color: "#b31e1e1e"
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
                }
            }
        }
    }
}