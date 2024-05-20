import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts

ApplicationWindow {
    id: mainWindow
    visible: true
    color: "#1f1f1f"
    width: 1024
    height: 720
    title: qsTr("Reproductor de Video")
    property var videoPlayers: []
    property int numberOfPlayers: 2  // Propiedad para controlar el número de VideoPlayers

    signal playAll()
    signal pauseAll()

    signal playNextSegment()

    Download {
        id: progressWindow
    }

    Dialog {
        id: segmentDialog
        title: "Editar Segmentos del Vídeo"
        modal: true
        visible: false
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent

        TextArea {
            id: textArea
            placeholderText: qsTr("Ingrese los segmentos en el formato 'mm:ss - Descripción' \n Ejemplo:\n00:00 - Inicio del video\n00:10 - Final del video\n00:20 - Créditos finales\n")
        }

        onAccepted: {
            videoHandler.updateSegments(textArea.text)
            console.log("Segmentos guardados")
        }
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
            height: 45  // Ajustar la altura de la barra de herramientas

            background: Rectangle {
                implicitHeight: 50  // Ajustar la altura implícita del fondo
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
                    // Set the initial checked state based on numberOfPlayers
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
            Layout.preferredHeight: parent.height - 60 // Ajustar según sea necesario

            Repeater {
                model: numberOfPlayers  // El modelo del Repeater es el número de VideoPlayers
                delegate: VideoPlayerComponent {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    playerIndex: index  // Cada componente conoce su índice
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
            height: 45

            background: Rectangle {
                implicitHeight: 50
                color: "#161616"
                border.width: 1
                border.color: "#2b2b2b"
            }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter

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
                    
                    onClicked: {
                        mainWindow.playNextSegment()
                    }
                }

                Button {
                    icon.source: "./images/play.svg"
                    checkable: true

                    id: playButton
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
                    
                    onClicked: {
                        mainWindow.playNextSegment()
                    }
                }
            }
        }
    }

    Button {
        text: "Recortar video"
        anchors.centerIn: parent
        onClicked: videoHandler.trim_video(video0.propiedad, rangeSlider.first.value, rangeSlider.second.value)
    }

    Button {
        text: "Fusion"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 46
        anchors.horizontalCenterOffset: -1
        onClicked: videoHandler.fusion_video(video0.propiedad, video1.propiedad)
    }
}
