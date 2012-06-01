var channel1data, channel2data, channel3data, channel4data;
	
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

var chanOptions = $.extend({}, options, showSeries, { legend: { noColumns: 4, labelFormatter: seriesLabelFormatter, container: "#channelChartLegend" } });

var defaultOptions = $.extend({}, options, showSeries); 

function seriesLabelFormatter(label, series) {
	var thisLabel = label.replace(" ", "");
	
	/* Temporarily disable checkboxes until I figure out why it fails 
	return "<input id=\"" + thisLabel + "checkbox\" type=\"checkbox\" checked></input>" + label + "&nbsp;&nbsp;&nbsp;";
	*/
	return label + "&nbsp;&nbsp;&nbsp;";
}

function onDataLoad1(json) {	
	// we need channel data to be selectable, so do not discard it 
	channel1data = json.channel1;
	channel2data = json.channel2;
	channel3data = json.channel3;
	channel4data = json.channel4;

	$.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: 'Channel Rate' } ]}));
	$.plot($("#triggerChart"), [json.trigger],$.extend({}, defaultOptions, { yaxes: [ {position: 'left', axisLabel: 'Trigger Rate' } ]}));
	$.plot($("#satChart"), [ json.satellites ],$.extend({}, defaultOptions, { yaxes: [ {position: 'left', axisLabel: json.satellites.ylabel } ]}));
	$.plot($("#voltChart"), [ json.voltage ], $.extend({}, defaultOptions, { yaxes: [ {position: 'left', axisLabel: json.voltage.ylabel + ' (' + json.voltage.unit + ')' } ]}));
	$.plot($("#tempChart"), [ json.temperature], $.extend({}, defaultOptions, { yaxes: [ {position: 'left', axisLabel: json.temperature.ylabel + ' (' + json.temperature.unit + ')' } ]}));
	$.plot($("#pressureChart"), [ json.pressure ], $.extend({}, defaultOptions, { yaxes: [ {position: 'left', axisLabel: json.pressure.ylabel + ' (' + json.pressure.unit + ')' } ]}));

	// attach listener callbacks to checkboxes to hide/unhide
}

function onChannelCheckbox(label) {
	var hiddenSeries = { points: { show: false } };
	var  shownSeries = { points: { show: true  } };

	// parse label, get data ptr 

	// (un)show points

	// replot 
	$.plot($("#channelChart"), [channel1data, channel2data, channel3data, channel4data ], chanOptions );
}

