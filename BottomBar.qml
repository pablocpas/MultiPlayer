// BottomBar.qml

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ToolBar {
    id: bottomBar
    width: 800
    Layout.fillWidth: true
    height: 90

    property int currentIndex: mainWindow.currentSegment


    background: Rectangle {
        implicitHeight: 90
        color: "#161616"
        border.width: 1
        border.color: "#2b2b2b"
    }

    ColumnLayout {
        width: parent.width

        Slider {
            id: progressSlider
            from: mainWindow.longest_timestamps[currentIndex] * 1000
            to: mainWindow.longest_timestamps[currentIndex] * 1000 + mainWindow.longest_segments[currentIndex] * 1000
            value: mainWindow.longestVideoPlayer.position
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
            onMoved: {
                mainWindow.seekAll(progressSlider.value)
                console.log("progressSlider.value: " + progressSlider.value)
                
            }
            onValueChanged: {
                console.log("onValueChanged")
            }

            
        }

    }

    RowLayout{
        y: 53
        x: 35
        Text {
            id: currentSegment
            text: "Segmento actual: "
            font.pixelSize: 19
            color: "#c5c5c5"

        }
    }

    RowLayout{
        x: controlButtons.x - 60
        y: 36
        Button {
            icon.source: "./images/screen-full.svg"
            background: Rectangle {
                opacity: 0
            }
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "Pantalla completa"
            onClicked: {
                if (mainWindow.isFullScreen) {
                    mainWindow.visibility = Window.Windowed
                    mainWindow.isFullScreen = false
                } else {
                    mainWindow.visibility = Window.FullScreen
                    mainWindow.isFullScreen = true
                }
            }
        }
    }

    RowLayout{
        id: controlButtons
        y:36
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            icon.source: "./images/anterior.svg"
            Layout.fillHeight: true
            Layout.fillWidth: true
            background: Rectangle {
                opacity: 0
            }
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "Anterior segmento"

            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
            onClicked: {
                mainWindow.playPreviousSegment()
                mainWindow.previousSegment()
            
            }
        }

        Button {
            icon.source: "./images/play.svg"
            checkable: true
            id: playButton
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
            onClicked: {
                if (playButton.checked) {
                    mainWindow.playAll()
                } else {
                    mainWindow.pauseAll()
                }
            }
            Layout.fillHeight: true
            Layout.fillWidth: true
            background: Rectangle {
                opacity: 0
            }
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
            onCheckedChanged: {
                icon.source = checked ? "./images/pause.svg" : "./images/play.svg"
            }
        }

        Button {
            icon.source: "./images/siguiente.svg"
            Layout.fillHeight: true
            Layout.fillWidth: true
            background: Rectangle {
                opacity: 0
            }
            ToolTip.text: "Siguiente segmento"
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
            onClicked: {
                mainWindow.playNextSegment()
                mainWindow.nextSegment()
            
            }
        }
    }

    RowLayout {
        y: 36
        x: controlButtons.x + 190

        spacing: 20


        ComboBox {
            id: speedSelector
            implicitWidth: 65
            model: ["0.25x", "0.5x", "0.75x", "1x", "1.25x", "1.5x", "1.75x", "2x"]
            Layout.alignment: Qt.AlignCenter
            currentIndex: 3

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "Velocidad de reproducción"

            onActivated: {
                mainWindow.speed = currentText.split("x")[0]
                mainWindow.speedChange(mainWindow.speed)
            }
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
        }

        Button {
            Layout.fillHeight: true
            Layout.fillWidth: true
            background: Rectangle {
                opacity: 0
            }
            icon.source: "./images/segments.svg"
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "Gestionar segmentos"

            onClicked: {
                console.log("Gestionar segmentos")
                mainWindow.setVisible(true)
            }
        }
    }

    function updateCurrentSegment() {
        currentSegment.text = "Segmento actual: " + mainWindow.segments[currentIndex].description
    }

    Connections  {
        target: mainWindow
        onPlaying: {
            playButton.checked = true
        }

        onPaused: {
            playButton.checked = false
        }
    }
}
