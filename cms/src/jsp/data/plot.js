function isArray(testObject) {   
    return testObject && !(testObject.propertyIsEnumerable('length')) && typeof testObject === 'object' && typeof testObject.length === 'number';
}

function pp(obj) {
	if (isArray(obj)) {
		s = "[";
		for (var i in obj) {
			s += i + ": " + pp(obj[i]) + ", "; 
		}
		s += "]";
		return s;
	}
	else if (obj == null) {
		return null;
	}
	else {
		return obj.toString();
	}
}

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
	document.plots[index] = $.plot($(id + " .placeholder"), {data: []}, options);
	document.animSpeed[index] = 1;
	bindButtons(index);
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
	$(id + " .xlabel").html(stack[0]["labelx"]);
	$(id + " .ylabel").html(stack[0]["labely"]);
	var te = totalEvents(index);
	setCurrentEvent(index, te);
	$(id + " .totalevents").html(te);
	log("plot setup done");
}

function redrawPlot(index, stack) {
	log("redrawing plot " + index);
	var pdata = new Array();
	for (var sp = 0; sp < stack.length; sp++) {
		crt = stack[sp];
		var h = crt["histogram"];
		var dd = new Array();
		var last = 0;
		for (var i = crt["histmin"]; i <= crt["histmax"]; i++) {
			var x = i;
			var y = h[i];
			if (y == null) {
				y = 0;
			}
			dd.push([x - 0.0001, last]);
			dd.push([x, y]);
			dd.push([x + 0.9999, y]);
			last = y;
		}
		var d = {
			shadowSize: 0,
			color: crt["color"],
			label: crt["title"],
			data: dd
		};
		pdata.push(d);
	}
	document.data[index] = pdata;
	redrawPlot2(index, options);
}
	
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
	document.plots[index] = $.plot($("#plot" + index + " .placeholder"), document.data[index],
            $.extend(true, {}, options, {
                xaxis: { transform: tx, inverseTransform: itx },
                yaxis: { transform: ty, inverseTransform: ity }
            }));
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

function parseReply(text) {
	log("received reply: " + text.length + " bytes");
	var plots = new Array();
	var crt = null;
	var data = null;
	var histogram = null;
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
		var value = kv[1];
		switch (kv[0]) {
			case "combine":
				document.combinePlots = value == "true";
				break;
			case "path":
				if (crt != null) {
					crt["eventcount"] = eventCount;
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
				histogram = new Array();
				crt["data"] = data;
				crt["histogram"] = histogram;
				crt["histmin"] = 99999999;
				crt["histmax"] = 0;
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
				crt[kv[0]] = value;
				break; 
			default:
				if (value == null) {
					break;
				}
				eventCount++;
				var s = value.split("\s+");
				var va = new Array();
				data.push([kv[0], va]);
				for (var j = 0; j < s.length; j++) {
					var vf = parseFloat(s[j]);
					va.push(vf);
					var v = Math.floor(vf);
					var count = histogram[v];
					if (count == null) {
						count = 0;
					}
					histogram[v] = ++count;
					if (crt["histmin"] > v) {
						crt["histmin"] = v;
					}
					if (crt["histmax"] < v) {
						crt["histmax"] = v;
					}
				}
		}
	}
	if (crt != null) {
		crt["eventcount"] = eventCount;
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
    		var text = ro.responseText;
    		updatePlots(parseReply(text));
    	}
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
		for (var i = 0; i < steps && event < events; i++) {
			var kv = data[event++];
			if (kv == null) {
				continue;
			}
			var s = kv[1];
			for (var j = 0; j < s.length; j++) {
				var v = Math.floor(s[j]);
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
		var crs = document.getElementById("cursor");
		var crsVal = document.getElementById("cursorValue");
		$(plot + " .cursor").css("left", (pos.pageX + 6) + "px");
		$(plot + " .cursor").css("top", (pos.pageY - 20) + "px");
		$(plot + " .cursorValue").html(Math.round(pos.x * 10) / 10);
	});
	$(plot + " .placeholder").bind("mouseenter", function() {
		$(plot + " .cursor").css("display", "block");
	});
	$(plot + " .placeholder").bind("mouseleave", function() {
		$(plot + " .cursor").css("display", "none");
	});

	$(plot + " .apply-selection").bind("click", function() {
		var r = document.plots[index].getSelection();
		redrawPlot2(index, $.extend(true, {}, options, {
            xaxis: { min: r.xaxis.from, max: r.xaxis.to }
        }));
    	plotUnselected(index);
	});

	$(plot + " .reset-selection").bind("click", function() {
		redrawPlot2(index, options);
		plotUnselected(index);
	});

	$(plot + " .anim-bskip").bind("click", function() {animationBSkip(index)});
	$(plot + " .anim-playpause").bind("click", function() {animationPlayPause(index)});
	$(plot + " .anim-fstep").bind("click", function() {animationFStep(index)});
	$(plot + " .anim-fskip").bind("click", function() {animationFSkip(index)});
	$(plot + " .anim-incspeed").bind("click", function() {animationIncSpeed(index)});
	$(plot + " .anim-decspeed").bind("click", function() {animationDecSpeed(index)});
}