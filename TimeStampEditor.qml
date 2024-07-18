// TimeStampEditor.qml

/** \addtogroup frontend
 * @{
 */


import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * Ventana para editar los timestamps de los segmentos de video.
 */
Window {
    id: timestampEditor
    width: 950
    height: 400
    title: "Editar Timestamps de Segmentos"
    visible: false

    /** type:var Lista de segmentos */
    property var segments
    /** type:string Ruta del video */
    property string videoPath: ""
    /** type:string Texto descriptivo */
    property string texto: ""
    /** type:string Ruta adicional */
    property string path: ""

    Shortcut {
        sequence: "."
        /**
         * Avanza al siguiente cuadro del video cuando se presiona el atajo.
         */
        onActivated: {
            incrustado.nextFrame()
        }
    }

    Shortcut {
        sequence: ","
        /**
         * Retrocede al cuadro anterior del video cuando se presiona el atajo.
         */
        onActivated: {
            incrustado.previousFrame()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        anchors.topMargin: 30
        anchors.bottomMargin: 30
        spacing: 90

        // Primera columna: ListView
        ColumnLayout {
            spacing: 10

            Text {
                text: "Selecciona el tiempo de inicio de cada segmento"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            ListView {
                id: segmentListView
                Layout.fillWidth: true
                Layout.fillHeight: true

                model: ListModel {
                    id: segmentListModel
                }
                delegate: Item {
                    height: 40

                    RowLayout {
                        spacing: 10

                        Text {
                            text: (index + 1) + "."
                            font.pixelSize: 16
                            width: 30
                            Layout.alignment: Qt.AlignVCenter
                        }

                        TextField {
                            id: nameField
                            text: model.description
                            readOnly: true
                            Layout.fillWidth: true
                        }

                        TextField {
                            id: timestampField
                            text: model.timestamp
                            Layout.preferredWidth: 80
                            inputMask: "99:99:999"  // Máscara de entrada para asegurar el formato 00:00:000
                            validator: RegularExpressionValidator { regularExpression: /^(?:[0-5][0-9]):[0-5][0-9]:[0-9]{3}$/ }  // Validador para reforzar el formato de tiempo correcto
                            onTextChanged: {
                                if (timestampField.text !== model.timestamp) {
                                    let timestampInSeconds = timeToSeconds(timestampField.text);
                                    segmentListModel.setProperty(index, "timestamp", timestampField.text);
                                    segmentListModel.setProperty(index, "timestampInSeconds", timestampInSeconds);
                                    updateDurations();
                                }
                            }
                        }

                        Button {
                            text: "Copiar"
                            /**
                             * Copia la posición actual del video al campo de timestamp.
                             */
                            onClicked: {
                                let time = incrustado.position;
                                let timestampInSeconds = time / 1000;
                                let minutes = Math.floor(time / 60000);
                                let seconds = Math.floor((time % 60000) / 1000);
                                let milliseconds = time % 1000;
                                let formattedTime = (minutes < 10 ? "0" + minutes : minutes) + ":" + 
                                                    (seconds < 10 ? "0" + seconds : seconds) + ":" + 
                                                    (milliseconds < 100 ? (milliseconds < 10 ? "00" + milliseconds : "0" + milliseconds) : milliseconds);
                                segmentListModel.setProperty(index, "timestamp", formattedTime);
                                segmentListModel.setProperty(index, "timestampInSeconds", timestampInSeconds);
                                updateDurations();
                            }
                        }
                    }
                }
            }
        }

        // Segunda columna: Rectángulo y Slider
        ColumnLayout {
                width: parent.width / 2
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillWidth: true

                VideoPlayer {
                    id: incrustado
                    height: 380
                    width: 200
                    ruta: videoPath
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    spacing: 10

                    Slider {
                        id: progressSlider
                        width: 400
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 380
                        from: 0
                        to: incrustado.duration
                        value: incrustado.position
                        /**
                        * Actualiza la posición del video y el indicador de tiempo al cambiar el valor del slider.
                        */
                        onValueChanged: {
                            incrustado.seek(progressSlider.value)
                            timeIndicator.text = formatTime(progressSlider.value)
                        }
                    }

                    Text {
                        id: timeIndicator
                        text: formatTime(progressSlider.value)
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Botón de guardar
                RowLayout {
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "Anterior fotograma"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            incrustado.previousFrame()
                        }
                    }

                    Button {
                        text: "Siguiente fotograma"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            incrustado.nextFrame()
                        }
                    }

                    Button {
                        text: "Guardar"
                        Layout.alignment: Qt.AlignHCenter
                        /**
                        * Guarda los timestamps y cierra el editor.
                        */
                        onClicked: {
                            saveTimestamps()
                            timestampEditor.visible = false
                        }
                    }
                }
            }

    }

    /**
     * Guarda los timestamps actuales en el modelo de segmentos y actualiza el reproductor de video.
     */
    function saveTimestamps() {
        let segmentsArray = []
        for (let i = 0; i < segmentListModel.count; i++) {
            segmentsArray.push(segmentListModel.get(i))
        }
        timestampEditor.segments = segmentsArray
        timestampEditor.visible = false

        videoPlayerComponent.setSegments(segmentsArray)
        mainWindow.setSegments(segmentsArray, videoPlayerComponent.playerIndex)
    }

    /**
     * Actualiza los segmentos en el editor con los nuevos segmentos proporcionados.
     * @param type:var newSegments Nuevos segmentos.
     */
    function updateSegments(newSegments) {
        segments = newSegments
        segmentListModel.clear()
        for (var i = 0; i < segments.length; i++) {
            segmentListModel.append(segments[i])
            segmentListModel.setProperty(i, "timestamp", "00:00:000")
            segmentListModel.setProperty(i, "timestampInSeconds", 0)
        }
    }

    /**
     * Formatea el tiempo en milisegundos a un string en el formato mm:ss:SSS.
     * @param type:int ms Tiempo en milisegundos.
     * @return type:string Tiempo formateado.
     */
    function formatTime(ms) {
        let totalSeconds = Math.floor(ms / 1000);
        let minutes = Math.floor(totalSeconds / 60);
        let seconds = totalSeconds % 60;
        let milliseconds = Math.floor(ms % 1000); // Truncar los milisegundos a tres dígitos
        return (minutes < 10 ? "0" + minutes : minutes) + ":" + 
               (seconds < 10 ? "0" + seconds : seconds) + ":" + 
               (milliseconds < 100 ? (milliseconds < 10 ? "00" + milliseconds : "0" + milliseconds) : milliseconds);
    }

    /**
     * Convierte el tiempo en formato mm:ss:SSS a segundos.
     * @param type:string time Tiempo en formato mm:ss:SSS.
     * @return type:real Tiempo en segundos.
     */
    function timeToSeconds(time) {
        let parts = time.split(":");
        return parseInt(parts[0]) * 60 + parseInt(parts[1]) + parseInt(parts[2]) / 1000;
    }

    /**
     * Actualiza la duración de cada segmento basado en los timestamps.
     */
    function updateDurations() {
        let count = segmentListModel.count;
        let videoDurationInSeconds = incrustado.duration / 1000;
        for (let i = 0; i < count; i++) {
            let currentTimestamp = segmentListModel.get(i).timestampInSeconds;
            let nextTimestamp = (i + 1 < count) ? segmentListModel.get(i + 1).timestampInSeconds : null;
            let duration;

            if (nextTimestamp) {
                duration = nextTimestamp - currentTimestamp;
            } else {
                duration = videoDurationInSeconds - currentTimestamp;
            }
            segmentListModel.setProperty(i, "duration", duration);
        }
    }

    /**
     * Resetea el video al inicio y lo pausa al cambiar la visibilidad de la ventana.
     */
        onVisibleChanged: {
        if (visible) {
            incrustado.seek(0)
            incrustado.pause()
        }
    }

    /**
     * Inicializa la propiedad segmentsReady de mainWindow al completar el componente.
     */
    Component.onCompleted: {
        mainWindow.segmentsReady = 0
    }
}


/** @} */