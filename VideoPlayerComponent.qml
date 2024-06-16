// VideoPlayerComponent.qml

import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts

Item {
    id: videoPlayerComponent
    property alias videoSource: videoPlayer.ruta
    property bool videoLoaded: false
    property int playerIndex: 0
    property var segments: []

    property int currentSegmentIndex: -1
    property string currentSegmentName: ""

    property string videoName: "Video " + (playerIndex + 1)

    property bool tag_editable: false

    property var segmentEndTime: 1

    property var timestamps: []

    property var segmentNames: []

    property int duration: videoPlayer.duration
    property int position: videoPlayer.position

    signal readyToPlay()

    signal segmentChanged()

    TimeStampEditor {
        id: timeStampEditor
        visible: false
        videoPath: videoSource
        texto: "Editar segmentos del video " + (videoPlayerComponent.playerIndex + 1)
    }

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
                mainWindow.hasVideo = true
                if (videoPlayer.duration > mainWindow.maxSegmentDuration) {
                    mainWindow.maxSegmentDuration = videoPlayer.duration
                    mainWindow.longestVideoPlayer = videoPlayerComponent
                }
            }
            onPositionChanged: {
                if ( segmentEndTime> 0 && videoPlayer.position >= segmentEndTime) {
                    videoPlayer.pause()
                }
            }
            volumen: 1.0  // Inicialmente el volumen está al máximo
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
                bottomMargin: 5
            }
        }

        Text {
            text: "Arrastre un vídeo aquí"
            color: "#a3a3a3"
            font.pixelSize: 12
            visible: !videoLoaded
            anchors {
                bottom: dragIcon.top
                horizontalCenter: dragIcon.horizontalCenter
            }
        }

        ColumnLayout {
            id: buttonLayout
            anchors.verticalCenterOffset: 120
            anchors.centerIn: parent
            spacing: 10

            Button {
                text: "Seleccionar Video " + (playerIndex)
                visible: !videoLoaded
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    fileDialog.open()
                }
            }

            Button {
                text: "Youtube URL"
                Layout.alignment: Qt.AlignHCenter
                visible: !videoLoaded
                onClicked: youtubeDialog.open()
            }

            Button {
                text: "Editar Segmentos"
                Layout.alignment: Qt.AlignHCenter
                visible: videoLoaded
                onClicked: {

                }
            }
        }

        Row{

        }

        // Botón de mute
        Button {
            id: muteButton
            icon.source: "./images/mute.svg" // Imagen de mute (silencio)
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
            checkable: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo

            background: Rectangle {
                opacity: 0
            }

            

            onCheckedChanged: {
                videoPlayer.volumen = checked ? 0 : 1  // Silencia o activa el sonido
                console.log("video player volume: ", videoPlayer.volumen)
                icon.source = checked ? "./images/unmute.svg" : "./images/mute.svg" // Cambia el ícono según el estado
            }
        }

        Row {
                id: inputRow
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.bottomMargin: 10
                spacing: 5

                TextEdit {
                    id: tedit_videoName
                    text: "Video " + (playerIndex + 1)
                    readOnly: true
                    color: "#c5c5c5"
                    font.pixelSize: 16
                    wrapMode: TextEdit.NoWrap
                    onTextChanged: {
                        // Reemplaza los saltos de línea con espacios
                        tedit_videoName.text = tedit_videoName.text.replace(/\n/g, " ");
                    }
                }

                Button {
                    id: button
                    icon.source: "./images/write.svg"
                    icon.width: 18
                    icon.height: 18
                    y: tedit_videoName.y -3
                    background: Rectangle {
                        opacity: 0
                    }
                    icon.color: "transparent"
                    onClicked: {
                        if (tag_editable) {
                            icon.source = "./images/write.svg"
                            tedit_videoName.readOnly = true
                            tedit_videoName.focus = false
                            tag_editable = false
                            videoName = tedit_videoName.text
                            // Emitir señal para actualizar el nombre del video
                        } else {
                            icon.source = "./images/save.svg"
                            tedit_videoName.readOnly = false
                            tedit_videoName.selectAll()
                            tedit_videoName.focus = true
                            tag_editable = true
                        }
                    }
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
            progressWindow.visible = true
            videoLoaded = true
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
        videoLoaded = true
    }

    function setSegments(segments) {
        timestamps = videoHandler.updateSegments(videoPlayerComponent.playerIndex, segments)

        console.log("Timestamps: ", timestamps)

        segmentNames = videoHandler.getDescription(videoPlayerComponent.playerIndex)

        segmentChanged()


    }

    function playNextSegment() {
        if (currentSegmentIndex < timestamps.length - 1) {
            currentSegmentIndex++
            console.log("Playing segment: ", currentSegmentIndex)
            segmentEndTime = timestamps[currentSegmentIndex + 1] * 1000
            videoPlayer.seek(timestamps[currentSegmentIndex] * 1000)
            currentSegmentName = segmentNames[currentSegmentIndex]
        }
    }

    function playPreviousSegment() {
        if (currentSegmentIndex > 0) {
            currentSegmentIndex--
            console.log("Playing segment: ", currentSegmentIndex)
            videoPlayer.seek(timestamps[currentSegmentIndex] * 1000)
            currentSegmentName = segmentNames[currentSegmentIndex]
        }
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
        function onPlayAll() {
            videoPlayerComponent.play()
        }
        function onPlayNextSegment() {
            playNextSegment()
        }
        function onPlayPreviousSegment() {
            playPreviousSegment()
        }
        function onPauseAll() {
            videoPlayer.pause()
        }
        function onSeekAll(position) {
            videoPlayer.seek(position)
        }
        function onSpeedChange(value) {
            videoPlayer.setPlaybackRate(value)
        }
    }

    Connections {
        target: mainWindow
        function onSegmentsLoaded(segments) {
            console.log("estoy en timestampEditor y recibi los segmentos")
            console.log(segments)
            timeStampEditor.updateSegments(segments)
            timeStampEditor.visible = true
        }
    }
}
