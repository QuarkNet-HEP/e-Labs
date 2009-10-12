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

function getBaseURLPath () {

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

    // Process this as a synchronus request since we need to 
    // deal with the result before continuing
    var request = "asp/getBaseXMLURL.asp";
    xmlHttp.open("GET",request,false);
    xmlHttp.send(null);

    var xmlURL = xmlHttp.responseText;
        
    // Now that we have the path to the XML file... get it and read it in
    xmlHttp.open("GET",xmlURL,false);
    xmlHttp.send(null);
    var xml = xmlHttp.responseXML;

    var nodes = xml.getElementsByTagName("parameter");
    var url = new String();
    for ( i=0; i<nodes.length; i++ ) {
	if ( nodes[i].getAttribute('name') == "urlPath" )
            url = nodes[i].getAttribute('value');
    }
    return url;
}

var baseURL      = getBaseURLPath ();
var sessionID    = null;
var showToolTips = true;
var dmWorkPath   = baseURL+"/javascript/menu/";
var useDynMenu   = false;

// Objects that will get bound into jsWindowlets
var introWin = new Object();
var dataHlp  = new Object();
var variHlp  = new Object();
var archHlp  = new Object();
var demoHlp  = new Object();
var crdtWin  = new Object();
var dataWin  = new Object();
var variWin  = new Object();
var archWin  = new Object();
var prevWin  = new Object();
var demoWin  = new Object();

include(baseURL+"/javascript/cookies.js");
include(baseURL+"/javascript/utilities.js");
include(baseURL+"/javascript/procForm.js");
include(baseURL+"/javascript/drag_drop.js");

include(baseURL+"/javascript/jsWindowlet.js");
include(baseURL+"/javascript/triggers-include.js");
include(baseURL+"/javascript/variable-include.js");
include(baseURL+"/javascript/archive-include.js");
include(baseURL+"/javascript/previous-include.js");

if ( useDynMenu )
    include(baseURL+"/javascript/menu/dmenu.js");
