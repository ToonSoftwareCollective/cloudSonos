import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

Screen {
	id: mediaSelectZoneScreen
	screenTitle: "Audioberichten"
	property bool debugOutput : app.debugOutput
	property int numberofItems:0
	property int numberofItems2:0
	property int message1Index: 0
	property int message2Index: 0
	property int message3Index: 0
	property int message4Index: 0


	onShown: {
		saveVolumeLabel.inputText = app.messageVolume;
		app.messageResult = ""
		updatePlayersList();
		updateMessageTextList();
		listview1.currentIndex = message1Index
		listview2.currentIndex = message2Index
		radioButtonList1.currentIndex = message3Index
		radioButtonList2.currentIndex = message4Index
	}
	
	
	function playTexttoSonos(){
		if (debugOutput) console.log("*********sonos playTexttoSonos")
		var selectedZone = model.get(listview1.currentIndex).name
		var playMessage = app.messageTextArray[listview2.currentIndex]
		if (debugOutput) console.log("*********sonos selected zone is " + selectedZone)
		if (debugOutput) console.log("*********sonos selected text is " + playMessage)
		app.messageResult = ""
		if(selectedZone == "Alle"){
			if (debugOutput) console.log("*********sonos playing to alle")
			for (var i in app.sonosArray){
				app.playMessageToSonos(i, playMessage, app.messageVolume)
				removemessageResultTimer.start()
			}
		}else{
			if (debugOutput) console.log("*********sonos playing to: " + app.sonosArray[listview1.currentIndex-1].group.id)
			if (debugOutput) console.log("*********sonos playing to: " + app.sonosArray[listview1.currentIndex-1].player.id)
			if (debugOutput) console.log("*********sonos playing message is: " + playMessage)
			app.playMessageToSonos(listview1.currentIndex-1, playMessage,  app.messageVolume)
			removemessageResultTimer.start()
		}
	}
	
	function playEffectTexttoSonos(){
		if (debugOutput) console.log("*********sonos playTexttoSonos")
		var selectedZone = model.get(listview1.currentIndex).name
		var playMessage = app.messageTextArray[listview2.currentIndex]
		if (debugOutput) console.log("*********sonos selected zone is " + selectedZone)
		if (debugOutput) console.log("*********sonos selected text is " + playMessage)
		var voice
		
		switch (radioButtonList1.currentIndex) {
            case 1:
                console.log("Option Ruben");
				voice="Ruben"
                break;
            case 2:
                console.log("Option Lotte");
				voice="Lotte"
                break;
            default:
                console.log("Invalid");
                break;
        }
		
		switch (radioButtonList2.currentIndex) {
            case 1:
                console.log("Option Fluister");
				playMessage = "<amazon:effect name=\"whispered\">" + playMessage + "</amazon:effect>"
                break;
            case 2:
                console.log("Option langzaam");
				playMessage = "<prosody rate=\"slow\">" + playMessage + "</prosody>"
                break;
			case 3:
                console.log("Option snel");
				playMessage = "<prosody rate=\"fast\">" + playMessage + "</prosody>"
                break;
			case 4:
                console.log("Option laag");
				playMessage = "<prosody pitch=\"-20%\">" + playMessage + "</prosody>"
                break;
			case 5:
                console.log("Option hoog");
				playMessage = "<prosody pitch=\"high\">" + playMessage + "</prosody>"
                break;
            default:
                console.log("Invalid");
                break;
        }

		app.messageResult = ""
		if(selectedZone == "Alle"){
			if (debugOutput) console.log("*********sonos playing to alle")
			for (var i in app.sonosArray){
				app.playEffectTexttoSonos(i, playMessage,voice,app.messageVolume)
				removemessageResultTimer.start()
			}
		}else{
			if (debugOutput) console.log("*********sonos playing to: " + app.sonosArray[listview1.currentIndex-1].group.id)
			if (debugOutput) console.log("*********sonos playing to: " + app.sonosArray[listview1.currentIndex-1].player.id)
			if (debugOutput) console.log("*********sonos playing message is: " + playMessage)
			app.playEffectTexttoSonos(listview1.currentIndex-1, playMessage,voice,app.messageVolume)
			removemessageResultTimer.start()
		}
	}	
	

	function updatePlayersList() {
		if (debugOutput) console.log("*********sonos updatePlayersList()")
		model.clear()
		listview1.model.append({name: "Alle"});
		numberofItems =  app.sonosArray.length
		for (var i in app.sonosArray) {
			listview1.model.append({name: app.sonosArray[i].player.name})
		}
	}
	
	

	function updateMessageTextList() {
		if (debugOutput) console.log("*********sonos updateMessageTextList")
		model2.clear()
		numberofItems2 =  app.messageTextArray.length
		for (var i in app.messageTextArray) {
			console.log(app.messageTextArray[i])
			listview2.model.append({name: app.messageTextArray[i]})
		}
	}



	function removeText(item) {
		if (item > -1) {
  			app.messageTextArray.splice(item, 1);
		}
		app.saveSettings();
		updateMessageTextList();
	}
	
	

	function saveNewText(text) {
		if (text) {
			app.messageTextArray.push(text);
			app.saveSettings();
			updateMessageTextList();
		}
	}

	function saveVolume(text) {
		if (text) {
			app.messageVolume = text;
			saveVolumeLabel.inputText = app.messageVolume;
			app.saveSettings();
		}
	}


	function validateVolume(text, isFinalString) {
		if (isFinalString) {
			if ((parseInt(text) > 9) && (parseInt(text) < 101))
				return null;
			else
				return {title: "Ongeldig volume", content: "Voer een getal in tussen 10 en 100"};
		}
		return null;
	}

	Text {
		id: zoneTXT
		width:  160
		text: "Zone:"
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.bold.name
		anchors {
			top:		parent.top
			left:   	parent.left
			leftMargin : isNxt ? 20 : 16
		}
	}


	Rectangle{
		id: listviewContainer1
		width: isNxt ? parent.width/2 -100 : parent.width/2 - 80
		height: isNxt ? 200 : 160
		color: "white"
		radius: isNxt ? 5 : 4
		border.color: "black"
		border.width: isNxt ? 3 : 2
		anchors {
			top:		zoneTXT.bottom
			left:   	zoneTXT.left
			topMargin : isNxt ? 5 : 4
		}

		Component {
			id: aniDelegate
			Item {
				width: isNxt ? (parent.width-20) : (parent.width-16)
				height: isNxt ? 22 : 18
				Text {
					id: tst
					text: name
					font.pixelSize: isNxt ? 18:14
					font.family: qfont.bold.name
				}
			}
		}

		ListModel {
				id: model
		}
		ListView {
			id: listview1
			anchors {
				top: parent.top
				topMargin:isNxt ? 20 : 16
				leftMargin: isNxt ? 12 : 9
				left: parent.left
			}
			width: parent.width
			height: isNxt ? (parent.height-50) : (parent.height-40)
			model:model
			delegate: aniDelegate
			highlight: Rectangle { 
				color: "lightsteelblue"; 
				radius: isNxt ? 5 : 4
			}
			focus: true
		}
	}


	IconButton {
		id: upButton
		anchors {
			top: listviewContainer1.top
			left:  listviewContainer1.right
			leftMargin : isNxt? 3 : 2
		}

		iconSource: "qrc:/tsc/up.png"
		onClicked: {
		    if (listview1.currentIndex>0){
                    listview1.currentIndex  = listview1.currentIndex -1
            }
		}	
	}
	

	IconButton {
		id: downButton
		anchors {
			bottom: listviewContainer1.bottom
			left:  upButton.left
		}
		iconSource: "qrc:/tsc/down.png"
		onClicked: {
		    if (numberofItems>listview1.currentIndex){
                   listview1.currentIndex  = listview1.currentIndex +1
            }
		}	
	}
	
	EditTextLabel4421 {
		id: saveVolumeLabel
		width: listviewContainer1.width
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 125 : 100
		leftText: "Volume:"
		anchors {
			left: listviewContainer1.left
			top: listviewContainer1.bottom
			topMargin: isNxt ? 10 : 8
		}

		onClicked: {
			message1Index = listview1.currentIndex
			message2Index = listview1.currentIndex
			message3Index = radioButtonList1.currentIndex
			message4Index = radioButtonList2.currentIndex
			qnumKeyboard.open("Volume (20 - 100)", saveVolumeLabel.inputText, app.messageVolume, 1,  saveVolume, validateVolume);
			qnumKeyboard.maxTextLength = 3;
			qnumKeyboard.state = "num_integer_clear_backspace";
		}
	}
	
	Text {
		id: voiceTXT
		width:  160
		text: "Stem:"
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.bold.name
		anchors {
			left: listviewContainer1.left
			top: saveVolumeLabel.bottom
			topMargin: isNxt ? 10 : 8
		}
	}

	SonosRadioButtonList {
		id: radioButtonList1
		width: listviewContainer1.width
		height: 60
		gridCellWidth: isNxt ? 200:157
		gridCellHeight: isNxt ? 32:25
		radioWidth: isNxt ? 180:64
		radioHeight:isNxt ? 29:23
		backgroundColor:colors.canvas
		
		anchors {
			left: listviewContainer1.left
			top: voiceTXT.bottom
			topMargin: isNxt ? 5 : 4
		}
		Component.onCompleted: {
			addItem("Google");
			addItem("Ruben");
			addItem("Lotte");
			forceLayout();
		}
	}
	
	Text {
		id: effectTXT
		width:  160
		text: "Effect:"
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.bold.name
		anchors {
			left: listviewContainer1.left
			top: radioButtonList1.bottom
			topMargin: isNxt ? 10 : 8
		}
		visible: radioButtonList1.currentIndex>0
	}

	SonosRadioButtonList {
		id: radioButtonList2
		width: listviewContainer1.width
		height: 90
		gridCellWidth: isNxt ? 200:157
		gridCellHeight: isNxt ? 32:25
		radioWidth: isNxt ? 180:64
		radioHeight:isNxt ? 29:23
		backgroundColor:colors.canvas
		
		anchors {
			left: listviewContainer1.left
			top: effectTXT.bottom
			topMargin: isNxt ? 5 : 4
		}
		title: qsTr("Local access")

		Component.onCompleted: {
			addItem("Standaard)");
			addItem("Fluister");
			addItem("Langzaam");
			addItem("Snel");
			addItem("Laag");
			addItem("Hoog");
			forceLayout();
		}
		visible: radioButtonList1.currentIndex>0
	}
////////////////////////////////////////////////////////////////////////////////////////////////


	Text {
		id: messageTXT
		width:  160
		text: "Bericht:"
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.bold.name
		anchors {
			top:		zoneTXT.top
			left:   	upButton.right
			leftMargin : isNxt ? 20 : 16
		}
	}


	Rectangle{
		id: listviewContainer2
		width: isNxt ? parent.width/2 -100 : parent.width/2 - 80
		height: isNxt ? 200 : 160
		color: "white"
		radius: isNxt ? 5 : 4
		border.color: "black"
		border.width: isNxt ? 3 : 2
		anchors {
			top:		messageTXT.bottom
			left:   	messageTXT.left
			topMargin : isNxt ? 5 : 4
		}

		Component {
			id: aniDelegate2
			Item {
				width: isNxt ? (parent.width-20) : (parent.width-16)
				height: isNxt ? 22 : 18
				Text {
					id: tst
					text: name
					font.pixelSize: isNxt ? 18:14
					font.family: qfont.bold.name
				}
			}
		}

		ListModel {
				id: model2
		}
		ListView {
			id: listview2
			anchors {
				top: parent.top
				topMargin:isNxt ? 20 : 16
				leftMargin: isNxt ? 12 : 9
				left: parent.left
			}
			width: parent.width
			height: isNxt ? (parent.height-50) : (parent.height-40)
			model:model2
			delegate: aniDelegate2
			highlight: Rectangle { 
				color: "lightsteelblue"; 
				radius: isNxt ? 5 : 4
			}
			focus: true
		}
	}


	IconButton {
		id: upButton2
		anchors {
			top: listviewContainer2.top
			left:  listviewContainer2.right
			leftMargin : isNxt? 3 : 2
		}

		iconSource: "qrc:/tsc/up.png"
		onClicked: {
		    if (listview2.currentIndex>0){
                    listview2.currentIndex  = listview2.currentIndex -1
            }
		}	
	}
	
	IconButton {
		id: deleteButton2
		color: colors.background
		anchors {
			verticalCenter: listviewContainer2.verticalCenter
			left:  upButton2.left
		}
		iconSource: "qrc:/tsc/icon_delete.png"
		onClicked: {
				if (debugOutput) console.log("*********sonos removing from messageText: " + listview2.currentIndex)
				removeText(listview2.currentIndex)
		}
		visible: numberofItems2>0
	}

	IconButton {
		id: downButton2
		anchors {
			bottom: listviewContainer2.bottom
			left:  upButton2.left
		}
		iconSource: "qrc:/tsc/down.png"
		onClicked: {
		    if (numberofItems2>listview2.currentIndex){
                   listview2.currentIndex  = listview2.currentIndex +1
            }
		}	
	}
	
	EditTextLabel4421 {
		id: saveNewTextLabel
		width: listviewContainer2.width
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 125 : 100
		leftText: "Nieuw:"
		anchors {
			left: listviewContainer2.left
			top: listviewContainer2.bottom
			topMargin: isNxt ? 10 : 8
		}

		onClicked: {
			message1Index = listview1.currentIndex
			message2Index = listview1.currentIndex
			message3Index = radioButtonList1.currentIndex
			message4Index = radioButtonList2.currentIndex
			qkeyboard.open("Nieuwe Text", saveNewTextLabel.inputText, saveNewText);
		}
	}
	
	
	SonosStandardButton {
		id: playTextButton
		text: "Speel af!"
		width: listviewContainer2.width
		fontColorUp: "black"
		fontPixelSize: isNxt ? 20 : 16
		anchors {
			left: listviewContainer2.left
			top: saveNewTextLabel.bottom
			topMargin: isNxt? 50:40
		}
		onClicked: {
			if (radioButtonList1.currentIndex>0){
				playEffectTexttoSonos()
			}else{
				playTexttoSonos()
			}
		}
	}
	
	
	Text {
		id: resultTXT
		width: listviewContainer2.width
		text: app.messageResult
		font.pixelSize: isNxt? 22:18
		font.family: qfont.bold.name

		anchors {
			left: listviewContainer2.left
			top: playTextButton.bottom
			topMargin: isNxt? 20:16
		}
	}

	Timer {
		id: removemessageResultTimer
		interval: 4000
		onTriggered: {
			app.messageResult = ""
		}
	}

}