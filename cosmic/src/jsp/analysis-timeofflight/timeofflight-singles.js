var tofCollection = [,,,,,,];
var options = "";
var minx, maxx, mean, deviation, numberOfEntries;
var yAxisLabel = "number of entries/time bin";
var xAxisLabel = "relative time between channels (ns)";
var currentBinValue = 1.25;
var chartNum = 0;
var loadCount = 0;

function onDataLoad1() {
	loadJSON1(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoadChart1(json);
		});
	});
}//end of onDataLoad1

function loadJSON1(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/timeOfFlightPlotData1", true); 
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}//end of loadJSON1

function onDataLoadChart1(json) {	
	//var start = new Date().getTime();
	loadCount++;
	if (json.td1) {
		buildIndividualDataSets(json.td1, "1", 0, document.getElementById("chart1"));
	}
	//var end = new Date().getTime();
	//var time = end - start;
	//console.log("Chart 1: "+time);
}//end of onDataLoadChart1	

function onDataLoad2() {
	loadJSON2(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoadChart2(json);
		});
	});
}//end of onDataLoad2

function loadJSON2(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/timeOfFlightPlotData2", true); 
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}//end of loadJSON2

function onDataLoadChart2(json) {	
	//var start = new Date().getTime();
	loadCount++;
	if (json.td2) {
		buildIndividualDataSets(json.td2, "2", 1, document.getElementById("chart2"));
	}
	//var end = new Date().getTime();
	//var time = end - start;
	//console.log("Chart 2: "+time);
}//end of onDataLoadChart2

function onDataLoad3() {
	loadJSON3(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoadChart3(json);
		});
	});
}//end of onDataLoad3

function loadJSON3(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/timeOfFlightPlotData3", true); 
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}//end of loadJSON3

function onDataLoadChart3(json) {	
	//var start = new Date().getTime();
	loadCount++;
	if (json.td3) {
		buildIndividualDataSets(json.td3, "3", 2, document.getElementById("chart3"));
	}
	//var end = new Date().getTime();
	//var time = end - start;
	//console.log("Chart 3: "+time);
}//end of onDataLoadChart3

function onDataLoad4() {
	loadJSON4(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoadChart4(json);
		});
	});
}//end of onDataLoad4

function loadJSON4(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/timeOfFlightPlotData4", true); 
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}//end of loadJSON4

function onDataLoadChart4(json) {	
	//var start = new Date().getTime();
	loadCount++;
	if (json.td4) {
		buildIndividualDataSets(json.td4, "4", 3, document.getElementById("chart4"));
	}
	//var end = new Date().getTime();
	//var time = end - start;
	//console.log("Chart 4: "+time);
}//end of onDataLoadChart4

function onDataLoad5() {
	loadJSON5(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoadChart5(json);
		});
	});
}//end of onDataLoad5

function loadJSON5(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/timeOfFlightPlotData5", true); 
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}//end of loadJSON5

function onDataLoadChart5(json) {	
	//var start = new Date().getTime();
	loadCount++;
	if (json.td5) {
		buildIndividualDataSets(json.td5, "5", 4, document.getElementById("chart5"));
	}
	//var end = new Date().getTime();
	//var time = end - start;
	//console.log("Chart 4: "+time);
}//end of onDataLoadChart4

function onDataLoad6() {
	loadJSON6(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoadChart6(json);
		});
	});
}//end of onDataLoad6

function loadJSON6(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/timeOfFlightPlotData6", true); 
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}//end of loadJSON6

function onDataLoadChart6(json) {	
	//var start = new Date().getTime();
	//buildIndividualDataSets(json.td1, "1", 0, document.getElementById("chart1"));
	//buildIndividualDataSets(json.td2, "2", 1, document.getElementById("chart2"));
	//buildIndividualDataSets(json.td3, "3", 2, document.getElementById("chart3"));
	//buildIndividualDataSets(json.td4, "4", 3, document.getElementById("chart4"));
	//buildIndividualDataSets(json.td5, "5", 4, document.getElementById("chart5"));
	loadCount++;
	if (json.td6) {
		buildIndividualDataSets(json.td6, "6", 5, document.getElementById("chart6"));
	}
	//var end = new Date().getTime();
	//var time = end - start;
	//console.log("Chart 6: "+time);
}//end of onDataLoadChart6

function buildIndividualDataSets(timediff, ndx, arrayndx, div) {
	if (timediff != null) {
		tofCollection[arrayndx]={onOffPlot: "", timeDiff: timediff, data: "", originalMinX: timediff.minX, originalMaxX: 0,
				originalMinY: timediff.minY, originalMaxY: 0, numberOfEntries: 0, mean: 0, stddev: 0, label: timediff.label, 
				maxBins: timediff.maxBins, binValue: timediff.binValue, ndx: ndx, chart: div, currentBinValue: timediff.binValue};
		buildTimeDiff(timediff, ndx);
	} else {
		tofCollection[arrayndx] = "";
		div.style.display="none";
	}
}//end of buildIndividualDataSets

function buildTimeDiff(timediff, diffNum) {
    var feedback = document.getElementById("feedback");
    feedback.innerHTML = "<strong>Chart "+diffNum+" is loading...</strong>";
    //loadCount++;--SB, 10/3/16, put this in each onDataLoadChart# instead.
	data = [];
	if (timediff != null) {
		timediff.data = getDataWithBins(timediff.data_original, timediff.binValue, timediff.minX, timediff.maxX, timediff.nBins, timediff.bins);
		data.push(timediff);
		tofCollection[diffNum-1].data = data;
	}
	var onOffPlot = $.plot("#placeholder"+diffNum, data, options);
	tofCollection[diffNum-1].onOffPlot = onOffPlot;
	setDataStats(diffNum);
	setStatsLegend(diffNum);

	$("#range"+diffNum).attr({"min":timediff.binValue, "max":Math.floor(timediff.maxBins), "value": timediff.binValue, "step": timediff.binValue});
	$("#binWidth"+diffNum).attr({"min":timediff.binValue, "max":Math.floor(timediff.maxBins), "value": timediff.binValue, "step": timediff.binValue});
    $('#range'+diffNum).on('input', function(){
        $('#binWidth'+diffNum).val($('#range'+diffNum).val());
        if ($('#range'+diffNum).val() > 0) {
        	tofCollection[diffNum-1].currentBinValue = $('#range'+diffNum).val();
        	reBinData($('#range'+diffNum).val(),diffNum,timediff, data, onOffPlot);       
    		writeLegend(diffNum);
        }
    });
    $('#binWidth'+diffNum).on('change', function(){
        $('#range'+diffNum).val($('#binWidth'+diffNum).val());
        if ($('#binWidth'+diffNum).val() > 0) {
        	tofCollection[diffNum-1].currentBinValue = $('#binWidth'+diffNum).val();
        	reBinData($('#binWidth'+diffNum).val(),diffNum,timediff, data, onOffPlot);
    		writeLegend(diffNum);
        }
    });    
    writeLegend(diffNum);
    if (loadCount == 6) {
    	feedback.innerHTML = "";
    }
}//end of generic buildTimeDiff

function setDataStats(ndx) {
	tofCollection[ndx-1].mean = mean;
	tofCollection[ndx-1].stddev = deviation;
	tofCollection[ndx-1].numberOfEntries = numberOfEntries;
	tofCollection[ndx-1].originalMinX = tofCollection[ndx-1].onOffPlot.getAxes().xaxis.min;
	tofCollection[ndx-1].originalMaxX = tofCollection[ndx-1].onOffPlot.getAxes().xaxis.max;
	tofCollection[ndx-1].originalMinY = tofCollection[ndx-1].onOffPlot.getAxes().yaxis.min;
	tofCollection[ndx-1].originalMaxY = tofCollection[ndx-1].onOffPlot.getAxes().yaxis.max;
}//end of setDataStats

function setStatsLegend(diffNum) {
	var meandiv = document.getElementById("mean"+diffNum);
	meandiv.innerHTML = "Mean: "+parseFloat(tofCollection[diffNum-1].mean).toFixed(2);
	var stddevdiv = document.getElementById("stddev"+diffNum);
	stddevdiv.innerHTML = "Std Dev: "+parseFloat(tofCollection[diffNum-1].stddev).toFixed(2);
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

function reBinData(binValue, diffNum, timediff, data, onOffPlot) {
	if (binValue > 0) {
	  	var plotData = onOffPlot.getData();
		bins = [];
		nBins = Math.ceil(timediff.maxBins / binValue);
		for (var i = (timediff.minX*1.00); i < (timediff.maxX*1.00+binValue*1.00); i += (binValue*1.00)) {
			bins.push(i);
		}
		data = [];
		if (timediff != null) {
			timediff.data = getDataWithBins(timediff.data_original, binValue, timediff.minX, timediff.maxX, nBins, bins);
			data.push(timediff);
		}
		onOffPlot.setData(data);
	    onOffPlot.setupGrid();
	    onOffPlot.draw();
	}
}//end of reBinData

function writeLegend(diffNum) {
	var title = document.getElementById("chartTitle"+diffNum);
	title.innerHTML = "<strong>"+tofCollection[diffNum-1].label+"</strong>";
	var context = tofCollection[diffNum-1].onOffPlot.getCanvas().getContext('2d');
	context.lineWidth=3;
	context.fillStyle="#000000";
	context.lineStyle="#ffff00";
	context.font="12px sans-serif";
	context.save();
	context.textAlign = "Time Of Flight Study";
	context.fillText("Time Of Flight Study", 90, 20);
	context.font="10px sans-serif";
	context.textAlign = tofCollection[diffNum-1].label;
	context.fillText(tofCollection[diffNum-1].label, 130, 30);
	context.textAlign = '# of Entries: '+ tofCollection[diffNum-1].numberOfEntries;
	context.fillText('# of Entries: '+ tofCollection[diffNum-1].numberOfEntries, 140, 40);
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
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
	context.font="8px sans-serif";
	context.textAlign = xAxisLabel;
	context.fillText(xAxisLabel, 60, 220);	
	context.translate(0, 150);
	context.rotate(-Math.PI / 2);
	context.textAlign = yAxisLabel;
	context.fillText(yAxisLabel, 0, 40);	
	context.restore();		
}//end of writeLegend

redrawPlotX = function(ndx, newX, type) {
	var plot, label, entries;
	plot = tofCollection[ndx-1].onOffPlot;
	entries = tofCollection[ndx-1].numberOfEntries;
	label = tofCollection[ndx-1].label;
	originalminx = tofCollection[ndx-1].originalMinX;
	originalmaxx = tofCollection[ndx-1].originalMaxX;
	var axes = plot.getAxes();
	if (type == "min") {
		axes.xaxis.options.min = newX;
	} else {
		axes.xaxis.options.max = newX;
	}
	plot.setupGrid();
	plot.draw();
	writeLegend(ndx);	
}//end of redrawPlotX

redrawPlotY = function(ndx, newY, type) {
	var plot, label, entries;
	plot = tofCollection[ndx-1].onOffPlot;
	entries = tofCollection[ndx-1].numberOfEntries;
	label = tofCollection[ndx-1].label;
	var axes = plot.getAxes();
	if (type == "min") {
		axes.yaxis.options.min = newY;
	} else {
		axes.yaxis.options.max = newY;
	}
	plot.setupGrid();
	plot.draw();
	writeLegend(ndx);	
}//end of redrawPlotY

redrawPlotFitX = function(ndx, newMinX, newMaxX) {
	if (newMinX == null || newMinX == "") {
		newMinX = tofCollection[ndx-1].originalMinX;
	}
	if (newMaxX == null || newMaxX == "") {
		newMaxX = tofCollection[ndx-1].originalMaxX;
	}
	var originalminx, originalmaxx, plot, label, entries, original;
	plot = tofCollection[ndx-1].onOffPlot;
	originalminx = tofCollection[ndx-1].originalMinX;
	originalmaxx = tofCollection[ndx-1].originalMaxX;
	entries = tofCollection[ndx-1].numberOfEntries;
	label = tofCollection[ndx-1].label;
	original = tofCollection[ndx-1].timeDiff;
	localdata = [];
	if (original != null) {
		var fittedData = fitData(original.data_original, newMinX, newMaxX);
		var nBins = Math.ceil((newMaxX - newMinX) / tofCollection[ndx-1].currentBinValue);
		var bins = [];		
		for (var i = (newMinX*1.00); i < (newMaxX*1.00+binValue); i += (binValue)) {
			bins.push(i);
		}
		original.data = getDataWithBins(fittedData, tofCollection[ndx-1].currentBinValue, newMinX, newMaxX, nBins, bins);
   		setDataStats(ndx);
   		setStatsLegend(ndx);	      		
   		localdata.push(original);
	}
	plot = $.plot("#placeholder"+ndx, localdata, options);
	writeLegend(ndx);
}//end of redrawPlotFitX

function fitData(data_original, newMinX, newMaxX) {
	var fittedData = [];
	for (var i = 0; i < data_original.length; i++) {
		if (parseFloat(data_original[i]) >= parseFloat(newMinX) && parseFloat(data_original[i]) <= parseFloat(newMaxX)) {
			fittedData.push(data_original[i]);
		}
	}	
	return fittedData;
}//end of fitData

resetAll = function(ndx) {
	var plot, originalminx, originalmaxx, label, entries, original;
	document.getElementById("minFitX"+ndx).value = "";
	document.getElementById("maxFitX"+ndx).value = "";;
	document.getElementById("minX"+ndx).value = "";;
	document.getElementById("maxX"+ndx).value = "";;
	document.getElementById("minY"+ndx).value = "";;
	document.getElementById("maxY"+ndx).value = "";;
	$("#range"+ndx).attr({"min":tofCollection[ndx-1].timeDiff.binValue, "max":Math.floor(tofCollection[ndx-1].timeDiff.maxBins), "value": tofCollection[ndx-1].timeDiff.binValue, "step": tofCollection[ndx-1].timeDiff.binValue});
	$("#binWidth"+ndx).attr({"min":tofCollection[ndx-1].timeDiff.binValue, "max":Math.floor(tofCollection[ndx-1].timeDiff.maxBins), "value": tofCollection[ndx-1].timeDiff.binValue, "step": tofCollection[ndx-1].timeDiff.binValue});
	original = tofCollection[ndx-1].timeDiff;
	localdata = [];
	if (original != null) {
		original.data = getDataWithBins(original.data_original, original.binValue, original.minX, original.maxX, original.nBins, original.bins);
   		setDataStats(ndx);
   		setStatsLegend(ndx);	      		
   		localdata.push(original);
	}
	plot = tofCollection[ndx-1].onOffPlot;
	originalminx = tofCollection[ndx-1].originalMinX;
	originalmaxx = tofCollection[ndx-1].originalMaxX;
	entries = tofCollection[ndx-1].numberOfEntries;
	label = tofCollection[ndx-1].label;
	var axes = plot.getAxes();	
	axes.xaxis.options.min = originalminx;
	axes.xaxis.options.max = originalmaxx;
	plot = $.plot("#placeholder"+ndx, localdata, options);
	plot.setupGrid();
	plot.draw();
	writeLegend(ndx);	
}//end of resetAll

function saveToFChart(ndx, name_id, div_id, run_id) {
	var filename = document.getElementById(name_id);
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
	var values = new Array();
	$.each(serialized, function(index,element){
	     values.push(element.value);
	   });	 
	var rc = true;
	if (filename != null) {
		if (filename.value != "") {
			var canvas = tofCollection[ndx-1].onOffPlot.getCanvas();			
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
}//end of saveTOFChart

function validateAndSaveTOFChart(ndx, name_id, div_id, run_id) {
	if (validatePlotName(name_id)){
		saveToFChart(ndx, name_id, div_id, run_id); return true;
	}else {
  	return false;
	}
}//end of validateAndSaveTOFChart
        	
     	
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

Number.prototype.toFixedDown = function(digits) {
	  var n = this - Math.pow(10, -digits)/2;
	  n += n / Math.pow(2, 53); // added 1360765523: 17.56.toFixedDown(2) === "17.56"
	  return n.toFixed(digits);
}

function intToFloat(num, decPlaces) { 
	return num + '.' + Array(decPlaces + 1).join('0'); 
}

