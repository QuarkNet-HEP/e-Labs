var DMTStations = [ "EX", "EY", "LVEA", "MX", "MY", "VAULT" ];
var PEMStations = DMTStations.concat([ "BSC1", "BSC5", "BSC6", "BSC9", "BSC10", "COIL" ]);
var GDSStations = [ "MONITOR" ];

var PEMMagSensors = [ "MAGX", "MAGY", "MAGZ" ];
var PEMMag1Sensors = [ "MAG1X", "MAG1Y", "MAG1Z "];
var PEMArmSensors = [ "SEISX", "SEISY", "SEISZ", "TILTX", "TILTY", "TILTT", "RAIN", "WIND", "WINDMPH" ];
var PEMVaultSensors = ["SEISX", "SEISY", "SEISZ"];

var DMTSensors = [ 'SEISX_0.03_0.1Hz', 'SEISX_0.1_0.3Hz', 'SEISX_0.3_1Hz', 'SEISX_10_30Hz', 'SEISX_1_3Hz', 'SEISX_3_10Hz',
                   'SEISY_0.03_0.1Hz', 'SEISY_0.1_0.3Hz', 'SEISY_0.3_1Hz', 'SEISY_10_30Hz', 'SEISY_1_3Hz', 'SEISY_3_10Hz',
                   'SEISZ_0.03_0.1Hz', 'SEISZ_0.1_0.3Hz', 'SEISZ_0.3_1Hz', 'SEISZ_10_30Hz', 'SEISZ_1_3Hz', 'SEISZ_3_10Hz']; 

var GDSSensors = [ 'EARTHQUAKE' ];

var DMTPrefix = "";

/* For filtered data, rms == mean */ 
var DMTSampling = [ "rms"];
var Sampling = [ "rms", "mean"];

var data = { };

var rows = 0; 

var logCheckedY = false; 

function samplingCB(index) {
	var ptr = null; 
	
	switch($("#subsystem_" + index + " :selected").text()) {
	case "DMT": 
		ptr = DMTSampling;
		break;
	case "PEM":
	case "GDS": 
		ptr = Sampling;
		break;
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
	
	switch($("#subsystem_" + index + " :selected").text()) {
	case "DMT":
		ptr = DMTSensors;
		break;
	case "PEM":
		switch($("#station_" + index + " :selected").val()) {
		case "EX":
		case "EY":
		case "LVEA":
		case "MX":
		case "MY":
			ptr = PEMArmSensors; 
			break;
		case "VAULT":
			ptr = PEMVaultSensors;
			break;
		case "BSC5":
		case "BSC6": 
		case "BSC9":
		case "BSC10":
		case "COIL":
			ptr = PEMMagSensors;
			break;
		case "BSC1":
			ptr = PEMMag1Sensors;
			break;
		default: 
			return;
		}	
		break; 
	case "GDS":
		ptr = GDSSensors;
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
	 
	switch($("#subsystem_" + index + " :selected").text()) {
	case "DMT": 
		ptr = DMTStations; 
		break;
	case "PEM":
		ptr = PEMStations; 
		break;
	case "GDS":
		ptr = GDSStations; 
		break;
	default: 
		return; 	
	}
	
	$("#station_" + index).children().remove();
	$.each(ptr, function(i, value){
		$("#station_" + index).append($("<option></option>").attr("value", value).text(value));
	}); 
}

function generateFilename(index) { 
	return $("#site_" + index + " :selected").val() + ":" + $("#subsystem_" + index + " :selected").val()  + 
		$("#station_" + index + " :selected").val() + "_" + $("#sensor_" + index + " :selected").val() + "." +
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
	var deleteButton = $("<input></input>").attr("type", "button").attr("id", "removeRow_" + index).attr("value", "-").attr("class", "removeRow");
	
	// Site Dropdown
	var siteSelector = $("<select></select>").attr("name", "site").attr("id", "site_" + index).attr("class", "site");
	siteSelector.append($("<option></option>").attr("value", "H0").text("H0"));
	siteSelector.append($("<option></option>").attr("value", "L0").text("L0"));
	
	// Subsystem Dropdown
	var subsysSelector = $("<select></select>").attr("name", "subsystem").attr("id", "subsystem_" + index).attr("class", "subsystem");
	subsysSelector.append($("<option></option>").attr("value", "DMT-BRMS_PEM_").text("DMT"));
	subsysSelector.append($("<option></option>").attr("value", "PEM-").text("PEM"));
	subsysSelector.append($("<option></option>").attr("value", "GDS-").text("GDS"));
	
	var stationSelector = $("<select></select>").attr("name", "station").attr("id", "station_" + index).attr("class", "station");
	var sensorSelector = $("<select></select>").attr("name", "sensor").attr("id", "sensor_" + index).attr("class", "sensor");
	var samplingSelector = $("<select></select>").attr("name", "sampling").attr("id", "sampling_" + index).attr("class", "sampling");
	var nameLabel = $("<span></span>").attr("id", "dataName_" + index).attr("class", "dataName");
	
	$("#channelTable > tbody:last").append(
		$("<tr></tr>").attr("id", "row_" + index).append(
			$("<td></td>").append(deleteButton)).append(
			$("<td></td>").append(siteSelector)).append(
			$("<td></td>").append(subsysSelector)).append(
			$("<td></td>").append(stationSelector)).append(
			$("<td></td>").append(sensorSelector)).append(
			$("<td></td>").append(samplingSelector)).append(
			$("<td></td>").append(nameLabel))
	)
				
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

function getDataAndPlotCB() {
	var c = "";
	
	$(".dataName").each(function(i){
		c = c + $(this).text() + ","
	});
	
	if (c != "") {
		c = c.substr(0, c.length - 1);
	}

	var url = dataServerUrl + '?fn=getData&channels=' + c + '&startTime=' + xminGPSTime + '&endTime=' + xmaxGPSTime;

	// Get the data via AJAJ call
	$.ajax({ 
		url: url,
		method: 'GET', 
		dataType: 'json',
		timeout: timeout,
		success: onChannelDataReceived,
		beforeSend: spinnerOn,
		complete: spinnerOff
	});

	function onChannelDataReceived(json) { 
		data = json;
		plot = $.plot(placeholder, data, options); 
		logCheckboxCB();
		plot = $.plot(placeholder, data, options);
		
		// We have a plot, therefore let someone save it 
		hasBeenPlotted = true; 
		zoomButtonSet(); 
		$("#savePlotToDisk").removeAttr("disabled");
	}
}

$(document).ready(function() {
	/* Initialize the initial dropdown list */ 
	subsystemChangeCB(0); 
	sensorChangeCB(0);
	samplingCB(0);
	displayFilename(0);
	initBinding();
	
	$(".logCheckbox").bind('click', function() {
		if (data.length > 0) {
			logCheckboxCB();
			plot = $.plot(placeholder, data, options);
		}
	}); 

	$("#savePlotToDisk").bind('click', function() {
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
			}
			else {
				/* Display that something went wrong */ 
			}
			return;  
		}
		
		function onPlotError(data) {
			/* TODO: Implement parsing of error codes in case something goes wrong */ 
			return; 
		}
	});


	$("#buttonZoom").click(function() {
		getDataAndPlotCB();
	});

	$("#buttonZoomOut").click(function() {
		xminGPSTime = ligoMinTime;
		xmaxGPSTime = ligoMaxTime;
		$("#xmin").val((new Date(convertTimeGPSToUNIX(parseFloat(xminGPSTime)) * 1000.0)).toDateString()); 
		$("#xmax").val((new Date(convertTimeGPSToUNIX(parseFloat(xmaxGPSTime)) * 1000.0)).toDateString());
		getDataAndPlotCB(); 
	});
	
	$("#plotButton").bind('click', function() {
		getDataAndPlotCB(); 
	});
	

	$("#addNewRow").click(function() {
		++rows;
		addNewRow(rows);
	});

});