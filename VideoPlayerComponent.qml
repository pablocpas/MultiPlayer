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
    property int segmentStartTime: 0
    property int segmentEndTime: 0

    SegmentEditor {
        id: segmentEditor
        visible: false
        segments: videoPlayerComponent.segments
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
                // Handle duration change
            }
            onPositionChanged: {
                if (segmentEndTime > 0 && videoPlayer.position >= segmentEndTime) {
                    videoPlayer.pause()
                }

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
                    segmentEditor.segments = segments
                    segmentEditor.visible = true
                    segmentEditor.videoPath = videoPlayer.ruta
                    console.log("path: ", segmentEditor.videoPath)
                }
            }
        }
    
        Text {
        id: segmentName
        text: videoPlayerComponent.currentSegmentName
        color: "white"
        font.pixelSize: 16
        anchors {
            top: parent.top
            left: parent.left
            margins: 10
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

    function play() {
        videoPlayer.play()
    }

    function pause() {
        videoPlayer.pause()
    }

    function seek(position) {
        videoPlayer.seek(position)
    }

    function handleSegmentsUpdated(newSegments) {
        console.log("handleSegmentsUpdated called with: ", newSegments)
        videoPlayerComponent.segments = newSegments
        console.log("Updated segments: ", videoPlayerComponent.segments)
        videoHandler.updateSegments(playerIndex, newSegments)
    }

    function playNextSegment() {
        console.log("Playing next segment, current segments length: ", videoPlayerComponent.segments.length)
        if (videoPlayerComponent.segments.length > 0) {
            currentSegmentIndex = (currentSegmentIndex + 1) % videoPlayerComponent.segments.length
            let segment = videoPlayerComponent.segments[currentSegmentIndex]
            let timestamp = segment.timestamp.split(":")
            let seconds = parseInt(timestamp[0]) * 60 + parseInt(timestamp[1]) * 1000
            currentSegmentName = segment.description
            segmentStartTime = seconds
            console.log("Playing segment: ", segment)

            let nextSegment = videoPlayerComponent.segments[(currentSegmentIndex + 1) % videoPlayerComponent.segments.length]
            let nextTimestamp = nextSegment.timestamp.split(":")
            let nextSeconds = parseInt(nextTimestamp[0]) * 60 + parseInt(nextTimestamp[1]) * 1000
            console.log("Next segment starts at: ", nextSeconds)
            segmentEndTime = nextSeconds

            videoPlayer.seek(segmentStartTime)
            videoPlayer.play()
        } else {
            console.log("No hay segmentos definidos.")
        }
    }

    Connections {
        target: mainWindow
        function onPlayAll() {
            videoPlayer.play()
        }
        function onPlayNextSegment() {
            playNextSegment()
        }
        function onPauseAll() {
            videoPlayer.pause()
        }
    }

    Component.onCompleted: {
        segmentEditor.segmentsUpdated.connect(handleSegmentsUpdated)
        console.log("Component completed, initial segments: ", videoPlayerComponent.segments)
    }
}
