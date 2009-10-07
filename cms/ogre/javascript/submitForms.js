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

    with (thisForm) {
	archive.value = 0;
	finalize.value = 0;
    }

    thisForm.submit();
    return false;
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
    var xmlHttp;
    try {
	// Firefox, Opera 8.0+, Safari
	xmlHttp=new XMLHttpRequest();
    } catch (e) {
	// Internet Explorer
	try {
	    xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e) {
	    try {
		xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
	    } catch (e) {
		alert("Your browser does not support AJAX!");
		return false;
	    }
	}
    }

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

	    var check = xmlHttp.responseText.substring(0,6).toLowerCase();
	    var alert = document.getElementById('alertdiv');
	    var text  = document.getElementById('alerttext');
	    text.style.color = "#00ff00";

	    if (  check == "unable" ) {
		text.innerHTML = xmlHttp.responseText;
		text.style.color = '#ff0000';
	    } else {
		text.innerHTML = xmlHttp.responseText;
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

    var request = '/~ogre/asp/saveStudy.asp?directory=' +
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
    var xmlHttp;
    try {
	// Firefox, Opera 8.0+, Safari
	xmlHttp=new XMLHttpRequest();
    } catch (e) {
	// Internet Explorer
	try {
	    xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e) {
	    try {
		xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
	    } catch (e) {
		alert("Your browser does not support AJAX!");
		return false;
	    }
	}
    }

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
	    var check = xmlHttp.responseText.substring(0,6).toLowerCase();
	    var alert = document.getElementById('alertdiv');
	    var text  = document.getElementById('alerttext');

	    text.style.color = "#00ff00";
	    text.style.fontSize = '5em';
	    text.style.width = '48em';
	    text.style.left = "1em";
	    text.innerHTML = "";

	    if (  check == "unable" ) {
		text.innerHTML = xmlHttp.responseText;
		text.style.color = '#ff0000';
	    } else {
		text.style.color = '#ff00ff';
		text.style.fontSize = '2em';
		text.style.width = '18em';
		text.style.left = "1.75em";
		text.innerHTML = "Congratulations young scientist... " +
		"your study is complete!" +
		" We shall now return thee whence thou came..." +
		"<br><br><br>(Say howdy-do to Bert for us)";
	    }

	    // Pop up the alert div to let the user see that something happened
	    alert.style.display = "block";
	    
	    // and fade it away slowly
	    var turnOff = new Array( alert );
	    var fadeStep = (check != "unable") ? 0.005 : 0.005;
	    
	    // if it worked, wait a couple seconds... then return the user to the front page
	    if ( check != "unable" ) {
		var timer = 2000 + 10/fadeStep;
		setTimeout(function(){document.location.href="/~ogre/";}, timer);
	    } else {
		crossFade(null, turnOff, fadeStep);
	    }
	    return false;
	}
    }

    // Build the request
    var dir = document.forms['recut'].directory.value;
    var typ = document.forms['recut'].type.value;
    var ver = document.forms['recut'].version.value;

    var request = '/~ogre/asp/saveStudy.asp?directory=' +
	dir + '&version=' + ver + '&type=' + typ + '&overwrite=' + !isArchived
	+ '&finalize='+1;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

    return false;

}
