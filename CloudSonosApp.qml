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

    property bool     debugOutput: false
	property bool     isDimmed: false

    property variant xhrgetHouseholdsAndGroups
    property string  jsonStringgetHouseholdsAndGroups
    property variant jsonObjectgetHouseholdsAndGroups

    property variant xhrgetGroups
    property string jsonStringgetGroupes
    property variant jsonObjectgetGroupes

    property variant xhrgetGroupVolume;
    property string jsonStringgetGroupVolume
    property variant jsonObjectgetGroupVolume

    property variant xhrgetPlaybackStatus
    property string jsonStringgetPlaybackStatus
    property variant jsonObjectgetPlaybackStatus

    property variant xhrcheckImages
    property string xhrcheckImageimage1
    property string xhrcheckImageimage2
    property string image1
    property string image2

    property variant xhrgetMetaData
    property string jsonStringgetMetaData
    property variant jsonObjectgetMetaData

    property variant xhrsetSimpleGroupCommand

    property variant xhrcheckImage
    property string xhrcheckImageimage
    property string returnImage


    property url     tileUrl : "SonosTile.qml"
    property         SonosConfigScreen sonosConfigScreen
    property url     sonosConfigScreenUrl : "SonosConfigScreen.qml"
    property url    trayUrl : "MediaTray.qml";
    property         SystrayIcon mediaTray2

    property url     menuScreenUrl : "MenuScreen.qml"
    property url     mediaScreenUrl : "MediaScreen.qml"
    property         MediaScreen mediaScreen
    property url     messageScreenUrl : "MessageScreen.qml"
    property         MessageScreen messageScreen

    property url     favoritesScreenUrl : "FavoritesScreen.qml"
    property         FavoritesScreen favoritesScreen

    property url     playlistScreenUrl : "PlaylistScreen.qml"
    property         PlaylistScreen playlistScreen

    property url     speakerScreenUrl : "SpeakerScreen.qml"
    property         SpeakerScreen speakerScreen

    property url     thumbnailIcon: "qrc:/tsc/SonosSystrayIcon.png"

    property bool     isFirstRun: true
    property int     numberofTries:0
    property bool     sonosWarningShown: false
    property bool     sonosNameIsGroup: false
    property bool     playButtonVisible : false
    property bool     pauseButtonVisible : false
    property bool     showSlider: true
    property bool     visibleInDimState: false

    property int     favoriteScreenRadioOption1: 0

    property bool     tokenOK: true
    property bool     lineInAvailable:false
    property bool     savedFromConfigScreen:false
    property bool     savedFromMediaScreen:false

    property string  containerType: ""
    property string  streamInfo: ""

    property variant playlist : []
    property variant favorites: []
    property variant sonosArray: []
    property int     playerIndex: 0
    property int     numberofItems: 0

    property variant messageTextArray : ["Hallo","Hallo daar, het eten staat klaar"]

    property string messageSonosName : "Alle"
    property int     messageVolume : 20
    property string  messageText

    property int message1Index: 0
    property int message2Index: 0
    property int message3Index: 0
    property int message4Index: 0

    property string  households: ""
    property string  groupID: ""
    property string  groupName: ""
    property string  groupURL: ""
    property string  playerID: ""
    property string  playerName: ""
    property int     groupVolume: 0
    property bool    groupMuted: false

    property bool      shuffle: false
    property bool      repeatOne: false
    property bool      repeat: false
    property bool      crossfade: false

    property string  playModes: ""
    property int     positionMillis:0
    property string  playbackState: ""
    property string  stationName: ""

    property string  messageResult: ""

    property string  currentItemName: ""
    property string  currentItemImageUrl: ""
    property string  currentItemTrackArtistName: ""
    property int     currentItemTrackDurationMillis:0
    property bool      currentLineInAvailable:false

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

    function initXMLHttpRequests() {

        xhrgetHouseholdsAndGroups = new XMLHttpRequest();
        xhrgetHouseholdsAndGroups.withCredentials = true;
        xhrgetHouseholdsAndGroups.onreadystatechange = function() {
            if( xhrgetHouseholdsAndGroups.readyState === 4){
                if (xhrgetHouseholdsAndGroups.status === 200 || xhrgetHouseholdsAndGroups.status === 300  || xhrgetHouseholdsAndGroups.status === 302) {
                    if (debugOutput) console.log("sonos getHouseholds first and then groups response : " + xhrgetHouseholdsAndGroups.responseText)
                    jsonStringgetHouseholdsAndGroups = xhrgetHouseholdsAndGroups.responseText
                    jsonObjectgetHouseholdsAndGroups= JSON.parse(jsonStringgetHouseholdsAndGroups)
                    if (jsonObjectgetHouseholdsAndGroups.households[0]) {households = jsonObjectgetHouseholdsAndGroups.households[0].id} else {tokenOK = false;SonosTokenFunctions.getRefreshToken()}
                    getGroups()
                }else{
                    if (debugOutput) console.log("sonos getHouseholds first and then groups fault response:" + xhrgetHouseholdsAndGroups.responseText)
                    if (xhrgetHouseholdsAndGroups.responseText.indexOf("keymanagement.service")> 0){
                        tokenOK = false
                        SonosTokenFunctions.getRefreshToken()
                    }
                }
            }
        }

        xhrgetGroups = new XMLHttpRequest();
        xhrgetGroups.withCredentials = true;
        xhrgetGroups.onreadystatechange = function() {
            if( xhrgetGroups.readyState === 4){
                if (xhrgetGroups.status === 200 || xhrgetGroups.status === 300  || xhrgetGroups.status === 302) {
                    if (debugOutput) console.log(xhrgetGroups.responseText)
                    sonosArray = []
                    numberofItems = 0
                    jsonStringgetGroupes = xhrgetGroups.responseText
                    jsonObjectgetGroupes= JSON.parse(jsonStringgetGroupes)
                    for (var a in jsonObjectgetGroupes.groups){
                        for (var i in jsonObjectgetGroupes.players){
                            if (debugOutput) console.log("sonos check " + jsonObjectgetGroupes.groups[a].name + " : "+jsonObjectgetGroupes.groups[a].playerIds+"=="+jsonObjectgetGroupes.players[i].id)
                            if (JSON.stringify(jsonObjectgetGroupes.groups[a].playerIds).search(JSON.stringify(jsonObjectgetGroupes.players[i].id)) > -1 ) {
                                for (var b in jsonObjectgetGroupes.players[i].capabilities){
                                    if(jsonObjectgetGroupes.players[i].capabilities[b]==="LINE_IN"){lineInAvailable=true}else{lineInAvailable=false}
                                }
                                var url = jsonObjectgetGroupes.players[i].websocketUrl.split("wss://")[1].split(":")[0]
                                sonosArray.push({"group" : {"id": jsonObjectgetGroupes.groups[a].id, "name": jsonObjectgetGroupes.groups[a].name, "members" : jsonObjectgetGroupes.groups[a].playerIds , "lineInAvailable" : lineInAvailable},"player":{"id": jsonObjectgetGroupes.players[i].id, "url": url, "name": jsonObjectgetGroupes.players[i].name, "lineInAvailable" : lineInAvailable}})
                                if (debugOutput) console.log("*********sonos sonosArray.push:  " + "{\"group\" : {\"id\": " + jsonObjectgetGroupes.groups[a].id + " , \"name\": " + jsonObjectgetGroupes.groups[a].name + ", \"lineInAvailable\" : " + lineInAvailable + "},\"player\":{\"id\": " + jsonObjectgetGroupes.players[i].id + ", \"url\": "+ url + ", \"name\": " + jsonObjectgetGroupes.players[i].name + ", \"lineInAvailable\" : " + lineInAvailable + "}}")
                                if (debugOutput) console.log("*********sonos sonosArray:  " + JSON.stringify(sonosArray))
                                break
                            }
                        }
                        numberofItems++
                    }

                    if(playerIndex>=numberofItems){playerIndex = 0}

                    if(mediaScreen){mediaScreen.refreshScreen()}

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
                    favoritesScreen.updateFavoriteslist()
                }else{
                    if (debugOutput) console.log("sonos getGroups fault response:" + xhrgetGroups.responseText)
                    if (xhrgetGroups.responseText.indexOf("keymanagement.service")> 0){
                        tokenOK = false
                        SonosTokenFunctions.getRefreshToken()
                    }
                }
            }
        }

        xhrgetGroupVolume = new XMLHttpRequest();
        xhrgetGroupVolume.withCredentials = true;
        xhrgetGroupVolume.onreadystatechange = function() {
            if( xhrgetGroupVolume.readyState === 4){
                if (xhrgetGroupVolume.status === 200 || xhrgetGroupVolume.status === 300  || xhrgetGroupVolume.status === 302) {
                    if (debugOutput) console.log(xhrgetGroupVolume.responseText)
                    jsonStringgetGroupVolume = xhrgetGroupVolume.responseText
                    jsonObjectgetGroupVolume= JSON.parse(jsonStringgetGroupVolume)
                    groupVolume = jsonObjectgetGroupVolume.volume
                    groupMuted = jsonObjectgetGroupVolume.muted
                    if (debugOutput) console.log("*********sonos groupVolume: " + groupVolume)
                    if (debugOutput) console.log("*********sonos groupMuted: " + groupMuted)
                }
            }
        }

        xhrgetPlaybackStatus = new XMLHttpRequest();
        xhrgetPlaybackStatus.withCredentials = true;
        xhrgetPlaybackStatus.onreadystatechange = function() {
            if( xhrgetPlaybackStatus.readyState === 4){
                if (xhrgetPlaybackStatus.status === 200 || xhrgetPlaybackStatus.status === 300  || xhrgetPlaybackStatus.status === 302) {
                    if (debugOutput) console.log(xhrgetPlaybackStatus.responseText)
                    jsonStringgetPlaybackStatus = xhrgetPlaybackStatus.responseText
                    jsonObjectgetPlaybackStatus= JSON.parse(jsonStringgetPlaybackStatus)
                    shuffle = jsonObjectgetPlaybackStatus.playModes.shuffle
                    repeatOne = jsonObjectgetPlaybackStatus.playModes.repeatOne
                    repeat = jsonObjectgetPlaybackStatus.playModes.repeat
                    crossfade  = jsonObjectgetPlaybackStatus.playModes.crossfade

                    positionMillis = jsonObjectgetPlaybackStatus.positionMillis
                    if(currentItemTrackDurationMillis>0){
                        mediaScreen.positionIndicatorX = Math.floor((positionMillis / currentItemTrackDurationMillis) * mediaScreen.positionIndicatorWidth)
                    }
                    playbackState = jsonObjectgetPlaybackStatus.playbackState
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

        xhrcheckImages = new XMLHttpRequest();
        xhrcheckImages.onreadystatechange = function() {

            if( xhrcheckImages.readyState === 4){
                if (xhrcheckImages.status === 200 || xhrcheckImages.status === 300  || xhrcheckImages.status === 302) {
                    if (debugOutput) console.log("*********sonos returning: " +     xhrcheckImageimage1 )
                    returnImage = xhrcheckImageimage1
                }else{
                    if (debugOutput) console.log("*********sonos returning: " + xhrcheckImageimage2)
                    returnImage = xhrcheckImageimage2
                }
            }
        }

        xhrgetMetaData = new XMLHttpRequest();
        xhrgetMetaData.withCredentials = true;
        xhrgetMetaData.onreadystatechange = function() {
            if( xhrgetMetaData.readyState === 4){
                if (xhrgetMetaData.status === 200 || xhrgetMetaData.status === 300  || xhrgetMetaData.status === 302) {
                    if (debugOutput) console.log(xhrgetMetaData.responseText)
                    jsonStringgetMetaData = xhrgetMetaData.responseText
                    var containerType
                    jsonObjectgetMetaData= (JSON.parse(jsonStringgetMetaData))
                    if(jsonObjectgetMetaData.container && jsonObjectgetMetaData.container.type){
                        containerType=jsonObjectgetMetaData.container.type
                    }else if(jsonObjectgetMetaData.hasOwnProperty('currentItem')){
                        containerType=jsonObjectgetMetaData.currentItem.track.type
                    }else{
                    }
                    stationName=""
                    currentItemName=""
                    currentItemTrackArtistName=""
                    //currentItemImageUrl=""
                    streamInfo = ""
                    if(containerType=="station"){
                        showSlider=false
                        stationName=jsonObjectgetMetaData.container.name
                        currentItemName=jsonObjectgetMetaData.container.name
                        currentItemTrackArtistName="Station"
                        for (var i in favorites){
                            if(favorites[i].name === stationName){
                                image1=favorites[i].imageUrl
                            }
                        }
                        if(jsonObjectgetMetaData.hasOwnProperty('streamInfo')){
                            streamInfo= jsonObjectgetMetaData.streamInfo
                        }
                    } else if(containerType=="linein.homeTheater"){
                        showSlider=false
                        stationName=""
                        currentItemName="Line In/Home Theater"
                        currentItemTrackArtistName=""
                        image1=""
                        streamInfo = ""
                    }else if (typeof containerType==="undefined"){
                        showSlider=false
                        stationName=""
                        streamInfo = ""
                        currentItemName="Geen bron"
                        currentItemTrackArtistName=""
                        image1=""
                    }else{
                        showSlider=true
                          if (jsonObjectgetMetaData.currentItem.track.name)currentItemName=jsonObjectgetMetaData.currentItem.track.name
                        if (jsonObjectgetMetaData.currentItem.track.imageUrl) image1=jsonObjectgetMetaData.currentItem.track.imageUrl
                        if (jsonObjectgetMetaData.currentItem.track.artist) if (jsonObjectgetMetaData.currentItem.track.artist.name)currentItemTrackArtistName=jsonObjectgetMetaData.currentItem.track.artist.name
                        if (jsonObjectgetMetaData.currentItem.track.durationMillis)currentItemTrackDurationMillis=jsonObjectgetMetaData.currentItem.track.durationMillis
                        if (jsonObjectgetMetaData.container.imageUrl)image2=jsonObjectgetMetaData.container.imageUrl
                        try{
                            if (jsonObjectgetMetaData.nextItem.track.name)nextItemName=jsonObjectgetMetaData.nextItem.track.name
                            if (jsonObjectgetMetaData.nextItem.track.artist.name)nextItemTrackArtistName=jsonObjectgetMetaData.nextItem.track.artist.name
                        } catch(e) {
                        }
                        streamInfo = ""
                    }
                    currentItemNameShort = breakAtWholeWord(currentItemName, 38);
                    currentItemTrackArtistNameShort = breakAtWholeWord(currentItemTrackArtistName, 38);
                    nextItemNameShort = breakAtWholeWord(nextItemName, 38);
                    nextItemTrackArtistNameShort = breakAtWholeWord(nextItemTrackArtistName, 38);
                    currentLineInAvailable =  sonosArray[playerIndex].group.lineInAvailable

                    if (image2 !==""){
                        currentItemImageUrl = checkImages(image1, image2)
                    }else{
                        currentItemImageUrl = image1
                    }
                    currentItemImageUrl = checkImage(currentItemImageUrl)

               } else {
                    if (debugOutput) console.log("*********sonos playbackMetadata error response:" + xhrgetMetaData.responseText)
                    if (xhrgetMetaData.responseText.indexOf("invalid_access_token")> 0){
                        tokenOK = false;
                        SonosTokenFunctions.getFirstToken();
                    }
                    if (xhrgetMetaData.responseText.indexOf("token_expired")> 0){
                        tokenOK = false;
                        SonosTokenFunctions.getRefreshToken();
                    }
                }
            }
        }


        xhrsetSimpleGroupCommand = new XMLHttpRequest();
        xhrsetSimpleGroupCommand.withCredentials = true;
        xhrsetSimpleGroupCommand.onreadystatechange = function() {
            if( xhrsetSimpleGroupCommand.readyState === 4){
                if (xhrsetSimpleGroupCommand.status === 200 || xhrsetSimpleGroupCommand.status === 300  || xhrsetSimpleGroupCommand.status === 302) {
                    if (debugOutput) console.log(xhrsetSimpleGroupCommand.responseText)
                    if(isFirstRun){isFirstRun=false;getGroupVolume()}
                }
            }
        }

        xhrcheckImage = new XMLHttpRequest();
        xhrcheckImage.onreadystatechange = function() {
            if( xhrcheckImage.readyState === 4){
                if (xhrcheckImage.status === 200 || xhrcheckImage.status === 300  || xhrcheckImage.status === 302) {
                    if (debugOutput) console.log("*********sonos returning: " + xhrcheckImageimage)
                    returnImage = xhrcheckImageimage
                }else{
                    returnImage = "drawables/sonos.png"
                }
            }
        }
    }
    
    function init() {
        registry.registerWidget("screen", messageScreenUrl, this, "messageScreen");
        registry.registerWidget("screen", mediaScreenUrl, this, "mediaScreen");
        registry.registerWidget("systrayIcon", trayUrl, this, "mediaTray2");
        registry.registerWidget("screen", favoritesScreenUrl, this, "favoritesScreen");
        registry.registerWidget("screen", playlistScreenUrl, this, "playlistScreen");
        registry.registerWidget("screen", speakerScreenUrl, this, "speakerScreen");
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
        initXMLHttpRequests()
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
        }else if(savedFromConfigScreen){
            sonosConfigScreen.hide()
        }else{

        }
    }

    function getHouseholdsAndGroups(){
        if (debugOutput) console.log("*********sonos getHouseholds first and then groups")
        xhrgetHouseholdsAndGroups.open("GET", "https://api.ws.sonos.com/control/api/v1//households");
        xhrgetHouseholdsAndGroups.setRequestHeader("Authorization", "Bearer " + token);
        xhrgetHouseholdsAndGroups.setRequestHeader("Content-Type", "application/json");
        xhrgetHouseholdsAndGroups.send()
    }

    function getGroups(){
        if (debugOutput) console.log("*********sonos getGroups")
        xhrgetGroups.open("GET", "https://api.ws.sonos.com/control/api/v1/households/" + households + "/groups");
        xhrgetGroups.setRequestHeader("Authorization", "Bearer " + token);
        xhrgetGroups.setRequestHeader("Content-Type", "application/json");
        xhrgetGroups.send()
    }

    function getGroupVolume(){
        if (debugOutput) console.log("*********sonos getGroupVolume")
        xhrgetGroupVolume.open("GET", "https://api.ws.sonos.com/control/api/v1/groups/" + sonosArray[playerIndex].group.id + "/groupVolume");
        xhrgetGroupVolume.setRequestHeader("Authorization", "Bearer " + token);
        xhrgetGroupVolume.setRequestHeader("Content-Type", "application/json");
        xhrgetGroupVolume.send()
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
					xhr = null
                }
            }
        }
        xhr.send(JSON.stringify({"volume": volume}));
    }

    function setGroupMuted(mute){
        if (debugOutput) console.log("*********sonos setGroupMuted:  " + mute)
        if (debugOutput) console.log("*********sonos setGroupMuted:  " +JSON.stringify({"muted": mute}))
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/groupVolume/mute");
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    getGroupVolume()
					xhr = null
                }
            }
        }
        xhr.send(JSON.stringify({"muted": mute}));
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
					xhr = null
                }
            }
        }
        xhr.send(JSON.stringify({"positionMillis": position}));
    }


    function setPlayModes(jsType, jsValue){
		if (debugOutput) console.log("*********sonos setPlayModes")
		var jsonString = "{\"playModes\": {\"" + jsType + "\": " + jsValue +"}}"
		if (debugOutput) console.log("*********sonos setPlayModes1" + jsonString)
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
					xhr = null
                }
            }
        }
        //xhr.send(JSON.stringify({"playModes": {"repeat": repeat,"repeatOne": repeatOne ,"crossfade": crossfade,"shuffle": shuffle}}));
        xhr.send(jsonString);
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
					xhr = null
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
					xhr = null
                }
                if (debugOutput) console.log("*********sonos postGroupCommand error : " + xhr.status +", "+ xhr.responseText )
            }
        }
        xhr.send(params);
    }

    function getPlaybackStatus(){
        if (debugOutput) console.log("*********sonos getPlaybackStatus")
        xhrgetPlaybackStatus.open("GET", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/playback");
        xhrgetPlaybackStatus.setRequestHeader("Authorization", "Bearer " + token);
        xhrgetPlaybackStatus.setRequestHeader("Content-Type", "application/json");
        xhrgetPlaybackStatus.send()
    }

    function breakAtWholeWord(sentence, maxLength) {
        if (sentence.length > maxLength){
            var lastWordIndex = sentence.lastIndexOf(" ", maxLength)
            if (lastWordIndex === -1) {
                // If no space was found, break at the maximum width
                lastWordIndex = maxLength
                sentence = sentence.substring(0, lastWordIndex)
            }
            sentence = sentence.substring(0, lastWordIndex)  + ".."
        }else{
            sentence = sentence
        }
        return sentence
    }

    function checkImages(checkimage1, checkimage2){
        xhrcheckImageimage1 = checkimage1
        xhrcheckImageimage2 = checkimage2
        if (debugOutput) console.log("*********sonos checkImages")
        returnImage = ""
        xhrcheckImages.open("GET", checkimage1, false);
        xhrcheckImages.send()
        return returnImage
    }

    function getMetaData(){
        if (debugOutput) console.log("*********sonos playbackMetadata")
        xhrgetMetaData.open("GET", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/playbackMetadata");
        xhrgetMetaData.setRequestHeader("Authorization", "Bearer " + token);
        xhrgetMetaData.setRequestHeader("Content-Type", "application/json");
        xhrgetMetaData.send()
    }

    function setSimpleGroupCommand(command){
        if (debugOutput) console.log("*********sonos setSimpleGroupCommand:  " + command)
        xhrsetSimpleGroupCommand.open("POST", "https://api.ws.sonos.com/control/api/v1/groups/"  + sonosArray[playerIndex].group.id +  "/" + command);
        xhrsetSimpleGroupCommand.setRequestHeader("Authorization", "Bearer " + token);
        xhrsetSimpleGroupCommand.setRequestHeader("Content-Type", "application/json");
        xhrsetSimpleGroupCommand.send();
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
				xhr = null
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
					JsonObject = null
					JsonString = null
					xhr = null
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
				xhr = null
            }
        }
        xhr.send(JSON.stringify({"name": "ACME","appId": "com.acme.app","volume": volume,"streamUrl": newURL,"clipType": "CUSTOM"}));
    }

    function checkBash(){
        if (debugOutput) console.log("*********sonos checkBash getting credentials()")
        var httpcheckBash = new XMLHttpRequest()
        httpcheckBash.open("GET", "https://raw.githubusercontent.com/ToonSoftwareCollective/toonanimations/main/sonoscode.txt");
        httpcheckBash.onreadystatechange = function() { // Call a function when the state changes.
            if( httpcheckBash.readyState === 4){
                if (httpcheckBash.status === 200) {
                    if (debugOutput) console.log("*********sonos checkBash httpcheckBash.responseText " + httpcheckBash.responseText)
                    var JsonString2 = httpcheckBash.responseText
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
					JsonObject2 = null
					JsonString2 = null
					content = null
					httpcheckBash = null
                }
            }
        }
        httpcheckBash.send();
    }


    function checkImage(image){
        if ( typeof image === "undefined") {
            if (debugOutput) console.log("*********sonos checkImage image undefined")
            returnImage = "drawables/sonos.png"
        } else {
            if (debugOutput) console.log("*********sonos checkImage")
            xhrcheckImageimage = image
            xhrcheckImage.open("GET", image, false);
            returnImage = ""
            xhrcheckImage.send()
        }
        return returnImage
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
            //sonosPlayInfoTimer.interval=6000
            getPlaybackStatus();
            sleep(50);
            getMetaData();
        }
    }

    Timer {
        id: checkHouseholdTimer //check if speaker confioguration has changed
        interval: 60000
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
	

	function setTimersDimMode(){
		if (debugOutput) console.log("*********sonos setTimersDimMode()")
		if (!isDimmed){
			if (debugOutput) console.log("*********sonos setting short timers")
			sonosPlayInfoTimer.interval=6000
			sonosTrackTimer.interval= 1000
			checkHouseholdTimer.interval = 60000
			
			sonosPlayInfoTimer.stop()
			sonosTrackTimer.stop()
			checkHouseholdTimer.stop()
			
			sonosPlayInfoTimer.start()
			sonosTrackTimer.start()
			checkHouseholdTimer.start()

		}else{
			if (debugOutput) console.log("*********sonos setting long timers")
			sonosPlayInfoTimer.interval=20000
			sonosTrackTimer.interval= 10000
			checkHouseholdTimer.interval = 120000
		}
	}


}
