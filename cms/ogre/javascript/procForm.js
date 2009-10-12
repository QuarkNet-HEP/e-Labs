// ID the browser... meaning ID Internet Explorer so
// we can account for M$ idiocy... again... fuckers.
var browser = new Object();
browser.isIE = (/MSIE (\d+\.\d+);/.test(navigator.userAgent));
browser.ieVer = (browser.isIE) ? new Number(RegExp.$1) : -1;

/////////////////////////////////////////////////////////////////////////
//
// Used below in rootColor... convert firefox rgb() string to 
// a proper consistant (goddamned programmers!) format. Idiot programmers
//
function RGBtoHex(RGB) {return toHex(RGB[0])+toHex(RGB[1])+toHex(RGB[2])}
function toHex(N) {
 if (N==null) return "00";
 N=parseInt(N); if (N==0 || isNaN(N)) return "00";
 N=Math.max(0,N); N=Math.min(N,255); N=Math.round(N);
 return "0123456789ABCDEF".charAt((N-N%16)/16)
      + "0123456789ABCDEF".charAt(N%16);
}

// Take a root color code and covert it to hex
function root2hex(color) {
    // Root color codes: None   => 0, Black => 1, Red    => 2, 
    //                   Green  => 3, Blue  => 4, Yellow => 5, 
    //                   Purple => 6, White => 10

    switch (color) {
    case 2:
	return '#FF0000';  // Red
	break;
    case 3:
	return '#00FF00'; // Green
	break;
    case 4:
	return '#0000FF'; // Blue
	break;
    case 1:
	return '#000000'; // Black
	break;
    case 10:
	return '#FFFFFF'; // White
	break;
    case 5:
	return '#FFFF00'; // Yellow
	break;
    case 6:
	return '#FF00FF'; // Purple
	break;
    default:              // return an empty color code
	return '';
    }

    return '';
}

//
// Funtion to take CSS/HTML color values and convert to ROOT color pallette
//
function rootColor( elementColor ) {
    var color;
    if ( elementColor.substring(0,3) == 'rgb') {
	color = elementColor.substring(4,elementColor.length-1);
	var rgb = color.split(',');
	color = '#' + RGBtoHex(rgb);   
    } else {
	color = elementColor.toUpperCase();
    }

    // Root color codes: None   => 0, Black => 1, Red    => 2, 
    //                   Green  => 3, Blue  => 4, Yellow => 5, 
    //                   Purple => 6, White => 10

    switch (color) {
    case '#FF0000':  // Red
	return 2;
	break;
    case '#00FF00': // Green
	return 3;
	break;
    case '#0000FF': // Blue
	return 4;
	break;
    case '#000000': // Black
	return 1;
	break;
    case '#FFFFFF': // White
	return 10;
	break;
    case '#FFFF00': // Yellow
	return 5;
	break;
    case '#FF00FF': // Purple
	return 6;
	break;
    default:
	return 0;
    }

    return 0;
}

function submitForm(thisForm, sID) {


    try {
	thisForm.sessionID.value = sID;
    } catch (e) { return false;}

    if ( !thisForm.sessionID.value ) {
	return false;
    }

    thisForm.submit();
    return true;
}

function restoreMe(triggers, holder, plots, color, opts, sessionID) {

    // First.... restore the session so we've got the user ID
    var request = baseURL + "/asp/Burrito.asp?sessid="+sessionID+"&iotype=getUser";
    var xmlHttp=new XMLHttpRequest();
    xmlHttp.open("GET",request,false);
    xmlHttp.send(null);
    var userName = xmlHttp.responseText;

    // Update the session ID cookie if they're allowed
    if ( testCookies() )
	setCookie('sessionID', sessionID);


    // Array of id's for the logic boxes... 
    var trigHolder = ['DragContainer11','DragContainer12','DragContainer13',
		      'DragContainer15','DragContainer16','DragContainer17'];

    // Grab a reference to the holding pen for triggers
    var trigs = document.getElementById('DragContainer14');

    // First... clear out the logic boxes
    for ( var i=0; i<trigHolder.length; i++ ) {
	var dEle = document.getElementById(trigHolder[i]);
	if ( dEle ) {
	    var dChild = dEle.firstChild;
	    while (dChild) {
		var next = dChild.nextSibling;
		trigs.appendChild(dChild);
		dChild = next;
	    }
	}
    }

    // Flush the dragHelper (defined in drag_drop.js) in case there's anything in it
    for(var i=0; i<dragHelper.childNodes.length; i++) 
	dragHelper.removeChild(dragHelper.childNodes[i]);

    // Then, put the old triggers into their respective boxes
    for ( var i=0; i<triggers.length; i++ ) {
	var container = document.getElementById(holder[i]);
	var child = document.getElementById(triggers[i]);

	container.appendChild(child);
    }

    // Update the data selection to reflect the current conditions
    updateLogic();

    // Rebuild the plot box...
    var plotBox  = document.getElementById('DragContainer2');
    var plotHome = document.getElementById('DragContainer1');
    
    // First clear it out of anything that might be there
    dChild = plotBox.firstChild;
    while ( dChild ) {
	var next = dChild.nextSibling;
	plotHome.appendChild(dChild);
	dChild.style.backgroundColor = "";
	dChild = next;
    }

    // Then loop over the saved plot state and restore it
    for ( var i=0; i<plots.length; i++ ) {
	var child = document.getElementById(plots[i]);
	plotBox.appendChild(child);
	child.style.backgroundColor = color[i];
    }

    // Clear out the options box of whatever's in there
    var optBox = document.getElementById('DragContainer8');
    dChild = optBox.firstChild;
    while ( dChild ) {
	next = dChild.nextSibling;
	dChild.origParentNode.appendChild(dChild);
	dChild = next;
    }

    // And restore the original options
    for ( var i=0; i<opts.length; i++ ) {
	// These options are on/off switches, so we can treat them simply
	if ( opts[i] == 'logy' || opts[i] == 'logx' || opts[i] == 'gcut' || opts[i] == 'savedata' ) {
	    var child = document.getElementById(opts[i]);
	    optBox.appendChild(child);

	// Size & type aren't unique ids... so we've got to loop and find it by value
	} else if ( opts[i] == 'type' ) {
	    var types = document.getElementsByName("type");
	    for ( var j=0; j<types.length; j++ ) {
		var value = types[j].getAttribute("value");
		if ( value == opts[eval(i+1)] ) {
		    optBox.appendChild(types[j]);
		    break;
		}
	    }
	} else if ( opts[i] == 'size' ) {
	    var sizes = document.getElementsByName("size");
	    for ( var j=0; j<sizes.length; j++ ) {
		var value = sizes[j].getAttribute("value");
		if ( value == opts[i+1] ) {
		    optBox.appendChild(sizes[j]);
		    break;
		}
	    }
	}
    }

    // Since we're restoring a previous session... 
    // close the intro & open the data/vars windowlets
    introWin.hide();
    dataWin.show();
    variWin.show();

    return;
}

function submitGetData(thisForm) {

    var ele;

    var trigHolder = ['DragContainer11','DragContainer12','DragContainer13',
		      'DragContainer15','DragContainer16','DragContainer17'];

    var plotHolder = 'DragContainer2';
    var optsHolder = 'DragContainer8';

    var triggers = new Array();
    var holder   = new Array();
    var plots    = new Array();
    var color    = new Array();
    var opts     = new Array();

    for (var i=0; i<triggers.length; i++ ) {
	triggers[i] = null;
	holder[i] = null;
    }
    triggers.length = holder.length = 0;

    for ( var i=0; i<trigHolder.length; i++ ) {

	var dEle = document.getElementById(trigHolder[i]);
	if ( dEle ) {
	    var dChild = dEle.firstChild;
	    while (dChild) {
		triggers[triggers.length++] = dChild.id;
		holder[holder.length++]     = trigHolder[i];
		dChild = dChild.nextSibling;
	    }
	}
    }

    //
    // Get some "must be there" data options
    // !document.getElementById("select1").length <== Old version... selection by run number
    if ( !triggers.length ) {
	alert("No data... :( \nPlease give me something to do... please?\nPretty please?");
	return false;
    }

    //
    // Drop into the plots form and get the info on the graphics we'll be constructing
    //
    // DragContainer2 contains the variables, colors, and names to plot
    var vEle = document.getElementById('DragContainer2');
    var child = vEle.firstChild;
    var numLeaves = 0;

    if ( !child ) {     // Nothing to plot :(
 	alert("No plots selected! You didn't even try!\nPetulantly refusing to continue this charade.");
	return false;
    }

    for ( var i=0; i<plots.length; i++ ) {
	plots[i] = null;
	color[i] = null;
    }
    plots.length = 0;
    color.length = 0;

    while ( child ) {
	ele = null;

	if ( child.id.substring(0,4) == "leaf" || child.id.substring(0,7) == "formula" ) {
	    numLeaves++;

	    ele = document.createElement('input');
	    ele.type  = 'hidden';
	    ele.name  = (child.id.substring(0,4)=="leaf") ? "leaf" : "formula";
	    
	    ele.value = (child.id.substring(0,4)=="leaf") ?
		parseInt(child.id.substring(4,child.id.length)) :
		parseInt(child.id.substring(7,child.id.length));

	    thisForm.appendChild(ele);

	    ele = document.createElement('input');
	    ele.type  = 'hidden';
	    ele.name  = "root_leaf";
	    ele.value = child.getAttribute('name');
	    thisForm.appendChild(ele);

	    ele = document.createElement('input');
	    ele.type  = 'hidden';
	    ele.name  = 'color';
	    ele.value = rootColor(child.style.backgroundColor);
	    thisForm.appendChild(ele);

	    plots[plots.length++] = child.id;
	    color[color.length++] = child.style.backgroundColor;
	}
	child = child.nextSibling;
    }

    if ( numLeaves == 0 ) {     // Nothing to plot :(
 	alert("Nothing to plot. :O\nBailing out now while there's still time.");
	return false;
 
    } else if ( numLeaves > 1 ) { // send the all-on-one signal to stack multiple plots
	ele = document.createElement('input');
	ele.type  = 'hidden';
	ele.name  = 'allonone';
	ele.value = 1;
	thisForm.appendChild(ele);
    }

    // DragContainer8 contains the options... size, logX/logY, etc
    vEle = document.getElementById('DragContainer8');
    child = vEle.firstChild;
    
    for ( var i=0; i<opts.length; i++ )
	opts[i] = null;
    opts.length = 0;

    while ( child ) {
	ele = null;

	if ( child.id == 'logy' || child.id == 'logx' ) {
	    ele = document.createElement('input');
	    ele.type  = 'hidden';
	    ele.name  = child.id;
	    ele.value = 1;
	    ele.id    = child.id;
	    thisForm.appendChild(ele);
	    opts[opts.length++] = child.id;

	} else if ( child.id == 'type' ) {

	    ele = document.createElement('input');
	    ele.type  = 'hidden';
	    ele.name  = child.id;
	    ele.id    = child.id;
	    ele.value = child.getAttribute("value");
	    thisForm.appendChild(ele);

	    opts[opts.length++] = child.id;
	    opts[opts.length++] = child.getAttribute("value");

	} else if ( child.id == 'size' ) {

	    var temp = child.getAttribute("value").split('x');
	    var width = temp[0];
	    var height = temp[1];

	    ele = document.createElement('input');
	    ele.type  = 'hidden';
	    ele.name  = 'gWidth';
	    ele.id    = 'gWidth';
	    ele.value = width;
	    thisForm.appendChild(ele);

	    ele = document.createElement('input');
	    ele.type  = 'hidden';
	    ele.name  = 'gHeight';
	    ele.id    = 'gHeight';
	    ele.value = height;
	    thisForm.appendChild(ele);

	    opts[opts.length++] = child.id;
	    opts[opts.length++] = child.getAttribute("value");

	} else if ( child.id == 'gcut' ) {

	    ele = document.createElement('input');
	    ele.type  = 'hidden';
	    ele.name  = 'mycuts';
	    ele.id    = 'mycuts';
	    //ele.value = getCookie('selection');
	    ele.value = selection;
	    //alert(ele.id+' '+ele.name+' '+ele.value);
	    //return true;

	    thisForm.appendChild(ele);

	    opts[opts.length++] = child.id;

	} else if ( child.id == 'savedata' ) {

	    ele = document.createElement('input');
	    ele.type  = 'hidden';
	    ele.name  = child.id;
	    ele.id    = child.id;
	    thisForm.appendChild(ele);

	    opts[opts.length++] = child.id;

	} else {
	    alert(child.getAttribute('id'));
	}
	child = child.nextSibling;
    }

    // Append the sessionID to the form
    if ( sessionID ) {
	ele = document.createElement('input');
	ele.type  = 'hidden';
	ele.name  = 'sID';
	ele.id    = 'sessID';
	ele.value = sessionID;
	thisForm.appendChild(ele);
    }

    // Append the page state to the form
    for ( var i=0; i<triggers.length; i++ ) {
	ele = document.createElement('input');
	ele.type = 'hidden';
	ele.name = 'triggers';
	ele.value = triggers[i];
	thisForm.appendChild(ele);

	ele = document.createElement('input');
	ele.type = 'hidden';
	ele.name = 'holders';
	ele.value = holder[i];
	thisForm.appendChild(ele);
    }

    //
    // Submit the form to the server for processing
    //
    thisForm.submit();

    //
    // Now that that's taken care of.... 
    // Clean up the form elements we just created
    // so that a return & resubmit won't send all
    // the values twice.
    ele = null;

    // flush the page state...
    ele = document.getElementById('sessID');
    if ( ele ) {
	try {
	    thisForm.removeChild(ele);
	} catch(e) {}
	ele = null;
    }

    var triggrs = new Array();
    var holders = new Array();

    triggrs = document.getElementsByName('triggers');
    holders = document.getElementsByName('holders');
    for ( var i=0; i<triggrs.length; i++ ) {
	try {
	    thisForm.removeChild(triggrs[i]);
	    thisForm.removeChild(holders[i]);
	} catch (e) {}
    }

    ele = document.getElementById('logx');
    if ( ele ) {
	try {
	    thisForm.removeChild(ele);
	} catch (e) {}
	ele = null;
    }
    ele = document.getElementById('logy');
    if ( ele ) {
	try {
	    thisForm.removeChild(ele);
	} catch (e) {}
	ele = null;
    }
    ele = document.getElementById('type');
    if ( ele ) {
	try {
	    thisForm.removeChild(ele);
	} catch(e) {}
	ele = null;
    }
    ele = document.getElementById('gWidth');
    if ( ele ) {
	try {
	    thisForm.removeChild(ele);
	} catch(e) {}
	ele = null;
    }
    ele = document.getElementById('gHeight');
    if ( ele ) {
	try {
	    thisForm.removeChild(ele);
	} catch(e) {}
	ele = null;
    }
    ele = document.getElementById('gcut');
    if ( ele ) {
	try {
	    thisForm.removeChild(ele);
	} catch(e) {}
	ele = null;
    }

    var leaves = new Array();
    var rootLv = new Array();
    var colors = new Array();

    leaves = document.getElementsByName("leaf");
    rootLv = document.getElementsByName("root_leaf");
    colors = document.getElementsByName("color");

    for ( var i=0; i<leaves.length; i++ ) {
	try {
	    thisForm.removeChild(leaves[i]);
	} catch(e) {}
	try {
	    thisForm.removeChild(rootLv[i]);
	} catch(e) {}
	try {
	    thisForm.removeChild(colors[i]);
	} catch(e) {}
    }

    return false;
}
