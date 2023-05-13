import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: playlistScreen
	property bool debugOutput : app.debugOutput

	screenTitle: app.groupName
	hasHomeButton: false
	
	property int  numberofItems :0
	
	onShown: {
			model.clear()
			getMediaInfo()
	}
	
	
	Text {
		id: playlistTXT
		width:  160
		text: "Huidige afspeellijst:"
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
		width: isNxt ? parent.width -100 : parent.width - 80
		height: isNxt ? parent.height -40 :  parent.height -32
		color: "white"
		radius: isNxt ? 5 : 4
		border.color: "black"
		border.width: isNxt ? 3 : 2
		anchors {
			top:		playlistTXT.bottom
			left:   	playlistTXT.left
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
				updateItems(app.playlist[listview1.currentIndex].id)
            }
		}	
	}
	
	IconButton {
		id: playButton
		color: colors.background
		anchors {
			verticalCenter: listviewContainer1.verticalCenter
			left:  upButton.left
		}

		iconSource: "qrc:/tsc/play.png"
		onClicked: {
			playTrack(listview1.currentIndex+1)

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
		    if (numberofItems>listview1.currentIndex + 1){
                   listview1.currentIndex  = listview1.currentIndex +1
				   updateItems(app.playlist[listview1.currentIndex].id)
            }
		}	
	}



	function getMediaInfo() {
        if (debugOutput) console.log("*********sonos GetMediaInfo")
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n<u:GetMediaInfo xmlns:u=\"urn:schemas-upnp-org:service:AVTransport:1\">\r\n  <InstanceID>ui4</InstanceID>\r\n</u:GetMediaInfo>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + app.sonosArray[app.playerIndex].player.url + ":1400/MediaRenderer/AVTransport/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:AVTransport:1#GetMediaInfo");	
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					var numbertracks  = responseXML.split("<NrTracks>")[1].split("<")[0]
					if (debugOutput) console.log("*********sonos numbertracks: "+ numbertracks)
					if(numbertracks>1){
						getPlaylist()
					}else{
						model.clear()
						listview1.model.append({name: "Geen huidige afspeellijst gevonden"})
					}
                }
            }
        }
        xhr.send(data)
    }
	
	function getPlaylist() {
        if (debugOutput) console.log("*********sonos getPlaylist")
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n<u:Browse xmlns:u=\"urn:schemas-sonos-com:service:Queue:1\">\r\n  <QueueID>0</QueueID>\r\n  <StartingIndex>0</StartingIndex>\r\n  <RequestedCount>1000</RequestedCount>\r\n</u:Browse>\r\n  </s:Body>\r\n</s:Envelope>";
        console.log(app.sonosArray[app.playerIndex].player.url)
		xhr.open("POST", "http://" + app.sonosArray[app.playerIndex].player.url + ":1400/MediaRenderer/Queue/Control", true);
		xhr.setRequestHeader("soapaction", "urn:schemas-sonos-com:service:Queue:1#Browse");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					responseXML = responseXML.replace(/&lt;/g, "<")
                    responseXML = responseXML.replace(/&gt;/g, ">")
                    responseXML = responseXML.replace(/&amp;/g, "&")
                    responseXML = responseXML.replace(/&quot;/g, "\"")
                    responseXML = responseXML.replace(/&#039;/g, "'");
					responseXML = responseXML.replace(/&apos;/g, "'");
					const items = responseXML.split("\/item")
					if (debugOutput) console.log("*********sonos responseXML: " + responseXML)
					numberofItems =  0
					for (var a = 0; a < items.length-1; a++) {
                        if (items[a].indexOf("dc:creator>") > 0) {
                            var artist = items[a].split("dc:creator>")[1].split("<")[0]
                        } else {
                            var artist = "onbekende artiest"
                        }
                        if (items[a].indexOf("dc:title>") > 0) {
                            var title  = items[a].split("dc:title>")[1].split("<")[0]
                        } else {
                            var artist = "onbekende trackname"
                        }
                        if (items[a].indexOf("duration=") > 0) {
                            var trackDduration  = " (" + items[a].split("duration=\"")[1].split("\">")[0] + ")"
                        } else {
                            var trackDduration  = ""
                        }
                        var fullname = artist + "-" + title + trackDduration
                        if (debugOutput) console.log(fullname)
                        numberofItems++
                        listview1.model.append({name: fullname})
					}
					getPositionInfo()
                }
            }
        }
        xhr.send(data)
    }

	function playTrack(number) {
        if (debugOutput) console.log("*********sonos playTrack: " + number)
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n<u:Seek xmlns:u=\"urn:schemas-upnp-org:service:AVTransport:1\">\r\n  <InstanceID>0</InstanceID>\r\n  <Unit>TRACK_NR</Unit>\r\n  <Target>" + number + "</Target>\r\n</u:Seek>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + app.sonosArray[app.playerIndex].player.url + ":1400/MediaRenderer/AVTransport/Control");
		xhr.setRequestHeader("Content-Type", "text/xml; charset=utf-8");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:AVTransport:1#Seek");
        xhr.onreadystatechange = function() {
		if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					console.log("*********sonos responseXML :"  + responseXML)
                }
            }
        }
        xhr.send(data)
    }
	
	
	function getPositionInfo() {
        if (debugOutput) console.log("*********sonos GetPositionInfo")
        var xhr = new XMLHttpRequest();
		var data = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\r\n  <s:Body>\r\n<u:GetPositionInfo xmlns:u=\"urn:schemas-upnp-org:service:AVTransport:1\">\r\n  <InstanceID>0</InstanceID>\r\n</u:GetPositionInfo>\r\n  </s:Body>\r\n</s:Envelope>";
		xhr.open("POST", "http://" + app.sonosArray[app.playerIndex].player.url + ":1400/MediaRenderer/AVTransport/Control");
		xhr.setRequestHeader("soapaction", "urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo");	
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					var responseXML = xhr.responseText
					var thistrack  = responseXML.split("<Track>")[1].split("<")[0]
					if (debugOutput) console.log("*********sonos thistrack: "+ thistrack)
					if(thistrack)listview1.currentIndex= parseInt(thistrack)-1
                }
            }
        }
        xhr.send(data)
    }


}

