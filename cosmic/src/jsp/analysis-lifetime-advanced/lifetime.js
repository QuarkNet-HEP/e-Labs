var lifetimeData, lifetimeDataError;
var yDefaultPosition = "left";
var xDefaultPosition = "bottom";
var sliderMinX = -1;
var sliderMaxX = -1;
var maxYaxis = -1.0;
var maxError = -1.0;
var minX = -1;
var maxX = -1;
var nBins = -1;
var bins;
var originalJson;

function onDataLoad1() {
	spinnerOn();
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
    xobj.open('GET', outputDir.value+"/LifetimePlotFlot", true); 
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}

function onDataLoad(json) {	
	var timeStart = new Date();
	originalJson = json;
	lifetimeData = json.lifetimedata;
	binValue = json.binValue;
	globalBinWidth = binValue;
	minX = json.minX;
	maxX = json.maxX;
	nBins = json.nBins;
	bins = json.fakeBins;
	studyLabel = "Lifetime Study";
	xAxisLabel = "Decay Length (microsec)";
	yAxisLabel = "Number of Decays";	
	
	if (json.lifetimedata != null) {
		firstX = lifetimeData.data[0][0];
		dummyData = [[firstX, null]];
		maxYaxis = json.maxYaxis;
		maxError = json.maxError;
		data.push(lifetimeData);
	}
	
	setSliders(10,200);
	
	$("#range").attr({"min":Math.floor(sliderMinX), "max":Math.floor(sliderMaxX), "value": binValue});
	$("#binWidth").attr({"min":Math.floor(sliderMinX), "max":Math.floor(sliderMaxX), "value": binValue});
	
	onOffPlot = $.plot("#placeholder", data, options);
	overviewPlot = $.plot("#overview", data, overviewOptions);
	
	var axes = onOffPlot.getAxes();
    axes.yaxis.options.max = maxYaxis + maxError;	
    onOffPlot.setupGrid();
    onOffPlot.draw();
	var axesOverview = overviewPlot.getAxes();
	axesOverview.yaxis.options.max = maxYaxis + maxError;	
	overviewPlot.setupGrid();
    overviewPlot.draw();

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
    var timeEnd = new Date();
    var timeDiff = timeEnd - timeStart;
    //console.log("millis: "+timeDiff);
    spinnerOff();
}   

function getDataWithBinsPlusError(rawData,localBinValue, minX, maxX, nBins, bins) {
    var outputFinal = [];
	if (rawData != null) {
		binValue = localBinValue;
		var histogram = d3.layout.histogram();
		histogram.bins(bins);
		var data = histogram(rawData);
	    for ( var i = 0; i < data.length; i++ ) {
	    	if (data[i].y > 0) {
				var yError = Math.sqrt(data[i].y);
				outputFinal.push([data[i].x, data[i].y, yError]);
		    	if ((data[i].y + (data[i].y * 0.30)) > maxYaxis) {
		    		maxYaxis = data[i].y + (data[i].y * 0.30);
		    	}
		    	if (yError > maxError) {
		    		maxError = yError;
		    	}
	    	} else {
		    	outputFinal.push([data[i].x, null, null]);	
	    	}
	    }
	}
    return outputFinal;	
}//end of getDataWithBinsPlusError


function reBinData(json, binValue) {
	if (binValue > 0) {
		maxYaxis = 1;
	  	var plotData = onOffPlot.getData();
	  	var overviewData = overviewPlot.getData();
		minX = json.minX;
		maxX = json.maxX;
		bins = [];
		nBins = binValue;
		var step = (maxX-minX)/nBins; 		
		for (var i = minX+step; i <= maxX+(step*2); i=i+step) {
			bins.push(i-(step/2));
		}
		data = [];		
		if (json.lifetimedata != null) {
			lifetimeData.data = getDataWithBinsPlusError(lifetimeData.data_original, binValue, minX, maxX, nBins, bins);
			data.push(lifetimeData);
		}
		setSliders(10,200);
	
		onOffPlot.setData(data);
		overviewPlot.setData(data);
		var axes = onOffPlot.getAxes();
	    axes.yaxis.options.max = maxYaxis + maxError;	
	    onOffPlot.setupGrid();
	    onOffPlot.draw();
		var axesOverview = overviewPlot.getAxes();
		axesOverview.yaxis.options.max = maxYaxis + maxError;	
		overviewPlot.setupGrid();
	    overviewPlot.draw();
	    refresh();
	}
}//end of reBinData

var firstX = 0;
var dummyData;

options = {
		//canvas: true,
        axisLabels: {
            show: true
        },		
        legend: {  
            show: false,  
            margin: 10,  
            backgroundOpacity: 0.5  
        },  
    	series: {
    		lines: {
    			show: false,
				steps: false
    		},
    		points: {
    			show: true,
    			radius: 0.5,
    			errorbars: "y", 
    			yerr: {show:true, asymmetric:null, upperCap: "-", lowerCap: "-"}
    		},
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
		xaxes: [{	
				axisLabelUseCanvas: true,
				}
		]
};

overviewOptions = {
		legend: {
			show: false
		},
		series: {
			lines: {
				show: false,
				steps: false,
				lineWidth: 1
			},
			shadowSize: 0
		},
		xaxis: {
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
	  plotData[seriesIdx].points.yerr.show = !plotData[seriesIdx].points.yerr.show;
	  onOffPlot.setData(plotData);
	  onOffPlot.draw();
	  refreshFlux();
}//end of togglePlot


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

Number.prototype.toFixedDown = function(digits) {
	  var n = this - Math.pow(10, -digits)/2;
	  n += n / Math.pow(2, 53); // added 1360765523: 17.56.toFixedDown(2) === "17.56"
	  return n.toFixed(digits);
	}
function intToFloat(num, decPlaces) { 
	return num + '.' + Array(decPlaces + 1).join('0'); 
	}