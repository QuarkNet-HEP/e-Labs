var channel1, channel2, channel3, channel4;
var yLabel = 'Number of PMT pulses';
var xLabel = 'Time over Threshold (nanosec)';
var onOffPlot = null;

togglePlot = function(seriesIdx)
{
  var plotData = onOffPlot.getData();
  plotData[seriesIdx].points.show = !plotData[seriesIdx].points.show;
  plotData[seriesIdx].lines.show = !plotData[seriesIdx].lines.show;
  plotData[seriesIdx].points.yerr.show = !plotData[seriesIdx].points.yerr.show;
  onOffPlot.setData(plotData);
  onOffPlot.draw();
}

var options = {  
        legend: {  
            show: true,  
            margin: 10,  
            backgroundOpacity: 0.5  
        },  
    	series: {
    		lines: {
    			show: true 
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
		legend: {
			container: "#placeholderLegend",
			noColumns: 4,
            labelFormatter: function(label, series){
              return '<a href="#" onClick="togglePlot('+series.idx+'); return false;">'+label+'</a>';
            }
        }
};
//var chanOptions = $.extend({}, options, { legend: { noColumns: 4, labelFormatter: seriesLabelFormatter, container: "#channelChartLegend" } });
function onDataLoad(json) {	
	channel1 = json.channel1;
	channel2 = json.channel2;
	channel3 = json.channel3;
	channel4 = json.channel4;
	//onOffPlot = $.plot($("#performanceCharts"), [channel1, channel2, channel3, channel4], options);
	onOffPlot = $.plot("#placeholder", [channel1, channel2, channel3, channel4], 
			$.extend({}, options, { yaxes: [ {position: 'left', axisLabel: yLabel} ], xaxes: [{position: 'bottom', axisLabel: xLabel}]}));
	var overview = $.plot("#overview", [channel1, channel2, channel3, channel4], {
		legend: {
			show: false
		},
		series: {
			lines: {
				show: true,
				lineWidth: 1
			},
			shadowSize: 0
		},
		xaxis: {
			ticks: 4
		},
		yaxis: {
			ticks: 4
		},
		grid: {
			color: "#999"
		},
		selection: {
			mode: "xy"
		}
	});
	$("#placeholder").bind("plotselected", function (event, ranges) {
		// clamp the zooming to prevent eternal zoom

		if (ranges.xaxis.to - ranges.xaxis.from < 0.00001) {
			ranges.xaxis.to = ranges.xaxis.from + 0.00001;
		}

		if (ranges.yaxis.to - ranges.yaxis.from < 0.00001) {
			ranges.yaxis.to = ranges.yaxis.from + 0.00001;
		}

		// do the zooming
		onOffPlot = $.plot("#placeholder", [channel1, channel2, channel3, channel4] ,
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
					y = item.datapoint[1].toFixed(2);

				$("#tooltip").html(item.series.label + " of " + x + " = " + y)
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

	$("<div class='button' style='right:20px;top:20px'>zoom out</div>")
		.appendTo($("#placeholder"))
		.click(function (event) {
			event.preventDefault();
			onOffPlot.zoomOut();
		});

	// and add panning buttons

	// little helper for taking the repetitive work out of placing
	// panning arrows

	function addArrow(dir, right, top, offset) {
		$("<img class='button' src='../graphics/arrow-" + dir + ".gif' style='right:" + right + "px;top:" + top + "px'>")
			.appendTo(placeholder)
			.click(function (e) {
				e.preventDefault();
				onOffPlot.pan(offset);
			});
	}

	addArrow("left", 55, 60, { left: -100 });
	addArrow("right", 25, 60, { left: 100 });
	addArrow("up", 40, 45, { top: -100 });
	addArrow("down", 40, 75, { top: 100 });
	
	$("<div id='tooltip'></div>").css({
		position: "absolute",
		display: "none",
		border: "1px solid #fdd",
		padding: "2px",
		"background-color": "#fee",
		opacity: 0.80
	}).appendTo("body");	
	$("#footer").prepend("Built with Flot " + $.plot.version);


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

			if (p1 == null) {
				y = p2[1];
			} else if (p2 == null) {
				y = p1[1];
			} else {
				y = p1[1] + (p2[1] - p1[1]) * (pos.x - p1[0]) / (p2[0] - p1[0]);
			}

			//legends.eq(i).text(series.label.replace(/=.*/, "= " + y.toFixed(2)));
		}
	}

}		
