var defaultPlotOptions = {
    lines: { show: true, fill: false, lineWidth: 1.2 },
    grid: { hoverable: true, autoHighlight: false },
    points: { show: false },
    legend: { noColumns: 1 },
    xaxis: { tickDecimals: 0 },
    yaxis: { autoscaleMargin: 0.1 },
    y2axis: { autoscaleMargin: 0.1 },
    crosshair: { mode: "x" },
    selection: { mode: "x", color: "yellow" },
    hooks: { bindEvents: [bindEventsHook] }
};

function updatePlots(data) {
	document.plots = new Array();
	document.data = new Array();
	document.animSpeed = new Array();
	document.currentEvent = new Array();
	for (var i = 0; i < data.length; i++) {
		createPlot(i);
		updatePlot(i, data[i]);
	}
}

function createPlot(index) {
	var id = "#plot" + index;
	$("#plot-container").append("<div class=\"plot\" id=\"plot" + index + "\"></div>");
	$(id).html($("#plot-template").html().replace(/animation-panel/g, "animation-panel" + index));
	document.plots[index] = $.plot($(id + " .placeholder"), {data: []}, $.extend(defaultPlotOptions, {index: index}));
	document.animSpeed[index] = 1;
	bindButtons(index);
}

function bindEventsHook(plot, eventHolder) {
	// why here? because doing it directly on the placeholder
	// does not properly behave when the mouse is over the legend
	eventHolder.mouseout(function() {
		var p = "#plot" + plot.getOptions().index;
		$(p + " .cursor").css("display", "none");
	});
	
	eventHolder.mouseenter(function() {
		var p = "#plot" + plot.getOptions().index;
		$(p + " .cursor").css("display", "block");
	});
}

plotUnselected = function(index) {
	$("#plot" + index + " .selection").css("display", "none");
	$("#plot" + index + " .selection").text("none");
	$("#plot" + index + " .apply-selection").attr("disabled", true);
};

function updatePlot(index, stack) {
	redrawPlot(index, stack);
	var id = "#plot" + index;
	$(id + " .cursorUnit").html(stack[0]["units"]);
	$(id + " .xlabel").html(stack[0]["labelx"] + " (" + stack[0]["units"] + ")");
	$(id + " .ylabel").html(stack[0]["labely"]);
	var te = totalEvents(index);
	setCurrentEvent(index, te);
	$(id + " .totalevents").html(te);
	if (stack[0]["maxy"] != null) {
		$(id + " .maxy").val(stack[0]["maxy"]);
	}
	if (stack[0]["logy"] == "true") {
		$(id + " .logy").attr("checked", "true");
	}
	else {
		$(id + " .logy").removeAttr("checked");
	}
	if (stack[0]["logx"] == "true") {
		$(id + " .logx").attr("checked", "true");
	}
	else {
		$(id + " .logx").removeAttr("checked");
	}
	log("plot setup done");
}

function updateInternalPlotString(index) {
	var stack = document.plotData[index];
	var s = "";
	var keys = ["path", "color", "logx", "logy", "maxy", "minx", "maxx", "binwidth"];
	for(var sp = 0; sp < stack.length; sp++) { 
		for(var k in keys) {
			if (stack[sp][keys[k]] != null) {
				s += keys[k] + ":" + stack[sp][keys[k]] + ",";
			}
		}
		s += " ";
	}
	log(index + ": " + s);
	$("#plot" + index + " .plots-input").val(s);
}

/**
 * Recalculates the data and draws the plot
 */
function redrawPlot(index, stack) {
	log("redrawing plot " + index);
	if (stack == null) {
		stack = document.plotData[index];
	}
	log("color: '" + stack[0]["color"] + "'");
	var pdata = new Array();
	for (var sp = 0; sp < stack.length; sp++) {
		crt = stack[sp];
		var h = crt["histogram"];
		var binwidth = getBinWidth(crt);
		var dd = new Array();
		var last = 0;
		for (var i = crt["histmin"]; i <= crt["histmax"]; i++) {
			var x = i * binwidth;
			var y = h[i];
			if (isNaN(y)) {
				y = 0;
			}
			dd.push([x - 0.0001, last]);
			dd.push([x, y]);
			dd.push([x + binwidth - 0.0001, y]);
			last = y;
		}
		var d = {
			shadowSize: 0,
			color: crt["color"],
			label: crt["title"],
			data: dd,
		};
		pdata.push(d);
	}
	document.data[index] = pdata;
	redrawPlot2(index, defaultPlotOptions);
}
	
/**
 * Only redraws the plot with possibly updated parameters
 */
function redrawPlot2(index, options) {
	var tx = null;
	var itx = null;
	var ty = null;
	var ity = null;
	if (document.plotData[index][0]["logx"] == "true") {
		tx = ln;
		itx = exp;
	}
	if (document.plotData[index][0]["logy"] == "true") {
		ty = ln;
		ity = exp;
	}
	var minx = document.plotData[index][0]["minx"];
	var maxx = document.plotData[index][0]["maxx"];
	var maxy = document.plotData[index][0]["maxy"];
	document.plots[index] = $.plot($("#plot" + index + " .placeholder"), document.data[index],
            $.extend(true, {}, options, {
                xaxis: { min: minx, max: maxx, transform: tx, inverseTransform: itx },
                yaxis: { max: maxy, transform: ty, inverseTransform: ity }
            }));
	
	if (typeof $("#plot" + index + " .legendColorBox").jeegoocontext == "function") {
		$("#plot" + index + " .legendColorBox").jeegoocontext("color-list", popupOptions);
	}
	updateInternalPlotString(index);
}

ln = function(v) { return v > 0 ? Math.log(v) : 0; }
exp = function(v) { return Math.exp(v); }
p1 = function(v) { return v + 1; }
m1 = function(v) { return v - 1; }

function totalEvents(index) {
	if (index == null) {
		throw "Null index";
	}
	var max = 0;
	var crt = document.plotData[index];
	for (var i = 0; i < crt.length; i++) {
		if (crt[i]["data"].length > max) {
			max = crt[i]["data"].length;
		}
	}
	return max;
}

/**
 * Recomputes the histogram based on a possibly changed bin width
 * and redraws
 */
function reBin(index) {
	stack = document.plotData[index];
	for (var sp = 0; sp < stack.length; sp++) {
		crt = stack[sp];
		buildHistogram(crt);
	}
	redrawPlot(index, stack);
}

function getBinWidth(crt) {
	var binWidth = parseFloat(crt["binwidth"]);
	if (!binWidth) {
		binWidth = 1.0;//GeV
	}
	return binWidth;
}

/**
 * Since hashes are weird in javascript, use a normal
 * array for the histogram and scale when drawing using the bin width
 */
function buildHistogram(crt) {
	var binWidth = getBinWidth(crt);
	var data = crt["data"];
	var histogram = [];
	var histmin = 999999;
	var histmax = 0;
	for (var i in data) {
		var va = data[i];
		for (var j = 1; j < va.length; j++) {
			var v = Math.floor(va[j] / binWidth);
			while (histogram.length <= v) {
				histogram.push(0);
			}
			var count = histogram[v];
			if (count == null) {
				count = 0;
			}
			histogram[v] = ++count;
			if (histmin > v) {
				histmin = v;
			}
			if (histmax < v) {
				histmax = v;
			}
		}
	}
	crt["histmin"] = histmin;
	crt["histmax"] = histmax;
	crt["histogram"] = histogram;
}

function parseReply(text) {
	log("received reply: " + text.length + " bytes");
	var plots = new Array();
	var crt = null;
	var data = null;
	var eventCount = 0;
	var combined = new Array();
	var index = -1;
	var lines = text.split('\n');
	document.combinePlots = false;
	for (var i = 0; i < lines.length; i++) {
		var line = jQuery.trim(lines[i]);
		if (line == "") {
			continue;
		}
		var kv = line.split(': ', 2);
		var key = kv[0];
		var value = kv[1];
		switch (key) {
			case "combine":
				document.combinePlots = value == "true";
				break;
			case "path":
				if (crt != null) {
					crt["eventcount"] = eventCount;
					buildHistogram(crt);
					log(crt["path"] + ": " + (crt["data"].length) + " events, out of which " + eventCount + " are valid, " + crt["histogram"].length + " bins");
					eventCount = 0;
					if (index == -1) {
						plots.push([crt]);
					}
					else {
						plots[index].push(crt);
					}
				}
				crt = new Array();
				crt["path"] = value;
				data = new Array();
				crt["data"] = data;
				break;
			case "units":
				//this relies on logx logy info appearing in the stream before the units
				index = -1;
				if (document.combinePlots) {
					var v = value + ":" + crt["logx"] + ":" + crt["logy"];
					if (combined[v] != null) {
						log("existing plot with units " + v + " found");
						index = combined[v];
					}
					else {
						log("no existing plot with units " + v + " found");
						combined[v] = plots.length;
					}
				}
			case "color":
			case "title":
			case "labelx":
			case "labely":
			case "description":
			case "logx":
			case "logy":
			case "run":
			case "minx":
			case "maxx":
			case "maxy":
			case "binwidth":
				crt[key] = value;
				break;
			default:
				if (value == null) {
					break;
				}
				eventCount++;
				var s = value.split("\s+");
				var va = new Array(); 
				data.push([key, va]);
				for (var j = 0; j < s.length; j++) {
					var vf = parseFloat(s[j]);
					va.push(vf);
				}
		}
	}
	if (crt != null) {
		crt["eventcount"] = eventCount;
		buildHistogram(crt);
		log(crt["path"] + ": " + (crt["data"].length) + " events, out of which " + eventCount + " are valid, " + crt["histogram"].length + " bins");
		if (index == -1) {
			plots.push([crt]);
		}
		else {
			plots[index].push(crt);
		}
	}
	document.plotData = plots;
	return plots;
}

function getData(dataset, runs, plots, combine) {
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
    		if (ro.status == 200) {
    			var text = ro.responseText;
    			updatePlots(parseReply(text));
    			if (typeof updatingDone == "function") {
    				updatingDone();
    			}
    		}
    		else {
    	    	log("status: " + ro.status);
    	    	log("statusText: " + ro.statusText);
    			if (typeof updatingFailed == "function") {
    				updatingFailed(ro.status, ro.statusText, ro.responseText);
    			}
    		}
    	}
    }
    if (typeof updatingStarted == "function") {
    	updatingStarted();
    }
    var url = "../data/get-data.jsp?dataset=" + dataset + "&runs=" + runs + "&plots=" + plots + "&combine=" + combine;
    log("plot-data: <a href=\"" + url + "\">" + url + "</a>");
    ro.open("get", url);
    ro.onreadystatechange = cb;
    ro.send(null);
}

function enableButton(index, cls) {
	var btn = $("#plot" + index + " ." + cls);
	if (btn.hasClass("disabled")) {
		btn.removeClass("disabled");
	}
}

function disableButton(index, cls) {
	var btn = $("#plot" + index + " ." + cls);
	if (!btn.hasClass("disabled")) {
		btn.addClass("disabled");
	}
}

function resetHistogram(index) {
	for (var i = 0; i < document.plotData[index].length; i++) {
		document.plotData[index][i]["histogram"] = new Array();
	}
	redrawPlot(index, document.plotData);
}

function setCurrentEvent(index, e) {
	$("#plot" + index + " .crtevent").html(e);
	document.currentEvent[index] = e;
}

function animationBSkip(index) {
	log("bskip");
	enableButton(index, "anim-fskip");
	enableButton(index, "anim-fstep");
	disableButton(index, "anim-bskip");
	setCurrentEvent(index, 0);
	resetHistogram(index);
}

function animationFSkip(index) {
	log("fskip");
	disableButton(index, "anim-fskip");
	disableButton(index, "anim-fstep");
	enableButton(index, "anim-bskip");
	log("skipping " + (totalEvents(index) - document.currentEvent[index]));
	histogramFStep(index, totalEvents(index) - document.currentEvent[index]);
	redrawPlot(index, document.plotData[index]);
}

function setPlayButton(index, img) {
	var pb = $("#plot" + index + " .anim-playpause").get()[0];
	var im = firstNonTextChild(pb);
	im.src = "../graphics/" + img + ".png";
}

function animationPlayPause(index) {
	log("playpause");
	if (!document.playing) {
		document.playing = new Array();
	}
	if (document.playing[index]) {
		document.playing[index] = false;
		if (currentEvent(index) < totalEvents(index)) {
			enableButton(index, "anim-fstep");
		}
		setPlayButton(index, "play");
	}
	else {
		if (document.currentEvent[index] == totalEvents(index)) {
			animationBSkip(index);
		}
		document.playing[index] = true;
		disableButton(index, "anim-fstep");
		setPlayButton(index, "pause");
		setTimeout(function() {playStep(index)}, speedProfile[document.animSpeed[index]][0]);
	}
	return false;
}

function playStep(index) {
	if (document.currentEvent[index] == totalEvents(index)) {
		animationPlayPause(index);
	}
	else if (document.playing[index]) {
		animationFStep(index);
		setTimeout(function() {playStep(index)}, speedProfile[document.animSpeed[index]][0]);
	}
}

function currentEvent(index) {
	return document.currentEvent[index];
}

function animationFStep(index) {
	log("fstep");
	histogramFStep(index, speedProfile[document.animSpeed[index]][1]);
	redrawPlot(index, document.plotData[index]);
}

function histogramFStep(index, steps) {
	if (document.currentEvent[index] == 0) {
		enableButton(index, "anim-bskip");
	}
	var stack = document.plotData[index];
	var evmax = 0;
	for (var sp = 0; sp < stack.length; sp++) {
		var event = document.currentEvent[index];
		var pd = stack[sp];
		var data = pd["data"];
		var histogram = pd["histogram"];
		var events = data.length;
		var binWidth = getBinWidth(pd);
		for (var i = 0; i < steps && event < events; i++) {
			var kv = data[event++];
			if (kv == null) {
				continue;
			}
			var s = kv[1];
			for (var j = 0; j < s.length; j++) {
				var v = Math.floor(s[j] / binWidth);
				var count = histogram[v];
				if (count == null) {
					count = 0;
				}
				histogram[v] = ++count;
			}
		}
		if (event > evmax) {
			evmax = event;
		}
	}
	setCurrentEvent(index, evmax);
	if (document.currentEvent[index] == events) {
		disableButton(index, "anim-fskip");
		disableButton(index, "anim-fstep");
	}
}

//[[delay, eventsPerStep]...]
speedProfile = [[], [500, 1], [250, 1], [100, 1], [80, 2], [80, 4], [80, 8], [80, 16], [80, 32], [80, 64]];

function animationIncSpeed(index) {
	log("incspeed");
	var se = $("#plot" + index + " .crtspeed");
	if (document.animSpeed[index] < 9) {
		se.html(++document.animSpeed[index]);
	}
}

function animationDecSpeed(index) {
	log("decspeed");
	var se = $("#plot" + index + " .crtspeed");
	if (document.animSpeed[index] > 1) {
		se.html(--document.animSpeed[index]);
	}
}

function bindButtons(index) {
	var plot = "#plot" + index;
	$(plot + " .placeholder").bind("plotselected", function (event, ranges) {
		$(plot + " .selection").css("display", "block");
		var scale = document.plots[index].getAxes().xaxis.scale;
		var pos = ranges.xaxis.from;
		var client = document.plots[index].getAxes().xaxis.p2c(pos);
		$(plot + " .selection").html(ranges.xaxis.from.toFixed(1) + " - " + ranges.xaxis.to.toFixed(1) 
				+ " " + document.plotData[index][0]["units"]);
		$(plot + " .selection").css("left", (client + 50) + "px");
		$(plot + " .apply-selection").attr("disabled", false);
	});
	
	$(plot + " .placeholder").bind("plotunselected", function() {plotUnselected(index);});
	
	$(plot + " .placeholder").bind("plothover", function(event, pos, item) {
		$(plot + " .cursor").css("left", (pos.pageX + 6) + "px");
		$(plot + " .cursor").css("top", (pos.pageY - 20) + "px");
		$(plot + " .cursorValue").html(Math.round(pos.x * 10) / 10);
	});

	$(plot + " .apply-selection").bind("click", function() {
		var r = document.plots[index].getSelection();
		setAll(document.plotData[index], "minx", r.xaxis.from);
		setAll(document.plotData[index], "maxx", r.xaxis.to);
		redrawPlot2(index, defaultPlotOptions);
    	plotUnselected(index);
	});

	$(plot + " .reset-selection").bind("click", function() {
		setAll(document.plotData[index], "minx", null);
		setAll(document.plotData[index], "maxx", null);
		redrawPlot2(index, defaultPlotOptions);
		plotUnselected(index);
	});
	
	$(plot + " .logx").bind("change", function() {
		setAll(document.plotData[index], "logx", $(this).attr("checked") ? "true" : "false");
		redrawPlot(index);
		plotUnselected(index);
	});
	
	$(plot + " .logy").bind("change", function() {
		setAll(document.plotData[index], "logy", $(this).attr("checked") ? "true" : "false");
		redrawPlot(index);
		plotUnselected(index);
	});
	
	bindTextWithApply(index, "maxy", "apply-maxy", "maxy", redrawPlot, function(x) {return !isNaN(x);});
	bindTextWithApply(index, "binwidth", "apply-binwidth", "binwidth", reBin, function(x) {return !isNaN(x) && x > 0;});

	$(plot + " .anim-bskip").bind("click", function() {animationBSkip(index)});
	$(plot + " .anim-playpause").bind("click", function() {animationPlayPause(index)});
	$(plot + " .anim-fstep").bind("click", function() {animationFStep(index)});
	$(plot + " .anim-fskip").bind("click", function() {animationFSkip(index)});
	$(plot + " .anim-incspeed").bind("click", function() {animationIncSpeed(index)});
	$(plot + " .anim-decspeed").bind("click", function() {animationDecSpeed(index)});
}

function bindTextWithApply(index, textClass, applyClass, propName, callback, isValid) {
	var textSelector = "#plot" + index + " ." + textClass;
	var applySelector = "#plot" + index + " ." + applyClass;
	$(textSelector).bind("keyup", function() {
		// the input doesn't see the results of the keypress 
		// until after this handler is called, at least on chrome
		setTimeout(function() {
			var text = $(textSelector);
			var value = text.attr("value");
			var textval = parseFloat(text.attr("value"));
			if (value == "" && document.plotData[index][0][propName] != null) {
				$(applySelector).removeAttr("disabled");
				$(applySelector).attr("value", "Reset");
				return;
			}
			else {
				$(applySelector).attr("value", "Set");
			}
			if (!isValid(textval)) {
				text.css("color", "red");
				$(applySelector).attr("disabled", true);
			}
			else {
				text.css("color", "black");
				$(applySelector).removeAttr("disabled");
			}
		}, 20);
	});
	
	$(applySelector).bind("click", function() {
		var value = $(textSelector).attr("value");
		var textval = parseFloat(value);
		if (value == "") {
			setAll(document.plotData[index], propName, null); //auto
			$(applySelector).attr("disabled", true);
			$(applySelector).attr("value", "Set");
		}
		else if (!isValid(textval)) {
			return;
		}
		else {
			setAll(document.plotData[index], propName, textval);
		}
		log(propName + ": " + textval);
		callback(index);
		plotUnselected(index);
	});
}

/**
 * When plots are stacked, most of the code here references
 * the first plot in the stack to get various parameters (such as logx). This
 * is because plots are combined before the determination of their compatibility 
 * of units is done. So it's a simplifying assumption.
 * 
 * However, when saving a plot, if only the parameters for the first plot are modified,
 * upon re-plotting them it may result in separate plots. So when things like logx are
 * changed, all plots in the stack should be internally updated.
 */
function setAll(stack, key, value) {
	for (var sp = 0; sp < stack.length; sp++) {
		stack[sp][key] = value;
	}
}

var popupOptions = {
		widthOverflowOffset: 0,
        heightOverflowOffset: 3,
        submenuLeftOffset: -4,
        submenuTopOffset: -5,
        event: 'click',
        onSelect: updateColor
};

function findPlotIndex(el) {
	if (el == null) {
		return -1;
	}
	else if (el.className == "plot") {
		return parseInt(el.id.substring(4));
	}
	else {
		return findPlotIndex(el.parentNode);
	}
}

function updateColor(e, context) {
	var color = $(this).context.getAttribute("value");
	var index = findPlotIndex(context);
	var sp = context.parentNode.rowIndex;
	log("change color for index: " + sp + ", plot: " + index + ", color: " + color);
	document.plotData[index][sp]["color"] = color;
	redrawPlot(index);
}

updatingStarted = function() {
	log("Updating started");
	spinnerOn(".wait-on-data");
}

updatingDone = function() {
	log("Updating done");
	spinnerOff(".wait-on-data");
}

function flotify() {
	var index = 0;
	$(".flotifiable").each(function() {
		log("flotifying " + $(this).attr("src"));
		var src = $(this).attr("src");
		var sp = src.split("?", 2);
		var pels = sp[1].split("&");
		var params = new Array();
		for (var i = 0; i < pels.length; i++) {
			var kv = pels[i].split("=", 2);
			params[kv[0]] = kv[1];
		}
		$(this).replaceWith('<div id="plot-container" class="wait-on-data" style="width: 800px; height: 400px;"></div>');
		getData(params["dataset"], params["runs"], params["plots"], "on");
	});
}

function switchPanel(obj) {
	var vid = obj.id + "-v";
	var v = document.getElementById(vid);
	if (v) {
		var on = v.style.display == "block";
		var img = firstNonTextChild(obj);
		if (on) {
			v.style.display = "none";
			img.src = "../graphics/plus.png";
		}
		else {
			v.style.display = "block";
			img.src = "../graphics/minus.png";
		}
	}
}
