/*
 * This code builds the blessing charts using Flot
 * 
 * Edit Peronja: 01/23/2013 - Bug 472: code updates, see below.
 * 
 */
var data = []; //data that will be sent to the chart
var trigger = [];
var satellite = [];
var voltage = [];
var temperature = [];
var pressure = [];

var channel1data, channel2data, channel3data, channel4data;
var benchmarkChannel1data, benchmarkChannel2data, benchmarkChannel3data, benchmarkChannel4data, benchmarkTriggerdata;
var channel1LowerError, channel1UpperError;
var channel2LowerError, channel2UpperError;
var channel3LowerError, channel3UpperError;
var channel4LowerError, channel4UpperError;
var triggerLowerError, triggerUpperError;
//EPeronja-01/22/2013: Bug472- this variable is used to toggle series on/off 
var triggerdata, satellitedata, voltagedata, temperaturedata, pressuredata;
var onOffPlot = null;
var trigPlot = null;
var satPlot = null;
var voltPlot = null;
var tempPlot = null;
var pressPlot = null;
var channelRateXLabel = "";
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
  writeLegend(onOffPlot.getCanvas(), "Channel Rate (Hz)", 325, 250);
}

//EPeronja-01/23/2013: Bug472- added next functions to redraw the axes based on user input, called from compare1.jsp
redrawPlotX = function(newX, type)
{
	if (type == "min") {
		chanOptions.xaxis.min = trigOptions.xaxis.min = satOptions.xaxis.min = voltOptions.xaxis.min = tempOptions.xaxis.min = pressOptions.xaxis.min = newX;
	} else {
		chanOptions.xaxis.max = trigOptions.xaxis.max = satOptions.xaxis.max = voltOptions.xaxis.max = tempOptions.xaxis.max = pressOptions.xaxis.max = newX;
	}
	onOffPlot = $.plot($("#channelChart"), data, $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
	trigPlot = $.plot($("#triggerChart"), trigger,$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
	satPlot = $.plot($("#satChart"), [ satellitedata ],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	voltPlot = $.plot($("#voltChart"), [ voltagedata ], $.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	tempPlot = $.plot($("#tempChart"), [ temperaturedata ], $.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	pressPlot = $.plot($("#pressureChart"), [ pressuredata ], $.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	writeLegends();
}

resetPlotX = function(objectIdXMin, objectIdXMax)
{
	var inputObjectMin = document.getElementById(objectIdXMin);
	inputObjectMin.value = "";
	var inputObjectMax = document.getElementById(objectIdXMax);
	inputObjectMax.value = "";
	chanOptions.xaxis.min = trigOptions.xaxis.min = satOptions.xaxis.min = voltOptions.xaxis.min = tempOptions.xaxis.min = pressOptions.xaxis.min = 0;
	chanOptions.xaxis.max = trigOptions.xaxis.max = satOptions.xaxis.max = voltOptions.xaxis.max = tempOptions.xaxis.max = pressOptions.xaxis.max = 86400;
	onOffPlot = $.plot($("#channelChart"), data, $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
	trigPlot = $.plot($("#triggerChart"), trigger,$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
	satPlot = $.plot($("#satChart"), [ satellitedata ],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	voltPlot = $.plot($("#voltChart"), [ voltagedata ], $.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	tempPlot = $.plot($("#tempChart"), [ temperaturedata ], $.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	pressPlot = $.plot($("#pressureChart"), [ pressuredata ], $.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	writeLegends();
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
			onOffPlot = $.plot($("#channelChart"), data, $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
			writeLegend(onOffPlot.getCanvas(), "Channel Rate (Hz)", 325, 250);
			break;
		case ("trigger"):
			if (type == "min") {
				trigOptions.yaxis.min = newY;
			} else {
				trigOptions.yaxis.max = newY;
			}
			trigPlot = $.plot($("#triggerChart"), trigger,$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(trigPlot.getCanvas(), "Trigger Rate (Hz)", 325, 250);
			break;
		case ("satellite"):
			if (type == "min") {
				satOptions.yaxis.min = newY;
			} else {
				satOptions.yaxis.max = newY;
			}
			satPlot = $.plot($("#satChart"), [satellitedata],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(satPlot.getCanvas(), "# Satellites in view", 325, 250);
			break;
		case ("voltage"):
			if (type == "min") {
				voltOptions.yaxis.min = newY;
			} else {
				voltOptions.yaxis.max = newY;
			}
			voltPlot = $.plot($("#voltChart"), [voltagedata],$.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(voltPlot.getCanvas(), "Vcc (Volts)", 325, 250);
			break;
		case ("temperature"):
			if (type == "min") {
				tempOptions.yaxis.min = newY;
			} else {
				tempOptions.yaxis.max = newY;
			}
			tempPlot = $.plot($("#tempChart"), [temperaturedata],$.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(tempPlot.getCanvas(), "Temperature (\u00b0 C)", 325, 250);
			break;
		case ("pressure"):
			if (type == "min") {
				pressOptions.yaxis.min = newY;
			} else {
				pressOptions.yaxis.max = newY;
			}
			pressPlot = $.plot($("#pressureChart"), [pressuredata],$.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(pressPlot.getCanvas(), "Pressure (mb)", 325, 250);
			break;
	}
}

resetPlotY = function(chart, objectIdYMin, objectIdYMax)
{
	var inputYMinObject = document.getElementById(objectIdYMin);
	inputYMinObject.value = "";
	var inputYMaxObject = document.getElementById(objectIdYMax);
	inputYMaxObject.value = "";

	switch (chart) {
		case ("channel"):
			chanOptions.yaxis.min = originalChanYMin;
			chanOptions.yaxis.max = originalChanYMax;
			onOffPlot = $.plot($("#channelChart"), data, $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
			writeLegend(onOffPlot.getCanvas(), "Channel Rate (Hz)", 325, 250);
	    	break;
		case ("trigger"):
			trigOptions.yaxis.min = originalTrigYMin;
			trigOptions.yaxis.max = originalTrigYMax;
			trigPlot = $.plot($("#triggerChart"), trigger,$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(trigPlot.getCanvas(), "Trigger Rate (Hz)", 325, 250);
			break;
		case ("satellite"):
			satOptions.yaxis.min = originalSatYMin;
			satOptions.yaxis.max = originalSatYMax;
			satPlot = $.plot($("#satChart"), [satellitedata],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(satPlot.getCanvas(), "# Satellites in view", 325, 250);
			break;
		case ("voltage"):
			voltOptions.yaxis.min = originalVoltYMin;
			voltOptions.yaxis.max = originalVoltYMax;
			voltPlot = $.plot($("#voltChart"), [voltagedata],$.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(voltPlot.getCanvas(), "Vcc (Volts)", 325, 250);
			break;
		case ("temperature"):
			tempOptions.yaxis.min = originalTempYMin;
			tempOptions.yaxis.max = originalTempYMax;
			tempPlot = $.plot($("#tempChart"), [temperaturedata],$.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(tempPlot.getCanvas(), "Temperature (\u00b0 C)", 325, 250);
			break;
		case ("pressure"):
			pressOptions.yaxis.min = originalPressYMin;
			pressOptions.yaxis.max = originalPressYMax;
			pressPlot = $.plot($("#pressureChart"), [pressuredata],$.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(pressPlot.getCanvas(), "Pressure (mb)", 325, 250);
			break;
	}
}

var options = {
	xaxis: {
		labelHeight: 20,
		min: 0,
		max: 86400,
		tickSize: 7200 // 2 hours 
	},
	yaxis: {
		labelWidth: 40,
		reserveSpace: true,
	},
	xaxes: [
		{ position: 'bottom' }
	],
	yaxes: {
		axisLabelUseCanvas: true
	},
	xaxes: {
		axisLabelUseCanvas: true
	},
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
			labelHeight: 20,
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [
			{ position: 'bottom' }
		],
		colors: ["#000000"]
	};

var triggerOptions = {
		xaxis: {
			labelHeight: 20,
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [
			{ position: 'bottom' }
		],
		colors: ["#000000"]
	};

var benchmarkOptions = {
		xaxis: {
			labelHeight: 20,
			min: 0,
			max: 86400,
			tickSize: 21600 // 6 hours 
		},
		yaxis: {
			min: 0,
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [
			{ position: 'bottom' }
		],
		colors: ["#000000"]
	};

var benchmarkTriggerOptions = {
		xaxis: {
			labelHeight: 20,
			min: 0,
			max: 86400,
			tickSize: 21600 // 2 hours 
		},
		yaxis: {
			min: 0,
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [
			{ position: 'bottom' }
		],
		colors: ["#000000"]
	};

var satelliteOptions = {
		xaxis: {
			labelHeight: 20,
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [
			{ position: 'bottom'//, axisLabel: 'Seconds since midnight UTC' }
			}
		],
		colors: ["#000000"]
	};

var voltageOptions = {
		xaxis: {
			labelHeight: 20,
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [
			{ position: 'bottom' }
		],
		colors: ["#000000"]
	};
var temperatureOptions = {
		xaxis: {
			labelHeight: 20,
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [
			{ position: 'bottom' }
		],
		colors: ["#000000"]
	};
var pressureOptions = {
		xaxis: {
			labelHeight: 20,
			min: 0,
			max: 86400,
			tickSize: 7200 // 2 hours 
		},
		yaxis: {
			labelWidth: 40,
			reserveSpace: true,
		},
		xaxes: [
			{ position: 'bottom' }
		],
		colors: ["#000000"]
	};

//EPeronja-01/18/2013: Bug472- removed 'showSeries' since each channel has its own point with symbols
var chanOptions = $.extend({}, channelOptions, { legend: { noColumns: 4, labelFormatter: seriesLabelFormatter, container: "#channelChartLegend" } });
var trigOptions = $.extend({}, triggerOptions, showSeries);
var benchmarkChanOptions = $.extend({}, channelOptions, { legend: { noColumns: 4, labelFormatter: seriesLabelFormatter, container: "#benchmarkChannelChartLegend" } });
var benchmarkOptions = $.extend({}, benchmarkOptions, { legend: {show:false}});
var benchmarkTrigOptions = $.extend({}, benchmarkTriggerOptions, { legend: {show:false}});
var satOptions = $.extend({}, satelliteOptions, showSeries);
var voltOptions = $.extend({}, voltageOptions, showSeries);
var tempOptions = $.extend({}, temperatureOptions, showSeries);
var pressOptions = $.extend({}, pressureOptions, showSeries);

//EPeronja-01/18/2013: Bug472- this function returns an href of the series labels so we can toggle them on/off
function seriesLabelFormatter(label, series) {
	var thisLabel = label.replace(" ", "");
	var reference = '<tr><td colspan="8" style="text-align: center;">(Select channels to turn them on/off)</td></tr>';
	if (series.idx == (data.length - 1)) {
		return '<a href="#" onClick="togglePlot('+series.idx+'); return false;">'+label+'</a>' + reference;
	} else {
		return '<a href="#" onClick="togglePlot('+series.idx+'); return false;">'+label+'</a>';
	}
}

function writeLegend(canvas, ymessage, width, height) {
	var context = canvas.getContext('2d');
	context.lineWidth=3;
	context.fillStyle="#000000";
	context.lineStyle="#ffff00";
	context.font="16 px sans-serif";
	context.textAlign = 'Seconds since midnight UTC';
	/*context.fillText('Seconds since midnight UTC', width, height);*/
	context.save();
	context.translate(0, 150);
	context.rotate(-Math.PI / 2);
	context.textAlign = ymessage;
	context.fillText(ymessage, 0, 10);
	context.restore();
}//end of writeLegend

function writeLegends() {
	writeLegend(onOffPlot.getCanvas(), "Channel Rate (Hz)", 325, 250);
	writeLegend(trigPlot.getCanvas(), "Trigger Rate (Hz)", 325, 250);
	writeLegend(satPlot.getCanvas(), "# Satellites in view", 325, 250);
	writeLegend(voltPlot.getCanvas(), "Vcc (Volts)", 325, 250);
	writeLegend(tempPlot.getCanvas(), "Temperature (\u00b0 C)", 325, 250);
	writeLegend(pressPlot.getCanvas(), "Pressure (mb)", 325, 250);
}//end of writeLegends

function writeLegends2() {
	writeLegend(onOffPlot.getCanvas(), "Channel Rate (Hz)", 225, 200);
	writeLegend(trigPlot.getCanvas(), "Trigger Rate (Hz)", 225, 200);
}//end of writeLegends2


function onDataLoad1(json) {
	// we need channel data to be selectable, so do not discard it 
	channel1data = json.channel1;
	channel2data = json.channel2;
	channel3data = json.channel3;
	channel4data = json.channel4;
	triggerdata = json.trigger;
    benchmarkChannel1data = json.benchmarkChannel1;
	benchmarkChannel2data = json.benchmarkChannel2;
	benchmarkChannel3data = json.benchmarkChannel3;
	benchmarkChannel4data = json.benchmarkChannel4;
	benchmarkTriggerdata = json.benchmarkTrigger;
	data = [];
	data.push(channel1data);
	data.push(channel2data);
	data.push(channel3data);
	data.push(channel4data);
	if (json.isBenchmarked) {
		data.push(benchmarkChannel1data);
		data.push(benchmarkChannel2data);
		data.push(benchmarkChannel3data);
		data.push(benchmarkChannel4data);
	}
	trigger = [];
	trigger.push(json.trigger);
	if (json.isBenchmarked) {
		trigger.push(benchmarkTriggerdata);
	}
	satellitedata = json.satellites;
	voltagedata = json.voltage;
	temperaturedata = json.temperature;
	pressuredata = json.pressure;
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

	onOffPlot = $.plot($("#channelChart"), data, $.extend({}, chanOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel } ]}));
	trigPlot = $.plot($("#triggerChart"), trigger ,$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
	satPlot = $.plot($("#satChart"), [ json.satellites ],$.extend({}, satOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	voltPlot = $.plot($("#voltChart"), [ json.voltage ], $.extend({}, voltOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	tempPlot = $.plot($("#tempChart"), [ json.temperature], $.extend({}, tempOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	pressPlot = $.plot($("#pressureChart"), [ json.pressure ], $.extend({}, pressOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	writeLegends();
}

//EPeronja-07/31/2013 570-Bless Charts: add option to save them as plots
function saveChart(plot_to_save, name_id, div_id) {
	var filename = document.getElementById(name_id);
	var rc = true;
	if (filename != null) {
		if (filename.value != "") {
			var canvas = plot_to_save.getCanvas();
			var image = canvas.toDataURL("image/png");
			image = image.replace('data:image/png;base64,', '');

			$.ajax({
				url: "savecharts.jsp",
				type: 'POST',
				data: { imagedata: image, filename: filename.value },
				success: function (response) {
					var msgDiv = document.getElementById(div_id);
					if (msgDiv != null) {
						msgDiv.innerHTML = '<a href="'+response+'">' +filename.value +'</a> file created successfully.';
					}
				}
			});

		} else {
			rc = false;
		}

	} else {
		rc = false;
	}
    if (rc == false) {
		var msgDiv = document.getElementById(div_id);
		if (msgDiv != null) {
			msgDiv.innerHTML = "<i>* Please enter a file name</i>";
		}
    }
    return rc;
}

function onDataLoad2(json) {
	// we need channel data to be selectable, so do not discard it 
	channel1data = json.channel1;
	channel2data = json.channel2;
	channel3data = json.channel3;
	channel4data = json.channel4;
	data = [];
	data.push(channel1data);
	data.push(channel2data);
	data.push(channel3data);
	data.push(channel4data);
	triggerdata = json.trigger;
	trigger = [];
	trigger.push(triggerdata);
	if (json.isBenchmarked) {
		trigger.push(benchmarkTriggerdata);
	}
	satellitedata = "";
	voltagedata = "";
	temperaturedata = "";
	pressuredata = "";
	onOffPlot = $.plot($("#benchmarkChannelChart"), data, $.extend({}, benchmarkChanOptions, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	trigPlot = $.plot($("#benchmarkTriggerChart"), trigger,$.extend({}, trigOptions, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
	writeLegends2();
}

function onDataLoadWithBenchmark(json) {
	// we need channel data to be selectable, so do not discard it 
	channel1data = json.channel1;
	channel2data = json.channel2;
	channel3data = json.channel3;
	channel4data = json.channel4;
	triggerdata = json.trigger;
    channel1LowerError = json.channel1LowerError;
    channel1UpperError = json.channel1UpperError;
    channel2LowerError = json.channel2LowerError;
    channel2UpperError = json.channel2UpperError;
    channel3LowerError = json.channel3LowerError;
    channel3UpperError = json.channel3UpperError;  
    channel4LowerError = json.channel4LowerError;
    channel4UpperError = json.channel4UpperError;
    triggerLowerError = json.triggerLowerError;
    triggerUpperError = json.triggerUpperError;  
    benchmarkChannel1data = json.benchmarkChannel1;
	benchmarkChannel2data = json.benchmarkChannel2;
	benchmarkChannel3data = json.benchmarkChannel3;
	benchmarkChannel4data = json.benchmarkChannel4;
	benchmarkTriggerdata = json.benchmarkTrigger;
	satellitedata = "";
	voltagedata = "";
	temperaturedata = "";
	pressuredata = "";

	$.plot($("#benchmarkChannel1Chart"), [channel1LowerError, channel1UpperError, channel1data, benchmarkChannel1data ], $.extend({}, benchmarkOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel } ]}));
	$.plot($("#benchmarkChannel2Chart"), [channel2LowerError, channel2UpperError, channel2data, benchmarkChannel2data ], $.extend({}, benchmarkOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel } ]}));
	$.plot($("#benchmarkChannel3Chart"), [channel3LowerError, channel3UpperError, channel3data, benchmarkChannel3data ], $.extend({}, benchmarkOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel } ]}));
	$.plot($("#benchmarkChannel4Chart"), [channel4LowerError, channel4UpperError, channel4data, benchmarkChannel4data ], $.extend({}, benchmarkOptions, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel } ]}));
	$.plot($("#benchmarkTriggerChart1"), [triggerLowerError, triggerUpperError, json.trigger, benchmarkTriggerdata],$.extend({}, benchmarkTrigOptions, { yaxes: [ {position: 'left'} ]}));
}

