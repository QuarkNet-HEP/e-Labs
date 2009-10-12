var restrictDrop = true; // Used in drag_drop.js to restrict allowed targets

var tip1   = 'These are the plots you can make';
var tip2   = 'Drag plots here';
var tip3   = 'Drag onto a plot to set its color';
var tip4   = 'Use these to make Log-Log or Semi-Log plots';
var tip5   = 'Use these to set the output graphics type';
var tip6   = 'How big do you want it?';
var tip7_1 = 'Apply previously saved cuts to new plots';
var tip7_2 = 'Get the numbers as well as the pictures (not working yet)';
var tip8   = 'Drag options here';

function showvarsToolTip(text) {
    try {
	if (showToolTips)
	    Tip(text);
    } catch (e) {}

    return false;
}

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

include(baseURL+"/javascript/cookies.js");
include(baseURL+"/javascript/drag_drop.js");
