var localDeltaTdata = [];
var options = "";
var minx, maxx, mean, deviation, numberOfEntries;
var yAxisLabel = "number of entries/time bin";
var xAxisLabel = "delta T (ns)";
var currentBinValue = 1.25;
var chartNum = 0;
var loadCount = 0;


function saveDeltaTChart(name_id, div_id, run_id) {
	console.log("it gets here " + name_id);
	var filename = document.getElementById(name_id);
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
	var values = new Array();
	console.log(filename);
	$.each(serialized, function(index,element){
	     values.push(element.value);
	   });	 
	var rc = true;
	if (filename != null) {
		if (filename.value != "") {
			var canvas = localDeltaTdata[0].onOffPlot.getCanvas();			
			var image = canvas.toDataURL("image/png");
			image = image.replace('data:image/png;base64,', '');
			$.ajax({
				url: "../analysis/save-plot.jsp",
				type: 'POST',
				data: { imagedata: image, filename: filename.value, id: run_id, metadata: values},
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
}//end of saveChart

options = {
        axisLabels: {
            show: true
        },		
        legend: {  
            show: false
        },  
        lines: { 
        	show: true, 
        	fill: false, 
        	lineWidth: 2.0 
        },
        xaxis: { 
        	tickDecimals: 0
        },
		grid: {
			hoverable: true,
			clickable: true
		},	
		yaxes: {
			axisLabelUseCanvas: true
		},
		xaxes: {
			axisLabelUseCanvas: true			
		}
	};

function onDataLoad() {
	loadJSON(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoadChart(json);
		});
	});
}//end of onDataLoad1

function loadJSON(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/deltaTHistogram", true); 
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}//end of loadJSON

function onDataLoadChart(json) {	
	if (json.tdDeltaT) {
		data = [];
		if (json.tdDeltaT != null) {
			tdDeltaTdata = json.tdDeltaT;
			//console.log(tdDeltaTdata);
			localDeltaTdata[0]={onOffPlot: "", DeltaTdata: tdDeltaTdata, data: "", originalMinX: tdDeltaTdata.minX, originalMaxX: 0,
					originalMinY: tdDeltaTdata.minY, originalMaxY: 0, numberOfEntries: 0, mean: 0, stddev: 0, label: tdDeltaTdata.label, 
					maxBins: tdDeltaTdata.maxBins, binValue: tdDeltaTdata.binValue, currentBinValue: tdDeltaTdata.binValue};
			//console.log(localDeltaTdata[0]);
			tdDeltaTdata.data = getDataWithBins(tdDeltaTdata.data_original, tdDeltaTdata.binValue, tdDeltaTdata.minX, tdDeltaTdata.maxX, tdDeltaTdata.nBins, tdDeltaTdata.bins);
			//console.log(tdDeltaTdata);
			data.push(tdDeltaTdata);
			localDeltaTdata[0].data = data;
		}
		var onOffPlot = $.plot("#deltaTChart", data, options);
		localDeltaTdata[0].onOffPlot = onOffPlot;
		setDataStats();
		setStatsLegend();
		writeLegend();

		$("#rangeDeltaT").attr({"min":tdDeltaTdata.binValue, "max":Math.floor(tdDeltaTdata.maxBins), "value": tdDeltaTdata.binValue, "step": tdDeltaTdata.binValue});
		$("#binWidthDeltaT").attr({"min":tdDeltaTdata.binValue, "max":Math.floor(tdDeltaTdata.maxBins), "value": tdDeltaTdata.binValue, "step": tdDeltaTdata.binValue});
	    $('#rangeDeltaT').on('input', function(){
	        $('#binWidthDeltaT').val($('#rangeDeltaT').val());
	        if ($('#rangeDeltaT').val() > 0) {
	        	localDeltaTdata[0].currentBinValue = $('#rangeDeltaT').val();
	        	reBinData($('#rangeDeltaT').val(), tdDeltaTdata, data, onOffPlot);       
	    		writeLegend();
	        }
	    });
	    $('#binWidthDeltaT').on('change', function(){
	        $('#rangeDeltaT').val($('#binWidthDeltaT').val());
	        if ($('#binWidthDeltaT').val() > 0) {
	        	localDeltaTdata[0].currentBinValue = $('#binWidthDeltaT').val();
	        	reBinData($('#binWidthDeltaT').val(),tdDeltaTdata, data, onOffPlot);
	    		writeLegend();
	        }
	    }); 
		writeLegend();
	}
}//end of onDataLoadChart

function setDataStats() {
	localDeltaTdata[0].mean = mean;
	localDeltaTdata[0].stddev = deviation;
	localDeltaTdata[0].numberOfEntries = numberOfEntries;
	localDeltaTdata[0].originalMinX = localDeltaTdata[0].onOffPlot.getAxes().xaxis.min;
	localDeltaTdata[0].originalMaxX = localDeltaTdata[0].onOffPlot.getAxes().xaxis.max;
	localDeltaTdata[0].originalMinY = localDeltaTdata[0].onOffPlot.getAxes().yaxis.min;
	localDeltaTdata[0].originalMaxY = localDeltaTdata[0].onOffPlot.getAxes().yaxis.max;
}//end of setDataStats

function setStatsLegend() {
	var meandiv = document.getElementById("mean");
	meandiv.innerHTML = "Mean: "+parseFloat(localDeltaTdata[0].mean).toFixed(2);
	var stddevdiv = document.getElementById("stddev");
	stddevdiv.innerHTML = "Std Dev: "+parseFloat(localDeltaTdata[0].stddev).toFixed(2);
}//end of setStatsLegend

function getDataWithBins(rawData, localBinValue, minX, maxX, nBins, bins) {
	//create histogram data
    var outputFinal = [];
	if (rawData != null) {
		binValue = localBinValue;
		var histogram = d3.layout.histogram();
		histogram.bins(bins);
		var data = histogram(rawData);
		//minx = Math.min.apply(Math,rawData);
		//maxx = Math.max.apply(Math,rawData);
		mean = d3.mean(rawData);
		deviation = d3.deviation(rawData);
		numberOfEntries = rawData.length;
		for ( var i = 0; i < data.length; i++ ) {
	    	outputFinal.push([data[i].x, data[i].y]);
	    	outputFinal.push([data[i].x + data[i].dx, data[i].y]);
	    } 
	}
    return outputFinal;	
}//end of getDataWithBins

function reBinData(binValue, deltaTdata, data, onOffPlot) {
	if (binValue > 0) {
	  	var plotData = onOffPlot.getData();
		bins = [];
		nBins = Math.ceil(deltaTdata.maxBins / binValue);
		for (var i = (deltaTdata.minX*1.00); i < (deltaTdata.maxX*1.00+binValue*1.00); i += (binValue*1.00)) {
			bins.push(i);
		}
		data = [];
		if (deltaTdata != null) {
			deltaTdata.data = getDataWithBins(deltaTdata.data_original, binValue, deltaTdata.minX, deltaTdata.maxX, nBins, bins);
			data.push(deltaTdata);
		}
		onOffPlot.setData(data);
	    onOffPlot.setupGrid();
	    onOffPlot.draw();
	}
}//end of reBinData

function writeLegend() {
	var context = localDeltaTdata[0].onOffPlot.getCanvas().getContext('2d');
	context.lineWidth=3;
	context.fillStyle="#000000";
	context.lineStyle="#ffff00";
	context.font="12px sans-serif";
	context.save();
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
	var dTcaption = "";
	$.each(serialized, function(index,element){
		var val = element.value;
		if (val.indexOf("deltaTIDs") > -1) {
			dTcaption = val.substring(val.indexOf("Delta T:"), val.length);
		}
	   });	 
	context.textAlign = "Shower Study - "+dTcaption;
	context.fillText("Shower Study - "+dTcaption, 90, 20);
	context.font="10px sans-serif";
	context.textAlign = localDeltaTdata[0].label;
	context.fillText(localDeltaTdata[0].label, 130, 30);
	context.textAlign = '# of Entries: '+ localDeltaTdata[0].numberOfEntries;
	context.fillText('# of Entries: '+ localDeltaTdata[0].numberOfEntries, 140, 40);
	var values = new Array();
	var xcoord = 50;
	var ycoord = 0;
	var yspace = 10;	
	ycoord = 50;
	$.each(serialized, function(index,element){
		var val = element.value;
		if (val.indexOf("caption") > -1) {
			var caption = val.substring(val.indexOf("Data"), val.length);
			var captionArray = caption.split("\n");
			for (var i = 0; i < captionArray.length; i++) {
				var printText = captionArray[i];
				if (captionArray[i].length > 38) {
					printText = captionArray[i].substring(0, 38);
				}
				ycoord += yspace; 
				context.fillText(printText, xcoord, ycoord);				
			}
		}
	   });	 
	context.font="12px sans-serif";
	context.textAlign = xAxisLabel;
	context.fillText(xAxisLabel, 100, 420);	
	context.translate(0, 150);
	context.rotate(-Math.PI / 2);
	context.textAlign = yAxisLabel;
	context.fillText(yAxisLabel, 0, 40);	
	context.restore();		
}//end of writeLegend


redrawPlotX = function(newX, type) {
	var plot, label, entries;
	plot = localDeltaTdata[0].onOffPlot;
	entries = localDeltaTdata[0].numberOfEntries;
	label = localDeltaTdata[0].label;
	originalminx = localDeltaTdata[0].originalMinX;
	originalmaxx = localDeltaTdata[0].originalMaxX;
	var axes = plot.getAxes();
	if (type == "min") {
		axes.xaxis.options.min = newX;
	} else {
		axes.xaxis.options.max = newX;
	}
	plot.setupGrid();
	plot.draw();
	writeLegend();	
}//end of redrawPlotX

redrawPlotY = function(newY, type) {
	var plot, label, entries;
	plot = localDeltaTdata[0].onOffPlot;
	entries = localDeltaTdata[0].numberOfEntries;
	label = localDeltaTdata[0].label;
	var axes = plot.getAxes();
	if (type == "min") {
		axes.yaxis.options.min = newY;
	} else {
		axes.yaxis.options.max = newY;
	}
	plot.setupGrid();
	plot.draw();
	writeLegend();	
}//end of redrawPlotY

redrawPlotFitX = function(newMinX, newMaxX) {
	if (newMinX == null || newMinX == "") {
		newMinX = localDeltaTdata[0].originalMinX;
	}
	if (newMaxX == null || newMaxX == "") {
		newMaxX = localDeltaTdata[0].originalMaxX;
	}
	var originalminx, originalmaxx, plot, label, entries, original;
	plot = localDeltaTdata[0].onOffPlot;
	originalminx = localDeltaTdata[0].originalMinX;
	originalmaxx = localDeltaTdata[0].originalMaxX;
	entries = localDeltaTdata[0].numberOfEntries;
	label = localDeltaTdata[0].label;
	original = localDeltaTdata[0].DeltaTdata;
	localdata = [];
	if (original != null) {
		var fittedData = fitData(original.data_original, newMinX, newMaxX);
		var nBins = Math.ceil((newMaxX - newMinX) / localDeltaTdata[0].currentBinValue);
		var bins = [];		
		for (var i = (newMinX*1.00); i < (newMaxX*1.00+binValue); i += (binValue)) {
			bins.push(i);
		}
		original.data = getDataWithBins(fittedData, localDeltaTdata[0].currentBinValue, newMinX, newMaxX, nBins, bins);
   		setDataStats();
   		setStatsLegend();	      		
   		localdata.push(original);
   		plot = $.plot("#deltaTChart", localdata, options);
   		writeLegend();
	}
}//end of redrawPlotFitX

function fitData(data_original, newMinX, newMaxX) {
	var fittedData = [];
	for (var i = 0; i < data_original.length; i++) {
		if (data_original[i] >= newMinX && data_original[i] <= newMaxX) {
			fittedData.push(data_original[i]);
		}
	}	
	return fittedData;
}//end of fitData

resetAll = function() {
	var plot, originalminx, originalmaxx, label, entries, original;
	document.getElementById("minFitX").value = "";
	document.getElementById("maxFitX").value = "";;
	document.getElementById("minX").value = "";;
	document.getElementById("maxX").value = "";;
	document.getElementById("minY").value = "";;
	document.getElementById("maxY").value = "";;
	$("#rangeDeltaT").attr({"min":localDeltaTdata[0].DeltaTdata.binValue, "max":Math.floor(localDeltaTdata[0].DeltaTdata.maxBins), "value": localDeltaTdata[0].DeltaTdata.binValue, "step": localDeltaTdata[0].DeltaTdata.binValue});
	$("#binWidthDeltaT").attr({"min":localDeltaTdata[0].DeltaTdata.binValue, "max":Math.floor(localDeltaTdata[0].DeltaTdata.maxBins), "value": localDeltaTdata[0].DeltaTdata.binValue, "step": localDeltaTdata[0].DeltaTdata.binValue});
	original = localDeltaTdata[0].DeltaTdata;
	localdata = [];
	if (original != null) {
		original.data = getDataWithBins(original.data_original, original.binValue, original.minX, original.maxX, original.nBins, original.bins);
   		setDataStats();
   		setStatsLegend();	      		
   		localdata.push(original);
	}
	plot = localDeltaTdata[0].onOffPlot;
	originalminx = localDeltaTdata[0].originalMinX;
	originalmaxx = localDeltaTdata[0].originalMaxX;
	entries = localDeltaTdata[0].numberOfEntries;
	label = localDeltaTdata[0].label;
	var axes = plot.getAxes();	
	axes.xaxis.options.min = originalminx;
	axes.xaxis.options.max = originalmaxx;
	plot = $.plot("#deltaTChart", localdata, options);
	plot.setupGrid();
	plot.draw();
	writeLegend();	
}//end of resetAll

Number.prototype.toFixedDown = function(digits) {
	  var n = this - Math.pow(10, -digits)/2;
	  n += n / Math.pow(2, 53); // added 1360765523: 17.56.toFixedDown(2) === "17.56"
	  return n.toFixed(digits);
}

function intToFloat(num, decPlaces) { 
	return num + '.' + Array(decPlaces + 1).join('0'); 
}

