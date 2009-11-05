var isArchived = false;
function submitForm(thisForm) {

    var historyVisible = (hstWin.newWin.style.display == "block") ? 1 : 0;

    var hVisble = document.createElement('INPUT');
    hVisble.name = 'historyVisible';
    hVisble.type = 'hidden';
    hVisble.value = (!isNaN(historyVisible)) ? historyVisible : 0;

    thisForm.appendChild(hVisble);

    var unit = document.createElement('INPUT');
    unit.name  = 'units';
    unit.type  = 'hidden';
    unit.value = document.forms['hiddenInput'].units.value;

    thisForm.appendChild(unit);

    var sID   = document.createElement('INPUT');
    sID.name  = 'sessionID';
    sID.type  = 'hidden';
    sID.value = sessionID;

    thisForm.appendChild(sID);

    with (thisForm) {
	archive.value = 0;
	finalize.value = 0;
    }

    // Build an AJAX request to update the cuts in the database
    var xmlHttp = createXMLHttp();
    var request = baseURL + '/asp/updateCuts.asp?sessionID='+sessionID+
	'&selection='+newCut.replace(/&/g,"%26");

    xmlHttp.open("GET",request,false); // synchronus request
    xmlHttp.send(null);

    thisForm.submit();
    return true;
}

function setCuts(s) {
   var i = s.indexOf('[') + 1;
   var j = s.indexOf(']');
   var range;
   if ( j > i ) {
     range = s.substring(i,j);
   } else
    return false;

   i = range.indexOf(',');
   var min = range.substring(0,i);
   var max = range.substring(i+1,range.length);  

   document.recut.cutMin.value = min;
   document.recut.cutMax.value = max;

}

function archiveStudy(thisForm) {
    var xmlHttp=createXMLHttp();

    /*
     * States: 0 == The request is not initialized
     *         1 == The request has been set up
     *         2 == The request has been sent
     *         3 == The request is in process
     *         4 == The request is complete
     */
    xmlHttp.onreadystatechange=function() {
	if ( xmlHttp.readyState == 0 ) {
	} else if ( xmlHttp.readyState == 4 ) {

	    var check = xmlHttp.responseText.substring(0,1);

	    var alert = document.getElementById('alertdiv');
	    var text  = document.getElementById('alerttext');
	    text.innerHTML = xmlHttp.responseText.substring(2);

	    if (  check == 0 ) {
		text.style.color = '#00ff00';
		text.style.margin = "20% 25%";
		text.style.fontSize = '3em';
	    } else if ( check == 1 ) {
		text.style.color = '#ff0000';
		text.style.margin = "15% 4.5%";
		text.style.fontSize = '2em';
	    } else if ( check == 2 ) {
		text.style.color = '#ff0000';
		text.style.margin = "25% 4.5%";
		text.style.fontSize = '3em';
	    } else if ( check == 3 ) {
		text.style.color = '#ff0000';
		text.style.margin = "15% 5%";
		text.style.fontSize = '3em';
	    }

	    // Pop up the alert div to let the user see that something happened
	    alert.style.display = "block";
	    alert.style.zIndex = 15;

	    // And schedule it to close out in a few seconds
	    if ( !browser.isIE )
		setTimeout(closeAlert, 2500);
	    else {
		var callback = function() {closeAlert();};
		setTimeout(callback, 2500);
	    }
	}
    }

    // Build the request
    var dir = document.forms['recut'].directory.value;
    var typ = document.forms['recut'].type.value;
    var ver = document.forms['recut'].version.value;

    var request = baseURL+'/asp/saveStudy.asp?directory=' +
	dir + '&version=' + ver + '&type=' + typ + '&overwrite=' + !isArchived + 
	'&finalize=' + 0;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

    return false;
}

function closeAlert() {
    var alert = document.getElementById('alertdiv');
    alert.style.display = "none";
    return;
}

function finalizeStudy(thisForm) {
    var xmlHttp=createXMLHttp();

    /*
     * States: 0 == The request is not initialized
     *         1 == The request has been set up
     *         2 == The request has been sent
     *         3 == The request is in process
     *         4 == The request is complete
     */
    xmlHttp.onreadystatechange=function() {
	if ( xmlHttp.readyState == 0 ) {
	} else if ( xmlHttp.readyState == 4 ) {

	    var check = xmlHttp.responseText.substring(0,1);

	    var alert = document.getElementById('alertdiv');
	    var text  = document.getElementById('alerttext');
	    text.innerHTML = xmlHttp.responseText.substring(2);

	    if (  check == 0 ) {
		text.style.color = '#ff00ff';
		text.style.fontSize = '2em';
		text.style.width = '18em';
		text.style.margin = "5% 7.5%";
		text.innerHTML = "Congratulations young scientist... " +
		"your study is complete!" +
		" We shall now return thee whence thou came..." +
		"<br><br><br>(Say howdy-do to Bert for us)";
	    } else if ( check == 1 ) {
		text.style.color = '#ff0000';
		text.style.margin = "15% 4.5%";
		text.style.fontSize = '2em';
	    } else if ( check == 2 ) {
		text.style.color = '#ff0000';
		text.style.margin = "25% 4.5%";
		text.style.fontSize = '3em';
	    } else if ( check == 3 ) {
		text.style.color = '#ff0000';
		text.style.margin = "15% 5%";
		text.style.fontSize = '3em';
	    }

	    // Pop up the alert div to let the user see that something happened
	    alert.style.zIndex = 15;
	    alert.style.display = "block";
	    
	    // and fade it away slowly
	    var turnOff = new Array( alert );
	    var fadeStep = (check != "unable") ? 0.005 : 0.005;

	    var userName = getUserName();
	    var url = baseURL+'/ogre.php?user='+userName;

	    // if it worked, wait a couple seconds... then return the user to the front page
	    if ( check != "unable" ) {
		var timer = 2000 + 10/fadeStep;
		setTimeout(function(){document.location.href=url;}, timer);
	    } else {
		crossFade(null, turnOff, fadeStep);
	    }
	    return false;
	}
    }

    //////////////////////////////////////
    // Now that they've completed a study... bump the user level up a notch
    var ajax = createXMLHttp();

    var request = baseURL + "/asp/Burrito.asp?iotype=retrieve&sessid=" + sessionID;
    ajax.open("GET", request, false);
    ajax.send(null);

    var mesParsed = ajax.responseText.split(":",15);
    var userLevel = mesParsed[1];
    var user      = getUserName();

    if ( userLevel < 3 && user.indexOf('guest') == -1 ) {
	userLevel++;
	sendState("userLevel", userLevel, false, true);
    }
    /////////////////////////////////////

    // Build the request
    var dir = document.forms['recut'].directory.value;
    var typ = document.forms['recut'].type.value;
    var ver = document.forms['recut'].version.value;

    var request = baseURL+'/asp/saveStudy.asp?directory=' +
	dir + '&version=' + ver + '&type=' + typ + '&overwrite=' + !isArchived
	+ '&finalize='+1;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

    return false;

}

function getUserName() {
    var sessionID = getCookie('sessionID');
    if ( !sessionID )
	return null;

    var xmlHttp=createXMLHttp();

    var request = baseURL + '/asp/Burrito.asp?sessid='+sessionID+'&iotype=getUser';
    xmlHttp.open("GET",request,false);
    xmlHttp.send(null);
    return xmlHttp.responseText;
}