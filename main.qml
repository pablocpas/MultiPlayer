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
            videoHandler.download_youtube_video(textURL.text, "./downloaded_videos", 0)
            progressWindow.visible = true;
            console.log("Video descargado")
        }

    }

    Shortcuts{}

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
                video0.videoLoaded = true
            } 

            else if (videoIndex === 1){
                video1.propiedad = selectedFile
                video1.pause()
                video1.seek(0)
                video1.videoLoaded = true
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
                id: dropArea1
                anchors.fill: parent
                keys: ["text/uri-list"]  // Aceptar solo arrastres que incluyan URIs

                onEntered: {
                    dragIcon1.visible = true;
                }

                onExited: {
                    dragIcon1.visible = false;
                    console.log("Drag exited");
                }

                onPositionChanged: {
                    if (containsDrag) {
                        drag.accept(Qt.LinkAction);
                    }
                }

                onDropped: {
                    console.log("Dropped with URLs: " + drop.urls)
                    if (drop.urls.length > 0) {
                        video0.propiedad = drop.urls[0].toString().replace("file:///", "")
                        video0.pause()
                        video0.seek(0)
                        video0.videoLoaded = true
                    }
                }
            }


            Image {
                //color #a3a3a3

                id: dragIcon1
                source: "./images/drag_drop_icon.png"
                width: 128  // Establece un ancho fijo
                height: 128  // Establece un alto fijo
                visible: !video0.videoLoaded
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: buttonLayout.top
                    bottomMargin: 5  // Ajusta la separación a tus necesidades
                }
            }

            Text {
                text: "Arrastre un vídeo aquí"
                color: "#a3a3a3"
                font.pixelSize: 12
                visible: !video0.videoLoaded
                anchors { bottom: dragIcon1.top; horizontalCenter: dragIcon1.horizontalCenter }
            }

            // Primer VideoPlayer
            VideoPlayer {
                id: video0
                z: 4
                anchors.fill: parent
                Layout.column: 0
                onDurationChanged: {
                    rangeSlider.first.value = 0
                    rangeSlider.to = video0.duration / 1000 // En segundos
                    rangeSlider.second.value = video0.duration / 1000
                }
                Component.onCompleted: {
                    videoHandler.registerVideoPlayer(video0)
                }
            }

            ColumnLayout {
                id: buttonLayout
                anchors.verticalCenterOffset: 63
                anchors.horizontalCenterOffset: 1
                anchors.centerIn: parent
                spacing: 10 // Espacio entre los botones

                Button {
                    text: "Seleccionar Video 1"
                    visible: !video0.videoLoaded
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        fileDialogs.videoIndex = 0
                        fileDialogs.open()
                    }
                }

                Button {
                    text: "Descargar desde Youtube"
                    visible: !video0.videoLoaded
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: youtubeDialog.open()

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
                to: 100000 // La duración del video en segundos
                first.value: 0
                second.value: video0.duration / 1000
                first.onMoved: {
                    video0.seek(first.value * 1000) // Convierte segundos a milisegundos
                    video0.initialTime = first.value * 1000; // Tiempo inicial
                }
                second.onMoved: {
                    video0.finalTime = second.value * 1000; // Tiempo final
                }
            }
        }




        // Segundo VideoPlayer

                // Segundo VideoPlayer con su entorno
        Rectangle {
            id: rectangle2
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#161616"
            radius: 10
            border.width: 1

            DropArea {
                id: dropArea2
                anchors.fill: parent
                onEntered: { drag.accept(Qt.LinkAction); }
                onDropped: {
                    console.log(drop.urls)
                    if (drop.urls.length > 0) {
                        video1.propiedad = drop.urls[0].toString().replace("file:///", "")
                        video1.pause()
                        video1.seek(0)
                        video1.videoLoaded = true
                    }
                }
            }

            Image {
                //color #a3a3a3

                id: dragIcon2
                source: "./images/drag_drop_icon.png"
                width: 128  // Establece un ancho fijo
                height: 128  // Establece un alto fijo
                visible: !video1.videoLoaded
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: buttonLayout2.top
                    bottomMargin: 5  // Ajusta la separación a tus necesidades
                }
            }

            Text {
                text: "Arrastre un vídeo aquí"
                color: "#a3a3a3"
                font.pixelSize: 12
                visible: !video1.videoLoaded
                anchors { bottom: dragIcon2.top; horizontalCenter: dragIcon2.horizontalCenter }
            }

            VideoPlayer {
                id: video1
                z: 4
                anchors.fill: parent
                Layout.column: 1
                onDurationChanged: {
                    rangeSlider2.to = video1.duration / 1000
                    rangeSlider2.first.value = 0
                    rangeSlider2.second.value = video1.duration / 1000
                }
            }

            ColumnLayout {
                id: buttonLayout2
                anchors.verticalCenterOffset: 63
                anchors.horizontalCenterOffset: 1
                anchors.centerIn: parent
                spacing: 10

                Button {
                    text: "Seleccionar Video 2"
                    Layout.alignment: Qt.AlignHCenter
                    visible: !video1.videoLoaded

                    onClicked: {
                        fileDialogs.videoIndex = 1
                        fileDialogs.open()
                    }
                }

                Button {
                    visible: !video1.videoLoaded
                    text: "Descargar desde Youtube"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: youtubeDialog.open()

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
                to: 100000
                first.value: 0
                second.value: video1.duration / 1000
                first.onMoved: { video1.seek(first.value * 1000) }
                second.onMoved: { video1.finalTime = second.value * 1000; }
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
