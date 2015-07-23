var onOffPlot;
var overviewPlot;
var timeDiff1, timeDiff2, timeDiff3, timeDiff4, timeDiff5, timeDiff6;
var data = []; //data that will be sent to the chart
var original_data = [];
var options = "";
var overviewOptions = "";
var yAxisLabel;
yAxisLabel = "number of entries/time bin";
var maxYaxis;
var maxBins = -1;
var binValue = 0;
var originalBinValue = 2;
var minXCombined = 0;
var maxXCombined = 0;

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
			axisLabelUseCanvas: true,
			min: 0
		},
		xaxes: {
			axisLabelUseCanvas: true			
		},
		legend: {
			container: "#placeholderLegend",
			noColumns: 6,
            labelFormatter: function(label, series){
              if (series.toggle) {
            	  return '<a href="#" onClick="togglePlot('+series.idx+'); return false;">'+label+'</a>';
              }
            }
        }	
};

togglePlot = function(seriesIdx) {
	var plotData = onOffPlot.getData();
	plotData[seriesIdx].lines.show = !plotData[seriesIdx].lines.show;
	plotData[seriesIdx].points.show = !plotData[seriesIdx].points.show;
	onOffPlot.setData(plotData);
	onOffPlot.draw();
}//end of togglePlot

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
    xobj.open('GET', outputDir.value+"/timeOfFlightPlotData", true); // Replace 'my_data' with the path to your file
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
 }

function onDataLoad(json) {	
	timeDiff1 = json.timediff1;
	timeDiff2 = json.timediff2;
	timeDiff3 = json.timediff3;
	timeDiff4 = json.timediff4;
	timeDiff5 = json.timediff5;
	timeDiff6 = json.timediff6;	
	buildTimeDiff(json,json.timediff1,data);
	buildTimeDiff(json,json.timediff2,data);
	buildTimeDiff(json,json.timediff3,data);
	buildTimeDiff(json,json.timediff4,data);
	buildTimeDiff(json,json.timediff5,data);
	buildTimeDiff(json,json.timediff6,data);
	bindEverything(json);
	original_data = data;
}//end of onDataLoad	

function buildTimeDiff(json, timediff, data) {
	if (timediff != null) {
		timediff.data = getDataWithBins(timediff.data_original, timediff.binValue, timediff.minX, timediff.maxX, timediff.nBins, timediff.nBins);
		data.push(timediff);
		if (timediff.maxX > maxXCombined) {
			maxXCombined = timediff.maxX;
		}
		if (timediff.minX < minXCombined) {
			minXCombined = timediff.minX;
		}
		if (timediff.maxBins > maxBins) {
			maxBins = timediff.maxBins;
		}
		binValue = timediff.binValue;
	}
}

function bindEverything(json) {
	onOffPlot = $.plot("#placeholder", data, options);
	overviewPlot = $.plot("#overview", data, overviewOptions);
	
	$("#range").attr({"min":Math.floor(1), "max":Math.floor(maxBins), "value": binValue});
	$("#binWidth").attr({"min":Math.floor(1), "max":Math.floor(maxBins), "value": binValue});

    $('#range').on('input', function(){
        $('#binWidth').val($('#range').val());
        if ($('#range').val() > 0) {
            reBinData($('#range').val()); 
            refresh();
        }
    });
    $('#binWidth').on('change', function(){
        $('#range').val($('#binWidth').val());
        if ($('#binWidth').val() > 0) {
        	reBinData($('#binWidth').val());
            refresh();
        }
    });
	
    $("<div class='button' style='left:20px;top:20px'>reset</div>")
	.appendTo($("#resetbutton"))
	.click(function (event) {
		event.preventDefault();
		reBinData(originalBinValue);
		onOffPlot = $.plot("#placeholder", original_data, options);
		overviewPlot = $.plot("#overview", original_data, overviewOptions);				
		$(".message").html("");
		$(".click").html("");
		refresh();
	});	
    buildZoomOutButton();
    refresh();
}//end of generic buildTimeDiff

function refresh() {
    bindPlotHover();
    bindPlotClick();
    bindPlotSelection();
    buildInteractiveZoom();
    buildArrows();
    buildInteractivePanning();
    writeLegend(onOffPlot.getCanvas());
}

function writeLegend(canvas) {
	var context = canvas.getContext('2d');
	context.lineWidth=3;
	context.fillStyle="#000000";
	context.lineStyle="#ffff00";
	context.font="16px sans-serif";
	context.save();
	context.textAlign = "Time Of Flight Study";
	context.fillText("Time Of Flight Study", 180, 40);
	context.font="12px sans-serif";
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
	var values = new Array();
	var xcoord = 30;
	var ycoord = 0;
	var yspace = 15;	
	ycoord = 50;
	$.each(serialized, function(index,element){
		var val = element.value;
		if (val.indexOf("caption") > -1) {
			var caption = val.substring(val.indexOf("Data"), val.length);
			var captionArray = caption.split("\n");
			for (var i = 0; i < captionArray.length; i++) {
				var printText = captionArray[i];
				if (captionArray[i].length > 48) {
					printText = captionArray[i].substring(0, 48);
				}
				ycoord += yspace; 
				context.fillText(printText, xcoord, ycoord);				
			}
		}
	   });	 
	var series = onOffPlot.getData();   
	var xcoord = 360;
	var ycoord = 0;
	var yspace = 15;	
	ycoord = 50;
	for (var i = 0; i < series.length; i++) {
		if (series[i].toggle) {
			context.strokeStyle = series[i].color;
			context.beginPath();
		    ycoord += (yspace);
		    context.moveTo(xcoord, ycoord);
		    context.lineTo(xcoord+5, ycoord);
		    context.stroke();
		    context.fillText(series[i].label + " #"+series[i].numberOfEntries,xcoord+10,ycoord);	
		}
	}		

	context.translate(0, 350);
	context.rotate(-Math.PI / 2);
	context.textAlign = yAxisLabel;
	context.fillText(yAxisLabel, 0, 40);
	context.restore();		
}//end of writeLegend

function buildInteractivePanning() {
	$("#placeholder").bind("plotpan", function (event, plot) {
		var axes = onOffPlot.getAxes();
		$(".message").html("Panning to x: "  + axes.xaxis.min.toFixed(2)
		+ " &ndash; " + axes.xaxis.max.toFixed(2)
		+ " and y: " + axes.yaxis.min.toFixed(2)
		+ " &ndash; " + axes.yaxis.max.toFixed(2));
        refresh();
	});	
}//end of buildInteractivePanning

//and add panning buttons
function addArrow(dir, left, top, offset) {
	$("<img class='button' src='../graphics/arrow-" + dir + ".gif' style='left:" + left + "px;top:" + top + "px'>")
		.appendTo("#arrowcontainer")
		.click(function (e) {
			e.preventDefault();
			onOffPlot.pan(offset);
		});
}
function buildArrows() {
	addArrow("left", 55, 15, { left: -100 });
	addArrow("right", 85, 15, { left: 100 });
	addArrow("up", 70, 0, { top: -100 });
	addArrow("down", 70, 30, { top: 100 });
}//end of buildArrows

function buildInteractiveZoom() {
	$("#placeholder").bind("plotzoom", function (event, plot) {
		var axes = onOffPlot.getAxes();
		$(".message").html("Zooming to x: "  + axes.xaxis.min.toFixed(2)
		+ " &ndash; " + axes.xaxis.max.toFixed(2)
		+ " and y: " + axes.yaxis.min.toFixed(2)
		+ " &ndash; " + axes.yaxis.max.toFixed(2));
        refresh();
	});	
}//end of buildInteractiveZoom

function buildZoomOutButton() {
	// add zoom out button 
	$("<div class='button' style='left:20px;top:20px'>zoom out</div>")
		.appendTo($("#zoomoutbutton"))
		.click(function (event) {
			event.preventDefault();
			onOffPlot.zoomOut();
            refresh();
		});	
}//end of buildZoomOutButton

function bindPlotSelection() {
	$("#placeholder").bind("plotselected", function (event, ranges) {
		// clamp the zooming to prevent eternal zoom
		if (ranges.xaxis.to - ranges.xaxis.from < 0.00001) {
			ranges.xaxis.to = ranges.xaxis.from + 0.00001;
		}
		if (ranges.yaxis.to - ranges.yaxis.from < 0.00001) {
			ranges.yaxis.to = ranges.yaxis.from + 0.00001;
		}
		// do the zooming
		onOffPlot = $.plot("#placeholder", data ,
			$.extend(true, {}, options, {
				xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
				yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to }
			})
		);
		buildCanvas();
		overviewPlot.setSelection(ranges, true);
	});

	$("#overview").bind("plotselected", function (event, ranges) {
		onOffPlot.setSelection(ranges);
	});	
}//end of bindPlotSelection
function bindPlotClick() {
	$("#placeholder").bind("plotclick", function (event, pos, item) {
		if (item) {
			$("#clickdata").text("Click point " + item.dataIndex + " in " + item.series.label);
			onOffPlot.highlight(item.series, item.datapoint);
		}
	});
}//end of bindPlotClick

function bindPlotHover() {
	$("<div id='tooltip'></div>").css({
		position: "absolute",
		display: "none",
		border: "1px solid #fdd",
		padding: "2px",
		"background-color": "#fee",
		opacity: 0.80
	}).appendTo("body");

	$("#placeholder").bind("plothover", function (event, pos, item) {
		if ($("#enablePosition:checked").length > 0) {
			var str = "(" + pos.x.toFixed(2) + ", " + pos.y.toFixed(2) + ")";
			$("#hoverdata").text(str);
		}
		if ($("#enableTooltip:checked").length > 0) {
			if (item) {
				var x = item.datapoint[0].toFixed(2),
					y = item.datapoint[1].toFixed(2);
				$("#tooltip").html(item.series.label + " at " + x + " = " + y)
					.css({top: item.pageY+5, left: item.pageX+5})
					.fadeIn(200);
			} else {
				$("#tooltip").hide();
			}
		}
	});	
}//end of bindTooltip

function getDataWithBins(rawData, localBinValue, minX, maxX, nBins, bins) {
	//create histogram datax
    var outputFinal = [];
	if (rawData != null) {
		binValue = localBinValue;
		var histogram = d3.layout.histogram();
		histogram.bins(bins);
		var data = histogram(rawData);
		for ( var i = 0; i < data.length; i++ ) {
	    	outputFinal.push([data[i].x, data[i].y]);
	    	outputFinal.push([data[i].x + data[i].dx, data[i].y]);
	    	if ((data[i].y + (data[i].y * 0.30)) > maxYaxis) {
	    		maxYaxis = data[i].y + (data[i].y * 0.30);
	    	}
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

function reBinData(binValue) {
	if (binValue > 0) {
		bins = [];
		nBins = Math.ceil(maxBins / binValue);
		for (var i = (minXCombined*1.00000)+0.00001; i < (maxXCombined*1.00000+binValue*1.00000); i += (binValue*1.00000)) {
			bins.push(i);
		}
		data = [];
		if (timeDiff1 != null) {
			timeDiff1.data = getDataWithBins(timeDiff1.data_original, binValue, timeDiff1.minX, timeDiff1.maxX, nBins, bins);
			data.push(timeDiff1);
		}
		if (timeDiff2 != null) {
			timeDiff2.data = getDataWithBins(timeDiff2.data_original, binValue, timeDiff2.minX, timeDiff2.maxX, nBins, bins);
			data.push(timeDiff2);
		}
		if (timeDiff3 != null) {
			timeDiff3.data = getDataWithBins(timeDiff3.data_original, binValue, timeDiff3.minX, timeDiff3.maxX, nBins, bins);
			data.push(timeDiff3);
		}
		if (timeDiff4 != null) {
			timeDiff4.data = getDataWithBins(timeDiff4.data_original, binValue, timeDiff4.minX, timeDiff4.maxX, nBins, bins);
			data.push(timeDiff4);
		}
		if (timeDiff5 != null) {
			timeDiff5.data = getDataWithBins(timeDiff5.data_original, binValue, timeDiff5.minX, timeDiff5.maxX, nBins, bins);
			data.push(timeDiff5);
		}
		if (timeDiff6 != null) {
			timeDiff6.data = getDataWithBins(timeDiff6.data_original, binValue, timeDiff6.minX, timeDiff6.maxX, nBins, bins);
			data.push(timeDiff6);
		}
		onOffPlot.setData(data);
	    onOffPlot.setupGrid();
	    onOffPlot.draw();
		overviewPlot.setData(data);
		overviewPlot.setupGrid();
		overviewPlot.draw();
	}
}//end of reBinData

