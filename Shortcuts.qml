// Shortcuts.qml
import QtQuick

/**
 * Componente para definir los atajos de teclado.
 */
Item {
    /**
     * Atajo para avanzar al siguiente cuadro.
     * Secuencia: "."
     */
    Shortcut {
        sequence: "."
        onActivated: {
            mainWindow.nextFrame()
        }
    }

    /**
     * Atajo para retroceder al cuadro anterior.
     * Secuencia: ","
     */
    Shortcut {
        sequence: ","
        onActivated: {
            mainWindow.previousFrame()
        }
    }

    /**
     * Atajo para reproducir todos los videos.
     * Secuencia: "Space"
     */
    Shortcut {
        sequence: "Space"
        onActivated: {
            playAll()
        }
    }

    /**
     * Atajo para establecer el número de reproductores a 2.
     * Secuencia: "Ctrl+2"
     */
    Shortcut {
        sequence: "Ctrl+2"
        onActivated: {
            mainWindow.numberOfPlayers = 2
        }
    }

    /**
     * Atajo para establecer el número de reproductores a 3.
     * Secuencia: "Ctrl+3"
     */
    Shortcut {
        sequence: "Ctrl+3"
        onActivated: {
            mainWindow.numberOfPlayers = 3
        }
    }

    /**
     * Atajo para establecer el número de reproductores a 4.
     * Secuencia: "Ctrl+4"
     */
    Shortcut {
        sequence: "Ctrl+4"
        onActivated: {
            mainWindow.numberOfPlayers = 4
        }
    }

    /**
     * Atajo para alternar entre pantalla completa y ventana.
     * Secuencia: "Ctrl+F"
     */
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: {
            mainWindow.isFullScreen = !mainWindow.isFullScreen
        }
    }

    /**
     * Atajo para reproducir el siguiente segmento.
     * Secuencia: "Ctrl+Right"
     */
    Shortcut {
        sequence: "Ctrl+Right"
        onActivated: {
            mainWindow.playNextSegment()
            mainWindow.nextSegment()
        }
    }

    /**
     * Atajo para reproducir el segmento anterior.
     * Secuencia: "Ctrl+Left"
     */
    Shortcut {
        sequence: "Ctrl+Left"
        onActivated: {
            mainWindow.playPreviousSegment()
            mainWindow.previousSegment()
        }
    }

    /**
     * Atajo para mostrar el editor de segmentos.
     * Secuencia: "Ctrl+S"
     */
    Shortcut {
        sequence: "Ctrl+S"
        onActivated: {
            mainWindow.setSegmentEditorVisibility(true)
        }
    }
}
