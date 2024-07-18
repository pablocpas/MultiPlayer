// main.qml

/** \addtogroup frontend
 * @{
 */

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls

ApplicationWindow {
    id: mainWindow
    visible: true
    color: "#1f1f1f"
    width: 1024
    height: 720
    title: qsTr("MultiVideoPlayer - Reproductor de Video")

    visibility: mainWindow.isFullScreen ? Window.FullScreen : Window.Windowed

    /** type:int Número de reproductores de video */
    property int numberOfPlayers: 2
    /** type:int Duración máxima del segmento */
    property int maxSegmentDuration: 0
    /** type:bool Indica si hay video */
    property bool hasVideo: false
    /** type:bool Indica si hay segmentos */
    property bool hasSegments: false

    /** type:var Lista de segmentos */
    property var segments: []
    /** type:int Índice del segmento actual */
    property int currentSegment: 0
    /** type:bool Indica si está en pantalla completa */
    property bool isFullScreen: false
    /** type:VideoPlayerComponent Referencia al reproductor de video más largo */
    property VideoPlayerComponent longestVideoPlayer: null
    /** type:double Velocidad de reproducción */
    property double speed: 1

    /** type:var Lista de los segmentos más largos */
    property var longest_segments: []
    /** type:var Lista de marcas de tiempo más largas */
    property var longest_timestamps: []
    /** type:var Lista de IDs de los reproductores de video más largos */
    property var longest_videoPlayerId: []

    /** type:int Cantidad de segmentos listos */
    property var segmentsReady: 0

    /**
     * Señal emitida cuando se está reproduciendo
     */
    signal playing()
    /**
     * Señal emitida cuando se pone en pausa
     */
    signal pausa()

    /**
     * Señal emitida cuando los segmentos están cargados
     * @param segments Lista de segmentos cargados
     */
    signal segmentsLoaded(var segments)

    /**
     * Señal emitida para reproducir todos los videos
     */
    signal playAll()
    /**
     * Señal emitida para pausar todos los videos
     */
    signal pauseAll()
    /**
     * Señal emitida para reproducir el siguiente segmento
     */
    signal playNextSegment()
    /**
     * Señal emitida para reproducir el segmento anterior
     */
    signal playPreviousSegment()
    /**
     * Señal emitida para buscar en todos los videos
     * @param value Valor de búsqueda en segundos
     */
    signal seekAll(int value)
    /**
     * Señal emitida para cambiar la velocidad de reproducción
     * @param speed Nueva velocidad de reproducción
     */
    signal speedChange(double speed)

    /**
     * Señal emitida para avanzar un cuadro
     */
    signal nextFrame()
    /**
     * Señal emitida para retroceder un cuadro
     */
    signal previousFrame()

    /** type:bool Indica si el editor de segmentos está visible */
    property bool segmentEditorVisible: false

    /** Componente ventana de descarga */
    Download {
        id: progressWindow
    }
    /** Componente ventana de exportación */
    Export {
        id: exportWindow
    }

    /** Componente ventana editor de segmentos */
    SegmentEditor {
        id: segmentEditor
    }

    /** Componente atajos de teclado */
    Shortcuts {}

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 15

        /** Componente barra superior */
        TopBar{
            id: topBar
            Layout.fillWidth: true
        }

        /** Reproductores de video */
        GridLayout {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: 10
            columnSpacing: 10
            Layout.preferredHeight: parent.height - 60

            Repeater {
                id: videoPlayersRepeater
                model: numberOfPlayers
                delegate: VideoPlayerComponent {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    playerIndex: index

                    Component.onCompleted: {
                        videoHandler.registerVideoPlayer(this, index)
                    }
                }
            }
        }

        /** Componente barra inferior */
        BottomBar {
            id: bottomBar
            Layout.fillWidth: true
        }
    }

    /** Botón de descarga */
    Button {
        icon.source: "./images/download.svg"
        visible: true
        anchors.centerIn: parent

        Layout.fillHeight: true
        Layout.fillWidth: true
        background: Rectangle {
            opacity: 0
        }
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: "Exportar vídeo combinado"

        icon.width: 36
        icon.height: 36
        icon.color: "transparent"
        enabled: mainWindow.hasVideo // Inactivo hasta que se añada un vídeo
        onClicked: {
            exportWindow.visible = true                
        }
    }

    Button {
        text: "Fusion"
        visible: false
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 46
        anchors.horizontalCenterOffset: -1
    }

    /**
     * Establece la visibilidad del editor de segmentos
     * @param type:bool visible Indica si el editor debe ser visible
     */
    function setSegmentEditorVisibility(visible) {
        segmentEditor.visible = visible
    }

    /**
     * Configura los segmentos
     * @param type:var segments Lista de segmentos
     * @param type:int index Índice del reproductor de video
     */
    function setSegments(segments, index) {
        this.segments = segments

        segmentsReady += 1
        console.log("Segments ready: " + segmentsReady)
        console.log("segments", segments)
        // Initialize longest_segments if empty or update with new segments
        if (longest_segments.length === 0) {
            longest_segments = segments.map(segment => segment.duration)
            longest_timestamps = segments.map(segment => segment.timestampInSeconds)

            longest_videoPlayerId = segments.map(segment => index)
        } else {
            for (let i = 0; i < segments.length; i++) {
                if (i < longest_segments.length) {
                    if (segments[i].duration > longest_segments[i]) {
                        longest_segments[i] = segments[i].duration
                        longest_timestamps[i] = segments[i].timestampInSeconds
                        longest_videoPlayerId[i] = index
                    }
                } else {
                    longest_segments.push(segments[i].duration)
                    longest_timestamps.push(segments[i].timestampInSeconds)
                    longest_videoPlayerId.push(index)
                }
            }
        }

        
        if (segmentsReady === numberOfPlayers) {
            playNextSegment()
            playPreviousSegment()
            bottomBar.updateCurrentSegment()
        }
    }

    function clearlongestSegments() {
        longest_segments = []
        longest_timestamps = []
        longest_videoPlayerId = []
        currentSegment = 0
        segmentsReady = 0
    }

    /**
     * Avanza al siguiente segmento
     */
    function nextSegment() {
        if(currentSegment < segments.length - 1){
            currentSegment++
            bottomBar.updateCurrentSegment()         

        }
    }

    /**
     * Retrocede al segmento anterior
     */
    function previousSegment() {
        if(currentSegment > 0){

            currentSegment--
            bottomBar.updateCurrentSegment()

        }
    }

    Connections {
        target: segmentEditor
        function onSegmentsUpdated(s) {
            segments = s
            segmentsLoaded(segments)
        }
    }
}

/** @} */