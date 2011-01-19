var fileList = null; 

function loadEvent() {
	// Firefox 3.6+ only right now :(
	
	fileList = document.getElementById('file-selector').files; 
	
	var data = fileList[0].getAsText("utf8");
	
	var ed = eval(data);
	
	eventDataLoaded(ed); 
	
	$("#title").html(files[0].name);
}