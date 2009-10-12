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
include(baseURL+"/javascript/utilities.js");
include(baseURL+"/javascript/drag.js");
include(baseURL+"/javascript/procForm.js");
