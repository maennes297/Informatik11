import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Layouts
import Quickshell.Widgets

FloatingWindow {
    //layer: Window.Overlay
    //focus: false
    //flags: QtFramelessWindowHint

    Rectangle {
        width: 300
        height: 200
        radius: 12
        color: "#000000ff"

        Text {
            anchors.centerIn: parent
            text: "helloWorld"
        }
    }
}