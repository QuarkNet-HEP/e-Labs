var lifetimeData;

options = {
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
				steps: false
    		},
    		points: {
    			show: true,
    			errorbars: "y", 
    			yerr: {show:true, asymmetric:false, upperCap: "-", lowerCap: "-"}
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

togglePlot = function(seriesIdx) {
	  var plotData = onOffPlot.getData();
	  plotData[seriesIdx].points.show = !plotData[seriesIdx].points.show;
	  plotData[seriesIdx].points.yerr.show = !plotData[seriesIdx].points.yerr.show;
	  onOffPlot.setData(plotData);
	  onOffPlot.draw();
	  refresh();
}//end of togglePlot

function onDataLoad(json) {	
	lifetimeData = json.lifetimedata;
	data.push(lifetimeData);
	onOffPlot = $.plot("#placeholder", data, options);
	overviewPlot = $.plot("#overview", data, overviewOptions);
	bindEverything();
}		





