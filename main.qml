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
        id: fileDialogVideo0
        title: "Seleccione un vídeo"
        nameFilters: ["Video files (*.mp4 *.avi *.mov)"]
        onAccepted: {
            video0.propiedad = selectedFile
        }
    }

    FileDialog {
        id: fileDialogVideo1
        title: "Seleccione un vídeo"
        nameFilters: ["Video files (*.mp4 *.avi *.mov)"]
        onAccepted: {
            video1.propiedad = selectedFile
        }
    }

    // Primer VideoPlayer
    VideoPlayer {
        id: video0
        width: parent.width / 2
        height: parent.height
        anchors.left: parent.left
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

    Button {
        text: "Seleccionar Video 1"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onClicked: fileDialogVideo0.open()
    }

    Button {
        text: "Seleccionar Video 2"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: fileDialogVideo1.open()
    }
}
