import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Layouts

ToolBar {
    id: bottomBar
    width: parent.width
    Layout.fillWidth: true
    height: 90

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
            from: 0
            to: mainWindow.maxSegmentDuration
            value: mainWindow.longestVideoPlayer.position
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
            onMoved: {
                mainWindow.seekAll(progressSlider.value)
            }
        }
    }

    RowLayout {
        y: 36
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            icon.source: "./images/screen-full.svg"
            background: Rectangle {
                opacity: 0
            }
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
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

        Button {
            icon.source: "./images/anterior.svg"
            Layout.fillHeight: true
            Layout.fillWidth: true
            background: Rectangle {
                opacity: 0
            }
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
            onClicked: {
                mainWindow.playNextSegment()
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
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
            onClicked: {
                mainWindow.playNextSegment()
            }
        }

        ComboBox {
            id: speedSelector
            implicitWidth: 65
            model: ["0.25x", "0.5x", "0.75x", "1x", "1.25x", "1.5x", "1.75x", "2x"]
            Layout.alignment: Qt.AlignCenter
            currentIndex: 3
            onActivated: {
                mainWindow.speed = currentText.split("x")[0]
                mainWindow.speedChange(mainWindow.speed)
                console.log("Speed changed to " + mainWindow.speed)
            }
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
        }
    }
}
