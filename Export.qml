import QtQuick
import QtQuick.Controls

Window {
    id: exportingWindow
    visible: false
    width: 400
    height: 200
    title: "Exoratción en Progreso"

    ProgressBar {
        id: progressBar
        anchors.centerIn: parent
        width: parent.width - 40
        height: 30
        value: 0

        function updateProgress(value) {
            progressBar.value = value / 100
        }
    }

    Text {
        id: text1
        anchors.bottom: progressBar.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        text: qsTr("Exportando...")
        font.pixelSize: 19
    }

    Connections {
        target: videoHandler
        function onProgressUpdated(progress) {
            console.log("Progress received: " + progress);
            progressBar.updateProgress(progress);
        }

        function onFinished(file_path) {
            console.log("aaaaaaaeeeee")
            
            exportingWindow.close();  // Cerrar la ventana cuando la descarga finaliza
        }
}



}