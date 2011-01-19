function loadEvent() {
	// Firefox 3.6+ only right now :( 
	var files = document.getElementById('file-selector').files; 
	
	var data = files[0].getAsText("utf8");
	
	var ed = eval(data);
	
	eventDataLoaded(ed); 
}