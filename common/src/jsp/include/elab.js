function populateInputs() {
	var inputs = document.getElementsByTagName("input");
	for (var i = 0; i < inputs.length; i++) {
		if (inputs[i].type == "text" && inputs[i].getAttribute("placeholder") != null) {
			inputs[i].style.color = "gray";
			inputs[i].value = inputs[i].getAttribute("placeholder");
		}
	}
}

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

function vSwitchShow(id) {
	show(id + "-h");
	hide(id + "-v");
}

function vSwitchHide(id) {
	show(id + "-v");
	hide(id + "-h");
}

function hide(id) {
	aLs(id).visibility = "hidden";
	aLs(id).display = "none";
}

function show(id) {
	aLs(id).visibility = "visible";
	aLs(id).display = "";
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

function firstNonTextChild(obj) {
    for (var i in obj.childNodes) {
        if (obj.childNodes[i].nodeName != "#text") {
	        return obj.childNodes[i];
        }
    }
    return null;
}

function getAncestor(obj, level) {
    if (level == 0) {
        return obj;
    }
    else {
        return getAncestor(obj.parentNode, level - 1);
    }
}

function log(text) {
    var l = document.getElementById("log");
    if (l) {
    	l.innerHTML = l.innerHTML + "<br />\n" + new Date().toGMTString() + " " + text;
    	l.scrollTop = l.scrollHeight;
    }
}

function initlog() {
	document.write(
		'<div id="log">' + 
			'<input id="logtoggle" type="button" value="Hide Log" onclick="toggleLog();" style="position: fixed; bottom: 4px; right: 20px;"/>' + 
		'</div>');
}

function toggleLog() {
	var l = document.getElementById("log");
	var lt = document.getElementById("logtoggle");
	if (l.style.height == "6px") {
		l.style.height = "100px";
		lt.value = "Hide Log";
	}
	else {
		l.style.height = "6px";
		lt.value = "Show Log";
	}
}
