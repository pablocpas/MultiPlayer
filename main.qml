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

    signal playAll()
    signal pauseAll()
    signal playNextSegment()
    signal playPreviousSegment()
    signal seekAll(int value)
    signal speedChange(double speed)

    Download {
        id: progressWindow
    }

    Shortcuts {}

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        ToolBar {
            id: toolBar
            x: 0
            y: 0
            Layout.fillWidth: true
            height: 45

            background: Rectangle {
                implicitHeight: 50
                color: "#161616"
                border.width: 1
                border.color: "#2b2b2b"
            }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter

                ButtonGroup {
                    id: toolButtonGroup
                }

                ToolButton {
                    id: toolButton2
                    icon.source: "./images/split2.svg"
                    checkable: true
                    autoExclusive: true
                    ButtonGroup.group: toolButtonGroup
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: numberOfPlayers = 2

                    background: Rectangle {
                        opacity: 0
                    }
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"

                    onCheckedChanged: {
                        icon.source = checked ? "./images/split2_clicked.svg" : "./images/split2.svg"
                    }
                }

                ToolButton {
                    id: toolButton3
                    icon.source: "./images/split3.svg"
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"
                    checkable: true
                    autoExclusive: true
                    ButtonGroup.group: toolButtonGroup
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: numberOfPlayers = 3

                    background: Rectangle {
                        opacity: 0
                    }


                    onCheckedChanged: {
                        icon.source = checked ? "./images/split3_clicked.svg" : "./images/split3.svg"
                    }
                }

                ToolButton {
                    id: toolButton4
                    icon.source: "./images/split4.svg"
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"

                    checkable: true
                    autoExclusive: true
                    ButtonGroup.group: toolButtonGroup
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: numberOfPlayers = 4

                    background: Rectangle {
                        opacity: 0
                    }


                    onCheckedChanged: {
                        icon.source = checked ? "./images/split4_clicked.svg" : "./images/split4.svg"
                    }
                }

                Component.onCompleted: {
                    switch (numberOfPlayers) {
                        case 2:
                            toolButton2.checked = true
                            break
                        case 3:
                            toolButton3.checked = true
                            break
                        case 4:
                            toolButton4.checked = true
                            break
                    }
                }
            }
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
        anchors.centerIn: parent
    }

    Button {
        text: "Fusion"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 46
        anchors.horizontalCenterOffset: -1
    }
}
