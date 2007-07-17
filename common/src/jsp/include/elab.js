function aLs(layerID) {
	return document.getElementById(layerID).style;
}

function HideShow(ID) {
	if ((aLs(ID).visibility == "hidden")) {
		aLs(ID).visibility = "visible";
		aLs(ID).display = "";
	}
	else if (aLs(ID).visibility == "visible") {
		aLs(ID).visibility = "hidden";
		aLs(ID).display = "none";
	}
}

function selectAll(start, finish) {
	var direction;
	for (var i = start; i < finish; i++) {
		fldObj = document.getElementById("cb" + i);
		if (fldObj.type == 'checkbox') {
			if (fldObj.name == 'selectall') {
				direction = fldObj.checked;
			}
			else {
				fldObj.checked = direction; 
			}
		}
	}
}
    
function reference(name, W, H) {
	if (!H) {
		H = 250;
	}
	while (name.indexOf(" ") > 0) {
		name = name.replace(" ", "_");
	}
	var url="../references/display.jsp?name=" + name + "&type=reference";
	var winPref = "width=300,height=" + H + ",scrollbars=no,toolbar=no,menubar=no,status=no,resizable=yes,title=yes";
	window.open(url, "Reference", winPref);
}


function showRefLink(url, W, H) {
	var height=500;
	var width=500;
	if (!H) {
		H = 500;
	}
	if (!W) {
		W = 500;
	}
	winPref = "width=" + W + ",height=" + H + ",scrollbars=yes,toolbar=no,menubar=no,status=yes,resizable=yes";
	window.open(url, "Linked_Reference", winPref);
}
