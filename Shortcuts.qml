// Shortcuts.qml
import QtQuick
Item {
    
    Shortcut{
        sequence: "."
        onActivated: {
            mainWindow.nextFrame()
        }
    }

    Shortcut{
        sequence: ","
        onActivated: {
            mainWindow.previousFrame()
        }
    }

    Shortcut{
        sequence: "Space"
        onActivated: {
            playAll()
        }
    }
}