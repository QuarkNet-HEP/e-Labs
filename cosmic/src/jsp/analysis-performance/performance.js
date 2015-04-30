var channel1, channel2, channel3, channel4;
var channel1Error, channel2Error, channel3Error, channel4Error;
var yDefaultPosition = "left";
var xDefaultPosition = "bottom";
var sliderMinX = -1;
var sliderMaxX = -1;
var maxYaxis = -1;
var minX = -1;
var maxX = -1;
var nBins = -1;
var bins;
var channels = 0;

options = {
        axisLabels: {
            show: true
        },		
        legend: {  
            show: true,  
            margin: 10,  
            backgroundOpacity: 0.5  
        },  
        lines: { 
        	show: true, 
        	fill: false, 
        	lineWidth: 2.0 
        },
        grid: { 
        	hoverable: true, 
        	autoHighlight: false
        },
        xaxis: { 
        	tickDecimals: 0
        },
 		zoom: {
			interactive: true
		},
		pan: {
			interactive: true
		},
		grid: {
			hoverable: true,
			clickable: true
		},	
		crosshair: {
			mode: "x"
		},
		yaxes: {
			axisLabelUseCanvas: true
		},
		xaxes: {
			axisLabelUseCanvas: true			
		},
		legend: {
			container: "#placeholderLegend",
			noColumns: 4,
            labelFormatter: function(label, series){
              if (series.toggle) {
            	  return '<a href="#" onClick="togglePlot('+series.idx+'); return false;">'+label+'</a>';
              }
            }
        }
};

overviewOptions = {
		legend: {
			show: false
		},
        lines: { 
        	show: true, 
        	fill: false, 
        	lineWidth: 1.2 
        },
        grid: { 
        	hoverable: true, 
        	autoHighlight: false 
        },
		xaxis: {
        	tickDecimals: 0, 
			ticks: 0
		},
		yaxis: {
			ticks: 0
		},
		grid: {
			color: "#999"
		},
		selection: {
			mode: "xy"
		}
};

togglePlot = function(seriesIdx) {
	if (seriesIdx < channels) {
	  var plotData = onOffPlot.getData();
	  plotData[seriesIdx].lines.show = !plotData[seriesIdx].lines.show;
	  plotData[seriesIdx+channels].points.show = !plotData[seriesIdx+channels].points.show;
	  plotData[seriesIdx+channels].points.yerr.show = !plotData[seriesIdx+channels].points.yerr.show;
	  onOffPlot.setData(plotData);
	  onOffPlot.draw();
	  refresh();
	}
}//end of togglePlot

function onDataLoad1() {
	loadJSON(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoad(json);
		});
	});
}

function loadJSON(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/PerformancePlotFlot", true); // Replace 'my_data' with the path to your file
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
 }

function onDataLoad(json) {	
	channel1 = json.channel1;
	channel2 = json.channel2;
	channel3 = json.channel3;
	channel4 = json.channel4;
	channel1Error = json.channel1error;
	channel2Error = json.channel2error;
	channel3Error = json.channel3error;
	channel4Error = json.channel4error;
	binValue = json.binValue;
	globalBinWidth = binValue;
	minX = json.minX;
	maxX = json.maxX;
	nBins = json.nBins;
	bins = json.fakeBins;
	studyLabel = "Performance Study";
	xAxisLabel = "Time over Threshold (nanosec)";
	yAxisLabel = "Number of PMT pulses";	

	if (channel1.data != null) {
		channel1.data = getDataWithBins(channel1.data, binValue, minX, maxX, nBins, bins);
		channels += 1;
		data.push(channel1);
	}
	if (channel2.data != null) {
		channel2.data = getDataWithBins(channel2.data, binValue, minX, maxX, nBins, bins);
		channels += 1;
		data.push(channel2);
	}
	if (channel3.data != null) {
		channel3.data = getDataWithBins(channel3.data, binValue, minX, maxX, nBins, bins);
		channels += 1;
		data.push(channel3);
	}
	if (channel4.data != null) {
		channel4.data = getDataWithBins(channel4.data, binValue, minX, maxX, nBins, bins);
		channels += 1;
		data.push(channel4);
	}
	if (channel1.data != null) {
		channel1Error.data = getError(channel1.data_original, binValue, minX, maxX, nBins, bins);
		data.push(channel1Error);
	}
	if (channel2.data != null) {
		channel2Error.data = getError(channel2.data_original, binValue, minX, maxX, nBins, bins);
		data.push(channel2Error);
	}
	if (channel3.data != null) {
		channel3Error.data = getError(channel3.data_original, binValue, minX, maxX, nBins, bins);
		data.push(channel3Error);		
	}
	if (channel4.data != null) {
		channel4Error.data = getError(channel4.data_original, binValue, minX, maxX, nBins, bins);
		data.push(channel4Error);		
	}
	setSliders(minX, maxX);
	
	$("#range").attr({"min":Math.floor(sliderMinX), "max":Math.floor(sliderMaxX), "value": binValue});
	$("#binWidth").attr({"min":Math.floor(sliderMinX), "max":Math.floor(sliderMaxX), "value": binValue});
	
	onOffPlot = $.plot("#placeholder", data, options);
	overviewPlot = $.plot("#overview", data, overviewOptions);

    $('#range').on('input', function(){
        $('#binWidth').val($('#range').val());
        if ($('#range').val() > 0) {
            reBinData(json,$('#range').val());        	
        }
    });
    $('#binWidth').on('change', function(){
        $('#range').val($('#binWidth').val());
        if ($('#binWidth').val() > 0) {
        	reBinData(json,$('#binWidth').val());
        }
    });

    
    $("<div class='button' style='left:20px;top:20px'>reset</div>")
	.appendTo($("#resetbutton"))
	.click(function (event) {
		event.preventDefault();
		reBinData(json, json.binValue);
		onOffPlot = $.plot("#placeholder", data, options);
		overviewPlot = $.plot("#overview", data, overviewOptions);				
		$(".message").html("");
		$(".click").html("");
		refresh();			
	});	
    bindEverything();
}//end of onDataLoad	

function setSliders(minX, maxX) {
	//get values for the slider from the data
	if (sliderMinX <= 0 ) {
		sliderMinX = minX;
	} else {
		if (minX < sliderMinX) {
			sliderMinX = minX;
		}
	}
	if (sliderMaxX <= 0 ) {
		sliderMaxX = maxX;
	} else {
		if (maxX > sliderMaxX) {
			sliderMaxX = maxX;
		}
	}	
}//end of setSliders

function getDataWithBins(rawData, localBinValue, minX, maxX, nBins, bins) {
	//create histogram data
    var outputFinal = [];
	if (rawData != null) {
		binValue = localBinValue;
		var histogram = d3.layout.histogram();
		histogram.bins(bins);
		var data = histogram(rawData);
	    for ( var i = 0; i < data.length; i++ ) {
	    	outputFinal.push([data[i].x, data[i].y]);
	    	outputFinal.push([data[i].x + data[i].dx, data[i].y]);
	    	if (data[i].y > maxYaxis) {
	    		maxYaxis = data[i].y + (data[i].y * 0.1);
	    	}
	     } 
	}
    return outputFinal;	
}//end of getDataWithBins

function getError(rawData, localBinValue, minX, maxX, nBins, bins) {
    var outputFinal = [];
	if (rawData != null) {
		binValue = localBinValue;
		var histogram = d3.layout.histogram();
		histogram.bins(bins);
		var data = histogram(rawData);
		var halfBin = localBinValue / 2.0;
	    for ( var i = 0; i < data.length; i++ ) {
	    	outputFinal.push([data[i].x + halfBin, data[i].y, Math.sqrt(data[i].y)]);
	     } 
	}
    return outputFinal;	
}//end of getDataWithBins

Number.prototype.toFixedDown = function(digits) {
	  var n = this - Math.pow(10, -digits)/2;
	  n += n / Math.pow(2, 53); // added 1360765523: 17.56.toFixedDown(2) === "17.56"
	  return n.toFixed(digits);
	}
function intToFloat(num, decPlaces) { 
	return num + '.' + Array(decPlaces + 1).join('0'); 
	}

function reBinData(json, binValue) {
	if (binValue > 0) {
		maxYaxis = 1;
	  	var plotData = onOffPlot.getData();
	  	var overviewData = overviewPlot.getData();
		minX = json.minX;
		maxX = json.maxX;
		bins = [];
		nBins = Math.ceil(json.maxX / binValue);
		for (var i = 0.00001; i < (maxX*1.00000); i += (binValue*1.00000)) {
			bins.push(i);
		}
		data = [];
		if (channel1.data != null) {
			channel1.data = getDataWithBins(channel1.data_original, binValue, minX, maxX, nBins, bins);
			data.push(channel1);
		}
		if (channel2.data != null) {
			channel2.data = getDataWithBins(channel2.data_original, binValue, minX, maxX, nBins, bins);
			data.push(channel2);
		}
		if (channel3.data != null) {
			channel3.data = getDataWithBins(channel3.data_original, binValue, minX, maxX, nBins, bins);
			data.push(channel3);
		}
		if (channel4.data != null) {
			channel4.data = getDataWithBins(channel4.data_original, binValue, minX, maxX, nBins, bins);
			data.push(channel4);
		}
		if (channel1Error.data != null) {
			channel1Error.data = getError(channel1.data_original, binValue, minX, maxX, nBins, bins);
			data.push(channel1Error);
		}
		if (channel2Error.data != null) {
			channel2Error.data = getError(channel2.data_original, binValue, minX, maxX, nBins, bins);
			data.push(channel2Error);
		}
		if (channel3Error.data != null) {
			channel3Error.data = getError(channel3.data_original, binValue, minX, maxX, nBins, bins);
			data.push(channel3Error);
		}
		if (channel4Error.data != null) {
			channel4Error.data = getError(channel4.data_original, binValue, minX, maxX, nBins, bins);
			data.push(channel4Error);
		}
	
		setSliders(minX, maxX);
	
		onOffPlot.setData(data);
		overviewPlot.setData(data);
		var axes = onOffPlot.getAxes();
	    axes.yaxis.options.max = maxYaxis + (maxYaxis * 0.05);	
	    onOffPlot.setupGrid();
	    onOffPlot.draw();
		var axesOverview = overviewPlot.getAxes();
		axesOverview.yaxis.options.max = maxYaxis + (maxYaxis * 0.05);	
		overviewPlot.setupGrid();
	    overviewPlot.draw();
	    refresh();
	}
}//end of reBinData
