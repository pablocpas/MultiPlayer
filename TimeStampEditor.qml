import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: timestampEditor
    width: 900
    height: 400
    title: "Editar Timestamps de Segmentos"
    visible: false

    property var segments
    property string videoPath: ""
    property string texto: ""
    property string path: ""

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        anchors.topMargin: 30
        anchors.bottomMargin: 30
        spacing: 90

        // Primera columna: ListView
        ColumnLayout {
            width: parent.width / 2

            ListView {
                id: segmentListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 300
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
                            Layout.preferredWidth: 60
                            inputMask: "99:99"  // Máscara de entrada para asegurar el formato 00:00
                            validator: RegularExpressionValidator { regularExpression: /^(?:[0-5][0-9]):[0-5][0-9]$/ }  // Validador para reforzar el formato de tiempo correcto
                            onTextChanged: {
                                if (timestampField.text !== model.timestamp) {
                                    segmentListModel.setProperty(index, "timestamp", timestampField.text)
                                }
                            }
                        }

                        Button {
                            text: "Copiar"
                            onClicked: {
                                let time = incrustado.position;
                                let minutes = Math.floor(time / 60000);
                                let seconds = Math.floor((time % 60000) / 1000);
                                let formattedTime = (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds);
                                segmentListModel.setProperty(index, "timestamp", formattedTime);
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
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Slider {
                    id: progressSlider
                    width: 400
                    Layout.preferredWidth: 380
                    from: 0
                    to: incrustado.duration
                    value: incrustado.position
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
                    text: "Guardar"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        saveTimestamps()
                        timestampEditor.visible = false
                    }
                }
            }
        }
    }

    function saveTimestamps() {
        let segmentsArray = []
        for (let i = 0; i < segmentListModel.count; i++) {
            segmentsArray.push(segmentListModel.get(i))
        }
        timestampEditor.segments = segmentsArray
        timestampEditor.visible = false

        videoPlayerComponent.setSegments(segmentsArray)

        //show video name
        console.log("video name: " + videoPlayerComponent.videoName)
    }

    function updateSegments(newSegments) {
        segments = newSegments
        segmentListModel.clear()
        console.log("segments numero: " + segments.length)
        for (var i = 0; i < segments.length; i++) {
            segmentListModel.append(segments[i])
            segmentListModel.setProperty(i, "timestamp", "00:00")
        }
    }

    function formatTime(ms) {
        let totalSeconds = Math.floor(ms / 1000);
        let minutes = Math.floor(totalSeconds / 60);
        let seconds = totalSeconds % 60;
        return (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds);
    }

    onVisibleChanged: {
        if (visible) {
            incrustado.seek(0)
            incrustado.pause()
        }
    }
}
