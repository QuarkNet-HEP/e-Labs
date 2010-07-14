var options = {
		widthOverflowOffset: 0,
        heightOverflowOffset: 3,
        submenuLeftOffset: -4,
        submenuTopOffset: -5,
        event: 'click'
};

var setColor = function(e, context) {
	var c = firstNonTextChild(context); 
	var v = $(this).context.getAttribute("value");
	log("selected color: " + v);
	c.style.backgroundColor = v;
	c.setAttribute("value", v);
	updatePlotList();
}

function clearPlots() {
	var table = document.getElementById("plots");
	while (table.rows.length > 2) {
		table.deleteRow(1);
	}
	document.getElementById("plot-submit").disabled = true;
}

function updatePlotsFromValue(val, label) {
	clearPlots();
	addPlotRow(val, label);
	updatePlotList();
}

function addPlotRow(value, label) {
	var tbl = document.getElementById("plots");
	var row = tbl.insertRow(tbl.rows.length - 1);

	$("#plot-template .plot-index").html(tbl.rows.length - 2);
	var html = label;
	if (html.indexOf("...") != -1) {
		html = html.replace("...", $("#param-template").html());
	}
	$("#plot-template .active-label").html(html);
	$("#plot-template .active-label").attr("value", value);
	
	var trow = document.getElementById("plot-template");
	for (var i = 0; i < trow.cells.length; i++) {
		var tcell = trow.cells[i];
		var cell = row.insertCell(row.cells.length);
		cell.innerHTML = tcell.innerHTML;
		if (tcell.className) {
			cell.className = tcell.className;
		}
		if (tcell.width) {
			cell.width = tcell.width;
		}
		if (tcell.getAttribute("value")) {
			cell.setAttribute("value", tcell.getAttribute("value"));
		}
	}
	
	options["onSelect"] = setColor;
	$(".colorbutton").jeegoocontext("color-list", options);
	$("input.log").change(updatePlotList);
	$(".remove .tbutton").click(removePlotRow);
}

function removePlotRow(c) {
	log("remove plot row: " + this.parentNode.parentNode.rowIndex);
	var tbl = document.getElementById("plots");
	tbl.deleteRow(this.parentNode.parentNode.rowIndex);
	if (updatePlotList() == 1) {
		var list = document.getElementById("plots-input");
		setSimplifiedPlotsValue(list.value.split(":")[0]);
	}
}

var addPlot = function(e, context) {
	var label = $(this).html();
	var plabel = $(this).parent().parent().contents().filter("span.label").html();
	var value = $(this).get()[0].getAttribute("value");
	if (value == null) {
		value = label;
	}
	var pvalue = $(this).parent().parent().get()[0].getAttribute("value");
	
	addPlotRow(value +  pvalue, label + " " + plabel);
	
	$('select #advanced').attr("selected", "true");
	updatePlotList();
}

function updatePlotList() {
	var list = document.getElementById("plots-input");
	var str = "";
	var tbl = document.getElementById("plots");
	for (var i = 1; i < tbl.rows.length - 1; i++) {
		var a = firstNonTextChild(tbl.rows[i].cells[2]);
		var img = firstNonTextChild(a);
		var color = img.getAttribute("value");
		if (color == null || color == "") {
			color = "black";
		}
		str += "path:" + tbl.rows[i].cells[1].getAttribute("value") + ",color:" + color + " ";
	}
	list.value = str;
	log("plot str: " + str);
	document.getElementById("plot-submit").disabled = str == "";
	log("plot count: " + (tbl.rows.length - 2));
	return tbl.rows.length - 2;
}

function msplit(str, sep1, sep2) {
	var map = new Array();
	var s1 = str.split(sep1);
	for (var i = 0; i < s1.length; i++) {
		var s2 = s1[i].split(sep2);
		map[s2[0]] = s2[1];
	}
	return map;
}

function mjoin(map, sep1, sep2) {
	var str = "";
	var first = true;
	for (var k in map) {
		if (!first) {
			str += sep1;
		}
		str += k + sep2 + map[k];
		first = false;
	}
	return str;
}

function initializeFromPlotParams() {
	options['onSelect'] = addPlot;
    $('#addplot').jeegoocontext('plot-list', options);
	
	buildPlotTypeMap();
	var plots = document.getElementById("plots-input");
	if (plots.value == null || plots.value == "") {
		return;
	}
	document.getElementById("plot-submit").disabled = false;
	var tbl = document.getElementById("plots");
	var s = plots.value.split(" ");
	var count = 0;
	var single = null;
	for (var i = 0; i < s.length; i++) {
		if (s[i] != "") {
			var p = msplit(s[i], ",", ":");
			if (++count == 1) {
				single = p["path"];
			}
			addPlotRow(p["path"], document.plotTypes[p["path"]]);
			var a = firstNonTextChild(tbl.rows[i + 1].cells[2]);
			var img = firstNonTextChild(a);
			img.style.backgroundColor = p["color"];
			img.setAttribute("value", p["color"]);
		}
	}
	if (count == 1) {
		setSimplifiedPlotsValue(single);
	}
	else if (count > 1) {
		setSimplifiedPlotsValue("advanced");
	}
}

function setSimplifiedPlotsValue(v) {
	var sp = document.getElementById("simplified-plots");
	var any = false;
	for (var i = 0; i < sp.childNodes.length; i++) {
		var option = sp.childNodes[i];
		if ((option.value == "advanced") && (!any || (v == "advanced"))) {
			option.selected = true;
			vSwitchShow("advanced-plot-panel");
		}
		else if (option.value == v) {
			any = true;
			option.selected = true;
		}
		else {
			option.selected = false;
		}
	}
}

function buildPlotTypeMap() {
	// build map from plot types to labels
	document.plotTypes = new Array();
	var plots = document.getElementById("plot-list");
	if (plots === null) {
		return;
	}
	for (var i = 0; i < plots.childNodes.length; i++) {
		var c1 = plots.childNodes[i];
		if (c1.nodeName == "LI") {
			var v1 = c1.getAttribute("value");
			var l1 = null;
			for (var j = 0; j < c1.childNodes.length; j++) {
				var c2 = c1.childNodes[j];
				if (c2.nodeName == "UL") {
					for (var k = 0; k < c2.childNodes.length; k++) {
						var c3 = c2.childNodes[k];
						if (c3.nodeName == "LI") {
							var v2 = c3.getAttribute("value");
							var l2 = c3.innerHTML;
							document.plotTypes[v2 + v1] = l2 + " " + l1;
						}
					}
				}
				else if (c2.nodeType != 3) {
					l1 = c2.innerHTML;
				}
			} 
		}
	}
}
