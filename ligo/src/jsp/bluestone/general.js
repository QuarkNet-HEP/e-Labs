var data = []; 
var timeout = 30000; /* Some data takes awhile to load; 30sec should be enough?  */ 
var dataPoints = 1200; 
var dataServerUrl = '/elab/ligo/data/data-server-json.jsp';
var plotViewerURL = "http://www13.i2u2.org/elab/ligo/plots/view.jsp?";
var plot = null; 
var placeholder = null; 

var xminGPSTime;
var xmaxGPSTime; 

var ligoMinTime; 
var ligoMaxTime; 
var ligoMaxRange; 

var options = { 
	lines: {show: true, lineWidth: 1, shadowSize: 0 },
	points: {show: false},
	legend: {show: true},
	xaxis: { mode: 'time'},
	selection: { mode: "x" },
	shadowSize: 0
};

ln = function(v) { return v > 0 ? Math.log(v) : 0; }
exp = function(v) { return Math.exp(v); }

function spinnerOn() {
	$("#busySpinner").css('visibility', 'visible');
}

function spinnerOff() {
	$("#busySpinner").css('visibility', 'hidden');
}

function smallSpinnerOn() {
	$("#busySpinnerSmall").css('visibility', 'visible');
}

function smallSpinnerOff() {
	$("#busySpinnerSmall").css('visibility', 'hidden');
}

function convertTimeGPSToUNIX(x) { 
	// TODO: Make a proper offset, this is off depending on leap seconds
	return x + 315964787.0;
}

function convertTimeUNIXtoGPS(x) {
	return x - 315964787.0;
}

$(document).ready(function() {
	placeholder = $("#chart");
	
	$.plot(placeholder, { }, options);
	//$("#slider").slider();

	$("#resizablecontainer").resizable(); 
	
	// Get maximum timespan to start
	$.ajax({
		url: dataServerUrl + '?fn=getTimeRange', 
		method: 'GET',
		dataType: 'json', 
		timeout: 10000,
		success: onTimeRangeReceived,
		beforeSend: spinnerOn,
		complete: onTimeRangeCompleted
	});
	
	function onTimeRangeReceived(series) {
		xminGPSTime = series.minTime; 
		ligoMinTime = series.minTime; 
		xmaxGPSTime = series.maxTime; 
		ligoMaxTime = series.maxTime; 
		$("#xmin").val((new Date(convertTimeGPSToUNIX(parseFloat(xminGPSTime)) * 1000.0)).toDateString()); 
		$("#xmax").val((new Date(convertTimeGPSToUNIX(parseFloat(xmaxGPSTime)) * 1000.0)).toDateString());
		ligoMaxRange = ligoMaxTime - ligoMinTime; 

		$("#slider").slider( { min: 0, max: 1200, value: 600} ); 
	}

	function onTimeRangeCompleted() {
		spinnerOff();
	}

	placeholder.bind("plotselected", function(event, ranges) {
		xminGPSTime = convertTimeUNIXtoGPS(ranges.xaxis.from / 1000.0); 
		xmaxGPSTime = convertTimeUNIXtoGPS(ranges.xaxis.to / 1000.0); 
		$("#xmin").val((new Date(ranges.xaxis.from)).toDateString()); 
		$("#xmax").val((new Date(ranges.xaxis.to)).toDateString());
	});

	$("#parseDropDown").click(function() {
		var c = $("#channelSelector :selected").val();
		if (c == "placeholder") {
			return;
		}

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

			updateSliderPositionCB(plot); 
			
		}
	});

	$("#resizablecontainer").bind("resizestop", function(event, ui) {
		$("#chart").css('width', ui.size.width - 8);
		$("#chart").css('height', ui.size.height - 8);
		if (plot != null) {
			$.plot(placeholder, data, options);  
		}
		
	});

	function updateSliderPositionCB(plot) {
		$("#slider").css('margin-left', plot.getPlotOffset().left + 'px');
		
		// resize slider
		// remember, x-axis values are in UNIX millis time, not GPS second time! 
		
		// get width of the slider control
		var sliderWidth = $("#slider").width(); 
		var currentViewWidth = (plot.getAxes().xaxis.max - plot.getAxes().xaxis.min) / 1000.0;
		var currentViewWidthMaxRatio = currentViewWidth / ligoMaxRange; 
		var newSliderWidth = parseInt(sliderWidth * currentViewWidthMaxRatio);
		var newSliderOffset = parseInt(newSliderWidth / -2.0);
		$(".ui-slider .ui-slider-handle").css('width', newSliderWidth + 'px'); 
		$(".ui-slider .ui-slider-handle").css('margin-left', newSliderOffset + 'px'); 

		// move position to new place on slider (SHOULD start out centered!) 
		// Slider range is 0-1200
		//var currentViewMiddle = convertTimeUNIXtoGPS((plot.getAxes().xaxis.max - plot.getAxes().xaxis.min) / 2.0);
		var currentXMax = plot.getAxes().xaxis.min/1000.0;
		var currentXMin = plot.getAxes().xaxis.max/1000.0;
		var currentXCenter = (currentXMax + currentXMin) / 2.0; 
		var currentViewPosition = (convertTimeUNIXtoGPS(currentXCenter) - ligoMinTime) / ligoMaxRange * 1200.0;
		 
		// alter slider
		$("#slider").slider("option", "value", currentViewPosition);
	}
});