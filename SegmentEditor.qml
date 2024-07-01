// segmentEditor.qml

/** \addtogroup frontend
 * @{
 */


import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * Ventana para editar los segmentos de video.
 */
Window {
    id: segmentEditor
    width: 600
    height: 400
    title: "Editar Segmentos"

    /** type:var Lista de segmentos */
    property var segments
    /**
     * Señal emitida cuando los segmentos son actualizados.
     * @param segments Lista de segmentos actualizados.
     */
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
                        /**
                         * Elimina el segmento actual de la lista.
                         */
                        onClicked: segmentListModel.remove(index)
                    }
                }

                /**
                 * Selecciona todo el texto del campo de nombre y enfoca el campo.
                 */
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
                /**
                 * Agrega un nuevo segmento a la lista.
                 */
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
                /**
                 * Guarda los segmentos actuales.
                 */
                onClicked: saveSegments()
            }
            Button {
                text: "Cancelar"
                /**
                 * Cancela la edición y cierra el editor de segmentos.
                 */
                onClicked: {
                    segmentEditor.visible = false
                    segmentListModel.clear()
                }
            }
        }
    }

    /**
     * Guarda los segmentos actuales en el modelo de segmentos y actualiza el estado de la ventana principal.
     */
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

/** @} */