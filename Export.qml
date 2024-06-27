import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
        function onProgressUpdated(progress) {
            progressBar.updateProgress(progress);
        }

        function onFinishedCombine(file_path) {
            //exportingWindow.visible = false;  // Cerrar la ventana cuando la exportación finaliza
            finishedText.text = file_path;
            finishedText.visible = true;
        }
    }

    onVisibleChanged: {
        if (visible) {
            videoHandler.combine_videos()
        }
    }
}
