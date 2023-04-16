//
// Sonos v3.2 by Harmen Bartelink
// Further enhanced by Toonz after Harmen stopped developing
// Further enhanced by oepi-loepi to make it work without broker
//

import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import ScreenStateController 1.0
import FileIO 1.0
import "SonosTokenFunctions.js" as SonosTokenFunctions


App {
	id: root
	property url 	tileUrl : "SonosTile.qml"
	property 		SonosConfigScreen sonosConfigScreen
	property url 	sonosConfigScreenUrl : "SonosConfigScreen.qml"
	property url    trayUrl : "MediaTray.qml";
	property 		SystrayIcon mediaTray2
	
	property url 	menuScreenUrl : "MenuScreen.qml"
	property url 	mediaScreenUrl : "MediaScreen.qml"
	property 		MediaScreen mediaScreen
	property url 	messageScreenUrl : "MessageScreen.qml"
	property 		MessageScreen messageScreen
	

	property url 	favoritesScreenUrl : "FavoritesScreen.qml"
	property 		FavoritesScreen favoritesScreen
	
	//property url 	thumbnailIcon: "qrc:/tsc/SonosThumb.png"
	property url 	thumbnailIcon: "qrc:/tsc/SonosSystrayIcon.png"
	
	property bool 	debugOutput: false
	
	property bool 	isFirstRun: true
	property int 	numberofTries:0
	property bool 	sonosWarningShown: false
    property bool 	sonosNameIsGroup: false
    property bool 	playButtonVisible : false
    property bool 	pauseButtonVisible : false
	property bool 	showSlider: true
	property bool 	visibleInDimState: false
	
	property int 	favoriteScreenRadioOption1: 0
	
	property bool 	tokenOK: true
	property bool 	lineInAvailable:false
	property bool 	savedFromConfigScreen:false
	property string  containerType: ""
	property string  streamInfo: ""
	
	property variant playlist : []
	property variant favorites: []
	property variant sonosArray: []
	property int 	playerIndex: 0
	property int 	numberofItems: 0
	
	property variant messageTextArray : ["Hallo","Hallo daar, het eten staat klaar"]

	property string messageSonosName : "Alle"
	property int 	messageVolume : 20
	property string  messageText
	
	property int message1Index: 0
	property int message2Index: 0
	property int message3Index: 0
	property int message4Index: 0

    property string  households: ""
    property string  groupID: ""
    property string  groupName: ""
    property string  playerID: ""
    property string  playerName: ""
    property int     groupVolume: 0
    property bool    groupMuted: false

    property bool  	shuffle: false
    property bool  	repeatOne: false
    property bool  	repeat: false
	property bool  	crossfade: false

    property string  playModes: ""
    property int     positionMillis:0
    property string  playbackState: ""
    property string  stationName: ""
	
	property string  messageResult: ""
	

    property string  currentItemName: ""
    property string  currentItemImageUrl: ""
    property string  currentItemTrackArtistName: ""
    property int     currentItemTrackDurationMillis:0
	property bool 	 currentLineInAvailable:false
	
    property string  nextItemName: ""
    property string  nextItemTrackArtistName: ""

	property string  currentItemNameShort: ""
    property string  currentItemTrackArtistNameShort: ""
    property string  nextItemNameShort: ""
    property string  nextItemTrackArtistNameShort: ""
	

	property bool    showSonosIcon : true
	property string  sonosName : ""
	property string  sonosNameVoetbalApp : ""
	property string  userName : ""
	property string  passWord : ""
	property string  token: ""
	property string  refreshToken : ""
	property bool    playFootballScores : false
	
	property bool    needReboot: false
	

	property variant settings : {
		"showSonosIcon" : "true",
		"debugOutput": "false",
		"sonosWarningShown" : "false",
		"sonosName" : "",
		"sonosNameVoetbalApp" : "",
		"userName" : "",
		"passWord" : "",
		"messageText" : "",
		"messageVolume" : "",
		"messageSonosName" : "",
		"token" : "",
		"refreshToken" : "",
		"playerIndex" : 0,
		"playFootballScores" : "false",
		"visibleInDimState" : "false"
	}
	
	FileIO {
		id: sonosSettingsFile
		source: "file:///mnt/data/tsc/cloudSonos.userSettings.json"
 	}
	
	FileIO {
		id: sonosTokenFile
		source: "file:///qmf/qml/apps/cloudSonos/cloudSonos.sh"
 	}
	
	function init() {
		registry.registerWidget("screen", messageScreenUrl, this, "messageScreen");
		registry.registerWidget("screen", mediaScreenUrl, this, "mediaScreen");
		registry.registerWidget("systrayIcon", trayUrl, this, "mediaTray2");
		registry.registerWidget("screen", favoritesScreenUrl, this, "favoritesScreen");
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: qsTr("sonosCloud"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", sonosConfigScreenUrl, this, "sonosConfigScreen");
	}
	
	Component.onCompleted: {
		try{
			tscsignals.tscSignal.connect(playMessage);
			if (debugOutput) console.log("*********sonos tscSignal connected")
		} catch(e) {
		}
		sleep(1000);
		readSettings();
	}
	

	function sleep(milliseconds) {
      var start = new Date().getTime();
      while ((new Date().getTime() - start) < milliseconds )  {
      }
    }


	function readSettings() {
		if (debugOutput) console.log("*********sonos readSettings()")
		try {
			var settingsString = sonosSettingsFile.read();
			settings = JSON.parse(settingsString);
			if (settings['debugOutput']) debugOutput = (settings['debugOutput'] == "true");
			if (settings['showSonosIcon']) showSonosIcon = (settings['showSonosIcon'] == "true");
			if (settings['sonosWarningShown']) sonosWarningShown = (settings['sonosWarningShown'] == "true");
			if (settings['sonosName']) sonosName = (settings['sonosName']);
			if (settings['sonosNameVoetbalApp']) sonosNameVoetbalApp = (settings['sonosNameVoetbalApp']);
			if (settings['userName']) userName = (settings['userName']);
			if (settings['messageVolume']) messageVolume = (settings['messageVolume']);
			if (settings['messageSonosName']) messageSonosName = (settings['messageSonosName']);
			if (settings['messageText']) messageTextArray = (settings['messageText']);
			if (settings['passWord']) passWord = (settings['passWord']);
			if (settings['token']) token = (settings['token']);
			if (settings['refreshToken']) refreshToken = (settings['refreshToken']);
			if (settings['playerIndex']) playerIndex = (settings['playerIndex']);
			if (settings['playFootballScores']) playFootballScores = (settings['playFootballScores'] == "true");
			if (settings['visibleInDimState']) visibleInDimState = (settings['visibleInDimState'] == "true");
		} catch(e) {
		}
		sleep(1000);
		checkBash();
		sleep(1000);
		//if (showSonosIcon) {
		//	mediaTray2.show();
		//} else {
		//	mediaTray2.hide();
		//}
    }
	
	function saveSettings() {
		if (debugOutput) console.log("*********sonos saveSettings()")
		
		var tmpTrayIcon = "";
		if (showSonosIcon == true) {
			tmpTrayIcon = "true";
		} else {
			tmpTrayIcon = "false";
		}
		
		var tmpWarning = "";
		if (sonosWarningShown) {
			tmpWarning = "true";
		} else {
			tmpWarning = "false";
		}
		
		var tmpVoetbal = "";
		if(playFootballScores){
			tmpVoetbal = "true"
		}else{
			tmpVoetbal = "false"
		}

		var tmpdebugOutput = "";
		if (debugOutput) {
			tmpdebugOutput = "true";
		} else {
			tmpdebugOutput = "false";
		}

		var tmpVisible = "";
		if (visibleInDimState) {
			tmpVisible = "true";
		} else {
			tmpVisible = "false";
		}

		settings["showSonosIcon"] = tmpTrayIcon;
		settings["sonosWarningShown"] = tmpWarning;
		settings["debugOutput"] = tmpdebugOutput;
		settings["userName"] = userName;
		settings["passWord"] = passWord;
		settings["sonosName"] = sonosName;
		settings["sonosNameVoetbalApp"] = sonosNameVoetbalApp;
		settings["token"] = token;
		settings["refreshToken"] = refreshToken;
		settings["messageText"] = messageTextArray;
		settings["messageSonosName"] = messageSonosName;
		settings["messageVolume"] = messageVolume;
		settings["playFootballScores"] = tmpVoetbal;
		settings["visibleInDimState"] = tmpVisible;
		settings["playerIndex"] = playerIndex;
		
		sonosSettingsFile.write(JSON.stringify(settings));
		
		if (debugOutput) console.log("*********sonos saveSettings() file saved")
		
		sleep(1000)
		
		if (showSonosIcon) {
			mediaTray2.show();
		} else {
			mediaTray2.hide();
		}
		
		if(savedFromConfigScreen & needReboot){
			Qt.quit()
		}else{
			sonosConfigScreen.hide()
		}
	}

    function getHouseholdsAndGroups(){
        if (debugOutput) console.log("*********sonos getHouseholds first and then groups")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("GET", "https://api.ws.sonos.com/control/api/v1//households");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log("sonos getHouseholds first and then groups response:" + xhr.responseText)
                    var JsonString = xhr.responseText
                    var JsonObject= JSON.parse(JsonString)
                    if (JsonObject.households[0]) {households = JsonObject.households[0].id} else {tokenOK = false;SonosTokenFunctions.getRefreshToken()}
                    getGroups()
				}else{
					if (debugOutput) console.log("sonos getHouseholds first and then groups fault response:" + xhr.responseText)
					if (xhr.responseText.indexOf("keymanagement.service")> 0){
						tokenOK = false
						SonosTokenFunctions.getRefreshToken()
					}
				}
            }
        }
        xhr.send()
    }

    function getGroups(){
        if (debugOutput) console.log("*********sonos getGroups")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("GET", "https://api.ws.sonos.com/control/api/v1/households/" + households + "/groups");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
					sonosArray = []
                    var JsonString = xhr.responseText
                    var JsonObject= JSON.parse(JsonString)
					for (var a in JsonObject.groups){
						for (var i in JsonObject.players){
							if(JsonObject.groups[a].playerIds==JsonObject.players[i].id){
								for (var b in JsonObject.players[i].capabilities){
									if(JsonObject.players[i].capabilities[b]==="LINE_IN"){lineInAvailable=true}else{lineInAvailable=false}	
								}
								numberofItems++
								sonosArray.push({"group" : {"id": JsonObject.groups[a].id, "name": JsonObject.groups[a].name, "lineInAvailable" : lineInAvailable},"player":{"id": JsonObject.players[i].id, "name": JsonObject.players[i].name, "lineInAvailable" : lineInAvailable}})
								if (debugOutput) console.log("*********sonos sonosArray.push:  " + "{\"group\" : {\"id\": " + JsonObject.groups[a].id + " , \"name\": " + JsonObject.groups[a].name + ", \"lineInAvailable\" : " + lineInAvailable + "},\"player\":{\"id\": " + JsonObject.players[i].id + ", \"name\": " + JsonObject.players[i].name + ", \"lineInAvailable\" : " + lineInAvailable + "}}")
							}
						}
					}
					
					if(playerIndex>=numberofItems){playerIndex = 0}

                    groupID = sonosArray[playerIndex].group.id
                    groupName = sonosArray[playerIndex].group.name
                    playerID = sonosArray[playerIndex].player.id
                    playerName = sonosArray[playerIndex].player.name
						
                    if (debugOutput) console.log(groupID)
                    if (debugOutput) console.log(groupName)
                    if (debugOutput) console.log(playerID)
                    if (debugOutput) console.log(playerName)
					setAfterTotalStartTimer.running = true
					sonosPlayInfoTimer.running = true
					//get images for the favorites
					favoritesScreen.updateFavoriteslist()
                }else{
					if (debugOutput) console.log("sonos getGroups fault response:" + xhr.responseText)
					if (xhr.responseText.indexOf("keymanagement.service")> 0){
						tokenOK = false
						SonosTokenFunctions.getRefreshToken()
					}
				}
            }
        }
        xhr.send()
    }

    function getGroupVolume(){
        if (debugOutput) console.log("*********sonos getGroupVolume")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("GET", "https://api.ws.sonos.com/control/api/v1/groups/" + sonosArray[playerIndex].group.id + "/groupVolume");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    var JsonString = xhr.responseText
                    var JsonObject= JSON.parse(JsonString)
                    groupVolume = JsonObject.volume
                    groupMuted = JsonObject.muted
                    if (debugOutput) console.log(groupVolume)
                    if (debugOutput) console.log(groupMuted)
                }
            }
        }
        xhr.send()
    }

    function setGroupVolume(volume){
        if (debugOutput) console.log("*********sonos setGroupVolume:  " + setGroupVolume)
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/groupVolume");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    getGroupVolume()
                }
            }
        }
        xhr.send(JSON.stringify({"volume": volume}));
    }
	
	function setSeek(position){
        if (debugOutput) console.log("*********sonos setSeek:  " + position)
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/playback/seek");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    getPlaybackStatus()
                }
            }
        }
        xhr.send(JSON.stringify({"positionMillis": position}));
  }


    function setPlayModes(){
        if (debugOutput) console.log("*********sonos setPlayModes")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/playback/playMode");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    getPlaybackStatus()
                }
            }
        }
        xhr.send(JSON.stringify({"playModes": {"repeat": repeat,"repeatOne": repeatOne ,"crossfade": crossfade,"shuffle": shuffle}}));
    }
	
	function setPlayList(playlistid){
        if (debugOutput) console.log("*********sonos setPlayList : " + playlistid)
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/playlists");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    getMetaData()
                }
            }
        }
        xhr.send(JSON.stringify({"playlistId" : playlistid}));
    }
	
	function postGroupCommand(command, params){
        if (debugOutput) console.log("*********sonos postGroupCommand : " + command +", "+ params )
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/" + command);
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log("*********sonos postGroupCommand : " +xhr.responseText)
                    getMetaData()
                }
				if (debugOutput) console.log("*********sonos postGroupCommand error : " + xhr.status +", "+ xhr.responseText )
            }
        }
        xhr.send(params);
    }
  
    function getPlaybackStatus(){
        if (debugOutput) console.log("*********sonos getPlaybackStatus")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("GET", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/playback");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    var JsonString = xhr.responseText
                    var JsonObject= JSON.parse(JsonString)
                    shuffle = JsonObject.playModes.shuffle
                    repeatOne = JsonObject.playModes.repeatOne
                    repeat = JsonObject.playModes.repeat
					crossfade  = JsonObject.playModes.crossfade
					
                    positionMillis = JsonObject.positionMillis
					if(currentItemTrackDurationMillis>0){
						mediaScreen.positionIndicatorX = Math.floor((positionMillis / currentItemTrackDurationMillis) * mediaScreen.positionIndicatorWidth)
					}
                    playbackState = JsonObject.playbackState
					if (playbackState == "PLAYBACK_STATE_PAUSED" || playbackState == "PLAYBACK_STATE_IDLE"){pauseButtonVisible =false ; playButtonVisible = true}
					if (playbackState == "PLAYBACK_STATE_PLAYING"){pauseButtonVisible =true ; playButtonVisible = false}
					if (pauseButtonVisible) {
						sonosTrackTimer.start()
					} else {
						sonosTrackTimer.stop()
					} 
                }
            }
        }
        xhr.send()
    }
	
	function breakAtWholeWord(sentence, maxLength) {
	if (debugOutput) console.log("*********sonos sentence: " + sentence)
	if (debugOutput) console.log("*********sonos maxLength: " + maxLength)
		if (sentence.length > maxLength){
			var lastWordIndex = sentence.lastIndexOf(" ", maxLength)
			if (debugOutput) console.log("*********sonos lastWordIndex: " + lastWordIndex)
			if (lastWordIndex === -1) {
				// If no space was found, break at the maximum width
				lastWordIndex = maxLength
				sentence = sentence.substring(0, lastWordIndex)
			}
			sentence = sentence.substring(0, lastWordIndex)  + ".."
		}else{
			sentence = sentence
		}
		if (debugOutput) console.log("*********sonos return sentence: " + sentence)
		return sentence
	}

    function getMetaData(){
        if (debugOutput) console.log("*********sonos playbackMetadata")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("GET", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/playbackMetadata");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    var JsonString = xhr.responseText
					var containerType
                    var JsonObject= (JSON.parse(JsonString))
					if(JsonObject.container && JsonObject.container.type){
						containerType=JsonObject.container.type
					}else if(JsonObject.hasOwnProperty('currentItem')){
						containerType=JsonObject.currentItem.track.type
					}else{
					}
					stationName=""
					currentItemName=""
					currentItemTrackArtistName=""
					currentItemImageUrl=""
					streamInfo = ""
					if(containerType=="station"){
							showSlider=false
							stationName=JsonObject.container.name
							currentItemName=JsonObject.container.name
							currentItemTrackArtistName="Station"
							for (var i in favorites){
								if(favorites[i].name === stationName){
									currentItemImageUrl=favorites[i].imageUrl
								}
							}
							if(JsonObject.hasOwnProperty('streamInfo')){
								streamInfo= JsonObject.streamInfo
							}
					} else if(containerType=="linein.homeTheater"){
								showSlider=false
								stationName=""
								currentItemName="Line In"
								currentItemTrackArtistName=""
								currentItemImageUrl=""
								streamInfo = ""
					}else if (typeof containerType==="undefined"){
								showSlider=false
								stationName=""
								streamInfo = ""
								currentItemName="Geen bron"
								currentItemTrackArtistName=""
								currentItemImageUrl=""
					}else{
							showSlider=true
                      		if (JsonObject.currentItem.track.name)currentItemName=JsonObject.currentItem.track.name
                        	if (JsonObject.currentItem.track.imageUrl) currentItemImageUrl=JsonObject.currentItem.track.imageUrl
                         	if (JsonObject.currentItem.track.artist.name)currentItemTrackArtistName=JsonObject.currentItem.track.artist.name
                        	if (JsonObject.currentItem.track.durationMillis)currentItemTrackDurationMillis=JsonObject.currentItem.track.durationMillis
							
							try{
								if (JsonObject.nextItem.track.name)nextItemName=JsonObject.nextItem.track.name
								if (JsonObject.nextItem.track.artist.name)nextItemTrackArtistName=JsonObject.nextItem.track.artist.name	
							} catch(e) {
							}
							streamInfo = ""					
                	}
					
					currentItemNameShort = breakAtWholeWord(currentItemName, 38);
					currentItemTrackArtistNameShort = breakAtWholeWord(currentItemTrackArtistName, 38);
					nextItemNameShort = breakAtWholeWord(nextItemName, 38);
					nextItemTrackArtistNameShort = breakAtWholeWord(nextItemTrackArtistName, 38);
					currentLineInAvailable =  sonosArray[playerIndex].group.lineInAvailable
           	} else {
				if (debugOutput) console.log("*********sonos playbackMetadata error response:" + xhr.responseText)
				if (xhr.responseText.indexOf("invalid_access_token")> 0){
					tokenOK = false;
					SonosTokenFunctions.getFirstToken();
				}
				if (xhr.responseText.indexOf("token_expired")> 0){
					tokenOK = false;
					SonosTokenFunctions.getRefreshToken();
				}
			}
            	}
        }
        xhr.send()
    }

    function setSimpleGroupCommand(command){
        if (debugOutput) console.log("*********sonos setSimpleGroupCommand:  " + setSimpleGroupCommand)
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/" + command);
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
					if(isFirstRun){isFirstRun=false;getGroupVolume()}
                }
            }
        }
        xhr.send();
    }
		
	function playMessage(appName, appArguments) {
		if ((appName == "sonos") && playFootballScores) {
		if (debugOutput) console.log("*********sonos tscSignal received.. playing footballscores")
		if (debugOutput) console.log("*********sonos sonosNameVoetbalApp:  " + sonosNameVoetbalApp)
			for(var i in sonosArray){
			if (debugOutput) console.log("*********sonos sonosArray[i].group.name:  " + sonosArray[i].group.name)
				if (sonosArray[i].group.name === sonosNameVoetbalApp){
				if (debugOutput) console.log("*********sonos match!")
				if (debugOutput) console.log("*********sonos setSimpleGroupCommand:  " + setSimpleGroupCommand)
					playMessageToSonos(i, appArguments, messageVolume)
				}
			}
		}
	}
	
	function playMessageToSonos(playerIndex, message, volume){
        if (debugOutput) console.log("*********sonos sendToSonos:  " + message)
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/players/"+ sonosArray[playerIndex].player.id + "/audioClip");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
					messageResult = "Afspelen gelukt" ; 
                }else{
					messageResult = "Fout bij afspelen"
				}
            }
        }
        xhr.send(JSON.stringify({"name": "ACME","appId": "com.acme.app","volume": volume,"streamUrl": "http://translate.google.com/translate_tts?client=tw-ob&tl=nl&q=" + encodeURIComponent(message),"clipType": "CUSTOM"}));
	}
	
	
	function playEffectTexttoSonos(playerIndex, message,voice,volume){
      if (debugOutput) console.log("*********sonos creating tts message:  " + message)
      var xhr = new XMLHttpRequest()
      xhr.withCredentials = true
      var body= "msg=" + encodeURIComponent(message) + "&lang=" + voice + "&source=ttsmp3"
      var url =  "https://ttsmp3.com/makemp3_new.php"
      if (debugOutput) console.log(url)
      xhr.open("POST", url);
      xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
      xhr.onreadystatechange = function() {
          if(xhr.readyState === 4){
              if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    var JsonString = xhr.responseText
                    var JsonObject= JSON.parse(JsonString)
                    var ttsUrl = JsonObject.MP3
                    playTTStoSonos(playerIndex,ttsUrl, volume)
                }
          }
      }
      xhr.send(body)
	}

	function playTTStoSonos(playerIndex,ttsUrl, volume){
        if (debugOutput) console.log("*********sonos sendToSonos:  " + ttsUrl)
		var newURL = "https://ttsmp3.com/created_mp3/" + ttsUrl
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/players/"+ sonosArray[playerIndex].player.id + "/audioClip");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
					messageResult = "Afspelen gelukt" ; 
                }else{
					messageResult = "Fout bij afspelen"
				}
            }
        }
        xhr.send(JSON.stringify({"name": "ACME","appId": "com.acme.app","volume": volume,"streamUrl": newURL,"clipType": "CUSTOM"}));
	}
	
	
	function checkBash(){
		if (debugOutput) console.log("*********sonos checkBash getting credentials()")
		var http = new XMLHttpRequest()
		var url = "https://raw.githubusercontent.com/ToonSoftwareCollective/toonanimations/main/sonoscode.txt"
		http.open("GET", url);
		http.onreadystatechange = function() { // Call a function when the state changes.
			if( http.readyState === 4){
				if (http.status === 200) {
					if (debugOutput) console.log("*********sonos checkBash http.responseText " + http.responseText)
					var JsonString2 = http.responseText
					var JsonObject2 = JSON.parse(JsonString2)
					var bearerToken = JsonObject2.token
					var clientid = JsonObject2.clientid
					var newversion = JsonObject2.version
					if (debugOutput) console.log("*********sonos token : " + bearerToken)
					if (debugOutput) console.log("*********sonos clientid : " + clientid)
					if (debugOutput) console.log("*********sonos newversion : " + newversion)
					
					var content = sonosTokenFile.read();
					var oldversion = content.split("#VERSION-")[1].split("#")[0]
					if (parseInt(oldversion)< newversion){
						var searchString = "#VERSION-" + oldversion
						var replaceString = "#VERSION-" + newversion
						if (debugOutput) console.log("*********sonos searchString : " + searchString)
						content = content.replace(new RegExp(searchString, "g"), replaceString);
						
						var searchString = content.split("&client_id=")[1].split("&")[0]
						if (debugOutput) console.log("*********sonos searchString : " + searchString)
						replaceString = clientid
						content = content.replace(new RegExp(searchString, "g"), replaceString);
						
						var searchString = content.split("\'clientId=")[1].split("\"")[0]
						if (debugOutput) console.log("*********sonos searchString : " + searchString)
						replaceString = clientid
						content = content.replace(new RegExp(searchString, "g"), replaceString);
						
						var searchString = content.split("Authorization: Basic ")[1].split("\"")[0]
						if (debugOutput) console.log("*********sonos searchString : " + searchString)
						replaceString = bearerToken
						content = content.replace(new RegExp(searchString, "g"), replaceString);
						
						sonosTokenFile.write(content);
					}
					sleep(6000);
					if (debugOutput) console.log("*********sonos token found: " + token)
					if (token == ""){
						SonosTokenFunctions.getFirstToken()
					}else{
						getHouseholdsAndGroups();
					}
				}
			}
		}
		http.send();
	}
	
	
	function addTrackTimer() {	
		positionMillis = positionMillis + 1000;
		if (positionMillis > currentItemTrackDurationMillis) positionMillis = currentItemTrackDurationMillis;
	}
	

	Timer {
		id: sonosPlayInfoTimer
		interval: 6000
		triggeredOnStart: true
		running: false
		repeat: true
		onTriggered: {
			sonosPlayInfoTimer.interval=6000
			getPlaybackStatus();
			sleep(50);
			getMetaData();
		}
	}
	
	Timer {
		id: checkHouseholdTimer //check if speaker confioguration has changed
		interval: 300000
		triggeredOnStart: false
		running: true
		repeat: true
		onTriggered: {
			getHouseholdsAndGroups();
		}
	}	
	
	Timer {
		id: setAfterTotalStartTimer
		interval: 10000
		triggeredOnStart: true
		running: false
		repeat: false
		onTriggered: {
			getGroupVolume();
		}
	}
	
	Timer {
		id: sonosTrackTimer
		interval: 1000
		triggeredOnStart: false
		running: false 
		repeat: true
		onTriggered: addTrackTimer()
	}
	
	Timer {
		id:tokenNewTryTimer
		interval: 3600000
		triggeredOnStart: false
		running: true 
		repeat: true
		onTriggered: numberofTries=0
	}

}