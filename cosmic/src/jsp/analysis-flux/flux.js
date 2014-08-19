var fluxData;
var onOffPlot = null;
var yLabel = " ";
var xLabel = " ";
var data = [];
var steps = false;
var xunits = new Object();
var yunits = new Object();
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
var options = {
		//canvas: true,
        axisLabels: {
            show: true
        },		
        legend: {  
            show: true,  
            margin: 10,  
            backgroundOpacity: 0.5  
        },  
    	series: {
    		lines: {
    			show: false,
				steps: steps
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
			tickFormatter: function (val, axis) {
				var d = new Date(val);
				return d.customFormat("#DD#/#MMM# #hh#:#ss#");
			}
		},
		//xaxis: {
		//	ticks: 20,
		//    mode: "time",
		//    minTickSize: [1, "hour"],
		//    tickFormatter: function (val, axis) {
		//        var d = new Date(val);
		//        return d;
		//    }
		//},
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

function buildDataMap() {
	var series = onOffPlot.getData();
	for (var i = 0; i < series.length; i++) {
		var xaxisnum = series[i].xaxis.n;
		var xunit = series[i].xunits;
		if (!getXData(xaxisnum)) {
			xunits[xaxisnum] = xunit;
		}
		var yaxisnum = series[i].yaxis.n;
		var yunit = series[i].yunits;
		if (!getYData(yaxisnum)) {
			yunits[yaxisnum] = yunit;
		}
	}
}

function getXData(key) {
	return xunits[key];
}

function getYData(key) {
	return yunits[key];
}

togglePlot = function(seriesIdx) {
	  var plotData = onOffPlot.getData();
	  plotData[seriesIdx].points.show = !plotData[seriesIdx].points.show;
	  plotData[seriesIdx].points.yerr.show = !plotData[seriesIdx].points.yerr.show;
	  onOffPlot.setData(plotData);
	  onOffPlot.draw();
	  addEverything();
}//end of togglePlot

function addEverything() {
	  completeCanvas();
	  buildOverview();
	  bindEnableSteps();
	  bindZoomingPanningTooltip();
	  buildUnits();	
}

function completeCanvas() {
	buildDataMap();
	var canvas = onOffPlot.getCanvas();
	var context = canvas.getContext('2d');
	context.lineWidth=3;
	context.fillStyle="#000000";
	context.lineStyle="#ffff00";
	context.font="18px sans-serif";
	context.fillText("Flux Study",400,35);

	context.lineWidth=2;
	context.font="12px sans-serif";
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
	var values = new Array();
	$.each(serialized, function(index,element){
		var val = element.value;
		if (val.indexOf("caption") > -1) {
			var caption = val.substring(val.indexOf("Data"), val.length);
			var captionArray = caption.split(" ");
			var i = 0;
			var numlines = 0;
			while (i < captionArray.length && numlines < 4) {
				var line = "";
				for (var x = i; x < (i+4); x++) {
					if (captionArray[x]) {
						line += captionArray[x] + " ";
					}
				}
				i = i + 4;
				numlines = numlines + 1;
				context.fillText(line, 400, 50 + (i*3));				
			}
		}
	   });	 

	var series = onOffPlot.getData();
    
	for (var i = 0; i < series.length; i++) {
		context.strokeStyle = series[i].color;
		context.beginPath();
	    context.moveTo(400, 105+ (i*15));
	    context.lineTo(420, 105+ (i*15));
	    context.stroke();
		context.fillText(series[i].label,430,105+ (i*15));		
	}	
	var maxxaxis = getXNumAxis();
	var maxyaxis = getYNumAxis();
	
	if (maxxaxis == 1) {	
		context.textAlign = 'Time UTC (hours)';
		context.fillText('Time UTC (hours)', 250, 650);
	}
	if (maxyaxis == 1) {
		context.save();
		context.translate(0, 380);
		context.rotate(-Math.PI / 2);
		context.textAlign = 'Flux(events/m2/60-seconds';
		context.fillText('Flux(events/m2/60-seconds', 0, 8);
		context.restore();	
	}
	
	$.each(onOffPlot.getAxes(), function (i, axis) {
		if (!axis.show)
			return;
		var box = axis.box;
		if (axis.direction == 'y') {
			var yunit = getYData(axis.n);
			context.fillText("Axis " + axis.direction + axis.n + " units:" + yunit, 400, 200 + (axis.n*15));
		}
		if (axis.direction == 'x') {
			var xunit = getXData(axis.n);
			var newx = box.left + box.width;
			context.fillText("Axis " + axis.direction + axis.n + " units:" + xunit, 400, 300 + (axis.n*15));
		}
	});
	
}//end of completeCanvas

function buildOverview() {
	var overview = $.plot("#overview", data, {
		legend: {
			show: false
		},
		series: {
			lines: {
				show: false,
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
	});
}//end of buildOverview

function bindEnableSteps() {
	$("#enableSteps").bind("click", function() {
		if ($("#enableSteps").prop("checked")) {
			onOffPlot = $.plot("#placeholder", data ,
					$.extend(true, {}, options, {
				    	series: {
				    		lines: {
								steps: true
				    		}
				    	}
					})
				);
		} else {
			onOffPlot = $.plot("#placeholder", data ,
					$.extend(true, {}, options, {
				    	series: {
				    		lines: {
								steps: false
				    		}
				    	}
					})
				);
		}
		addEverything();
	});	
}//end of bindEnableSteps

function bindZoomingPanningTooltip() {
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
		// don't fire event on the overview to prevent eternal loop
		overview.setSelection(ranges, true);
	});

	$("#overview").bind("plotselected", function (event, ranges) {
		onOffPlot.setSelection(ranges);
	});	
	$("#placeholder").bind("plothover", function (event, pos, item) {

		if ($("#enablePosition:checked").length > 0) {
			var str = "(" + pos.x.toFixed(2) + ", " + pos.y.toFixed(2) + ")";
			$("#hoverdata").text(str);
		}
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
		latestPosition = pos;
		if (!updateLegendTimeout) {
			updateLegendTimeout = setTimeout(updateLegend, 50);
		}

	});

	$("#placeholder").bind("plotclick", function (event, pos, item) {
		if (item) {
			$("#clickdata").text("Click point " + item.dataIndex + " in " + item.series.label);
			onOffPlot.highlight(item.series, item.datapoint);
		}
	});
	// show pan/zoom messages to illustrate events 
	$("#placeholder").bind("plotpan", function (event, plot) {
		var axes = onOffPlot.getAxes();
		$(".message").html("Panning to x: "  + axes.xaxis.min.toFixed(2)
		+ " &ndash; " + axes.xaxis.max.toFixed(2)
		+ " and y: " + axes.yaxis.min.toFixed(2)
		+ " &ndash; " + axes.yaxis.max.toFixed(2));
	});

	$("#placeholder").bind("plotzoom", function (event, plot) {
		var axes = onOffPlot.getAxes();
		$(".message").html("Zooming to x: "  + axes.xaxis.min.toFixed(2)
		+ " &ndash; " + axes.xaxis.max.toFixed(2)
		+ " and y: " + axes.yaxis.min.toFixed(2)
		+ " &ndash; " + axes.yaxis.max.toFixed(2));
	});



	// add zoom out button 
	$("<div class='button' style='right:20px;top:120px'>zoom out</div>")
		.appendTo($("#placeholder"))
		.click(function (event) {
			event.preventDefault();
			onOffPlot.zoomOut();
		});

	// and add panning buttons
	function addArrow(dir, right, top, offset) {
		$("<img class='button' src='../graphics/arrow-" + dir + ".gif' style='right:" + right + "px;top:" + top + "px'>")
			.appendTo(placeholder)
			.click(function (e) {
				e.preventDefault();
				onOffPlot.pan(offset);
			});
	}

	addArrow("left", 55, 160, { left: -100 });
	addArrow("right", 25, 160, { left: 100 });
	addArrow("up", 40, 145, { top: -100 });
	addArrow("down", 40, 175, { top: 100 });
	
	$("<div id='tooltip'></div>").css({
		position: "absolute",
		display: "none",
		border: "1px solid #fdd",
		padding: "2px",
		"background-color": "#fee",
		opacity: 0.80
	}).appendTo("body");	
	$("#footer").html("Built with Flot " + $.plot.version);


	var legends = $("#placeholder .legendLabel");

	legends.each(function () {
		// fix the widths so they don't jump around
		$(this).css('width', $(this).width());
	});

	var updateLegendTimeout = null;
	var latestPosition = null;

	function updateLegend() {

		updateLegendTimeout = null;

		var pos = latestPosition;

		var axes = onOffPlot.getAxes();
		if (pos.x < axes.xaxis.min || pos.x > axes.xaxis.max ||
			pos.y < axes.yaxis.min || pos.y > axes.yaxis.max) {
			return;
		}

		var i, j, dataset = onOffPlot.getData();
		for (i = 0; i < dataset.length; ++i) {

			var series = dataset[i];

			// Find the nearest points, x-wise

			for (j = 0; j < series.data.length; ++j) {
				if (series.data[j][0] > pos.x) {
					break;
				}
			}

			// Now Interpolate

			var y,
				p1 = series.data[j - 1],
				p2 = series.data[j];

			//if (p1 == null) {
			//	y = p2[1];
			//} else if (p2 == null) {
			//	y = p1[1];
			//} else {
			//	y = p1[1] + (p2[1] - p1[1]) * (pos.x - p1[0]) / (p2[0] - p1[0]);
			//}

			//legends.eq(i).text(series.label.replace(/=.*/, "= " + y.toFixed(2)));
		}
	}
}//end of bindZoomingPanningTooltip

function buildUnits() {
	$.each(onOffPlot.getAxes(), function (i, axis) {
		if (!axis.show)
			return;
		var box = axis.box;
		if (axis.direction == 'y') {
			var yunit = getYData(axis.n);
			$("<div style='font-size:xx-small;position:absolute; left:" + box.left + "px; top:" + box.top+ "px; width:30px; height:15px'>"+yunit+"</div>")
			.data("axis.direction", axis.direction)
			.data("axis.n", axis.n)
			.css({ backgroundColor: "#fff", opacity: 1 })
			.appendTo(onOffPlot.getPlaceholder())		
		}
		if (axis.direction == 'x') {
			var xunit = getXData(axis.n);
			var newx = box.left + box.width;
			$("<div style='font-size:xx-small;position:absolute; left:" + newx + "px; top:" + box.top+ "px; width: 30px; height:15px'>"+xunit+"</div>")
			.data("axis.direction", axis.direction)
			.data("axis.n", axis.n)
			.css({ backgroundColor: "#fff", opacity: 1 })
			.appendTo(onOffPlot.getPlaceholder())			
		}
		$("<div class='axisTarget' style='position:absolute; left:" + box.left + "px; top:" + box.top + "px; width:" + box.width +  "px; height:" + box.height + "px'></div>")
		.data("axis.direction", axis.direction)
		.data("axis.n", axis.n)
		.css({ backgroundColor: "#f00", opacity: 0, cursor: "pointer" })
		.appendTo(onOffPlot.getPlaceholder())
		.hover(
			function () { $(this).css({ opacity: 0.10 }) },
			function () { $(this).css({ opacity: 0 }) }
		)
		.click(function () {
			if (axis.direction == 'y') {
				$(".click").text("You clicked axis(" + axis.direction + axis.n + ") which displays "+getYData(axis.n));
			} else {
				$(".click").text("You clicked axis(" + axis.direction + axis.n + ") which displays "+getXData(axis.n));
			}
		});
	});
	
}//end of buildUnits

function onDataLoad(json) {	
	fluxData = json.fluxdata;
	console.log(fluxData);
	data.push(fluxData);
	onOffPlot = $.plot("#placeholder", data, options);
	addEverything();
}		

function saveChart(plot_to_save, name_id, div_id, run_id) {
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
			var canvas = plot_to_save.getCanvas();			
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

function getXNumAxis() {
	var series = onOffPlot.getData();
	var maxxaxis = 1;
	for (var i = 0; i < series.length; i++) {
		if (series[i].xaxis.n > maxxaxis) {
			maxxaxis = series[i].xaxis.n;
		}
	}
	return maxxaxis;
}

function getYNumAxis() {
	var series = onOffPlot.getData();
	var maxyaxis = 1;
	for (var i = 0; i < series.length; i++) {
		if (series[i].yaxis.n > maxyaxis) {
			maxyaxis = series[i].yaxis.n;
		}
	}
	return maxyaxis;
}


function superImpose() {
	var option = document.getElementById("externalFiles");
	var fileselected = option.options[option.selectedIndex].value;
	if (fileselected != "") {
		var series = onOffPlot.getData();
		var maxxaxis = getXNumAxis();
		var maxyaxis = getYNumAxis();
		var dataUrl= "../data/get-uploaded-data.jsp?filename="+fileselected+"&ndx="+series.length+"&yAxisNum="+maxyaxis+"&xAxisNum="+maxxaxis;
		function onFailed() {
			alert("it failed");
		}
		function onDataReceived(json) {
			var ud = json.uploadedData;
			data.push(ud);
			onOffPlot = $.plot("#placeholder", data , options);

			var newseries = onOffPlot.getData();
			addEverything();
		}
	
		$.ajax({
			url: dataUrl,
			processData: false,
			dataType: "json",
			type: "GET",
			success: onDataReceived,
			failure: onFailed
		});
	} else {
		var divObj = document.getElementById("msg");
		divObj.innerHTML = "<i>*Please select a file</i>"
		return;
	}
}//end of superImpose

