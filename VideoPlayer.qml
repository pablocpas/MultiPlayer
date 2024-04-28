// VideoPlayer.qml

import QtQuick
import QtMultimedia

Item {
    property string propiedad: "" // Propiedad para la ruta del vídeo
    readonly property int duration: mediaPlayer.duration
    property int finalTime: 0 // Nuevo: tiempo final de reproducción

    MediaPlayer {
        id: mediaPlayer
        source: propiedad
        videoOutput: videoOut

        onPositionChanged: {
            if (mediaPlayer.position >= finalTime) {
                mediaPlayer.stop();
            }
        }
    }

    VideoOutput {
        id: videoOut
        anchors.fill: parent
    }

    function play() {
        mediaPlayer.play();
        console.log("Reproduciendo: " + propiedad);
    }

    function stop() {
        mediaPlayer.stop();
    }

    function seek(position) {
        mediaPlayer.position = position;
    }

}
