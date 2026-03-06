/*
 * edpearOS SDDM Login Theme
 * Tokyo Night dark theme — minimal, clean, modern
 */
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root

    readonly property color bgColor:      "#1a1b26"
    readonly property color surfaceColor:  "#24283b"
    readonly property color borderColor:   "#414868"
    readonly property color fgColor:       "#c0caf5"
    readonly property color fgDimColor:    "#565f89"
    readonly property color accentColor:   "#7aa2f7"
    readonly property color errorColor:    "#f7768e"
    readonly property color greenColor:    "#9ece6a"

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() {
            errorMessage.text = ""
            loginButton.enabled = true
        }
        function onLoginFailed() {
            errorMessage.text = "Incorrect password"
            passwordField.text = ""
            loginButton.enabled = true
            errorAnimation.running = true
        }
    }

    // Background
    color: bgColor

    // Wallpaper image (falls back to solid color)
    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background || ""
        fillMode: Image.PreserveAspectCrop
        opacity: 0.3
        visible: status === Image.Ready
    }

    // Dark overlay on wallpaper
    Rectangle {
        anchors.fill: parent
        color: bgColor
        opacity: wallpaper.visible ? 0.7 : 1.0
    }

    // Subtle accent glow behind login box
    Rectangle {
        anchors.centerIn: loginBox
        width: loginBox.width + 120
        height: loginBox.height + 120
        radius: 80
        color: accentColor
        opacity: 0.02
    }

    // ── Clock (top right) ──
    ColumnLayout {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        spacing: 2

        Text {
            Layout.alignment: Qt.AlignRight
            text: Qt.formatTime(new Date(), "h:mm AP")
            font.pixelSize: 42
            font.weight: Font.Light
            font.family: "Noto Sans"
            color: fgColor
        }
        Text {
            Layout.alignment: Qt.AlignRight
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
            font.pixelSize: 14
            font.family: "Noto Sans"
            color: fgDimColor
        }
    }

    // Timer to update clock
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {} // QML re-evaluates bindings automatically
    }

    // ── Login Box (centered) ──
    Rectangle {
        id: loginBox
        anchors.centerIn: parent
        width: 380
        height: loginColumn.implicitHeight + 80
        radius: 16
        color: Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.85)
        border.width: 1
        border.color: Qt.rgba(borderColor.r, borderColor.g, borderColor.b, 0.3)

        // Subtle inner shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 15
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.03)
        }

        ColumnLayout {
            id: loginColumn
            anchors.centerIn: parent
            width: parent.width - 60
            spacing: 16

            // Logo
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "edpearOS"
                font.pixelSize: 28
                font.weight: Font.Bold
                font.letterSpacing: 1.5
                font.family: "JetBrains Mono Nerd Font,JetBrains Mono,Noto Sans,monospace"
                color: fgColor
            }

            // Tagline
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "The Modern Student Desktop"
                font.pixelSize: 11
                font.family: "Noto Sans"
                color: fgDimColor
            }

            // Spacer
            Item { Layout.preferredHeight: 8 }

            // Username field
            TextField {
                id: usernameField
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                placeholderText: "Username"
                text: userModel.lastUser
                font.pixelSize: 14
                font.family: "Noto Sans"
                color: fgColor
                horizontalAlignment: TextInput.AlignHCenter

                background: Rectangle {
                    radius: 10
                    color: bgColor
                    border.width: usernameField.activeFocus ? 2 : 1
                    border.color: usernameField.activeFocus ? accentColor : borderColor
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }

                Keys.onReturnPressed: passwordField.forceActiveFocus()
                Keys.onTabPressed: passwordField.forceActiveFocus()
            }

            // Password field
            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.pixelSize: 14
                font.family: "Noto Sans"
                color: fgColor
                horizontalAlignment: TextInput.AlignHCenter

                background: Rectangle {
                    radius: 10
                    color: bgColor
                    border.width: passwordField.activeFocus ? 2 : 1
                    border.color: passwordField.activeFocus ? accentColor : borderColor
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }

                Keys.onReturnPressed: doLogin()
            }

            // Error message
            Text {
                id: errorMessage
                Layout.alignment: Qt.AlignHCenter
                text: ""
                font.pixelSize: 12
                font.family: "Noto Sans"
                color: errorColor
                opacity: text.length > 0 ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                SequentialAnimation {
                    id: errorAnimation
                    PropertyAnimation {
                        target: errorMessage; property: "x"
                        from: errorMessage.x - 10; to: errorMessage.x + 10
                        duration: 50
                    }
                    PropertyAnimation {
                        target: errorMessage; property: "x"
                        from: errorMessage.x + 10; to: errorMessage.x
                        duration: 50
                    }
                }
            }

            // Login button
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: "Log In"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                font.family: "Noto Sans"

                contentItem: Text {
                    text: loginButton.text
                    font: loginButton.font
                    color: bgColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 10
                    color: loginButton.down ? Qt.darker(accentColor, 1.2) :
                           loginButton.hovered ? Qt.lighter(accentColor, 1.1) : accentColor
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                onClicked: doLogin()
            }

            // Session selector (hidden — single session)
            ComboBox {
                id: sessionBox
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
                visible: false
                width: 0; height: 0
            }
        }
    }

    // ── Power buttons (bottom right) ──
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 30
        spacing: 16

        // Suspend
        ToolButton {
            id: suspendBtn
            visible: sddm.canSuspend
            icon.name: "system-suspend"
            icon.color: fgDimColor
            onClicked: sddm.suspend()

            background: Rectangle {
                radius: 8
                color: suspendBtn.hovered ? Qt.rgba(1,1,1,0.05) : "transparent"
                implicitWidth: 40; implicitHeight: 40
            }

            ToolTip.visible: hovered
            ToolTip.text: "Suspend"
        }

        // Restart
        ToolButton {
            id: rebootBtn
            visible: sddm.canReboot
            icon.name: "system-reboot"
            icon.color: fgDimColor
            onClicked: sddm.reboot()

            background: Rectangle {
                radius: 8
                color: rebootBtn.hovered ? Qt.rgba(1,1,1,0.05) : "transparent"
                implicitWidth: 40; implicitHeight: 40
            }

            ToolTip.visible: hovered
            ToolTip.text: "Restart"
        }

        // Shutdown
        ToolButton {
            id: shutdownBtn
            visible: sddm.canPowerOff
            icon.name: "system-shutdown"
            icon.color: fgDimColor
            onClicked: sddm.powerOff()

            background: Rectangle {
                radius: 8
                color: shutdownBtn.hovered ? Qt.rgba(1,1,1,0.05) : "transparent"
                implicitWidth: 40; implicitHeight: 40
            }

            ToolTip.visible: hovered
            ToolTip.text: "Shut Down"
        }
    }

    // ── Hostname (bottom left) ──
    Text {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 30
        text: sddm.hostName
        font.pixelSize: 11
        font.family: "Noto Sans"
        color: fgDimColor
        opacity: 0.6
    }

    // ── Login function ──
    function doLogin() {
        loginButton.enabled = false
        errorMessage.text = ""
        sddm.login(usernameField.text, passwordField.text, sessionBox.currentIndex)
    }

    // Focus password field on load
    Component.onCompleted: {
        if (usernameField.text.length > 0) {
            passwordField.forceActiveFocus()
        } else {
            usernameField.forceActiveFocus()
        }
    }
}
