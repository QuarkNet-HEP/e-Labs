/*
 * EPeronja-04/15/2013: Made a copy of the original advanced.js
 * 						Need to make changes to work with the current data
 */
var PEMStations = [ "LVEA", "EY", "MX", "VAULT" ];
var DMTStations = [ "LVEA", "EY", "MX", "VAULT" ];

var PEMSensors = ["SEISX", "SEISY", "SEISZ"];
var DMTSensors =  ["SEISX_0.03_0.1Hz", "SEISY_0.03_0.1Hz", "SEISZ_0.03_0.1Hz",
                   "SEISX_0.1_0.3Hz", "SEISY_0.1_0.3Hz", "SEISZ_0.1_0.3Hz",
                   "SEISX_0.3_1Hz", "SEISY_0.3_1Hz", "SEISZ_0.3_1Hz",
                   "SEISX_1_3Hz", "SEISY_1_3Hz", "SEISZ_1_3Hz",
                   "SEISX_3_10Hz", "SEISY_3_10Hz", "SEISZ_3_10Hz",
                   "SEISX_10_30Hz", "SEISY_10_30Hz", "SEISZ_10_30Hz"];

var StationMapping = {
		"LVEA": "CS_SEIS_LVEA",
		"EY": "EY_SEIS_VEA",
		"MX": "MX_SEIS_VEA",
		"VAULT": "VAULT_SEIS_1030X195Y" 
};

var SensorMapping = {
		"LVEA_SEISX": "VERTEX_X_DQ",
		"LVEA_SEISY": "VERTEX_Y_DQ",
		"LVEA_SEISZ": "VERTEX_Z_DQ",
		"EY_SEISX": "FLOOR_X_DQ",
		"EY_SEISY": "FLOOR_Y_DQ",
		"EY_SEISZ": "FLOOR_Z_DQ",
		"MX_SEISX": "FLOOR_X_DQ",
		"MX_SEISY": "FLOOR_Y_DQ",
		"MX_SEISZ": "FLOOR_Z_DQ",
		"VAULT_SEISX": "STS2_X_DQ",
		"VAULT_SEISY": "STS2_Y_DQ",
		"VAULT_SEISZ": "STS2_Z_DQ",
		"LVEA_SEISX_0.03_0.1Hz": "VERTEX_X_BLRMS_30MHZ100",
		"LVEA_SEISY_0.03_0.1Hz": "VERTEX_Y_BLRMS_30MHZ100",
		"LVEA_SEISZ_0.03_0.1Hz": "VERTEX_Z_BLRMS_30MHZ100",
		"LVEA_SEISX_0.1_0.3Hz": "VERTEX_X_BLRMS_100MHZ300",
		"LVEA_SEISY_0.1_0.3Hz": "VERTEX_Y_BLRMS_100MHZ300",
		"LVEA_SEISZ_0.1_0.3Hz": "VERTEX_Z_BLRMS_100MHZ300",
		"LVEA_SEISX_0.3_1Hz": "VERTEX_X_BLRMS_300MHZ1000",
		"LVEA_SEISY_0.3_1Hz": "VERTEX_Y_BLRMS_300MHZ1000",
		"LVEA_SEISZ_0.3_1Hz": "VERTEX_Z_BLRMS_300MHZ1000",
		"LVEA_SEISX_1_3Hz": "VERTEX_X_BLRMS_1HZ3",		
		"LVEA_SEISY_1_3Hz": "VERTEX_Y_BLRMS_1HZ3",		
		"LVEA_SEISZ_1_3Hz": "VERTEX_Z_BLRMS_1HZ3",	
		"LVEA_SEISX_3_10Hz": "VERTEX_X_BLRMS_3HZ10",			
		"LVEA_SEISY_3_10Hz": "VERTEX_Y_BLRMS_3HZ10",			
		"LVEA_SEISZ_3_10Hz": "VERTEX_Z_BLRMS_3HZ10",			
		"LVEA_SEISX_10_30Hz": "VERTEX_X_BLRMS_10HZ30",
		"LVEA_SEISY_10_30Hz": "VERTEX_Y_BLRMS_10HZ30",
		"LVEA_SEISZ_10_30Hz": "VERTEX_Z_BLRMS_10HZ30",

		"EY_SEISX_0.03_0.1Hz": "FLOOR_X_BLRMS_30MHZ100",
		"EY_SEISY_0.03_0.1Hz": "FLOOR_Y_BLRMS_30MHZ100",
		"EY_SEISZ_0.03_0.1Hz": "FLOOR_Z_BLRMS_30MHZ100",
		"EY_SEISX_0.1_0.3Hz": "FLOOR_X_BLRMS_100MHZ300",
		"EY_SEISY_0.1_0.3Hz": "FLOOR_Y_BLRMS_100MHZ300",
		"EY_SEISZ_0.1_0.3Hz": "FLOOR_Z_BLRMS_100MHZ300",
		"EY_SEISX_0.3_1Hz": "FLOOR_X_BLRMS_300MHZ1000",
		"EY_SEISY_0.3_1Hz": "FLOOR_Y_BLRMS_300MHZ1000",
		"EY_SEISZ_0.3_1Hz": "FLOOR_Z_BLRMS_300MHZ1000",
		"EY_SEISX_1_3Hz": "FLOOR_X_BLRMS_1HZ3",		
		"EY_SEISY_1_3Hz": "FLOOR_Y_BLRMS_1HZ3",		
		"EY_SEISZ_1_3Hz": "FLOOR_Z_BLRMS_1HZ3",	
		"EY_SEISX_3_10Hz": "FLOOR_X_BLRMS_3HZ10",			
		"EY_SEISY_3_10Hz": "FLOOR_Y_BLRMS_3HZ10",			
		"EY_SEISZ_3_10Hz": "FLOOR_Z_BLRMS_3HZ10",			
		"EY_SEISX_10_30Hz": "FLOOR_X_BLRMS_10HZ30",
		"EY_SEISY_10_30Hz": "FLOOR_Y_BLRMS_10HZ30",
		"EY_SEISZ_10_30Hz": "FLOOR_Z_BLRMS_10HZ30",

		"MX_SEISX_0.03_0.1Hz": "FLOOR_X_BLRMS_30MHZ100",
		"MX_SEISY_0.03_0.1Hz": "FLOOR_Y_BLRMS_30MHZ100",
		"MX_SEISZ_0.03_0.1Hz": "FLOOR_Z_BLRMS_30MHZ100",
		"MX_SEISX_0.1_0.3Hz": "FLOOR_X_BLRMS_100MHZ300",
		"MX_SEISY_0.1_0.3Hz": "FLOOR_Y_BLRMS_100MHZ300",
		"MX_SEISZ_0.1_0.3Hz": "FLOOR_Z_BLRMS_100MHZ300",
		"MX_SEISX_0.3_1Hz": "FLOOR_X_BLRMS_300MHZ1000",
		"MX_SEISY_0.3_1Hz": "FLOOR_Y_BLRMS_300MHZ1000",
		"MX_SEISZ_0.3_1Hz": "FLOOR_Z_BLRMS_300MHZ1000",
		"MX_SEISX_1_3Hz": "FLOOR_X_BLRMS_1HZ3",		
		"MX_SEISY_1_3Hz": "FLOOR_Y_BLRMS_1HZ3",		
		"MX_SEISZ_1_3Hz": "FLOOR_Z_BLRMS_1HZ3",	
		"MX_SEISX_3_10Hz": "FLOOR_X_BLRMS_3HZ10",			
		"MX_SEISY_3_10Hz": "FLOOR_Y_BLRMS_3HZ10",			
		"MX_SEISZ_3_10Hz": "FLOOR_Z_BLRMS_3HZ10",			
		"MX_SEISX_10_30Hz": "FLOOR_X_BLRMS_10HZ30",
		"MX_SEISY_10_30Hz": "FLOOR_Y_BLRMS_10HZ30",
		"MX_SEISZ_10_30Hz": "FLOOR_Z_BLRMS_10HZ30",
		
		"VAULT_SEISX_0.03_0.1Hz": "STS2_X_BLRMS_30MHZ100",
		"VAULT_SEISY_0.03_0.1Hz": "STS2_Y_BLRMS_30MHZ100",
		"VAULT_SEISZ_0.03_0.1Hz": "STS2_Z_BLRMS_30MHZ100",
		"VAULT_SEISX_0.1_0.3Hz": "STS2_X_BLRMS_100MHZ300",
		"VAULT_SEISY_0.1_0.3Hz": "STS2_Y_BLRMS_100MHZ300",
		"VAULT_SEISZ_0.1_0.3Hz": "STS2_Z_BLRMS_100MHZ300",
		"VAULT_SEISX_0.3_1Hz": "STS2_X_BLRMS_300MHZ1000",
		"VAULT_SEISY_0.3_1Hz": "STS2_Y_BLRMS_300MHZ1000",
		"VAULT_SEISZ_0.3_1Hz": "STS2_Z_BLRMS_300MHZ1000",
		"VAULT_SEISX_1_3Hz": "STS2_X_BLRMS_1HZ3",		
		"VAULT_SEISY_1_3Hz": "STS2_Y_BLRMS_1HZ3",		
		"VAULT_SEISZ_1_3Hz": "STS2_Z_BLRMS_1HZ3",	
		"VAULT_SEISX_3_10Hz": "STS2_X_BLRMS_3HZ10",			
		"VAULT_SEISY_3_10Hz": "STS2_Y_BLRMS_3HZ10",			
		"VAULT_SEISZ_3_10Hz": "STS2_Z_BLRMS_3HZ10",			
		"VAULT_SEISX_10_30Hz": "STS2_X_BLRMS_10HZ30",
		"VAULT_SEISY_10_30Hz": "STS2_Y_BLRMS_10HZ30",
		"VAULT_SEISZ_10_30Hz": "STS2_Z_BLRMS_10HZ30"		
};

/* For filtered data, rms == mean */ 
var DMTSampling = [ "rms"];
var Sampling = [ "rms", "mean"];

var data = { };

var rows = 0; 

var logCheckedY = false;

var lastRangeChange = 0;

function samplingCB(index) {
	var ptr = null; 
	
	switch($("#subsystem_" + index + " :selected").text()) {
	case "PEM":
		ptr = Sampling;
		break;
	case "DMT":
		ptr = Sampling;
	default: 
		return;
	}
	$("#sampling_" + index).children().remove();
	$.each(ptr, function(i, value){
		$("#sampling_" + index).append($("<option></option>").attr("value", value).text(value));
	}); 
}

function sensorChangeCB(index) {
	var ptr = null; 
	console.log("sensor");	 	
	switch($("#subsystem_" + index + " :selected").text()) {
	case "PEM":
		switch($("#station_" + index + " :selected").val()) {
		case "LVEA":
		case "EY":
		case "MX":
		case "VAULT":
			ptr = PEMSensors; 
			break;
		default: 
			return;
		}	
		break; 
	case "DMT":
		switch($("#station_" + index + " :selected").val()) {
		case "LVEA":
		case "EY":
		case "MX":
		case "VAULT":
			ptr = DMTSensors; 
			break;
		default: 
			return;
		}	
		break; 
	default:
		return; 
	}
	
	$("#sensor_" + index).children().remove();
	$.each(ptr, function(i, value){
		$("#sensor_" + index).append($("<option></option>").attr("value", value).text(value));
	}); 
}

function subsystemChangeCB(index) { 
	var ptr = null; 
	console.log("subsystem");	 
	switch($("#subsystem_" + index + " :selected").text()) {
	case "PEM":
		ptr = PEMStations; 
		break;
	case "DMT":
		ptr = DMTStations; 
		break;
	default: 
		return; 	
	}
	
	$("#station_" + index).children().remove();
	$.each(ptr, function(i, value){
		$("#station_" + index).append($("<option></option>").attr("value", value).text(value));
	}); 
}

function parseChannel(name) {
	// H0:DMT-BRMS_PEM_EX_SEISX_0.03_0.1Hz.rms
	name = name.replace("DMT-", "PEM-");
	// H0:DMT_EX_SEISX_0.03_0.1Hz.rms
	console.log(name);
	s = name.split(":");
	site = s[0];
	s = s[1].split("-");
	subsystem = s[0];
	s = s[1].split("_");
	station = s[0];
	rest = s.slice(1).join("_");
	sensor = rest.substr(0, rest.lastIndexOf("."));
	sampling = rest.substr(rest.lastIndexOf(".") + 1);
	
	return {
		site: site,
		subsystem: subsystem,
		station: station,
		sensor: sensor,
		sampling: sampling
	}
}

function generateFilename(index) { 
	var subsystem = $("#subsystem_" + index + " :selected").val();
	var station = $("#station_" + index + " :selected").val();
	var sensor = $("#sensor_" + index + " :selected").val();
	
	//get mappings
	var mappedStation = StationMapping[station];
    var mappedSensor = SensorMapping[station + "_" + sensor];
    
	subsystem = subsystem.replace("DMT-", "PEM-");	
	
	return $("#site_" + index + " :selected").val() + ":" + subsystem + 
			mappedStation + "_" + mappedSensor + "." +
			$("#sampling_" + index + " :selected").val(); 
}

function displayFilename(index) { 
	$("#dataName_" + index).text(generateFilename(index));
}

function logCheckboxCB() {
	logCheckedY = $("#logYcheckbox:checked").val() != null;
	var tx = null;
	var itx = null;
	var ty = null;
	var ity = null;
	
	var tfx = null;
	var tfy = null; 
	
	if (logCheckedY == true) {
		ty = ln;
		ity = exp; 
		if (plot != null && plot.getAxes().yaxis.max - plot.getAxes().yaxis.min > 5) {
			// heuristic so that my log algorithm doesn't crunch small numbers.
			tfy = logTickFormatter;
		}
	}
	
	$.extend(options, { yaxis: {transform: ty, inverseTransform: ity, ticks: tfy } });
}

function yAutoRangeCheckboxCB() {
	yAutoRange = $("#yAutoRangeCheckbox:checked").val() != null;
	
	if (yAutoRange) {
		$("#yRangeMin").attr("disabled", "true");
		$("#yRangeMax").attr("disabled", "true");
		$.extend(options, { yaxis: { min: null, max: null } });
		replot();
		updateAutoRange();
	}
	else {
		$("#yRangeMin").removeAttr("disabled");
		$("#yRangeMax").removeAttr("disabled");
		commitYRangeChangeCB();
	}
}

function isNumeric(v) {
	return (v - 0) == v && v.length > 0;
}

function validateNumericInput(id) {
	var val = $(id).val();
	
	if (isNumeric(val)) {
		$(id).css("background-color", "white");
		return parseInt(val);
	}
	else {
		$(id).css("background-color", "red");
		return null;
	}
}

function replot() {
	if (data.length > 0) {
		plot = $.plot(placeholder, data, options);
	}
}

function commitYRangeChangeCB() {
	var now = new Date().getTime(); 
	if (now - lastRangeChange < 600) {
		return;
	}
	lastRangeChange = now;
	var min = validateNumericInput("#yRangeMin");
	var max = validateNumericInput("#yRangeMax");
	if (min != null && max != null) {
		$.extend(options, { yaxis: { min: min, max: max } });
		replot();
	}
}

function yRangeChangedCB() {
	validateNumericInput("#yRangeMin");
	validateNumericInput("#yRangeMax");
	lastRangeChange = new Date().getTime();
	window.setTimeout(commitYRangeChangeCB, 1000);
}

function updateAutoRange() {
	if (plot != null) {
		$("#yRangeMin").val(plot.getAxes().yaxis.min);
		$("#yRangeMax").val(plot.getAxes().yaxis.max);
	}
}

function getIndex(objName) {
	var tokens = objName.split("_", 2);
	return tokens[1];
}

function logTickFormatter(axis) {
	var axisValues = [];
	// Heuristic from the flot source code
	// var numTicks = 0.3 * Math.sqrt(plot.height()); 
	
	var min = Math.pow(10, Math.floor(Math.log(axis.min == 0 ? 1 : axis.min) / Math.LN10)); 
	var max = Math.pow(10, Math.ceil(Math.log(axis.max) / Math.LN10));
	 
	for (var i = min ; i <= max; i = i * 10) {
		axisValues.push(i);
	}
	
	return axisValues; 
}

function addNewRow(index) {
	var foo = $("#channel-list-advanced");
	// Delete button
	var deleteButton = 
		$("<button></button>").attr("id", "removeRow_" + index).attr("value", "Remove This Row").attr("class", "removeRow").
			append($("<img></img>").attr("src", "../graphics/minus.png"));
	
	// Site Dropdown
	var siteSelector = $("<select></select>").attr("name", "site").attr("id", "site_" + index).attr("class", "site");
	siteSelector.append($("<option></option>").attr("value", "H1").text("H0"));
	siteSelector.append($("<option></option>").attr("value", "L1").text("L0"));
	
	// Subsystem Dropdown
	var subsysSelector = $("<select></select>").attr("name", "subsystem").attr("id", "subsystem_" + index).attr("class", "subsystem");
	subsysSelector.append($("<option></option>").attr("value", "PEM-").text("PEM"));
	
	var stationSelector = $("<select></select>").attr("name", "station").attr("id", "station_" + index).attr("class", "station");
	var sensorSelector = $("<select></select>").attr("name", "sensor").attr("id", "sensor_" + index).attr("class", "sensor");
	var samplingSelector = $("<select></select>").attr("name", "sampling").attr("id", "sampling_" + index).attr("class", "sampling");
	var nameLabel = $("<span></span>").attr("id", "dataName_" + index).attr("class", "dataName");
	
	$
	$("#channelTable tr").last().before(
		$("<tr></tr>").attr("id", "row_" + index).append(
			$("<td></td>").append(deleteButton)).append(
			$("<td></td>").append(siteSelector)).append(
			$("<td></td>").append(subsysSelector)).append(
			$("<td></td>").append(stationSelector)).append(
			$("<td></td>").append(sensorSelector)).append(
			$("<td></td>").append(samplingSelector)).append(
			$("<td></td>").append(nameLabel))
	)
	console.log("addnewrow");
	subsystemChangeCB(index); 
	sensorChangeCB(index);
	samplingCB(index);
	displayFilename(index);
	initBinding();
}

function initBinding() {
	/* Change Station */ 
	$(".subsystem").change(function() {
		var index = getIndex($(this).attr('id'));
		console.log("initBinding " + index);
		subsystemChangeCB(index); 
		sensorChangeCB(index);
		samplingCB(index);
		displayFilename(index);
	});

	/* Change Sensor */ 
	$(".station").change(function() {
		var index = getIndex($(this).attr('id'));
		sensorChangeCB(index); 
		samplingCB(index);
		displayFilename(index);
	}); 

	$(".site, .sensor, .sampling").change(function() {
		var index = getIndex($(this).attr('id'));
		displayFilename(index);
	});
	
	$(".removeRow").click(function() {
		var index = getIndex($(this).attr('id'));
		/* delete stuff - should probably switch to simply assigning each row element a class index rather
		   than appending to ID. Oops. */
		$("#row_" + index).empty().remove();
	});
}

function getDataURL() {
	var c = "";
	
	$(".dataName").each(function(i){
		c = c + $(this).text() + ","
	});
	
	if (c != "") {
		c = c.substr(0, c.length - 1);
	}
	
	$("#xmin").val((new Date(convertTimeGPSToUNIX(parseFloat(xminGPSTime)) * 1000.0)).toDateString()); 
	$("#xmax").val((new Date(convertTimeGPSToUNIX(parseFloat(xmaxGPSTime)) * 1000.0)).toDateString());

	return dataServerUrl + '?fn=getData&channels=' + c + '&startTime=' + xminGPSTime + '&endTime=' + xmaxGPSTime;
}

function getAllDataURL() {
	var c = "";
	
	$(".dataName").each(function(i){
		c = c + $(this).text() + ","
	});
	
	if (c != "") {
		c = c.substr(0, c.length - 1);
	}

	return dataServerUrl + '?fn=getData&channels=' + c + '&startTime=730922400.0&endTime=967165200.0';
}

function overrideYLabel(channel, unit) {
	c = parseChannel(channel);
	
	switch (subsystem) {
		case "PEM":
			switch (sensor) {
				case "SEISX":
				case "SEISY":
				case "SEISZ":
					return "Signal (volts)";
				default:
					return unit;
			}
		default:
			return unit;
	}
}

function getDataAndPlotCB() {
	var url = getDataURL();
	var messages = document.getElementById("messages");
	messages.innerHTML = "";
	// Get the data via AJAX call
	$.ajax({ 
		url: url,
		method: 'GET', 
		dataType: 'json',
		timeout: timeout,
		success: onChannelDataReceived,
		beforeSend: spinnerOn,
		complete: spinnerOff,
	});

	function onChannelDataReceived(json) { 
		data = json;
		if (data[0]) {
			$("#yAxisLabel").html(overrideYLabel(data[0].channel, data[0].unit).replace(" ", "&nbsp;")); 
			plot = $.plot(placeholder, data, options); 
			logCheckboxCB();
			plot = $.plot(placeholder, data, options);
		
			// We have a plot, therefore let someone save it 
			hasBeenPlotted = true; 
			zoomButtonSet(); 
			$("#savePlotToDisk").removeAttr("disabled");
			updateAutoRange();
		} else {
			var messages = document.getElementById("messages");
			messages.innerHTML = " No data to plot";
		}
	}
}

function openSaveDialog() {
	centerElement("save-dialog");
	$("#save-dialog").show();
}

function closeSaveDialog() {
	$("#save-dialog").hide();
}

function userPlotTitleChangedCB() {
	if ($("#userPlotTitle").val() != "") {
		$("#savePlotToDiskCommit").removeAttr("disabled");
	}
	else {
		$("#savePlotToDiskCommit").attr("disabled", "true");
	}
}

function exportData() {	
	var url = getDataURL() + "&format=text";
	window.open(url);
}

function exportAllData() {
	var url = getAllDataURL() + "&format=text";
	window.open(url);
}
$(document).ready(function() {
	/* Initialize the initial dropdown list */ 
	console.log("readyfunction");
	subsystemChangeCB(0);
	sensorChangeCB(0);
	samplingCB(0);
	displayFilename(0);
	initBinding();
	
	$(".logCheckbox").bind('click', function() {
		logCheckboxCB();
		replot();
	});
	
	$("#savePlotToDisk").bind('click', function() {
		openSaveDialog();
	});
	
	$("#savePlotToDiskCancel").bind('click', function() {
		closeSaveDialog();
	});
	
	$("#exportData").bind("click", function() {
		exportData();
	});
	
	//EPeronja-04/01/2013: Ligo request: to export all data rather than the plotted data
	$("#exportAllData").bind("click", function() {
		exportAllData();
	});

	$("#savePlotToDiskCommit").bind('click', function() {
		// need start, end, channels, title 
		var title = $("#userPlotTitle").val(); 
		var channelArray = []; 
		$(".dataName").each(function(index) {
			channelArray.push($(this).text());
		});
		var channels = channelArray.join(",");
		$.ajax({
			url: "savechart.jsp", 
			type: "GET",
			dataType: "json",
			data: { startTime: xminGPSTime, endTime: xmaxGPSTime, title: title, channels: channels, logScale: logCheckedY },
			timeout: timeout,
			success: onPlotSaved, 
			error: onPlotError,
			beforeSend: smallSpinnerOn, 
			complete: smallSpinnerOff
		});
		
		function onPlotSaved(json) {
			/* TODO: Implement parsing of correct result codes 
			 * Probably should get the filename back and a link so the user can
			 * see it without resorting to going to the plot-search page */ 
			
			if (json.success == true) {
				$("#savedPlotLink").attr("href", plotViewerURL + "?filename=" + json.filename);
				$("#savedPlotLink").show();
				closeSaveDialog();
			}
			else {
				/* Display that something went wrong */
			}
			return;  
		}
		
		function onPlotError(data) {
			/* TODO: Implement parsing of error codes in case something goes wrong */
			window.alert("Saving failed: " + data.statusText);
			return; 
		}
	});


	$("#buttonZoom").click(function() {
		$("#buttonZoom").attr("disabled", "true");
	});

	$("#buttonZoomOut").click(function() {
		xminGPSTime = ligoMinTime;
		xmaxGPSTime = ligoMaxTime;
		$("#xmin").val((new Date(convertTimeGPSToUNIX(parseFloat(xminGPSTime)) * 1000.0)).toDateString()); 
		$("#xmax").val((new Date(convertTimeGPSToUNIX(parseFloat(xmaxGPSTime)) * 1000.0)).toDateString());
	});
	
	$(".plotButton").bind('click', function() {
		getDataAndPlotCB(); 
	});
	

	$("#addNewRow").click(function() {
		++rows;
		addNewRow(rows);
	});
	
	$("#yAutoRangeCheckbox").bind("click", yAutoRangeCheckboxCB);
	
	$("#yRangeMin").keyup(yRangeChangedCB);
	$("#yRangeMax").keyup(yRangeChangedCB);
	
	$("#userPlotTitle").keyup(userPlotTitleChangedCB);
});