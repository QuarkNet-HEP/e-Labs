var fluxData, fluxDataError;
var fluxArea;
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
    xobj.open('GET', outputDir.value+"/FluxPlotFlot", true); 
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
	fluxData = json.fluxdata;
	fluxArea = fluxData.area;
	binValue = json.binValue;
	globalBinWidth = binValue;
	minX = json.minX;
	maxX = json.maxX;
	nBins = json.nBins;
	bins = json.fakeBins;
	studyLabel = "Flux Study";
	xAxisLabel = "Time UTC (hours:minutes)";
	yAxisLabel = "Flux (events/m^2/60-seconds)";	
	pressData = json.pressure;
	tempData = json.temperature;
	
	if (json.fluxdata != null) {
		firstX = fluxData.data[0][0];
		dummyData = [[firstX, null]];
		maxYaxis = json.maxYaxis;
		maxError = json.maxError;
		data.push(fluxData);
	}
	
	setSliders(60, 6000);

	$("#showPressure").click (function() {
		if ($("#showPressure:checked").length > 0) {
			addSeries(pressData, "pressure");
			pressNdx = data.length - 1;
		} else {
			removeSeries(pressNdx);
		}
	});

	$("#showTemperature").click (function() {
		if ($("#showTemperature:checked").length > 0) {
			addSeries(tempData, "temperature");
			tempNdx = data.length - 1;
		} else {
			removeSeries(tempNdx);
		}
	});
	
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
		refreshFlux();			
	});	
    bindEverythingFlux();
    var timeEnd = new Date();
    var timeDiff = timeEnd - timeStart;
    //console.log("millis: "+timeDiff);
    spinnerOff();
}   

function getDataWithBinsPlusError(rawData, area, localBinValue, minX, maxX, nBins, bins) {
    var outputFinal = [];
	if (rawData != null) {
		binValue = localBinValue;
		var histogram = d3.layout.histogram();
		histogram.bins(bins);
		var data = histogram(rawData);
		var halfBin = localBinValue / 2.0;
	    for ( var i = 0; i < data.length; i++ ) {
			if (data[i].y > 0) {
				var areaFactor = 0.0;
				for (var x = 0; x < area.length; x++) {
					if (data[i].x >= area[x][0]) {
						areaFactor = area[x][1];
						break;
					}
				}
				if (areaFactor > 0) {
					var yValue = (data[i].y/(binValue/60)/areaFactor);
					var yError = (Math.sqrt(data[i].y)/(binValue/60)/areaFactor);
					outputFinal.push([data[i].x + halfBin, yValue, yError]);
			    	if ((yValue + (yValue * 0.30)) > maxYaxis) {
			    		maxYaxis = yValue + (yValue * 0.30);
			    	}
			    	if (yError > maxError) {
			    		maxError = yError;
			    	}
				}
			} else {
		    	outputFinal.push([data[i].x, null, null]);				
			}
	     } 
	}
	for (var x = 1; x < outputFinal.length; x++) {
		if (x < outputFinal.length - 2) {
			if (outputFinal[x+1][1] == null && outputFinal[x][1] != null) {
				outputFinal[x][1] = null;
				outputFinal[x][2] = null;
			}
		}
	}
	//clear the last one
	outputFinal[outputFinal.length-1][1] = null;
	outputFinal[outputFinal.length-1][2] = null;
	
    return outputFinal;	
}//end of getDataWithBins


function reBinData(json, binValue) {
	if (binValue > 0) {
		maxYaxis = 1;
	  	var plotData = onOffPlot.getData();
	  	var overviewData = overviewPlot.getData();
		minX = json.minX;
		maxX = json.maxX;
		bins = [];
		nBins = Math.ceil(json.maxX / (binValue*1000));
		for (var i = minX; i < (maxX*1.00000); i += (binValue*1000*1.00000)) {
			bins.push(i);
		}
		data = [];
		
		if (json.fluxdata != null) {
			fluxData.data = getDataWithBinsPlusError(fluxData.data_original, fluxArea, binValue, minX, maxX, nBins, bins);
			data.push(fluxData);
		}
		setSliders(60, 6000);
	
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
		//console.log(onOffPlot.getData());

	    refreshFlux();
	}
}//end of reBinData

var tempNdx, pressNdx;
var firstX = 0;
var dummyData;
var pressData, tempData;

function removeSeries(ndx) {
	data.splice(ndx,1,dummyData);
	onOffPlot = $.plot("#placeholder", data, options);
	overviewPlot = $.plot("#overview", data, overviewOptions);				
	refreshFlux();
}

function addSeries(newSeries) {
	data.push(newSeries);
	onOffPlot = $.plot("#placeholder", data, options);
	overviewPlot = $.plot("#overview", data, overviewOptions);				
	refreshFlux();	
}

Date.prototype.customFormat = function(formatString){
    var YYYY,YY,MMMM,MMM,MM,M,DDDD,DDD,DD,D,hhh,hh,h,mm,m,ss,s,ampm,AMPM,dMod,th;
    var dateObject = this;
    YY = ((YYYY=dateObject.getFullYear())+"").slice(-2);
    MM = (M=dateObject.getMonth()+1)<10?('0'+M):M;
    MMM = (MMMM=["January","February","March","April","May","June","July","August","September","October","November","December"][M-1]).substring(0,3);
    DD = (D=dateObject.getDate())<10?('0'+D):D;
    DDD = (DDDD=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"][dateObject.getDay()]).substring(0,3);
    th=(D>=10&&D<=20)?'th':((dMod=D%10)==1)?'st':(dMod==2)?'nd':(dMod==3)?'rd':'th';
    formatString = formatString.replace("#YYYY#",YYYY).replace("#YY#",YY).replace("#MMMM#",MMMM).replace("#MMM#",MMM).replace("#MM#",MM).replace("#M#",M).replace("#DDDD#",DDDD).replace("#DDD#",DDD).replace("#DD#",DD).replace("#D#",D).replace("#th#",th);

    h=(hhh=dateObject.getHours());
    if (h==0) h=24;
    if (h>12) h-=12;
    hh = h<10?('0'+h):h;
    AMPM=(ampm=hhh<12?'am':'pm').toUpperCase();
    mm=(m=dateObject.getMinutes())<10?('0'+m):m;
    ss=(s=dateObject.getSeconds())<10?('0'+s):s;
    return formatString.replace("#hhh#",hhh).replace("#hh#",hh).replace("#h#",h).replace("#mm#",mm).replace("#m#",m).replace("#ss#",ss).replace("#s#",s).replace("#ampm#",ampm).replace("#AMPM#",AMPM);
}

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
				mode: "time",
				tickFormatter: function (val, axis) {		
					var d = new Date(val);
					return d.customFormat("#DD#/#MMM#<br />#hh#:#mm#");
					}
				}, {	
				axisLabelUseCanvas: true,
				mode: "time",
				tickFormatter: function (val, axis) {		
					var d = new Date(val);
					return d.customFormat("#DD#/#MMM#<br />#hh#:#mm#");
					}
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

function bindTooltip() {
	$("#placeholder").bind("plothover", function (event, pos, item) {

		if ($("#enableTooltip:checked").length > 0) {
			if (item) {
				var x = item.datapoint[0].toFixed(2),
					y = item.datapoint[1].toFixed(2),
					z = item.datapoint[0];
				var zx = new Date(z);
				if (zx) {
					x = zx.customFormat("#DD#/#MMM# #hh#:#mm#");
				}
				$("#tooltip").html(item.series.label+" at " + x + " = " + y)
					.css({top: item.pageY+5, left: item.pageX+5})
					.fadeIn(200);
			} else {
				$("#tooltip").hide();
			}
		}
	});

}//end of bindZoomingPanningTooltip


function bindEverythingFlux() {
	  buildCanvas(); // creates a canvas of the chart with captions, legends, etc so then then it can be saved
	  bindTooltip();
	  bindPlotClick();
	  bindPlotSelection();
	  buildZoomOutButton();
	  buildInteractiveZoom();
	  buildArrows();
	  buildInteractivePanning();
	  buildUnits();	
}//end of bindEverything

function refreshFlux() {
	  buildCanvas();
	  bindTooltip();
	  bindPlotClick();
	  bindPlotSelection();
	  buildInteractiveZoom();
	  buildInteractivePanning();
	  buildUnits();	
}//end of refresh


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