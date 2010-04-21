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

$(document).ready(function() {
	/* Initialize the list */ 
	subsystemChangeCB(); 
	sensorChangeCB();
	samplingCB();
	displayFilename();

	function samplingCB() {
		var ptr = null; 
		
		switch($("#subsystem :selected").text()) {
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
		$("#sampling").children().remove();
		$.each(ptr, function(index, value){
			$("#sampling").append($("<option></option>").attr("value", value).text(value));
		}); 
	}

	function sensorChangeCB() {
		var ptr = null; 
		
		switch($("#subsystem :selected").text()) {
		case "DMT":
			ptr = DMTSensors;
			break;
		case "PEM":
			switch($("#station :selected").val()) {
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
		
		$("#sensor").children().remove();
		$.each(ptr, function(index, value){
			$("#sensor").append($("<option></option>").attr("value", value).text(value));
		}); 
	}

	function subsystemChangeCB() { 
		var ptr = null; 
		 
		switch($("#subsystem :selected").text()) {
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
		
		$("#station").children().remove();
		$.each(ptr, function(index, value){
			$("#station").append($("<option></option>").attr("value", value).text(value));
		}); 
	}

	function generateFilename() { 
		return $("#site :selected").val() + ":" + $("#subsystem :selected").val()  + 
			$("#station :selected").val() + "_" + $("#sensor :selected").val() + "." +
			$("#sampling :selected").val(); 
	}

	function displayFilename() { 
		$("#dataName").text(generateFilename());
	}

	/* Change Station */ 
	$("#subsystem").change(function() {
		subsystemChangeCB(); 
		sensorChangeCB();
		samplingCB();
	});

	/* Change Sensor */ 
	$("#station").change(function() {
		sensorChangeCB(); 
		samplingCB();
	}); 

	$("#site, #subsystem, #station, #sensor, #sampling").change(function() {
		displayFilename(); 
	});
	
	$("#parseDropDownAdvanced").bind('click', function() {
		var c = generateFilename();

		var url = dataServerUrl + '?fn=getData&params=' + c + ',0,' + xminGPSTime + ',' + xmaxGPSTime;

		// Get the data via AJAT call
		$.ajax({ 
			url: url,
			method: 'GET', 
			dataType: 'text',
			timeout: timeout,
			success: onChannelDataReceived,
			beforeSend: spinnerOn,
			complete: spinnerOff
		});

		function onChannelDataReceived(series) { 
			var s = series.split(" ");
			var a = new Array();
			var num = s[0];
			for (var i = 0; i < s.length / 2 - 1; i++) {
				a.push([convertTimeGPSToUNIX(parseFloat(s[i * 2 + 1])) * 1000.0, s[i * 2 + 2]]);
			}
			data = [{data: a, shadowSize: 0}];
			plot = $.plot(placeholder, data, options); 
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
		
});

