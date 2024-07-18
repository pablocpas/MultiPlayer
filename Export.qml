// Export.qml

/** \addtogroup frontend
 * @{
 */


import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * Ventana para mostrar el progreso de la exportación de videos.
 */
Window {
    id: exportingWindow
    visible: false
    width: 400
    height: 200
    title: "Exportación en Progreso"

    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    minimumWidth: 400
    minimumHeight: 200
    maximumWidth: 400
    maximumHeight: 200

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            id: text1
            text: qsTr("Exportando...")
            font.pixelSize: 19
            Layout.alignment: Qt.AlignHCenter
        }

        ProgressBar {
            id: progressBar
            width: parent.width - 40
            height: 30
            value: 0
            Layout.alignment: Qt.AlignHCenter

            /**
             * Actualiza el progreso de la barra de progreso.
             * @param value Valor del progreso.
             */
            function updateProgress(value) {
                progressBar.value = value / 100
            }
        }

        Button {
            id: cancelButton
            text: qsTr("Cancelar")
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                confirmationDialog.open()
            }
        }

        Text {
            id: finishedText
            visible: false
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    videoHandler.open_file_explorer(finishedText.text)
                }
            }
        }
    }

    Dialog {
        id: confirmationDialog
        title: qsTr("Confirmación")
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: parent

        Text {
            text: qsTr("¿Estás seguro de que deseas cancelar la exportación?")
            wrapMode: Text.WordWrap
        }

        onAccepted: {
            // Aquí puedes poner la lógica para cancelar la exportación
            videoHandler.stop()
            exportingWindow.close()
        }
    }

    Connections {
        target: videoHandler
        /**
         * Actualiza el progreso de la exportación.
         * @param progress Progreso actual de la exportación.
         */
        function onProgressUpdated(progress) {
            progressBar.updateProgress(progress);
        }

        /**
         * Acción realizada cuando la combinación de videos finaliza.
         * @param file_path Ruta del archivo exportado.
         */
        function onFinishedCombine(file_path) {
            //exportingWindow.visible = false;  // Cerrar la ventana cuando la exportación finaliza
            finishedText.text = file_path;
            finishedText.visible = true;
        }
    }

    /**
     * Inicia la combinación de videos cuando la ventana se hace visible.
     */
    onVisibleChanged: {
        if (visible) {
            progressBar.updateProgress(0)
            videoHandler.combine_videos()
        }
    }
}

/** @} */