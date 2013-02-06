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

//EPeronja-01/22/2013: Bug472- function to actually turn series on/off, called from series 'href' -- see seriesLabelFormatter code below
togglePlot = function(seriesIdx)
{
  var plotData = onOffPlot.getData();
  plotData[seriesIdx].points.show = !plotData[seriesIdx].points.show;
  onOffPlot.setData(plotData);
  onOffPlot.draw();
}

//EPeronja-01/23/2013: Bug472- function to redraw the axes based on user input, called from compare1.jsp
redrawPlotX = function(newmax)
{
	channelOptions.xaxis.max = triggerOptions.xaxis.max = satelliteOptions.xaxis.max = voltageOptions.xaxis.max = temperatureOptions.xaxis.max = pressureOptions.xaxis.max = newmax;
	onOffPlot = $.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
	$.plot($("#triggerChart"), [triggerdata],$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: triggerdata.ylabel + ' (' + triggerdata.unit + ')'} ]}));
	$.plot($("#satChart"), [satellitedata],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: satellitedata.ylabel + ' (' + satellitedata.unit + ')'} ]}));
	$.plot($("#voltChart"), [voltagedata],$.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: voltagedata.ylabel + ' (' + voltagedata.unit + ')'} ]}));
	$.plot($("#tempChart"), [temperaturedata],$.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: temperaturedata.ylabel + ' (' + temperaturedata.unit + ')'} ]}));
	$.plot($("#pressureChart"), [pressuredata],$.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: pressuredata.ylabel + ' (' + pressuredata.unit + ')'} ]}));		
}
redrawPlotMinY = function(newmin, chart)
{
	var tempOps;
	switch (chart) {
		case ("channel"):
			channelOptions.yaxis.min = newmin;
			onOffPlot = $.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
	    	break;
		case ("trigger"):
			triggerOptions.yaxis.min = newmin;
			$.plot($("#triggerChart"), [triggerdata],$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: triggerdata.ylabel + ' (' + triggerdata.unit + ')'} ]}));
			break;
		case ("satellite"):
			satelliteOptions.yaxis.min = newmin;
			$.plot($("#satChart"), [satellitedata],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: satellitedata.ylabel + ' (' + satellitedata.unit + ')'} ]}));
		break;
		case ("voltage"):
			voltageOptions.yaxis.min = newmin;
			$.plot($("#voltChart"), [voltagedata],$.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: voltagedata.ylabel + ' (' + voltagedata.unit + ')'} ]}));
		break;
		case ("temperature"):
			temperatureOptions.yaxis.min = newmin;
			$.plot($("#tempChart"), [temperaturedata],$.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: temperaturedata.ylabel + ' (' + temperaturedata.unit + ')'} ]}));
		break;
		case ("pressure"):
			pressureOptions.yaxis.min = newmin;
			$.plot($("#pressureChart"), [pressuredata],$.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: pressuredata.ylabel + ' (' + pressuredata.unit + ')'} ]}));
		break;		
	}
}
redrawPlotMaxY = function(newmax, chart)
{
	var tempOps;
	switch (chart) {
		case ("channel"):
			channelOptions.yaxis.max = newmax;
			onOffPlot = $.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
	    	break;
		case ("trigger"):
			triggerOptions.yaxis.max = newmax;
			$.plot($("#triggerChart"), [triggerdata],$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: triggerdata.ylabel + ' (' + triggerdata.unit + ')'} ]}));
			break;
		case ("satellite"):
			satelliteOptions.yaxis.max = newmax;
			$.plot($("#satChart"), [satellitedata],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: satellitedata.ylabel + ' (' + satellitedata.unit + ')'} ]}));
		break;
		case ("voltage"):
			voltageOptions.yaxis.max = newmax;
			$.plot($("#voltChart"), [voltagedata],$.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: voltagedata.ylabel + ' (' + voltagedata.unit + ')'} ]}));
		break;
		case ("temperature"):
			temperatureOptions.yaxis.max = newmax;
			$.plot($("#tempChart"), [temperaturedata],$.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: temperaturedata.ylabel + ' (' + temperaturedata.unit + ')'} ]}));
		break;
		case ("pressure"):
			pressureOptions.yaxis.max = newmax;
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
	
	onOffPlot = $.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel } ]}));
	$.plot($("#triggerChart"), [json.trigger],$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: json.trigger.ylabel + ' (' + json.trigger.unit + ')'} ]}));
	$.plot($("#satChart"), [ json.satellites ],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: json.satellites.ylabel } ]}));
	$.plot($("#voltChart"), [ json.voltage ], $.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: json.voltage.ylabel + ' (' + json.voltage.unit + ')' } ]}));
	$.plot($("#tempChart"), [ json.temperature], $.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel                         : json.temperature.ylabel + ' (' + json.temperature.unit + ')' } ]}));
	$.plot($("#pressureChart"), [ json.pressure ], $.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: json.pressure.ylabel + ' (' + json.pressure.unit + ')' } ]}));
}
