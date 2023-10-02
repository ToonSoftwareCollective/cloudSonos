import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: mediaScreen
	screenTitle: app.groupName
	
	property bool debugOutput : app.debugOutput
	
	property string playState
	property string shuffleMode
	property string itemType
	property int volumeState

	property alias positionIndicatorWidth : positionIndicatorBar.width
	property alias positionIndicatorLeft : positionIndicatorBar.left
	property bool positionIndicatorDragActive : false
	property int positionIndicatorX
	property int totalheight:0
	property int totalwidth:0
	property bool centered : false
	
	onCustomButtonClicked:{
		if (app.sonosConfigScreen) {
			 app.needReboot = false
			 app.sonosConfigScreen.show();
		}
	}
	
	onHidden: {
		app.savedFromMediaScreen = false;
		getAllFromMetaDataTimer.running = false;
	}

	onShown: {
		if (debugOutput) console.log("*********sonos mediaScreen loaded. Number of items: " + app.numberofItems)
		if (app.numberofItems<2){centered = true} else {centered = false}
		getAllFromMetaDataTimer.running = true;
		addCustomTopRightButton("Instellingen");
		if (app.userName == "" || app.passWord == "") {
			if (app.sonosConfigScreen){
				app.sonosConfigScreen.show();
				showPopup();
			}
		}
		getAllFromMetaData();
	}
		
	function showPopup() {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Informatie"), qsTr("U bent nu doorgestuurd naar het menuscherm omdat er of nog geen geldige informatie is ingevuld.. <br><br> Check deze gegevens op het menuscherm waar u nu op terecht bent gekomen. ") , qsTr("Sluiten"));
	}
	
	function refreshScreen(){
		if (debugOutput) console.log("*********sonos mediaScreen loaded. Number of items: " + app.numberofItems)
		if (app.numberofItems<2){centered = true} else {centered = false}
		if (debugOutput) console.log("*********sonos mediaScreen centered: " + centered)
		frame2.update()
		frame3.update()
	}


	Rectangle {
		id:frame1_left
		width: isNxt? 341 : 266
		height: parent.height
		color: colors.canvas
		
		//border.width:2
		//border.color: "black"
		
		anchors {
			top: parent.top
			left: centered ? undefined : parent.left
			leftMargin: centered ? undefined : isNxt ? 20 : 16
		}
		
		Image {
			id: positionIndicatorBar
			source: "drawables/volumeBarTile.png"
			width: isNxt? 341 : 266
			height: isNxt ? 30 : 24
			anchors {
				top: parent.top
				left: parent.left
			}
			visible: app.showSlider
		}
		
		//this image is the slider indicator. 
		Image {
			id: positionIndicator
			source: "drawables/volumeIndicator.png"
			height: isNxt ? 35 : 28
			width: isNxt ? 35 : 28
			x: positionIndicatorX
			y: positionIndicatorBar.y - 5
		
			MouseArea {
				id: mouseArea
				anchors.fill: parent
				drag {
					target: positionIndicator
					axis: Drag.XAxis
					minimumX: 0
					maximumX: isNxt ? 290 : 232
				}
				property bool dragActive: drag.active
					onDragActiveChanged: {
						if (!drag.active) {
						positionIndicatorDragActive = false;
						var xPos = positionIndicator.x;
						if (xPos < 0) xPos = 0;
						app.setSeek( Math.floor(xPos * app.currentItemTrackDurationMillis / positionIndicatorBar.width)); 
						app.showSlider = false;
					} else {
						positionIndicatorDragActive = true;
					} 
				}
			}
			onXChanged: {
				if (mouseArea.drag.active) {
					app.positionMillis = Math.floor(x * app.currentItemTrackDurationMillis / positionIndicatorBar.width); 
				}
			}
			visible: app.showSlider
		}

		Text {
			id: trackLength

			text: new Date(app.currentItemTrackDurationMillis).toISOString().substr(14, 5)
			font.pixelSize: isNxt ? 13 : 10
			font.family: qfont.regular.name
			font.bold: true
			color: colors.tileTextColor

			anchors {
				bottom: positionIndicatorBar.top
				bottomMargin: isNxt ? 5 : 4
				right: positionIndicatorBar.right
				rightMargin: isNxt ? -20 : -16
			}
			visible: app.showSlider
		}

		Text {
			id: trackPositionTime

			text: new Date(app.positionMillis).toISOString().substr(14, 5)
			font.pixelSize: isNxt ? 13 : 10
			font.family: qfont.regular.name
			font.bold: true
			color: colors.foreground 
			anchors {
				bottom: positionIndicatorBar.top
				bottomMargin: isNxt ? 5 : 4
				right: positionIndicator.right
			}
			visible: app.showSlider && ((positionIndicatorX / positionIndicatorBar.width) < 0.85)
		}

		//this is the item for the now playing image
		StyledRectangle {
			id: nowPlaying
			width: isNxt ? 256: 206
			height: isNxt ? 256 : 206
			radius: 3
			color: colors.background
			opacity: 1.0
			//shadowPixelSize: 1
			anchors {
				top: positionIndicatorBar.bottom
				horizontalCenter: parent.horizontalCenter
				topMargin: isNxt ? 30 : 24
			}
			
			Image {
				id: missingPlayingImageMain
				source: "drawables/sonos.png"
				fillMode: Image.PreserveAspectFit
				height: parent.heigth - 6
				width: parent.width - 6
				anchors {
					top: parent.top
					horizontalCenter: parent.horizontalCenter
					topMargin: 3
				}
				visible : app.currentItemImageUrl == "drawables/sonos.png"
			}
		
			Image {
				id: nowPlayingImage
				source: app.currentItemImageUrl
				fillMode: Image.PreserveAspectFit
				height: parent.heigth - 6
				width: parent.width - 6
				anchors {
					top: parent.top
					horizontalCenter: parent.horizontalCenter
					verticalCenter: parent.verticalCenter
					topMargin: 3
				}
			}
		}
		
		Rectangle{
			id: textBackground
			width: nowPlaying.width
			height: itemArtist.implicitHeight + itemText.implicitHeight
			color: colors.canvas
			opacity: 0.8
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: itemText.bottom
				bottomMargin: isNxt ? 8 : 6
			}
		}
	
		//This is the text which is showing you the now playing artist and number
		Text {
			id: itemArtist
			text: app.currentItemTrackArtistNameShort
			font.pixelSize: isNxt ? 30 : 24
			font.family: qfont.bold.name
			color: colors.tileTextColor
			width: parent.width -24
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignHCenter
			anchors {
				bottom: itemText.top
				bottomMargin: isNxt ? 8 : 6
			}
			
		}
		
		Text {
			id: itemText
			//text: app.currentItemNameShort
			text: app.currentItemName
			//font.pixelSize: isNxt ? 35 : 28
			font.pixelSize: app.currentItemName.length < 30 ? ( isNxt ? 35 : 28) : ( isNxt ? 17 : 14)
			font.family: qfont.bold.name
			color: "red"
			width: parent.width -24
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignHCenter
			anchors {
				bottom: streamInfoTxt.visible? streamInfoTxt.top : pauseButton.top
				bottomMargin: isNxt ? 5 : 4
			}
		}
		
		Text {
			id: streamInfoTxt
			text: app.streamInfo
			font.pixelSize: isNxt ? 20 : 16
			font.family: qfont.bold.name
			color: "red"
			width: parent.width -20
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignHCenter
			anchors {
				bottom: pauseButton.top
				bottomMargin: isNxt ? 5 : 4
			}
			visible: !app.showSlider
		}
		
		IconButton {
			id: pauseButton
			color: colors.background
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: isNxt ? 8 : 6
			}

			iconSource: "qrc:/tsc/pause.png"
			onClicked: {
				app.playButtonVisible = true;
				app.pauseButtonVisible = false;
				app.setSimpleGroupCommand("/playback/pause");
			}
			visible :  app.pauseButtonVisible
			//visible :  app.pauseButtonVisible && app.showSlider
		}
		
		IconButton {
			id: playButton
			color: colors.background
			anchors {
				left: pauseButton.left
				top: pauseButton.top
			}

			iconSource: "qrc:/tsc/play.png"
			onClicked: {
				app.playButtonVisible = false;
				app.pauseButtonVisible = true;
				app.setSimpleGroupCommand("/playback/play");
			}
			//visible :  app.playButtonVisible && app.showSlider
			visible :  app.playButtonVisible
		}
		
		IconButton {
			id: prevButton
			anchors {
				right: pauseButton.left
				rightMargin: isNxt ? 19 : 15
				top: pauseButton.top
			}
			iconSource: "qrc:/tsc/left.png"
			onClicked: {
				app.setSimpleGroupCommand("playback/skipToPreviousTrack");
				app.getMetaData();
			}
			visible : app.showSlider
		}
		
		IconButton {
			id: volumeDown
			anchors {
				right: prevButton.left
				rightMargin: isNxt ? 19 : 15
				top: pauseButton.top
			}
			iconSource: "qrc:/tsc/volume_down.png"
			onClicked: {
				app.setGroupVolume((app.groupVolume-2))
			}
		}
		
		IconButton {
			id: nextButton
			anchors {
				left: pauseButton.right
				leftMargin: isNxt ? 19 : 15
				top: pauseButton.top
			}
			iconSource: "qrc:/tsc/right.png"
			onClicked: {
				app.setSimpleGroupCommand("/playback/skipToNextTrack");
				app.getMetaData();
			}
			visible : app.showSlider
		}

		IconButton {
			id: volumeUp
			anchors {
				left: nextButton.right
				leftMargin: isNxt ? 19 : 15
				top: pauseButton.top
			}
			iconSource: "qrc:/tsc/volume_up.png"
			onClicked: {
				app.setGroupVolume((app.groupVolume+2))
			}
		}
		
		Text {
            id: groupVolume
            text: app.groupVolume
            font.pixelSize: isNxt ? 15 : 12
            font.family: qfont.regular.name
            font.bold: true
            color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
            anchors {
                verticalCenter: volumeUp.verticalCenter
                left : volumeUp.right
                leftMargin: isNxt ? 5 : 4
            }
        }
		visible: !centered
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Rectangle {
		id: frame1_centered
		width: isNxt? 341 : 266
		height: parent.height
		color: colors.canvas
		
		//border.width:2
		//border.color: "black"
		
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}
		
	
		Image {
			id: positionIndicatorBar_centered
			source: "drawables/volumeBarTile.png"
			width: isNxt? 341 : 266
			height: isNxt ? 30 : 24
			anchors {
				top: parent.top
				left: parent.left
			}
			visible: app.showSlider
		}
		
		//this image is the slider indicator. 
		Image {
			id: positionIndicator_centered
			source: "drawables/volumeIndicator.png"
			height: isNxt ? 35 : 28
			width: isNxt ? 35 : 28
			x: positionIndicatorX
			y: positionIndicatorBar_centered.y - 5
		
			MouseArea {
				id: mouseArea_centered
				anchors.fill: parent
				drag {
					target: positionIndicator_centered
					axis: Drag.XAxis
					minimumX: 0
					maximumX: isNxt ? 290 : 232
				}
				property bool dragActive: drag.active
					onDragActiveChanged: {
						if (!drag.active) {
						positionIndicatorDragActive = false;
						var xPos = positionIndicator_centered.x;
						if (xPos < 0) xPos = 0;
						app.setSeek( Math.floor(xPos * app.currentItemTrackDurationMillis / positionIndicatorBar_centered.width)); 
						app.showSlider = false;
					} else {
						positionIndicatorDragActive = true;
					} 
				}
			}
			onXChanged: {
				if (mouseArea_centered.drag.active) {
					app.positionMillis = Math.floor(x * app.currentItemTrackDurationMillis / positionIndicatorBar_centered.width); 
				}
			}
			visible: app.showSlider
		}

		Text {
			id: trackLength_centered

			text: new Date(app.currentItemTrackDurationMillis).toISOString().substr(14, 5)
			font.pixelSize: isNxt ? 13 : 10
			font.family: qfont.regular.name
			font.bold: true
			color: colors.tileTextColor

			anchors {
				bottom: positionIndicatorBar_centered.top
				bottomMargin: isNxt ? 5 : 4
				right: positionIndicatorBar_centered.right
				rightMargin: isNxt ? -20 : -16
			}
			visible: app.showSlider
		}

		Text {
			id: trackPositionTime_centered

			text: new Date(app.positionMillis).toISOString().substr(14, 5)
			font.pixelSize: isNxt ? 13 : 10
			font.family: qfont.regular.name
			font.bold: true
			color: colors.foreground 
			anchors {
				bottom: positionIndicatorBar_centered.top
				bottomMargin: isNxt ? 5 : 4
				right: positionIndicator_centered.right
			}
			visible: app.showSlider && ((positionIndicatorX / positionIndicatorBar_centered.width) < 0.85)
		}

		//this is the item for the now playing image
		StyledRectangle {
			id: nowPlaying_centered
			width: isNxt ? 256: 206
			height: isNxt ? 256 : 206
			radius: 3
			color: colors.background
			opacity: 1.0
			//shadowPixelSize: 1
			anchors {
				top: positionIndicatorBar_centered.bottom
				horizontalCenter: parent.horizontalCenter
				topMargin: isNxt ? 30 : 24
			}
			
			Image {
				id: missingPlayingImageMain_centered
				source: "drawables/sonos.png"
				fillMode: Image.PreserveAspectFit
				height: parent.heigth - 6
				width: parent.width - 6
				anchors {
					top: parent.top
					horizontalCenter: parent.horizontalCenter
					topMargin: 3
				}
				visible : app.currentItemImageUrl == "drawables/sonos.png"
				
			}
		
			Image {
				id: nowPlayingImage_centered
				source: app.currentItemImageUrl
				fillMode: Image.PreserveAspectFit
				height: parent.heigth - 6
				width: parent.width - 6
				anchors {
					top: parent.top
					horizontalCenter: parent.horizontalCenter
					verticalCenter: parent.verticalCenter
					topMargin: 3
				}
			}
		}
		
		Rectangle{
			id: textBackground_centered
			width: nowPlaying_centered.width
			height: itemArtist_centered.implicitHeight + itemText_centered.implicitHeight
			color: colors.canvas
			opacity: 0.8
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: itemText_centered.bottom
				bottomMargin: isNxt ? 8 : 6
			}
		}
	
		//This is the text which is showing you the now playing artist and number
		Text {
			id: itemArtist_centered
			text: app.currentItemTrackArtistNameShort
			font.pixelSize: isNxt ? 30 : 24
			font.family: qfont.bold.name
			color: colors.tileTextColor
			width: parent.width -24
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignHCenter
			anchors {
				bottom: itemText_centered.top
				bottomMargin: isNxt ? 8 : 6
			}
			
		}
		
		Text {
			id: itemText_centered
			//text: app.currentItemNameShort
			text: app.currentItemName
			//font.pixelSize: isNxt ? 35 : 28
			font.pixelSize: app.currentItemName.length < 30 ? ( isNxt ? 35 : 28) : ( isNxt ? 17 : 14)
			font.family: qfont.bold.name
			color: "red"
			width: parent.width -24
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignHCenter
			anchors {
				bottom: streamInfoTxt_centered.visible? streamInfoTxt_centered.top : pauseButton_centered.top
				bottomMargin: isNxt ? 5 : 4
			}
		}
		
		Text {
			id: streamInfoTxt_centered
			text: app.streamInfo
			font.pixelSize: isNxt ? 20 : 16
			font.family: qfont.bold.name
			color: "red"
			width: parent.width -20
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignHCenter
			anchors {
				bottom: pauseButton_centered.top
				bottomMargin: isNxt ? 5 : 4
			}
			visible: !app.showSlider
		}
		
		IconButton {
			id: pauseButton_centered
			color: colors.background
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: isNxt ? 8 : 6
			}

			iconSource: "qrc:/tsc/pause.png"
			onClicked: {
				app.playButtonVisible = true;
				app.pauseButtonVisible = false;
				app.setSimpleGroupCommand("/playback/pause");
			}
			//visible :  app.pauseButtonVisible && app.showSlider
			visible :  app.pauseButtonVisible
		}
		
		IconButton {
			id: playButton_centered
			color: colors.background
			anchors {
				left: pauseButton_centered.left
				top: pauseButton_centered.top
			}

			iconSource: "qrc:/tsc/play.png"
			onClicked: {
				app.playButtonVisible = false;
				app.pauseButtonVisible = true;
				app.setSimpleGroupCommand("/playback/play");
			}
			//visible :  app.playButtonVisible && app.showSlider
			visible :  app.playButtonVisible
		}
		
		IconButton {
			id: prevButton_centered
			anchors {
				right: pauseButton_centered.left
				rightMargin: isNxt ? 19 : 15
				top: pauseButton_centered.top
			}
			iconSource: "qrc:/tsc/left.png"
			onClicked: {
				app.setSimpleGroupCommand("playback/skipToPreviousTrack");
				app.getMetaData();
			}
			visible : app.showSlider
		}
		
		IconButton {
			id: volumeDown_centered
			anchors {
				right: prevButton_centered.left
				rightMargin: isNxt ? 19 : 15
				top: pauseButton_centered.top
			}
			iconSource: "qrc:/tsc/volume_down.png"
			onClicked: {
				app.setGroupVolume((app.groupVolume-2))
			}
		}
		
		IconButton {
			id: nextButton_centered
			anchors {
				left: pauseButton_centered.right
				leftMargin: isNxt ? 19 : 15
				top: pauseButton_centered.top
			}
			iconSource: "qrc:/tsc/right.png"
			onClicked: {
				app.setSimpleGroupCommand("/playback/skipToNextTrack");
				app.getMetaData();
			}
			visible : app.showSlider
		}

		IconButton {
			id: volumeUp_centered
			anchors {
				left: nextButton_centered.right
				leftMargin: isNxt ? 19 : 15
				top: pauseButton_centered.top
			}
			iconSource: "qrc:/tsc/volume_up.png"
			onClicked: {
				app.setGroupVolume((app.groupVolume+2))
			}
		}
		
		Text {
            id: groupVolume_centered
            text: app.groupVolume
            font.pixelSize: isNxt ? 15 : 12
            font.family: qfont.regular.name
            font.bold: true
            color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
            anchors {
                verticalCenter: volumeUp_centered.verticalCenter
                left : volumeUp_centered.right
                leftMargin: isNxt ? 5 : 4
            }
        }

		visible: !frame1_left.visible
	}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	Rectangle {
		id: frame2
		width: centered? isNxt ? 200:157  : isNxt ? (parent.width - 411): (parent.width - 322)
		height: centered? parent.height : isNxt ? 40 : 32
		color: colors.canvas

		anchors {
			top: frame1_left.top
			left: centered ? undefined : frame1_left.right
			leftMargin: centered ? undefined : isNxt ? 40 : 32
			right: centered ? parent.right : undefined
			rightMargin: centered ? isNxt ? 4 : 3 : undefined
		}
			
		GridView {
			anchors {
				fill:  parent
				right: centered ? parent.right : undefined
				top: centered ? undefined : parent.top
			}
			
			cellWidth: isNxt ? 200:157
			cellHeight:  isNxt ? 50:40
			model: 	
				ListModel { 
					id: buttonModel
					ListElement { text: "Lijst/Favoriet"; actions: 1}
					ListElement { text: "Audioberichten"; actions: 2}
					ListElement { text: "Wachtrij"; actions: 3}
				}
					
			delegate: 
			SonosStandardButton {
				text: model.text
				width: isNxt ? 180: 144
				height: isNxt ? 40:32
				fontColorUp: "darkslategray"
				fontPixelSize: isNxt ? 20 : 16
				onClicked: 
					switch (model.actions) {
						case 1:
							if(app.favoritesScreen){app.favoritesScreen.show();}
							break;
						case 2:
							if(app.messageScreen) {app.messageScreen.show();}
							break;
						case 3:
							if(app.playlistScreen) {app.playlistScreen.show();}
							break;
						default:
							break;
					}
			}
		}
	}

	Rectangle {
		id: frame3
		width: frame2.width
		height: parent.height - nowPlaying.y -1
		color: colors.canvas
		y: nowPlaying.y

		anchors {
			left: frame2.left
		}


		ListModel {
			id: sonosModel
		}

		GridView {
			id: sonosGrid
			anchors.fill: parent
			cellWidth: isNxt ? 200:157
			cellHeight: isNxt ? 200:157
			model: sonosModel

			delegate: Rectangle {
				width:isNxt ? 180: 144
				height: isNxt ? 180: 144
				color: "white"
				
				
				MouseArea {
					anchors.fill: parent
					onClicked: {
						if (debugOutput) console.log("*********sonos mousearea clicked:" + index);
						app.playerIndex = index;
						app.groupName = model.name;
						app.savedFromMediaScreen = true
						app.saveSettings()
						app.getGroupVolume()
						app.getMetaData()
						app.getGroupVolume()
						app.getPlaybackStatus()
						stage.setScreenTitle(model.name,"")
					}
				}
				
				Image {
					id: missingPlayingImage
					source: "drawables/sonos.png"
					width: isNxt ? 80 : 64
					height: isNxt ? 80 : 64
					opacity: 0.5
					anchors {
						top: roomName.bottom
						horizontalCenter: parent.horizontalCenter
						topMargin: 2
					}
					visible : model.imageURL == "drawables/sonos.png"
				}
			
				Image {
					id: nowPlayingImage
					source: model.imageURL
					width: isNxt ? 80 : 64
					height: isNxt ? 80 : 64
					opacity: (app.playerIndex == index ) ? 1 : 0.5
					anchors {
						top: roomName.bottom
						horizontalCenter: parent.horizontalCenter
						topMargin: 2
					}
				}
				
				Text {
					id: roomName
					text: model.name
					font.pixelSize:  isNxt ? 16 : 12
					font.family: qfont.bold.name
					width: parent.width - 2
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
					color: colors.tileTextColor
					anchors {
						top: parent.top
						horizontalCenter: parent.horizontalCenter
						topMargin: isNxt ? 5 : 4
					}
				}
				
				Rectangle{
					id: textBackground2
					width: parent.width - 5
					height: trackName.implicitHeight + artistName.implicitHeight
					color: "white"
					opacity: 0.8
					anchors {
						horizontalCenter: parent.horizontalCenter
						top: artistName.top
					}
				}
				Text {
					id: trackName
					text: model.track.length>38 ? app.breakAtWholeWord(model.track, 38) + ".." : model.track
					font.pixelSize:  isNxt ? 16 : 12
					font.family: qfont.bold.name
					width: parent.width - 2
					wrapMode: Text.WordWrap
					color: "red"
					horizontalAlignment: Text.AlignHCenter
					anchors {
						bottom: parent.bottom
						horizontalCenter: parent.horizontalCenter
						bottomMargin: isNxt ? 5 : 4
					}
				}
				Text {
					id: artistName
					text: model.artist.length>18 ? app.breakAtWholeWord(model.artist, 18) +".." : model.artist
					font.pixelSize:  isNxt ? 16 : 12
					font.family: qfont.bold.name
					width: parent.width - 2
					wrapMode: Text.WordWrap
					color: colors.tileTextColor
					horizontalAlignment: Text.AlignHCenter
					anchors {
						bottom: trackName.top
						horizontalCenter: parent.horizontalCenter
						bottomMargin: isNxt ? 3 : 2
					}

				}
			}
		}
		visible: !centered
	}
	
	
	Rectangle {
	    id: speakerButton
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		y: pauseButton.y
		anchors {
			right: parent.right
			rightMargin : isNxt ? 20:16
		}
		Image {
			source: "drawables/equalizer.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				if(app.speakerScreen) {app.speakerScreen.show();}
			}
		}
		//visible: app.currentLineInAvailable
	}
	
	Rectangle {
	    id: inputButton
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		y: pauseButton.y
		anchors {
			right: speakerButton.visible? speakerButton.left : parent.right
			rightMargin : isNxt ? 20:16
		}
		Image {
			source: "drawables/input.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.postGroupCommand("playback/lineIn", JSON.stringify({}))
			}
		}
		visible: app.currentLineInAvailable
	}

	Rectangle {
	    id: crossButtonOnButton
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		y: pauseButton.y
		anchors {
			right: speakerButton.visible? inputButton.visible? inputButton.left : speakerButton.left : parent.right
			rightMargin : isNxt ? 20:16
		}
		Image {
			source: "drawables/crossfade_on.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.setPlayModes("crossfade", false)
			}
		}
		visible: app.crossfade
	}
	
	Rectangle {
	    id: crossButton
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		
		y: pauseButton.y
		anchors {
			left: crossButtonOnButton.left
		}
		Image {
			source: "drawables/crossfade.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.setPlayModes("crossfade", true)
			}
		}
		visible: !app.crossfade
	}
	
	Rectangle {
	    id: repeatOnButton
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		
		y: pauseButton.y
		anchors {
			right: crossButtonOnButton.left
			rightMargin: isNxt ? 19 : 15
		}
		Image {
			source: "drawables/loop_on.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.setPlayModes("repeat", false)
			}
		}
		visible: app.repeat
	}
	
	Rectangle {
	    id: repeatButton
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		
		y: pauseButton.y
		anchors {
			left: repeatOnButton.left
		}
		Image {
			source: "drawables/loop.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.setPlayModes("repeat", true);
			}
		}
		visible: !app.repeat
	}
	
	Rectangle {
	    id: shuffleOnButton2
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		
		y: pauseButton.y
		anchors {
			right: repeatOnButton.left
			rightMargin: isNxt ? 19 : 15
		}
		Image {
			source: "drawables/shuffle_on.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.setPlayModes("shuffle", false);
			}
		}
		visible: app.shuffle
	}
	
	Rectangle {
	    id: shuffleButton2
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		
		y: pauseButton.y
		anchors {
			left: shuffleOnButton2.left
		}
		Image {
			source: "drawables/shuffle.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.setPlayModes("shuffle", true);
			}
		}
		visible: !app.shuffle
	}

	Rectangle {
	    id: muteOnButton2
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		
		y: pauseButton.y
		anchors {
			right: shuffleOnButton2.left
			rightMargin: isNxt ? 19 : 15
		}
		Image {
			source: "drawables/mute_on.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.setGroupMuted(false)
			}
		}
		visible: app.groupMuted
	}
	
	Rectangle {
	    id: muteButton2
		width: isNxt ? 44:35
		height: isNxt ? 44:35
		color: colors.btnUp
		radius: designElements.radius
		
		y: pauseButton.y
		anchors {
			left: muteOnButton2.left
		}
		Image {
			source: "drawables/mute.png"
			width: isNxt ? 26:24
			height: isNxt ? 26:24
			anchors.centerIn: parent
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.setGroupMuted(true)
			}
		}
		visible: !app.groupMuted
	}	

	function getAllFromMetaData(){
		if (debugOutput) console.log("*********sonos getAllFromMetaData filling the grid")
		sonosModel.clear()
		for(var i in app.sonosArray){
			if (debugOutput) console.log("*********sonos getAllFromMetaData filling the grid:" + app.sonosArray[i].group.name)
			sonosModel.append({id: i , type:"", status:"", name: app.sonosArray[i].group.name, id: app.sonosArray[i].group.id, imageURL: "", artist: "", track: ""})     
			var xhr = new XMLHttpRequest();
			var url = "https://api.ws.sonos.com/control/api/v1/groups/"  + app.sonosArray[i].group.id +  "/playbackMetadata"
			if (debugOutput) console.log("*********sonos getAllFromMetaData url:" + url)
			if (debugOutput) console.log("*********sonos getAllFromMetaData filling the grid:" + app.sonosArray[i].group.name)
			xhr.open("GET", url, false);
			xhr.setRequestHeader("Authorization", "Bearer " + app.token);
			xhr.setRequestHeader("Content-Type", "application/json");
			xhr.onreadystatechange = function() {
				if( xhr.readyState === 4){
					if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
						if (debugOutput) console.log(xhr.responseText)
						var JsonString = xhr.responseText
						var containerType
						var JsonObject= (JSON.parse(JsonString))
						if(JsonObject.hasOwnProperty('container') & !JsonObject.hasOwnProperty('currentItem')){
							if (debugOutput) console.log("*********sonos metaType = container")
							containerType=JsonObject.container.type
						}else if(JsonObject.hasOwnProperty('currentItem')){
							if (debugOutput) console.log("*********sonos metaType = currentItem")
							containerType=JsonObject.currentItem.track.type
						}else{
						}
						if (debugOutput) console.log("*********sonos containerType: " + containerType)
						if(containerType=="station"){
							sonosModel.setProperty(i, "track", JsonObject.container.name)
							sonosModel.setProperty(i, "artist", "Station")
							for (var fav in app.favorites){
								if(app.favorites[fav].name === JsonObject.container.name){
									sonosModel.setProperty(i, "imageURL", app.favorites[fav].imageUrl)
								}
							}
						}else if(typeof containerType==="undefined"){
							if (debugOutput) console.log("*********sonos  (undefined) imageUrl ="  + " geen" )
							sonosModel.setProperty(i, "track", "Geen bron")
							sonosModel.setProperty(i, "imageURL", "")
							sonosModel.setProperty(i, "artist", "")
							
						}else if(containerType==="playlist"){
							if (debugOutput) console.log("*********sonos  (paylist) imageUrl ="  + JsonObject.currentItem.track.imageUrl )
							sonosModel.setProperty(i, "track", JsonObject.currentItem.track.name)
							sonosModel.setProperty(i, "imageURL", JsonObject.currentItem.track.imageUrl)
							sonosModel.setProperty(i, "artist", JsonObject.currentItem.track.artist.name)
						
						} else if(containerType=="linein.homeTheater"){
							if (debugOutput) console.log("*********sonos  (linein.homeTheater) imageUrl ="  + " geen" )
							sonosModel.setProperty(i, "track", "Line In/Home Theater")
							sonosModel.setProperty(i, "imageURL", "")
							sonosModel.setProperty(i, "artist", "")
							
						}else if(containerType==="track"){
							if (debugOutput) console.log("*********sonos  (track) imageUrl ="  + JsonObject.currentItem.track.imageUrl )
							var image1 = ""
							var image2 = ""
							var selectedImage = ""
							if (JsonObject.currentItem.track.imageUrl) image1 = JsonObject.currentItem.track.imageUrl
							if (JsonObject.container.imageUrl) image2 = JsonObject.container.imageUrl
							
							if (image2 !==""){
								selectedImage = app.checkImages(image1, image2)
							}else{
								selectedImage = image1
							}
							selectedImage = app.checkImage(selectedImage)

							sonosModel.setProperty(i, "track", JsonObject.currentItem.track.name)
							sonosModel.setProperty(i, "imageURL", selectedImage)
							sonosModel.setProperty(i, "artist", JsonObject.currentItem.track.artist.name)
							
						}else{
							if (debugOutput) console.log("*********sonos  (else) imageUrl ="  + JsonObject.currentItem.track.imageUrl )
							sonosModel.setProperty(i, "track", JsonObject.currentItem.track.name)
							sonosModel.setProperty(i, "imageURL", JsonObject.currentItem.track.imageUrl)
							sonosModel.setProperty(i, "artist", JsonObject.currentItem.track.artist.name)
						}
					}
				}
			}
			xhr.send()
		}
	}
	
	Timer{
		id: getAllFromMetaDataTimer
		interval: 8000
		triggeredOnStart: true
		running: false
		repeat: true
		onTriggered: getAllFromMetaData()
	}
}
