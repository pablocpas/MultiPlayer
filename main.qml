// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.5
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts
ApplicationWindow {
    visible: true
    color: "#1f1f1f"
    width: 640
    height: 480
    title: qsTr("Reproductor de Video")

    FileDialog {
        id: fileDialogs
        title: "Seleccione un vídeo"
        nameFilters: ["Video files (*.mp4 *.avi *.mov)"]
        property int videoIndex: 0

        onAccepted: {
            if (videoIndex === 0) video0.propiedad = selectedFile
            else if (videoIndex === 1) video1.propiedad = selectedFile
        }

    }


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

    ToolBar {
        id: toolBar
        x: 0
        y: 0
        width: parent.width
        height: 30

    }

    GridLayout {
        id: grid
        width: parent.width
        height: parent.height * 0.9
        anchors.top: toolBar.bottom
        anchors.bottom: playButton.top

        columnSpacing: 10

        columns:2

        Rectangle {
            id: rectangle
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#161616"
            radius: 10

            border.width: 1

            DropArea {
                id: dropArea
                anchors.fill: parent

                onEntered: {
                    drag.accept (Qt.LinkAction);
                }
                onDropped: {
                    console.log(drop.urls)

                    if (drop.urls.length > 0) {
                        video0.propiedad = drop.urls[0].toString().replace("file:///", "")
                    }
                }

            }


            // Primer VideoPlayer
            VideoPlayer {
                id: video0
                z: 4
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                height: parent.height
                width: parent.width

                Layout.column: 0

                onDurationChanged: {
                    // Manejar la nueva duración
                    rangeSlider.to = video0.duration / 1000 // Actualiza 'to' en segundos
                    rangeSlider.first.value = video0.duration
                    rangeSlider.second.value = video0.duration / 1000
                }


            }

            Button {
                text: "Select video"

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                onClicked:{
                    fileDialogs.videoIndex = 0
                    fileDialogs.open()
                }
            }

            RangeSlider {
                id: rangeSlider
                width: video0.width
                height: 40

                x: video0.x
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter

                from: 0
                to: 100000 // La duración del video debe ser en segundos

                first.value: 0
                second.value: video0.duration / 1000

                // Actualiza la posición del vídeo cuando se mueve el primer handle
                first.onMoved: {
                    video0.seek(first.value * 1000) // Multiplica por 1000 para convertir segundos a milisegundos
                }

                // Actualiza la posición del vídeo cuando se mueve el segundo handle
                second.onMoved: {
                    video0.seek(second.value * 1000 - 1000) // Multiplica por 1000 para convertir segundos a milisegundos

                    video0.finalTime = second.value * 1000; // Actualiza el tiempo final
                    video0.seek(first.value * 1000) // Mueve el vídeo al tiempo inicial
                }

            }
        }



        // Segundo VideoPlayer

        Rectangle{

            Layout.column: 1
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#161616"
            radius: 10


            VideoPlayer {
                id: video1


            }

            Button {
                text: "Seleccionar Video 2"

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter


                onClicked:{
                    fileDialogs.videoIndex = 1
                    fileDialogs.open()
                }
            }
        }







    }






    Button {

        text: "Recortar video"
        anchors.centerIn: parent
        onClicked: videoHandler.trim_video(video0.propiedad, rangeSlider.first.value, rangeSlider.second.value)
    }


}
