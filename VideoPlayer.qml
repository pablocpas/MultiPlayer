// VideoPlayer.qml

import QtQuick
import QtMultimedia

Item {
    property string propiedad: "" // Propiedad para la ruta del vídeo
    readonly property int duration: mediaPlayer.duration
    property int finalTime: 0 // Nuevo: tiempo final de reproducción
    property int initialTime: 0 // Nuevo: tiempo inicial de reproducción

    MediaPlayer {
        id: mediaPlayer
        source: propiedad
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

}
