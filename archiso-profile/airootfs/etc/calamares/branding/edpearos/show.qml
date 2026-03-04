/* edpearOS Calamares Installer QML Slideshow */
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1b26"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "🎓 Welcome to edpearOS"
                    color: "#c0caf5"
                    font.pixelSize: 32
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "The Modern Student Desktop"
                    color: "#7aa2f7"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Built on Arch Linux for academic productivity.\nPre-configured with everything you need to succeed."
                    color: "#a9b1d6"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    width: 400
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1b26"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "🎯 Focus Mode"
                    color: "#c0caf5"
                    font.pixelSize: 28
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "One-click to block distractions.\n\n• Silences notifications (Do Not Disturb)\n• Blocks social media & streaming sites\n• Enables blue light filter for night study\n\nToggle with Super + F or from the app menu."
                    color: "#a9b1d6"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    width: 420
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1b26"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "📚 Student Productivity Stack"
                    color: "#c0caf5"
                    font.pixelSize: 28
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Pre-installed and ready to go:\n\n• Obsidian — Markdown notes & knowledge base\n• Zotero — Citation & reference manager\n• LibreOffice — Documents, spreadsheets, presentations\n• VS Code — Code editor for CS students\n• Firefox & Chromium — Web browsers\n• LaTeX — Professional document typesetting"
                    color: "#a9b1d6"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    width: 420
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1b26"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "🖥 Dual Desktop Modes"
                    color: "#c0caf5"
                    font.pixelSize: 28
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Choose your workflow at login:\n\n• KDE Plasma — Full desktop with panels, widgets,\n  and a familiar feel. Great for general use.\n\n• Hyprland — Tiling window manager for power users.\n  Textbook on the left, notes on the right.\n  Keyboard-driven productivity."
                    color: "#a9b1d6"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    width: 420
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1a1b26"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "⌨ Smart Shortcuts"
                    color: "#c0caf5"
                    font.pixelSize: 28
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Pre-configured for students:\n\nSuper + N  →  Notes (Obsidian)\nSuper + C  →  Calculator\nSuper + T  →  Terminal\nSuper + E  →  File Manager\nSuper + F  →  Toggle Focus Mode\nSuper + B  →  Browser (Firefox)\nSuper + Space → App Launcher"
                    color: "#a9b1d6"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    width: 420
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "JetBrains Mono"
                }
            }
        }
    }
}
