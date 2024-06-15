//TopBar.qml

import QtQuick 6.5
import QtQuick.Controls.Basic
import QtQuick.Layouts

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
                    icon.source: "./images/split2.svg"
                    checkable: true
                    autoExclusive: true
                    ButtonGroup.group: toolButtonGroup
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    ToolTip.delay: 1000
                    ToolTip.timeout: 5000
                    ToolTip.visible: hovered
                    ToolTip.text: "2 reproductores"

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

                    onCheckedChanged: {
                        icon.source = checked ? "./images/split2_clicked.svg" : "./images/split2.svg"
                    }
                }

                ToolButton {
                    id: toolButton3
                    icon.source: "./images/split3.svg"
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"
                    checkable: true
                    autoExclusive: true
                    ButtonGroup.group: toolButtonGroup
                    Layout.fillHeight: true
                    Layout.fillWidth: true
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


                    onCheckedChanged: {
                        icon.source = checked ? "./images/split3_clicked.svg" : "./images/split3.svg"
                    }
                }

                ToolButton {
                    id: toolButton4
                    icon.source: "./images/split4.svg"
                    icon.width: 36
                    icon.height: 36
                    icon.color: "transparent"

                    checkable: true
                    autoExclusive: true
                    ButtonGroup.group: toolButtonGroup
                    Layout.fillHeight: true
                    Layout.fillWidth: true
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


                    onCheckedChanged: {
                        icon.source = checked ? "./images/split4_clicked.svg" : "./images/split4.svg"
                    }
                }

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