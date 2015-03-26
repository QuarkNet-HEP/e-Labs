var channel1, channel2, channel3, channel4;
var yDefaultPosition = "left";
var xDefaultPosition = "bottom";
var sliderMinX = -1;
var sliderMaxX = -1;
var maxYaxis = -1;

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
        	lineWidth: 1.2 
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
              return '<a href="#" onClick="togglePlot('+series.idx+'); return false;">'+label+'</a>';
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
	  var plotData = onOffPlot.getData();
	  plotData[seriesIdx].points.show = !plotData[seriesIdx].points.show;
	  plotData[seriesIdx].lines.show = !plotData[seriesIdx].lines.show;
	  plotData[seriesIdx].points.yerr.show = !plotData[seriesIdx].points.yerr.show;
	  onOffPlot.setData(plotData);
	  onOffPlot.draw();
	  refresh();
}//end of togglePlot

function onDataLoad(json) {	
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
	var values = new Array();
	$.each(serialized, function(index,element){
	     values.push(element.value);
	});	 
	var binValue = 1;
	for (var i = 0; i < values.length; i++) {
		if (values[i].startsWith("bins")) {
			var parts = values[i].split(" ");
			binValue = parts[2];
		}
	}
	channel1 = json.channel1;
	channel2 = json.channel2;
	channel3 = json.channel3;
	channel4 = json.channel4;
	channel1.data = getDataWithBins(channel1.data, binValue);
	channel2.data = getDataWithBins(channel2.data, binValue);
	channel3.data = getDataWithBins(channel3.data, binValue);
	channel4.data = getDataWithBins(channel4.data, binValue);
	
	data.push(channel1);
	data.push(channel2);
	data.push(channel3);
	data.push(channel4);

	$("#range").attr({"min":Math.floor(sliderMinX), "max":Math.floor(sliderMaxX), "value": binValue});
	$("#binWidth").attr({"min":Math.floor(sliderMinX), "max":Math.floor(sliderMaxX), "value": binValue});

	options = $.extend(true, {}, options, {
		yaxes: [{
			position: channel1.yaxis.position
		}],
		xaxes: [{
			position: channel1.xaxis.position
		}]
	});
	options = $.extend(true, {}, options, {
		yaxes: [{
			position: channel2.yaxis.position
		}],
		xaxes: [{
			position: channel2.xaxis.position
		}]
	});
	options = $.extend(true, {}, options, {
		yaxes: [{
			position: channel3.yaxis.position
		}],
		xaxes: [{
			position: channel3.xaxis.position
		}]
	});
	options = $.extend(true, {}, options, {
		yaxes: [{
			position: channel4.yaxis.position
		}],
		xaxes: [{
			position: channel4.xaxis.position
		}]
	});
	
	onOffPlot = $.plot("#placeholder", data, options);
	overviewPlot = $.plot("#overview", data, overviewOptions);

    $('#range').on('change', function(){
        $('#binWidth').val($('#range').val());
        reBinData(json,$('#range').val());
    });
    $('#binWidth').on('change', function(){
        $('#range').val($('#binWidth').val());
        reBinData(json,$('#binWidth').val());
    });
	
	bindEverything();
}//end of onDataLoad	

if (typeof String.prototype.startsWith != 'function') {
	  String.prototype.startsWith = function (str){
	    return this.indexOf(str) === 0;
	  };
}//helper

function getDataWithBins(rawData, binValue) {
	//calculate number of bins
	var minX = d3.min(d3.values(rawData));
	var maxX = d3.max(d3.values(rawData));
	var nbins = Math.floor((maxX - minX) / binValue);
	//get values for the slider from the data
	if (sliderMinX < 0 ) {
		sliderMinX = minX;
	} else {
		if (minX < sliderMinX) {
			sliderMinX = minX;
		}
	}
	if (sliderMaxX < 0 ) {
		sliderMaxX = maxX;
	} else {
		if (maxX > sliderMaxX) {
			sliderMaxX = maxX;
		}
	}	
	//create histogram data
	var histogram = d3.layout.histogram();
	histogram.bins(nbins);
	var data = histogram(rawData);
    var outputFinal = [];
    for ( var i = 0; i < data.length; i++ ) {
    	var error = Math.sqrt(data[i].y);
    	outputFinal.push([data[i].x, data[i].y, error]);
    	outputFinal.push([data[i].x + data[i].dx, data[i].y, error]);
    	if (data[i].y > maxYaxis) {
    		maxYaxis = data[i].y;
    	}
     } 
    return outputFinal;	
}