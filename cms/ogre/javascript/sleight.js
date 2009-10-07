// Copyright 2001, Aaron Boodman
// This code is public domain. Please use it for good, not evil.

if (navigator.platform == "Win32" && navigator.appName == "Microsoft Internet Explorer" && window.attachEvent) {
    document.writeln('<style type="text/css">img { visibility:hidden; } </style>');
    window.attachEvent("onload", fnLoadPngs);
}

function fnLoadPngs() {

    var rslt = navigator.appVersion.match(/MSIE (\d+\.\d+)/, '');
    var itsAllGood = (rslt != null && Number(rslt[1]) >= 5.5);
    for (var i = document.images.length - 1, img = null; (img = document.images[i]); i--) {
	
	if (itsAllGood && img.src.match(/\.png$/i) != null ) {

	    var src = img.src;
	    var div = document.createElement("DIV");
	    div.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + 
		src + "', sizingMethod='scale')";
	    try {
		div.style.position = img.style.position;
	    } catch (e) {
		div.style.position = "relative";
	    }

	    try {
		div.style.width = parseInt(img.style.width) + "px";
	    } catch (e) {
		div.style.width = img.width + "px";
	    }
	    try {
		div.style.height = parseInt(img.style.height) + "px";
	    } catch (e) {
		div.style.height = img.height + "px";
	    }

	    try {
		div.style.zIndex = img.style.zIndex;
	    } catch (e) {}
	    
	    try {
		div.style.top = parseInt(img.style.top) + "px";
	    } catch (e) {}
	    try {
		div.style.left = parseInt(img.style.left) + "px";
	    } catch (e) {}
	    
	    img.replaceNode(div);
	}

	img.style.visibility = "visible";
    }
}
