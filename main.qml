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

    property var videoPlayers: []
    property int numberOfPlayers: 2
    property int maxSegmentDuration: 0
    property bool hasVideo: false
    property int currentSegment: 0
    property bool isFullScreen: false
    property VideoPlayerComponent longestVideoPlayer: null
    property double speed: 1

    signal segmentsLoaded(var segments)

    signal playAll()
    signal pauseAll()
    signal playNextSegment()
    signal playPreviousSegment()
    signal seekAll(int value)
    signal speedChange(double speed)

    property bool segmentEditorVisible: false

    Download {
        id: progressWindow
    }

    SegmentEditor {
        id: segmentEditor
    }

    Shortcuts {}

    ColumnLayout {
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
        text: "Recortar video"
        visible: false
        anchors.centerIn: parent
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

    Connections {
        target: segmentEditor
        function onSegmentsUpdated(segments) {
            console.log("me llegoooo")

            segmentsLoaded(segments)
            console.log(segments)
        }
    }

}
