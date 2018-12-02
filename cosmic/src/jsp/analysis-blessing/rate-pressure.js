var triggerPressureData = [,,];
var triggerData = [];
var correctedTriggerData = [];
var pressureData = [];
var ratepressData = [];
var onOffPlot0;
var options = "";
var minx, maxx, mean, deviation, numberOfEntries;
var yAxisLabel = "average of entries/time bin";
var xAxisLabel = "xxxx";
var currentBinValue = 1.25;
var chartNum = 0;
var loadCount = 0;
var tf = "%m/%d/%y";
var sliderMinX = -1;
var sliderMaxX = -1;

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

function saveRatePressureChart(name_id, div_id, run_id) {
	var filename = document.getElementById(name_id);
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
	var values = new Array();
	console.log(filename.value);
	$.each(serialized, function(index,element){
	     values.push(element.value);
	   });	 
	var rc = true;
	if (filename != null) {
		if (filename.value != "") {
			//save trigger
			var triggername = filename.value +"-trigger";
			var canvas = triggerPressureData[0].onOffPlot.getCanvas();			
			//console.log(canvas);
			var image = canvas.toDataURL("image/png");
			image = image.replace('data:image/png;base64,', '');
			$.ajax({
				url: "../analysis/save-plot.jsp",
				type: 'POST',
				data: { imagedata: image, filename: triggername, id: run_id, metadata: values},
				success: function (response) {
					var msgDiv = document.getElementById(div_id);
					if (msgDiv != null) {
						msgDiv.innerHTML = '<a href="'+response+'">' +triggername +'</a> file created successfully.';
					}
				}
			});	
			//save pressure
			var pressurename = filename.value +"-pressure";
			var canvas1 = triggerPressureData[1].onOffPlot.getCanvas();	
			//console.log(canvas1);
			var image1 = canvas1.toDataURL("image/png");
			image1 = image1.replace('data:image/png;base64,', '');
			$.ajax({
				url: "../analysis/save-plot.jsp",
				type: 'POST',
				data: { imagedata: image1, filename: pressurename, id: run_id, metadata: values},
				success: function (response) {
					var msgDiv = document.getElementById(div_id);
					if (msgDiv != null) {
						msgDiv.innerHTML += '<br /><a href="'+response+'">' +pressurename +'</a> file created successfully.';
					}
				}
			});	
			//save rate/pressure
			var ratename = filename.value +"-rate-pressure";
			//var canvas2 = onOffPlot0.getCanvas();			
			console.log(canvas2);
			var image2 = canvas2.toDataURL("image/png");
			image2 = image2.replace('data:image/png;base64,', '');
			$.ajax({
				url: "../analysis/save-plot.jsp",
				type: 'POST',
				data: { imagedata: image2, filename: ratename, id: run_id, metadata: values},
				success: function (response) {
					var msgDiv = document.getElementById(div_id);
					if (msgDiv != null) {
						msgDiv.innerHTML += '<br /><a href="'+response+'">' +ratename +'</a> file created successfully.';
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

optionsExtra = {
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
     		points: {
    			show: true,
    			radius: 0.5,
    			errorbars: "n", 
    			yerr: {show:true, asymmetric:null, upperCap: "-", lowerCap: "-"}
    		},
    	},
		yaxes: {
			axisLabelUseCanvas: true
		},
		xaxes: [{	
				axisLabelUseCanvas: true,
				}
		]
};


function onDataLoad() {
	loadJSON(function(response) {
		JSON.parseAsync(response, function(json) {
			onDataLoadChart(json);
		});
	});
}//end of onDataLoad

function loadJSON(callback) {   
    var xobj = new XMLHttpRequest();
	var outputDir = document.getElementById("outputDir");
    xobj.overrideMimeType("application/json");
    xobj.open('GET', outputDir.value+"/RatePressureFlotPlot", true); 
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
}//end of loadJSON

function onDataLoadChart(json) {	
	if (json.trigger) {
		data = [];
		if (json.trigger != null) {
			triggerData = json.trigger;
			triggerPressureData[0]={onOffPlot: "", TriggerData: triggerData, data: triggerData.data, originalMinX: triggerData.minX, originalMaxX: 0,
					originalMinY: triggerData.minY, originalMaxY: triggerData.maxY, numberOfEntries: 0, mean: 0, stddev: 0, label: triggerData.label, 
					maxBins: triggerData.maxBins, binValue: triggerData.binValue, currentBinValue: triggerData.binValue};
			triggerPressureData[0].data = data;
			correctedTriggerData = json.correctedtrigger;
			triggerPressureData[2]={onOffPlot: "", TriggerData: correctedTriggerData, data: correctedTriggerData.data, originalMinX: correctedTriggerData.minX, originalMaxX: 0,
					originalMinY: correctedTriggerData.minY, originalMaxY: correctedTriggerData.maxY, numberOfEntries: 0, mean: 0, stddev: 0, label: correctedTriggerData.label, 
					maxBins: correctedTriggerData.maxBins, binValue: correctedTriggerData.binValue, currentBinValue: correctedTriggerData.binValue};
			triggerPressureData[2].data = data;
		}
		data.push(correctedTriggerData);
		data.push(triggerData);
		var onOffPlot = $.plot("#triggerChart", data, options);
		triggerPressureData[0].onOffPlot = onOffPlot;
		var axes = onOffPlot.getAxes();
		axes.yaxis.options.min = triggerPressureData[0].originalMinY;
	    onOffPlot.setupGrid();
	    onOffPlot.draw();
		data1 = [];
		if (json.pressure != null) {
			pressureData = json.pressure;
			triggerPressureData[1]={onOffPlot: "", PressureData: pressureData, data: pressureData.data, originalMinX: pressureData.minX, originalMaxX: 0,
					originalMinY: pressureData.minY, originalMaxY: 0, numberOfEntries: 0, mean: 0, stddev: 0, label: pressureData.label, 
					maxBins: pressureData.maxBins, binValue: pressureData.binValue, currentBinValue: pressureData.binValue};
			triggerPressureData[1].data = data1;
		}
		data1.push(pressureData);
		var onOffPlot1 = $.plot("#pressureChart", data1, options);
		triggerPressureData[1].onOffPlot = onOffPlot1;
		writeLegend('trigger');
		writeLegend('pressure');

		data0 = [];		
		if (json.ratepressure != null) {
			ratepressData = json.ratepressure;
		}
		data0.push(ratepressData);
		onOffPlot0 = $.plot("#trigPressChart", data0, optionsExtra);
		var axes0 = onOffPlot0.getAxes();
		axes0.yaxis.options.min = triggerPressureData[2].originalMinY;
	    onOffPlot0.setupGrid();
	    onOffPlot0.draw();
		writeLegend('trigpres')
	    
	}
}//end of onDataLoadChart

function writeLegend(dataGroup) {
	if (dataGroup == 'trigpres') {
		
	}
	var context = triggerPressureData[0].onOffPlot.getCanvas().getContext('2d');
	var localLabel = triggerPressureData[0].label;
	if (dataGroup == 'trigpres') {
		context = onOffPlot0.getCanvas().getContext('2d');
		localLabel = "Trigger over Pressure";
		yAxisLabel = "average trigger/pressure";
	} else {
		yAxisLabel = "average of entries/time bin";		
	}
	if (dataGroup == 'pressure') {
		context = triggerPressureData[1].onOffPlot.getCanvas().getContext('2d');
		localLabel = triggerPressureData[1].label;
	}
	context.lineWidth=3;
	context.fillStyle="#000000";
	context.lineStyle="#ffff00";
	context.font="12px sans-serif";
	context.save();
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
	var caption = "";
	context.textAlign = "Flux Study - Rate vs Pressure";
	context.fillText("Flux Study -  Rate vs Pressure", 90, 20);
	context.font="10px sans-serif";
	context.textAlign = localLabel;
	context.fillText(localLabel, 130, 30);
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
	context.fillText(yAxisLabel, 0, 45);	
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

