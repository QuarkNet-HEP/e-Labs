function showEventBrowser() {
	centerElement("event-browser");
	clearList("browser-files");
	clearList("browser-events");
	$("#event-browser").show();
	$("#browser-load").addClass("disabled");
	browserFileList(document.settings.lastDir);
}

function closeEventBrowser() {
	$("#event-browser").hide();
}

function clearList(id) {
	var tbl = document.getElementById(id);
	while (tbl.rows.length > 0) {
		tbl.deleteRow(0);
	}
}

var listCache = {};

function browserFileList(dir) {
	if (listCache[dir]) {
		updateFileList(listCache[dir], dir);
	}
	else {
		browserRequest("list", dir, browserFileListCB, dir);
	}
} 

function browserFileListCB(text, dir) {
	try {
		list = eval(text);
	}
	catch (e) {
		window.alert("Invalid response: " + text);
	}
	listCache[dir] = list;
	updateFileList(list, dir);
}

function updateFileList(list, dir) {
	clearList("browser-files");
	clearList("browser-events");
	document.currentFileList = list;
	document.settings.lastDir = dir;
	var tbl = document.getElementById("browser-files");
	for (var i = 0; i < list.length; i++) {
		var e = list[i];
		var row = tbl.insertRow(tbl.rows.length);
		var cell = row.insertCell(0);
		var cls = e.type == 1 ? "dir" : "file"; 
		cell.innerHTML = '<a id="browser-file-' + i + '" class="' + cls + '" onclick="selectFile(\'' + i + '\');">' + e.name + '</a>';  
	}
	fleXenv.fleXcrollMain("browser-files-div");
}

function stripOne(f) {
	var fs = f.split("/");
	fs.pop();
	window.alert(fs);
	return fs.join("/");
}

function selectFile(index) {
	if (document.selectedFileIndex) {
		$("#browser-file-" + document.selectedFileIndex).removeClass("selected");
	}
	if (document.selectedEventIndex) {
		$("#browser-event-" + document.selectedEventIndex).removeClass("selected");
	}
	var f = document.currentFileList[index];
	if (f.type == 1) {
		$("#selected-event").html("");
		$("#browser-load").addClass("disabled");
		document.selectedFileIndex = null;
		var dir;
		if (f.name == "..") {
			dir = stripOne(document.settings.lastDir);
		}
		else {
			dir = document.settings.lastDir + "/" + f.name;
		}
		document.settings.lastDir = dir;
		browserFileList(dir);
	}
	else {
		document.selectedFileIndex = index;
		browserEventList(document.settings.lastDir + "/" + f.name, index);
	}
}

function browserEventList(file, fileIndex) {
	browserRequest("events", file, browserEventListCB, fileIndex);
}

function browserEventListCB(text, fileIndex) {
	document.selectedFileIndex = fileIndex;
	$("#browser-file-" + fileIndex).addClass("selected");
	try {
		list = eval(text);
	}
	catch (e) {
		window.alert("Invalid response: " + text);
	}
	updateEventsList(list);
}

function updateEventsList(list) {
	document.currentEventList = list;
	clearList("browser-events");
	var tbl = document.getElementById("browser-events");
	for (var i = 0; i < list.length; i++) {
		var e = list[i];
		var row = tbl.insertRow(tbl.rows.length);
		var cell = row.insertCell(0); 
		cell.innerHTML = '<a id="browser-event-' + i + '" class="event" onclick="selectEvent(\'' + i + '\');">' + e.name + '</a>';  
	}
	fleXenv.fleXcrollMain("browser-events-div");
}

function selectEvent(index) {
	var file = document.currentFileList[document.selectedFileIndex];
	if (document.selectedEventIndex) {
		$("#browser-event-" + document.selectedEventIndex).removeClass("selected");
	}
	$("#browser-event-" + index).addClass("selected");
	document.selectedEventIndex = index;
	var event = document.currentEventList[index];
	var ld = document.settings.lastDir;
	$("#selected-event").html(ld + "/" + file.name + ":" + event.name);
	$("#browser-load").removeClass("disabled");
}

function browserRequest(name, paramStr, callback, data) {
    var ro;
    if(navigator.appName == "Microsoft Internet Explorer") {
		ro = new ActiveXObject("Microsoft.XMLHTTP");
	}
	else {
		ro = new XMLHttpRequest();
	}
    function cb() {
    	if (ro.readyState == 4) {
    		if (ro.status == 200) {
    			callback(ro.responseText, data);
    		}
    		else {
	    		log("Update failed: ");
	    		log("    status: " + ro.status);
    	    	log("    statusText: " + ro.statusText);
    	    	log("    responseText: " + ro.responseText);
    	    	callback(ro.responseText, data, ro.statusText);
    		}
    	}
    }
    var url = "browser.jsp?op=" + name + "&param=" + paramStr;
    log("url: <a href=\"" + url + "\">" + url + "</a>");
    ro.open("get", url);
    ro.onreadystatechange = cb;
    ro.send(null);
    return ro;
}

function loadEvent() {
	if ($("#selected-event").html() == "") {
		return;
	}
	closeEventBrowser();
	updateProgress(0, "Initializing");
	centerElement("load-progress-window");
	$("#load-progress-window").show();
	var file = document.currentFileList[document.selectedFileIndex];
	var event = document.currentEventList[document.selectedEventIndex];
	var size = event.size;
	var ro = startDownload(file.name, event.name);
	var progress = function() {
		if (ro.readyState == 1) {
			updateProgress(0.5, "Connection opened");
		}
		else if (ro.readyState == 2) {
			updateProgress(1.0, "Headers received");
		}
		else if (ro.readyState == 3) {
			var crt = ro.responseText.length;
			var p = crt / size * 89 + 1;
			updateProgress(p, "Receiving data: " + crt + "/" + size + " bytes");
		}
		else if (ro.readyState == 4) {
			return;
		}
		setTimeout(progress, 100);
	};
	setTimeout(progress, 100);
}

function startDownload(file, event) {
	return browserRequest("get", file + ":" + event, loadEventCB, null);
}

function loadEventCB(text, data, error) {
	if (error) {
		window.alert("Error: " + error);
		$("#load-progress-window").hide();
		return;
	}
	updateProgress(91, "Parsing data");
	var nan = Number.NaN;
	try {
		document.d_event = eval(text);
		updateProgress(93, "Initializing objects");
		initializeData();
		document.draw();
		updateProgress(100, "Done");
	}
	catch (e) {
		window.alert("Data loading failed: ", e);
		$("#load-progress-window").hide();
		throw e;
	}
	$("#load-progress-window").hide();
}

function updateProgress(p, text) {
	var frame = document.getElementById("event-load-progress-frame");
	width = 576;
	$("#event-load-progress-bar").css("width", Math.round(p / 100 * width) + "px");
	$("#event-load-progress-text").html(text);
}