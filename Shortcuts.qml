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

    Shortcut{
        sequence: "Ctrl+2"
        onActivated: {
            mainWindow.numberOfPlayers = 2
        }
    }

    Shortcut{
        sequence: "Ctrl+3"
        onActivated: {
            mainWindow.numberOfPlayers = 3
        }
    }

    Shortcut{
        sequence: "Ctrl+4"
        onActivated: {
            mainWindow.numberOfPlayers = 4
        }
    }

    Shortcut{
        sequence: "Ctrl+F"
        onActivated: {
            mainWindow.isFullScreen = !mainWindow.isFullScreen
        }
    }

    Shortcut{
        sequence: "Ctrl+Right"
        onActivated: {
            mainWindow.playNextSegment()
            mainWindow.nextSegment()
        }
    }

    Shortcut{
        sequence: "Ctrl+Left"
        onActivated: {
            mainWindow.playPreviousSegment()
            mainWindow.previousSegment()
        }
    }

    Shortcut{
        sequence: "Ctrl+S"
        onActivated: {
            mainWindow.setSegmentEditorVisibility(true)
        }
    }


}