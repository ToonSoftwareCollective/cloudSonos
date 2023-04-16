import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: sonosConfigScreen
	property bool debugOutput : app.debugOutput
	screenTitle: qsTr("Sonos Instellingen")
	property bool    	tmpShowSonosIcon: app.showSonosIcon;
	property bool    	tmpVisible: app.visibleInDimState;
	property bool    	tmpPlayFootballScores : app.playFootballScores;
	property string    	tmpUserName: app.userName;
	property string		tmpPassWord: app.passWord;
	property int		tmpMessageVolume: app.messageVolume;
	property string		tmpSonosNameVoetbalApp: app.sonosNameVoetbalApp;
	property int 		numberofItems:0
	property bool		fromDisclaimer : false
	property string		rightButtonText: "Opslaan";

	
	onShown: {
		if (debugOutput) console.log("*********sonos configScreen loaded")
		showSonosIconToggle.isSwitchedOn = tmpShowSonosIcon;
		voetbalToggle.isSwitchedOn = tmpPlayFootballScores;
		visibleToggle.isSwitchedOn = tmpVisible;
		addCustomTopRightButton(rightButtonText);
		userNameLabel.inputText = tmpUserName;
		passWordLAbel.inputText = tmpPassWord;
		if (debugOutput) console.log("*********sonos tmpUserName: " + tmpUserName)
		if (debugOutput) console.log("*********sonos tmpPassWord: " + tmpPassWord)
		saveVoetbalVolumeLabel.inputText = tmpMessageVolume;
		updatePlayersList()
		if (debugOutput) console.log("*********sonos configScreen loaded app.sonosWarningShown: " + app.sonosWarningShown)
	}

	function showPopup() {
		qdialog.showDialog(qdialog.SizeLarge, "Informatie", "\
			<center><b>SONOS</b></center><br>\
			Door het gebruik van de app sta je Toon toe om je Sonos-systeem te bedienen.<br> Dit geeft Toon toestemming om:\
			<ul>\
			<li>te zien wat je Sonos afspeelt</li>\
			<li>afspelen en volume op je Sonos aan te passen</li>\
			<li>je Sonos-kamers en -groepen aan te passen</li>\
			<li>je Sonos-favorieten en -playlists af te spelen</li>\
			</ul>\
			Je gaat ermee akkoord dat Toon ervoor verantwoordelijk is dat jouw informatie volgens hun privacybeleid wordt gebruikt.\
			Het privacybeleid van Sonos is van toepassing op het gebruik van Sonos-producten. " , fromDisclaimer? "Sluiten" : "Afwijzen", null, fromDisclaimer? null : "Akoord", function() {
				if (debugOutput) console.log("*********sonos configScreen showPopup agreed ")
				saveSettings()
			});
			fromDisclaimer = false
	}
	
	
	function saveSettings(){
		app.sonosWarningShown = true
		app.showSonosIcon =tmpShowSonosIcon
		app.visibleInDimState =tmpVisible
		app.playFootballScores = tmpPlayFootballScores 
		app.userName = tmpUserName
		app.passWord = tmpPassWord
		app.messageVolume=tmpMessageVolume;
		app.sonosNameVoetbalApp = tmpSonosNameVoetbalApp
		app.savedFromConfigScreen = true
		app.saveSettings();
	}

	onCustomButtonClicked: {
		if (!app.sonosWarningShown){
			app.needReboot = true
			showPopup()
		}else{
			saveSettings()
		}
	}
	
	function updatePlayersList() {
		if (debugOutput) console.log("*********sonos updatePlayersList()")
		model.clear()
		numberofItems =  app.sonosArray.length
		for (var i in app.sonosArray) {
			listview1.model.append({name: app.sonosArray[i].group.name})
		}
	}
	
	function saveUserName(text) {
		if (text) {
			tmpUserName = text;
			app.needReboot = true
		}
	}
	
	function savePassWord(text) {
		if (text) {
			tmpPassWord = text;
			app.needReboot = true
		}
	}
	
	function saveVolume(text) {
		if (text) {
			tmpMessageVolume = text;
			saveVoetbalVolumeLabel.inputText=tmpMessageVolume
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
		id: titleText
		anchors {
			left: parent.left
			top: parent.top
			leftMargin: 20
			topMargin: isNxt ? 8 : 6
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		text: "Configureer hier de instellingen voor Sonos"
	}


	EditTextLabel4421 {
		id: userNameLabel
		height: isNxt ? 35 : 28
		width: isNxt ? 800 : 600
		leftText: qsTr("Gebruikersnaam voor de Sonos app")
		leftTextAvailableWidth:isNxt ? 500 : 400
		anchors {
			left: titleText.left
			top: titleText.bottom
			topMargin: isNxt ? 8 : 6
		}

		onClicked: {
		    rightButtonText= "Opslaan en herstarten";
		    //stage.customButton.label = "Opslaan en herstarten";
			qkeyboard.open("Gebruikersnaam", userNameLabel.inputText, saveUserName)
		}
	}
			

	EditTextLabel4421 {
		id: passWordLAbel
		height: isNxt ? 35 : 28
		width: isNxt ? 800 : 600
		leftText: qsTr("Wachtwoord voor de Sonos app")
		leftTextAvailableWidth:isNxt ? 500 : 400
		anchors {
			left: titleText.left
			top: userNameLabel.bottom
			topMargin: isNxt ? 8 : 6
		}
		onClicked: {
			rightButtonText= "Opslaan en herstarten";
			qkeyboard.open("Wachtwoord", passWordLAbel.inputText, savePassWord)
		}
	}

	Text {
		id: systrayText
		anchors {
			left: titleText.left
			top: passWordLAbel.bottom
			topMargin: isNxt ? 8 : 6
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		text: "Sonos icoon zichtbaar op systray?"
	}
	
	OnOffToggle {
		id: showSonosIconToggle
		height: 36
		anchors {
			left: systrayText.right
			top: systrayText.top
			leftMargin: 15
		}
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				tmpShowSonosIcon=true
			} else {
				tmpShowSonosIcon=false
			}
		}
	}
	
	Text {
		id: visibleText
		anchors {
			left: titleText.left
			top: systrayText.bottom
			topMargin: isNxt ? 6 : 5
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		text: "Afbeelding zichtbaar in gedimde modus?"
	}
	
	OnOffToggle {
		id: visibleToggle
		height: 36
		anchors {
			left: visibleText.right
			top: visibleText.top
			leftMargin: 15
		}
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				tmpVisible=true
			} else {
				tmpVisible=false
			}
		}
	}
	
	Text {
		id: voetbalText
		anchors {
			left: titleText.left
			top: visibleText.bottom
			topMargin: isNxt ? 6 : 5
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		text: "Voetbal tussenstanden afspelen (configureren via voetbal app)?"
	}
	
	OnOffToggle {
		id: voetbalToggle
		height: 36
		anchors {
			left: voetbalText.right
			top: voetbalText.top
			leftMargin: 15
		}
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				tmpPlayFootballScores = true
			} else {
				tmpPlayFootballScores = false
			}
		}
	}
	
	Text {
		id: voetbalZone
		text: "Selecteerd de  zone om de voetbalstanden door te geven?"
		anchors {
			left: titleText.left
			top: voetbalToggle.bottom
			topMargin: isNxt ? 6 : 5
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		visible: voetbalToggle.isSwitchedOn
	}
	
	Rectangle{
		id: listviewContainer1
		width: isNxt ? parent.width/2 -100 : parent.width/2 - 80
		height: isNxt ? 140 : 112
		color: "white"
		radius: isNxt ? 5 : 4
		border.color: "black"
		border.width: isNxt ? 3 : 2
		anchors {
			top:		voetbalZone.bottom
			left: titleText.left
			topMargin: isNxt ? 6 : 5
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
		visible: voetbalZone.visible
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
		visible: voetbalZone.visible
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
		visible: voetbalZone.visible		
	}
	
	
	SonosStandardButton {
		id: selectZone
		text: "Selecteer deze zone"
		width: listviewContainer1.width
		height: isNxt ? 40 : 32
		fontColorUp: "darkslategray"
		fontPixelSize: isNxt ? 20 : 16
		anchors {
			left: listviewContainer1.left
			top: listviewContainer1.bottom
			topMargin: isNxt ? 8 : 6
		}
		onClicked: {
			tmpSonosNameVoetbalApp = app.sonosArray[listview1.currentIndex].group.name
		}
		visible: voetbalZone.visible
	}
				
	
	Text {
		id: voetbalZoneSelected
		text: "Geselecteerd: " + tmpSonosNameVoetbalApp
		anchors {
			left: titleText.left
			top: selectZone.bottom
			topMargin: isNxt ? 6 : 5
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.bold.name
		}
		wrapMode: Text.WordWrap
		visible: voetbalZone.visible
	}


	EditTextLabel4421 {
		id: saveVoetbalVolumeLabel
		width: listviewContainer1.width
		height: isNxt ? 35 : 28
		leftTextAvailableWidth: isNxt ? 125 : 100
		leftText: "Volume:"
		anchors {
			left: listviewContainer1.left
			top: voetbalZoneSelected.bottom
			topMargin: isNxt ? 8 : 6
		}

		onClicked: {
			qnumKeyboard.open("Volume (20 - 100)", saveVoetbalVolumeLabel.inputText, tmpMessageVolume, 1,  saveVolume, validateVolume);
			qnumKeyboard.maxTextLength = 3;
			qnumKeyboard.state = "num_integer_clear_backspace";
		}
		visible: voetbalZone.visible
	}
		
	SonosStandardButton {
		id: disclaimerButton
		text: "Disclaimer"
		width: isNxt ? 140 : 112
		height: isNxt ? 40 : 32
		fontColorUp: "darkslategray"
		fontPixelSize: isNxt ? 20 : 16
		anchors {
			right: parent.right
			bottom: parent.bottom
			topMargin: isNxt ? 8 : 6
			rightMargin : isNxt ? 8 : 6
		}
		onClicked: {
			fromDisclaimer = true
			showPopup() 
		}
	}
}
