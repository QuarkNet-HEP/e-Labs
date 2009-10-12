var restrictDrop = false; // Used in drag_drop.js to restrict allowed targets

var dataTip  = 'Data which matches your criteria from the Select/Reject boxes to the left';
var logicTip = 'Text equivilent of the boxes in the Select/Reject regions above';
var anyofTip = 'accept data which matches any of the conditions in this box (logical OR)';
var allofTip = 'accept data which matches all of the conditions in this box (logical AND)';
var oneofTip = 'accept data which matches one or the other, but not both, of the conditions in this box (logical XOR)';

function showtrigToolTip(text, reject) {

    var reject = (reject) ? reject : false;
    if ( reject )
	text = text.replace("accept", "reject");

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
