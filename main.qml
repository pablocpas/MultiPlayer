// main.qml

import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls 6.5

ApplicationWindow {
    id: mainWindow
    visible: true
    color: "#1f1f1f"
    width: 1024
    height: 720
    title: qsTr("Reproductor de Video")

    property int numberOfPlayers: 2
    property int maxSegmentDuration: 0
    property bool hasVideo: false
    property bool hasSegments: false

    property var segments: []
    property int currentSegment: 0
    property bool isFullScreen: false
    property VideoPlayerComponent longestVideoPlayer: null
    property double speed: 1

    property var longest_segments: []
    property var longest_timestamps: []
    property var longest_videoPlayerId: []

    property alias videoPlayersRepeater: videoPlayersRepeater

    signal segmentsLoaded(var segments)

    signal playAll()
    signal pauseAll()
    signal playNextSegment()
    signal playPreviousSegment()
    signal seekAll(int value)
    signal speedChange(double speed)

    signal changeSegment(int index)

    property bool segmentEditorVisible: false

    Download {
        id: progressWindow
    }

    SegmentEditor {
        id: segmentEditor
    }

    Shortcuts {}

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 15

        TopBar{
            id: topBar
            Layout.fillWidth: true
        }

        GridLayout {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: 10
            columnSpacing: 10
            Layout.preferredHeight: parent.height - 60

            Repeater {

                id: videoPlayersRepeater
                model: numberOfPlayers
                delegate: VideoPlayerComponent {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    playerIndex: index

                    Component.onCompleted: {
                        videoHandler.registerVideoPlayer(this, index)
                    }
                }
            }
        }

        BottomBar {
            id: bottomBar
            Layout.fillWidth: true
        }
    }

    
    Button {
            icon.source: "./images/download.svg"
            visible: true
            anchors.centerIn: parent


            Layout.fillHeight: true
            Layout.fillWidth: true
            background: Rectangle {
                opacity: 0
            }
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "Exportar vídeo combinado"

            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
            enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
            onClicked: {
                videoHandler.exportVideo()
            }
    }

    Button {
        text: "Fusion"
        visible: false
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 46
        anchors.horizontalCenterOffset: -1
    }

    function setVisible(visible) {
        segmentEditor.visible = visible
    }

    function setSegments(segments, index) {
        this.segments = segments

        console.log("AQUI VA INDEX", index)

        // Initialize longest_segments if empty or update with new segments
        if (longest_segments.length === 0) {
            longest_segments = segments.map(segment => segment.duration)
            longest_timestamps = segments.map(segment => segment.timestampInSeconds)

            longest_videoPlayerId = segments.map(segment => index)
        } else {
            for (let i = 0; i < segments.length; i++) {
                if (i < longest_segments.length) {
                    if (segments[i].duration > longest_segments[i]) {
                        longest_segments[i] = segments[i].duration
                        longest_timestamps[i] = segments[i].timestampInSeconds
                        longest_videoPlayerId[i] = index

                    }
                } else {
                    longest_segments.push(segments[i].duration)
                    longest_timestamps.push(segments[i].timestampInSeconds)
                    longest_videoPlayerId.push(index)
                }
            }
        }

    }

    function nextSegment() {
        if(currentSegment < segments.length - 1){

            currentSegment++

            bottomBar.updateCurrentSegment()
            changeSegment(currentSegment)
           
        }
    }

    function previousSegment() {
        if(currentSegment > 0){
            currentSegment--
            bottomBar.updateCurrentSegment()
            changeSegment(currentSegment)

        }
    }

    Connections {
        target: segmentEditor
        function onSegmentsUpdated(s) {

            segments = s

            segmentsLoaded(segments)
            console.log(segments)
        }
    }

    onSegmentsChanged: {

            bottomBar.updateCurrentSegment()
        
    }

        function iterateOverPlayers() {
        for (let i = 0; i < videoPlayersRepeater.count; i++) {
            let videoPlayer = videoPlayersRepeater.itemAt(i);
            if (videoPlayer) {
                console.log("VideoPlayer Index:", videoPlayer.playerIndex);
                console.log("VideoPlayer Position:", videoPlayer.position);
                // You can access other properties or call functions on the videoPlayer here
            }
        }
    }

}
