import QtQuick
import QtQuick.Controls

Window {
    id: progressWindow
    visible: false
    width: 400
    height: 200
    title: "Descarga en Progreso"

    ProgressBar {
        id: progressBar
        anchors.centerIn: parent
        width: parent.width - 40
        height: 30
        value: 0

        function updateProgress(value) {
            progressBar.value = value
        }
    }

    Text {
        id: text1
        anchors.bottom: progressBar.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        text: qsTr("Descargando vídeo...")
        font.pixelSize: 19
    }

    Connections {
        target: videoHandler
        onProgressUpdated: progressBar.updateProgress(progressBar.value)
    }
}