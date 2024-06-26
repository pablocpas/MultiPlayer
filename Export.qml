import QtQuick 2.15
import QtQuick.Controls 2.15

Window {
    id: exportingWindow
    visible: false
    width: 400
    height: 200
    title: "Exportación en Progreso"

    minimumWidth: 400
    minimumHeight: 200
    maximumWidth: 400
    maximumHeight: 200

    ProgressBar {
        id: progressBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
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

    Button {
        id: cancelButton
        text: qsTr("Cancelar")
        anchors.top: progressBar.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        onClicked: {
            confirmationDialog.open()
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
        function onProgressUpdated(progress) {
            progressBar.updateProgress(progress);
        }

        function onFinished(file_path) {
            exportingWindow.close();  // Cerrar la ventana cuando la exportación finaliza
        }
    }

    onVisibleChanged: {
        if (visible) {
            videoHandler.combine_videos()
        }
    }
}
