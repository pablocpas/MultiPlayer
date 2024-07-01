// VideoPlayer.qml

/** \addtogroup frontend
 * @{
 */


import QtQuick
import QtMultimedia

/**
 * Componente de reproductor de video.
 */
Item {
    /** type:string Ruta para el vídeo */
    property string ruta: "" // ruta para la ruta del vídeo
    /** type:int Duración del vídeo */
    property int duration: mediaPlayer.duration
    /** type:int Tiempo final de reproducción */
    property int finalTime: 0 // Nuevo: tiempo final de reproducción
    /** type:int Tiempo inicial de reproducción */
    property int initialTime: 0 // Nuevo: tiempo inicial de reproducción
    /** type:bool Indica si el vídeo está cargado */
    property bool videoLoaded: false
    /** type:int Posición actual del vídeo */
    property int position: mediaPlayer.position
    /** type:real Tasa de reproducción */
    property real playbackRate: 1.0 // Nuevo: tasa de reproducción
    /** type:real Volumen del vídeo */
    property real volumen: 1

    MediaPlayer {
        id: mediaPlayer
        source: ruta
        videoOutput: videoOut
        playbackRate: playbackRate

        audioOutput: AudioOutput {
            id: audio
            volume: volumen
        }

        onPositionChanged: {
            //if (mediaPlayer.position >= finalTime) {
            //        mediaPlayer.stop();
            //}
        }

        onDurationChanged: {
            finalTime = mediaPlayer.duration - 1000;
            console.log(finalTime)
            duration = finalTime
        }
    }

    VideoOutput {
        id: videoOut
        anchors.fill: parent
    }

    /**
     * Establece la ruta del vídeo.
     * @param type:string path Ruta del vídeo.
     */
    function setPath(path) {
        console.log("Cambiando la ruta del vídeo a: " + path);
        mediaPlayer.source = path;
        mediaPlayer.play();
    }

    /**
     * Reproduce el vídeo.
     */
    function play() {
        mediaPlayer.play();
        mainWindow.playing()
    }

    /**
     * Detiene el vídeo.
     */
    function stop() {
        mediaPlayer.stop();
    }

    /**
     * Pausa el vídeo.
     */
    function pause() {
        mediaPlayer.pause();
        console.log("pausado")
        mainWindow.pausa()
    }

    /**
     * Busca una posición en el vídeo.
     * @param type:int position Posición en milisegundos.
     */
    function seek(position) {
        mediaPlayer.position = position;
    }

    /**
     * Avanza un cuadro en el vídeo.
     */
    function nextFrame() {
        mediaPlayer.position += 1000 / mediaPlayer.metaData.value(17);
    }

    /**
     * Retrocede un cuadro en el vídeo.
     */
    function previousFrame() {
        mediaPlayer.position -= 1000 / mediaPlayer.metaData.value(17);
    }

    /**
     * Cambia la velocidad de reproducción.
     * @param type:real rate Nueva tasa de reproducción.
     */
    function setPlaybackRate(rate) {
        mediaPlayer.playbackRate = rate;
    }

    /**
     * Reproduce el vídeo a velocidad normal.
     */
    function playNormalSpeed() {
        setPlaybackRate(1.0);
    }

    /**
     * Reproduce el vídeo a la mitad de la velocidad normal.
     */
    function playHalfSpeed() {
        setPlaybackRate(0.5);
    }

    /**
     * Reproduce el vídeo a una cuarta parte de la velocidad normal.
     */
    function playQuarterSpeed() {
        setPlaybackRate(0.25);
    }

    /**
     * Reproduce el vídeo a una vez y media la velocidad normal.
     */
    function playOneAndHalfSpeed() {
        setPlaybackRate(1.5);
    }

    /**
     * Reproduce el vídeo al doble de la velocidad normal.
     */
    function playDoubleSpeed() {
        setPlaybackRate(2.0);
    }
}

/** @} */