//Cell.qml

import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts
        
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
                    rangeSlider.first.value = 0
                    rangeSlider.to = video0.duration / 1000 // Actualiza 'to' en segundos
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
                    video0.initialTime = first.value * 1000; // Actualiza el tiempo inicial
                }

                // Actualiza la posición del vídeo cuando se mueve el segundo handle
                second.onMoved: {
                    video0.finalTime = second.value * 1000; // Actualiza el tiempo final
                }

            }
        }