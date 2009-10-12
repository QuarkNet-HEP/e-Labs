function fader(turnOn, turnOff, fadeLimit, opacity) {

     // Set defaults for the arguments...
    var opacity   = (opacity   == null) ? 0.0 : opacity;
    var fadeLimit = (fadeLimit == null) ? 1.0 : fadeLimit;

    (turnOn) ? turnOn.style.display = "block" : 0;

    // Fade the current windowlet out, and the new one in
    (turnOn  != null && turnOn.id)  ? setAlpha(turnOn,  opacity)  : 0;
    if (turnOff && turnOff.length > 0) {
	for ( var i=0; i<turnOff.length; i++ )
	    setAlpha(turnOff[i], 1 - opacity);
    }

    if ( opacity < fadeLimit ) {
	opacity += 0.01;
	setTimeout(fader, 10, turnOn, turnOff, fadeLimit, opacity);
    } else {
	if ( turnOff && fadeLimit == 1 ) {
	    for ( var i=0; i<turnOff.length; i++ ) {
		turnOff[i].style.display = "none";
		turnOff[i].style.opacity = 1.0;
	    }
	}
	opacity = 0;
	turnOn = null;
	turnOff = null;
    }
 
    return true;
}

function setAlpha(which, alpha) {
    if ( !which )
	return false;

    (alpha < 0) ? alpha = 0 : 0;
    (alpha > 1) ? alpha = 1 : 0;

    if ( browser.isIE ) {
	which.style.zoom = 1;
	which.style.filter = 'alpha(opacity='+100*alpha+')';
    } else
	which.style.opacity = alpha;

    return true;
}

$(function() {
	// install flowplayer into flowplayer container
	var player = //$f("player", "graphics/flowplayer-3.0.7.swf");
	    flowplayer("player", "graphics/flowplayer-3.0.7.swf",  {

		    // default configuration for a clip 
		    clip: conf.defaults, 
 
		    // setup controlbar to use our "gray" skin 
		    plugins: {
			controls: conf.skins.gray
		    }
		});

	// setup button action. it will fire our overlay 
	$("button[rel]").overlay({

		// when overlay is opened, load our player
		onLoad: function() {

		    // If the slice demo is up... there's a nasty 
		    // layering conflict, so just shut it off
		    document.getElementById('demo').style.display = "none";

		    //var turnOff = new Array();
		    //turnOff[0] = document.getElementById("wrapper");
		    //fader(null, turnOff, 0.05);
		    // fade the background out
		    //setAlpha(document.getElementById('wrapper'), 0.25);

		    player.load();
		},

		// when overlay is closed, unload our player
		onClose: function() {
		    player.unload();
		    //fader(document.getElementById("wrapper"), null, 1, 0.25);
		}
	    });
    });
