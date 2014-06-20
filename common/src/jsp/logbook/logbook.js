function insertImgSrc() {
    var raw = document.log.img_src.value;
    var parsed = raw.split(",");
    for (var i = 0; i < parsed.length; i++)
    {
        var txt = document.log.log_text.value;
        txt = txt.replace("(--Image "+i+"--)", parsed[i]);
        document.log.log_text.value = txt;
    }
}

function showFullLog(showDivId, fullDivId) {
	var showDiv = document.getElementById(showDivId);
	var fullDiv = document.getElementById(fullDivId);
	showDiv.innerHTML = fullDiv.innerHTML;
}

function showFullComment(showDivId, fullDivId) {
	var showDiv = document.getElementById(showDivId);
	var fullDiv = document.getElementById(fullDivId);
	showDiv.innerHTML = fullDiv.innerHTML;
}

function markAsRead(id, url) {
	var ro = newRequestObject();
	ro.open('get', url);
	ro.onreadystatechange = function() {
		if (ro.readyState == 4 && ro.status == 200) {
			var div = document.getElementById(id);
			div.innerHTML = "";
		}
	};
	ro.send(null);
}

function newRequestObject() {
	browser = navigator.appName;
	if(browser == "Microsoft Internet Explorer") {
		return new ActiveXObject("Microsoft.XMLHTTP");
	}
	else {
		return new XMLHttpRequest();
	}
}