	


	function getFirstToken() {
		if (debugOutput) console.log("*********sonos getFirstToken()")
		setAfterTotalStartTimer.stop
		sonosPlayInfoTimer.stop
		numberofTries ++
		if (numberofTries<5){
			
			var doc2 = new XMLHttpRequest();
			doc2.open("PUT", "file:///var/tmp/sonos_token.txt");
			if (debugOutput) console.log("*********sonos credentials: " + encodeURIComponent(userName) + ";" + encodeURIComponent(passWord))
			doc2.send(encodeURIComponent(userName) + ";" + encodeURIComponent(passWord));

			var doc4 = new XMLHttpRequest();
			doc4.open("PUT", "file:///var/tmp/tsc.command");
			doc4.send("external-cloudSonos");
			sleep(12000)
			parseFirstToken()
		}else {
			if (debugOutput) console.log("*********sonos too many token tries")
		}
	}
	
	function parseFirstToken(){
		if (debugOutput) console.log("*********sonos parseFirstToken()")
		var http = new XMLHttpRequest()
		var url = "file:///var/tmp/sonosBearer.txt"
		http.open("GET", url, true);
		http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					console.log("*********sonos http.responseText " + http.responseText)
					if (http.responseText.indexOf("error")> 0){
						tokenOK = false
						if (isFirstTry){
							isFirstTry = false;
							getFirstToken()
						}else{
							console.log("*********sonos something is wrong withe the token engine")
						}
					}else{
						tokenOK = true
						var JsonString = http.responseText
						var JsonObject= JSON.parse(JsonString)
						token = JsonObject.access_token
						refreshToken = JsonObject.refresh_token
						if (debugOutput) console.log("*********sonos token : " + token)
						if (debugOutput) console.log("*********sonos refreshToken : " + refreshToken)
						saveSettings();
						sleep(5000);
						getHouseholdsAndGroups();
					}
				} else {
					if (debugOutput) console.log("parseFirstToken error: " + http.status)
					tokenOK = false
				}
			}
		}
		http.send();
	}

	function getRefreshToken() {
		if (debugOutput) console.log("*********sonos getRefreshToken()")
		numberofTries ++
		if (numberofTries>2){token = ""; refreshToken = ""; getFirstToken()}
		setAfterTotalStartTimer.stop
		sonosPlayInfoTimer.stop
		var doc2 = new XMLHttpRequest();
		doc2.open("PUT", "file:///var/tmp/sonos_refresh.txt");
		doc2.send(refreshToken);
		var doc4 = new XMLHttpRequest();
		doc4.open("PUT", "file:///var/tmp/tsc.command");
		doc4.send("external-cloudSonos");
		sleep(10000)
		parseFirstToken()
	}

    function sleep(milliseconds) {
      var start = new Date().getTime();
      while ((new Date().getTime() - start) < milliseconds )  {
      }
    }
