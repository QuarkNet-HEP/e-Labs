// overrides for the main plot-params.js

function plotSelected() {
	updatePlotList();
}

function updatePlotList() {
	var list = document.getElementById("plots-input");
	var str = "";
	var tbl = document.getElementById("plotlist");
	for (var i = 1; i < tbl.rows.length; i++) {
		var cb = firstNonTextChild(tbl.rows[i].cells[0]);
		if (!cb.checked) {
			continue;
		}
		var a = firstNonTextChild(tbl.rows[i].cells[2]);
		var img = firstNonTextChild(a);
		var color = img.getAttribute("value");
		if (color == null || color == "") {
			color = "black";
		}
		str += "path:" + cb.getAttribute("value") + ",color:" + color + " ";
	}
	list.value = str;
	log("plot str: " + str);
	document.getElementById("plot-submit").disabled = str == "";
	log("plot count: " + (tbl.rows.length - 2));
	return tbl.rows.length - 2;
}

function initializeFromPlotParams() {
	options["onSelect"] = setColor;
	$(".colorbutton").jeegoocontext("color-list", options);
	$("#plotlist .plot").bind("click", plotSelected);
		
	var plots = document.getElementById("plots-input");
	if (plots.value == null || plots.value == "") {
		return;
	}
	document.getElementById("plot-submit").disabled = false;
	var tbl = document.getElementById("plotlist");
	var s = plots.value.split(" ");
	var count = 0;
	var single = null;
	for (var i = 1; i < tbl.rows.length - 1; i++) {
		var cb = firstNonTextChild(tbl.rows[i].cells[0]);
		cb.checked = false;
		for (var j = 0; j < s.length; j++) {
			if (s[j] != "") {
				var p = msplit(s[j], ",", ":");
				if (cb.value == p["path"]) {
					cb.checked = true;
					var a = firstNonTextChild(tbl.rows[i].cells[2]);
					var img = firstNonTextChild(a);
					log("path: " + p["path"] + ", color: " + p["color"]);
					img.style.backgroundColor = p["color"];
					img.setAttribute("value", p["color"]);
				}
			}
		}
	}
}