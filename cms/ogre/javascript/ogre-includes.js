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

var showToolTips = true;
var dmWorkPath   = "./javascript/menu/";
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

include("/~ogre/javascript/cookies.js");
include("/~ogre/javascript/utilities.js");
include("/~ogre/javascript/procForm.js");
include("/~ogre/javascript/drag_drop.js");

include("/~ogre/javascript/jsWindowlet.js");
include("/~ogre/javascript/triggers-include.js");
include("/~ogre/javascript/variable-include.js");
include("/~ogre/javascript/archive-include.js");
include("/~ogre/javascript/previous-include.js");

if ( useDynMenu )
    include("/~ogre/javascript/menu/dmenu.js");
