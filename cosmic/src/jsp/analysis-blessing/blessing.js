/*
 * This code builds the blessing charts using Flot
 * 
 * Edit Peronja: 01/23/2013 - Bug 472: code updates, see below.
 * 
 */

var channel1data, channel2data, channel3data, channel4data;
//EPeronja-01/22/2013: Bug472- this variable is used to toggle series on/off 
var triggerdata, satellitedata, voltagedata, temperaturedata, pressuredata
var onOffPlot = null;
var channelRateXLabel = 'Channel Rate (Hz)';
var originalXMax;
var originalChanYMin, originalChanYMax;
var originalTrigYMin, originalTrigYMax;
var originalSatYMin, originalSatYMax;
var originalVoltYMin, originalVoltYMax;
var originalTempYMin, originalTempYMax;
var originalPressYMin, originalPressYMax;

//EPeronja-01/22/2013: Bug472- function to actually turn series on/off, called from series 'href' -- see seriesLabelFormatter code below
togglePlot = function(seriesIdx)
{
  var plotData = onOffPlot.getData();
  plotData[seriesIdx].points.show = !plotData[seriesIdx].points.show;
  onOffPlot.setData(plotData);
  onOffPlot.draw();
}

//EPeronja-01/23/2013: Bug472- added next functions to redraw the axes based on user input, called from compare1.jsp
redrawPlotX = function(newmax)
{
	chanOptions.xaxis.max = trigOptions.xaxis.max = satOptions.xaxis.max = voltOptions.xaxis.max = tempOptions.xaxis.max = pressOptions.xaxis.max = newmax;
	onOffPlot = $.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
	$.plot($("#triggerChart"), [triggerdata],$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: triggerdata.ylabel + ' (' + triggerdata.unit + ')'} ]}));
	$.plot($("#satChart"), [satellitedata],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: satellitedata.ylabel + ' (' + satellitedata.unit + ')'} ]}));
	$.plot($("#voltChart"), [voltagedata],$.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: voltagedata.ylabel + ' (' + voltagedata.unit + ')'} ]}));
	$.plot($("#tempChart"), [temperaturedata],$.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: temperaturedata.ylabel + ' (' + temperaturedata.unit + ')'} ]}));
	$.plot($("#pressureChart"), [pressuredata],$.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: pressuredata.ylabel + ' (' + pressuredata.unit + ')'} ]}));		
}
resetPlotX = function(objectIdXMax)
{
	var inputObject = document.getElementById(objectIdXMax);
	inputObject.value = "";
	chanOptions.xaxis.max = trigOptions.xaxis.max = satOptions.xaxis.max = voltOptions.xaxis.max = tempOptions.xaxis.max = pressOptions.xaxis.max = originalXMax;
	onOffPlot = $.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
	$.plot($("#triggerChart"), [triggerdata],$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: triggerdata.ylabel + ' (' + triggerdata.unit + ')'} ]}));
	$.plot($("#satChart"), [satellitedata],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: satellitedata.ylabel + ' (' + satellitedata.unit + ')'} ]}));
	$.plot($("#voltChart"), [voltagedata],$.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: voltagedata.ylabel + ' (' + voltagedata.unit + ')'} ]}));
	$.plot($("#tempChart"), [temperaturedata],$.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: temperaturedata.ylabel + ' (' + temperaturedata.unit + ')'} ]}));
	$.plot($("#pressureChart"), [pressuredata],$.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: pressuredata.ylabel + ' (' + pressuredata.unit + ')'} ]}));		
}
redrawPlotY = function(newY, chart, type)
{
	var tempOps;
	switch (chart) {
		case ("channel"):
			if (type == "min") {
				chanOptions.yaxis.min = newY;
			} else {
				chanOptions.yaxis.max = newY;
			}
			onOffPlot = $.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
	    	break;
		case ("trigger"):
			if (type == "min") {
				trigOptions.yaxis.min = newY;
			} else {
				trigOptions.yaxis.max = newY;
			}
			$.plot($("#triggerChart"), [triggerdata],$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: triggerdata.ylabel + ' (' + triggerdata.unit + ')'} ]}));
			break;
		case ("satellite"):
			if (type == "min") {
				satOptions.yaxis.min = newY;
			} else {
				satOptions.yaxis.max = newY;
			}
			$.plot($("#satChart"), [satellitedata],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: satellitedata.ylabel + ' (' + satellitedata.unit + ')'} ]}));
			break;
		case ("voltage"):
			if (type == "min") {			
				voltOptions.yaxis.min = newY;
			} else {
				voltOptions.yaxis.max = newY;
			}
			$.plot($("#voltChart"), [voltagedata],$.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: voltagedata.ylabel + ' (' + voltagedata.unit + ')'} ]}));
			break;
		case ("temperature"):
			if (type == "min") {			
				tempOptions.yaxis.min = newY;
			} else {
				tempOptions.yaxis.max = newY;
			}
			$.plot($("#tempChart"), [temperaturedata],$.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: temperaturedata.ylabel + ' (' + temperaturedata.unit + ')'} ]}));
			break;
		case ("pressure"):
			if (type == "min") {
				presOptions.yaxis.min = newY;
			} else {
				presOptions.yaxis.max = newY;
			}
			$.plot($("#pressureChart"), [pressuredata],$.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: pressuredata.ylabel + ' (' + pressuredata.unit + ')'} ]}));
			break;		
	}
}
resetPlotY = function(objectIdYMin, objectIdYMax)
{
	var inputYMinObject = document.getElementById(objectIdYMin);
	inputYMinObject.value = "";
	var inputYMaxObject = document.getElementById(objectIdYMax);
	inputYMaxObject.value = "";
	
	switch (chart) {
		case ("channel"):
			chanOptions.yaxis.min = originalChanYMin;
			chanOptions.yaxis.max = originalChanYMax;
			onOffPlot = $.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
	    	break;
		case ("trigger"):
			trigOptions.yaxis.min = originalTrigYMin;
			trigOptions.yaxis.max = originalTrigYMax;
			$.plot($("#triggerChart"), [triggerdata],$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: triggerdata.ylabel + ' (' + triggerdata.unit + ')'} ]}));
			break;
		case ("satellite"):
			satOptions.yaxis.min = originalSatYMin;
			satOptions.yaxis.max = originalSatYMax;
			$.plot($("#satChart"), [satellitedata],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: satellitedata.ylabel + ' (' + satellitedata.unit + ')'} ]}));
			break;
		case ("voltage"):
			voltOptions.yaxis.min = originalVoltYMin;
			voltOptions.yaxis.max = originalVoltYMax;
			$.plot($("#voltChart"), [voltagedata],$.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: voltagedata.ylabel + ' (' + voltagedata.unit + ')'} ]}));
			break;
		case ("temperature"):
			tempOptions.yaxis.min = originalTempYMin;
			tempOptions.yaxis.max = originalTempYMax;
			$.plot($("#tempChart"), [temperaturedata],$.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: temperaturedata.ylabel + ' (' + temperaturedata.unit + ')'} ]}));
			break;
		case ("pressure"):
			presOptions.yaxis.min = originalPressYMin;
			presOptions.yaxis.max = originalPressYMax;
			$.plot($("#pressureChart"), [pressuredata],$.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: pressuredata.ylabel + ' (' + pressuredata.unit + ')'} ]}));
		break;		
	}
}

var options = { 
	xaxis: {
		min: 0,
		max: 86400,
		tickSize: 7200 // 2 hours 
	},
	yaxis: {
		labelWidth: 40,
		reserveSpace: true,
	},
	xaxes: [ 
		{ position: 'bottom', axisLabel: 'Seconds since midnight UTC' }
	],
	colors: ["#000000"]
};

var showSeries = { 
	series: {
		lines: {
			show: false 
		},
		points: {
			show: true,
			radius: 0.5
		}
	}
}

var hideSeries = { 
	series: {
		lines: {
			show: false 
		},
		points: {
			show: false,
		}
	}
}

var channelOptions = { 
		xaxis: {
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [ 
			{ position: 'bottom', axisLabel: 'Seconds since midnight UTC' }
		],
		colors: ["#000000"]
	};
var triggerOptions = { 
		xaxis: {
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [ 
			{ position: 'bottom', axisLabel: 'Seconds since midnight UTC' }
		],
		colors: ["#000000"]
	};
var satelliteOptions = { 
		xaxis: {
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [ 
			{ position: 'bottom', axisLabel: 'Seconds since midnight UTC' }
		],
		colors: ["#000000"]
	};
var voltageOptions = { 
		xaxis: {
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [ 
			{ position: 'bottom', axisLabel: 'Seconds since midnight UTC' }
		],
		colors: ["#000000"]
	};
var temperatureOptions = { 
		xaxis: {
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [ 
			{ position: 'bottom', axisLabel: 'Seconds since midnight UTC' }
		],
		colors: ["#000000"]
	};
var pressureOptions = { 
		xaxis: {
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [ 
			{ position: 'bottom', axisLabel: 'Seconds since midnight UTC' }
		],
		colors: ["#000000"]
	};

//EPeronja-01/18/2013: Bug472- removed 'showSeries' since each channel has its own point with symbols
//var chanOptions = $.extend({}, options, { legend: { noColumns: 4, labelFormatter: seriesLabelFormatter, container: "#channelChartLegend" } });
var chanOptions = $.extend({}, channelOptions, { legend: { noColumns: 4, labelFormatter: seriesLabelFormatter, container: "#channelChartLegend" } });
//var defaultOptions = $.extend({}, options, showSeries); 
var trigOptions = $.extend({}, triggerOptions, showSeries);
var satOptions = $.extend({}, satelliteOptions, showSeries);
var voltOptions = $.extend({}, voltageOptions, showSeries);
var tempOptions = $.extend({}, temperatureOptions, showSeries);
var pressOptions = $.extend({}, pressureOptions, showSeries);

//EPeronja-01/18/2013: Bug472- this function returns an href of the series labels so we can toggle them on/off
function seriesLabelFormatter(label, series) {
	var thisLabel = label.replace(" ", "");
	var reference = '<tr><td colspan="8" style="text-align: center;">(Select channels to turn them on/off)</td></tr>';
	if (series.idx == 3)
		{
	 	return '<a href="#" onClick="togglePlot('+series.idx+'); return false;">'+label+'</a>' + reference;
		}
 	return '<a href="#" onClick="togglePlot('+series.idx+'); return false;">'+label+'</a>';
}

function onDataLoad1(json) {	
	// we need channel data to be selectable, so do not discard it 
	channel1data = json.channel1;
	channel2data = json.channel2;
	channel3data = json.channel3;
	channel4data = json.channel4;
	triggerdata = json.trigger;
	satellitedata = json.satellites;
	voltagedata = json.voltage;
	temperaturedata = json.temperature;
	pressuredata = json.pressure;
	originalXMax = chanOptions.xaxes.max;
	originalChanYMin = chanOptions.yaxis.min;
	originalChanYMax = chanOptions.yaxis.max;
	originalTrigYMin = trigOptions.yaxis.min;
	originalTrigYMax = trigOptions.yaxis.max;
	originalSatYMin = satOptions.yaxis.min;
	originalSatYMax = satOptions.yaxis.max;
	originalVoltYMin = voltOptions.yaxis.min;
	originalVoltYMax = voltOptions.yaxis.max;
	originalTempYMin = tempOptions.yaxis.min;
	originalTempYMax = tempOptions.yaxis.max;
	originalPressYMin = pressOptions.yaxis.min;
	originalPressYMax = pressOptions.yaxis.max;
	
	onOffPlot = $.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel } ]}));
	$.plot($("#triggerChart"), [json.trigger],$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: json.trigger.ylabel + ' (' + json.trigger.unit + ')'} ]}));
	$.plot($("#satChart"), [ json.satellites ],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: json.satellites.ylabel } ]}));
	$.plot($("#voltChart"), [ json.voltage ], $.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: json.voltage.ylabel + ' (' + json.voltage.unit + ')' } ]}));
	$.plot($("#tempChart"), [ json.temperature], $.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel                         : json.temperature.ylabel + ' (' + json.temperature.unit + ')' } ]}));
	$.plot($("#pressureChart"), [ json.pressure ], $.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: json.pressure.ylabel + ' (' + json.pressure.unit + ')' } ]}));
}
