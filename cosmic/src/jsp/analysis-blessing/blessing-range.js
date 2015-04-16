var tf = "%m/%d/%y";

function writeLegendsRange() {
	writeLegend(onOffPlot.getCanvas(), "Channel Rate (Hz)", 325, 250);
	writeLegend(trigPlot.getCanvas(), "Trigger Rate (Hz)", 325, 250);
	writeLegend(satPlot.getCanvas(), "# Satellites in view", 325, 250);
	writeLegend(voltPlot.getCanvas(), "Vcc (Volts)", 325, 250);
	writeLegend(tempPlot.getCanvas(), "Temperature (\u00b0 C)", 325, 250);
	writeLegend(pressPlot.getCanvas(), "Pressure (mb)", 325, 250);
}//end of writeLegendsRange

//plots within a range
redrawPlotYRange = function(newY, chart, type)
{
	var tempOps;
	switch (chart) {
		case ("channel"):
			if (type == "min") {
				chanOptions.yaxis.min = newY;
			} else {
				chanOptions.yaxis.max = newY;
			}
			onOffPlot = $.plot($("#channelChart"), data, $.extend({}, chanOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
			writeLegend(onOffPlot.getCanvas(), "Channel Rate (Hz)", 325, 250);
			break;
		case ("trigger"):
			if (type == "min") {
				trigOptions.yaxis.min = newY;
			} else {
				trigOptions.yaxis.max = newY;
			}
			trigPlot = $.plot($("#triggerChart"), trigger,$.extend({}, trigOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(trigPlot.getCanvas(), "Trigger Rate (Hz)", 325, 250);
			break;
		case ("satellite"):
			if (type == "min") {
				satOptions.yaxis.min = newY;
			} else {
				satOptions.yaxis.max = newY;
			}
			satPlot = $.plot($("#satChart"), satellite ,$.extend({}, satOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(satPlot.getCanvas(), "# Satellites in view", 325, 250);
			break;
		case ("voltage"):
			if (type == "min") {			
				voltOptions.yaxis.min = newY;
			} else {
				voltOptions.yaxis.max = newY;
			}
			voltPlot = $.plot($("#voltChart"), voltage,$.extend({}, voltOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(voltPlot.getCanvas(), "Vcc (Volts)", 325, 250);
			break;
		case ("temperature"):
			if (type == "min") {			
				tempOptions.yaxis.min = newY;
			} else {
				tempOptions.yaxis.max = newY;
			}
			tempPlot = $.plot($("#tempChart"), temperature,$.extend({}, tempOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(tempPlot.getCanvas(), "Temperature (\u00b0 C)", 325, 250);
			break;
		case ("pressure"):
			if (type == "min") {
				pressOptions.yaxis.min = newY;
			} else {
				pressOptions.yaxis.max = newY;
			}
			pressPlot = $.plot($("#pressureChart"), pressure,$.extend({}, pressOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(pressPlot.getCanvas(), "Pressure (mb)", 325, 250);
			break;		

	}
}

resetPlotYRange = function(chart, objectIdYMin, objectIdYMax) {
	var inputYMinObject = document.getElementById(objectIdYMin);
	inputYMinObject.value = "";
	var inputYMaxObject = document.getElementById(objectIdYMax);
	inputYMaxObject.value = "";
	
	switch (chart) {
		case ("channel"):
			chanOptions.yaxis.min = originalChanYMin;
			chanOptions.yaxis.max = originalChanYMax;
			onOffPlot = $.plot($("#channelChart"), data, $.extend({}, chanOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel} ]}));
			writeLegend(onOffPlot.getCanvas(), "Channel Rate (Hz)", 325, 250);
	    	break;
		case ("trigger"):
			trigOptions.yaxis.min = originalTrigYMin;
			trigOptions.yaxis.max = originalTrigYMax;
			trigPlot = $.plot($("#triggerChart"), trigger,$.extend({}, trigOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(trigPlot.getCanvas(), "Trigger Rate (Hz)", 325, 250);
			break;
		case ("satellite"):
			satOptions.yaxis.min = originalSatYMin;
			satOptions.yaxis.max = originalSatYMax;
			satPlot = $.plot($("#satChart"), satellite,$.extend({}, satOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(satPlot.getCanvas(), "# Satellites in view", 325, 250);
			break;
		case ("voltage"):
			voltOptions.yaxis.min = originalVoltYMin;
			voltOptions.yaxis.max = originalVoltYMax;
			voltPlot = $.plot($("#voltChart"), voltage,$.extend({}, voltOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(voltPlot.getCanvas(), "Vcc (Volts)", 325, 250);
			break;
		case ("temperature"):
			tempOptions.yaxis.min = originalTempYMin;
			tempOptions.yaxis.max = originalTempYMax;
			tempPlot = $.plot($("#tempChart"), temperature,$.extend({}, tempOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(tempPlot.getCanvas(), "Temperature (\u00b0 C)", 325, 250);
			break;
		case ("pressure"):
			pressOptions.yaxis.min = originalPressYMin;
			pressOptions.yaxis.max = originalPressYMax;
			pressPlot = $.plot($("#pressureChart"), pressure,$.extend({}, pressOptions, {xaxis: {mode: "time",timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
			writeLegend(pressPlot.getCanvas(), "Pressure (mb)", 325, 250);
			break;		

	}
}

function onDataLoad1() {
	loadJSON(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoadRange(json);
		});
	});
}

function loadJSON(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/FluxBlessRange", true); // Replace 'my_data' with the path to your file
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
 }

function onDataLoadRange(json) {	
	console.log(json.channel1);
	channel1data = json.channel1;
	channel2data = json.channel2;
	channel3data = json.channel3;
	channel4data = json.channel4;
	triggerdata = json.trigger;
	data = [];
	data.push(channel1data);
	data.push(channel2data);
	data.push(channel3data);
	data.push(channel4data);
	trigger = [];
	trigger.push(json.trigger);
	satellitedata = json.satellites;
	satellite = [];
	satellite.push(json.satellites);
	voltagedata = json.voltage;
	voltage = [];
	voltage.push(voltagedata);
	temperaturedata = json.temperature;
	temperature = [];
	temperature.push(temperaturedata);
	pressuredata = json.pressure;	
	pressure = [];
	pressure.push(pressuredata);
	
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
		
	onOffPlot = $.plot($("#channelChart"), data, $.extend({}, chanOptions, {xaxis: {mode: "time",minTickSize: [1, "hour"],timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: channelRateXLabel } ]}));
	trigPlot = $.plot($("#triggerChart"), trigger ,$.extend({}, trigOptions,{xaxis: {mode: "time",minTickSize: [1, "hour"],timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: ''} ]}));
	satPlot = $.plot($("#satChart"), satellite ,$.extend({}, satOptions, {xaxis: {mode: "time",minTickSize: [1, "hour"],timeformat: tf}},{ yaxes: [ {position: 'left', axisLabel: '' } ]}));
	voltPlot = $.plot($("#voltChart"), voltage, $.extend({}, voltOptions, {xaxis: {mode: "time",minTickSize: [1, "hour"],timeformat: tf}},{ yaxes: [ {position: 'left', axisLabel: '' } ]}));
	tempPlot = $.plot($("#tempChart"), temperature, $.extend({}, tempOptions,{xaxis: {mode: "time",minTickSize: [1, "hour"],timeformat: tf}}, { yaxes: [ {position: 'left', axisLabel: '' } ]}));
	pressPlot = $.plot($("#pressureChart"), pressure, $.extend({}, pressOptions, {xaxis: {mode: "time",minTickSize: [1, "hour"],timeformat: tf}},{ yaxes: [ {position: 'left', axisLabel: '' } ]}));
	writeLegendsRange();
}

