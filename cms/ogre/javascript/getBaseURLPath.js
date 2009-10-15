var baseURL = new String();

// 
function getBaseURLPath () {
    var xmlHttp=createXMLHttp();

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
