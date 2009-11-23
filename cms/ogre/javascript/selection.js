function include(filename) {
    var head = document.getElementsByTagName('head')[0];
    var scripts = head.getElementsByTagName('script');
    for ( var i=0; i<scripts.length; i++ ) {
	if ( scripts[i].src && scripts[i].src.indexOf(filename) > -1 )
	    return;
    }

    var head = document.getElementsByTagName('head')[0];

    var script = document.createElement('script');
    script.src = filename;
    script.type = 'text/javascript';

    head.appendChild(script);
}
var useDragDrop = true;

include(baseURL+"/javascript/utilities.js");
include(baseURL+"/javascript/submitForms.js");
include(baseURL+"/javascript/cookies.js");

// Include Walter Zorns wonderful javascript graphics package
include(baseURL+"/javascript/wz_jsgraphics.js");

var dragDiv;
var xmin   = 0;
var xmax   = 0;
var startX = 0;

var ymin   = 0;
var ymax   = 0;
var startY = 0;

var width  = 0;
var height = 0;
var dragging = false;
var selection = new String();
var newCut;

// Constants for converting graph units to pixels 
var graphXmin;
var graphXmax;
var graphYmin;
var graphYmax;
var X0;
var Y0;

var Xmin, Xmax, Ymin, Ymax;

var mouseOffSet;
var pixel2X;
var pixel2Xk;
var pixel2Y;
var pixel2Yk;

var units = new String();
var logx = false;
var logy = false;
var range = {x:0, y:0};

var plotType = 0;

// Objects that will hold the windowlets...
var browser = new Object();
var cutWin  = new Object();
var hlpWin  = new Object();
var hstWin  = new Object();
var ctlHlp  = new Object();

/*-- Get the position of the cursor sanely for everyone --*/
function getMousePosition(e) {

    if ( plotType != 1 && plotType != 2 )
	return {x:0,y:0};

    var coords = {x:0, y:0};
    if (!e) var e = window.event;
    if (e.pageX || e.pageY) {
	coords.x = e.pageX - cutWin.newWin.offsetLeft -
	    dragDiv.offsetLeft;
	coords.y = e.pageY - cutWin.newWin.offsetTop -
	    dragDiv.offsetTop;
    }
    else if (e.clientX || e.clientY) 	{
	coords.x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;

	if (cutWin.newWin != null && cutWin.newWin.offsetLeft != null) 
	    coords.x -= cutWin.newWin.offsetLeft;

	if (dragDiv != null && dragDiv.offsetLeft != null)
	    coords.x -= dragDiv.offsetLeft;

	coords.y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
	
	if ( cutWin.newWin != null && cutWin.newWin.offsetTop != null )
	    coords.y -= cutWin.newWin.offsetTop;

	if ( dragDiv != null && dragDiv.offsetTop != null )
	    coords.y -= dragDiv.offsetTop;
    }

    return coords;
}

// Define a Log_base_10 function as part of the generic Math object
Math.log10 = function(arg) {
    return Math.log(arg)/Math.LN10;
}
// And floating point rounding to 2 or 3 significant decimals
Math.round2 = function(arg) { 
    return Math.round(100*arg)/100;
}
Math.round3 = function(arg) { 
    return Math.round(1000*arg)/1000;
}

/*-- Convert pixel values to plot values --*/
function pixel2plot(pixel) {

    var a = 1;
    var pos = 0.0;
    var coords = {x:0, y:0};

    if ( logx )
	coords.x = eval(Math.pow(10,a*pixel2Xk + a*pixel2X*(pixel.x - X0)));
    else
	coords.x = eval(a*pixel2Xk + a*pixel2X*(pixel.x - X0));

    // Since y starts low at the top and increases as you go down the page
    // flip the axis to match what we'll be getting from the mouse
    pixel.y = Ymin + Ymax - pixel.y;

    if ( logy )
	coords.y = eval(Math.pow(10,pixel2Yk - pixel2Y*pixel.y));
    else
	coords.y = eval(pixel2Yk - pixel2Y*pixel.y);

    if ( range.x < 25 )
	coords.x = Math.round3(coords.x);
    else if ( range.x < 50 )
	coords.x = Math.round2(coords.x);
    else
	coords.x = Math.round(coords.x);

    if ( range.y < 25 ) 
	coords.y = Math.round3(coords.y);
    else if ( range.y < 50 )
	coords.y = Math.round2(coords.y);
    else
	coords.y = Math.round(coords.y);

    return coords;
}

function mouseTrap (event) {

    if ( plotType != 1 && plotType != 2 )
	return false;

    dragDiv = (!dragDiv) ? document.getElementById("graph") : dragDiv;
    if ( !dragDiv )
	alert("Can't find dragDiv!");

    if ( browser.isIE ) {
	document.attachEvent("onmousemove", select);
    } else {
	document.addEventListener("mousemove", select, true);
    }

    return;
}

function mouseRelease() {
    if ( plotType != 1 && plotType != 2 )
	return false;

    if ( browser.isIE )
	document.detachEvent("onmousemove", select);
    else
	document.removeEventListener("mousemove", select, true);
    return;
}

function clearSelection(event) {

    if ( browser.isIE ) {
	var coords = {x:0, y:0};
	coords = getMousePosition(event);
	if ( !isActive(coords.x, coords.y) ) {
	    jg.clear();
	    xmin=xmax=startX=Xmin-10;
	}
    } else {
	jg.clear();
	xmin=xmax=startX=Xmin-10;
    }

    selection = "";
    return;
}

function isActive(x, y) {
    var coords = {x:x, y:y};
    var place  = {x:0, y:0};

    try {
	place = pixel2plot(coords);

	if ( plotType == 1 ) {
	    if ( y > Ymin && y < Ymax && place.x > graphXmin && place.x < graphXmax)
		return true;
	    else
		return false;

	} else if ( plotType == 2 ) {
	    if ( place.y > graphYmin && place.y < graphYmax && place.x > graphXmin && place.x < graphXmax )
		return true;
	    else
		return false;
	} else
	    return false;
    } catch (e) {return false;}
}

function startDrag(event) {

    if ( browser.isIE ) {
	if ( event && event.button != 1 )
	    return;

	window.event.cancelBubble = true;
	window.event.returnValue = false;
    } else {
	if ( event.which != 1 )
	    return;
 	event.preventDefault();
    }

    startX = xmin = xmax = getMousePosition(event).x - mouseOffSet.x;
    startY = ymin = ymax = getMousePosition(event).y - mouseOffSet.y;

    var plotX = pixel2plot(xmin).x;
    if ( plotX > graphXmax || plotX < graphXmin ) {
	dragging = false;
	return false;
    }

    var plotY = pixel2plot(ymin).y;
    if ( plotY > graphYmax || plotY < graphYmin ) {
	dragging = false;
	return false;
    }

    dragging = true;
    jg.setColor('#ff00ff');

    return true;
}

function stopDrag(event) {

    if ( !dragging )
	return;

    if ( plotType != 1 && plotType != 2 )
	return false;

    var button;
    if (event)
	button = event.button || event.which;
    else
	button = 1;

    if ( useDragDrop && button != 1 )
	return;

    dragging = false;

    var coordsHi = {x:xmax-mouseOffSet.x, y:ymin};
    coordsHi = pixel2plot(coordsHi);

    var coordsLo = {x:xmin, y:ymax-mouseOffSet.y};
    coordsLo = pixel2plot(coordsLo);

    var xunits = units.split(':')[0];
    var yunits = units.split(':')[1];

    // Show the user what (s)he's done....
    if ( plotType == 1 )
	selection = 'Selected (' + coordsLo.x + ' ' + xunits + ', ' + coordsHi.x + ' ' + xunits + ')';
    else
	selection = 'Selected [(' + coordsLo.x + ' ' + xunits + ', ' + coordsLo.y + ' ' + yunits + '), ('
	    + coordsHi.x + ' ' + xunits + ', ' + coordsHi.y + ' ' + yunits + ')]';

    // And record the cuts...
    document.forms["recut"].cutXMin.value = coordsLo.x;
    document.forms["recut"].cutXMax.value = coordsHi.x;
    if ( plotType == 2 ) {
	document.forms["recut"].cutYMin.value = coordsLo.y;
	document.forms["recut"].cutYMax.value = coordsHi.y;
    }

    var temp = new Array();
    var currentSelection;

    if ( plotType == 1 ) {

	newCut = "";
	var selections = cuts.split(',');

	for ( var j=0; j<selections.length; j++ ) {
	    temp = selections[j].split('&&');

	    for ( var i=0; i<temp.length; i++ ) {

		if ( temp[i].indexOf('>') > -1 ) {  // x-axis lower bound
		    currentSelection = temp[i].split('>')[1];
		    temp[i] = temp[i].replace(currentSelection, coordsLo.x);

		} else {                            // x-axis upper bound

		    currentSelection = temp[i].split('\<')[1];
		    temp[i] = temp[i].replace(currentSelection, coordsHi.x);

		}
	    }

	    if ( j == 0 ) 
		newCut = temp.join("&&");
	    else
		newCut += "," + temp.join("&&");

	    temp = new Array();
	}


    } else if ( plotType ==2 ) {   // Cuts are in the page x vs y for scatter plots (type 2) 

	newCut = "";
	var selections = cuts.split(',');

	for ( var j=0; j<selections.length; j++ ) {
	    temp = selections[j].split('&&');

	    for ( var i=0; i<temp.length; i++ ) {

		if ( !(i%2) ) {                         // x-axis

		    if ( temp[i].indexOf('>') > -1 ) {  // x-axis lower bound
			currentSelection = temp[i].split('>')[1];
			temp[i] = temp[i].replace(currentSelection, coordsLo.x);

		    } else {                            // x-axis upper bound

			currentSelection = temp[i].split('\<')[1];
			temp[i] = temp[i].replace(currentSelection, coordsHi.x);

		    }
		
		} else {                                // y-axis

		    if ( temp[i].indexOf('>') > -1 ) {  // y-axis lower bound

			currentSelection = temp[i].split('>')[1];
			temp[i] = temp[i].replace(currentSelection, coordsLo.y);

		    } else {                            // y-axis upper bound

			currentSelection = temp[i].split('\<')[1];
			temp[i] = temp[i].replace(currentSelection, coordsHi.y);

		    }
		}

	    }
	    
	    if ( j == 0 )
		newCut = temp.join("&&");
	    else
		newCut += "," + temp.join("&&");

	    temp = new Array();
	}
    }
  
    return;
}

function select(event) {

    if ( plotType != 1 && plotType != 2 )
	return false;

    var coords = {x:0, y:0};
    coords = getMousePosition(event);
    var x = eval(coords.x - mouseOffSet.x);
    var y = eval(coords.y - mouseOffSet.y);

    var selOpacity = 0.25;
    var rejOpacity = 0.20;

    if ( !isActive(x,y) )
	return false;
    
    var xunits = units.split(':')[0];
    var yunits = units.split(':')[1];
    var coordsHi = {x:0,y:0};
    var coordsLo = {x:0,y:0};

    jg.clear();

    if ( dragging ) {

	// Get the current mouse coordinates, and convert them from pixels to plot units
	coordsHi = {x:(startX<x)?startX:x, y:(startY<y)?y:startY};
	coordsHi = pixel2plot(coordsHi);

	coordsLo = {x:(startX<x)?x:startX, y:(startY<y)?startY:y};
	coordsLo = pixel2plot(coordsLo);

	/*-- put the current selection on the status bar --*/
	if ( plotType == 1 ) {
	    selection = '(' + coordsHi.x + ' ' + xunits + ', ' + coordsLo.x + ' ' + xunits + ')';
	} else {
	    selection = '[(' + coordsHi.x + ' ' + xunits + ', ' + coordsHi.y + ' ' + yunits + '), ('
		+ coordsLo.x + ' ' + xunits + ', ' + coordsLo.y + ' ' + yunits + ')]';
	}

	/*-- Fade out the graph... --*/
	jg.setColor('#aaaaaa');
	jg.fillRect(Xmin, Ymin, Math.abs(Xmax-Xmin), Math.abs(Ymax-Ymin), rejOpacity);

	/*-- Highlight the selected region --*/
	jg.setColor('#ffff00');

	if ( plotType == 1 )
	    jg.fillRect( (startX<x)?startX:x, Ymin, Math.abs(startX-x), Math.abs(Ymax-Ymin), selOpacity);
	else
	    jg.fillRect( (startX<x)?startX:x, (startY<y)?startY:y, 
			 Math.abs(startX-x), Math.abs(startY-y), selOpacity);

    } else if ( xmin > Xmin ) {
	jg.setColor('#aaaaaa');
	jg.fillRect(Xmin, Ymin, Math.abs(Xmax-Xmin), Math.abs(Ymax-Ymin), rejOpacity);

	jg.setColor('#ffff00');
	if ( plotType == 1 )
	    jg.fillRect( xmin, Ymin, Math.abs(xmax-xmin-mouseOffSet.x), Math.abs(Ymax-Ymin), selOpacity);
	else
	    jg.fillRect(xmin, ymin, Math.abs(xmax-xmin-mouseOffSet.x), Math.abs(ymax-ymin-mouseOffSet.y), selOpacity);
    }

    if ( useDragDrop ) {
	/*-- put up a line by the mouse to guide the selection --*/
	jg.setColor('#ff0000');
	jg.drawLine(x,Ymax,x,Ymin);

	if ( plotType == 2 )
	    jg.drawLine(Xmin, y, Xmax, y);

	var position = {x:x, y:y};
	position = pixel2plot(position);
	var plotRange = graphXmax - graphXmin;
	if ( plotRange < 25 )
	    position.x = Math.round3(position.x);
	else if ( plotRange < 50 )
	    position.x = Math.round2(position.x);
	else
	    position.x = Math.round(position.x);

	if ( plotType == 2 ) {
	    plotRange = graphYmax - graphYmin;
	    if ( plotRange < 25 )
		position.y = Math.round3(position.y);
	    else if ( plotRange < 50 )
		position.y = Math.round2(position.y);
	    else
		position.y = Math.round(position.y);
	}

	var label  = position.x+" "+xunits;
	if ( plotType == 2 ) {
	    label = '(' + label;
	    label += ', '+position.y+" "+yunits+")";
	}

	jg.drawString(label, x+10,y-20);
	
    }

    // Put up the current selection
    jg.setColor('#ff0000');
    jg.drawString(selection,width/3,Ymin-18);

    jg.paint();

    /*-- And save the current selection --*/
    if ( dragging ) {
	xmin = (startX < x) ? startX : x;
	xmax = (startX < x) ? x : startX;
	xmax += mouseOffSet.x;

	ymin = (startY < y) ? startY : y;
	ymax = (startY < y) ? y : startY;
	ymax += mouseOffSet.y;

	coordsHi = {x:xmax,y:ymin};
	coordsLo = {x:xmin,y:ymax};

	coordsHi = pixel2plot(coordsHi);
	coordsLo = pixel2plot(coordsLo);

	range.x = coordsHi.x - coordsLo.x;
	range.y = coordsHi.y - coordsLo.y;
    }

    return true;
}

var click1 = false;
var click2 = false;
function onMouseClick(event) {

    dragDiv = (!dragDiv) ? document.getElementById("graph") : dragDiv;
    if ( !dragDiv )
	alert("Can't find dragDiv!");

    var coords = {x:0, y:0};
    coords = getMousePosition(event);
    var x = coords.x;
    var y = coords.y;

    if ( !click1 ) {
	xmin = x;
	click1 = true;

    } else if ( !click2 ) {
	if ( x >= xmin ) 
	    xmax = x;
	else {
	    xmax = xmin;
	    xmin = x;
	}
	stopDrag(event);
	select(event);
	click2 = true;

    } else {
	if ( browser.isIE ) {
	    var coords = {x:0, y:0};
	    coords = getMousePosition(event);
	    if ( !isActive(coords.x, coords.y) ) {
		jg.clear();
		xmin=xmax=startX=Xmin-10;
	    }
	} else {
	    jg.clear();
	    xmin=xmax=startX=Xmin-10;
	}

	selection = "";
	click1 = click2 = false;
    }

    return true;
}

function pageLoad() {

    // Sync the session ID cookie....
    if ( sessionID && testCookies() )
	setCookie('sessionID', sessionID);

    //load the coodinates
    var xmlHttp=createXMLHttp();
    var request;
    var message;
    var mesParsed;
    var i;

    // Request coordinates from the server
    var request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID + "&iotype=retrieve";

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,false);
    xmlHttp.send(null);
    message = xmlHttp.responseText;
    if (message == ":::::::::::::"){
	request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID +"&iotype=create";
	xmlHttp.open("GET",request,false);
	xmlHttp.send(null);
	message = xmlHttp.responseText;
    }

    var Xcoords = new Array(3);
    var Ycoords = new Array(3);
    mesParsed = message.split(":",14);
    for (i = 0; i < 3; i++) {
	Xcoords[i] = parseInt(mesParsed[7 + 2*i]);
	Ycoords[i] = parseInt(mesParsed[7 + 2*i + 1]);
    }

    // Set the user level...
    var userLevel =  mesParsed[1];

    var xmlTheme = (xmlTheme) ? xmlTheme : baseURL + "/xml/ogre-theme.xml";

    // First we initialize the DIV (container) of the draggable image as 'canvas'.
    container = document.getElementById("graph");
    jg = new jsGraphics(container);
    jg.setColor("#ff0000");

    try {
	width  = document.getElementById('image').clientWidth;
	height = document.getElementById('image').clientHeight;
    } catch (e) {}

    // Make the cut windowlet out of the graphics container...
    cutWin = new jsWindowlet(xmlTheme);
    cutWin.make(container, 'archWin', 'Data Selection', parseInt(1.11*width), parseInt(1.2*height));

    // Adjust for the drop shadows on the graphic
    cutWin.shAdjust(24, 24, width, height);
    cutWin.setMinTop(25);

    // Make a windowlet for the control buttons
    ctlWin = new jsWindowlet(xmlTheme);
    ctlWin.make(document.getElementById('controls'), 'stdWin', 
		'OGRE Controls');
    ctlWin.setMinTop(25);

    ctlHlp = new jsWindowlet(xmlTheme);
    ctlHlp.make(document.getElementById('ctlHlp'), 'hlpWin', 
		'Using OGRE Controls');
    ctlHlp.setMinTop(35);

    ctlWin.bind('stdHelp', ctlHlp);

    // And bind some help text to it
    hlpWin = new jsWindowlet(xmlTheme);
    hlpWin.make(document.getElementById('cuthelp'), 'hlpWin', "Refining Data Selection");
    hlpWin.setMinTop(35);

    cutWin.bind('archHelp', hlpWin);

    // Now then.... let's see what it is we're supposed to be showing...
    if ( userLevel < 2 ) {
	document.getElementById('buttonWrapperTop').style.display="block";
	document.getElementById('buttonWrapperBtm').style.display="block";
	singleWindow = true;

    } else {
	document.getElementById('buttonWrapperTop').style.display="none";
	document.getElementById('buttonWrapperBtm').style.display="none";
	singleWindow = false;

	ctlWin.show();
    }

    cutWin.show();

   // Offset of the graph on the page
    X0    = 11;
    Y0    = 0;
    mouseOffSet = {x:32, y:41};

    // Get the scale factors
    try {
	var w = document.hiddenInput.width.value;
	var scaleX = eval(w/width);
    } catch (e) {
	var scaleX = 1;
    }

    try {
	var h = document.hiddenInput.height.value;
	var scaleY = eval(h/height);
    } catch(e) {
	var scaleY = 1;
    }

    // Xmin/Xmax of the graph in graph units
    graphXmin = document.hiddenInput.xmin.value;
    graphXmax = document.hiddenInput.xmax.value;

    // Ymin/Ymax of the graph in graph units
    graphYmin = document.hiddenInput.ymin.value;
    graphYmax = document.hiddenInput.ymax.value;

    // Ymin/Ymax of the graph in pixels
    Ymin = Y0 + Math.round(eval(0.105*height)) - 2;
    Ymax = Y0 + Math.round(eval(0.892*height)) + 3;

    // Pixel-to-X conversion parameters
    pixel2X  = eval(scaleX*document.hiddenInput.X2px.value);
    pixel2Xk = document.hiddenInput.Xcst.value;

    // Pixel-to-Y conversion parameters
    pixel2Y  = document.hiddenInput.Y2px.value;
    pixel2Yk = document.hiddenInput.Ycst.value;

    // Xmin/Xmax of the graph in pixels
    Xmin = X0 + Math.round(eval(0.0975*width));
    Xmax = X0 + Math.round(eval(0.8975*width));

    ///////////////////////////// Windowlet popping ///////////////////////
    var hist = new Object();
    try {
	hist = document.getElementById("hist");
	hist.style.opacity = 1.0;
    } catch (e) {;}

    // load the history page into a div
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
	    var hist = document.getElementById('hist');
	    hist.innerHTML = xmlHttp.responseText;

	    var width  = parseInt(document.forms['mapSize'].histWidth.value);
	    var height = parseInt(document.forms['mapSize'].histHeight.value);
	    var historyVisible = false;
	    try {
		historyVisible = parseInt(document.forms['mapSize'].histVisible.value);
	    } catch (e) {
		historyVisible = true;
	    }

	    // Now that we have it.... make a windowlet out of the history
	    hstWin = new jsWindowlet(xmlTheme);
	    hstWin.make(hist, 'hlpWin', "Selection History", eval(width+50), eval(height+64));
	    hstWin.changeBkg("gray-plain.png");
	    hstWin.shAdjust(16, 24, width, height);
	    hstWin.setMinTop(35);

	    if ( historyVisible && !singleWindow )
		hstWin.show();

	    // Set the graphics window to the top of the stack by default
	    cutWin.setStack(cutWin.newWin);
	    // And move stuff about to the way it was 
	    ctlWin.moveTo(Xcoords[0],Ycoords[0]);
	    cutWin.moveTo(Xcoords[1],Ycoords[1]);
	    hstWin.moveTo(Xcoords[2],Ycoords[2]);
	    switch(mesParsed[13]){
	    case "controlsWin":
		ctlWin.setStack(ctlWin.newWin);
		break;
	    case "graphWin":
		cutWin.setStack(cutWin.newWin);
		break;
	    case "histWin":
		hstWin.setStack(hstWin.newWin);
		break;
	    default:
		cutWin.setStack(cutWin.newWin);
	    }
	}
    }

    // Request the history page from the server
    var request = baseURL + '/asp/getHistory.asp?id='+document.forms['recut'].directory.value;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

    // Grab the plot units from the page...
    units = document.hiddenInput.units.value;

    // And see if this is a log-log or semi-log plot...
    logx = (document.hiddenInput.logX.value == 0) ? false : true;
    logy = (document.hiddenInput.logY.value == 0) ? false : true;

    // Finally... bind over the mouse moves & clicks & whatnot to the histogram
    var graphics = document.getElementById('graph');
    if ( useDragDrop ) {
	graphics.onmouseover = mouseTrap;
	graphics.onmouseout  = mouseRelease;
	graphics.onmousedown = startDrag;
	graphics.onmouseup   = stopDrag;
	graphics.onclick     = clearSelection
    } else
	graphics.onclick     = onMouseClick;

    // And set the page range for reporting significant digits
    range.x = graphXmax - graphXmin;
    range.y = graphYmax - graphYmin;

    // And find out the type of plot we've got... 1 => histogram, 2=> scatter plot
    plotType = document.hiddenInput.plType.value;

    // If plotType != 1||2... then we're not doing selection at all...
    // So inhibit all the buttons which deal with selections
    //if ( plotType != 1 && plotType != 2 ) {;}


    return;
}

function callMenu(option) {
    if ( option == 0 )
	return false;
    else if ( option == 1 )
	submitForm(document.forms['recut']);
    else if ( option == 2 )
	delCookie('selection', baseURL + "/");
    else if ( option == 3 )
	archiveStudy(document.forms['recut']);
    else if ( option == 4 )
	finalizeStudy(document.forms['recut']);
    else if ( option == 5 ) {
	showEffects = !showEffects;

	// Update the fancy menu to reflect the next choice that could be made
	for ( var i=0; i<menuItems.length; i++ ) {
	    if ( menuItems[i][0].indexOf("Effects") > -1 ) {
		if ( showEffects )
		    menuItems[i][0] = "Effects Off";
		else
		    menuItems[i][0] = "Effects On";
		
		try {
		    dm_ext_changeItem(0,6,1, menuItems[i]);
		} catch (e) {}
	    }
	}
    }
    else if ( option == 6 )
	toggleMenu();

    else if ( option == 7 )
	hstWin.show();

    else if ( option == 8 )
	document.location.href = 
	    "mailto:karmgard.1@nd.edu?subject=Bug the OGRE";

    else if ( option == 12 || option == 13 ) {
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

	ctlWin.reTheme(xmlThemeFile,'stdWin');
	cutWin.reTheme(xmlThemeFile,'archWin');
	ctlHlp.reTheme(xmlThemeFile,'hlpWin');
	hlpWin.reTheme(xmlThemeFile,'hlpWin');

	ctlWin.bind('stdHelp', ctlHlp);
	cutWin.bind('archHlp', hlpWin);

	// And adjust the sizes, shadows, etc...
	cutWin.setMinTop(35);
	ctlWin.setMinTop(25);
	ctlHlp.setMinTop(35);
	hlpWin.setMinTop(35);
	hstWin.setMinTop(35);
    }

    // For advanced users... push the header/footer to the background
    if ( userLevel > 1 ) {
	document.getElementById('header').style.zIndex = -1;
	document.getElementById('footer').style.zIndex = -1;
    }

   return true;
}

function clearCuts() {
    sendState("selection", 'blah', true, true);
    return true;
}

function replaceCuts() {
    if ( newCut )
	sendState("replaceCut", escapeCuts(newCut), true, true);
    else
	alert("No selection defined!");
    return true;
}

function appendCuts() {
    if ( newCut )
	sendState("appendCut", escapeCuts(newCut), false, true);
    else
	alert("No selection defined!");
    return true;
}

function escapeCuts(submitCuts) {
    submitCuts = submitCuts.replace(/\+/g, "%2B");
    submitCuts = submitCuts.replace(/\*/g, "%2A");
    submitCuts = submitCuts.replace(/\//g, "%2F");
    submitCuts = submitCuts.replace(/\)/g, "%29");
    submitCuts = submitCuts.replace(/\(/g, "%28");
    submitCuts = submitCuts.replace(/\:/g, "%3A");
    submitCuts = submitCuts.replace(/\|/g, "%7C");
    submitCuts = submitCuts.replace(/\>/g, "%3E");
    submitCuts = submitCuts.replace(/\</g, "%3C");
    submitCuts = submitCuts.replace(/\&/g, "%26");
    return submitCuts;
}