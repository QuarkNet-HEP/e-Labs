var fluxData;

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
		yaxes: {
			axisLabelUseCanvas: true
		},
		xaxes: [
				{	
					axisLabelUseCanvas: true,
					tickFormatter: function (val, axis) {
				
						var d = new Date(val);
						return d.customFormat("#DD#/#MMM# #hh#:#ss#");
					}
				},
				{	
					axisLabelUseCanvas: true,
				}
				],
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



function timeFormatter(val, series) {
	var d = new Date(val);
	return d.customFormat("#DD#/#MMM# #hh#:#ss#");	
}

togglePlot = function(seriesIdx) {
	  var plotData = onOffPlot.getData();
	  plotData[seriesIdx].points.show = !plotData[seriesIdx].points.show;
	  plotData[seriesIdx].points.yerr.show = !plotData[seriesIdx].points.yerr.show;
	  onOffPlot.setData(plotData);
	  onOffPlot.draw();
	  refresh();
}//end of togglePlot

function onDataLoad(json) {	
	fluxData = json.fluxdata;
	data.push(fluxData);
	onOffPlot = $.plot("#placeholder", data, options);
	overviewPlot = $.plot("#overview", data, overviewOptions);
	var newseries = onOffPlot.getData();
	for (var i = 0; i < newseries.length; i++) {
		if (i == 0) {
			newseries[i].xaxis.tickFormatter = timeFormatter;
		}
	}
	onOffPlot.setData(newseries);
	onOffPlot.draw();
	bindEverything();
	bindTooltip();
}		




