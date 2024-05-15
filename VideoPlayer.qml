// VideoPlayer.qml

import QtQuick
import QtMultimedia

Item {
    property string ruta: "" // ruta para la ruta del vídeo
    readonly property int duration: mediaPlayer.duration
    property int finalTime: 0 // Nuevo: tiempo final de reproducción
    property int initialTime: 0 // Nuevo: tiempo inicial de reproducción
    property bool videoLoaded: false
    property int position: mediaPlayer.position

    MediaPlayer {
        id: mediaPlayer
        source: ruta
        videoOutput: videoOut

        onPositionChanged: {
            if (mediaPlayer.position >= finalTime) {
                mediaPlayer.position = initialTime;
                
            }
        }

        onDurationChanged: {
            finalTime = mediaPlayer.duration - 1000;
        }
    }

    VideoOutput {
        id: videoOut
        anchors.fill: parent
    }

    function setPath(path) {
        console.log("Cambiando la ruta del vídeo a: " + path);
        //relative source
        mediaPlayer.source = "./" + path;
        mediaPlayer.play();
    }

    function play() {

        // Hace play si esta parado y pause si está reproduciendo
        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
            mediaPlayer.pause();
        } else {
            mediaPlayer.play();
        }

    }

    function stop() {
        mediaPlayer.stop();
    }

    function pause() {
        mediaPlayer.pause();
    }

    function seek(position) {
        mediaPlayer.position = position;
    }

    function nextFrame() {
        mediaPlayer.position += 1000 / mediaPlayer.metaData.value(17);
    }

    function previousFrame() {
        mediaPlayer.position -= 1000 / mediaPlayer.metaData.value(17);
    }

}
