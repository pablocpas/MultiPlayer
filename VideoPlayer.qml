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
        //relative source
        mediaPlayer.source =  path;
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
        console.log("pausaddoooo")
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
