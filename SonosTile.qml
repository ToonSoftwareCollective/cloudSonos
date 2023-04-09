//
// Sonos app by Harmen Bartelink, further enhanced by Toonz
//

import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Tile {
	id: sonosTile
	property bool		showNext : false

	onClicked: {
		//app.playGoogleTTStoSonos("knopje is gedrukt")
		if (app.mediaScreen){	
			app.mediaScreen.show();
		}
	}
	

	//Show you the active zone name selected in the mediascreen.
	Text {
		id: zoneName

		text: app.sonosNameIsGroup ? "Grp " + app.groupName : app.groupName
		font.pixelSize: isNxt ? 20 : 16
		font.family: qfont.regular.name
		font.bold: true

		wrapMode: Text.WordWrap
		horizontalAlignment: Text.AlignHCenter
		anchors {
			top: parent.top
			topMargin: isNxt ? 8 : 6
			horizontalCenter: parent.horizontalCenter
		}
		width: isNxt ? 250 : 200
		visible: !dimState
	}
	
	//Shows you the now playing image.
	StyledRectangle {
		id: nowPlaying
		width: isNxt ? 86 : 70
		height: isNxt ? 86 : 70
		radius: 3
		opacity: 1.0
		shadowPixelSize: 1
		anchors.top: zoneName.bottom
		anchors.left: parent.left
		anchors.leftMargin: 10
		anchors.topMargin: isNxt ? 3: 2
		
		Image {
			id: nowPlayingImage
			source: app.currentItemImageUrl
			width: isNxt ? 80 : 64
			height: isNxt ? 80 : 64
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.leftMargin: 3
			anchors.topMargin: 3			
		}
		visible: !dimState && (app.currentItemImageUrl.length > 5) & !showNext
	}

	
	//shows you the now playing artist / number.
	Text {
		id: itemPosition
		text: new Date(app.positionMillis).toISOString().substr(14, 5) + " (" + new Date(app.currentItemTrackDurationMillis).toISOString().substr(14, 5) + ")"
		font.pixelSize: isNxt ? 15 : 12
		font.family: qfont.regular.name
		font.bold: true
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		wrapMode: Text.WordWrap
		anchors {
			bottom: volumeDown.top
			bottomMargin: 1
			left: nowPlaying.left		
		}
		width: 100
		visible: app.showSlider & !dimState & !showNext
	}
	
	//shows you the now playing artist / number.
	Text {
		id: itemText
		text: app.currentItemTrackArtistName
		font.pixelSize: isNxt ? 17 : 13
		font.family: qfont.regular.name
		font.bold: true
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		wrapMode: Text.WordWrap
		anchors {
			top: nowPlaying.top
			left: nowPlaying.right
			leftMargin: isNxt ? 5 : 4
		}
		width: isNxt ? 157 : 125
		visible: !showNext
	}
	
	Text {
		id: titleText
		text: app.currentItemName
		font.pixelSize: isNxt ? 17 : 13
		font.family: qfont.regular.name
		font.bold: false
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		wrapMode: Text.WordWrap
		anchors {
			top: itemText.bottom
			topMargin: 2
			left: itemText.left
		}
		width: isNxt ? 157 : 125
		visible: !showNext
	}
	
	Text {
		id: streamInfoTxt
		text: app.streamInfo
		font.pixelSize: isNxt ? 12 : 9
		font.family: qfont.bold.name
		font.bold: false
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		wrapMode: Text.WordWrap
		anchors {
			top: titleText.bottom
			topMargin: 3
			left: itemText.left
		}
		width: isNxt ? 157 : 125
		visible: !(streamInfo== "") & !showNext
	}


	//shows you the now playing artist / number.
	Text {
		id: itemNext
		text: "Volgende track"
		font.pixelSize: isNxt ? 17 : 13
		font.family: qfont.regular.name
		font.bold: true
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		wrapMode: Text.WordWrap
		anchors {
			top: zoneName.bottom
			horizontalCenter: parent.horizontalCenter
			topMargin: isNxt ? 5 : 4
		}
		visible: showNext
	}
	
	
	Text {
		id: itemTextNext
		text: app.nextItemTrackArtistName
		font.pixelSize: isNxt ? 17 : 13
		font.family: qfont.regular.name
		width: isNxt ? 250 : 200
		font.bold: true
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		wrapMode: Text.WordWrap
		horizontalAlignment: Text.AlignHCenter
		anchors {
			top: itemNext.bottom
			horizontalCenter: parent.horizontalCenter
		}
		visible: showNext
	}
	
	Text {
		id: titleTextNext
		text: app.nextItemName
		font.pixelSize: isNxt ? 17 : 13
		font.family: qfont.regular.name
		width: isNxt ? 250 : 200
		font.bold: false
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		wrapMode: Text.WordWrap
		horizontalAlignment: Text.AlignHCenter
		anchors {
			top: itemTextNext.bottom
			topMargin: 2
			horizontalCenter: parent.horizontalCenter
		}
		visible: showNext
	}
	
	Text {
		id: pauseText

		text: "(gepauzeerd)"
		font.pixelSize: isNxt ? 17 : 13
		font.family: qfont.regular.name
		font.bold: false
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		wrapMode: Text.WordWrap
		anchors {
			top: titleText.bottom
			topMargin: 5
			left: itemText.left
		}
		width: isNxt ? 157 : 125
		visible: dimState && app.playButtonVisible & !showNext
	}

	
	//volume control session start here, first you'll find the first button.
	IconButton {
		id: volumeDown
		anchors {
			bottom: parent.bottom
			bottomMargin: 5
			left: parent.left
			leftMargin: isNxt ? 2 : 1
		}

		iconSource: "qrc:/tsc/volume_down_small.png"
		onClicked: {
			if (app.sonosNameIsGroup) {
				app.setGroupVolume((app.groupVolume-2))
			} else {
				app.setGroupVolume((app.groupVolume-2))			
			}
		}
		visible: !dimState
	}
	IconButton {
		id: prevButton
		anchors {
			left: volumeDown.right
			leftMargin: isNxt ? 16 : 12
			bottom: volumeDown.bottom
		}

		iconSource: "qrc:/tsc/left.png"
		onClicked: {
			app.setSimpleGroupCommand("playback/skipToPreviousTrack");
		}
		visible: !dimState && app.showSlider
	}

	IconButton {
		id: pauseButton
		anchors {
			left: prevButton.right
			leftMargin: isNxt ? 16 : 12
			bottom: prevButton.bottom
		}
		iconSource: "qrc:/tsc/pause.png"
		onClicked: {
			app.playButtonVisible = true;
			app.pauseButtonVisible = false;
			app.setSimpleGroupCommand("/playback/pause");
		}
		visible: !dimState && app.pauseButtonVisible
	}
	
	IconButton {
		id: playButton
		anchors {
			left: prevButton.right
			leftMargin: isNxt ? 16 : 12
			bottom: pauseButton.bottom
		}

		iconSource: "qrc:/tsc/play.png"
		onClicked: {
			app.playButtonVisible = false;
			app.pauseButtonVisible = true;
			app.setSimpleGroupCommand("/playback/play");
			}
		visible: !dimState && app.playButtonVisible
	}
	
	IconButton {
		id: nextButton
		anchors {
			left: playButton.right
			leftMargin: isNxt ? 16 : 12
			bottom: playButton.bottom
		}

		iconSource: "qrc:/tsc/right.png"
		onClicked: {
			console.log("next");
			app.setSimpleGroupCommand("/playback/skipToNextTrack");
		}
		visible: !dimState && app.showSlider
	}	
	
	//last in this section is the volume up button.
	IconButton {
		id: volumeUp
		anchors {
			bottom: nextButton.bottom
			left: nextButton.right
			leftMargin: isNxt ? 16 : 12
		}

		iconSource: "qrc:/tsc/volume_up_small.png"
		onClicked: {
			if (app.sonosNameIsGroup) {
				app.setGroupVolume((app.groupVolume+2))
			} else {
				app.setGroupVolume((app.groupVolume+2))
			}
		}
		visible: !dimState
	}
	
	Text {
		id: textNext
		text: ">"
		font.pixelSize: isNxt ? 20 : 16
		font.family: qfont.regular.name
		font.bold: true
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: parent.top
			right: parent.right
			rightMargin: isNxt ? 5 : 4
			topMargin:isNxt ? 5 : 4
		}
		visible: app.showSlider
	}


	MouseArea {
		height : 60
		width : 60
		anchors {
			top: parent.top
			right: parent.right
			rightMargin: 0
			topMargin:0
		}
		onClicked: {
			showNext = ! showNext
			if(showNext){textNext.text = "<"}else {textNext.text = ">"}
		}
		enabled: app.showSlider
	}
	
}
