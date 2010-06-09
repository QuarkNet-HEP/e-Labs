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

var hasBeenPlotted = false; 

$(document).ready(function() {
	/* Initialize the initial dropdown list */ 
	subsystemChangeCB(0); 
	sensorChangeCB(0);
	samplingCB(0);
	displayFilename(0);
	initBinding();

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

	$("#parseDropDownAdvanced").bind('click', function() {
		hasBeenPlotted = true; 
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
			dataType: "text",
			data: { startTime: ligoMinTime, endTime: ligoMaxTime, title: title, channels: channels },
			timeout: timeout,
			success: onPlotSaved, 
			error: onPlotError,
			beforeSend: spinnerOn, 
			complete: spinnerOff
		});
		
		function onPlotSaved(data) {
			return;  
		}
		
		function onPlotError(data) {
			return; 
		}
	});
	
	
	
	$("#buttonZoom").click(function() {
		$("#parseDropDownAdvanced").trigger('click');
	});
	
	$("#buttonZoomOut").click(function() {
		xminGPSTime = ligoMinTime;
		xmaxGPSTime = ligoMaxTime;
		$("#xmin").val((new Date(convertTimeGPSToUNIX(parseFloat(xminGPSTime)) * 1000.0)).toDateString()); 
		$("#xmax").val((new Date(convertTimeGPSToUNIX(parseFloat(xmaxGPSTime)) * 1000.0)).toDateString());
		$("#parseDropDownAdvanced").trigger('click');
	});
	
	function getIndex(objName) {
		var tokens = objName.split("_", 2);
		return tokens[1];
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
		
		foo.append(deleteButton).append(siteSelector).append(subsysSelector).append(stationSelector).append(sensorSelector).append(samplingSelector).append(nameLabel).append($("<br id=\"br_" + index + "\" />"));
		subsystemChangeCB(index); 
		sensorChangeCB(index);
		samplingCB(index);
		displayFilename(index);
		initBinding();
	}
	
	$("#addNewRow").click(function() {
		++rows;
		addNewRow(rows);
	});
		
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
			$("#removeRow_" + index).remove();
			$("#site_" + index).remove();
			$("#sensor_" + index).remove();
			$("#sampling_" + index).remove();
			$("#subsystem_" + index).remove();
			$("#station_" + index).remove();
			$("#dataName_" + index).remove();
			$("#br_" + index).remove();
		});
	}
});

