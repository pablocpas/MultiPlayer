import QtQuick 6.5
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Window {
    id: segmentEditor
    width: 1000
    height: 600
    title: "Editar Segmentos"
    

    visible: false

    property var segments: []
    property string videoPath: ""  // Ruta del vídeo

    signal segmentsUpdated(var segments)

    RowLayout {
        anchors.fill: parent
        spacing: 20

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Text {
                text: "Editar Segmentos del Vídeo"
                font.pixelSize: 20
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
                        Layout.fillWidth: true
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
                        TextField {
                            id: descriptionField
                            text: model.description
                            Layout.fillWidth: true

                            onTextChanged: {
                                if (descriptionField.text !== model.description) {
                                    segmentListModel.setProperty(index, "description", descriptionField.text)
                                }
                            }
                        }
                        Button {

                            text: "Eliminar"
                            onClicked: segmentListModel.remove(index)
                        }
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Button {
                    text: "Agregar Segmento"
                    onClicked: {
                        segmentListModel.append({"timestamp": "00:00", "description": "Nuevo segmento"})
                    }
                }
                Button {
                    text: "Guardar"
                    onClicked: saveSegments()
                }
                Button {
                    text: "Cancelar"
                    onClicked: segmentEditor.visible = false
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 400
            Layout.fillHeight: true
            spacing: 10

            VideoPlayer {
                id: videoPlayer
                height: 300
                width: 400
            }

            Slider {
                id: progressSlider
                from: 0
                to: videoPlayer.duration
                value: videoPlayer.position
                onMoved: videoPlayer.seek(progressSlider.value)
            }
        }
    }

    Component.onCompleted: {
        segmentListModel.clear()
        if (segments) {
            for (let i = 0; i < segments.length; i++) {
                segmentListModel.append(segments[i])
            }
        }
        videoPlayer.setPath(videoPath)
    }

    onVisibleChanged: {
        if (visible) {
            videoPlayer.setPath(videoPath)
            videoPlayer.pause()
        }
    }

    function saveSegments() {
        let segmentsArray = []
        for (let i = 0; i < segmentListModel.count; i++) {
            segmentsArray.push(segmentListModel.get(i))
        }
        segmentEditor.segments = segmentsArray
        segmentEditor.segmentsUpdated(segmentsArray)
        segmentEditor.visible = false
    }
}
