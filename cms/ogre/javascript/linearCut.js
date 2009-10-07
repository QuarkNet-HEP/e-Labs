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

var useDynMenu  = false;
var useDragDrop = true;

include("/~ogre/javascript/utilities.js");
include("/~ogre/javascript/submitForms.js");
include("/~ogre/javascript/cookies.js");

// Include Walter Zorns wonderful javascript graphics package
include("/~ogre/javascript/wz_jsgraphics.js");

// Include the script for the menu
if ( useDynMenu )
    include("/~ogre/javascript/menu/dmenu.js");

var dragDiv;
var xmin   = 0;
var xmax   = 0;
var startX = 0;
var width  = 0;
var height = 0;
var dragging = false;
var selection = new String();

// Constants for converting graph units to pixels 
var graphXmin;
var graphXmax;
var X0;
var Y0;
var mouseOffSet;
var pixel2X;
var pixel2Xk;
var units = new String();
var logx = false;

// Objects that will hold the windowlets...
var browser = new Object();
var cutWin = new Object();
var hlpWin = new Object();
var hstWin = new Object();

// Define the work path for the menu
var dmWorkPath   = "/~ogre/javascript/menu/";

/*-- Get the position of the cursor sanely for everyone --*/
function getMousePosition(e) {

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

var range = 0.0;

/*-- Convert pixel values to plot values --*/
function pixel2plot(pixel) {

    var a = 1;//0.993;
    var pos = 0.0;

    if ( logx )
	pos = eval(Math.pow(10,a*pixel2Xk + a*pixel2X*(pixel - X0)));
    else
	pos = eval(a*pixel2Xk + a*pixel2X*(pixel - X0));

    if ( range < 25 )
	return Math.round3(pos);
    else if ( range < 50 )
	return Math.round2(pos);
    else return Math.round(pos);
}

/*-- And backwards from plot to pixel --*/
function plot2pixel(plot) {

    var a = 1;//1.0067;
    plot = (logx && plot <= 0) ? 0.465 : plot;

    if ( logx )
	return Math.round( eval( X0 + (a*Math.log10(plot) - pixel2Xk)/(pixel2X) ) );
    else
	return Math.round( eval( X0 + Math.round( (a*plot - pixel2Xk)/pixel2X) ) );
    
}

function mouseTrap (event) {
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
	    xmin=xmax=startX=plot2pixel(graphXmin) - 10;
	}
    } else {
	jg.clear();
	xmin=xmax=startX=plot2pixel(graphXmin) - 10;
    }

    selection = "";
    return;
}

function isActive(x, y) {
    try {
	if ( y > Ymin && y < Ymax && pixel2plot(x) > graphXmin && pixel2plot(x) < graphXmax)
	    return true;
	else
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

    startX = xmin = xmax = getMousePosition(event).x - mouseOffSet;

    var plotX = pixel2plot(xmin);
    if ( plotX > graphXmax || plotX < graphXmin ) {
	dragging = false;
	return false;
    }

    dragging = true;
    jg.setColor('#ff00ff');

    return true;
}

function stopDrag(event) {

    var button;
    if (event)
	button = event.button || event.which;
    else
	button = 1;

    if ( useDragDrop && button != 1 )
	return;

    dragging = false;

    // Show the user what (s)he's done....
    selection = "Selected ("+pixel2plot(xmin)+" "+units+", "+
	pixel2plot(xmax-mouseOffSet)+" "+units+")";

    // And record the cuts...
    document.forms["recut"].cutMin.value = pixel2plot(xmin);
    document.forms["recut"].cutMax.value = pixel2plot(xmax-mouseOffSet);

    if ( xmin != xmax-mouseOffSet ) {
	var lo;
	var hi;
	var temp = cuts.split('&&');
	for ( var i=0; i<temp.length; i++ ) {
	    if ( temp[i].indexOf('>') > -1 )   // Min cut
		lo = temp[i].split('>')[1];
	    else if ( temp[i].indexOf('<') )   // Max cut
		hi = temp[i].split('<')[1];
	}

	var newCut = cuts.replace(lo, pixel2plot(xmin));
	newCut = newCut.replace(hi,pixel2plot(xmax-mouseOffSet));
	//setCorokie(corokie,newCut);
	
	sendState("selection", newCut.replace(/&/g,"%26"), true);
    }

    return;
}

function select(event) {

    var coords = {x:0, y:0};
    coords = getMousePosition(event);
    var x = eval(coords.x - mouseOffSet);
    var y = coords.y;

    var temp = parseInt(coords.x) - parseInt(mouseOffSet);

    var selOpacity = 0.25;
    var rejOpacity = 0.20;

    if ( !isActive(x,y) )
	return false;

    jg.clear();

    if ( dragging ) {

	/*-- put the current selection on the status bar --*/
	selection = '(' + pixel2plot( (startX < x) ? startX : x) + ' ' + units + ', ' +
	    pixel2plot( (startX < x) ? x : startX) + ' ' + units + ')';

	/*-- Highlight the selected region --*/
	jg.setColor('#ffff00');
	jg.fillRect( (startX<x)?startX:x, Ymin, Math.abs(startX-x), Ymax-Ymin, selOpacity);

	/*-- And fade out the rest of the graph --*/
	jg.setColor('#aaaaaa');

	if ( startX < x ) {
	    jg.fillRect(plot2pixel(graphXmin), Ymin, 
			startX - plot2pixel(graphXmin), Ymax-Ymin, rejOpacity);
	    jg.fillRect(x, Ymin, plot2pixel(graphXmax) - x, Ymax - Ymin, rejOpacity);
	} else {
	    jg.fillRect(plot2pixel(graphXmin), Ymin, 
			x - plot2pixel(graphXmin), Ymax-Ymin, rejOpacity);
	    jg.fillRect(startX, Ymin, plot2pixel(graphXmax) - startX, Ymax-Ymin, rejOpacity);
	}
    } else if ( xmin > plot2pixel( graphXmin) ) {
	jg.setColor('#ffff00');
	jg.fillRect( xmin, Ymin, xmax-xmin-mouseOffSet, Ymax-Ymin, selOpacity);

	jg.setColor('#aaaaaa');
	jg.fillRect(plot2pixel(graphXmin), Ymin, xmin - plot2pixel(graphXmin), Ymax-Ymin, rejOpacity);
	jg.fillRect(xmax-mouseOffSet, Ymin, plot2pixel(graphXmax)-xmax+mouseOffSet, Ymax-Ymin, rejOpacity);
    }

    if ( useDragDrop ) {
	/*-- put up a line by the mouse to guide the selection --*/
	jg.setColor('#ff0000');
	jg.drawLine(x,Ymax,x,Ymin);

	var position = pixel2plot(x);
	var plotRange = graphXmax - graphXmin;
	if ( plotRange < 25 )
	    position = Math.round3(position);
	else if ( plotRange < 50 )
	    position = Math.round2(position);
	else
	    position = Math.round(position);

	jg.drawString(position+" "+units, x+15,y-50);
    }

    // Put up the current selection
    jg.setColor('#ff0000');
    jg.drawString(selection,width/2.5,Ymin-18);

    jg.paint();

    /*-- And save the current selection --*/
    if ( dragging ) {
	xmin = (startX < x) ? startX : x;
	xmax = (startX < x) ? x : startX;
	xmax += mouseOffSet;

	range = pixel2plot(xmax) - pixel2plot(xmin);
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
    var x = eval(coords.x);// - mouseOffSet);
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
		xmin=xmax=startX=plot2pixel(graphXmin) - 10;
	    }
	} else {
	    jg.clear();
	    xmin=xmax=startX=plot2pixel(graphXmin) - 10;
	}

	selection = "";
	click1 = click2 = false;
    }

    return true;
}

function pageLoad() {
    //retrieve the session ID if it hasn't been passed along,
    //var sessionID = getCookie("sessionID");
    //load the coodinates
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
    // Request coordinates from the server
    var request = "/~ogre/asp/Burrito.asp?sessid=" + sessionID + "&iotype=retrieve";
    // Send the Ajax request to the server
    xmlHttp.open("GET",request,false);
    xmlHttp.send(null);
    message = xmlHttp.responseText;
    if (message == ":::::::::::::"){
	request = "/~ogre/asp/Burrito.asp?sessid=" + sessionID +"&iotype=create";
	xmlHttp.open("GET",request,false);
	xmlHttp.send(null);
	message = xmlHttp.responseText;
    }
    //alert(message);
    var Xcoords = new Array(3);
    var Ycoords = new Array(3);
    mesParsed = message.split(":",14);
    for (i = 0; i < 3; i++){
	Xcoords[i] = parseInt(mesParsed[7 + 2*i]);
	Ycoords[i] = parseInt(mesParsed[7 + 2*i + 1]);
	}

    var xmlTheme = (xmlTheme) ? xmlTheme : "/~ogre/graphics/themes/ogre/ogre-theme.xml";

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
    cutWin.setMinTop(5);

    // Make a windowlet for the control buttons
    ctlWin = new jsWindowlet(xmlTheme);
    ctlWin.make(document.getElementById('controls'), 'stdWin', 
		'OGRE Controls');
    ctlWin.setMinTop(5);
    ctlWin.show();

    ctlHlp = new jsWindowlet(xmlTheme);
    ctlHlp.make(document.getElementById('ctlHlp'), 'hlpWin', 
		'Using OGRE Controls');
    ctlHlp.setMinTop(5);

    ctlWin.bind('stdHelp', ctlHlp);

    // And bind some help text to it
    hlpWin = new jsWindowlet(xmlTheme);
    hlpWin.make(document.getElementById('cuthelp'), 'hlpWin', "Refining Data Selection");
    hlpWin.setMinTop(5);

    cutWin.bind('archHelp', hlpWin);
    cutWin.show();

   // Offset of the graph on the page
    X0    = 11;
    Y0    = 0;
    mouseOffSet = 32;

    // Get the scale factors
    try {
	var w = document.hiddenInput.width.value;
	var scaleX = eval(w/width);
    } catch (e) {
	var scaleX = 1;
    }

    // Xmin/Xmax of the graph in pixels
    graphXmin = document.hiddenInput.xmin.value;
    graphXmax = document.hiddenInput.xmax.value;

    // Ymin/Ymax of the graph in pixels
    Ymin = Y0 + Math.round(eval(0.105*height)) - 2;
    Ymax = Y0 + Math.round(eval(0.892*height)) + 3;

    // Pixel-to-X conversion parameters
    pixel2X  = eval(scaleX*document.hiddenInput.X2px.value);
    pixel2Xk = document.hiddenInput.Xcst.value;

    var hist = new Object();
    try {
	hist = document.getElementById("hist");
	hist.style.opacity = 1.0;
    } catch (e) {;}

    if ( cuts )
	//setCorokie(corokie,cuts);
	sendState("selection", cuts.replace(/&/g,"%26"), true);

    // MSIE v6 and prior doesn't respect the "fixed" positioning directive
    // and it drops back to static... :O so if we're dealing with an old
    // IE version force the fixed elements to absolute positioning
    if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){ //test for MSIE x.x;
	var ieversion=new Number(RegExp.$1); // capture the version number
	if ( ieversion <= 6 ) {

	    try {
		document.getElementById('background').style.position = "absolute";
	    } catch (e) {}
	    try {
		document.getElementById('header').style.position = "absolute";
	    } catch (e) {}
	    try {
		document.getElementById('footer').style.position = "absolute";
	    } catch (e) {}
	    try {
		document.getElementById('recut').style.position = "absolute";
	    } catch (e) {}
	    try {
		document.getElementById('myNotice').style.position = "absolute";
	    } catch (e) {}
	}
    }
    if ( ieversion < 6 ) {
	try {
	    document.getElementById('header').style.width = document.body.clientWidth - 20;
	} catch (e) {}
    }

    // load the history page into a div
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
	    hstWin.setMinTop(5);

	    if ( historyVisible )
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
    var request = '/~ogre/asp/getHistory.asp?id='+document.forms['recut'].directory.value;

    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

    // Grab the plot units from the page...
    units = document.hiddenInput.units.value;

    // And see if this is a logX plot...
    logx = (document.hiddenInput.logX.value == 0) ? false : true;

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
    range = graphXmax - graphXmin;

    return;
}

function callMenu(option) {
    if ( option == 0 )
	return false;
    else if ( option == 1 )
	submitForm(document.forms['recut']);
    //else if ( option == 2 )
	//delCorokie('selection', "/~ogre/");
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

    else if ( option == 9 || option == 10 ) {
	flushTheme();

	if ( option == 9 )
	    xmlThemeFile = '/~ogre/graphics/themes/ogre/ogre-theme.xml';
	else if ( option == 10 )
	    xmlThemeFile = '/~ogre/graphics/themes/simple/ogre-simple.xml';
	else
	    return false;

	ctlWin.reTheme(xmlThemeFile,'stdWin');
	cutWin.reTheme(xmlThemeFile,'archWin');
	ctlHlp.reTheme(xmlThemeFile,'hlpWin');
	cutHlp.reTheme(xmlThemeFile,'hlpWin');

	ctlWin.bind('stdHelp', ctlHlp);
	cutWin.bind('archHlp', cutHlp);
    }

   return true;
}
