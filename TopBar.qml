// TopBar.qml

/** \addtogroup frontend
 * @{
 */


import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * Barra de herramientas superior del reproductor de video.
 */
ToolBar {
    id: toolBar
    x: 0
    y: 0
    Layout.fillWidth: true
    height: 45

    background: Rectangle {
        implicitHeight: 50
        color: "#161616"
        border.width: 1
        border.color: "#2b2b2b"
    }

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        ButtonGroup {
            id: toolButtonGroup
        }

        ToolButton {
            id: toolButton2
            icon.source: numberOfPlayers === 2 ? "./images/split2_clicked.svg" : "./images/split2.svg"
            checkable: true
            autoExclusive: true
            ButtonGroup.group: toolButtonGroup
            Layout.fillHeight: true
            Layout.fillWidth: true

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "2 reproductores"

            /**
             * Configura el número de reproductores a 2 y reinicia el estado de video.
             */
            onClicked: {
                numberOfPlayers = 2
                mainWindow.hasVideo = false
            }

            background: Rectangle {
                opacity: 0
            }
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
        }

        ToolButton {
            id: toolButton3
            icon.source: numberOfPlayers === 3 ? "./images/split3_clicked.svg" : "./images/split3.svg"
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
            checkable: true
            autoExclusive: true
            ButtonGroup.group: toolButtonGroup
            Layout.fillHeight: true
            Layout.fillWidth: true

            /**
             * Configura el número de reproductores a 3 y reinicia el estado de video.
             */
            onClicked: {
                numberOfPlayers = 3
                mainWindow.hasVideo = false
            }

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "3 reproductores"

            background: Rectangle {
                opacity: 0
            }
        }

        ToolButton {
            id: toolButton4
            icon.source: numberOfPlayers === 4 ? "./images/split4_clicked.svg" : "./images/split4.svg"
            icon.width: 36
            icon.height: 36
            icon.color: "transparent"
            checkable: true
            autoExclusive: true
            ButtonGroup.group: toolButtonGroup
            Layout.fillHeight: true
            Layout.fillWidth: true

            /**
             * Configura el número de reproductores a 4 y reinicia el estado de video.
             */
            onClicked: {
                numberOfPlayers = 4
                mainWindow.hasVideo = false
            }

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "4 reproductores"

            background: Rectangle {
                opacity: 0
            }
        }

        /**
         * Configura el botón correspondiente según el número de reproductores al completar el componente.
         */
        Component.onCompleted: {
            switch (numberOfPlayers) {
                case 2:
                    toolButton2.checked = true
                    break
                case 3:
                    toolButton3.checked = true
                    break
                case 4:
                    toolButton4.checked = true
                    break
            }
        }
    }
}

/** @} */