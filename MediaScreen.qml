import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: mediaScreen
	screenTitle: qsTr("Sonos")
	
	property bool debugOutput : app.debugOutput
	
	property string playState
	property string shuffleMode
	property string itemType
	property int volumeState
	property int  numberofItems :0

	property alias positionIndicatorWidth : positionIndicatorBar.width
	property alias positionIndicatorLeft : positionIndicatorBar.left
	property bool positionIndicatorDragActive : false
	property int positionIndicatorX
	property int totalheight:0
	property int totalwidth:0
	property bool centerHorizontally: false
	
	onCustomButtonClicked:{
		if (app.sonosConfigScreen) {
			 app.sonosConfigScreen.show();
		}
	}
	
	onHidden: {
		getAllFromMetaDataTimer.running = false;
	}
	
	onShown: {
		if (debugOutput) console.log("*********sonos mediaScreen loaded. Number of items: " + app.numberofItems)
		if (app.numberofItems<2) {centerHorizontally = true} else  {centerHorizontally = false}
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


	Rectangle {
		id:frame1
		width: parent.width/3
		height: parent.height
		color: colors.canvas
		
		anchors {
			top: parent.top
			topMargin: 0
			left: centerHorizontally ? undefined : parent.left
			leftMargin: centerHorizontally ? undefined : isNxt ? 20 : 16
			horizontalCenter: centerHorizontally ? parent.horizontalCenter : undefined
		}
		
		Image {
			id: positionIndicatorBar
			source: "drawables/volumeBarTile.png"
			width: parent.width
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
			shadowPixelSize: 1
			anchors {
				top: positionIndicatorBar.bottom
				horizontalCenter: positionIndicatorBar.horizontalCenter
				topMargin: isNxt ? 30 : 24
			}
			
			Image {
				id: nowPlayingImage
				source: app.currentItemImageUrl
				fillMode: Image.PreserveAspectFit
				height: isNxt ? 250 : 200
				anchors {
					top: parent.top
					leftMargin: 3
					topMargin: 3
				}
			}
			visible: (app.currentItemImageUrl.length > 5)

		}
		
		Rectangle{
			id: textBackground
			width: (itemArtist.implicitWidth > itemText.implicitWidth) ? itemArtist.implicitWidth:  itemText.implicitWidth
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
			text: app.currentItemTrackArtistName
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
			text: app.currentItemName
			font.pixelSize: isNxt ? 35 : 28
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
				right: parent.horizontalCenter
				rightMargin: isNxt ? 5 : 4
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
			visible :  app.playButtonVisible
		}
		
		IconButton {
			id: prevButton
			anchors {
				right: pauseButton.left
				rightMargin: isNxt ? 10 : 7
				top: pauseButton.top
			}
			iconSource: "qrc:/tsc/left.png"
			onClicked: {
				app.setSimpleGroupCommand("playback/skipToPreviousTrack");
			}
		}
		
		IconButton {
			id: volumeDown
			anchors {
				right: prevButton.left
				rightMargin: isNxt ? 10 : 7
				top: pauseButton.top
			}
			iconSource: "qrc:/tsc/volume_down.png"
			onClicked: {
				app.setGroupVolume((app.groupVolume-2))
			}
		}
		
		IconButton {
			id: shuffleOnButton
			anchors {
				left: pauseButton.right
				leftMargin: isNxt ? 10 : 7
				top: pauseButton.top
			}
			iconSource: "qrc:/tsc/shuffle_on.png"
			onClicked: {
				app.shuffle = false
				app.setPlayModes();
			}
			visible :  app.shuffle
		}
		
		
		IconButton {
			id: shuffleButton
			anchors {
				left: shuffleOnButton.left
				top: pauseButton.top
			}

			iconSource: "qrc:/tsc/shuffle.png"
			onClicked: {
				app.shuffle = true
				app.setPlayModes();
			}
			visible :  !app.shuffle
		}
		
		IconButton {
			id: nextButton
			anchors {
				left: shuffleButton.right
				leftMargin: isNxt ? 10 : 7
				top: pauseButton.top
			}
			iconSource: "qrc:/tsc/right.png"
			onClicked: {
				app.setSimpleGroupCommand("/playback/skipToNextTrack");
			}
		}

		IconButton {
			id: volumeUp
			anchors {
				left: nextButton.right
				leftMargin: isNxt ? 10 : 7
				top: pauseButton.top
			}
			iconSource: "qrc:/tsc/volume_up.png"
			onClicked: {
				app.setGroupVolume((app.groupVolume+2))
			}
		}
	}

	Rectangle {
		id: frame2
		
		width: centerHorizontally? isNxt ? 200:160  : isNxt ? (parent.width - frame1.width - frame1.anchors.leftMargin - 50): (parent.width -frame1.width - frame1.anchors.leftMargin - 40)
		height: centerHorizontally? parent.height : isNxt ? 40 : 32
		color: colors.canvas
				
		anchors {
			top: frame1.top
			left: centerHorizontally ? undefined : frame1.right
			leftMargin: centerHorizontally ? undefined : isNxt ? 40 : 32
			right: centerHorizontally ? parent.right : undefined
			rightMargin: centerHorizontally ? isNxt ? 10 : 8 : undefined
		}
			
		GridView {
			anchors {
				fill: centerHorizontally ? undefined : parent
				right: centerHorizontally ? parent.right : undefined
				top: centerHorizontally ? undefined : parent.top
			}
			
			cellWidth: isNxt ? 200:157
			cellHeight: centerHorizontally ? isNxt ? 50:40 : isNxt ? 50:40
			model: ListModel {
				ListElement { text: "Favorieten"; actions: 1}
				ListElement { text: "Audioberichten"; actions: 2}
				ListElement { text: "Externe Ingang"; actions: 3 }
			}

			delegate: 
			SonosStandardButton {
				text: model.text
				width: centerHorizontally ? isNxt ? 180: 144 : isNxt ? 180: 144
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
							app.postGroupCommand("playback/lineIn", JSON.stringify({}))
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
		height: parent.height - frame2.height
		color: colors.canvas
		y: nowPlaying.y
		
		anchors {
			//top: frame2.bottom
			left: frame2.left
			//topMargin: isNxt ? 20:16
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
				border.color: "black"
				color: "white"
				MouseArea {
					anchors.fill: parent
					onClicked: {
						if (debugOutput) console.log("*********sonos mousearea clicked:" + index);
						app.playerIndex = index;
						app.groupName = model.name;
						app.saveSettings()
						app.getMetaData()
						app.getPlaybackStatus()
						app.getGroupVolume()
					}
				}
				Image {
					id: nowPlayingImage
					source: model.imageURL
					width: isNxt ? 80 : 64
					height: isNxt ? 80 : 64
					opacity: 0.5
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
					width: isNxt ? 180: 144
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
					width: parent.width
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
					text: model.track
					font.pixelSize:  isNxt ? 16 : 12
					font.family: qfont.bold.name
					width: isNxt ? 180: 144
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
					text: model.artist
					font.pixelSize:  isNxt ? 16 : 12
					font.family: qfont.bold.name
					width: isNxt ? 180: 144
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
		visible: !centerHorizontally
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
							
						}else if(containerType==="track"){
							if (debugOutput) console.log("*********sonos  (track) imageUrl ="  + JsonObject.currentItem.track.imageUrl )
							sonosModel.setProperty(i, "track", JsonObject.currentItem.track.name)
							sonosModel.setProperty(i, "imageURL", JsonObject.currentItem.track.imageUrl)
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
