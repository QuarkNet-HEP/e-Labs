
function testCookies() {

    var cookiesEnabled = false;
    if (typeof document.cookie == "string") {
	if (document.cookie.length == 0) {
	    document.cookie = "test";
	    cookieEnabled = (document.cookie == "test");
	    document.cookie = "";
	} else {
	    cookiesEnabled = true;
	}
    }
    return cookiesEnabled;
}

function setCookie( name, value ) { //, expires, path, domain, secure ) {
    // set time, it's in milliseconds
    var today = new Date();
    today.setTime( today.getTime() );

    var expires = 365;
    var location = window.location.toString();
    var temp = new Array();
    temp = location.split('/');

    var domain = temp[0] + '//' + temp[2] + "/";
    var path = "/" + temp[3] + "/";

    /*
      if the expires variable is set, make the correct 
      expires time, the current script below will set 
      it for x number of days, to make it for hours, 
      delete * 24, for minutes, delete * 60 * 24
    */
    if ( expires ) {
	expires = expires * 1000 * 60 * 60 * 24;
    }
    expires = new Date( today.getTime() + (expires) );
    expires = expires.toGMTString();
    var secure = null;

    if ( name == "userLevel" || name == "sessionID" ) {
	var cookieSet = name + "=" + value
	    + ( ( expires ) ? ";expires=" + expires : "" )
	    + ( ( path    ) ? ";path="    + path    : "" )
	    + ( ( secure  ) ? ";secure"             : "" );

	document.cookie = cookieSet;
	return;
    }

    /* Now that we've got the new values...check for existing cuts */
    var gCuts = getCookie('selection');

    if ( gCuts ) {
	// Found some... check and see if these are on the same quantities
	var oldCuts = gCuts.split('&&');
	var newCuts = value.split('&&');

	// For each of the new cuts... see if there's a corresponding old cut
	for ( var i=0; i<newCuts.length; i++ ) {

	    // Split up the new cuts... 
	    var myChar;
	    ( newCuts[i].indexOf('>') > -1 ) ? myChar = '>' : null;
	    ( newCuts[i].indexOf('<') > -1 ) ? myChar = '<' : null;
	    var index = newCuts[i].indexOf(myChar);

	    if (index) {

		var newCut = newCuts[i].substring(0,index+1);
		var oldCut = new String();

		// and search through the old ones
		for ( var j=0; j<oldCuts.length; j++ ) {

		    var myChar;
		    ( oldCuts[j].indexOf('>') > -1 ) ? myChar = '>' : null;
		    ( oldCuts[j].indexOf('<') > -1 ) ? myChar = '<' : null;
		    var index = oldCuts[j].indexOf(myChar);
		    oldCut = oldCuts[j].substring(0,index+1);
		    
		    // if there's a match...
		    if ( newCut == oldCut ) {

			// replace the old with the new...
			oldCuts[j] = newCuts[i];

			// and flush out the old
			newCuts[i] = null;

		    } // End of if ( newCut == oldCut )

		} // End of for ( var j=0; j<oldCuts.length; j++ )

	    } // End of if ( index )

	} // End of for ( var i=0; i<newCuts.length; i++ )

	// OK... so now we've got our set of cuts....
	// flush out whatever was sent in
	value = "";

	// And stitch together whatever we find in the original cut string
	for ( var i=0; i<oldCuts.length; i++ )
	    value += oldCuts[i] + '&&';

	// tack on anything that remains in the new string... 
	for ( var i=0; i<newCuts.length; i++ )
	    ( newCuts[i] ) ? value += newCuts[i] + '&&' : null;

	// And cut off the last '&&' that remains
	value = value.substring(0,value.length-2);

    } // End of if ( gCuts )

    if ( name == 'selection' ) {
	// And now we be having a proper set of cuts to apply :D So save it as a cookie
	var cookieSet = name + "=" + escape(value)
	    + ( ( expires ) ? ";expires=" + expires : "" )
	    + ( ( path    ) ? ";path="    + path    : "" )
	    + ( ( secure  ) ? ";secure"             : "" );
	//+ ( ( domain  ) ? ";domain="  + domain  : "" );
	
	document.cookie = cookieSet;
    }

    return;
}

// this deletes the cookie when called
function delCookie( name, path, domain ) {

    if ( getCookie( name ) ) {

	var cookie = name + "=\"\"" +
	    ( ( path   ) ? ";path="   + path   : "" ) +
	    ";expires=Thu, 01-Jan-1970 00:00:01 GMT";
	//( ( domain ) ? ";domain=" + domain : "" ) +

	document.cookie = cookie;

    }

    return;
}

// this fixes an issue with the old method, ambiguous values 
// with this test document.cookie.indexOf( name + "=" );
function getCookie( check_name ) {
    // first we'll split this cookie up into name/value pairs
    // note: document.cookie only returns name=value, not the other components
    var a_all_cookies = document.cookie.split( ';' );
    var a_temp_cookie = '';
    var cookie_name = '';
    var cookie_value = '';
    var b_cookie_found = false; // set boolean t/f default f
	
    for ( i = 0; i < a_all_cookies.length; i++ ) {
	// now we'll split apart each name=value pair
	a_temp_cookie = a_all_cookies[i].split( '=' );
	
	// and trim left/right whitespace while we're at it
	cookie_name = a_temp_cookie[0].replace(/^\s+|\s+$/g, '');
	
	// if the extracted name matches passed check_name
	if ( cookie_name == check_name ) {
	    b_cookie_found = true;
	    // we need to handle case where cookie has no value but exists (no = sign, that is):
	    if ( a_temp_cookie.length > 1 ) {
		cookie_value = unescape( a_temp_cookie[1].replace(/^\s+|\s+$/g, '') );
	    }
	    // note that in cases where cookie is initialized but no value, null is returned
	    return cookie_value;
	    break;
	}
	a_temp_cookie = null;
	cookie_name = '';
    }
    if ( !b_cookie_found ) {
	return null;
    }
    return;
}	

// End of script -->
