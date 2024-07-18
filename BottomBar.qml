// BottomBar.qml

/** \addtogroup frontend
 * @{
 */

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * Barra de herramientas inferior del reproductor de video.
 */
ToolBar {
    id: bottomBar
    width: 800
    Layout.fillWidth: true
    height: 90

    /** type:int Índice del segmento actual */
    property int currentIndex: mainWindow.currentSegment
    /** type:int Número de segmentos */
    property int numberOfSegments: mainWindow.segments.length

    property bool segmentsLoaded : mainWindow.hasSegments

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
            to: mainWindow.longest_timestamps[currentIndex] * 1000 + mainWindow.longest_segments[currentIndex] * 1000 || 0
            value: mainWindow.longestVideoPlayer ? mainWindow.longestVideoPlayer.position : 0
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
            /**
             * Busca la posición en todos los videos cuando se mueve el slider.
             */
            onMoved: {
                mainWindow.seekAll(progressSlider.value)
            }

        }
    }

    RowLayout {
        y: 53
        x: 35
        Text {
            id: currentSegment
            text: "Segmento actual: "
            font.pixelSize: 19
            color: "#c5c5c5"
        }
    }

    RowLayout {
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
            /**
             * Alterna entre pantalla completa y ventana.
             */
            onClicked: {
                if (mainWindow.isFullScreen) {
                    mainWindow.isFullScreen = false
                } else {
                    mainWindow.isFullScreen = true
                }
            }
        }
    }

    RowLayout {
        id: controlButtons
        y: 36
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
            /**
             * Reproduce el segmento anterior.
             */
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
            /**
             * Reproduce o pausa todos los videos.
             */
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
            /**
             * Cambia el ícono entre reproducir y pausar según el estado.
             */
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
            /**
             * Reproduce el siguiente segmento.
             */
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
            implicitWidth: 80
            model: ["0.25x", "0.5x", "0.75x", "1x", "1.25x", "1.5x", "1.75x", "2x"]
            Layout.alignment: Qt.AlignCenter
            currentIndex: 3

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "Velocidad de reproducción"
            /**
             * Cambia la velocidad de reproducción.
             */
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
            /**
             * Abre el editor de segmentos.
             */
            onClicked: {
                mainWindow.clearlongestSegments()
                mainWindow.setSegmentEditorVisibility(true)
            }
        }
    }

    /**
     * Actualiza el texto del segmento actual en la barra inferior y el slider de progreso.
     */
    function updateCurrentSegment() {
        if (segmentsLoaded == false) {
            return
        }

        console.log("Updating current segment")

        currentSegment.text = "Segmento actual: " + mainWindow.segments[currentIndex].description + " (" + (currentIndex + 1) + "/" + numberOfSegments + ")"
        progressSlider.from = mainWindow.longest_timestamps[currentIndex] * 1000
        progressSlider.to = mainWindow.longest_timestamps[currentIndex] * 1000 + mainWindow.longest_segments[currentIndex] * 1000
    }

    Connections {
        target: mainWindow
        /**
         * Actualiza el estado del botón de reproducción cuando el video está reproduciéndose.
         */
        function onPlaying() {
            playButton.checked = true
        }

        /**
         * Actualiza el estado del botón de reproducción cuando el video está en pausa.
         */
        function onPausa() {
            playButton.checked = false
        }
    }
}

/** @} */