// VideoPlayer.qml

import QtQuick
import QtMultimedia

Item {
    property string propiedad: "" // Propiedad para la ruta del vídeo

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
}
