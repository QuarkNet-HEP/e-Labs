var onOffPlot = null;
var overviewPlot = null;
var yLabel = " ";
var xLabel = " ";
var data = []; //data that will be sent to the chart
var dataOriginal = [];
var xunits = new Object(); //array to hold all x axes units
var yunits = new Object(); //array to hold all y axes units 
var options = "";
var overviewOptions = "";
var globalBinWidth = -1;
var studyname, xlabelname, ylabelname = "";

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
}//end of getXNumAxis

function getYNumAxis() {
	var series = onOffPlot.getData();
	var maxyaxis = 1;
	for (var i = 0; i < series.length; i++) {
		if (series[i].yaxis.n > maxyaxis) {
			maxyaxis = series[i].yaxis.n;
		}
	}
	return maxyaxis;
}//end of getYNumAxis


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
			if (typeof ud.yaxis.position != "undefined") {
				yDefaultPosition = ud.yaxis.position;
			}
			if (typeof ud.xaxis.position != "undefined") {
				xDefaultPosition = ud.xaxis.position;
			}
			options = $.extend(true, {}, options, {
	    			yaxes: [{
						position: yDefaultPosition
	    			}],
	    			xaxes: [{
	    				position: xDefaultPosition
	    			}]
			});
			console.log(data);			
			onOffPlot = $.plot("#placeholder", data, options);
			var opts = onOffPlot.getOptions();
			console.log(opts);
			overviewPlot = $.plot("#overview", data, overviewOptions);
			var newseries = onOffPlot.getData();
			for (var i = 0; i < newseries.length; i++) {
				if (i > 0) {
					newseries[i].lines.show = true;
				}
			}
			onOffPlot.setData(newseries);
			onOffPlot.draw();
			var newoverview = overviewPlot.getData();
			for (var i = 0; i < newoverview.length; i++) {
				if (i > 0) {
					newoverview[i].lines.show = true;
				}
			}
			overviewPlot.setData(newoverview);
			overviewPlot.draw();			
			refresh();
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

//to create legends for the y and x axes
function buildUnits() {
	$.each(onOffPlot.getAxes(), function (i, axis) {
		if (!axis.show)
			return;
		var box = axis.box;
		if (axis.direction == 'y') {
			var yunit = getYData(axis.n);
			$("<div style='font-size:xx-small;position:absolute; left:" + box.left + "px; top:" + box.top+ "px; width:35px; height:15px'>"+yunit+"</div>")
			.data("axis.direction", axis.direction)
			.data("axis.n", axis.n)
			.data("axis.position", axis.position)
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
		.data("axis.position", axis.position)
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

function buildInteractivePanning() {
	$("#placeholder").bind("plotpan", function (event, plot) {
		var axes = onOffPlot.getAxes();
		$(".message").html("Panning to x: "  + axes.xaxis.min.toFixed(2)
		+ " &ndash; " + axes.xaxis.max.toFixed(2)
		+ " and y: " + axes.yaxis.min.toFixed(2)
		+ " &ndash; " + axes.yaxis.max.toFixed(2));
		buildCanvas(studyname, xlabelname, ylabelname);
		//buildUnits();			
	});	
}//end of buildInteractivePanning

// and add panning buttons
function addArrow(dir, left, top, offset) {
	$("<img class='button' src='../graphics/arrow-" + dir + ".gif' style='left:" + left + "px;top:" + top + "px'>")
		.appendTo("#arrowcontainer")
		.click(function (e) {
			e.preventDefault();
			onOffPlot.pan(offset);
			buildCanvas(studyname, xlabelname, ylabelname);
			//buildUnits();			
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
		buildCanvas();
		//buildUnits();
	});	
}//end of buildInteractiveZoom

function buildZoomOutButton() {
	// add zoom out button 
	$("<div class='button' style='left:20px;top:20px'>zoom out</div>")
		.appendTo($("#zoomoutbutton"))
		.click(function (event) {
			event.preventDefault();
			onOffPlot.zoomOut();
			buildCanvas(studyname, xlabelname, ylabelname);
			//buildUnits();			
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
		buildCanvas(studyname, xlabelname, ylabelname);
		//buildUnits();
		// don't fire event on the overview to prevent eternal loop
		overview.setSelection(ranges, true);
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

$("<div id='tooltip'></div>").css({
	position: "absolute",
	display: "none",
	border: "1px solid #fdd",
	padding: "2px",
	"background-color": "#fee",
	opacity: 0.80
}).appendTo("body");

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
}//end of buildDataMap

function getXData(key) {
	return xunits[key];
}//end of getXData

function getYData(key) {
	return yunits[key];
}//end of getYData

function buildCanvas(study, xlabel, ylabel) {
	buildDataMap();
	var canvas = onOffPlot.getCanvas();
	var context = canvas.getContext('2d');
	var xcoord = 280;
	var ycoord = 0;
	var yspace = 15;
	context.lineWidth=3;
	context.fillStyle="#000000";
	context.lineStyle="#ffff00";
	context.font="22px sans-serif";
	ycoord = 35;
	context.fillText(study,xcoord,ycoord);
	context.lineWidth=2;
	context.font="12px sans-serif";
	var meta = document.getElementsByName("metadata");
	var serialized = $(meta).serializeArray();
	var values = new Array();
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
	ycoord += 10;
	for (var i = 0; i < series.length; i++) {
		if (series[i].toggle) {
			context.strokeStyle = series[i].color;
			context.beginPath();
		    ycoord += (yspace);
		    context.moveTo(xcoord, ycoord);
		    context.lineTo(xcoord+20, ycoord);
		    context.stroke();
		    context.fillText(series[i].label,xcoord+30,ycoord);		
		}
	}	
	var maxxaxis = getXNumAxis();
	var maxyaxis = getYNumAxis();
	
	if (maxxaxis == 1) {	
		context.textAlign = xlabel;
		context.fillText(xlabel, 250, 550);
	}
	if (maxyaxis == 1) {
		context.save();
		context.translate(0, 380);
		context.rotate(-Math.PI / 2);
		context.textAlign = ylabel;
		context.fillText(ylabel, 0, 8);
		context.restore();	
	}
	
	$.each(onOffPlot.getAxes(), function (i, axis) {
		if (!axis.show)
			return;
		var box = axis.box;
		ycoord += yspace;
		if (axis.direction == 'y') {
			var yunit = getYData(axis.n);
			context.fillText("Axis " + axis.direction + axis.n + " units:" + yunit, xcoord, ycoord);
		}
		if (axis.direction == 'x') {
			var xunit = getXData(axis.n);
			var newx = box.left + box.width;
			context.fillText("Axis " + axis.direction + axis.n + " units:" + xunit, xcoord, ycoord);
		}
	});
}//end of buildCanvas

function refresh(study, xlabel, ylabel) {
	  buildCanvas(study, xlabel, ylabel);
	  bindPlotHover();
	  bindPlotClick();
	  bindPlotSelection();
	  buildInteractiveZoom();
	  buildInteractivePanning();
	  buildUnits();	
}//end of refresh

function bindEverything(study, xlabel, ylabel) {
	  studyname = study;
	  xlabelname = xlabel;
	  ylabelname = ylabel;
	  buildCanvas(studyname, xlabelname, ylabelname); // creates a canvas of the chart with captions, legends, etc so then then it can be saved
	  bindPlotHover();
	  bindPlotClick();
	  bindPlotSelection();
	  buildZoomOutButton();
	  buildInteractiveZoom();
	  buildArrows();
	  buildInteractivePanning();
	  buildUnits();	
}//end of bindEverything

