import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: favoritesScreen
	property bool debugOutput : app.debugOutput
	
	property bool screenisVisible: false

	screenTitle: app.groupName
	hasHomeButton: false
	
	property int  numberofItems :0
	property int  numberofItems2 :0
	property int  numberofItems3 :0
	
	onShown: {
			model.clear()
			updatePlaylist()
			radioButtonList1.currentIndex = app.favoriteScreenRadioOption1
			screenisVisible = true
	}
	
	onHidden: {
		screenisVisible = false
	}
	
	Text {
		id: playlistTXT
		width:  160
		text: "Afspeellijst:"
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
		height: isNxt ? 170:136
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
			var playlistId = app.playlist[listview1.currentIndex].id
			if (debugOutput) console.log(app.playlist[listview1.currentIndex].id)
			if (debugOutput) console.log(app.playlist[listview1.currentIndex].type)
			
			if (app.playlist[listview1.currentIndex].type === "favoriteType"){ //is a playlist from the favorites type
				switch (radioButtonList1.currentIndex) {

					case 0:
						if (debugOutput) console.log("Vervangen");
						app.postGroupCommand("favorites", JSON.stringify({ favoriteId : playlistId,  "playOnCompletion" : true, "action": "REPLACE",  "playModes" : { "shuffle" : false }}))
						break;

					case 1:
						if (debugOutput) console.log("Toevoegen");
						app.postGroupCommand("favorites", JSON.stringify({ favoriteId : playlistId,  "playOnCompletion" : true, "action": "APPEND",  "playModes" : { "shuffle" : false }}))
						break;
					case 2:
						if (debugOutput) console.log("Invoegen");
						app.postGroupCommand("favorites", JSON.stringify({ favoriteId : playlistId,  "playOnCompletion" : true, "action": "INSERT",  "playModes" : { "shuffle" : false }}))
						break;
					case 3:
						if (debugOutput) console.log("Tussenvoegen");
						app.postGroupCommand("favorites", JSON.stringify({ favoriteId : playlistId,  "playOnCompletion" : true, "action": "INSERT_NEXT",  "playModes" : { "shuffle" : false }}))
						break;
					default:
						if (debugOutput) console.log("Ongeldig");
						break;
				}
			}else{
				switch (radioButtonList1.currentIndex) {
					case 0:
						if (debugOutput) console.log("Vervangen");
						app.postGroupCommand("playlists", JSON.stringify({ playlistId : playlistId,  "playOnCompletion" : true, "action": "REPLACE",  "playModes" : { "shuffle" : false }}))
						break;

					case 1:
						if (debugOutput) console.log("Toevoegen");
						app.postGroupCommand("playlists", JSON.stringify({ playlistId : playlistId,  "playOnCompletion" : true, "action": "APPEND",  "playModes" : { "shuffle" : false }}))
						break;
					case 2:
						if (debugOutput) console.log("Invoegen");
						app.postGroupCommand("playlists", JSON.stringify({ playlistId : playlistId,  "playOnCompletion" : true, "action": "INSERT",  "playModes" : { "shuffle" : false }}))
						break;
					case 3:
						if (debugOutput) console.log("Tussenvoegen");
						app.postGroupCommand("playlists", JSON.stringify({ playlistId : playlistId,  "playOnCompletion" : true, "action": "INSERT_NEXT",  "playModes" : { "shuffle" : false }}))
						break;
					default:
						if (debugOutput) console.log("Ongeldig");
						break;
				}
			}
			app.favoriteScreenRadioOption1 = radioButtonList1.currentIndex
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

	Text {
		id: itemsTXT
		width:  160
		text: "Items in afspeellijst:"
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.bold.name
		visible: numberofItems2 > 0
		anchors {
			top:		listviewContainer1.bottom
			left:   	listviewContainer1.left
			topMargin : isNxt ? 10 : 8
		}
	}

	Rectangle{
		id: listviewContainer2
		width: isNxt ? parent.width/2 -100 : parent.width/2 - 80
		height: isNxt ? 170:136
		color: "white"
		radius: isNxt ? 5 : 4
		border.color: "black"
		border.width: isNxt ? 3 : 2
		visible: numberofItems2 > 0
		anchors {
			top:		itemsTXT.bottom
			topMargin: 	isNxt ? 5 : 4
			left:   	listviewContainer1.left
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
	
	Image {
		id: favoriteImage
		source: screenisVisible?  (app.playlist[listview1.currentIndex].imageUrl.length > 5)? app.playlist[listview1.currentIndex].imageUrl : Qt.resolvedUrl("drawables/sonos.png") : ""
		fillMode: Image.PreserveAspectFit
		height: isNxt ? 200:160
		width: isNxt ? 200:160
		anchors {
			top:		listviewContainer1.bottom
			horizontalCenter: listviewContainer1.horizontalCenter
			topMargin : isNxt ? 10 : 8
		}
		visible: !listviewContainer2.visible
	}
	
	Text {
		id: playlistQueueTXT
		width:  listviewContainer1.width
		text: "Wijze van invoegen:"
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.bold.name
		anchors {
			left: listviewContainer1.left
			top: listviewContainer2.visible? listviewContainer2.bottom : favoriteImage.visible ? favoriteImage.bottom: listviewContainer1.bottom
			topMargin: 	isNxt ? 5 : 4
		}
	}

	SonosRadioButtonList {
		id: radioButtonList1
		width: listviewContainer1.width
		height: isNxt ? 90:72
		gridCellWidth: isNxt ? 200:157
		gridCellHeight: isNxt ? 32:25
		radioWidth: isNxt ? 180:164
		radioHeight:isNxt ? 29:23
		backgroundColor:colors.canvas
		
		anchors {
			left: listviewContainer1.left
			top: playlistQueueTXT.bottom
			topMargin: isNxt ? 5 : 4
		}
		title: qsTr("Local access")

		Component.onCompleted: {
			addItem("Vervangen");
			addItem("Toevoegen");
			addItem("Invoegen");
			addItem("Tussenvoegen");
			forceLayout();
		}
	}
	
	
	
	Text {
		id: favoriteTXT
		width:  160
		text: "Favorieten/stations:"
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.bold.name
		anchors {
			top:		playlistTXT.top
			left:   	upButton.right
			leftMargin : isNxt ? 20 : 16
		}
	}
	
	Rectangle{
		id: listviewContainer3
		width: isNxt ? parent.width/2 -100 : parent.width/2 - 80
		height: isNxt ? 170:136
		color: "white"
		radius: isNxt ? 5 : 4
		border.color: "black"
		border.width: isNxt ? 3 : 2
		anchors {
			top:		favoriteTXT.bottom
			left:   	favoriteTXT.left
			topMargin : isNxt ? 5 : 4
		}

		Component {
			id: aniDelegate3
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
				id: model3
		}
		ListView {
			id: listview3
			anchors {
				top: parent.top
				topMargin:isNxt ? 20 : 16
				leftMargin: isNxt ? 12 : 9
				left: parent.left
			}
			width: parent.width
			height: isNxt ? (parent.height-50) : (parent.height-40)
			model:model3
			delegate: aniDelegate3
			highlight: Rectangle { 
				color: "lightsteelblue"; 
				radius: isNxt ? 5 : 4
			}
			focus: true
		}
	}
	

	IconButton {
		id: upButton3
		anchors {
			top: listviewContainer3.top
			left:  listviewContainer3.right
			leftMargin : isNxt? 3 : 2
		}

		iconSource: "qrc:/tsc/up.png"
		onClicked: {
		    if (listview3.currentIndex>0){
                        listview3.currentIndex  = listview3.currentIndex -1
						updateItems(app.playlist[listview1.currentIndex].id)
            }
		}	
	}
	
	IconButton {
		id: playButton3
		color: colors.background
		anchors {
			verticalCenter: listviewContainer3.verticalCenter
			left:  listviewContainer3.right
			leftMargin : isNxt? 3 : 2
		}

		iconSource: "qrc:/tsc/play.png"
		onClicked: {
			var favoriteId = app.favorites[listview3.currentIndex].id
			app.postGroupCommand("favorites", JSON.stringify({"favoriteId" : favoriteId ,"playOnCompletion" : true}))
			app.containerType = "station"
		}
	}

	IconButton {
		id: downButton3
		anchors {
			bottom: listviewContainer3.bottom
			left:  listviewContainer3.right
			leftMargin : isNxt? 3 : 2

		}

		iconSource: "qrc:/tsc/down.png"
		onClicked: {
		    if (numberofItems3>listview3.currentIndex + 1){
                   listview3.currentIndex  = listview3.currentIndex +1
            }
		}	
	}
	
	
	Image {
		id: stationsImage
		source: screenisVisible? app.favorites[listview3.currentIndex].imageUrl: ""
		fillMode: Image.PreserveAspectFit
		height: isNxt ? 200:160
		width: isNxt ? 200:160
		anchors {
			top:		listviewContainer3.bottom
			horizontalCenter: listviewContainer3.horizontalCenter
			topMargin : isNxt ? 10 : 8
		}
		visible:  screenisVisible? app.favorites[listview3.currentIndex].imageUrl.length > 5 : false
	}


	
	function updatePlaylist() {
        if (debugOutput) console.log("*********sonos updatePlaylist")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("GET", "https://api.ws.sonos.com/control/api/v1/households/" + app.households + "/playlists");
        xhr.setRequestHeader("Authorization", "Bearer " + app.token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    var JsonString = xhr.responseText
                    var JsonObject= JSON.parse(JsonString)
					var playlists = JsonObject.playlists
					app.playlist = [];
					numberofItems =  0
					for (var i in playlists) {
						if (debugOutput) console.log(playlists[i].name)
						app.playlist.push({"id": playlists[i].id, "fullname": playlists[i].name + "(" + playlists[i].trackCount + ")" , "name": playlists[i].name, "trackcount": playlists[i].trackCount, "imageUrl": ""});
						var fullname = playlists[i].name + "(" + playlists[i].trackCount + ")"
						if (fullname.length > 40){
							fullname  = fullname.substring(0, 38) + ".. "
						}
						listview1.model.append({name: fullname })
						numberofItems++
					}
					updateFavoriteslist()
					
                }
            }
        }
        xhr.send()
    }

	function updateItems(playlistId) {
        if (debugOutput) console.log("*********sonos updateItems")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("POST", "https://api.ws.sonos.com/control/api/v1/households/" + app.households + "/playlists/getPlaylist");
        xhr.setRequestHeader("Authorization", "Bearer " + app.token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
				model2.clear()
				numberofItems2=0
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    var JsonString = xhr.responseText
                    var JsonObject= JSON.parse(JsonString)
					var tracks = JsonObject.tracks
					//model2.clear() and numberofItems2=0 moved upwards
					for (var i in tracks) {
						if (tracks[i].name) {
							if (debugOutput) console.log(tracks[i].name)
							var type = "playlistType"
							if (debugOutput) console.log(tracks[i].name)
							var fullname = tracks[i].artist + " - " + tracks[i].name
							if (fullname.length > 40){
								fullname = fullname.substring(0, 38) + ".. "
							}
							listview2.model.append({"type": type, name: fullname})
							numberofItems2++
						}
					}
                }
            }
        }
        xhr.send(JSON.stringify({"playlistId": playlistId}));
    }

	function updateFavoriteslist(){
        if (debugOutput) console.log("*********sonos updateFavoriteslist")
        var xhr = new XMLHttpRequest();
        xhr.withCredentials = true;
        xhr.open("GET", "https://api.ws.sonos.com/control/api/v1/households/" + app.households + "//favorites");
        xhr.setRequestHeader("Authorization", "Bearer " + app.token);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if( xhr.readyState === 4){
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                    if (debugOutput) console.log(xhr.responseText)
                    var JsonString = xhr.responseText
                    var JsonObject= JSON.parse(JsonString)
					var items = JsonObject.items
					app.favorites = [];
					model3.clear()
					numberofItems3=0
					for (var i in items) {
						if (debugOutput) console.log(items[i].name)
						var type = "streamType"
						if (items[i].resource) type = items[i].resource.type
						if (debugOutput) console.log(type)
						if (type ==="PLAYLIST" || type ==="ALBUM"){
							var type = "favoriteType"
							
							var selectedImage = app.checkImage(items[i].imageUrl)
							app.playlist.push({"type": type, "id": items[i].id, "fullname": items[i].name + "(" + items[i].service.name +")" , "name": items[i].name, "trackcount": 0, "imageUrl": selectedImage});

							var fullname = items[i].name + "(" + items[i].service.name +")"
							if (fullname.length > 40){
								var listname = fullname.substring(0, 35 - items[i].service.name.length)
								fullname = listname + ".. (" + items[i].service.name +")"
							}
							listview1.model.append({name: fullname})
							numberofItems++
						}else{
							var type = "streamType"
							var selectedImage = app.checkImage(items[i].imageUrl)
							app.favorites.push({"type": type, "id": items[i].id, "name": items[i].name , "imageUrl": selectedImage});
							listview3.model.append({name: items[i].name})
							numberofItems3++
						}
					}
					updateItems(app.playlist[0].id)
                }
            }
        }
        xhr.send()
    }
	
}

