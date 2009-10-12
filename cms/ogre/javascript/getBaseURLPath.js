var baseURL = new String();

// 
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
    for ( i=0; i<nodes.length; i++ ) {
	if ( nodes[i].getAttribute('name') == "urlPath" )
            baseURL = nodes[i].getAttribute('value');
    }

    return;
}
