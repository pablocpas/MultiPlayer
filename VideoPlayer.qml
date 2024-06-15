// VideoPlayer.qml

import QtQuick
import QtMultimedia

Item {
    property string ruta: "" // ruta para la ruta del vídeo
    property int duration: mediaPlayer.duration
    property int finalTime: 0 // Nuevo: tiempo final de reproducción
    property int initialTime: 0 // Nuevo: tiempo inicial de reproducción
    property bool videoLoaded: false
    property int position: mediaPlayer.position
    property real playbackRate: 1.0 // Nuevo: tasa de reproducción

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
            if (mediaPlayer.position >= finalTime) {
                    mediaPlayer.stop();
            }
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

    function setPath(path) {
        console.log("Cambiando la ruta del vídeo a: " + path);
        mediaPlayer.source = path;
        mediaPlayer.play();
    }

    function play() {
        mediaPlayer.play();
    }

    function stop() {
        mediaPlayer.stop();
    }

    function pause() {
        mediaPlayer.pause();
        console.log("pausado")
    }

    function seek(position) {
        //si la posición se va fuera del rango, se detiene el video
        if (position < 0 || position > mediaPlayer.duration) {
            mediaPlayer.stop();
        }else{
            mediaPlayer.position = position;
        
        }
    }

    function nextFrame() {
        mediaPlayer.position += 1000 / mediaPlayer.metaData.value(17);
    }

    function previousFrame() {
        mediaPlayer.position -= 1000 / mediaPlayer.metaData.value(17);
    }

    function setPlaybackRate(rate) { // Nuevo: función para cambiar la velocidad de reproducción
        mediaPlayer.playbackRate = rate;
    }

    // Opcional: Métodos para cambiar a velocidades específicas
    function playNormalSpeed() {
        setPlaybackRate(1.0);
    }

    function playHalfSpeed() {
        setPlaybackRate(0.5);
    }

    function playQuarterSpeed() {
        setPlaybackRate(0.25);
    }

    function playOneAndHalfSpeed() {
        setPlaybackRate(1.5);
    }

    function playDoubleSpeed() {
        setPlaybackRate(2.0);
    }
}
