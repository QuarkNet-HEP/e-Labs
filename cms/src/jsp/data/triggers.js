function getConjExpr(cell) {
    var ctable = firstNonTextChild(cell);
    var expr = "";
    for (var row = 0; row < ctable.rows.length - 1; row++) {
        var termcell = ctable.rows[row].cells[0];
        if (termcell.className != "vopcell") {
        	if (expr != "") {
	        	expr = expr + " and ";
        	}
        	var e = firstNonTextChild(termcell).getAttribute("value");
        	expr = expr + e;
        }
    }
    return expr;
}

function getExpr(id) {
    var table = document.getElementById(id);
    var expr = "";

    var frow = table.rows[0];
    for (var col = 0; col < frow.cells.length; col++) {
        var ccol = frow.cells[col];
        if (ccol.className != "hopcell") {
	        var conjexpr = getConjExpr(ccol);
	        if (expr != "") {
		        expr = expr + " or ";
	        }
	        expr = expr + conjexpr;
        }
    }
    return expr;
}

// Callback function to update totals; also fires on every 
// individual run checkbox state change. 
function updateTotals() {
	var sw = document.getElementsByTagName("input");
	var rinput = document.getElementById("runs-input");
	var runs = 0, events = 0;
	var runlist = "";
	var allChecked = true; 
	for (var i = 0; i < sw.length; i++) {
		if (sw[i].className == "runsw") {
			if (sw[i].checked) {
				runs++;
				events += parseInt(sw[i].getAttribute("nevents"));
				runlist += sw[i].getAttribute("run");
				runlist += " ";
			}
			else {
				allChecked = false; 
			}
		}
	}
	
	if (allChecked) {
		$("#select-all").attr('checked', true);
	}
	else {
		$("#select-all").attr('checked', false);
	}
	
	var totals = document.getElementById("totals");
	totals.innerHTML = "Total: " + runs + " runs, " + events + " events";
	rinput.value = runlist;
	
	// If totals = zero, we can't do any analyses so disable that button!
	if (events == 0) {
		$("#plot-params-button").attr("disabled", true);
	}
	else {
		$("#plot-params-button").removeAttr("disabled");
	}
}

function selectAll() {
	var all = document.getElementById("select-all");
	var sw = document.getElementsByTagName("input");
	for (var i = 0; i < sw.length; i++) {
		if (sw[i].className == "runsw") {
			sw[i].checked = all.checked;
		}
	}
	updateTotals(); 
}

function clearRunList() {
	var druns = document.getElementById("runlist");
    while (druns.childNodes.length > 0) {
    	druns.removeChild(druns.childNodes[0]);
    }
}

function updateData(expr) {
	var dataset = document.getElementById("dataset-input").value;
    var druns = document.getElementById("runlist");
    clearRunList();
    var ro;
    if(navigator.appName == "Microsoft Internet Explorer") {
		ro = new ActiveXObject("Microsoft.XMLHTTP");
	}
	else {
		ro = new XMLHttpRequest();
	}
    function cb() {
    	var dataset;
    	if (ro.readyState == 4) {
    		var text = ro.responseText;
    		var runs = new Array();
    		var crtrun = null;
    		var lines = text.split("\n");
    		for (var i = 0; i < lines.length; i++) {
    			lines[i] = lines[i].replace(/^\s+|\s+$/g, "");
    			if (lines[i] == "") {
    				continue;
    			}
    			var nv = lines[i].split("=", 2);
    			if (nv[0] == "run") {
    				if (crtrun != null) {
    					runs.push(crtrun);
    				}
    				crtrun = new Array();
    			}
    			else if (nv[0] == "dataset") {
    				dataset = nv[1];
    				continue;
    			}
    			crtrun[nv[0]] = nv[1];
    		}
    		if (crtrun != null) {
    			runs.push(crtrun);
    		}
    		
    		if (document.filterRuns) {
    			var runFilter = document.getElementById("runs-input").value + " ";
    		}
    		
    		var druns = document.getElementById("runlist");
    		var totalEvents = 0;
    		var someFilteredRuns = false;
    		log("runs: " + runs);
    		for (var i = 0; i < runs.length; i++) {
    			var run = runs[i]["run"];
    			var div = document.createElement("div");
    			div.className = "run";
    			var sw = document.createElement("input");
    			sw.type = "checkbox";
    			sw.name = runs[i]["run"];
    			sw.setAttribute("nevents", runs[i]["nevents"]);
    			sw.onchange = updateTotals;
    			sw.className = "runsw";
    			sw.setAttribute("run", run);
    			div.appendChild(sw);
    			// IE has problems if checked is set before the checkbox is added
    			// to the DOM.
    			if (!document.filterRuns || runFilter.indexOf(run + " ") != -1) {
    				sw.checked = true;
    			}
    			else {
    				someFilteredRuns = true;
    			}
    			var rundata = "Run " + run + " (" + runs[i]["nevents"] + " events, ";
    			if (dataset == "tb04") {
    				rundata = rundata +
    					runs[i]["energy"] + " GeV," + 
    					" &phi;=" + runs[i]["phi"] +
    					" &eta;=" + runs[i]["eta"] +
    					")";
    			}
    			else {
    				rundata = rundata + runs[i]["description"] + ")";
    			}
    			var txt = document.createElement("span");
    			txt.innerHTML = rundata;
    			div.appendChild(txt);
    			druns.appendChild(div);
    		}
    		updateTotals();
    		document.filterRuns = false;
    		if (someFilteredRuns) {
    			vSwitchShow("selected-events-panel");
    		}
    		if (typeof updatingDone == "function") {
    			updatingDone();
    		}
    	}
    }
    if (typeof updatingStarted == "function") {
    	updatingStarted();
    }
    var url = "../data/db-async.jsp?dataset=" + dataset + "&texpr=" + expr;
    log("db-request: " + url)
    ro.open("get", url);
    ro.onreadystatechange = cb;
    ro.send(null);
}

function updateExpr() {
	var incl = getExpr("incltable");
	var excl = getExpr("excltable");
	var expr = incl;
	if (excl != "") {
		expr = "(" + expr + ") and not (" + excl + ")";
	}
	var tf = document.getElementById("expr");
	tf.value = expr;
	updateData(expr);
}

function clearExpr() {
	document.getElementById("expr").value = "";
	clearTriggerTable(document.getElementById("incltable"));
	clearTriggerTable(document.getElementById("excltable"));
	var st = document.getElementById("simplified-triggers");
	if (st) {
		setSelected(st, 0);
	}
}

function setSelected(list, index) {
	for (var i = 0; i < list.options.length; i++) {
		if (i == index) {
			list.options[i].selected = true;
		}
		else {
			list.options[i].selected = false;
		}
	}
}

function clearTriggerTable(table) {
    log("Clearing previous selections from " + table);
    var row = table.rows[0];
    log("Starting cell count: " + row.cells.length);
    while (row.cells.length > 0) {
        row.deleteCell(0);
    }
    log("Ending cell count: " + row.cells.length);
}

function translateTrigger(value) {
	switch(value) {
		case "uu":
			return "&mu;&mu;";
		case "tt":
			return "&tau;&tau;";
		case "enu":
			return "e&nu;";
		case "munu":
			return "&mu;&nu;";
		default:
			return value;
	}
}

function updateTriggerTable(id, parsed) {
    log("Updating trigger table " + id);
    var ttbl = document.getElementById(id);
    clearTriggerTable(ttbl);
    for (var i = 0; i < parsed.length; i++) {
        var col = parsed[i];
        var cell = createOrColumn(ttbl);
        var ctbl = getAncestor(cell, 3);
        
        $("#trigger-template .active-label").attr("value", col[0]);
        $("#trigger-template .active-label").html(translateTrigger(col[0]));
		cell.innerHTML = $("#trigger-template").html();
        for (var j = 1; j < col.length; j++) {
	        var ocell = createAndRow(ctbl);
	        labelFromTemplate(ocell, col[j]); 
        }
    }
}

function updateTriggerTables(incl, excl) {
    updateTriggerTable("incltable", incl);
    updateTriggerTable("excltable", excl);
    setupTriggerMenus();
}

function initializeFromExpr() {
	var exprel = document.getElementById("expr");
	if (exprel.value != "") {
		document.filterRuns = true;
		updateFromExpr(exprel.value);
	}
	else {
		if (exprInvalid) {
			exprInvalid();
		}
	}
}

function updateFromExpr(expr) {
	updateFromSimpleExpr(expr);
	updateSimpleList(expr);
}

var NODETYPE_TEXT = 3;

function updateSimpleList(expr) {
	var sl = document.getElementById("simplified-triggers");
	var any = false;
	for (var i = 0; i < sl.childNodes.length; i++) {
		var option = sl.childNodes[i];
		if (option.nodeType == NODETYPE_TEXT) {
			continue;
		}
		if (option.value == expr) {
			any = true;
			option.selected = true;
		}
		else if (option.value == "advanced" && !any) {
			option.selected = true;
		}
		else {
			option.selected = false;
		}
	}
}

function updateFromSimpleExpr(expr) {
	var dataset = document.getElementById("dataset-input").value;
    log("updateFromExpr(" + dataset + ", " + expr + ")");
    var tf = document.getElementById("expr");
    tf.value = expr;
    var norm = expr.replace("[\\(\\)]", "");
    var incl = new Array();
    var excl = new Array();
    var terms = expr.split(" ");
    var crt = incl;
    var lastop = "start";
    for (var i = 0; i < terms.length; i++) {
        if (terms[i] == "not") {
	        if (lastop == "and") {
	        	crt = excl;
	        	lastop = "start";
	        }
	        else {
		        window.alert("Invalid expression ('not' not preceded by 'and'): " + expr); 
	        }
        }
        else if (terms[i] == "and") {
	        lastop = "and";
        } 
        else if (terms[i] == "or") {
	        lastop = "or";
        }
        else {
	         if (lastop == "start" || lastop == "or") {
		         ands = new Array();
		         ands.push(terms[i]);
		         crt.push(ands);
	         }
	         else if (lastop == "and") {
		         crt[crt.length - 1].push(terms[i]);
	         }
        }
    }
	log("incl: " + incl);
	log("excl: " + excl);
    updateTriggerTables(incl, excl);
    updateData(expr);
}

function showRemoveButton(obj) {
    
}

function hideRemoveButton(obj) {
    
}

function createAndRow(ttbl) {
	var row = ttbl.insertRow(ttbl.rows.length - 1);
	var cell = row.insertCell(0);
	cell.innerHTML = '<div class="voperator">and</div>';
	cell.className = "vopcell";
	row = ttbl.insertRow(ttbl.rows.length - 1);
	return row.insertCell(0);
}

function createOrColumn(ttbl) {
    log("Creating or column...");
	var trow = ttbl.rows[0];
	var first = trow.cells.length == 0;
	if (!first) {
		log("This is not the first column");
		var cell = trow.insertCell(trow.cells.length);
		cell.innerHTML = "or";
		cell.style.verticalAlign = "top";
		cell.className = "hopcell";
	}

	log("Inserting cell");
	var td = trow.insertCell(trow.cells.length);
	var ortblt = document.getElementById("ortable-template");
	td.innerHTML = ortblt.innerHTML;
	log("td: " + td);
	var ortbl = firstNonTextChild(td);
	log("ortbl: " + ortbl);
	var row = ortbl.insertRow(0);

	log("Inserting second cell");
	var btn = document.getElementById("and-button-template");
	var cell = row.insertCell(0);
	cell.innerHTML = btn.innerHTML;

	row = ortbl.insertRow(0);
	return row.insertCell(0);
}

var options = {
		widthOverflowOffset: 0,
        heightOverflowOffset: 3,
        submenuLeftOffset: -4,
        submenuTopOffset: -5,
        event: 'click'
};
var addTrigger = function(e, context) {
    var cls = context.className;
	var p;
	if (cls.indexOf(" andtrigger") != -1) {
    	var ttbl = getAncestor(context, 4);

    	p = createAndRow(ttbl);
	}
	else if (cls.indexOf(" ortrigger") != -1) {
		var ctbl = getAncestor(context, 4);
		log("ctbl: " + ctbl);
		log("fntc: " + firstNonTextChild(ctbl.rows[0].cells[0]));
		p = createOrColumn(firstNonTextChild(ctbl.rows[0].cells[0]));
	}
	else {
    	return;
	}
	$("#trigger-template .active-label").html($(this).text());
	var value = $(this).get()[0].getAttribute("value");
	$("#trigger-template .active-label").attr("value", value);
	p.innerHTML = $("#trigger-template").html();
	setupTriggerMenus();
	$('.active-trigger-label').hover(showRemoveButton, hideRemoveButton);
	updateExpr();
	$('select #advanced').attr("selected", "true");
	return true;
}
$(function() {
    options['onSelect'] = addTrigger;
    $('.ortrigger').jeegoocontext('trigger-list', options);
});

function setupTriggerMenus() {
	options['onSelect'] = addTrigger; 
	$('.andtrigger').jeegoocontext('trigger-list-and', options);
	$('.ortrigger').jeegoocontext('trigger-list-or', options);
}