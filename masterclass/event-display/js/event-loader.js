// Only tested on Firefox 3.6+
// Requires HTML5 File API support 

var fileList = null; 
var fileListCurrentIndex; 

function loadEvent() {
	fileList = document.getElementById('file-selector').files; 
	fileListCurrentIndex = 0; 
	loadEvent(fileListCurrentIndex);
}

function loadEvent(var i) {
	var data = fileList[i].getAsText("utf8");
	var ed   = eval(data);
	
	eventDataLoaded(ed); 
	enableNextPrev();
	
	$("#title").html(fileList[i].name);
}

function enableNextPrev() {
	if (fileListCurrentIndex > 0) {
		$("#prev-event-button").removeClass("disabled");
	}
	if (fileList && fileList.length > fileListCurrentIndex) {
		$("#next-event-button").removeClass("disabled");
	
function nextEvent() {
	if (fileList && fileList.length > fileListCurrentIndex) {
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