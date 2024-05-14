// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

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
    property int numberOfPlayers: 4  // Propiedad para controlar el número de VideoPlayers

    signal playAll()

    Download{
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
            id:textArea
            placeholderText: qsTr("Ingrese los segmentos en el formato 'mm:ss - Descripción' \n Ejemplo:\n00:00 - Inicio del video\n00:10 - Final del video\n00:20 - Créditos finales\n")
        }

        onAccepted: {
            videoHandler.updateSegments(textArea.text)
            console.log("Segmentos guardados")
        }

    }



    Shortcuts{}




    ColumnLayout{
        anchors.fill: parent
        spacing: 15

        ToolBar {
            id: toolBar
            x: 0
            y: 0
            Layout.fillWidth: true
            height: 30

            background: Rectangle {
                implicitHeight: 40
                color: "#161616"
                border.width: 1
                border.color: "#2b2b2b"
            }
                RowLayout{
                anchors.horizontalCenter: parent.horizontalCenter
                ToolButton {
                    icon.source: "./images/split2.svg"
                    checkable: true
                    autoExclusive: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: numberOfPlayers = 2
                }
                ToolButton {
                    icon.source: "./images/split3.svg"
                    checkable: true
                    autoExclusive: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: numberOfPlayers = 3
                }
                ToolButton {
                    icon.source: "./images/split4.svg"
                    checkable: true
                    autoExclusive: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: numberOfPlayers = 4
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
            height: 30

            background: Rectangle {
                implicitHeight: 40
                color: "#161616"
                border.width: 1
                border.color: "#2b2b2b"
            }

            RowLayout{
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    id:playButton
                    text: "Reproducir/Pausa"
                    onClicked: {
                        mainWindow.playAll()                    
                    }
                }

                Button {
                    text: "Siguiente Segmento"
                    onClicked: {
                        videoHandler.playNextSegment(video0)
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
