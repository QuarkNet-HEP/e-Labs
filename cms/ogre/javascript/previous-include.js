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

function showCompletedCanvas(which) {
    var img = new Object();

    img = document.body.appendChild(document.createElement('img'));

    // set the properties of the image to show
    img.id = "exp_"+which.id;
    img.src = which.src;

    img.style.position = "relative";
    img.style.top = "-8px";
    img.style.left= "-1px";
    img.style.width = "640px";

    img.onmousedown = function(event) {restoreArchive(event,which.id);}

    if ( !canvas ) {
	var canvas   = new Object();
	var canvasMD = new Object();

	try {
	    canvas   = new jsWindowlet(xmlThemeFile);
	    canvasMD = new jsWindowlet(xmlThemeFile);
	} catch (e) { alert(e); }
    }

    canvas.make(img, 'archWin', 'Study '+which.id);

    var newMetaData = document.createElement('DIV');
    newMetaData.id = "md_"+which.id;
    newMetaData.innerHTML = "Put in any metadata for the study here";
    canvasMD.make(newMetaData, 'hlpWin','MetaData for Study '+which.id);

    canvas.bind('archHelp', canvasMD);
    canvas.show();
    return;
}

include("/~ogre/javascript/cookies.js");
include("/~ogre/javascript/utilities.js");
include("/~ogre/javascript/procForm.js");
