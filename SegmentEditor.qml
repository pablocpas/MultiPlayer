import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: segmentEditor
    width: 600
    height: 400
    title: "Editar Segmentos"

    property var segments
    signal segmentsUpdated(var segments)

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Text {
            text: "Editar Segmentos"
            font.pixelSize: 20
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Configura la lista de segmentos que quieres visualizar"
            font.pixelSize: 12
            Layout.alignment: Qt.AlignHCenter
        }

        ListView {
            id: segmentListView
            Layout.preferredWidth: 300
            Layout.preferredHeight: 200
            Layout.alignment: Qt.AlignHCenter
            model: ListModel {
                id: segmentListModel
            }
            delegate: Item {
                height: 40
                width: 400

                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: (index + 1) + "."
                        font.pixelSize: 18
                        width: 30
                        Layout.alignment: Qt.AlignVCenter
                    }

                    TextField {
                        id: nameField
                        text: model.name
                        Layout.fillWidth: true

                        onTextChanged: {
                            if (nameField.text !== model.name) {
                                segmentListModel.setProperty(index, "name", nameField.text)
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
                text: "Agregar Segºento"
                onClicked: {
                    segmentListModel.append({"name": "Nuevo segmento"})
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

    function saveSegments() {
        let segmentsArray = []
        for (let i = 0; i < segmentListModel.count; i++) {
            segmentsArray.push(segmentListModel.get(i))
        }
        segmentEditor.segments = segmentsArray
        segmentEditor.segmentsUpdated(segmentsArray)  // Emitir la señal con los segmentos actualizados
        segmentEditor.visible = false

        mainWindow.hasSegments = true

    }
}
