import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Window {
    id: timestampEditor
    width: 800
    height: 600
    title: "Editar Timestamps de Segmentos"

    visible: false

    property var segments
    property string videoPath: ""
    property string texto: ""
    property string path: ""

    ColumnLayout {
        height: parent.height
        width: parent.width
        spacing: 10

        Text {
            text: texto
            font.pixelSize: 20
            Layout.alignment: Qt.AlignHCenter
        }

        VideoPlayer {
            id: incrustado
            height: timestampEditor.height / 2
            width: timestampEditor.height / 2
            ruta: videoPath
            Layout.alignment: Qt.AlignCenter
        }

        Slider {
            id: progressSlider
            from: 0
            to: incrustado.duration
            value: incrustado.position
            onMoved: incrustado.seek(progressSlider.value)
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Layout.preferredWidth: incrustado.width
        }

        ListView {
            id: segmentListView
            Layout.preferredWidth: incrustado.width / 2
            Layout.preferredHeight: timestampEditor.height / 4

            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            model: ListModel {
                id: segmentListModel
            }
            delegate: Item {
                height: 40
                width: timestampEditor.width / 2

                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: (index + 1) + "."
                        font.pixelSize: 16
                        width: 30
                        Layout.alignment: Qt.AlignVCenter
                    }

                    TextField {
                        id: nameField
                        text: model.name
                        readOnly: true
                        Layout.fillWidth: true
                    }

                        TextField {
                            id: timestampField
                            text: model.timestamp
                            Layout.fillWidth: true
                            inputMask: "99:99"  // Input mask to ensure format 00:00
                            validator: RegularExpressionValidator { regularExpression: /^(?:[0-5][0-9]):[0-5][0-9]$/ }  // Validator to enforce proper time format

                            onTextChanged: {
                                if (timestampField.text !== model.timestamp) {
                                    segmentListModel.setProperty(index, "timestamp", timestampField.text)
                                }
                            }
                        }

                    Button {
                        text: "Copiar posición del vídeo"
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

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Button {
                text: "Guardar"
                onClicked: saveTimestamps()
            }
            Button {
                text: "Cancelar"
                onClicked: timestampEditor.visible = false
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

}
