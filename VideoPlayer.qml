// VideoPlayer.qml

import QtQuick
import QtMultimedia

Item {
    property string propiedad: "" // Propiedad para la ruta del vídeo
    readonly property int duration: mediaPlayer.duration

    MediaPlayer {
        id: mediaPlayer
        source: propiedad
        videoOutput: videoOut
    }

    VideoOutput {
        id: videoOut
        anchors.fill: parent
    }

    function play() {
        mediaPlayer.play();
    }

    function stop() {
        mediaPlayer.stop();
    }

    function seek(position) {
        mediaPlayer.position = position;
    }

}
