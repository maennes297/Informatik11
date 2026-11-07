import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Controls 
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris 
import Quickshell.Services.UPower

Scope {
	id:root
	property string gp: "p"
	property string time
	property string cpuUsage
	property string gpuUsage
	property string ramUsage
	property var rectangleColor: root.gp == "p"
		? '#dd3d0924'
		: '#b8b29d'
	property var borderColor: '#ffffffff'
	property real borderWidth: 1
	property string fontFamily: "BigBlueTerm437NerdFont"
	property var fontSize: 22
	property string textColor: root.gp == "p"
		? '#ff00d4'
		: '#4b413d'
	property string unfocusedTextColor: root.gp == "p"
		? '#aaaaaa'
		: '#706460'
	property string volume
	property bool dragging: false
	property real sliderPosition: 0
	property real target: 0
	property real radiusNumber: 5
	property real widgetHeight: 45
	property var player: Mpris.players.values.length > 0
    	? Mpris.players.values[0]
    	: null

	Connections {
		target: root

		function onMediaPositionChanged() {
			if (!dragging)
				root.sliderPosition = root.mediaPosition
		}
	}


	Variants {
		model: Quickshell.screens

		PanelWindow {
			required property var modelData
			screen: modelData
			id: bar

			anchors {
				top: true
				left: true
				right: true
			}

			
			implicitHeight: 50
			color: "#00000000"

			Rectangle {
				id: rectangleMedia
				width: 200
				height: root.widgetHeight
				color: root.rectangleColor
				radius: root.radiusNumber
				border {
					color: root.borderColor
					width: root.borderWidth
				}
				anchors.left: rectangleWorkspaces.right
				anchors.top: parent.top
				anchors.topMargin: 5
				anchors.leftMargin: 5
				clip: true
				MouseArea {
						anchors.fill: parent
						onClicked:{
							SourceComponent: Mpris.players.values.length > 0
								? popupMedia.visible = true
								: null
						}
					}
				Loader {
					anchors.fill: parent
					sourceComponent: Mpris.players.values.length > 0
						? playingComponent
						: stoppedComponent
				}

				Component{
					id: playingComponent

					Text {
						color: root.textColor
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.leftMargin: 12.5
						anchors.rightMargin: 12.5
						text: root.player.trackTitle
						font {pixelSize: 15; family: fontFamily; bold: true}
						//width: 100
						elide: Text.ElideRight
						clip: true
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
				}

				Component{
					id: stoppedComponent

					Item {
						width:25
						height:25
						anchors.centerIn: parent

						Text {
							id: imageMusicScores
							anchors.centerIn: parent
							text: "󰺢"
							color: root.textColor
							font {pixelSize: root.fontSize; bold: true; family: root.fontFamily}
						}
					}
				}
			}

			Rectangle {
				id: rectangleClock
				width: 150
				height: widgetHeight
				color: rectangleColor
				radius: radiusNumber
				border {
					color: root.borderColor
					width: root.borderWidth
				}
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				anchors.topMargin: 5	
				Text {
					color: root.textColor
					anchors.centerIn: parent
					text: root.time
					font {pixelSize: root.fontSize; family: root.fontFamily; bold: true}
				}
			}

			Rectangle{
				id: rectangleLauncher
				height: root.widgetHeight
				width: 45
				color: rectangleColor
				radius: root.radiusNumber
				border {
					color: root.borderColor
					width: root.borderWidth
				}
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.topMargin: 5
				anchors.leftMargin: 5

				Text{
					id: imageLauncher
					height: 22
					width: 22
					//anchors.horizontalCenter: parent.horizontalCenter
					anchors.centerIn: parent
					anchors.top: parent.top
					anchors.topMargin:3.0	
					text: ""
					color: textColor
					font {pixelSize: root.fontSize; bold: true; family: root.fontFamily}	

					Process{
						id: processLauncher
						command: ["vicinae","toggle"]
						running: false
					}

					MouseArea{
						anchors.fill: parent
						onClicked:{
							processLauncher.running = true
						}
					}
				}

			}

			Rectangle {
				id: rectangleWorkspaces
				width: 190
				height: widgetHeight
				color: rectangleColor
				radius: radiusNumber
				border {
					color: root.borderColor
					width: root.borderWidth
				}
				anchors.left: rectangleLauncher.right
				anchors.leftMargin: 5 	
				anchors.top: parent.top
				anchors.topMargin: 5
				
			

				RowLayout {
					anchors.fill: parent
					anchors.verticalCenter: parent.verticalCenter
					anchors.margins: 5

					Repeater {
						model: 9

						Text {
							property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
							property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
							text: index + 1
							color: isActive ? root.textColor : root.unfocusedTextColor
							font { pixelSize: root.fontSize; bold: true; family: root.fontFamily }
							anchors.verticalCenter: parent.verticalCenter

							MouseArea {
								anchors.fill: parent
								onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (index + 1) + " })") 
								
							}
						}
					}

					Item { Layout.fillWidth: true }
				}	
			}

			Rectangle{
				id: rectangleSystemcontrols
				height: widgetHeight
				width: 95
				color: rectangleColor
				border {
					color: root.borderColor
					width: root.borderWidth
				}
				anchors.right: parent.right
				anchors.top: parent.top
				radius: radiusNumber
				anchors.topMargin: 5
				anchors.rightMargin:5

				RowLayout{
					anchors.fill: parent
					anchors.verticalCenter: parent.verticalCenter
					anchors.margins: 5
					spacing: 5
					layoutDirection: Qt.RightToLeft
					
					Text{
						id: imagePoweroff
						anchors.verticalCenter: parent.verticalCenter
						anchors.right: parent.right
						anchors.rightMargin: 1
						height: 20
						width: 20
						text: ""
						color: root.textColor
						font {pixelSize: root.fontSize; bold: true; family: root.fontFamily}					

						Process{
							id: processPoweroff
							command: ["systemctl","poweroff"]
							running: false
						}

						MouseArea{
							anchors.fill:parent
							onClicked:{
							processPoweroff.running = true
							}
						}
					}

					Text{
						id: imageReboot
						anchors.verticalCenter: parent.verticalCenter
						anchors.right: imagePoweroff.left
						anchors.rightMargin: 13
						height: 20
						width: 20
						text: ""
						color: root.textColor
						font {pixelSize: root.fontSize; bold: true; family: root.fontFamily}
						Process{
							id: processReboot
							command: ["systemctl","reboot"]
							running: false
						}

						MouseArea{
							anchors.fill: parent
							onClicked: {
								processReboot.running = true
							}
						}
					}

					Text{
						id: imageLogout
						anchors.verticalCenter: parent.verticalCenter
						anchors.right: imageReboot.left
						anchors.rightMargin: 13
						height: 20
						width: 20
						text: "󰗽"
						color: root.textColor
						font {pixelSize: root.fontSize; bold: true; family: root.fontFamily}
						

						MouseArea{
							anchors.fill: parent
							onClicked: {
								Hyprland.dispatch("hl.dsp.exit()")
							}
						}
					}
				}
			}

			Rectangle{
				id: rectangleSystemstats
				height: root.widgetHeight
				width: 340
				color: rectangleColor
				border {
					color: root.borderColor
					width: root.borderWidth
				}
				anchors.right: rectangleSystemcontrols.left
				anchors.top: parent.top
				radius: root.radiusNumber
				anchors.topMargin: 5
				anchors.rightMargin:5
				clip: true

				RowLayout{
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter
					layoutDirection: Qt.RightToLeft
					anchors.margins: 5
					spacing: 5


					Text{
						color: root.textColor
						id: textRAM
						text: root.ramUsage + " gb"
						font{pixelSize: root.fontSize; family: fontFamily; bold:true}
						Layout.preferredWidth: 90
						Layout.minimumWidth:90
						Layout.maximumWidth:90
						horizontalAlignment: Text.AlignRight
						elide: Text.ElideRight
						Layout.alignment: Qt.AlignVCenter

					}

					Text{
						id: imageRAM
						Layout.preferredWidth: 25
						Layout.maximumWidth: 25
						Layout.minimumWidth: 25
						Layout.alignment: Qt.AlignVCenter
						text: ""
						color: textColor
						font { pixelSize: root.fontSize; bold: true; family: root.fontFamily}

					}

					Text{
						color: root.textColor
						id: textCPU 
						text: root.cpuUsage + "%"
						font{pixelSize: root.fontSize; family: fontFamily; bold: true}
						Layout.preferredWidth: 75
						Layout.minimumWidth:75
						Layout.maximumWidth:75
						horizontalAlignment: Text.AlignRight
						elide: Text.ElideRight
						Layout.alignment: Qt.AlignVCenter

					}

					Text{
						id: imageCPU
						//anchors.verticalCenter: parent.verticalCenter
						Layout.preferredWidth: 25
						Layout.maximumWidth: 25
						Layout.minimumWidth: 25
						Layout.alignment: Qt.AlignVCenter
						text: ""
						color: root.textColor
						font { pixelSize: root.fontSize; bold: true; family: root.fontFamily}
					}

					Text{
						color: root.textColor
						id: textBattery
    					text:`${Math.round(UPower.devices.values.find(device => device.nativePath.endsWith("BAT0")).percentage * 100)}%`
						font{pixelSize: root.fontSize; family: fontFamily; bold: true}
						Layout.preferredWidth: 55
						Layout.minimumWidth: 55
						Layout.maximumWidth: 55
						horizontalAlignment: Text.AlignRight
						elide: Text.ElideRight
						Layout.alignment: Qt.AlignVCenter
					}

					
					Text{
						id: imageBattery
						Layout.preferredWidth: 25
						Layout.maximumWidth: 25
						Layout.minimumWidth: 25
						Layout.alignment: Qt.AlignVCenter
						text: ""
						color: root.textColor
						font {pixelSize: root.fontSize; bold: true; family: root.fontFamily}
					}

				}
			}	

			Rectangle {
				id: rectangleVolume
				height: widgetHeight
				width:105
				color: rectangleColor
				radius: radiusNumber
				border {
					color: root.borderColor
					width: root.borderWidth
				}
				anchors.left: rectangleMedia.right
				anchors.top: parent.top
				anchors.topMargin: 5
				anchors.leftMargin: 5

				Text {
					id: imageVolume
					anchors.verticalCenter: parent.verticalCenter
					anchors.left: parent.left
					anchors.leftMargin: 10
					text: ""
					color: textColor
					font {pixelSize: root.fontSize; bold: true; family: root.fontFamily}
				}

				Text {
					color: root.textColor
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.rightMargin: 10
					text: root.volume
					font {pixelSize: root.fontSize; family: fontFamily; bold: true}
				}

				MouseArea {
        			anchors.fill: parent
        			hoverEnabled: true 

        			onWheel: function(wheel) {
            			if (wheel.angleDelta.y > 0) {
                			processVolumeUp.running = true
            			} else {
                			processVolumeDown.running = true
            			}
					}
				}
			}

			Rectangle {
				id: rectangleFiller
				height: root.widgetHeight
				color: root.rectangleColor
				border{
					width: root.borderWidth
					color: root.borderColor
				}
				radius: radiusNumber
				anchors {
					top: parent.top
					topMargin: 5
					right: rectangleSystemstats.left
					rightMargin: 5
					left: rectangleClock.right
					leftMargin: 5
				}

				Process{
					id:processWallpaper1
					command: ["bash","-c","awww img /home/alth/Pictures/Wallpapers/wallpaperGreen.jpg -t none"]
					running: false
				}

				Process{
					id: processWallpaper2
					command: ["bash","-c","awww img /home/alth/Pictures/Wallpapers/wallpaperCastle.webp -t none"] 
					running: false
				}
				MouseArea {
					anchors.fill: parent
					onClicked: {
						if (root.gp == "p") {
							root.gp = "g"
							processWallpaper1.running = true
						} else {
							root.gp = "p"
							processWallpaper2.running = true
						}
					}
				}

				Text {
					color: root.textColor
					font {pixelSize: root.fontSize; family: fontFamily; bold: true}
					text: "P/G"
					anchors.centerIn: parent
				}
			}

			PopupWindow {
				id: popupTray
    			anchor.window: bar
    			anchor.rect.x: 770 - width / 2
    			anchor.rect.y: parentWindow.height + 5
				color: "transparent"
    			width: 500
    			height: 420
    			visible: false
				grabFocus: true

				Rectangle {
					id: rectangleTray
					anchors.fill: parent
					radius: 16
					color: rectangleColor
					border {
						color: root.borderColor
						width: root.borderWidth	
					}

					RowLayout {
						width: 400
						height: 35
						anchors {
							top: parent.top
							topMargin: 35
							horizontalCenter: parent.horizontalCenter
						}
						
						Text {
							text: "bluetooth"
						}

						Text {
							text: "Netzwerk"
						}

						Text {
							text: "Baupeningong"
						}
					}
				}
			}


			PopupWindow {
				id: popupMedia
    			anchor.window: bar
    			anchor.rect.x: 370 - width / 2
    			anchor.rect.y: parentWindow.height + 5
				color: "transparent"
    			width: 500
    			height: 420
    			visible: false
				grabFocus: true

				Rectangle {
					id: rectangleMediaPopup
					anchors.fill: parent
					radius: 16
					color: rectangleColor
					border {
						color: root.borderColor
						width: root.borderWidth
					}
					clip: true
					Image {
						id: imageMediaCover
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.top: parent.top
						anchors.topMargin: 30
						height: 200
						width: 200
						cache: false
						source: root.player.trackArtUrl
					}
					Text {
						id: textPopupMediaTitle
						text: root.player.trackTitle
						anchors.top: imageMediaCover.bottom
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.topMargin: 20
						font{pixelSize: 25; family: fontFamily; bold:true}
						width: 400
						elide: Text.ElideRight
						clip: true
						horizontalAlignment: Text.AlignHCenter
					}

					Text {
						id: textPopupMediaAlbum
						text: root.player.trackAlbum
						anchors.top: textPopupMediaTitle.bottom
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.topMargin: 0
						font{pixelSize: 15; family: fontFamily; bold:true}
						width: 400
						elide: Text.ElideRight
						clip: true
						horizontalAlignment: Text.AlignHCenter
					}

					Text {
						id: textPopupMediaArtist
						text: root.player.trackArtist
						anchors.top: textPopupMediaAlbum.bottom
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.topMargin: 0
						font{pixelSize: 15; family: fontFamily; bold:true}
						width: 400
						elide: Text.ElideRight
						clip: true
						horizontalAlignment: Text.AlignHCenter
					}

					RowLayout{
						id: rowlayoutMediacontrols
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.top: textPopupMediaArtist.bottom
						anchors.topMargin: 15
						layoutDirection: Qt.LeftToRight
						anchors.margins: 5
						spacing: 20

						Image{
							id: imagePrev
							source: "/home/alth/.config/quickshell/quickshellIcons/prev.png"
							Layout.preferredWidth: 25
							Layout.maximumWidth: 25
							Layout.minimumWidth: 25
							Layout.alignment: Qt.AlignVCenter
							MouseArea{
								anchors.fill: parent
								onClicked: {
									root.player.previous()
								}
							}
						}

						Image{
							id: imagePause
							source: root.player.isPlaying
								? "/home/alth/.config/quickshell/quickshellIcons/pause.png"
								: "/home/alth/.config/quickshell/quickshellIcons/play.png"
							Layout.preferredWidth: 25
							Layout.maximumWidth: 25
							Layout.minimumWidth: 25
							Layout.alignment: Qt.AlignVCenter
							MouseArea{
								anchors.fill: parent
								onClicked: {
									root.player.togglePlaying()
								}
							}
						}

						Image{
							id: imageNext
							source: "/home/alth/.config/quickshell/quickshellIcons/next.png"
							Layout.preferredWidth: 25
							Layout.maximumWidth: 25
							Layout.minimumWidth: 25
							Layout.alignment: Qt.AlignVCenter
							MouseArea{
								anchors.fill: parent
								onClicked: {
									root.player.next()
								}
							}
						}
					}

					Slider {
						id: seekBar
						anchors.top: rowlayoutMediacontrols.bottom
						anchors.topMargin: 15
						anchors.horizontalCenter: parent.horizontalCenter
    					from: 0.1
    					to: root.player.length
    					value: root.sliderPosition
						onMoved: {
							root.sliderPosition = root.player.position
						}
    					width: 300
						enabled: true

						onPressedChanged: {
							root.dragging = pressed
							if (!pressed) {
								processSeek.command = [
									"playerctl",
									"position",
									value.toString()
								]
								processSeek.running = true
							}
						}
						background: Rectangle {
        					implicitHeight: 6
        					radius: 3
        					color: "#000000"

        					Rectangle {
           						width: seekBar.visualPosition * parent.width
            					height: parent.height
            					radius: 3
            					color: "#333333"
        						}
    					}

    					handle: Rectangle {
        					x: seekBar.visualPosition * (seekBar.width - width)
        					y: -4
        					width: 14
        					height: 14
        					radius: 7
        					color: "#333333"
        					border.color: "#000000"
    					}
					}
				}
  			}	
		}
	}

	Process {
		id: processClock	
		command: ["date","+%H:%M"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: root.time = this.text
		}
	}

	Process{
		id: processRAM
		command: ["bash","-c","free -b | awk 'NR==2 {printf \"%.1f\", $2/1024/1024/1024}'"]
		running: true
		stdout: StdioCollector{
			onStreamFinished: root.ramUsage = this.text
		}
		
	}

	Process{
		id: processCPU
		command: ["bash", "-c","awk 'NR==1{u1=$2+$3+$4+$5+$6+$7+$8; i1=$5} END{system(\"sleep 0.2\"); getline < \"/proc/stat\"; u2=$2+$3+$4+$5+$6+$7+$8; i2=$5; printf \"%.1f\", (1-(i2-i1)/(u2-u1))*100}' /proc/stat"]
		running: true
		stdout: StdioCollector{
			onStreamFinished: root.cpuUsage = this.text
		}
	}

	Process{
		id: processGPU
		running: true
		command: ["bash", "-c", "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{printf \"%.1f\", $1}'"]
		stdout: StdioCollector{
			onStreamFinished: root.gpuUsage = this.text
		}
	}

	Process{
		id: processGetVolume
		running:true
		command :["bash","-c","amixer get Master | awk -F'[][]' '/%/ {print $2; exit}'"]
		stdout: StdioCollector{
			onStreamFinished: root.volume = this.text
		}
	}

	Process{
		id:processVolumeUp
		running:false
		command: ["bash","-c","amixer set Master 1%+"]
	}

	Process{
		id:processVolumeDown
		running:false
		command: ["bash","-c","amixer set Master 1%-"]
	}

	Process{
		id:processSeek
		running: false
	}

	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered:{
			processClock.running = true
			processRAM.running = true
			processCPU.running = true
			processGPU.running = true
		} 	
	}

	Timer {
		interval: 100
		running: true
		repeat: true
		onTriggered:{
			processGetVolume.running = true
		} 	
	}
}								


