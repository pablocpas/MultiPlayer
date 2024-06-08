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
    property int numberOfPlayers: 2  // Propiedad para controlar el número de VideoPlayers
    property int maxSegmentDuration: 0 // Duración máxima del segmento
    property bool hasVideo: false // Propiedad para verificar si hay un video añadido

    property VideoPlayerComponent longestVideoPlayer: null
    property double speed: 1

    signal playAll()
    signal pauseAll()
    signal playNextSegment()
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
                    checkable: true
                    autoExclusive: true
                    ButtonGroup.group: toolButtonGroup
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: numberOfPlayers = 3

                    background: Rectangle {
                        opacity: 0
                    }
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"

                    onCheckedChanged: {
                        icon.source = checked ? "./images/split3_clicked.svg" : "./images/split3.svg"
                    }
                }
                ToolButton {
                    id: toolButton4
                    icon.source: "./images/split4.svg"
                    checkable: true
                    autoExclusive: true
                    ButtonGroup.group: toolButtonGroup
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: numberOfPlayers = 4

                    background: Rectangle {
                        opacity: 0
                    }
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"

                    onCheckedChanged: {
                        icon.source = checked ? "./images/split4_clicked.svg" : "./images/split4.svg"
                    }
                }

                Component.onCompleted: {
                    switch (numberOfPlayers) {
                        case 2:
                            toolButton2.checked = true;
                            break;
                        case 3:
                            toolButton3.checked = true;
                            break;
                        case 4:
                            toolButton4.checked = true;
                            break;
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

        ToolBar {
            id: toolBar2
            width: parent.width
            Layout.fillWidth: true
            height: 90

            background: Rectangle {
                implicitHeight: 90
                color: "#161616"
                border.width: 1
                border.color: "#2b2b2b"
            }
            ColumnLayout {
                width: parent.width

                Slider {
                    id: progressSlider
                    from: 0
                    to: mainWindow.maxSegmentDuration
                    value: mainWindow.longestVideoPlayer.position
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
                    onMoved: {
                        seekAll(progressSlider.value)
                    }
                }
            }

            RowLayout {
                y: 36
                anchors.horizontalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter


                Rectangle {
                    id: rectangleeeee
                    width: 140

                }

                Button {
                    icon.source: "./images/anterior.svg"
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    background: Rectangle {
                        opacity: 0
                    }
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"
                    enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
                    onClicked: {
                        mainWindow.playNextSegment()
                    }
                }

                Button {
                    icon.source: "./images/play.svg"
                    checkable: true
                    id: playButton
                    enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
                    onClicked: {
                        if (playButton.checked) {
                            playAll()
                        } else {
                            pauseAll()
                        }
                    }
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    background: Rectangle {
                        opacity: 0
                    }
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"
                    onCheckedChanged: {
                        icon.source = checked ? "./images/pause.svg" : "./images/play.svg"
                    }
                }

                Button {
                    icon.source: "./images/siguiente.svg"
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    background: Rectangle {
                        opacity: 0
                    }
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"
                    enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
                    onClicked: {
                        mainWindow.playNextSegment()
                    }
                }

                ComboBox {
                    id: speedSelector
                    width: 100
                    model: ["0.25x", "0.5x", "0.75x", "1x", "1.25x", "1.5x", "1.75x", "2x"]
                    Layout.alignment: Qt.AlignCenter
                    currentIndex: 3
                    onActivated: {
                        speed = currentText.split("x")[0]
                        speedChange(speed);
                        console.log("Speed changed to " + speed);
                    }
                    enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
                }
            }
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
        onClicked: videoHandler.fusion_video(video0.propiedad, video1.propiedad)
    }
}
