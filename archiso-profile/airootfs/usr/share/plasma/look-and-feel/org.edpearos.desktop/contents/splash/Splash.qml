/*
 * edpearOS — Boot Splash Screen
 * Tokyo Night themed splash with fade-in animation
 */
import QtQuick 2.15
import QtQuick.Window 2.15

Rectangle {
    id: root
    color: "#1a1b26"
    anchors.fill: parent

    property int stage: 0

    onStageChanged: {
        if (stage === 1) {
            introAnimation.running = true;
        }
    }

    // Subtle background gradient overlay
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1b26" }
            GradientStop { position: 0.5; color: "#16161e" }
            GradientStop { position: 1.0; color: "#1a1b26" }
        }
    }

    // Main content column
    Item {
        id: content
        anchors.centerIn: parent
        width: 400
        height: 200
        opacity: 0

        // Logo text
        Text {
            id: logoText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            text: "edpearOS"
            font.family: "JetBrains Mono Nerd Font,JetBrains Mono,Noto Sans,sans-serif"
            font.pixelSize: 48
            font.weight: Font.Bold
            font.letterSpacing: 2
            color: "#c0caf5"
        }

        // Tagline
        Text {
            id: tagline
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: logoText.bottom
            anchors.topMargin: 8
            text: "The Modern Student Desktop"
            font.family: "Noto Sans,sans-serif"
            font.pixelSize: 14
            font.weight: Font.Normal
            color: "#565f89"
        }

        // Loading bar
        Rectangle {
            id: progressBarBg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: tagline.bottom
            anchors.topMargin: 40
            width: 200
            height: 3
            radius: 2
            color: "#24283b"

            Rectangle {
                id: progressBar
                anchors.left: parent.left
                anchors.top: parent.top
                height: parent.height
                radius: 2
                color: "#7aa2f7"
                width: 0

                Behavior on width {
                    NumberAnimation {
                        duration: 800
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    // Accent glow (subtle)
    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -20
        width: 300
        height: 300
        radius: 150
        color: "transparent"
        opacity: 0.03
        border.width: 0

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#7aa2f7" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            opacity: 0.15
        }
    }

    // Animation sequence
    SequentialAnimation {
        id: introAnimation

        // Fade in content
        ParallelAnimation {
            PropertyAnimation {
                target: content
                property: "opacity"
                from: 0; to: 1
                duration: 600
                easing.type: Easing.OutCubic
            }
        }

        // Progress bar fills through stages
        PropertyAnimation {
            target: progressBar
            property: "width"
            from: 0; to: 60
            duration: 400
        }

        PauseAnimation { duration: 200 }

        PropertyAnimation {
            target: progressBar
            property: "width"
            to: 130
            duration: 500
        }

        PauseAnimation { duration: 300 }

        PropertyAnimation {
            target: progressBar
            property: "width"
            to: 200
            duration: 400
        }
    }
}
