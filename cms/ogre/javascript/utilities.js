// Borswer detect so we can institute corrections for M$ IE
var browser = new Object();
browser.isIE = (/MSIE (\d+\.\d+);/.test(navigator.userAgent));
browser.ieVer = (browser.isIE) ? new Number(RegExp.$1) : -1;

function updateProgress(progress) {
    var progBar = document.getElementById('progress');
    progBar.style.width = progress+'%';
    return;
}

function createSessionID() {

    var dec2hex = [ '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' ];
    var hex = new String();
    var hasCookies = testCookies();

    for ( i=0; i<4; i++ ) {
	var decimal = Math.round(4294967296*Math.random()+1,0);
	hex += dec2hex[ decimal%16 ];
	decimal = Math.round(decimal/16,0);

	while ( decimal > 1 ) {
	    hex += dec2hex[ decimal%16 ];
	    decimal = Math.round(decimal/16,0);
	}
    }

    sessionID = hex;
    if ( hasCookies ) {
	setCookie('sessionID',sessionID);
    }

    return sessionID;
}

function init(sID) {

    // Grab hold of the session ID... assuming that it's there
    var userLevel = -1;
    var ds;

    // See if this browser is accepting cookies...
    var hasCookies = testCookies();

    if ( hasCookies ) {
	// Grab hold of the session ID... assuming that it's there
	sessionID = getCookie('sessionID');
    }

    if ( !sessionID ) { // If it ain't there ... we'll have to make our own
	sessionID = createSessionID();
    }

    //First, read in the data required for the forms
    var xmlHttp = createXMLHttp();
    var request;
    var message;
    var mesParsed;
    var i;

    // Send the actual request for information
    request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID + "&iotype=retrieve";

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,false);
    xmlHttp.send(null);
    message = xmlHttp.responseText;
    if (message == "::::::::::::::"){
	request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID + 
	    "&userName=" + userName  + "&iotype=create";
	xmlHttp.open("GET",request,false);
	xmlHttp.send(null);
	message = xmlHttp.responseText;
    }
    mesParsed = message.split(":",15);

    userLevel = parseInt(mesParsed[1]);
    ds = mesParsed[2];
    changeDataset(ds);
    document.getElementById("themes").value = mesParsed[3];
    document.getElementById("themesBtm").value = mesParsed[3];
    if (mesParsed[3] == 12 )
	xmlThemeFile = baseURL + '/xml/ogre-theme.xml';
    else if (mesParsed[3] == 13 )
	xmlThemeFile = baseURL + '/xml/ogre-simple.xml';
    else
	return false;
    if (mesParsed[4] == 1)
	showToolTips = true;
    else
	showToolTips = false;
    document.getElementById("tooltips").checked = showToolTips;
    document.getElementById("tooltipsBtm").checked = showToolTips;
    if (mesParsed[5] == 1)
	useDragDrop = true;
    else
	useDragDrop = false;
    document.getElementById("dragdrop").checked = useDragDrop;
    if (mesParsed[6] == 1)
	showEffects = true;
    else
	showEffects= false;
    document.getElementById("effects").checked = showEffects;

    selection = mesParsed[15];
    
    // Initialize the drag & drop interface (in javascript/drag_drop)
    dragLoad();

    // Initialize the user level selection box
    if ( isNaN(userLevel) || userLevel == -1 ) {
	userLevel = 0;
	sendState("userLevel", userLevel, false);
	levelChange();
    }

    // For beginners... Pin the windowlets to the browser and only show one at a time
    if ( userLevel < 2 )
	singleWindow = true;
    else
	singleWindow = false;

    try {
	// Update the menu selections to reflect the proper level
	document.getElementById('userLevel').selectedIndex = userLevel;
	document.getElementById('userLevelBtm').selectedIndex = userLevel;
    } catch (e) {}

    // Init the dataset selection box
    var select = document.getElementById('dsSelection');

    for ( var i=0; i<select.length; i++ ) {
	if (select[i].value.indexOf(ds) > -1)
	    select.selectedIndex = i;
    }

    // Set the drag/drop option
    document.getElementById('dragdrop').checked  = useDragDrop;
    document.getElementById('dragdrop').disabled = false;

    // Initialize the windowlets we'll be using
    introWin = new jsWindowlet(xmlThemeFile, false, true,
			       document.getElementById('intro'), 'hlpWin', 
			       "Introducing...Bert! (the ogre)" );

    var stat = 'Hint: use "zoom" to adjust the view -- <code>(CNTL) & +/-</code> in most browsers)';
    introWin.setStatus(stat);

    cntlHlp = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('cntlhelp'), 'hlpWin',
			      "Using the Controls");

    dataHlp = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('datahelp'), 'hlpWin',
			      "Selecting Data");

    variHlp = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('varhelp'), 'hlpWin',
			      "Selecting Quantities to Analyze");

    archHlp = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('archhelp'), 'hlpWin',
			      "Previous and Intermediate Results");

    prevHlp = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('prevhelp'), 'hlpWin',
			      "Previous and Intermediate Results");

    cntlWin = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('controls'), 'stdWin',
			      "OGRE Controls");
    cntlWin.bind('stdHelp', cntlHlp);

    crdtWin = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('credits'), 'hlpWin',
			      "Programming Credits");

    dataWin = new jsWindowlet(xmlThemeFile, false, true,
			      document.getElementById('moveData'), 
			      'stdWin', "Data Selection");
    var stat = "Hint: Drag one of the filters to a selection box";
    dataWin.setStatus(stat);
    dataWin.bind('stdHelp',dataHlp);

    variWin = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('moveVars'), 
			      'stdWin', "Plot Selection");
    variWin.bind('stdHelp', variHlp);

    archWin = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('moveArch'), 
			      'stdWin', "Studies In Progress");
    archWin.bind('stdHelp', archHlp);

    prevWin = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('movePrev'), 
			      'stdWin', "Completed Studies");
    prevWin.bind('stdHelp', prevHlp);

    // Construct the windowlets for the flash demo of the detector & the tutorial
    demoHlp = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('demohelp'), 
			      'hlpWin', "Using the CMS Detector Demonstration");

    demoWin = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('demo'), 
			      'archWin', "CMS Detector Demo");

    tutrWin = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('tutorial'), 
			      'stdWin', "OGRE Tutorial");


    if ( xmlThemeFile.indexOf("ogre-theme") > -1 )
	demoWin.changeBkg("white-640.png");
    else if ( xmlThemeFile.indexOf("ogre-simple") > -1 )
	demoWin.changeBkg("white-640.jpg");
    demoWin.bind('archHelp', demoHlp);

    // Make sure all the windowlets appear & stay in the active area
    introWin.setMinTop(45);
    cntlWin.setMinTop(45);
    dataHlp.setMinTop(45);
    variHlp.setMinTop(45);
    archHlp.setMinTop(45);
    crdtWin.setMinTop(45);
    dataWin.setMinTop(45);
    variWin.setMinTop(45);
    archWin.setMinTop(45);
    prevWin.setMinTop(45);
    demoHlp.setMinTop(45);
    demoHlp.setMinTop(45);
    demoWin.setMinTop(45);

    // Since our background image is an alpha channel PNG... 
    // IE 6 & under is gonna choke on it. Reload the image
    // for bad browsers using the AlphaImageLoader filter
    // from M$ (located in jsWindowlet.js). Bad form, but
    // there it is.
    fnLoadPngs(document.getElementById('bkgImg'), 122, 190);

    //cntlWin.show();

    //Code to show the right ogre graphic
    var backgroundImg = document.getElementById("bkgImg");
    if ( !backgroundImg )
	backgroundImg = document.getElementById("bkgImgieDiv");

    switch (userLevel) {
    case 0:
	introWin.show();   // For beginners... show the intro
	toggleMenu();      // and use the header/footer controls
	backgroundImg.src = baseURL + "/graphics/ogre-beanie.png";
	break;
    case 1:
	backgroundImg.src = baseURL + "/graphics/ogre-glasses.png";
	toggleMenu();      // Use the header/footer controls
	break;
    case 2:
	backgroundImg.src = baseURL + "/graphics/ogre-mortar.png";
	cntlWin.show();
	break;
    case 3:
	backgroundImg.src = baseURL + "/graphics/ogre-wand.png";
	cntlWin.show();
	break;
    default:
	introWin.show();
	backgroundImg.src = baseURL + "/graphics/ogre.png";
    }
    
    // Close the splash screen.... 
    try {
	document.getElementById('loadTxt').innerHTML = 
	    "<center><font color='green'><H1>Done!</H1></font></center><div id='progress'>";
	updateProgress(80);

	document.getElementById('load').style.display = "none";
	document.body.removeChild(document.getElementById('load'));

    } catch (e) {}

    // Render the page visible....
    document.getElementById('wrapper').style.display = "block";

    // And allow the tutorial to show (since it's flash if it's 
    // display is set to block straight away it'll show up over
    // the splash screen, ruining the effect).
    document.getElementById('tutorial').style.display="block";

    return true;
}

function sendState (parameter, value, encase) {
    // send a parameter and value to be stored
    var xmlHttp=createXMLHttp();
    var request;
    var message;
    if (encase == true){
        value = "'" + value + "'";
    }
    if (value == "'true'"){
        value = 1;
    }
    if (value == "'false'"){
        value = 0;
    }
    message = parameter + "=" + value;

    /*
     * States: 0 == The request is not initialized
     *         1 == The request has been set up
     *         2 == The request has been sent
     *         3 == The request is in process
     *         4 == The request is complete
     */
    xmlHttp.onreadystatechange = function() {
        if(xmlHttp.readyState==4) {
	    message = xmlHttp.responseText;
            if ( message.indexOf('userLevel') > 0 || message.indexOf('dataSet') > 0 )
		levelChange(true);
	}
    }

    // Make sure we know the sessionID
    if ( !sessionID )
	sessionID = getCookie('sessionID');

    // Request the history page from the server
    request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID + 
	"&iotype=send&parameter=" + parameter + "&value=" + value;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

    return;
}

function createXMLHttp() {
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
    return xmlHttp;
}

function toggleDragDrop() {
    var xmlHttp=createXMLHttp();

    useDragDrop = !useDragDrop;
    document.getElementById("dragdrop").checked=useDragDrop;

    // Make sure we know the sessionID
    if ( !sessionID )
	sessionID = getCookie('sessionID');

    // Request the history page from the server
    request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID + 
	"&iotype=send&parameter=dragDrop&value=" + useDragDrop;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);
    return;
}

function toggleTips() {

    var xmlHttp=createXMLHttp();

    showToolTips = !showToolTips;
    document.getElementById("tooltips").checked=showToolTips;
    document.getElementById("tooltipsBtm").checked=showToolTips;

    // Make sure we know the sessionID
    if ( !sessionID )
	sessionID = getCookie('sessionID');

    // Request the history page from the server
    request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID + 
	"&iotype=send&parameter=tooltip&value=" + showToolTips;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);
    return;
}

function changeDataset(newSet) {

    var newXMLName = new String();
    if ( newSet.indexOf("tb04") > -1 ) {
	newXMLName = "tb_data.xml";
	document.getElementById('dsSelection').selectedIndex = 0;
	document.getElementById('dsSelectionBtm').selectedIndex = 0;
    } else if ( newSet.indexOf("mc09") > -1 ) {
	newXMLName = "mc_data.xml";
	document.getElementById('dsSelection').selectedIndex = 1;
	document.getElementById('dsSelectionBtm').selectedIndex = 1;
    } else
	return false;

    // Step one... reset the global dataset variable
    document.getElementById('dataset').value = newSet;

    // Set two... update the location of the XML dataset descriptor
    var dsXML = new String();
    dsXML = document.getElementById('xmlfile').value;

    // Extract the current file name
    var oldXMLName = new String();
    oldXMLName = dsXML.substr( dsXML.lastIndexOf("/")+1 );

    // And replace it with the new file name (keeping the directory)
    dsXML = dsXML.replace(oldXMLName, newXMLName);

    // And reset the xmlfile with the new descriptor
    document.getElementById('xmlfile').value = dsXML;

    // And save the new setting in the settings DB on the server...
    sendState ("dataSet", newSet, true);

    // finally reset the menu to reflect the new situation
    var select = document.getElementById('dsSelection');

    return true;
}

function callButton(option) {

    if ( option == 0 )
	return false;
    else if ( option == 1 )
	dataWin.show();
    else if ( option == 2 )
	variWin.show();
    else if ( option == 3 )
	submitGetData(document.forms["getData"]);
    else if (option == 4 )
	archWin.show();
    else if ( option == 5 )
	prevWin.show();
    else if ( option == 6 )
	demoWin.show();
    else if ( option == 7 )
	document.getElementById('tutorialBtn').click();
    else if ( option == 8 ) {
	showToolTips = !showToolTips;

	// Update the HTML checkbox with the new state
	if ( showToolTips ) {
	    try {
		document.getElementById('tooltips').checked = true;
	    } catch (e) {}
	} else {
	    try {
		document.getElementById('tooltips').checked = false;
	    } catch(e) {}
	}
	sendState("tooltip", showToolTips, true);

    } else if ( option == 9 )
	toggleMenu();

    else if ( option == 10 )
	document.location.href = "mailto:karmgard.1@nd.edu?subject=Bug the OGRE";

    else if ( option == 11 ) {
	showEffects = !showEffects;
	sendState ("effects", showEffects, true);
	
    } else if ( option == 12 || option == 13 ) {
	flushTheme();

	// Sync the controls window selector with the footer selection
	document.getElementById('themes').selectedIndex = option-12;
	document.getElementById('themesBtm').selectedIndex = option-12;

	if ( option == 12 )
	    xmlThemeFile = baseURL + '/xml/ogre-theme.xml';
	else if ( option == 13 )
	    xmlThemeFile = baseURL + '/xml/ogre-simple.xml';
	else
	    return false;
	sendState ("theme", option, false);

	introWin = introWin.reTheme(xmlThemeFile,'hlpWin');
	cntlHlp  = cntlHlp.reTheme(xmlThemeFile,'hlpWin');
	dataHlp  = dataHlp.reTheme(xmlThemeFile,'hlpWin');
	variHlp  = variHlp.reTheme(xmlThemeFile,'hlpWin');
	archHlp  = archHlp.reTheme(xmlThemeFile,'hlpWin');
	crdtWin  = crdtWin.reTheme(xmlThemeFile,'hlpWin');
	cntlWin  = cntlWin.reTheme(xmlThemeFile,'stdWin');
	dataWin  = dataWin.reTheme(xmlThemeFile,'stdWin');
	variWin  = variWin.reTheme(xmlThemeFile,'stdWin');
	archWin  = archWin.reTheme(xmlThemeFile,'stdWin');
	prevWin  = prevWin.reTheme(xmlThemeFile,'stdWin');
	demoHlp  = demoHlp.reTheme(xmlThemeFile,'hlpWin');
	demoWin  = demoWin.reTheme(xmlThemeFile,'hlpWin');

	var stat = 'Hint: use "zoom" to adjust the view -- <code>(CNTL) & +/-</code> in most browsers)';
	introWin.setStatus(stat);

	stat = "Hint: Drag one of the filters to a selection box";
	dataWin.setStatus(stat);
	dataWin.bind('stdHelp',dataHlp);

	variWin.bind('stdHelp', variHlp);

	archWin.bind('stdHelp', archHlp);
	prevWin.bind('stdHelp', archHlp);

	if ( xmlThemeFile.indexOf("ogre-theme") > -1 )
	    demoWin.changeBkg("white-640.png");
	else if ( xmlThemeFile.indexOf("ogre-simple") > -1 )
	    demoWin.changeBkg("white-640.jpg");

	demoWin.bind('archHelp', demoHlp);

	// Make sure all the windowlets appear & stay in the active area
	introWin.setMinTop(45);
	cntlWin.setMinTop(45);
	dataHlp.setMinTop(45);
	variHlp.setMinTop(45);
	archHlp.setMinTop(45);
	crdtWin.setMinTop(45);
	dataWin.setMinTop(45);
	variWin.setMinTop(45);
	archWin.setMinTop(45);
	prevWin.setMinTop(45);
	demoHlp.setMinTop(45);
	demoHlp.setMinTop(45);
	demoWin.setMinTop(45);
	
    } else if (option == 14){
	//make the ogre dance
    }

    return true;
}

function toggleMenu() {
    var btnWrapperTop = document.getElementById('buttonWrapperTop');
    var btnWrapperBtm = document.getElementById('buttonWrapperBtm');

    if ( !btnWrapperTop.style.display || btnWrapperTop.style.display == "none" ) {
	btnWrapperTop.style.display = "block";
	btnWrapperBtm.style.display = "block";
	try {
	    cntlWin.hide();
	} catch (e) {
	    ctlWin.hide();
	}
    } else {
	btnWrapperTop.style.display = "none";
	btnWrapperBtm.style.display = "none";
	try {
	    cntlWin.show();
	} catch (e) {
	    ctlWin.show();
	}
    }
    return true;
}

function bkgClick(event) {

    // Cancel the browsers default action
    if ( browser.isIE ) {
	try {
	    window.event.cancelBubble = true;
	    window.event.returnValue = false;
	} catch(e) {}
    } else {
	try {
	    event.preventDefault();
	} catch(e) {}
    }

    // Figure out what the user wants....
    var selection = -1;
    var button    = event.button || event.which;

    // Dig out the userLevel from the settings table
    var xmlHttp=createXMLHttp();
    var request = baseURL+"/asp/Burrito.asp?sessid="+sessionID+"&iotype=retrieve";
    xmlHttp.open("GET",request,false);
    xmlHttp.send(null);

    // Parse the response...
    var mesParsed = xmlHttp.responseText.split(":",15);
    
    // And set the userLevel
    var userLevel = mesParsed[1];

    if ( button == 1 ) {
	if ( !(event.shiftKey || event.ctrlKey) )
	    selection = 1;
	else if ( event.shiftKey )
	    selection = 2;
	else if ( event.ctrlKey )
	    selection = 3;
    }

    // The background OGRE image was just clicked... find out what the user wants
    if ( selection == 1 ) {
	if ( userLevel > 1 ) {
	    try {
		cntlWin.show();
	    } catch (e) {
		try {
		    ctlWin.show();
		} catch(e) {}
	    }
	} else {
	    try {
		introWin.show();
	    } catch(e) {}
	}
    } else if ( selection == 2 ) {
	toggleMenu();

    } else if ( selection == 3 )
	try { (document.getElementById('credits'))?toggle("credits"):null } catch(e){};

    return true;
}

function restoreArchive(event, sID, srcID) {
    if ( event ) {
	var button = event.button || event.which;
	if ( button != 1 )
	    return false;
    }

    var hasCookies = testCookies();
    var retVal = true;
    if ( sID ) {
	var form = parent.document.getElementById('restoreForm');
	retVal = submitForm(form, sID);

	if ( hasCookies ) {
	    setCookie('sessionID',sID);
	}
    }

    sID = 0;
    return retVal;

}

function levelChange(firstTime) {
    /*-- When the user level changes... update the pages to reflect the status --*/
    var firstTime = (firstTime != null) ? firstTime : true;

    var xmlHttp=createXMLHttp();
    var request;

    /*
     * States: 0 == The request is not initialized
     *         1 == The request has been set up
     *         2 == The request has been sent
     *         3 == The request is in process
     *         4 == The request is complete
     */
    xmlHttp.onreadystatechange=function() {
	if(xmlHttp.readyState==4) {
	    // Grab the first line of the response
	    var lineOne = xmlHttp.responseText.substr(0,xmlHttp.responseText.indexOf('\n'));
	    var response = xmlHttp.responseText.substr(xmlHttp.responseText.indexOf('\n'));

	    if ( lineOne.indexOf("data") > -1 ) {
		document.getElementById('moveData').innerHTML = response;

		// reload the drag & drop library
		dragLoad();
	    } else if ( lineOne.indexOf("vars") > -1 )  {
		document.getElementById('moveVars').innerHTML = response;

		// reload the drag & drop library
		dragLoad();

	    }
	}
    }

    // Request the data page for the new user level
    if ( !document.getElementById('dataset') )
	return;

    if ( firstTime )
	request = baseURL + '/asp/refreshUserLevel.asp?page=data&sessionID='+sessionID;
    else
	request = baseURL + '/asp/refreshUserLevel.asp?page=vars&sessionID='+sessionID;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

    if ( firstTime )
	levelChange(false);

} // End of ayncDB function

// Call for the simple select menu for the onChange event
function simpleMenuLevel(level) {

    // Make sure this is a valid user level... and bail if it isn't
    level = parseInt(level);
    if ( level < 0 || level > 3 )
	return false;

    // First... set the new level
    sendState("userLevel",level, false);

    // Update Bert to reflect the newfound understanding....
    var source = new String();
    switch (level) {
    case 0:
	source = baseURL + "/graphics/ogre-beanie.png";
	singleWindow = true;
	break;
    case 1:
	source = baseURL + "/graphics/ogre-glasses.png";
	singleWindow = true;
	break;
    case 2:
	source = baseURL + "/graphics/ogre-mortar.png";
	singleWindow = false;
	break;
    case 3:
	source = baseURL + "/graphics/ogre-wand.png";
	singleWindow = false;
	break;
    default:
	source = baseURL + "/graphics/ogre.png";
	singleWindow = false;
    }
    var backgroundImg = document.getElementById("bkgImg");

    //if ( !backgroundImg ) {
    //backgroundImg = document.getElementById("bkgImgieDiv");
    //} else {
    backgroundImg.src = source;
    //}

    // Sync the two level selectors... control window & footer
    document.getElementById('userLevelBtm').selectedIndex = level;
    document.getElementById('userLevel').selectedIndex = level;

    switch (level) {
    case 0:
	try {
	    cntlWin.hide();
	} catch (e) {
	    ctlWin.hide();
	}
	document.getElementById('buttonWrapperTop').style.display="block";
	document.getElementById('buttonWrapperBtm').style.display="block";
	introWin.show();
	break;

     case 1:
	try {
	    cntlWin.hide();
	} catch (e) {
	    ctlWin.hide();
	}
	document.getElementById('buttonWrapperTop').style.display="block";
	document.getElementById('buttonWrapperBtm').style.display="block";
	introWin.hide();
	break;

    case 2: case 3:
	try {
	    cntlWin.show();
	} catch (e) {
	    ctlWin.show();
	}
	document.getElementById('buttonWrapperTop').style.display="none";
	document.getElementById('buttonWrapperBtm').style.display="none";
	introWin.hide();
	break;
    }

    return true;
}