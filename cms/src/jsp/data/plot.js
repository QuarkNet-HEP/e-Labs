function updatePlot(data) {
	redrawPlot(data);
	var crsUnit = document.getElementById("cursorUnit");
	crsUnit.innerHTML = data[0]["units"];
	var crtevent = document.getElementById("crtevent");
	var totalevents = document.getElementById("totalevents");
	document.maxevents = null;
	setCurrentEvent(totalEvents());
	totalevents.innerHTML = totalEvents();
	log("plot setup done");
}

function redrawPlot(data) {
	log("redrawing plot");
	var crt = data[0];
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
	var d = [{
		shadowSize: 0,
		color: data[0]["color"],
		label: data[0]["title"],
		data: dd
	}];
	document.data = d;
	document.plot.setData(d);
	document.plot.setupGrid();
	document.plot.draw();
}

function totalEvents() {
	if (document.maxevents != null) {
		return document.maxevents;
	}
	// just first plot for now
	return document.plotData[0]["data"].length;
	var max = 0;
	for (var i = 0; i < document.plotData.length; i++) {
		if (document.plotData[i]["data"].length > max) {
			max = document.plotData[i]["data"].length;
		}
	}
	document.maxevents = max;
	return max;
}

function parseReply(text) {
	log("received reply: " + text.length + " bytes");
	var plots = new Array();
	var crt = null;
	var data = null;
	var histogram = null;
	var eventCount = 0;
	var lines = text.split('\n');
	for (var i = 0; i < lines.length; i++) {
		var line = jQuery.trim(lines[i]);
		if (line == "") {
			continue;
		}
		var kv = line.split(': ', 2);
		var value = kv[1];
		switch (kv[0]) {
			case "path":
				if (crt != null) {
					crt["eventcount"] = eventCount;
					log(crt["path"] + ": " + (crt["data"].length) + " events, out of which " + eventCount + " are valid, " + crt["histogram"].length + " bins");
					eventCount = 0;
					plots.push(crt);
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
			case "color":
			case "title":
			case "labelx":
			case "labely":
			case "units":
			case "description":
			case "run":
				crt[kv[0]] = value;
				break; 
			default:
				data.push([kv[0], value]);
				if (value == null) {
					break;
				}
				eventCount++;
				var s = value.split("\s+");
				for (var j = 0; j < s.length; j++) {
					var v = Math.floor(parseFloat(s[j]));
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
		plots.push(crt);
	}
	document.plotData = plots;
	return plots;
}

function getData(dataset, runs, plots) {
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
    		updatePlot(parseReply(text));
    	}
    }
    var url = "../data/get-data.jsp?dataset=" + dataset + "&runs=" + runs + "&plots=" + plots;
    log("plot-data: " + url)
    ro.open("get", url);
    ro.onreadystatechange = cb;
    ro.send(null);
}

function enableButton(id) {
	var b = document.getElementById(id);
	b.className = "tbutton";
}

function disableButton(id) {
	var b = document.getElementById(id);
	b.className = "tbutton disabled";
}

function resetHistogram() {
	for (var i = 0; i < document.plotData.length; i++) {
		document.plotData[i].histogram = new Array();
	}
	redrawPlot(document.plotData);
}

function setCurrentEvent(e) {
	var cev = document.getElementById("crtevent");
	cev.innerHTML = e;
	document.currentEvent = e;
}

function animationBSkip() {
	log("bskip");
	enableButton("anim-fskip");
	enableButton("anim-fstep");
	disableButton("anim-bskip");
	setCurrentEvent(0);
	resetHistogram();
}

function animationFSkip() {
	log("fskip");
	disableButton("anim-fskip");
	disableButton("anim-fstep");
	enableButton("anim-bskip");
	log("skipping " + (totalEvents() - document.currentEvent));
	histogramFStep(totalEvents() - document.currentEvent);
	redrawPlot(document.plotData);
}

function setPlayButton(img) {
	var pb = document.getElementById("anim-playpause");
	var im = firstNonTextChild(pb);
	im.src = "../graphics/" + img + ".png";
}

function animationPlayPause() {
	log("playpause");
	if (document.playing) {
		document.playing = false;
		if (currentEvent() < totalEvents()) {
			enableButton("anim-fstep");
		}
		setPlayButton("play");
	}
	else {
		if (document.currentEvent == totalEvents()) {
			animationBSkip();
		}
		document.playing = true;
		disableButton("anim-fstep");
		setPlayButton("pause");
		setTimeout(playStep, speedProfile[document.animSpeed][0]);
	}
}

function playStep() {
	if (document.currentEvent == totalEvents()) {
		animationPlayPause();
	}
	else if (document.playing) {
		animationFStep();
		setTimeout(playStep, speedProfile[document.animSpeed][0]);
	}
}

function currentEvent() {
	return document.currentEvent;
}

function animationFStep() {
	log("fstep");
	histogramFStep(speedProfile[document.animSpeed][1]);
	redrawPlot(document.plotData);
}

function histogramFStep(steps) {
	if (document.currentEvent == 0) {
		enableButton("anim-bskip");
	}
	var data = document.plotData[0]["data"];
	var histogram = document.plotData[0]["histogram"];
	var events = document.plotData[0]["data"].length;
	for (var i = 0; i < steps && document.currentEvent < events; i++) {
		var kv = data[document.currentEvent++];
		if (kv == null) {
			window.alert("null: " + (document.currentEvent - 1));
			continue;
		}
		var s = kv[1].split("\s+");
		for (var j = 0; j < s.length; j++) {
			var v = Math.floor(parseFloat(s[j]));
			var count = histogram[v];
			if (count == null) {
				count = 0;
			}
			histogram[v] = ++count;
		}
	} 
	setCurrentEvent(document.currentEvent);
	if (document.currentEvent == events) {
		disableButton("anim-fskip");
		disableButton("anim-fstep");
	}
}

//[[delay, eventsPerStep]...]
speedProfile = [[], [500, 1], [250, 1], [100, 1], [80, 2], [80, 4], [80, 8], [80, 16], [80, 32], [80, 64]];

function animationIncSpeed() {
	log("incspeed");
	if (document.animSpeed < 9) {
		var se = document.getElementById("crtspeed");
		se.innerHTML = (++document.animSpeed);
	}
}

function animationDecSpeed() {
	log("decspeed");
	if (document.animSpeed > 1) {
		var se = document.getElementById("crtspeed");
		se.innerHTML = (--document.animSpeed);
	}
}