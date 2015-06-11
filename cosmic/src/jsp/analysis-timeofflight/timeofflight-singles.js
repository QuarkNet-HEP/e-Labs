var onOffPlot1, onOffPlot2, onOffPlot3, onOffPlot4, onOffPlot5, onOffPlot6;
var timeDiff1, timeDiff2, timeDiff3, timeDiff4, timeDiff5, timeDiff6;
var data1 = []; //data that will be sent to the chart
var data2 = []; //data that will be sent to the chart
var data3 = []; //data that will be sent to the chart
var data4 = []; //data that will be sent to the chart
var data5 = []; //data that will be sent to the chart
var data6 = []; //data that will be sent to the chart
var options = "";
var originalMinX1, originalMaxX1;
var originalMinY1, originalMaxY1;
var originalMinX2, originalMaxX2;
var originalMinY2, originalMaxY2;
var originalMinX3, originalMaxX3;
var originalMinY3, originalMaxY3;
var originalMinX4, originalMaxX4;
var originalMinY4, originalMaxY4;
var originalMinX5, originalMaxX5;
var originalMinY5, originalMaxY5;
var originalMinX6, originalMaxX6;
var originalMinY6, originalMaxY6;
var numberOfEntries1, numberOfEntries2, numberOfEntries3, numberOfEntries4, numberOfEntries5, numberOfEntries6;
var mean1, mean2, mean3, mean4, mean5, mean6;
var stddev1, stddev2, stddev3, stddev4, stddev5, stddev6;
var label1, label2, label3, label4, label5, label6;
var yAxisLabel;
yAxisLabel = "number of entries/time bin";

resetPlotX = function(ndx) {
	var plot, originalminx, originalmaxx, label, entries;
	var inputObjectMin = document.getElementById("minX"+ndx);
	inputObjectMin.value = "";
	var inputObjectMax = document.getElementById("maxX"+ndx);
	inputObjectMax.value = "";
	switch (ndx) {
		case (1):
			plot = onOffPlot1;
			originalminx = originalMinX1;
			originalmaxx = originalMaxX1;
			entries = numberOfEntries1;
			label = label1;
			break;
		case (2):
			plot = onOffPlot2;	
			originalminx = originalMinX2;
			originalmaxx = originalMaxX2;
			entries = numberOfEntries2;
			label = label2;
			break;
		case (3):
			plot = onOffPlot3;	
			originalminx = originalMinX3;
			originalmaxx = originalMaxX3;
			entries = numberOfEntries3;
			label = label3;
			break;
		case (4):
			plot = onOffPlot4;	
			originalminx = originalMinX4;
			originalmaxx = originalMaxX4;
			entries = numberOfEntries4;
			label = label4;
			break;
		case (5):
			plot = onOffPlot5;	
			originalminx = originalMinX5;
			originalmaxx = originalMaxX5;
			entries = numberOfEntries5;
			label = label5;
			break;
		case (6):
			plot = onOffPlot6;	
			originalminx = originalMinX6;
			originalmaxx = originalMaxX6;
			entries = numberOfEntries6;
			label = label6;
			break;
	}
	var axes = plot.getAxes();	
	axes.xaxis.options.min = originalminx;
	axes.xaxis.options.max = originalmaxx;
	plot.setupGrid();
	plot.draw();
	writeLegend(plot.getCanvas(), entries, label);	
}
redrawPlotX = function(ndx, newX, type) {
	var plot, label, entries;
	switch (ndx) {
		case (1):
			plot = onOffPlot1;
			entries = numberOfEntries1;
			label = label1;
			break;
		case (2):
			plot = onOffPlot2;
			entries = numberOfEntries2;
			label = label2;
			break;
		case (3):
			plot = onOffPlot3;
			entries = numberOfEntries3;
			label = label3;
			break;
		case (4):
			plot = onOffPlot4;
			entries = numberOfEntries4;
			label = label4;
			break;
		case (5):
			plot = onOffPlot5;
			entries = numberOfEntries5;
			label = label5;
			break;
		case (6):
			plot = onOffPlot6;
			entries = numberOfEntries6;
			label = label6;
			break;
	}
	var axes = plot.getAxes();
	if (type == "min") {
		axes.xaxis.options.min = newX;
	} else {
		axes.xaxis.options.max = newX;
	}
	plot.setupGrid();
	plot.draw();
	writeLegend(plot.getCanvas(), entries, label);	
}

resetPlotY = function(ndx) {
	var plot, originalminy, originalmaxy, label, entries;
	var inputObjectMin = document.getElementById("minY"+ndx);
	inputObjectMin.value = "";
	var inputObjectMax = document.getElementById("maxY"+ndx);
	inputObjectMax.value = "";
	switch (ndx) {
		case (1):
			plot = onOffPlot1;
			originalminy = originalMinY1;
			originalmaxy = originalMaxY1;
			entries = numberOfEntries1;
			label = label1;
			break;
		case (2):
			plot = onOffPlot2;	
			originalminy = originalMinY2;
			originalmaxy = originalMaxY2;
			entries = numberOfEntries2;
			label = label2;
			break;
		case (3):
			plot = onOffPlot3;	
			originalminy = originalMinY3;
			originalmaxy = originalMaxY3;
			entries = numberOfEntries3;
			label = label3;
			break;
		case (4):
			plot = onOffPlot4;	
			originalminy = originalMinY4;
			originalmaxy = originalMaxY4;
			entries = numberOfEntries4;
			label = label4;
			break;
		case (5):
			plot = onOffPlot5;	
			originalminy = originalMinY5;
			originalmaxy = originalMaxY5;
			entries = numberOfEntries5;
			label = label5;
			break;
		case (6):
			plot = onOffPlot6;	
			originalminy = originalMinY6;
			originalmaxy = originalMaxY6;
			entries = numberOfEntries6;
			label = label6;
			break;
	}
	var axes = plot.getAxes();	
	axes.yaxis.options.min = originalminy;
	axes.yaxis.options.max = originalmaxy;
	plot.setupGrid();
	plot.draw();
	writeLegend(plot.getCanvas(), entries, label);		
}
redrawPlotY = function(ndx, newY, type) {
	var plot, label, entries;
	switch (ndx) {
		case (1):
			plot = onOffPlot1;
			entries = numberOfEntries1;
			label = label1;
			break;
		case (2):
			plot = onOffPlot2;
			entries = numberOfEntries2;
			label = label2;
			break;
		case (3):
			plot = onOffPlot3;
			entries = numberOfEntries3;
			label = label3;
			break;
		case (4):
			plot = onOffPlot4;
			entries = numberOfEntries4;
			label = label4;
			break;
		case (5):
			plot = onOffPlot5;
			entries = numberOfEntries5;
			label = label5;
			break;
		case (6):
			plot = onOffPlot6;
			entries = numberOfEntries6;
			label = label6;
			break;
	}
	var axes = plot.getAxes();
	if (type == "min") {
		axes.yaxis.options.min = newY;
	} else {
		axes.yaxis.options.max = newY;
	}
	plot.setupGrid();
	plot.draw();
	writeLegend(plot.getCanvas(), entries, label);	
}
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
    xobj.open('GET', outputDir.value+"/timeOfFlightPlotData", true); 
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
	if (json.timediff1 != null) {
		buildTimeDiff(json.timediff1,data1,"1");
	} else {
		var div = document.getElementById("chart1");
		div.style.display="none";
	}
	timeDiff2 = json.timediff2;
	if (json.timediff2 != null) {
		buildTimeDiff(json.timediff2,data2,"2");
	} else {
		var div = document.getElementById("chart2");
		div.style.display="none";
	}
	timeDiff3 = json.timediff3;
	if (json.timediff3 != null) {
		buildTimeDiff(json.timediff3,data3,"3");
	} else {
		var div = document.getElementById("chart3");
		div.style.display="none";
	}
	timeDiff4 = json.timediff4;
	if (json.timediff4 != null) {
		buildTimeDiff(json.timediff4,data4,"4");
	} else {
		var div = document.getElementById("chart4");
		div.style.display="none";
	}		
	timeDiff5 = json.timediff5;
	if (json.timediff5 != null) {
		buildTimeDiff(json.timediff5,data5,"5");
	} else {
		var div = document.getElementById("chart5");
		div.style.display="none";
	}
	timeDiff6 = json.timediff6;
	if (json.timediff6 != null) {
		buildTimeDiff(json.timediff6,data6,"6");
	} else {
		var div = document.getElementById("chart6");
		div.style.display="none";
	}
}//end of onDataLoad	

function buildTimeDiff(timediff, data, diffNum) {
	if (timediff != null) {
		timediff.data = getDataWithBins(timediff.data, timediff.binValue, timediff.minX, timediff.maxX, timediff.nBins, timediff.nBins);
		data.push(timediff);
	}
	$("#range"+diffNum).attr({"min":Math.floor(1), "max":Math.floor(timediff.maxBins), "value": timediff.binValue});
	$("#binWidth"+diffNum).attr({"min":Math.floor(1), "max":Math.floor(timediff.maxBins), "value": timediff.binValue});

	var onOffPlot = $.plot("#placeholder"+diffNum, data, options);

    $('#range'+diffNum).on('input', function(){
        $('#binWidth'+diffNum).val($('#range'+diffNum).val());
        if ($('#range'+diffNum).val() > 0) {
            reBinData($('#range'+diffNum).val(),diffNum,timediff, data, onOffPlot);       
    		writeLegend(onOffPlot.getCanvas(), timediff.numberOfEntries, timediff.label);
        }
    });
    $('#binWidth'+diffNum).on('change', function(){
        $('#range'+diffNum).val($('#binWidth'+diffNum).val());
        if ($('#binWidth'+diffNum).val() > 0) {
        	reBinData($('#binWidth'+diffNum).val(),diffNum,timediff, data, onOffPlot);
    		writeLegend(onOffPlot.getCanvas(), timediff.numberOfEntries, timediff.label);
        }
    });
    
    $("<div class='button' style='left:20px;top:20px'>reset</div>")
	.appendTo($("#resetbutton"+diffNum))
	.click(function (event) {
		event.preventDefault();
		reBinData(json.binValue,diffNum,timediff, data, onOffPlot);
		onOffPlot = $.plot("#placeholder"+diffNum, data, options);
		$(".message"+diffNum).html("");
		$(".click").html("");
		
	});	
    switch (diffNum) {
    	case ("1"):
    		onOffPlot1 = onOffPlot;
    		originalMinX1 = timediff.minX;
    		originalMaxX1 = timediff.maxX;
    		originalMinY1 = onOffPlot1.getAxes().yaxis.min;
    		originalMaxY1 = onOffPlot1.getAxes().yaxis.max;
    		numberOfEntries1 = timediff.numberOfEntries;
    		label1 = timediff.label;
    		var mean = document.getElementById("mean1");
    		mean.innerHTML = "Mean: "+timediff.mean;
    		var stddev = document.getElementById("stddev1");
    		stddev.innerHTML = "Std Dev: "+timediff.stddev;
    		writeLegend(onOffPlot1.getCanvas(), numberOfEntries1, label1);
    		break;
    	case ("2"):
    		onOffPlot2 = onOffPlot;
    		originalMinX2 = timediff.minX;
    		originalMaxX2 = timediff.maxX;
    		originalMinY2 = onOffPlot2.getAxes().yaxis.min;
    		originalMaxY2 = onOffPlot2.getAxes().yaxis.max;
    		numberOfEntries2 = timediff.numberOfEntries;
    		label2 = timediff.label;
    		var mean = document.getElementById("mean2");
    		mean.innerHTML = "Mean: "+timediff.mean;
    		var stddev = document.getElementById("stddev2");
    		stddev.innerHTML = "Std Dev: "+timediff.stddev;
    		writeLegend(onOffPlot2.getCanvas(), numberOfEntries2, label2);
    		break;
    	case ("3"):
    		onOffPlot3 = onOffPlot;
    		originalMinX3 = timediff.minX;
    		originalMaxX3 = timediff.maxX;
    		originalMinY3 = onOffPlot3.getAxes().yaxis.min;
    		originalMaxY3 = onOffPlot3.getAxes().yaxis.max;
    		numberOfEntries3 = timediff.numberOfEntries;
    		label3 = timediff.label;
    		var mean = document.getElementById("mean3");
    		mean.innerHTML = "Mean: "+timediff.mean;
    		var stddev = document.getElementById("stddev3");
    		stddev.innerHTML = "Std Dev: "+timediff.stddev;
    		writeLegend(onOffPlot3.getCanvas(), numberOfEntries3, label3);
    		break;
    	case ("4"):
    		onOffPlot4 = onOffPlot;
    		originalMinX4 = timediff.minX;
    		originalMaxX4 = timediff.maxX;
    		originalMinY4 = onOffPlot4.getAxes().yaxis.min;
    		originalMaxY4 = onOffPlot4.getAxes().yaxis.max;
    		numberOfEntries4 = timediff.numberOfEntries;
    		label4 = timediff.label;
    		var mean = document.getElementById("mean4");
    		mean.innerHTML = "Mean: "+timediff.mean;
    		var stddev = document.getElementById("stddev4");
    		stddev.innerHTML = "Std Dev: "+timediff.stddev;
   		writeLegend(onOffPlot4.getCanvas(), numberOfEntries4, label4);
    		break;
    	case ("5"):
    		onOffPlot5 = onOffPlot;
    		originalMinX5 = timediff.minX;
    		originalMaxX5 = timediff.maxX;
    		originalMinY5 = onOffPlot5.getAxes().yaxis.min;
    		originalMaxY5 = onOffPlot5.getAxes().yaxis.max;
    		numberOfEntries5 = timediff.numberOfEntries;
    		label5 = timediff.label;
    		var mean = document.getElementById("mean5");
    		mean.innerHTML = "Mean: "+timediff.mean;
    		var stddev = document.getElementById("stddev5");
    		stddev.innerHTML = "Std Dev: "+timediff.stddev;
    		writeLegend(onOffPlot5.getCanvas(), numberOfEntries5, label5);
    		break;
    	case ("6"):
    		onOffPlot6 = onOffPlot;
    		originalMinX6 = timediff.minX;
    		originalMaxX6 = timediff.maxX;
    		originalMinY6 = onOffPlot6.getAxes().yaxis.min;
    		originalMaxY6 = onOffPlot6.getAxes().yaxis.max;
    		numberOfEntries6 = timediff.numberOfEntries;
    		label6 = timediff.label;
    		var mean = document.getElementById("mean6");
    		mean.innerHTML = "Mean: "+timediff.mean;
    		var stddev = document.getElementById("stddev6");
    		stddev.innerHTML = "Std Dev: "+timediff.stddev;
    		writeLegend(onOffPlot6.getCanvas(), numberOfEntries6, label6);
    		break;
    }
}//end of generic buildTimeDiff

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
	    } 
	}
    return outputFinal;	
}//end of getDataWithBins

function reBinData(binValue, diffNum, timediff, data, onOffPlot) {
	if (binValue > 0) {
	  	var plotData = onOffPlot.getData();
		bins = [];
		nBins = Math.ceil(timediff.maxBins / binValue);
		for (var i = (timediff.minX*1.00000)+0.00001; i < (timediff.maxX*1.00000+binValue*1.00000); i += (binValue*1.00000)) {
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

function writeLegend(canvas, numberOfEntries, label) {
	var context = canvas.getContext('2d');
	context.lineWidth=3;
	context.fillStyle="#000000";
	context.lineStyle="#ffff00";
	context.font="12px sans-serif";
	context.save();
	context.textAlign = "Time Of Flight Study";
	context.fillText("Time Of Flight Study", 90, 20);
	context.font="10px sans-serif";
	context.textAlign = label;
	context.fillText(label, 130, 30);
	context.textAlign = '# of Entries: '+ numberOfEntries;
	context.fillText('# of Entries: '+ numberOfEntries, 170, 40);
	context.font="8px sans-serif";
	context.translate(0, 150);
	context.rotate(-Math.PI / 2);
	context.textAlign = yAxisLabel;
	context.fillText(yAxisLabel, 0, 30);
	context.restore();		
}//end of writeLegend

Number.prototype.toFixedDown = function(digits) {
	  var n = this - Math.pow(10, -digits)/2;
	  n += n / Math.pow(2, 53); // added 1360765523: 17.56.toFixedDown(2) === "17.56"
	  return n.toFixed(digits);
}

function intToFloat(num, decPlaces) { 
	return num + '.' + Array(decPlaces + 1).join('0'); 
}
