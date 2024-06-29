// Download.qml

import QtQuick
import QtQuick.Controls

/**
 * Ventana para mostrar el progreso de la descarga de videos.
 */
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

        /**
         * Actualiza el progreso de la barra de progreso.
         * @param value Valor del progreso.
         */
        function updateProgress(value) {
            progressBar.value = value / 100
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

    /**
     * Resetea el valor de la barra de progreso cuando la ventana se hace visible.
     */
    onVisibleChanged: {
        progressBar.value = 0;
    }

    Connections {
        target: videoHandler

        /**
         * Actualiza el progreso de la descarga.
         * @param progress Progreso actual de la descarga.
         */
        function onProgressUpdated(progress) {
            progressBar.updateProgress(progress);
        }

        /**
         * Acción realizada cuando la descarga finaliza.
         * @param file_path Ruta del archivo descargado.
         */
        function onFinished(file_path) {            
            progressWindow.close();  // Cierra la ventana cuando la descarga finaliza
        }
    }
}
