import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts

Item {
    property alias videoSource: videoPlayer.ruta
    property bool videoLoaded: false
    property int playerIndex: 0  // Para identificar el índice del reproductor

    Rectangle {
        anchors.fill: parent
        Layout.fillHeight: true
        Layout.fillWidth: true
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        color: "#161616"
        radius: 10
        border.width: 1
        border.color: "#2b2b2b"


        DropArea {
            anchors.fill: parent
            keys: ["text/uri-list"]

            //onEntered: {
            //    dragIcon.visible = true;
            //}

            //onExited: {
            //    dragIcon.visible = false;
            //}

            onDropped: {
                if (drop.urls.length > 0) {
                    videoPlayer.ruta = drop.urls[0].toString().replace("file:///", "")
                    videoPlayer.pause()
                    videoPlayer.seek(0)
                    videoLoaded = true
                }
            }
        }

        VideoPlayer {
            id: videoPlayer
            anchors.fill: parent
            onDurationChanged: {
                // Handle duration change
            }
        }

        Image {
            id: dragIcon
            source: "./images/drag_drop_icon.png"
            width: 128
            height: 128
            visible: !videoLoaded
            anchors.centerIn: parent
            anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: buttonLayout.top
                    bottomMargin: 5  // Ajusta la separación a tus necesidades
            }
        }

        Text {
            text: "Arrastre un vídeo aquí"
            color: "#a3a3a3"
            font.pixelSize: 12
            visible: !videoLoaded
                anchors { bottom: dragIcon.top; horizontalCenter: dragIcon.horizontalCenter }
        }

        ColumnLayout {
            id: buttonLayout
            anchors.verticalCenterOffset: 120
            anchors.centerIn: parent
            spacing: 10

            Button {
                text: "Seleccionar Video " + (playerIndex)
                visible: !videoLoaded
                //font.family: "Helvetica"

                //background: Rectangle {
                //    color: "#0078d4"
                //    radius: 3
                //}

                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    fileDialog.open()
                    console.log("Seleccionar video ")
                }
            }

            Button {
                text: "Youtube URL"
                Layout.alignment: Qt.AlignHCenter
                visible: !videoLoaded
                onClicked: youtubeDialog.open()
            }
        }
    }

        Dialog {
        id: youtubeDialog
        title: "Introduce la URL de Youtube"
        modal: true
        visible: false
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent

        TextField {
            id: textURL
            placeholderText: qsTr("https://www.youtube.com/watch?v=XXXXXXXXX")
        }

        onAccepted: {
            videoHandler.download_youtube_video(textURL.text, "./downloaded_videos", playerIndex)
            progressWindow.visible = true;
            videoLoaded = true
            console.log("Video descargado")
        }

    }

            FileDialog {
            id: fileDialog
            title: "Seleccione un vídeo"
            nameFilters: ["Video files (*.mp4 *.avi *.mov)"]

            onAccepted: {
                videoPlayer.ruta = selectedFile
                videoPlayer.pause()
                videoPlayer.seek(0)
                videoLoaded = true

            }
        }

        function setPath(path) {
            videoPlayer.setPath(path)
            videoPlayer.videoLoaded = true
        }

        function play() {
            videoPlayer.play()
        }

        function pause() {
            videoPlayer.pause()
        }

        function seek(position) {
            videoPlayer.seek(position)
        }

        Connections {
        target: mainWindow
        onPlayAll: {
            videoPlayer.play()
        }
    }
}
