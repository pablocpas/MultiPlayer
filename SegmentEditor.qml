// SegmentEditor.qml
import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs

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
        padding: 10

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
                        text: model.timestamp
                        Layout.fillWidth: true
                    }
                    TextField {
                        text: model.description
                        Layout.fillWidth: true
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
                    let segmentsArray = []
                    for (let i = 0; i < segmentListModel.count; i++) {
                        segmentsArray.push(segmentListModel.get(i))
                    }
                    segmentEditor.segments = segmentsArray
                    segmentEditor.segmentsUpdated(segmentsArray)
                    segmentEditor.close()
                }
            }
            Button {
                text: "Cancelar"
                onClicked: segmentEditor.close()
            }
        }
    }

    Component.onCompleted: {
        segmentListModel.clear()
        for (let i = 0; i < segments.length; i++) {
            segmentListModel.append(segments[i])
        }
    }
}
