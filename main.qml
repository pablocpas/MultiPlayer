// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts
ApplicationWindow {
    visible: true
    color: "#1f1f1f"
    width: 1024
    height: 720
    title: qsTr("Reproductor de Video")
    property int numberOfPlayers: 2  // Propiedad para controlar el número de VideoPlayers

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



    Button {
        id:playButton
        text: "Reproducir/Pausa"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            video0.play()
            video1.play()
        }
    }

    Button {
        text: "Siguiente Segmento"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: playButton.top
        anchors.bottomMargin: 10
        onClicked: {
            videoHandler.playNextSegment(video0)
        }
    }

    ToolBar {
        id: toolBar
        x: 0
        y: 0
        width: parent.width
        height: 30


        
        Button {
            text: "Editar segmentos"
            onClicked: segmentDialog.open()
        }

        Button {
            text: "Abrir video youtube"
            onClicked: youtubeDialog.open()
        }

    }

    GridLayout {
        id: grid
        anchors.fill: parent
        columns: 2
        rowSpacing: 10
        columnSpacing: 10

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

    Row {  // Fila para los botones que controlan el número de VideoPlayers
        spacing: 10
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20

        Button {
            text: "2 Players"
            onClicked: numberOfPlayers = 2
        }
        Button {
            text: "3 Players"
            onClicked: numberOfPlayers = 3
        }
        Button {
            text: "4 Players"
            onClicked: numberOfPlayers = 4
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
