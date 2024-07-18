// VideoPlayerComponent.qml

/** \addtogroup frontend
 * @{
 */


import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts

/**
 * Componente de reproductor de video.
 */
Item {
    id: videoPlayerComponent
    /** type:alias Fuente del video */
    property alias videoSource: videoPlayer.ruta
    /** type:bool Indica si el video está cargado */
    property bool videoLoaded: false
    /** type:int Índice del reproductor */
    property int playerIndex: 0
    /** type:var Lista de segmentos */
    property var segments: []

    /** type:int Índice del segmento actual */
    property int currentSegmentIndex: mainWindow.currentSegment
    /** type:string Nombre del segmento actual */
    property string currentSegmentName: ""

    /** type:double Desplazamiento de tiempo */
    property double offset: 0

    /** type:string Nombre del video */
    property string videoName: "Video " + (playerIndex + 1)

    /** type:bool Indica si la etiqueta es editable */
    property bool tag_editable: false

    /** type:var Tiempos de finalización de los segmentos */
    property var segmentEndTime: []

    /** type:var Marcas de tiempo */
    property var timestamps: []

    /** type:var Nombres de los segmentos */
    property var segmentNames: []

    /** type:int Duración del video */
    property int duration: videoPlayer.duration
    /** type:int Posición actual del video */
    property int position: videoPlayer.position

    /** Editor de marcas de tiempo */
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

        /** Reproductor de video */
        VideoPlayer {
            id: videoPlayer
            anchors.fill: parent
            onDurationChanged: {
                mainWindow.hasVideo = true
                if (videoPlayer.duration > mainWindow.maxSegmentDuration) {
                    mainWindow.maxSegmentDuration = videoPlayer.duration
                    //mainWindow.longestVideoPlayer = videoPlayerComponent
                }
            }
            onPositionChanged: {
                if (segmentEndTime > 0 && videoPlayer.position >= segmentEndTime) {
                    videoPlayer.pause()
                }
            }
            volumen: 1.0  // Inicialmente el volumen está al máximo
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Image {
                id: dragIcon
                source: "./images/drag_drop_icon.png"
                Layout.preferredHeight: 128
                Layout.preferredWidth: 128
                visible: !videoLoaded
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Arrastre un vídeo aquí"
                color: "#a3a3a3"
                font.pixelSize: 16
                visible: !videoLoaded
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                id: buttonLayout
                spacing: 10
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "Seleccionar Video " + (playerIndex + 1)
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
                    visible: false
                    onClicked: {

                    }
                }
            }
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
                        videoHandler.setVideoName(playerIndex, videoName)
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

    /** Diálogo de Youtube */
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
            videoHandler.load_video(playerIndex, selectedFile)
            videoLoaded = true
        }
    }

    /**
     * Establece la ruta del video.
     * @param type:string path Ruta del video.
     */
    function setPath(path) {
        videoSource = path
        videoLoaded = true
    }

    /**
     * Configura los segmentos del video.
     * @param type:var segments Lista de segmentos.
     */
    function setSegments(segments) {
        timestamps = videoHandler.updateSegments(videoPlayerComponent.playerIndex, segments)

        segmentNames = videoHandler.getDescription(videoPlayerComponent.playerIndex)

        this.segments = segments
    }

    /**
     * Reproduce el siguiente segmento del video.
     */
    function playNextSegment() {
        if (currentSegmentIndex < timestamps.length - 1) {

            currentSegmentIndex++
            offset = timestamps[currentSegmentIndex] - mainWindow.longest_timestamps[currentSegmentIndex]

            segmentEndTime = timestamps[currentSegmentIndex + 1] * 1000

            videoPlayer.seek(timestamps[currentSegmentIndex] * 1000)

            videoPlayer.play()

            if(mainWindow.longest_videoPlayerId[currentSegmentIndex] == playerIndex){
                mainWindow.longestVideoPlayer = videoPlayerComponent
            }

            currentSegmentName = segmentNames[currentSegmentIndex]
        }
    }

    /**
     * Reproduce el segmento anterior del video.
     */
    function playPreviousSegment() {
        if (currentSegmentIndex > 0) {

            currentSegmentIndex--
            offset = timestamps[currentSegmentIndex] - mainWindow.longest_timestamps[currentSegmentIndex]
            segmentEndTime = timestamps[currentSegmentIndex + 1] * 1000
            videoPlayer.seek(timestamps[currentSegmentIndex] * 1000)

            videoPlayer.play()

            if(mainWindow.longest_videoPlayerId[currentSegmentIndex] == playerIndex){
                mainWindow.longestVideoPlayer = videoPlayerComponent
            }

            currentSegmentName = segmentNames[currentSegmentIndex]
        }
    }

    /**
     * Reproduce el video.
     */
    function play() {
        // Position
        videoPlayer.play()
    }

    /**
     * Pausa el video.
     */
    function pause() {
        videoPlayer.pause()
    }

    function stop() {
        videoPlayer.stop()
    }

    /**
     * Busca una posición en el video.
     * @param type:int position Posición en milisegundos.
     */
    function seek(position) {
        videoPlayer.seek(position + offset * 1000)
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
            videoPlayer.seek(position + offset * 1000)
        }
        function onSpeedChange(value) {
            videoPlayer.setPlaybackRate(value)
        }
    }

    Connections {
        target: mainWindow
        function onSegmentsLoaded(segments) {
            timeStampEditor.updateSegments(segments)
            timeStampEditor.visible = true
        }
    }

    Component.onCompleted: {
        videoHandler.setVideoName(playerIndex, videoName)
    }

    // Connections {
    //     target: videoHandler
    //     function onFinished(file_path, video_index) {   
    //         if(video_index == playerIndex){
    //             setPath(file_path)
    //         }
    //     }
    // }
}

/** @} */
