// Define an object to hold the XML we'll be grabbing
var XML = new Object();

/*
 * Create a new Document object. If no arguments are specified,
 * the document will be empty. If a root tag is specified, the document
 * will contain that single root tag. If the root tag has a namespace
 * prefix, the second argument must specify the URL that identifies the
 * namespace.
 */
XML.newDocument = function(rootTagName, namespaceURL) {
    if (!rootTagName) rootTagName = "";
    if (!namespaceURL) namespaceURL = "";

    if (document.implementation && document.implementation.createDocument) {
	// This is the W3C standard way to do it
	return document.implementation.createDocument(namespaceURL, 
						      rootTagName, null);
    }
    else { // This is the IE way to do it
	   // Create an empty document as an ActiveX object
	   // If there is no root element, this is all we have to do
	var doc = new ActiveXObject("MSXML2.DOMDocument");

	// If there is a root tag, initialize the document
	if (rootTagName) {
	    // Look for a namespace prefix
	    var prefix = "";
	    var tagname = rootTagName;
	    var p = rootTagName.indexOf(':');
	    if (p != -1) {
		prefix = rootTagName.substring(0, p);
		tagname = rootTagName.substring(p+1);
	    }

	    // If we have a namespace, we must have a namespace prefix
	    // If we don't have a namespace, we discard any prefix
	    if (namespaceURL) {
		if (!prefix) prefix = "a0"; // What Firefox uses
	    }
	    else prefix = "";
	    
	    // Create the root element (with optional namespace) as a
	    // string of text
	    var text = "<" + (prefix?(prefix+":"):"") + tagname +
		(namespaceURL
		 ?(" xmlns:" + prefix + '="' + namespaceURL +'"')
		 :"") +
		"/>";
	    // And parse that text into the empty document
	    doc.loadXML(text);
	}
	return doc;
    }
};

/*
 * Synchronously load the XML document at the specified URL and
 * return it as a Document object
 */
XML.load = function(url) {
    // Create a new document with the previously defined function
    var xmldoc = XML.newDocument();
    xmldoc.async = false;  // We want to load synchronously
    xmldoc.load(url);      // Load and parse
    return xmldoc;         // Return the document
};

/*
 * Asynchronously load and parse an XML document from the specified URL.
 * When the document is ready, pass it to the specified callback function.
 * This function returns immediately with no return value.
 */
XML.loadAsync = function(url, callback) {
    var xmldoc = XML.newDocument();

    // If we created the XML document using createDocument, use
    // onload to determine when it is loaded
    if (document.implementation && document.implementation.createDocument) {
        xmldoc.onload = function() { callback(xmldoc); };
    }
    // Otherwise, use onreadystatechange as with XMLHttpRequest
    else {
        xmldoc.onreadystatechange = function() {
            if (xmldoc.readyState == 4) callback(xmldoc);
        };
    }

    // Now go start the download and parsing
    xmldoc.load(url);
};
/*
 * Parse the XML document contained in the string argument and return
 * a Document object that represents it.
 */
/*
XML.parse = function(text) {
    if (typeof DOMParser != "undefined") {
        // Mozilla, Firefox, and related browsers
        return (new DOMParser()).parseFromString(text, "application/xml");
    }
    else if (typeof ActiveXObject != "undefined") {
        // Internet Explorer.
        var doc = XML.newDocument( );   // Create an empty document
        doc.loadXML(text);              //  Parse text into it
        return doc;                     // Return it
    }
    else {
        // As a last resort, try loading the document from a data: URL
        // This is supposed to work in Safari. Thanks to Manos Batsis and
        // his Sarissa library (sarissa.sourceforge.net) for this technique.
        var url = "data:text/xml;charset=utf-8," + encodeURIComponent(text);
        var request = new XMLHttpRequest();
        request.open("GET", url, false);
        request.send(null);
        return request.responseXML;
    }
};
*/