var browser = new Object();
var dragObj = new Object();
dragObj.zIndex = 10;
dragObj.start = true;

browser.isIE = document.all?true:false;
browser.isNS = !browser.isIE;

var showEffects  = (showEffects  != null) ? showEffects  : true;
var singleWindow = (singleWindow != null) ? singleWindow : false;

var windows = new Array( "intro", "datahelp", "varhelp", "archhelp", "cuthelp",
			 "moveData", "moveVars","moveArch", "movePrev", "hist", 
			 "cutscreen","pExpander", "aExpander", "demo", "credits");

function dragStart(event, id) {
    // IE doesn't always pass the event to the bound function... stupid windows
    event = (!event) ? window.event : event;

    // Only accept button 1 presses
    var button = event.button || event.which;
    if ( button != 1 )
	return false;

    // Inhibit shift-click since we'll need that elsewhere
    if ( event.shiftKey )
	return false;

    var el;
    var x = y = 0;
    // If an element id was given, find it. Otherwise use 
    // the element being clicked on.
    if (id) {
	dragObj.elNode = document.getElementById(id);
	if ( id != "demo" )
	    if ( showEffects ) {
		(browser.isIE) ? 
		    dragObj.elNode.style.filter='alpha(opacity=50)' : 
		    dragObj.elNode.style.opacity = 0.5;
	    }
    } else {
	if (browser.isIE || browser.isOP)
	    dragObj.elNode = window.event.srcElement;
	if (browser.isNS || browser.isWK)
	    dragObj.elNode = event.target;

	// If this is a text node, use its parent element.
	if (dragObj.elNode.nodeType == 3)
	    dragObj.elNode = dragObj.elNode.parentNode;
    }

    // Save the current stacking information
    dragObj.Z = isNaN(dragObj.elNode.style.zIndex) ? 0 : dragObj.elNode.style.zIndex;
    

    // Get cursor position with respect to the page.
    x = event.clientX + window.scrollX || 
	window.event.clientX + document.documentElement.scrollLeft + document.body.scrollLeft;
    y = event.clientY + window.scrollY ||
	window.event.clientY + document.documentElement.scrollTop + document.body.scrollTop;

    dragObj.start = false;

    // Save starting positions of cursor and element.
    dragObj.cursorStartX = x;
    dragObj.cursorStartY = y;
    dragObj.elStartLeft  = parseInt(dragObj.elNode.style.left, 10);
    dragObj.elStartTop   = parseInt(dragObj.elNode.style.top,  10);

    // If we don't already know where this thing is... find out
    if ( isNaN(dragObj.elStartLeft) || isNaN(dragObj.elNodeStartTop) ) {
	var curleft = curtop = -1;
	var obj = dragObj.elNode;
	if (obj.offsetParent) {
	    do {
		curleft += obj.offsetLeft;
		curtop  += obj.offsetTop;
	    } while (obj = obj.offsetParent);
	}
	dragObj.elStartLeft = curleft;
	dragObj.elStartTop  = curtop;
    }

    // If we *still* don't know where it is... just set it to (0,0)
    if (isNaN(dragObj.elStartLeft)) dragObj.elStartLeft = 0;
    if (isNaN(dragObj.elStartTop))  dragObj.elStartTop  = 0;

    // Update element's z-index.
    dragObj.elNode.style.zIndex = ++dragObj.zIndex;

    // Capture mousemove and mouseup events on the page.
    if (browser.isIE) {
	document.attachEvent("onmousemove", dragGo);
	document.attachEvent("onmouseup",   dragStop);
	window.event.cancelBubble = true;
	window.event.returnValue = false;
    } else {
	try {
	    document.addEventListener("mousemove", dragGo,   true);
	    document.addEventListener("mouseup",   dragStop, true);
	    event.preventDefault();
	} catch (e) { alert(e); }
    }

    // Set the cursor to move to indicate that we be mobile
    dragObj.cursor = dragObj.elNode.style.cursor;
    dragObj.elNode.style.cursor = "move";

    return;
}

function dragGo(event) {

    var x = y = 0;

    // Get cursor position with respect to the page.
    x = event.clientX + window.scrollX || 
	window.event.clientX + document.documentElement.scrollLeft + document.body.scrollLeft;
    y = event.clientY + window.scrollY ||
	window.event.clientY + document.documentElement.scrollTop + document.body.scrollTop;

    // Move drag element by the same amount the cursor has moved.
    dragObj.elNode.style.left =
	(dragObj.elStartLeft + x - dragObj.cursorStartX) + "px";
    dragObj.elNode.style.top  =
	(dragObj.elStartTop  + y - dragObj.cursorStartY) + "px";

    if (browser.isIE) {
	window.event.cancelBubble = true;
	window.event.returnValue = false;
    } else
	event.preventDefault();

    return;
}

function dragStop(event) {

    // Stop capturing mousemove and mouseup events.
    if (browser.isIE) {
	document.detachEvent("onmousemove", dragGo);
	document.detachEvent("onmouseup",   dragStop);
    }
    if (browser.isNS) {
	document.removeEventListener("mousemove", dragGo,   true);
	document.removeEventListener("mouseup",   dragStop, true);
    }

    if ( showEffects) {
	(browser.isIE) ? 
	    dragObj.elNode.style.filter = 'alpha(opacity = 100)' :
	    dragObj.elNode.style.opacity = 1.0;
    }

    // Restore the objects original style (saved in dragStart)
    dragObj.elNode.style.zIndex = dragObj.Z;
    dragObj.zIndex = 10;
    dragObj.elNode.style.cursor = dragObj.cursor;
    /*
    if ( !singleWindow )
	setStacking();
    */
    return;
}

function setStacking() {
    for ( var i=0; i<windows.length; i++ ) {
	var win = document.getElementById(windows[i]);
	if ( win != null ) {
	    if ( win.id == dragObj.elNode.id )
		win.style.zIndex = 6;
	    else
		win.style.zIndex = 3;
	}
    }
    return;
}