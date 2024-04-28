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
    width: 640
    height: 480
    title: qsTr("Reproductor de Video")

    FileDialog {
        id: fileDialogs
        title: "Seleccione un vídeo"
        nameFilters: ["Video files (*.mp4 *.avi *.mov)"]
        property int videoIndex: 0

        onAccepted: {
            if (videoIndex === 0){
                video0.propiedad = selectedFile
                video0.pause()
                video0.seek(0)
            } 

            else if (videoIndex === 1){
                video1.propiedad = selectedFile
                video1.pause()
                video1.seek(0)
            }
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
                        video0.pause()
                        video0.seek(0)
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
                    video0.finalTime = second.value * 1000; // Actualiza el tiempo final
                }

            }
        }



        // Segundo VideoPlayer

        Rectangle{

            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#161616"
            radius: 10

            DropArea {
                id: dropArea2
                anchors.fill: parent

                onEntered: {
                    drag.accept (Qt.LinkAction);
                }
                onDropped: {
                    console.log(drop.urls)

                    if (drop.urls.length > 0) {
                        video1.propiedad = drop.urls[0].toString().replace("file:///", "")
                        video1.pause()
                        video1.seek(0)
                    }
                }

            }

            VideoPlayer {
                id: video1
                z: 4

                height: parent.height
                width: parent.width


                    onDurationChanged: {
                    // Manejar la nueva duración
                    rangeSlider2.to = video1.duration / 1000 // Actualiza 'to' en segundos
                    rangeSlider2.first.value = video1.duration
                    rangeSlider2.second.value = video1.duration / 1000
                }
            }

            Column{
                height: parent.height
                width: parent.width
                Button {
                    id: selectButton2
                    text: "Seleccionar Video 2"

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter


                    onClicked:{
                        fileDialogs.videoIndex = 1
                        fileDialogs.open()
                    }
                }

                Button {
                    id: downloadYoutubeButton

                    text: "Descargar Video de YouTube"

                    onClicked: {
                        videoHandler.downloadFromYouTube(urlTextField.text, videoIndex)
                    }
                }

                TextField {
                    id: urlTextField
                    placeholderText: "Introduce URL de YouTube aquí"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: downloadYoutubeButton.top
                    anchors.bottomMargin: 10
                    width: parent.width * 0.8
                }
            }


            RangeSlider {
                id: rangeSlider2
                width: video1.width
                height: 40

                x: video1.x
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter

                from: 0
                to: 100000 // La duración del video debe ser en segundos

                first.value: 0
                second.value: video1.duration / 1000

                // Actualiza la posición del vídeo cuando se mueve el primer handle
                first.onMoved: {
                    video1.seek(first.value * 1000) // Multiplica por 1000 para convertir segundos a milisegundos
                }

                // Actualiza la posición del vídeo cuando se mueve el segundo handle
                second.onMoved: {
                    video1.finalTime = second.value * 1000; // Actualiza el tiempo final
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
