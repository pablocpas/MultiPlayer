import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Layouts

Window {
    id: segmentEditor
    width: 400
    height: 600
    title: "Editar Segmentos"
    visible: false

    property var segments: []

    signal segmentsUpdated(var segments)

    ColumnLayout {
        anchors.fill: parent
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
                width: parent.width
                height: 40
                RowLayout {
                    spacing: 10
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

        Button {
            text: "Agregar Segmento"
            onClicked: {
                segmentListModel.append({"timestamp": "00:00", "description": "Nuevo segmento"})
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Button {
                text: "Guardar"
                onClicked: {
                    saveSegments()
                }
            }
            Button {
                text: "Cancelar"
                onClicked: segmentEditor.visible = false
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
    }

    function saveSegments() {
        let segmentsArray = []
        for (let i = 0; i < segmentListModel.count; i++) {
            segmentsArray.push(segmentListModel.get(i))
        }
        console.log("Saving segments:", segmentsArray) // Agregado para depuración
        segmentEditor.segments = segmentsArray
        segmentEditor.segmentsUpdated(segmentsArray)
        segmentEditor.visible = false
    }
}
