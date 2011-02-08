// Only tested on Firefox 3.6+
// Requires HTML5 File API support 

var fileList = null; 
var fileListCurrentIndex; 

function loadEvent0() {
	fileList = document.getElementById('file-selector').files; 
	fileListCurrentIndex = 0; 
	loadEvent(fileListCurrentIndex);
}

function loadEvent(i) {
	var data = fileList[i].getAsText("utf8");
	var ed   = eval(data);
	
	enableNextPrev();
	eventDataLoaded(ed); 
	
	$("#title").html("File " + (fileListCurrentIndex + 1) + " of " + fileList.length + ": " + fileList[i].name);
}

function enableNextPrev() {
	if (fileListCurrentIndex > 0) {
		$("#prev-event-button").removeClass("disabled");
	}
	else {
		$("#prev-event-button").addClass("disabled");
	}
	if (fileList && fileList.length - 1 > fileListCurrentIndex) {
		$("#next-event-button").removeClass("disabled");
	}
	else {
		$("#next-event-button").addClass("disabled");
	}
}
	
function nextEvent() {
	if (fileList && fileList.length - 1 > fileListCurrentIndex) {
		fileListCurrentIndex++; 
		loadEvent(fileListCurrentIndex); 
	}
}

function prevEvent() {
	if (fileList && fileListCurrentIndex > 0) {
		fileListCurrentIndex--;
		loadEvent(fileListCurrentIndex); 
	}
}