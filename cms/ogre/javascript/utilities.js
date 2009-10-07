// Borswer detect so we can institute corrections for M$ IE
var browser = new Object();
browser.isIE = (/MSIE (\d+\.\d+);/.test(navigator.userAgent));
browser.ieVer = (browser.isIE) ? new Number(RegExp.$1) : -1;

var sessionID = null;

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

function initTwo(sID) {
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

    // This function is a duplicate of the init function for modification and testing before replacement
    //First, read in the data required for these forms
    var xmlHttp;
    var request;
    var message;
    var mesParsed;
    var i;

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
    // Send the actual request for information
    request = "/~ogre/asp/Burrito.asp?sessid=" + sessionID + "&iotype=retrieve";

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,false);
    xmlHttp.send(null);
    message = xmlHttp.responseText;
    if (message == "::::::::::::::"){
	request = "/~ogre/asp/Burrito.asp?sessid="+ "&userName=" + userName  + sessionID +"&iotype=create";
	xmlHttp.open("GET",request,false);
	xmlHttp.send(null);
	message = xmlHttp.responseText;
    }
    mesParsed = message.split(":",15);

    userLevel = parseInt(mesParsed[1]);
    ds = mesParsed[2];
    changeDataset(ds);
    document.getElementById("themes").value = mesParsed[3];
    if (mesParsed[3] == 12 )
	xmlThemeFile = '/~ogre/graphics/themes/ogre/ogre-theme.xml';
    else if (mesParsed[3] == 13 )
	xmlThemeFile = '/~ogre/graphics/themes/simple/ogre-simple.xml';
    else
	    return false;
    if (mesParsed[4] == 1)
	showToolTips = true;
    else
	showToolTips = false;
    document.getElementById("tooltips").checked = showToolTips;
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
    try {
	// Update the menu selections to reflect the proper level
	document.getElementById('userLevel').selectedIndex = userLevel;    // HTML Select
	if ( useDynMenu )
	    dm_ext_changeItem(0, 5, userLevel, [, , , , , "_"]);           // Deluxe menu userLevel

    } catch (e) {}

    // Init the menu structure 
    if ( useDynMenu )
	toggleMenu(null);

    // Init the dataset selection box
    var select = document.getElementById('dsSelection');

    for ( var i=0; i<select.length; i++ ) {
	if (select[i].value.indexOf(ds) > -1)
	    select.selectedIndex = i;
    }

    if ( useDynMenu ) {
	// Init the deluxe menu to reflect the dataset options
	var menuEntry = new Array();
	for ( var i=0; i<select.length; i++ ) {
	    if ( select[i].value.length ) {
		var value = select[i].value;
		var descr = select[i].innerHTML.substr(12);
		menuEntry = [descr,"javascript:changeDataset('"+value+"');"];
		dm_ext_addItem(0,6,menuEntry);

		if ( select[i].value.indexOf(ds) > -1 )
		    dm_ext_changeItem(0, 6, i, [, , , , , "_"]);
	    }
	}
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
    prevWin.bind('stdHelp', archHlp);

    // Construct the windowlets for the flash demo of the detector
    demoHlp = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('demohelp'), 
			      'hlpWin', "Using the CMS Detector Demonstration");

    demoWin = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('demo'), 
			      'archWin', "CMS Detector Demo");

    if ( xmlThemeFile.indexOf("ogre-theme") > -1 )
	demoWin.changeBkg("white-640.png");
    else if ( xmlThemeFile.indexOf("ogre-simple") > -1 )
	demoWin.changeBkg("white-640.jpg");
    demoWin.bind('archHelp', demoHlp);

    // Make sure all the windowlets appear & stay in the active area
    introWin.setMinTop(25);
    cntlWin.setMinTop(25);
    dataHlp.setMinTop(25);
    variHlp.setMinTop(25);
    archHlp.setMinTop(25);
    crdtWin.setMinTop(25);
    dataWin.setMinTop(25);
    variWin.setMinTop(25);
    archWin.setMinTop(25);
    prevWin.setMinTop(25);
    demoHlp.setMinTop(25);
    demoHlp.setMinTop(25);
    demoWin.setMinTop(25);

    // Since our background image is an alpha channel PNG... 
    // IE 6 & under is gonna choke on it. Reload the image
    // for bad browsers using the AlphaImageLoader filter
    // from M$ (located in jsWindowlet.js). Bad form, but
    // there it is.
    fnLoadPngs(document.getElementById('bkgImg'), 122, 190)

    // Close the splash screen and show the page
    try {
	document.getElementById('loadTxt').innerHTML = 
	    "<center><font color='green'><H1>Done!</H1></font></center><div id='progress'>";
	updateProgress(80);

	document.getElementById('load').style.display = "none";
	document.body.removeChild(document.getElementById('load'));

    } catch (e) {}

    document.getElementById('wrapper').style.display = "block";

    cntlWin.show();
    introWin.show();
    //Code to show the right ogre graphic
    switch (userLevel)
    {
    case 0:
	document.getElementById("bkgImg").src = "/~ogre/graphics/ogre-mirror-new-hat.png";
	break;
    case 1:
	document.getElementById("bkgImg").src = "/~ogre/graphics/ogre-mirror-new-glasses.png";
	break;
    case 2:
	document.getElementById("bkgImg").src = "/~ogre/graphics/ogre-mirror-new-mortar.png";
	break;
    case 3:
	document.getElementById("bkgImg").src = "/~ogre/graphics/ogre-mirror-new-wand.png";
	break;
    default:
	alert (userLevel);
	document.getElementById("bkgImg").src = "/~ogre/graphics/ogre-mirror-new-hat.png";
    }
    
    return true;
}

function sendState (parameter, value, encase) {
    // send a parameter and value to be stored
    var xmlHttp;
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
    //alert(message);
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
    xmlHttp.onreadystatechange = function() {
        if(xmlHttp.readyState==4) {
	    message = xmlHttp.responseText;
            if ( message.indexOf('userLevel') > 0 || message.indexOf('dataSet') > 0 )
		levelChange(true);
	}
    }
    // Request the history page from the server
    request = "/~ogre/asp/Burrito.asp?sessid=" + sessionID + "&iotype=send&parameter=" + parameter + "&value=" + value;
    // Send the Ajax request to the server
    //alert (request);
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

return;
}

function init() {

    // Initialize the drag & drop interface (in javascript/drag_drop)
    dragLoad();

    // Initialize the user level selection box
    var userLevel = -1;
    userLevel = parseInt(getCookie("userLevel"));
    if ( isNaN(userLevel) || userLevel == -1 ) {
	userLevel = 0;
	setCookie("userLevel", userLevel);
	levelChange();
    }
    try {
	// Update the menu selections to reflect the proper level
	document.getElementById('userLevel').selectedIndex = userLevel;    // HTML Select
	if ( useDynMenu )
	    dm_ext_changeItem(0, 5, userLevel, [, , , , , "_"]);           // Deluxe menu userLevel

    } catch (e) {}

    // Init the menu structure 
    if ( useDynMenu )
	toggleMenu(null);

    // Init the dataset selection box
    var ds = document.getElementById('dataset').value;
    var select = document.getElementById('dsSelection');

    for ( var i=0; i<select.length; i++ ) {
	if (select[i].value.indexOf(ds) > -1)
	    select.selectedIndex = i;
    }

    if ( useDynMenu ) {
	// Init the deluxe menu to reflect the dataset options
	var menuEntry = new Array();
	for ( var i=0; i<select.length; i++ ) {
	    if ( select[i].value.length ) {
		var value = select[i].value;
		var descr = select[i].innerHTML.substr(12);
		menuEntry = [descr,"javascript:changeDataset('"+value+"');"];
		dm_ext_addItem(0,6,menuEntry);

		if ( select[i].value.indexOf(ds) > -1 )
		    dm_ext_changeItem(0, 6, i, [, , , , , "_"]);
	    }
	}
    }    

    // Set the drag/drop option
    document.getElementById('dragdrop').checked  = useDragDrop;
    document.getElementById('dragdrop').disabled = false;

    // See if this browser is accepting cookies...
    var hasCookies = testCookies();

    if ( hasCookies ) {
	// Grab hold of the session ID... assuming that it's there
	sessionID = getCookie('sessionID');
    }

    if ( !sessionID ) { // If it ain't there ... we'll have to make our own
	var dec2hex = [ '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' ];
	var hex = new String();

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
	if ( hasCookies )
	    setCookie('sessionID', sessionID);
    }

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
    prevWin.bind('stdHelp', archHlp);

    // Construct the windowlets for the flash demo of the detector
    demoHlp = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('demohelp'), 
			      'hlpWin', "Using the CMS Detector Demonstration");

    demoWin = new jsWindowlet(xmlThemeFile, false, true, 
			      document.getElementById('demo'), 
			      'archWin', "CMS Detector Demo");

    if ( xmlThemeFile.indexOf("ogre-theme") > -1 )
	demoWin.changeBkg("white-640.png");
    else if ( xmlThemeFile.indexOf("ogre-simple") > -1 )
	demoWin.changeBkg("white-640.jpg");
    demoWin.bind('archHelp', demoHlp);

    // Make sure all the windowlets appear & stay in the active area
    introWin.setMinTop(25);
    cntlWin.setMinTop(25);
    dataHlp.setMinTop(25);
    variHlp.setMinTop(25);
    archHlp.setMinTop(25);
    crdtWin.setMinTop(25);
    dataWin.setMinTop(25);
    variWin.setMinTop(25);
    archWin.setMinTop(25);
    prevWin.setMinTop(25);
    demoHlp.setMinTop(25);
    demoHlp.setMinTop(25);
    demoWin.setMinTop(25);

    // Since our background image is an alpha channel PNG... 
    // IE 6 & under is gonna choke on it. Reload the image
    // for bad browsers using the AlphaImageLoader filter
    // from M$ (located in jsWindowlet.js). Bad form, but
    // there it is.
    fnLoadPngs(document.getElementById('bkgImg'), 122, 190)

    // Close the splash screen and show the page
    try {
	document.getElementById('loadTxt').innerHTML = 
	    "<center><font color='green'><H1>Done!</H1></font></center><div id='progress'>";
	updateProgress(80);

	document.getElementById('load').style.display = "none";
	document.body.removeChild(document.getElementById('load'));

    } catch (e) {}

    document.getElementById('wrapper').style.display = "block";

    cntlWin.show();
    introWin.show();
    return true;

}

function changeDataset(newSet) {

    var newXMLName = new String();
    if ( newSet.indexOf("tb04") > -1 )
	newXMLName = "tb_data.xml";
    else if ( newSet.indexOf("mc09") > -1 )
	newXMLName = "mc_data.xml";
    else
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

    // Now change the relevant parts of the page... 
    // essentially identical to a user level change
    // without changing the user level
    //levelChange(true);

    if ( !useDynMenu )
	return true;

    // finally reset the menu to reflect the new situation
    var select = document.getElementById('dsSelection');
    var menuEntry = new Array();

    for ( var i=0; i<select.length; i++ ) {
	if ( select[i].value.length ) {

	    var value = select[i].value;
	    var descr = select[i].innerHTML.substr(12);
	    menuEntry = [descr,"javascript:changeDataset('"+value+"');" , , , ""];

	    if ( select[i].value.indexOf(newSet) > -1 )
		dm_ext_changeItem(0, 6, i, [, , , , , "_"]);
	    else
		dm_ext_changeItem(0, 6, i, menuEntry);
	}
    }

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
	// Update the fancy menu to reflect the next choice that could be made
	for ( var i=0; i<menuItems.length; i++ ) {
	    if ( menuItems[i][0].indexOf("ToolTips") > -1 ) {
		if ( showToolTips )
		    menuItems[i][0] = "ToolTips Off";
		else
		    menuItems[i][0] = "ToolTips On";

		dm_ext_changeItem(0,4,4, menuItems[i]);
	    }
	}

    } else if ( option == 9 )
	toggleMenu();

    else if ( option == 10 )
	document.location.href = "mailto:karmgard.1@nd.edu?subject=Bug the OGRE";

    else if ( option == 11 ) {
	showEffects = !showEffects;
	sendState ("effects", showEffects, true);

	// Update the fancy menu to reflect the next choice that could be made
	for ( var i=0; i<menuItems.length; i++ ) {
	    if ( menuItems[i][0].indexOf("Effects") > -1 ) {
		if ( showEffects )
		    menuItems[i][0] = "Effects Off";
		else
		    menuItems[i][0] = "Effects On";

		try {
		    dm_ext_changeItem(0,4,5, menuItems[i]);
		} catch (e) {}
	    }
	}
    } else if ( option == 12 || option == 13 ) {
	flushTheme();

	if ( option == 12 )
	    xmlThemeFile = '/~ogre/graphics/themes/ogre/ogre-theme.xml';
	else if ( option == 13 )
	    xmlThemeFile = '/~ogre/graphics/themes/simple/ogre-simple.xml';
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

	demoWin.changeBkg("white-640.png");
	demoWin.bind('archHelp', demoHlp);

    }
    else if (option == 14){
	//make the ogre dance
    }

    document.getElementById('menu').selectedIndex = 0;
    return true;
}

function toggleMenu() {
    // Toggle between menu driven & button driven styles
    try {
	var menu = document.getElementById('menu');
    } catch (e) {return false;}

    if ( !menu )
	return false;

    if ( !menu.style.display )
	menu.style.display = "none";

    if (menu.style.display == "block") {

	var buttons = new Array();
	buttons = document.getElementsByName('button');
	for ( var i=0; i<buttons.length; i++ ) {
	    buttons[i].style.display = "block";
	}

	menu.style.display = "none";
    } else {

	var buttons = new Array();
	buttons = document.getElementsByName('button');
	for ( var i=0; i<buttons.length; i++ ) {
	    buttons[i].style.display = "none";
	}

	menu.style.display = "block";
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
	try {
	    cntlWin.show();
	} catch (e) {
	    try {
		ctlWin.show();
	    } catch(e) {}
	}
    } else if ( selection == 2 ) {
	toggleMenu();

	var menu = document.getElementById('menu');
	if ( menu.style.display == 'none' ) {
	    try {
		cntlWin.show();
	    } catch (e) {
		ctlWin.show();
	    }
	} else {
	    try {
		cntlWin.hide();
		cntlHlp.hide();
	    } catch (e) {
		ctlWin.hide();
		ctlHlp.hide();
	    }
	}
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

    var retVal = true;
    if ( sID ) {
	var form = parent.document.getElementById('restoreForm');
	retVal = submitForm(form, sID);
    }

    sID = 0;
    return retVal;

}

function levelChange(firstTime) {
    /*-- When the user level changes... update the pages to reflect the status --*/

    var firstTime = (firstTime != null) ? firstTime : true;

    var xmlHttp;
    var request;
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
    var dataset = document.getElementById('dataset').value;
    if ( firstTime )
	request = '/~ogre/asp/refreshUserLevel.asp?page=data&sessionID='+sessionID;
    else
	request = '/~ogre/asp/refreshUserLevel.asp?page=vars&sessionID='+sessionID;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

    if ( firstTime )
	levelChange(false);

} // End of ayncDB function

// Call for the fancy menu for the onChange event
// seperated from the simple call so that we can 
// sync the simple menu with this one.
function menuLevel(level) {
    if ( level < 0 || level > 3 )
	return false;

    // First... set the new level
    sendState("userLevel",level);

    // Sync the simple select to the menu if necessary
    document.getElementById('userLevel').options.selectedIndex = level;

    if ( useDynMenu ) {

	// Menu items 13-16 are the user levels.. reset them
	for ( var i=13; i<17; i++ )
	    dm_ext_changeItem(0,5,eval(i-13),menuItems[i]);

	// and disable this item
	dm_ext_changeItem(0, 5, level, [, , , , , "_"]);    
    }

    // and throw the call to levelChange to update the page
    //levelChange();

    return true;
}

// Call for the simple select menu for the onChange event
function simpleMenuLevel(level) {

    // Make sure this is a valid user level... and bail if it isn't
    level = parseInt(level);
    if ( level < 0 || level > 3 )
	return false;

    // First... set the new level
    sendState("userLevel",level, false);

    // Update Bert to reflect the newfound understanding....
    var source; // = new String();
    switch (level) {
    case 0:
	source = "/~ogre/graphics/ogre-mirror-new-hat.png";
	singleWindow = true;
	break;
    case 1:
	source = "/~ogre/graphics/ogre-mirror-new-glasses.png";
	singleWindow = true;
	break;
    case 2:
	source = "/~ogre/graphics/ogre-mirror-new-mortar.png";
	singleWindow = false;
	break;
    case 3:
	source = "/~ogre/graphics/ogre-mirror-new-wand.png";
	singleWindow = false;
	break;
    default:
	source = "/~ogre/graphics/ogre-mirror-new-hat.png";
	singleWindow = false;
    }
    document.getElementById("bkgImg").src = source;

    if ( useDynMenu ) {
	// Sync the fancy menu...
	// Menu items 13-16 are the user levels.. reset them
	for ( var i=13; i<17; i++ )
	    dm_ext_changeItem(0,5,eval(i-13),menuItems[i]);

	// and disable this item
	dm_ext_changeItem(0, 5, level, [, , , , , "_"]);    
    }

    // and throw the call to levelChange to update the page
    //levelChange();

    return true;
}