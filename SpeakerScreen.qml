import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: speakerScreen
	property bool debugOutput : app.debugOutput
	
	property variant speakers : []
	property bool loudnessOn : false
	
	property bool containesStereo : false
	
	screenTitle: app.groupName
	hasHomeButton: false
	
	property int  numberofItems :0
	
	property int leftVolume:0
	property int rightVolume:0
	
	property bool positionIndicatorDragActive : false
	property int positionIndicatorX
	
	property int rightsetVolume:100
	property int leftsetVolume:100


	
	
	onHidden: {
		updateSpeakersTimer.running = false;
	}
	
	onShown: {
		if (debugOutput) console.log("*********sonos speakerScreen loaded")
		updateSpeakersTimer.running = true
		getNames()
	}

	Text {
		id: speakerTXT
		width:  160
		text: "Luidspreker:"
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.bold.name
		anchors {
			top:		parent.top
			left:   	parent.left
			leftMargin : isNxt ? 20 : 16
		}
	}

	Rectangle {
		id: speakerFrame
		width: isNxt ? parent.width - 40 : parent.width - 32
		height: isNxt ? parent.height - 40 : parent.height - 32
		color: colors.canvas
		anchors {
			left: speakerTXT.left
			top: speakerTXT.bottom
			topMargin: isNxt ? 20: 16
		}
	
		ListModel { 
			id: speakerModel			
		}


		GridView {
			id: speakerGrid
			anchors.fill: parent
			cellWidth:parent.width -3
			cellHeight: containesStereo? isNxt ? 130:104 : isNxt ? 80:54
			model: speakerModel

			delegate: Rectangle {
				width: parent.width
				height: model.stereo? isNxt ? 120:96 : isNxt ? 70:56
				//color: colors.canvas
				color: "white"

				Text {
					id: speakerTXT
					text: model.text
					font.pixelSize:  isNxt ? 20 : 16
					font.family: qfont.bold.name
					color: colors.tileTextColor
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: parent.left
						leftMargin: isNxt ? 4 : 3
					}
				}
			
				IconButton {
					id: volumeDown
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: parent.left
						leftMargin: isNxt ? 205:164
					}

					iconSource: "qrc:/tsc/volume_down_small.png"
					onClicked: {
						if (parseInt(model.currentVolume)>0)setVolume(model.number ,model.url, parseInt(model.currentVolume)-1 )
					}
				}
			
				Text {
					id: currentVolumeTXT
					text: model.currentVolume
					font.pixelSize:  isNxt ? 20 : 16
					font.family: qfont.bold.name
					color: colors.tileTextColor
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: volumeDown.right
						leftMargin: isNxt ? 10 : 8
					}
				}
				
				IconButton {
					id: volumeUp
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: volumeDown.right
						leftMargin: isNxt ? 40 : 32
					}

					iconSource: "qrc:/tsc/volume_up_small.png"
					onClicked: {
						if (parseInt(model.currentVolume)<99)setVolume(model.number,model.url, parseInt(model.currentVolume)+1)
					}
				}
				
				Text {
					id: bassTXT
					text: "bass : "
					font.pixelSize:  isNxt ? 20 : 16
					font.family: qfont.bold.name
					color: colors.tileTextColor
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: volumeUp.right
						leftMargin: isNxt ? 20:16
					}
				}
			
				IconButton {
					id: bassDown
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: bassTXT.right
						leftMargin: isNxt ? 6:5
					}

					iconSource: "qrc:/tsc/down.png"
					onClicked: {
						if (parseInt(model.currentBass)>-10)setBass(model.number ,model.url, parseInt(model.currentBass)-1 )
					}
				}
			
				Text {
					id: currentBassTXT
					text: parseInt(model.currentBass)>0 ? "+" + model.currentBass: parseInt(model.currentBass)==0 ? " " + model.currentBass: model.currentBass
					font.pixelSize:  isNxt ? 20 : 16
					font.family: qfont.bold.name
					color: colors.tileTextColor
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: bassDown.right
						leftMargin: isNxt ? 5:4
					}
				}
				
				IconButton {
					id: bassUp
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: bassDown.right
						leftMargin: isNxt ? 42 : 33
					}

					iconSource: "qrc:/tsc/up.png"
					onClicked: {
						if (parseInt(model.currentBass)<10)setBass(model.number,model.url, parseInt(model.currentBass)+1)
					}
				}
				
				Text {
					id: trebleTXT
					text: "treble : "
					font.pixelSize:  isNxt ? 20 : 16
					font.family: qfont.bold.name
					color: colors.tileTextColor
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: bassUp.right
						leftMargin: isNxt ? 20:16
					}
				}
			
				IconButton {
					id: trebleDown
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: trebleTXT.right
						leftMargin: isNxt ? 6:5
					}

					iconSource: "qrc:/tsc/down.png"
					onClicked: {
						if (parseInt(model.currentTreble)>-10)setTreble(model.number ,model.url, parseInt(model.currentTreble)-1 )
					}
				}
			
				Text {
					id: currentTrebleTXT
					text: parseInt(model.currentTreble)>0 ? "+" + model.currentTreble: parseInt(model.currentTreble)==0 ? " " + model.currentTreble: model.currentTreble
					font.pixelSize:  isNxt ? 20 : 16
					font.family: qfont.bold.name
					color: colors.tileTextColor
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: trebleDown.right
						leftMargin: isNxt ? 5:4
					}
				}
				
				IconButton {
					id: trebleUp
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: trebleDown.right
						leftMargin: isNxt ? 42 : 33
					}

					iconSource: "qrc:/tsc/up.png"
					onClicked: {
						if (parseInt(model.currentTreble)<10)setTreble(model.number,model.url, parseInt(model.currentTreble)+1)
					}
				}
				
				Text {
					id: loudnessTXT
					text: "loudness: "
					font.pixelSize:  isNxt ? 20 : 16
					font.family: qfont.bold.name
					color: colors.tileTextColor
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: trebleUp.right
						leftMargin: isNxt ? 25:16
					}
				}
			
				Rectangle {
					id: loudnessOnButton
					width: isNxt ? 44:35
					height: isNxt ? 44:35
					color: colors.btnUp
					radius: designElements.radius
					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: loudnessTXT.right
						leftMargin: isNxt ? 6:5
					}
					Image {
						source: "drawables/loudness_on.png"
						width: isNxt ? 26:24
						height: isNxt ? 26:24
						anchors.centerIn: parent
					}
					MouseArea {
						anchors.fill: parent
						onClicked: {
							setLoudness(model.number,model.url, 0)
						}
					}
					visible: model.currentLoudness
				}
				
				Rectangle {
					id: loudnessButton
					width: isNxt ? 44:35
					height: isNxt ? 44:35
					color: colors.btnUp
					radius: designElements.radius

					anchors {
						verticalCenter: model.stereo? undefined : parent.verticalCenter
						top: model.stereo? parent.top : undefined
						topMargin: model.stereo? isNxt ? 10:8 : undefined
						left: loudnessOnButton.left
					}
					Image {
						source: "drawables/loudness.png"
						width: isNxt ? 26:24
						height: isNxt ? 26:24
						anchors.centerIn: parent
					}
					MouseArea {
						anchors.fill: parent
						onClicked: {
							setLoudness(model.number,model.url, 1)
						}
					}
					visible: !loudnessOnButton.visible
				}
				
				Image {
					id: positionIndicatorBar
					source: "drawables/volumeBarTile.png"
					width: isNxt? 341 : 266
					height: isNxt ? 20 : 16
					anchors {
						bottom: parent.bottom
						bottomMargin: isNxt ? 20:16
						horizontalCenter: parent.horizontalCenter
					}
					visible: model.stereo
				}
				
				//this image is the slider indicator. 
				Image {
					id: positionIndicator
					source: "drawables/volumeIndicator.png"
					height: isNxt ? 30 : 24
					width: isNxt ? 30 : 24
					x: positionIndicatorBar.x + model.positionIndicatorX - 15
					y: positionIndicatorBar.y - 5
					visible: model.stereo
				}
				
				Text {
					id: midTXT
					text: "><"
					font.pixelSize:  isNxt ? 20 : 16
					font.family: qfont.bold.name
					color: colors.tileTextColor
					anchors {
						horizontalCenter: positionIndicatorBar.horizontalCenter
						bottom: positionIndicatorBar.top
						topMargin: isNxt ? 10:8
					}
					visible: model.stereo & (leftVolume === 100 & rightVolume ===100)
				}
				
				IconButton {
					id:leftUp	
					anchors {
						verticalCenter: positionIndicatorBar.verticalCenter
						right: positionIndicatorBar.left
						rightMargin: isNxt ? 10 : 8
					}
					iconSource: "qrc:/tsc/navArrow-left.png"
					onClicked: {
						if (debugOutput) console.log("*********sonos is left, right :" + model.leftVolume + "  ,  "  + model.rightVolume )
						if (model.leftVolume === 100){
							rightsetVolume = model.rightVolume -10
							setRelativeVolume(model.number, "RF", url, rightsetVolume)
						}else{
							if (model.leftVolume > 90){leftsetVolume = 100}else{leftsetVolume = model.leftVolume + 10}
							setRelativeVolume(model.number,"LF", model.url, leftsetVolume)
						}
					}
					visible: model.stereo
				}
				
				IconButton {
					id: rightUp
					anchors {
						verticalCenter: positionIndicatorBar.verticalCenter
						left: positionIndicatorBar.right
						leftMargin: isNxt ? 10 : 8
					}

					iconSource: "qrc:/tsc/navArrow-right.png"
					onClicked: {
						if (debugOutput) console.log("*********sonos is left, right :" + model.leftVolume + "  ,  "  + model.rightVolume )
						if (model.rightVolume === 100){
							leftsetVolume = model.leftVolume -10
							setRelativeVolume(model.number, "LF", url, leftsetVolume)
						}else{
							if (model.rightVolume > 90){rightsetVolume = 100}else{rightsetVolume = model.rightVolume + 10}
							setRelativeVolume(model.number, "RF", model.url, rightsetVolume)
						}
					}
					visible: model.stereo
				}
			}
		}
	}
	

	function getNames(){
        if (debugOutput) console.log("*********sonos  getNames()")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("GET", "https://api.ws.sonos.com/control/api/v1/households/" + app.households + "/groups",false);
        xhr.setRequestHeader("Authorization", "Bearer " + app.token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					speakerModel.clear()
                    if (debugOutput) console.log(xhr.responseText)
					speakers = []
					var numberofItems = 0
                    var JsonString = xhr.responseText
                    var JsonObject= JSON.parse(JsonString)
					for (var i in  app.sonosArray[app.playerIndex].group.members){
						if (debugOutput) console.log("*********sonos  getNames() member: " + app.sonosArray[app.playerIndex].group.members[i])
						for (var a in  JsonObject.players){
							if (debugOutput) console.log("*********sonos JsonObject.players[a].id :" + JsonObject.players[a].id)
							if (app.sonosArray[app.playerIndex].group.members[i] === JsonObject.players[a].id){
								var url = JsonObject.players[a].websocketUrl.split("wss://")[1].split(":")[0]
                                var numberofSpeakers = JsonObject.players[a].deviceIds.length
								var stereoBool = false
								if (JsonObject.players[a].deviceIds.length ===2 ){
									console.log("*********sonos checking stereoBool....")
									checkStereo(url, function(result) {
										  stereoBool = result;
									});
								}
								if (stereoBool)containesStereo = true
								speakerModel.append({number: numberofItems, name: JsonObject.players[a].id , text: JsonObject.players[a].name, currentVolume: 0 , currentBass: 0 , currentTreble: 0  ,  currentLoudness: true ,  stereo: stereoBool ,  positionIndicatorX: 0 , rightVolume:100, leftVolume:100 , url :  url})
								speakers.push({"number" : numberofItems, "url" : url , "numberofSpeakers" : numberofSpeakers, "stereo" : stereoBool})
								numberofItems ++
							}
						}
					}
					if (debugOutput) console.log("*********sonos speakers : " + JSON.stringify(speakers))                    
					if (debugOutput) console.log("*********sonos  getting volumes from speakers")
					for(var i in speakers){
						if (speakers[i].stereo){
							getRelativeVolumeRight(speakers[i].number , speakers[i].url)
							getRelativeVolumeLeft(speakers[i].number , speakers[i].url)
						}
						getVolume(speakers[i].number , speakers[i].url)
						getBass(speakers[i].number , speakers[i].url)
						getTreble(speakers[i].number , speakers[i].url)
						getLoudness(speakers[i].number , speakers[i].url)
					}
				}
			}
		}
        xhr.send()
    }
	
	
	function checkStereo(url, callback) {
        if (debugOutput) console.log("*********sonos checkStereo() :" + url)
        var xhr = new XMLHttpRequest();
		xhr.open("GET", "http://" + url + ":1400/status/zp", false);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					if (debugOutput) console.log("*********sonos responseXML: "+ responseXML)
					var zoneName  = responseXML.split("<ZoneName>")[1].split("<")[0]
					if (debugOutput) console.log("*********sonos zoneName: " + zoneName)
					if (zoneName.indexOf("(L)") > 0 || zoneName.indexOf("(R)") > 0){callback(true)} else {callback(false)}
                } else{
					callback(false)
				}
            }
        }
        xhr.send()
    }
	
	
	function getRelativeVolumeRight(index,url) {
        if (debugOutput) console.log("*********sonos getVolume()" + url)
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:GetVolume xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n  <InstanceID>0</InstanceID>\r\n  <Channel>RF</Channel>\r\n</u:GetVolume>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control", false);
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#GetVolume");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
                    if (debugOutput) console.log("*********sonos responseXML: "+ responseXML)
					rightVolume  = parseInt(responseXML.split("<CurrentVolume>")[1].split("<")[0])
                    if (debugOutput) console.log("*********sonos rightVolume: " + rightVolume)
					speakerModel.set(index, { rightVolume: parseInt(rightVolume)})
					setPositionIndicator()
                }
            }
        }
        xhr.send(data)
    }
	
	
	function getRelativeVolumeLeft(index,url) {
        if (debugOutput) console.log("*********sonos getVolume()" + url)
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:GetVolume xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n  <InstanceID>0</InstanceID>\r\n  <Channel>LF</Channel>\r\n</u:GetVolume>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control", false);
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#GetVolume");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
                    if (debugOutput) console.log("*********sonos responseXML: "+ responseXML)
					leftVolume  = parseInt(responseXML.split("<CurrentVolume>")[1].split("<")[0])
                    if (debugOutput) console.log("*********sonos leftVolume: " + leftVolume)
					speakerModel.set(index, { leftVolume: parseInt(leftVolume)})
					setPositionIndicator(index)
                }
            }
        }
        xhr.send(data)
    }


	function setPositionIndicator(index){
		if (debugOutput) console.log("*********sonos setPositionIndicator()" )
		var position
		if ((leftVolume+rightVolume)>0){
			if (leftVolume === 100){
				if (isNxt){
					position = Math.floor((0.5 - ((100-rightVolume)/200))*341)
				}else{
					position = Math.floor((0.5 - ((100-rightVolume)/200))*266)
				}
			} else {
				if (isNxt){
					position = Math.floor((0.5 + ((100-leftVolume)/200))*341)
				}else{
					position = Math.floor((0.5 + ((100-leftVolume)/200))*266)
				}
			}
			speakerModel.set(index, { positionIndicatorX: parseInt(position)})
		}
	}
	
	function setRelativeVolume(index, channel, url, volume) {
		if (debugOutput) console.log("*********sonos setVolume() " + index + " , " + channel + " , " +  url  + " , " + volume )
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:SetVolume xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n        <InstanceID>0</InstanceID>\r\n <Channel>" + channel + "</Channel>\r\n <DesiredVolume>" + volume + "</DesiredVolume>\r\n</u:SetVolume>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#SetVolume");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					getRelativeVolumeRight(index,url)
					getRelativeVolumeLeft(index,url)
                }
            }
        }
        xhr.send(data)
    }

	
	function getVolume(index,url) {
        if (debugOutput) console.log("*********sonos getVolume()" + index + " , " + url)
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:GetVolume xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n  <InstanceID>0</InstanceID>\r\n  <Channel>Master</Channel>\r\n</u:GetVolume>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#GetVolume");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					if (debugOutput) console.log("*********sonos responseXML: "+ responseXML)
					var currentVolume  = responseXML.split("<CurrentVolume>")[1].split("<")[0]
					if (debugOutput) console.log("*********sonos currentVolume: " + currentVolume)
					speakerModel.set(index, { currentVolume: parseInt(currentVolume)})
                }
            }
        }
        xhr.send(data)
    }


	function getBass(index,url) {
        if (debugOutput) console.log("*********sonos getBass()")
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:GetBass xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n  <InstanceID>0</InstanceID>\r\n  <Channel>Master</Channel>\r\n</u:GetBass>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#GetBass");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					if (debugOutput) console.log("*********sonos responseXML: "+ responseXML)
					var currentBass  = responseXML.split("<CurrentBass>")[1].split("<")[0]
					if (debugOutput) console.log("*********sonos currentBass: "+ currentBass)
					speakerModel.set(index, { currentBass: parseInt(currentBass)})
                }
            }
        }
        xhr.send(data)
    }
	
	function getTreble(index,url) {
        if (debugOutput) console.log("*********sonos getTreble()")
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:GetTreble xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n  <InstanceID>0</InstanceID>\r\n  <Channel>Master</Channel>\r\n</u:GetTreble>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#GetTreble");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					if (debugOutput) console.log("*********sonos responseXML: "+ responseXML)
					var currentTreble  = responseXML.split("<CurrentTreble>")[1].split("<")[0]
					if (debugOutput) console.log("*********sonos currentTreble: "+ currentTreble)
					speakerModel.set(index, {currentTreble: parseInt(currentTreble)})
                }
            }
        }
        xhr.send(data)
    }
	
	function getLoudness(index,url) {
        if (debugOutput) console.log("*********sonos getLoudness()")
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:GetLoudness xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n  <InstanceID>0</InstanceID>\r\n  <Channel>Master</Channel>\r\n</u:GetLoudness>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#GetLoudness");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					if (debugOutput) console.log("*********sonos responseXML: "+ responseXML)
					var currentLoudness  = responseXML.split("<CurrentLoudness>")[1].split("<")[0]
					if (debugOutput) console.log("*********sonos currentLoudness: "+ currentLoudness)
					if (parseInt(currentLoudness) >0 ){loudnessOn = true }else {loudnessOn = false}
					speakerModel.set(index, {currentLoudness: loudnessOn})
                }
            }
        }
        xhr.send(data)
    }
	
	
	
	function setVolume(index, url, volume) {
        if (debugOutput) console.log("*********sonos setVolume()" + index + " , " + url  + " , " + volume )
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:SetVolume xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n        <InstanceID>0</InstanceID>\r\n <Channel>Master</Channel>\r\n <DesiredVolume>" + volume + "</DesiredVolume>\r\n</u:SetVolume>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#SetVolume");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					getVolume(index,url)
                }
            }
        }
        xhr.send(data)
    }

	function setBass(index, url, bass) {
        if (debugOutput) console.log("*********sonos setBass()" + index + " , " + url  + " , " + bass )
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:SetBass xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n        <InstanceID>0</InstanceID>\r\n <Channel>Master</Channel>\r\n <DesiredBass>" + bass + "</DesiredBass>\r\n</u:SetBass>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#SetBass");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					getBass(index,url)
                }
            }
        }
        xhr.send(data)
    }

	function setTreble(index, url, treble) {
        if (debugOutput) console.log("*********sonos setTreble()" + index + " , " + url  + " , " + treble )
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n    <u:SetTreble xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n        <InstanceID>0</InstanceID>\r\n <Channel>Master</Channel>\r\n <DesiredTreble>" + treble + "</DesiredTreble>\r\n</u:SetTreble>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#SetTreble");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					getTreble(index,url)
                }
            }
        }
        xhr.send(data)
    }
	
	
	function setLoudness(index, url, loudness) {
        if (debugOutput) console.log("*********sonos setLoudness()" + index + " , " + url  + " , " + loudness )
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n<u:SetLoudness xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:1\">\r\n  <InstanceID>0</InstanceID>\r\n  <Channel>Master</Channel>\r\n  <DesiredLoudness>" + loudness + "</DesiredLoudness>\r\n</u:SetLoudness>\r\n  </s:Body>\r\n</s:Envelope>";
		if (debugOutput) console.log("*********sonos data: "+ data)
		xhr.open("POST", "http://" + url + ":1400/MediaRenderer/RenderingControl/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:RenderingControl:1#SetLoudness");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					if (debugOutput) console.log("*********sonos responseXML: "+ responseXML)
					getLoudness(index,url)
                }
            }
        }
        xhr.send(data)
    }
	
	Timer{
		id: updateSpeakersTimer
		interval: 10000
		triggeredOnStart: false
		running: false
		repeat: true
		onTriggered: {
			if (debugOutput) console.log("*********sonos  getting volumes from speakers")
				for(var i in speakers){
					getVolume(speakers[i].number , speakers[i].url)
					getBass(speakers[i].number , speakers[i].url)
					getTreble(speakers[i].number , speakers[i].url)
					getLoudness(speakers[i].number , speakers[i].url)
					if (speakers[i].stereo){
						getRelativeVolumeRight(speakers[i].number , speakers[i].url)
						getRelativeVolumeLeft(speakers[i].number , speakers[i].url)
					}
				}
		}
	}

}

