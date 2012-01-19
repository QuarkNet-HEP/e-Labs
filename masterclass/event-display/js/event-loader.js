// Only tested on Firefox 7+
// Requires HTML5 File API support 

// tpm NOTE: File API has changed since Firefox 7+
// getAsText as File method has been deprecated
// FileReader is used instead. See loadEvent below.

// pxn NOTE: FF9+ recommended due to JavaScript engine
// improvements 

var fileList = null; 
var fileListCurrentIndex; 

function loadEvent0() {
	fileList = document.getElementById('file-selector').files; 
	fileListCurrentIndex = 0; 
	loadEvent(fileListCurrentIndex);
}


function cleanupData(d) {
    // rm non-standard json bits
    // newer files will not have this problem
    d = d.replace(/\(/g,'[')
	.replace(/\)/g,']')
	.replace(/\'/g, "\"")
	.replace(/nan/g, "0");
    return d;
}

function loadEvent(i) {
  var ua = $.browser;
  var version;
  if ( ua.mozilla ) {
    version = ua.version.slice(0,1);
  }
  else {
    alert("Firefox 7 or newer is required for this application.");
    return;
  }

  if ( version < 7 ) { 
    try {
	var data = cleanupData(JXG.decompress(fileList[i].getAsText("US-ASCII")));
      var ed   = JSON.parse(data);
      enableNextPrev();
      eventDataLoaded(ed); 
	
      $("#title").html("File " + (fileListCurrentIndex + 1) + " of " + fileList.length + ": " + fileList[i].name);
    } catch (e) {
      alert(e);
    }
  }

  else {
    try {
      var reader = new FileReader();

      reader.onload = function(e) {
    	var data = e.target.result; 
		data = JXG.decompress(data); // inflate base64-encoded gzipped data
    	data = cleanupData(data); // fix JSON if needed
        var ed = JSON.parse(data);
        enableNextPrev();
        eventDataLoaded(ed); 
	
        $("#title").html("File " + (fileListCurrentIndex + 1) + " of " + fileList.length + ": " + fileList[i].name);
      }
    reader.onerror = function(e) {
      alert(e);
    }

      reader.readAsText(fileList[i], "US-ASCII"); // requires base64-encoded compressed binary blob
    } catch(e) {
      alert(e);
    }
  }
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