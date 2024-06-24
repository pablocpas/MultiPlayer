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
                id: item

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
                        text: model.description
                        Layout.fillWidth: true

                        onTextChanged: {
                            if (nameField.text !== model.description) {
                                segmentListModel.setProperty(index, "description", nameField.text)
                                segmentListModel.setProperty(index, "timestamp", "")
                            }
                        }
                    }
                    Button {
                        text: "Eliminar"
                        onClicked: segmentListModel.remove(index)
                    }
                }

                function selectAll() {
                    nameField.selectAll()
                    nameField.forceActiveFocus()
                }

            }

        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Button {
                text: "Agregar Segmento"
                onClicked: {
                    // Obtener el número del próximo segmento
                    let nextSegmentNumber = segmentListModel.count + 1;
                    segmentListModel.append({
                        "description": "Segmento " + nextSegmentNumber, 
                        "timestamp": ""
                    });

                        segmentListView.forceLayout(); // Actualiza el ListView

                        let newItem = segmentListView.itemAtIndex(segmentListModel.count - 1)
                        if (newItem) {
                            newItem.selectAll()
                        }
                }
            }
            Button {
                text: "Guardar"
                onClicked: saveSegments()
            }
            Button {
                text: "Cancelar"
                onClicked: {
                    segmentEditor.visible = false
                    segmentListModel.clear()
                }
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
