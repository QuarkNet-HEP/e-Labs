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

function selectAll(start, finish, direction) {
	for (var i = start; i < finish; i++) {
		fldObj = document.getElementById("cb" + i);
		if (fldObj.type == 'checkbox') {
			fldObj.checked = direction; 
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
	var winPref = "width=400,height=" + H + ",scrollbars=no,toolbar=no,menubar=no,status=no,resizable=yes,title=yes";
	window.open(url, "_blank", winPref);
}

function glossary(name, H) {
	if (!H) {
		H = 250;
	}
	while (name.indexOf(" ") > 0) {
		name = name.replace(" ", "_");
	}
	var url = "../references/display.jsp?name=" + name + "&type=glossary";
    var winPref = "width=300,height=" + H + ",scrollbars=no,toolbar=no,menubar=no,status=no,resizable=yes,title=yes";
	window.open(url, "_blank", winPref);
}

function describe(tr, arg, label) {
	var url="../jsp/dispDescription.jsp?tr=" + tr + "&arg=" + arg + "&label=" + label;
    var winPref = "width=250,height=250,scrollbars=no,toolbar=no,menubar=no,status=no,resizable=yes,title=yes";
	window.open(url, "_blank", winPref);
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
	window.open(url, "_blank", winPref);
}

//http://www.experts-exchange.com/Web/Web_Languages/JavaScript/Q_21265898.html
function toggle(t_show, t_hide, s_show, s_hide){
	if (document.getElementById(t_show).innerHTML == s_show) {
		document.getElementById(t_show).innerHTML = s_hide;
		document.getElementById(t_hide).style.display = "";
	}
	else if (document.getElementById(t_show).innerHTML == s_hide) {
		document.getElementById(t_show).innerHTML = s_show;
		document.getElementById(t_hide).style.display = "none";
	}
	else {
		document.getElementById(t_hide).style.display = "none";
	}
}

function registerLabelForUpdate(name, label, dest) {
	if (!this.labelsToUpdate) {
		this.labelsToUpdate = [];
	}
	this.labelsToUpdate[name] = [label, dest];
}

function updateLabels(source, name) {
	if (this.labelsToUpdate != null && this.labelsToUpdate[name] != null) {
		var p = this.labelsToUpdate[name];
		if (p) {
			var label = p[0];
			var dest = p[1];
			var destInput = document.getElementById(dest);
			var text = destInput.value;
			var index = text.indexOf(label);
			if (index != -1) {
				index += label.length;
				var nl = text.indexOf('\n', index);
				if (nl == -1) {
					nl = text.length;
				}
				text = text.substring(0, index) + source.value + text.substring(nl);
				destInput.value = text; 
			}
		}
	}
}