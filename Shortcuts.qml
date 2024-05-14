// Shortcuts.qml
import QtQuick
Item {
    
    Shortcut{
        sequence: "."
        onActivated: {
            video0.nextFrame()
            video1.nextFrame()
        }
    }

    Shortcut{
        sequence: ","
        onActivated: {
            video0.previousFrame()
            video1.previousFrame()
        }
    }

    Shortcut{
        sequence: "Space"
        onActivated: {
            playAll()
        }
    }
}