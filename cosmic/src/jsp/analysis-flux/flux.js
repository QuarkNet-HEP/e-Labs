var fluxData, fluxDataError;
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
    		}
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
		xaxis: {
			mode: "time",
			tickFormatter: function (val, axis) {		
				var d = new Date(val);
				return d.customFormat("#DD#/#MMM#<br />#hh#:#mm#");
			}			
		},
		yaxes: {
			axisLabelUseCanvas: true
		},
		xaxes: [
				{	
					axisLabelUseCanvas: true,
				},
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
				$("#tooltip").html(item.series.label + " at " + x + " = " + y)
					.css({top: item.pageY+5, left: item.pageX+5})
					.fadeIn(200);
			} else {
				$("#tooltip").hide();
			}
		}
	});

}//end of bindZoomingPanningTooltip

togglePlot = function(seriesIdx) {
	  var plotData = onOffPlot.getData();
	  plotData[seriesIdx].points.show = !plotData[seriesIdx].points.show;
	  plotData[seriesIdx].points.yerr.show = !plotData[seriesIdx].points.yerr.show;
	  onOffPlot.setData(plotData);
	  onOffPlot.draw();
	  refresh();
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
    xobj.open('GET', outputDir.value+"/FluxPlotFlot", true); // Replace 'my_data' with the path to your file
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
 }

function onDataLoad(json) {	
	fluxData = json.fluxdata;
	fluxDataError = json.error;
	binValue = json.binValue;
	globalBinWidth = binValue;
	minX = json.minX;
	maxX = json.maxX;
	nBins = json.nBins;
	bins = json.fakeBins;
	studyLabel = "Flux Study";
	xAxisLabel = "Time UTC (hours:minutes)";
	yAxisLabel = "Flux (events/m^2/60-seconds)";	

	if (json.fluxdata != null) {
		fluxData.data = getDataWithBins(fluxData.data, binValue, minX, maxX, nBins, bins);
		data.push(fluxData);
	}
	if (json.fluxdata != null) {
		fluxDataError.data = getError(fluxData.data_original, binValue, minX, maxX, nBins, bins);
		data.push(fluxDataError);
	}
	setSliders(60, 6000);
	
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
}	

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
	    	if ((data[i].y + (data[i].y * 0.30)) > maxYaxis) {
	    		maxYaxis = data[i].y + (data[i].y * 0.30);
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
	    	if (Math.sqrt(data[i].y) > maxError) {
	    		maxError = Math.sqrt(data[i].y);
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

function reBinData(json, binValue) {
	if (binValue > 0) {
		maxYaxis = 1;
	  	var plotData = onOffPlot.getData();
	  	var overviewData = overviewPlot.getData();
		minX = json.minX;
		maxX = json.maxX;
		bins = [];
		nBins = Math.ceil(json.maxX / (binValue*1000));
		console.log(minX);
		console.log(maxX);
		for (var i = minX; i < (maxX*1.00000); i += (binValue*1000*1.00000)) {
			bins.push(i);
		}
		data = [];
		
		if (json.fluxdata != null) {
			fluxData.data = getDataWithBins(fluxData.data_original, binValue, minX, maxX, nBins, bins);
			data.push(fluxData);
		}
		if (json.fluxdata != null) {
			fluxDataError.data = getError(fluxData.data_original, binValue, minX, maxX, nBins, bins);
			data.push(fluxDataError);
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
	    refresh();
	}
}//end of reBinData
