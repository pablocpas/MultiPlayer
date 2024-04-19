import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Dialogs
import "." // Importa el directorio actual para acceder a VideoPlayer.qml

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Reproductor de Video")

    FileDialog {
        id: fileDialogs
        title: "Seleccione un vídeo"
        nameFilters: ["Video files (*.mp4 *.avi *.mov)"]
        property int videoIndex: 0

        onAccepted: {
            if (videoIndex === 0) video0.propiedad = selectedFile
            else if (videoIndex === 1) video1.propiedad = selectedFile
        }

    }

    // Primer VideoPlayer
    VideoPlayer {
        id: video0
        width: parent.width / 2
        height: parent.height
        anchors.left: parent.left

        onDurationChanged: {
            // Manejar la nueva duración
            rangeSlider.to = video0.duration / 1000 // Actualiza 'to' en segundos
            rangeSlider.first.value = video0.duration
            rangeSlider.second.value = video0.duration / 1000
        }
    }

    // Segundo VideoPlayer
    VideoPlayer {
        id: video1
        width: parent.width / 2
        height: parent.height
        anchors.right: parent.right
    }

    Button {
        text: "Reproducir/Pausa"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            video0.play()
            video1.play()
        }
    }

        // RangeSlider para seleccionar el rango de tiempo del vídeo
    RangeSlider {
        id: rangeSlider
        width: parent.width - 20
        height: 40
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        from: 0
        to: 100000 // La duración del video debe ser en segundos

        first.value: 0
        second.value: video0.duration / 1000

        // Actualiza la posición del vídeo cuando se mueve el primer handle
        first.onMoved: {
            video0.seek(first.value * 1000) // Multiplica por 1000 para convertir segundos a milisegundos
        }

        // Actualiza la posición del vídeo cuando se mueve el segundo handle
        second.onMoved: {
            video0.seek(second.value * 1000) // Multiplica por 1000 para convertir segundos a milisegundos
        }

    }

    Button {
        text: "Seleccionar Video 1"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onClicked:{
            fileDialogs.videoIndex = 0
            fileDialogs.open()
        }
    }

    Button {
        text: "Recortar video"
        anchors.centerIn: parent
        onClicked: videoHandler.trim_video(video0.propiedad, rangeSlider.first.value, rangeSlider.second.value)
    }

    Button {
        text: "Seleccionar Video 2"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked:{
            fileDialogs.videoIndex = 1
            fileDialogs.open()
        }
    }

}
