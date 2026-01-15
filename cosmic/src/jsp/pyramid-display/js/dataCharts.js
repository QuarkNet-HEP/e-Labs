/*
	Edit Peronja 23/10/2025: all charts in data analysis
*/

function removeCharts() {
	canvasIDs = ['X1','X2','X3','Y1','Y2','Y3',
		'6PTXYMIDDLE','6PTMX','6PTMY','6PTMXY','6PDIFFMX','6PDIFFMY',
		'6PTXYMIDDLEX','6PTXYMIDDLEY','6PTXYMIDDLEXY','6PDIFFMXHITS','6PDIFFMYHITS','6DXDYHITS',//'LEGO',
		'5PTTX','5PTMX','5PTBX','5PTTY','5PTMY','5PTBY',
		'4PTT','4PTM','4PTB','DXDY','DX1D','DY1D',
		'DXT1D','DXM1D','DXB1D','DYT1D','DYM1D','DYB1D','DXDZDYDZ','DXDZDYDZTM','DXDZDYDZMB',
		'DT','DT10','DT20','DT30','DT40','DT50','DT42','DT13','DT15','DT35',
		'#TRACKS4TM','#TRACKS4MB','#TRACKS5M','#TRACKS5TB','#TRACKS6',
		'X1ADC','X2ADC','X3ADC','Y1ADC','Y2ADC','Y3ADC',
		'X1ADCAverage','X2ADCAverage','X3ADCAverage','Y1ADCAverage','Y2ADCAverage','Y3ADCAverage'
	];
	for (var i = 0; i < canvasIDs.length; i++) {
		let chartStatus = Chart.getChart(canvasIDs[i]); // <canvas> id
		if (chartStatus != undefined) {
	  		chartStatus.destroy();
	  	}
	}
}//end of removeCharts

function drawAnalysis(l,g) {	
	removeCharts();
	var ctx1 = document.getElementById('X1').getContext('2d');
	var ctx2 = document.getElementById('X2').getContext('2d');
	var ctx3 = document.getElementById('X3').getContext('2d');
	var cty1 = document.getElementById('Y1').getContext('2d');
	var cty2 = document.getElementById('Y2').getContext('2d');
	var cty3 = document.getElementById('Y3').getContext('2d');
	var PTXYMIDDLE6 = document.getElementById('6PTXYMIDDLE').getContext('2d');
	var PTXYMIDDLEX6 = document.getElementById('6PTXYMIDDLEX').getContext('2d');
	var PTXYMIDDLEY6 = document.getElementById('6PTXYMIDDLEY').getContext('2d');
	var PTXYMIDDLEXY6 = document.getElementById('6PTXYMIDDLEXY').getContext('2d');
	var PDIFFMXHITS6 = document.getElementById('6PDIFFMXHITS').getContext('2d');
	var PDIFFMYHITS6 = document.getElementById('6PDIFFMYHITS').getContext('2d');
	var DXDYHITS6 = document.getElementById('6DXDYHITS').getContext('2d');
	//var LEGO = document.getElementById('LEGO').getContext('2D');
	var PTMX6 = document.getElementById('6PTMX').getContext('2d');
	var PTMY6 = document.getElementById('6PTMY').getContext('2d');
	var PTMXY6 = document.getElementById('6PTMXY').getContext('2d');
	var PDIFFMX6 = document.getElementById('6PDIFFMX').getContext('2d');
	var PDIFFMY6 = document.getElementById('6PDIFFMY').getContext('2d');
	var PTTX5 = document.getElementById('5PTTX').getContext('2d');
	var PTMX5 = document.getElementById('5PTMX').getContext('2d');
	var PTBX5 = document.getElementById('5PTBX').getContext('2d');
	var PTTY5 = document.getElementById('5PTTY').getContext('2d');
	var PTMY5 = document.getElementById('5PTMY').getContext('2d');
	var PTBY5 = document.getElementById('5PTBY').getContext('2d');
	var PTT4 = document.getElementById('4PTT').getContext('2d');
	var PTM4 = document.getElementById('4PTM').getContext('2d');
	var PTB4 = document.getElementById('4PTB').getContext('2d');
	var dxdy = document.getElementById('DXDY').getContext('2d');
	var dx1d = document.getElementById('DX1D').getContext('2d');
	var dy1d = document.getElementById('DY1D').getContext('2d');
	var dxT1d = document.getElementById('DXT1D').getContext('2d');
	var dxM1d = document.getElementById('DXM1D').getContext('2d');
	var dxB1d = document.getElementById('DXB1D').getContext('2d');
	var dyT1d = document.getElementById('DYT1D').getContext('2d');
	var dyM1d = document.getElementById('DYM1D').getContext('2d');
	var dyB1d = document.getElementById('DYB1D').getContext('2d');
	var dxdzdydz = document.getElementById('DXDZDYDZ').getContext('2d');
	var dxdzdydzTM = document.getElementById('DXDZDYDZTM').getContext('2d');
	var dxdzdydzMB = document.getElementById('DXDZDYDZMB').getContext('2d');
	var tracks4TM = document.getElementById('#TRACKS4TM').getContext('2d');
	var tracks4MB = document.getElementById('#TRACKS4MB').getContext('2d');
	var tracks5M = document.getElementById('#TRACKS5M').getContext('2d');
	var tracks5TB = document.getElementById('#TRACKS5TB').getContext('2d');
	var tracks6 = document.getElementById('#TRACKS6').getContext('2d');
	var deltaT = document.getElementById('DT').getContext('2d');
	var deltaT10 = document.getElementById('DT10').getContext('2d');
	var deltaT20 = document.getElementById('DT20').getContext('2d');
	var deltaT30 = document.getElementById('DT30').getContext('2d');
	var deltaT40 = document.getElementById('DT40').getContext('2d');
	var deltaT50 = document.getElementById('DT50').getContext('2d');
	var deltaT42 = document.getElementById('DT42').getContext('2d');
	var deltaT13 = document.getElementById('DT13').getContext('2d');
	var deltaT15 = document.getElementById('DT15').getContext('2d');
	var deltaT35 = document.getElementById('DT35').getContext('2d');
	var X1ADC = document.getElementById('X1ADC').getContext('2d');
	var X2ADC = document.getElementById('X2ADC').getContext('2d');
	var X3ADC = document.getElementById('X3ADC').getContext('2d');
	var Y1ADC = document.getElementById('Y1ADC').getContext('2d');
	var Y2ADC = document.getElementById('Y2ADC').getContext('2d');
	var Y3ADC = document.getElementById('Y3ADC').getContext('2d');
	var X1ADCAverage = document.getElementById('X1ADCAverage').getContext('2d');
	var X2ADCAverage = document.getElementById('X2ADCAverage').getContext('2d');
	var X3ADCAverage = document.getElementById('X3ADCAverage').getContext('2d');
	var Y1ADCAverage = document.getElementById('Y1ADCAverage').getContext('2d');
	var Y2ADCAverage = document.getElementById('Y2ADCAverage').getContext('2d');
	var Y3ADCAverage = document.getElementById('Y3ADCAverage').getContext('2d');

	xLayerLength = (l[4].length - 2) * 4;
	yLayerLength = (l[5].length - 2) * 4;
	geometry = g;
	layers = l;
	if (xLayerLength == null) {
		xLayerLength = 28;
	}
	if (yLayerLength == null) {
		yLayerLength = 48;
	}
		  
	var xLabels = [];
	for(var i = 0; i < xLayerLength; i++){
	  xLabels.push('Channel ' + i.toString());
	}

	var yLabels = [];
	for(var i = 0; i < yLayerLength; i++){
	  yLabels.push('Channel ' + i.toString());
	}
	
	var chartComments = "Run: "+globalThis.runNumber+' '+globalThis.conversionComments;
	var options = {
	  scales: {
	    y: {
	      ticks: {
	        stepSize: 1, // Set the step size to 1 to show only whole numbers
	        beginAtZero: true // Start the axis from zero
	      }
	    }
	  }
	};
	var start1 = new Date();
	var CAENOptions = {
		scales: {
		y: {
		 		beginAtZero: true,
		 		stepSize: 1,
		 		precision: 0,// Set the step size to 1 to show only whole numbers
			},
		},		
	};
	//X CAEN 0
	var dataX1 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'X CAEN 0 -'+chartComments, // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: populateX('x', 0), // Array of numerical values for the bars
	    },
	  ],
	};
	var barChartX1 = new Chart(ctx1, {
    	type: 'bar',
    	data: dataX1,
    	options: CAENOptions,
	});
	document.getElementById('downloadXCAEN0').addEventListener('click', () => {
	    downloadArray(populateX('x', 0), 'XCAEN0data.csv');
	});
	document.getElementById('downloadXCAEN0data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedX, 0), 'XCAEN0originaldata.csv');
	});
	
	//X CAEN 2
	var dataX2 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'X CAEN 2 -'+chartComments,
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: populateX('x', 1),
	     },
	  ],
	};
	var barChartX2 = new Chart(ctx2, {
	    type: 'bar',
	    data: dataX2,
	    options: CAENOptions,
	});
	document.getElementById('downloadXCAEN2').addEventListener('click', () => {
	    downloadArray(populateX('x', 1), 'XCAEN2data.csv');
	});
	document.getElementById('downloadXCAEN2data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedX, 1), 'XCAEN2originaldata.csv');
	});

	//X CAEN 3
	var dataX3 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
		{
	      label: 'X CAEN 4 -'+chartComments,
	       backgroundColor: 'rgba(20, 255, 132, 0.5)',
	       data: populateX('x', 2),
	     },
	  ],
	};
	var barChartX3 = new Chart(ctx3, {
	    type: 'bar',
	    data: dataX3,
	    options: CAENOptions,
	});  
	document.getElementById('downloadXCAEN4').addEventListener('click', () => {
	    downloadArray(populateX('x', 2), 'XCAEN4data.csv');
	});
	document.getElementById('downloadXCAEN4data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedX, 2), 'XCAEN4originaldata.csv');
	});

	//Y CAEN 1
	var dataY1 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y CAEN 1 -'+chartComments, // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: populateY('y', 0), // Array of numerical values for the bars
	    },
	  ],
	};
	var barChartY1 = new Chart(cty1, {
	    type: 'bar',
	    data: dataY1,
	    options: CAENOptions,
	});
	document.getElementById('downloadYCAEN1').addEventListener('click', () => {
	    downloadArray(populateY('y', 0), 'YCAEN1data.csv');
	});
	document.getElementById('downloadYCAEN1data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedY, 0), 'YCAEN1originaldata.csv');
	});

	//Y CAEN 3
	var dataY2 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y CAEN 3 -'+chartComments,
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: populateY('y', 1),
	     },
	  ],
	};	
	var barChartY2 = new Chart(cty2, {
	    type: 'bar',
	    data: dataY2,
	    options: CAENOptions,
	});
	document.getElementById('downloadYCAEN3').addEventListener('click', () => {
	    downloadArray(populateY('y', 1), 'YCAEN3data.csv');
	});
	document.getElementById('downloadYCAEN3data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedY, 1), 'YCAEN3originaldata.csv');
	});

	//Y CAEN 5
	var dataY3 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Y CAEN 5 -'+chartComments,
	       backgroundColor: 'rgba(20, 255, 132, 0.5)',
	       data: populateY('y', 2),
	          options: options,
	     },
	  ],
	};	
	var barChartY3 = new Chart(cty3, {
	    type: 'bar',
	    data: dataY3,
	    options: CAENOptions,
	});
	document.getElementById('downloadYCAEN5').addEventListener('click', () => {
	    downloadArray(populateY('y', 2), 'YCAEN5data.csv');
	});
	document.getElementById('downloadYCAEN5data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedY, 2), 'YCAEN5originaldata.csv');
	});
	var end1 = new Date();
	if (globalThis.showTime) {
		console.log("CAEN analysis: "+calculateProcessTime(end1,start1)+" seconds");
	}
	
	//these function calls get all the arrays needed for the coming charts
	start1 = new Date();
	getAnalysisXY();
	end1 = new Date();
	if (globalThis.showTime) {
		console.log("get dx and dy: "+calculateProcessTime(end1,start1)+" seconds");
	}
	start = new Date();
	getAnalysisBothLayers();	
	getAnalysisTopMiddleBothLayers();
	getAnalysisBottomMiddleBothLayers();	
	end1 = new Date();
	if (globalThis.showTime) {
		console.log("get dx and dy both layers: "+calculateProcessTime(end1,start1)+" seconds");
	}
	start1 = new Date();

	// fill the spinner data in draw2D with all the point tracking data	
	populateDropdownSix();
	populateDropdownFive();
	populateDropdownFour();
	
	//POINT TRACKING section
	var pointTrackingOptions = {
			plugins: {
			    tooltip: {
			        callbacks: {
			            label: function(tooltipItem) {
			                let label = `(${tooltipItem.parsed.x}, ${tooltipItem.parsed.y})`;
			                // Add the comment from your data
			                if (tooltipItem.raw.event) {
			                    label += ` - ${tooltipItem.raw.event}`;
			                }
			                return label;
			            },
			        }
			    }
			},
			scales: {
		    x: {
		      type: 'linear', // Use linear scale for the x-axis
		      position: 'bottom',
		    },
		    y: {
		      type: 'linear', // Use linear scale for the y-axis
		      position: 'left'
		    }
		  }		
	};
	
	//6 plane X middle hits
	var hit6middleXtotalEvents = getTotalChartEvents(tracking6MiddleHitsXY);
	var hit6middleXComments = chartComments+' Total Events: '+hit6middleXtotalEvents;
	var hit6middleX = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [{
		      label: 'Tracking: X middle hits '+hit6middleXComments,
		      backgroundColor: 'violet',
		      data: get6planemiddlehits(tracking6MiddleHitsXY),
		      options: options,
			  pointRadius: 3,
	     },],
	};	
	var pointTracking6X = new Chart(PTXYMIDDLE6, {	
	    type: 'scatter',
	    data: hit6middleX,
	    options: pointTrackingOptions,
	});
	document.getElementById('download6PTMHdata').addEventListener('click', () => {
	    download2DArray(tracking6MiddleHitsXY, '6PTMHoriginaldata.csv');
	});

	//6 plane X layer middle hits with only one hit on top and bottom
	var hit6XsinglepointsEvents = getTotalChartEvents(tracking6MiddleHitsXsingleTopBottom);
	var hit6XsinglepointsComments = chartComments+' Total Events: '+hit6XsinglepointsEvents;
	var hit6Xsinglepoints = {
		labels: xLabels, // Array of labels for each bar on the x-axis
		datasets: [{
		      label: 'Tracking X Layer only: middle hit with single cell top/bottom layers '+hit6XsinglepointsComments,
		      backgroundColor: 'lightblue',
		      data: get6singlepoints('X', tracking6MiddleHitsXsingleTopBottom),
		      options: options,
			  pointRadius: 3,
		   },],	
	};
	var pointTracking6XsinglePoints = new Chart(PTXYMIDDLEX6, {	
	    type: 'scatter',
	    data: hit6Xsinglepoints,
	    options: pointTrackingOptions,
	});
	document.getElementById('download6PTMHXdata').addEventListener('click', () => {
	    download2DArray(get6singlepoints('X', tracking6MiddleHitsXsingleTopBottom), '6PTMHXoriginaldata.csv');
	});
	
	//6 plane Y layer middle hits with only one hit on top and bottom	
	var hit6YsinglepointsEvents = getTotalChartEvents(tracking6MiddleHitsYsingleTopBottom);
	var hit6YsinglepointsComments = chartComments+' Total Events: '+hit6YsinglepointsEvents;
	var hit6Ysinglepoints = {
		labels: xLabels, // Array of labels for each bar on the x-axis
		datasets: [{
		      label: 'Tracking Y Layer only: middle hit with single cell top/bottom layers '+hit6YsinglepointsComments,
		      backgroundColor: 'lightgreen',
			  data: get6singlepoints('Y', tracking6MiddleHitsYsingleTopBottom),
		      options: options,
			  pointRadius: 3,
		   },],			
	};
	var pointTracking6YsinglePoints = new Chart(PTXYMIDDLEY6, {	
	    type: 'scatter',
	    data: hit6Ysinglepoints,
	    options: pointTrackingOptions,
	});
	document.getElementById('download6PTMHYdata').addEventListener('click', () => {
	    download2DArray(get6singlepoints('Y', tracking6MiddleHitsYsingleTopBottom), '6PTMHYoriginaldata.csv');
	});

	//6 plane XY layers middle hits with only one hit on top and bottom	
	var hit6XYsinglepointsEvents = getTotalChartEvents(tracking6MiddleHitsXsingleBothLayers);
	var hit6XYsinglepointsComments = chartComments+' Total Events: '+hit6XYsinglepointsEvents;
	var hit6XYsinglepoints = {
		labels: xLabels, // Array of labels for each bar on the x-axis
		datasets: [{
		      label: 'Tracking Both Layers: middle points '+hit6XYsinglepointsComments,
		      backgroundColor: 'orange',
		      data: get6singlepointsBothLayers('XY', tracking6MiddleHitsXsingleBothLayers),
		      options: options,
			  pointRadius: 3,
		   },],			
	};
	var pointTracking6XYsinglePoints = new Chart(PTXYMIDDLEXY6, {	
	    type: 'scatter',
	    data: hit6XYsinglepoints,
	    options: pointTrackingOptions,
	});
	//document.getElementById('download6PTMHXYdata').addEventListener('click', () => {
	//    download2DArray(get6singlepointsBothLayers('XY', tracking6MiddleHitsXsingleBothLayers), '6PTMHXYoriginaldata.csv');
	//});
	
	//6 plane tracking, frequency of difference between expected and actual points in middle X
	var barOptions = {
		scales: {
		  y: {
			beginAtZero: false,
		    stepSize: 1,
		    precision: 0,// Set the step size to 1 to show only whole numbers
		  },
		},
	};
	var hit6XhitsfrequencyEvents = getTotalChartEvents(tracking6MiddleHitsXY);
	var hit6XhitsfrequencyComments = chartComments+' Total Events: '+hit6XhitsfrequencyEvents;
	var hit6Xhitsfrequency = getFrequency6ExpectedActualforHits('X', tracking6MiddleHitsXY);
	var hit6XhitsfrequencyLabels = [];
	for (var i = 0; i < hit6Xhitsfrequency.length; i++) {
		hit6XhitsfrequencyLabels.push(hit6Xhitsfrequency[i].x);
	}
	var hit6XhitsfrequencyValues = Object.values(hit6Xhitsfrequency);
	var hit6Xhitsfrequency = {
		labels: hit6XhitsfrequencyLabels, // Array of labels for each bar on the x-axis
		datasets: [{
		      label: 'Tracking 6 planes: frequency of expected vs accepted point in middle X '+hit6XhitsfrequencyComments,
		      backgroundColor: 'red',
			  data: hit6XhitsfrequencyValues,
		      options: options,
			  pointRadius: 3,
		   },],			
	};
	var pointTracking6XHitsFrequency = new Chart(PDIFFMXHITS6, {	
	    type: 'bar',
	    data: hit6Xhitsfrequency,
	    options: barOptions,
	});
	document.getElementById('download6PDIFFMXHITSdata').addEventListener('click', () => {
	    download2DArray('', '6PDIFFMXHITSoriginaldata.csv');
	});

	//6 plane tracking, frequency of difference between expected and actual points in middle Y
	var hit6YhitsfrequencyEvents = getTotalChartEvents(tracking6MiddleHitsXY);
	var hit6YhitsfrequencyComments = chartComments+' Total Events: '+hit6YhitsfrequencyEvents;
	var hit6Yhitsfrequency = getFrequency6ExpectedActualforHits('Y', tracking6MiddleHitsXY);
	var hit6YhitsfrequencyLabels = [];
	for (var i = 0; i < hit6Yhitsfrequency.length; i++) {
		hit6YhitsfrequencyLabels.push(hit6Yhitsfrequency[i].x);
	}
	var hit6YhitsfrequencyValues = Object.values(hit6Yhitsfrequency);
	var hit6Yhitsfrequency = {
		labels: hit6YhitsfrequencyLabels, // Array of labels for each bar on the x-axis
		datasets: [{
		      label: 'Tracking 6 planes: frequency of expected vs accepted point in middle Y '+hit6YhitsfrequencyComments,
		      backgroundColor: 'blue',
			  data: hit6YhitsfrequencyValues,
		      options: options,
			  pointRadius: 3,
		   },],					
	};
	var pointTracking6XHitsFrequency = new Chart(PDIFFMYHITS6, {	
	    type: 'bar',
	    data: hit6Yhitsfrequency,
	    options: barOptions,
	});
	document.getElementById('download6PDIFFMYHITSdata').addEventListener('click', () => {
	    download2DArray('', '6PDIFFMYHITSoriginaldata.csv');
	});

	//6 plane tracking, delta XY for middle hits			
	var dxdyhitsEvents = getTotalChartEvents(tracking6MiddleHitsXY);;
	var dxdyhitsComments = chartComments+' Total Events: '+dxdyhitsEvents;
	var dxdyhits = {
		labels: xLabels, // Array of labels for each bar on the x-axis
		datasets: [{
		      label: 'Delta X and Y for hits '+dxdyhitsComments,
		      backgroundColor: 'cyan',
			  data: getDeltaXYforhits('TB',tracking6MiddleHitsXY),
		      options: options,
			  pointRadius: 3,
		   },]							
	};
	var dxdyhitsScatter = new Chart(DXDYHITS6, {	
	    type: 'scatter',
	    data: dxdyhits,
	    options: pointTrackingOptions,
	});
	document.getElementById('download6DXHITSDY').addEventListener('click', () => {
	    download2DArray('', 'download6DXHITSDYoriginaldata.csv');
	});
	

	
	//LEGO plot
	var xx = [];
	var yy = [];
	var deltaXYformiddlehits = getDeltaXYforhits('TB',tracking6MiddleHitsXY);
	for (var i = 0; i < deltaXYformiddlehits.length; i ++) {
		xx[i] = deltaXYformiddlehits[i].x;
		yy[i] = deltaXYformiddlehits[i].y;
	}

	var data = [
	  {
	    x: xx,
	    y: yy,
	    type: 'histogram2d',
		colorscale: 'Jet',// or 'Viridis', 'Hot', 'Greys', etc.
		autobinx: false,
		xbins: {
		  start: -30,
		  end: 30,
		  size: 1
		},
		autobiny: false,
		ybins: {
		  start: -30,
		  end: 30,
		  size: 1
		},		
		//nbinsx: 50,
		//nbinsy: 50,
		//colorscale: [
		//    ['0', 'rgb(12,51,131)'],    // low end
		//    ['0.5', 'rgb(242,211,56)'], // middle
		//    ['1', 'rgb(217,30,30)']     // high end
		//  ]
		//Set the histnorm attribute to options like 'probability', 'percent', 'density', or 'probability density'.
		histnorm: 'density', // Normalize to show probability
		//zsmooth: 'best', // 'best' performs bi-linear interpolation
	  }
	];
	var layout = {
	  title: '2D Histogram of DX/DY Data '+chartComments,
	  xaxis: { title: 'DX/DY for X Layer' },
	  yaxis: { title: 'DX/DY for Y Layer' },
	  height: 600, // Set the desired height in pixels
	  width: 950,  // Set the desired width in pixels
	  // Optional: add margins, axes details, etc.
	  //margin: { t: 50 } // Example margin to prevent title cutoff	  
	  // Add custom shapes, e.g., a vertical line at mean of X
	  //shapes: [{
	  //    type: 'line',
	  //    xref: 'x', yref: 'paper', // reference the x-axis data and paper height
	  //    x0: 50, y0: 0,
	  //    x1: 50, y1: 1,
	  //    line: { color: 'black', width: 2, dash: 'dashdot' }
	  //  }]
	  //shapes: [{
	  //    type: 'line',
	  //    xref: 'x',
	  //    yref: 'paper',
	  //    x0: meanX, // assuming meanX is calculated
	  //    y0: 0,
	  //    x1: meanX,
	  //    y1: 1,
	  //    line: {
	  //        color: 'red',
	  //        width: 2,
	  //        dash: 'dash'
	  //    }
	 // }]
	};
	Plotly.newPlot('LEGO', data, layout);	
	
	//6 plane missed X middle point
	var missed6middleXtotalEvents = getTotalChartEvents(tracking6MiddleMissedX);
	var missed6middleXComments = chartComments+' Total Events: '+missed6middleXtotalEvents;
	var missed6middleX = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [{
		      label: 'Tracking: X middle miss '+missed6middleXComments,
		      backgroundColor: 'red',
		      data: get6planemiddlemissed(tracking6MiddleMissedX, "X"),
		      options: options,
			  pointRadius: 3,
	     },],
	};	
	var pointTracking6MiddleX = new Chart(PTMX6, {	
	    type: 'scatter',
	    data: missed6middleX,
	    options: pointTrackingOptions,
	});
	document.getElementById('download6PTMXdata').addEventListener('click', () => {
	    download2DArray(tracking6MiddleMissedX, '6PTMXHoriginaldata.csv');
	});
	
	//6 plane missed Y middle point
	var missed6middleYtotalEvents = getTotalChartEvents(tracking6MiddleMissedY);
	var missed6middleYComments = chartComments+' Total Events: '+missed6middleYtotalEvents;
	var missed6middleY = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [{
		       label: 'Tracking: Y middle miss '+ missed6middleYComments,
		       backgroundColor: 'green',
		       data: get6planemiddlemissed(tracking6MiddleMissedY, "Y"),
		       options: options,
			   pointRadius: 3,
	     },],
	};	
	var pointTracking6MiddleY = new Chart(PTMY6, {	
	    type: 'scatter',
	    data: missed6middleY,
	    options: pointTrackingOptions,
	});	
	document.getElementById('download6PTMYdata').addEventListener('click', () => {
	    download2DArray(tracking6MiddleMissedY, '6PTMYHoriginaldata.csv');
	});
	
	//6 plane missed XY middle point
	var missed6middleXYtotalEvents = getTotalChartEvents(tracking6MiddleMissedXY);
	var missed6middleXYComments = chartComments+' Total Events: '+missed6middleXYtotalEvents;
	var missed6middleXY = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [{
	       label: 'Tracking: X and Y middle miss '+missed6middleXYComments,
	       backgroundColor: 'blue',
	       data: get6planemiddlemissed(tracking6MiddleMissedXY, "XY"),
	       options: options,
		   pointRadius: 3,
	     },],
	};	
	var pointTracking6MiddleXY = new Chart(PTMXY6, {	
	    type: 'scatter',
	    data: missed6middleXY,
	    options: pointTrackingOptions,
	});	
	document.getElementById('download6PTMXYdata').addEventListener('click', () => {
	    download2DArray(tracking6MiddleMissedXY, '6PTMXYHoriginaldata.csv');
	});
	
	//6 plane missed X frequency
	var frequency6MiddleXtotalEvents = getTotalChartEvents(tracking6MiddleMissedX) + getTotalChartEvents(tracking6MiddleMissedXY);
	var frequency6MiddleXComments = chartComments+' Total Events: '+frequency6MiddleXtotalEvents;
	var frequency6MiddleX = getFrequency6ExpectedActual('X',tracking6MiddleMissedX,tracking6MiddleMissedXY);
	var labels6MX = [];//Object.keys(frequency6MiddleX);
	for (var i = 0; i < frequency6MiddleX.length; i++) {
		labels6MX.push(frequency6MiddleX[i].x);
	}
	var values6MX = Object.values(frequency6MiddleX);
	var frequency6MiddleX = {
	  labels: labels6MX, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 6 planes: frequency of expected vs actual point in middle X '+frequency6MiddleXComments,
	       backgroundColor: 'darkblue',
	       data: values6MX,
	     },
	  ],
	};	
	var frequencyPointTracking6MiddleX = new Chart(PDIFFMX6, {	
	    type: 'bar',
	    data: frequency6MiddleX,
	    options: barOptions,
	});	
	document.getElementById('download6PDIFFMXdata').addEventListener('click', () => {
	    download2DArray(frequency6MiddleX, 'PDIFFMX6originaldata.csv');
	});
	
	//6 plane missed Y frequency
	var frequency6MiddleYtotalEvents = getTotalChartEvents(tracking6MiddleMissedY) + getTotalChartEvents(tracking6MiddleMissedXY);
	var frequency6MiddleYComments = chartComments+' Total Events: '+frequency6MiddleYtotalEvents;
	var frequency6MiddleY = getFrequency6ExpectedActual('Y',tracking6MiddleMissedY,tracking6MiddleMissedXY);
	var labels6MY = [];//Object.keys(frequency6MiddleY);
	for (var i = 0; i < frequency6MiddleY.length; i++) {
		labels6MY.push(frequency6MiddleY[i].x);
		}
	var values6MY = Object.values(frequency6MiddleY);
	var frequency6MiddleY = {
	  labels: labels6MY, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 6 planes: frequency of expected vs actual point in middle Y '+frequency6MiddleYComments,
	       backgroundColor: 'darkgreen',
	       data: values6MY,
	     },
	  ],
	};	
	var frequencyPointTracking6MiddleY = new Chart(PDIFFMY6, {	
	    type: 'bar',
	    data: frequency6MiddleY,
	    options: barOptions,
	});	
	document.getElementById('download6PDIFFMYdata').addEventListener('click', () => {
	    download2DArray(frequency6MiddleY, 'PDIFFMY6originaldata.csv');
	});
	
	end1 = new Date();
	if (globalThis.showTime) {
		console.log("6 plane tracking : "+calculateProcessTime(end1,start1)+" seconds");
	}
	start1 = new Date();
	
	// 5 planes, X top missing
	var missing5TopXtotalEvents = getTotalChartEvents(tracking5TopMissingX);
	var tracking5TopMissingXComments = chartComments+' Total Events: '+missing5TopXtotalEvents;
	var tracking5TopMissingX2_27Counts = getCountsBetween5('X','TX',tracking5TopMissingX, 2.5, 26.0);
	var tracking5TopMissingY2_47Counts = getCountsBetween5('Y','TX',tracking5TopMissingX, 4.0, 45.0);
	var tracking5TopMissingXExtraComments = '- x between 2.5 and 26, Count : '+tracking5TopMissingX2_27Counts;
	tracking5TopMissingXExtraComments += '- y between 4 and 45, Count: '+tracking5TopMissingY2_47Counts;
	var missing5TopX = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 5 planes: X top missing '+tracking5TopMissingXComments+tracking5TopMissingXExtraComments,
	       backgroundColor: 'magenta',
	       data: get5planemissing(tracking5TopMissingX, "TX"),
	          options: options,
		  pointRadius: 3,
	     },
	  ],
	};	
	var pointTracking5TopX = new Chart(PTTX5, {	
	    type: 'scatter',
	    data: missing5TopX,
	    options: pointTrackingOptions,
	});	
	document.getElementById('download5PTTXdata').addEventListener('click', () => {
	    download2DArray(tracking5TopMissingX, '5PTTXoriginaldata.csv');
	});

	//5 planes x middle missing		
	var missing5MiddleXtotalEvents = getTotalChartEvents(tracking5MiddleMissingX);
	var tracking5MiddleMissingX2_27Counts = getCountsBetween5('X','MX',tracking5MiddleMissingX, 2.5, 26.0);
	var tracking5MiddleMissingY2_47Counts = getCountsBetween5('Y','MX',tracking5MiddleMissingX, 4.0, 45.0);
	var tracking5MiddleMissingXExtraComments = '- x between 2.5 and 26, Count : '+tracking5MiddleMissingX2_27Counts;
	tracking5MiddleMissingXExtraComments += '- y between 4 and 45, Count: '+tracking5MiddleMissingY2_47Counts;
	var tracking5MiddleMissingXComments = chartComments+' Total Events: '+missing5MiddleXtotalEvents + tracking5MiddleMissingXExtraComments;
	var missing5MiddleX = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 5 planes: X middle missing '+tracking5MiddleMissingXComments,
	       backgroundColor: 'orange',
	       data: get5planemissing(tracking5MiddleMissingX, "MX"),
	          options: options,
		  pointRadius: 3,
	     },
	  ],
	};	
	var pointTracking5MiddleX = new Chart(PTMX5, {	
	    type: 'scatter',
	    data: missing5MiddleX,
	    options: pointTrackingOptions,
	});	
	document.getElementById('download5PTMXdata').addEventListener('click', () => {
	    download2DArray(tracking5MiddleMissingX, '5PTMXoriginaldata.csv');
	});
	
	//5 planes x bottom missing
	var missing5BottomXtotalEvents = getTotalChartEvents(tracking5BottomMissingX);
	var tracking5BottomMissingX2_27Counts = getCountsBetween5('X','BX',tracking5BottomMissingX, 2.5, 26.0);
	var tracking5BottomMissingY2_47Counts = getCountsBetween5('Y','BX',tracking5BottomMissingX, 4.0, 45.0);
	var tracking5BottomMissingXExtraComments = '- x between 2.5 and 26, Count : '+tracking5BottomMissingX2_27Counts;
	tracking5BottomMissingXExtraComments += '- y between 4 and 45, Count: '+tracking5BottomMissingY2_47Counts;
	var tracking5BottomMissingXComments = chartComments+' Total Events: '+missing5BottomXtotalEvents + tracking5BottomMissingXExtraComments;
	var missing5BottomX = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 5 planes: X bottom missing '+tracking5BottomMissingXComments,
	       backgroundColor: 'brown',
	       data: get5planemissing(tracking5BottomMissingX, "BX"),
	          options: options,
		  pointRadius: 3,
	     },
	  ],
	};	
	var pointTracking5BottomX = new Chart(PTBX5, {	
	    type: 'scatter',
	    data: missing5BottomX,
	    options: pointTrackingOptions,
	});	
	document.getElementById('download5PTBXdata').addEventListener('click', () => {
	    download2DArray(tracking5BottomMissingX, '5PTBXoriginaldata.csv');
	});
	
	//5 planes y top missing
	var missing5TopYMissingtotalEvents = getTotalChartEvents(tracking5TopMissingY);
	var tracking5TopMissingY2_27Counts = getCountsBetween5('X','TY',tracking5TopMissingY, 2.5, 26.0);
	var tracking5TopMissingY2_47Counts = getCountsBetween5('Y','TY',tracking5TopMissingY, 4.0, 45.0);
	var tracking5TopMissingYExtraComments = '- x between 2.5 and 26, Count : '+tracking5TopMissingY2_27Counts;
	tracking5TopMissingYExtraComments += '- y between 4 and 45, Count: '+tracking5TopMissingY2_47Counts;
	var tracking5TopYMissingComments = chartComments+' Total Events: '+missing5TopYMissingtotalEvents + tracking5TopMissingYExtraComments;	
	var missing5TopY = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 5 planes: Y top missing '+tracking5TopYMissingComments,
	       backgroundColor: 'darkgreen',
	       data: get5planemissing(tracking5TopMissingY, "TY"),
	          options: options,
		  pointRadius: 3,
	     },
	  ],
	};		
	var pointTracking5TopY = new Chart(PTTY5, {	
	    type: 'scatter',
	    data: missing5TopY,
	    options: pointTrackingOptions,
	});	
	document.getElementById('download5PTTYdata').addEventListener('click', () => {
	    download2DArray(tracking5TopMissingY, '5PTTYoriginaldata.csv');
	});

	//5 plane y middle missing
	var missing5MiddleYMissingtotalEvents = getTotalChartEvents(tracking5MiddleMissingY);
	var tracking5MiddleMissingY2_27Counts = getCountsBetween5('X','MY',tracking5MiddleMissingY, 2.5, 26.0);
	var tracking5MiddleMissingY2_47Counts = getCountsBetween5('Y','MY',tracking5MiddleMissingY, 4.0, 45.0);
	var tracking5MiddleMissingYExtraComments = '- x between 2.5 and 26, Count : '+tracking5MiddleMissingY2_27Counts;
	tracking5MiddleMissingYExtraComments += '- y between 4 and 45, Count: '+tracking5MiddleMissingY2_47Counts;
	var tracking5MiddleYMissingComments = chartComments+' Total Events: '+tracking5MiddleMissingYExtraComments;	
	var missing5MiddleY = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 5 planes: Y middle missing '+missing5MiddleYMissingtotalEvents+tracking5MiddleMissingYExtraComments,
	       backgroundColor: 'pink',
	       data: get5planemissing(tracking5MiddleMissingY, "MY"),
	          options: options,
		  pointRadius: 3,
	     },
	  ],
	};	
	var pointTracking5MiddleY = new Chart(PTMY5, {	
	    type: 'scatter',
	    data: missing5MiddleY,
	    options: pointTrackingOptions,
	});	
	document.getElementById('download5PTMYdata').addEventListener('click', () => {
	    download2DArray(tracking5MiddleMissingY, '5PTMYoriginaldata.csv');
	});
	
	//5 plane y bottom missing
	var missing5BottomYMissingtotalEvents = getTotalChartEvents(tracking5BottomMissingY);
	var tracking5BottomMissingY2_27Counts = getCountsBetween5('X','BY',tracking5BottomMissingY, 2.5, 26.0);
	var tracking5BottomMissingY2_47Counts = getCountsBetween5('Y','BY',tracking5BottomMissingY, 4.0, 45.0);
	var tracking5BottomMissingYExtraComments = '- x between 2.5 and 26, Count : '+tracking5BottomMissingY2_27Counts;
	tracking5BottomMissingYExtraComments += '- y between 4 and 45, Count: '+tracking5BottomMissingY2_47Counts;
	var tracking5BottomYMissingComments = chartComments+' Total Events: '+missing5BottomYMissingtotalEvents+tracking5BottomMissingYExtraComments;	
	var missing5BottomY = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 5 planes: Y bottom missing '+tracking5BottomYMissingComments,
	       backgroundColor: 'darkpink',
	       data: get5planemissing(tracking5BottomMissingY, "BY"),
	          options: options,
		  pointRadius: 3,
	     },
	  ],
	};	
	var pointTracking5BottomY = new Chart(PTBY5, {	
	    type: 'scatter',
	    data: missing5BottomY,
	    options: pointTrackingOptions,
	});			
	document.getElementById('download5PTBYdata').addEventListener('click', () => {
	    download2DArray(tracking5BottomMissingY, '5PTBYoriginaldata.csv');
	});
	end1 = new Date();
	if (globalThis.showTime) {		
		console.log("5 plane tracking : "+calculateProcessTime(end1,start1)+" seconds");
	}
	start1 = new Date();

		//4 plane top missing
	var missing4TopMissingtotalEvents = getTotalChartEvents(tracking4TopMissing);
	var trackin4TopMissingY2_27Counts = getCountsBetween4('X','T',tracking4TopMissing, 2.5, 26.0);
	var tracking4TopMissingY2_47Counts = getCountsBetween4('Y','T',tracking4TopMissing, 4.0, 45.0);
	var tracking4TopMissingYExtraComments = '- x between 2.5 and 26, Count : '+trackin4TopMissingY2_27Counts;
	tracking4TopMissingYExtraComments += '- y between 4 and 45, Count: '+tracking4TopMissingY2_47Counts;
	var tracking4TopMissingComments = chartComments+' Total Events: '+missing4TopMissingtotalEvents + tracking4TopMissingYExtraComments;	
	var missing4Top = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 4 planes: top missing '+tracking4TopMissingComments,
	       backgroundColor: 'darkyellow',
	       data: get4planemissing(dx, "T"),
	          options: options,
		  pointRadius: 3,
	     },
	  ],
	};	
	var pointTracking4Top = new Chart(PTT4, {	
	    type: 'scatter',
	    data: missing4Top,
	    options: pointTrackingOptions,
	});		
	document.getElementById('download4PTdata').addEventListener('click', () => {
	    download2DArray(tracking4TopMissing, '4PToriginaldata.csv');
	});
		
	//4 plane middle missing
	var missing4MiddleMissingtotalEvents = getTotalChartEvents(tracking4MiddleMissing);
	var trackin4MiddleMissingY2_27Counts = getCountsBetween4('X','M',tracking4MiddleMissing, 2.5, 26.0);
	var tracking4MiddleMissingY2_47Counts = getCountsBetween4('Y','M',tracking4MiddleMissing, 4.0, 45.0);
	var tracking4MiddleMissingYExtraComments = '- x between 2.5 and 26, Count : '+trackin4MiddleMissingY2_27Counts;
	tracking4MiddleMissingYExtraComments += '- y between 4 and 45, Count: '+tracking4MiddleMissingY2_47Counts;
	var tracking4MiddleMissingComments = chartComments+' Total Events: '+missing4MiddleMissingtotalEvents+tracking4MiddleMissingYExtraComments;	
	var missing4Middle = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 4 planes: middle missing '+tracking4MiddleMissingComments,
	       backgroundColor: 'darkblue',
	       data: get4planemissing(tracking4MiddleMissing, "M"),
	          options: options,
		  pointRadius: 3,
	     },
	  ],
	};	
	var pointTracking4Middle = new Chart(PTM4, {	
	    type: 'scatter',
	    data: missing4Middle,
	    options: pointTrackingOptions,
	});		
	document.getElementById('download4PMdata').addEventListener('click', () => {
	    download2DArray(tracking4MiddleMissing, '4PMoriginaldata.csv');
	});
	
	//4 plane bottom missing
	var missing4BottomMissingtotalEvents = getTotalChartEvents(tracking4BottomMissing);
	var trackin4BottomMissingY2_27Counts = getCountsBetween4('X','M',tracking4BottomMissing, 2.5, 26.0);
	var tracking4BottomMissingY2_47Counts = getCountsBetween4('Y','M',tracking4BottomMissing, 4.0, 45.0);
	var tracking4BottomMissingYExtraComments = '- x between 2.5 and 26, Count : '+trackin4BottomMissingY2_27Counts;
	tracking4BottomMissingYExtraComments += '- y between 4 and 45, Count: '+tracking4BottomMissingY2_47Counts;
	var tracking4BototomMissingComments = chartComments+' Total Events: '+missing4BottomMissingtotalEvents+tracking4BottomMissingYExtraComments;	
	var missing4Bottom = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Tracking 4 planes: bottom missing '+chartComments+tracking4BototomMissingComments,
	       backgroundColor: 'darkgreen',
	       data: get4planemissing(tracking4BottomMissing, "B"),
	          options: options,
		  pointRadius: 3,
	     },
	  ],
	};	
	var pointTracking4Bottom = new Chart(PTB4, {	
	    type: 'scatter',
	    data: missing4Bottom,
	    options: pointTrackingOptions,
	});	
	document.getElementById('download4PBdata').addEventListener('click', () => {
	    download2DArray(tracking4BottomMissing, '4BToriginaldata.csv');
	});
	end1 = new Date();
	if (globalThis.showTime) {
		console.log("4 plane tracking : "+calculateProcessTime(end1,start1)+" seconds");
	}
	start1 = new Date();

	//delta X / delta Y
	var deltaXdeltaYOptions = {
		      scales: {
		        x: {
		          type: 'linear', // Use linear scale for the x-axis
		          position: 'bottom',
		          suggestedMin: 0, // Set the minimum value to 0
		        },
		        y: {
		          type: 'linear', // Use linear scale for the y-axis
		          position: 'left'
		        }
		      }
		    };			
	//delta x delta y		
	var dxdyTotalEvents = getTotalChartEvents(dxbothlayers);
	var dxdyTopMiddleEvents = getTotalChartEvents(dxtopmiddlebothlayers);
	var dxdyMiddleBottomEvents = getTotalChartEvents(dxbottommiddlebothlayers);
	var dxdyComments = chartComments+' Total Events: '+dxdyTotalEvents;	
	var dxdyTopMiddleComments = chartComments+' Total Events: '+dxdyTopMiddleEvents;	
	var dxdyMiddleBottomComments = chartComments+' Total Events: '+dxdyMiddleBottomEvents;	
	var DXDYdatasets = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX - DY -'+dxdyComments, // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'cyan', // Color or array of colors for the bars
	       data: getDxDy(0), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 },
		 {
		   label: 'DX - DY Top/Middle -'+dxdyTopMiddleComments, // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getDxDyMiddle(dxtopmiddlebothlayers, dytopmiddlebothlayers, 0), // Array of numerical values for the bars
		   pointRadius: 3,
		 },		 
		 {
		   label: 'DX - DY Middle/Bottom -'+dxdyMiddleBottomComments, // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'orange', // Color or array of colors for the bars
		   data: getDxDyMiddle(dxbottommiddlebothlayers, dybottommiddlebothlayers, 0), // Array of numerical values for the bars
		   pointRadius: 3,
		 },
	 ],
	};				
	var scatterDXDYChart = new Chart(dxdy, {
		    type: 'scatter',
		    data: DXDYdatasets,
		    options: deltaXdeltaYOptions,
	});	
	document.getElementById('downloadDXDY').addEventListener('click', () => {
	    downloadXYdata(getDxDy(0), 'DXDYdata.csv');
	});
	document.getElementById('downloadDXdata').addEventListener('click', () => {
	    download2DArray(dxbothlayers, 'DXoriginaldata.csv');
	});
	document.getElementById('downloadDYdata').addEventListener('click', () => {
	    download2DArray(dybothlayers, 'DYoriginaldata.csv');
	});
	document.getElementById('downloadDXDYTOPMIDDLE').addEventListener('click', () => {
	    downloadXYdata(getDxDyMiddle(dxtopmiddlebothlayers, dytopmiddlebothlayers, 0), 'DXDYTOPMIDDLEdata.csv');
	});
	document.getElementById('downloadDXTMdata').addEventListener('click', () => {
	    download2DArray(dxtopmiddlebothlayers, 'DXTMoriginaldata.csv');
	});
	document.getElementById('downloadDYTMdata').addEventListener('click', () => {
	    download2DArray(dytopmiddlebothlayers, 'DYTMoriginaldata.csv');
	});	
	document.getElementById('downloadDXDYBOTTOMMIDDLE').addEventListener('click', () => {
	    downloadXYdata(getDxDyMiddle(dxbottommiddlebothlayers, dybottommiddlebothlayers, 0), 'DXDYBOTTOMMIDDLEdata.csv');
	});
	document.getElementById('downloadDXBMdata').addEventListener('click', () => {
	    download2DArray(dxbottommiddlebothlayers, 'DXBMoriginaldata.csv');
	});
	document.getElementById('downloadDYBMdata').addEventListener('click', () => {
	    download2DArray(dybottommiddlebothlayers, 'DYBMoriginaldata.csv');
	});
	
	//delta X Frequencies
  	var deltaXFrequencyEvents = getTotalChartEvents(dxbothlayers);
	var deltaXTopMiddleFrequencyEvents = getTotalChartEvents(dxtopmiddlebothlayers);
	var deltaXMiddleBottomFrequencyEvents = getTotalChartEvents(dxbottommiddlebothlayers);
	var deltaXFrequencyComments = chartComments+' Total Events: '+deltaXFrequencyEvents;	
	var deltaXTopMiddleFrequencyComments = chartComments+' Total Events: '+deltaXTopMiddleFrequencyEvents;	
	var deltaXMiddleBottomFrequencyComments = chartComments+' Total Events: '+deltaXMiddleBottomFrequencyEvents;	
	var deltaXFrequency = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX Frequency Distribution -'+deltaXFrequencyComments, // Label for the dataset
		   //borderColor: 'gray',
	       backgroundColor: 'blue', // Color or array of colors for the bars
	       data: calculateDeltaXDeltaYFrequency(dxbothlayers,0,2), 
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
	  	 },
		 {
		   label: 'DX Top/Middle Frequency Distribution -'+deltaXTopMiddleFrequencyComments, // Label for the dataset
		   //borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: calculateDeltaXDeltaYFrequency(dxtopmiddlebothlayers,0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
		 },		 
		 {
		   label: 'DX Middle/Bottom Frequency Distribution -'+deltaXMiddleBottomFrequencyComments, // Label for the dataset
		   //borderColor: 'gray',
		   backgroundColor: 'pink', // Color or array of colors for the bars
		   data: calculateDeltaXDeltaYFrequency(dxbottommiddlebothlayers,0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
		 },		
	 ],
	};		
	var scatterDX1DChart = new Chart(dx1d, {
		    type: 'line',
			labels: deltaXFrequency.datasets[0].data.map(item => item.x),
		    data: deltaXFrequency,
		    options: deltaXdeltaYOptions,
	});	
	document.getElementById('downloadDX1D').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dxbothlayers,0,2), 'DX1Ddata.csv');
	});	
	document.getElementById('downloadDX1Ddata').addEventListener('click', () => {
	    download2DArray(dxbothlayers, 'DX1Doriginaldata.csv');
	});	
	document.getElementById('downloadDX1DTOPMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dxtopmiddlebothlayers,0,2), 'DX1DTOPMIDDLEdata.csv');
	});	
	document.getElementById('downloadDX1DTOPMIDDLEdata').addEventListener('click', () => {
	    download2DArray(dxtopmiddlebothlayers, 'DX1DTOPMIDDLEoriginaldata.csv');
	});	
	document.getElementById('downloadDX1DBOTTOMMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dxbottommiddlebothlayers,0,2), 'DX1DBOTTOMMIDDLEdata.csv');
	});	
	document.getElementById('downloadDX1DBOTTOMMIDDLEdata').addEventListener('click', () => {
	    download2DArray(dxbottommiddlebothlayers, 'DX1DBOTTOMMIDDLEoriginaldata.csv');
	});	

	//delta Y frequencies
	var deltaYFrequencyEvents = getTotalChartEvents(dybothlayers);
	var deltaYTopMiddleFrequencyEvents = getTotalChartEvents(dytopmiddlebothlayers);
	var deltaYMiddleBottomFrequencyEvents = getTotalChartEvents(dybottommiddlebothlayers);
	var deltaYFrequencyComments = chartComments+' Total Events: '+deltaYFrequencyEvents;	
	var deltaYTopMiddleFrequencyComments = chartComments+' Total Events: '+deltaYTopMiddleFrequencyEvents;	
	var deltaYMiddleBottomFrequencyComments = chartComments+' Total Events: '+deltaYMiddleBottomFrequencyEvents;	
	var deltaYFrequency = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DY Frequency Distribution -'+deltaYFrequencyComments, // Label for the dataset
	       backgroundColor: 'magenta', // Color or array of colors for the bars
	       data: calculateDeltaXDeltaYFrequency(dybothlayers,0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
	  	 },
		 {
		   label: 'DY Top/Middle Frequency Distribution -'+deltaYTopMiddleFrequencyComments, // Label for the dataset
		   backgroundColor: 'green', // Color or array of colors for the bars
		   data: calculateDeltaXDeltaYFrequency(dytopmiddlebothlayers,0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
		 },		 
		 {
		   label: 'DY Middle/Bottom Frequency Distribution -'+deltaYMiddleBottomFrequencyComments, // Label for the dataset
		   backgroundColor: 'lightpink', // Color or array of colors for the bars
		   data: calculateDeltaXDeltaYFrequency(dybottommiddlebothlayers,0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
		 },
	 ],
	};		
	var scatterDY1DChart = new Chart(dy1d, {
		    type: 'line',
			labels: deltaYFrequency.datasets[0].data.map(item => item.x),
		    data: deltaYFrequency,
		    options: deltaXdeltaYOptions,
	});	
	document.getElementById('downloadDY1D').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dybothlayers,0,2), 'DY1Ddata.csv');
	});	
	document.getElementById('downloadDY1Ddata').addEventListener('click', () => {
	    download2DArray(dybothlayers, 'DY1Doriginaldata.csv');
	});	
	document.getElementById('downloadDY1DTOPMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dytopmiddlebothlayers,0,2), 'DY1DTOPMIDDLEdata.csv');
	});	
	document.getElementById('downloadDY1DTOPMIDDLEdata').addEventListener('click', () => {
	    download2DArray(dytopmiddlebothlayers, 'DY1DTOPMIDDLEoriginaldata.csv');
	});	
	document.getElementById('downloadDY1DBOTTOMMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dybottommiddlebothlayers,0,2), 'DY1DBOTTOMMIDDLEdata.csv');
	});	
	document.getElementById('downloadDY1DBOTTOMMIDDLEdata').addEventListener('click', () => {
	    download2DArray(dybottommiddlebothlayers, 'DY1DBOTTOMMIDDLEoriginaldata.csv');
	});	

	// channel frequency for X
	var dxtopChannelComments = globalThis.selectedFileClean+' '+globalThis.conversionComment;
	var dxtopmiddleChannelComments = globalThis.selectedFileClean+' '+globalThis.conversionComment;
	var dxtopChannelfrequency = getChannelData('top',dxbothlayers, xLayerLength, 0);	
	var dxtopmiddleChannelfrequency = getChannelData('top',dxtopmiddlebothlayers, xLayerLength, 0);	
	var frequencyTopMapX = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of X Top Cells on Track -'+dxtopChannelComments, // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'green', // Color or array of colors for the bars
	       data: getFrequency(dxtopChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 },
		 {
		   label: 'Frequency of X Top Cells on Half-Track -'+dxtopmiddleChannelComments,
		   borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getFrequency(dxtopmiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
		 },		 
 	  ],
	};		
	var scatterDXT1dChart = new Chart(dxT1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyTopMapX,
		    options: deltaXdeltaYOptions,
	});	
	document.getElementById('downloadDXT1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxtopChannelfrequency), 'DXT1Ddata.csv');
	});
	document.getElementById('downloadDXT1Ddata').addEventListener('click', () => {
	    downloadArray(dxtopChannelfrequency, 'DXT1Dchanneldata.csv');
	});
	document.getElementById('downloadDXTM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxtopmiddleChannelfrequency), 'DXTM1Ddata.csv');
	});
	document.getElementById('downloadDXTM1Ddata').addEventListener('click', () => {
	    downloadArray(dxtopmiddleChannelfrequency, 'DXTM1Dchanneldata.csv');
	});

	//x middle channel frquency
	var dxmiddleChannelfrequencyComments = chartComments;
	var dxmiddleChannelfrequency = getChannelData('middle',dxbothlayers, xLayerLength, 0);	
	var dxmiddleChannelfrequencyT = getChannelData('middle',dxtopmiddlebothlayers, xLayerLength, 0);	
	var dxmiddleChannelfrequencyB = getChannelData('middle',dxbottommiddlebothlayers, xLayerLength, 0);	
	var frequencyMiddleMapX = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of X Middle Cells on Track -'+dxmiddleChannelfrequencyComments,
		   borderColor: 'gray',
	       backgroundColor: 'red', // Color or array of colors for the bars
	       data: getFrequency(dxmiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 },
		 {
		   label: 'Frequency of X Middle Cells on Half-Track (Top/Middle) -'+dxmiddleChannelfrequencyComments, 
		   borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getFrequency(dxmiddleChannelfrequencyT), // Array of numerical values for the bars
		   pointRadius: 3,
		 },		 
		 {
		   label: 'Frequency of X Middle Cells on Half-Track (Bottom/Middle -'+dxmiddleChannelfrequencyComments,
		   borderColor: 'gray',
		   backgroundColor: 'blue', // Color or array of colors for the bars
		   data: getFrequency(dxmiddleChannelfrequencyB), // Array of numerical values for the bars
		   pointRadius: 3,
		 },	
	  ],
	};		
	var scatterDXM1dChart = new Chart(dxM1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyMiddleMapX,
		    options: deltaXdeltaYOptions,
	});	
	document.getElementById('downloadDXM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxmiddleChannelfrequency), 'DXM1Ddata.csv');
	});
	document.getElementById('downloadDXM1Ddata').addEventListener('click', () => {
	    downloadArray(dxmiddleChannelfrequency, 'DXM1Dchanneldata.csv');
	});
	document.getElementById('downloadDXM1DT').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxmiddleChannelfrequencyT), 'DXM1DTdata.csv');
	});
	document.getElementById('downloadDXM1DTdata').addEventListener('click', () => {
	    downloadArray(dxmiddleChannelfrequencyT, 'DXM1DTchanneldata.csv');
	});
	document.getElementById('downloadDXM1DB').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxmiddleChannelfrequencyB), 'DXM1DBdata.csv');
	});
	document.getElementById('downloadDXM1DBdata').addEventListener('click', () => {
	    downloadArray(dxmiddleChannelfrequencyB, 'DXM1DBchanneldata.csv');
	});

	// x bottom frequency
	var dxbottomChannelfrequencyComments = chartComments;
	var dxbottomChannelfrequency = getChannelData('bottom',dxbothlayers, xLayerLength, 0);	
	var dxbottomMiddleChannelfrequency = getChannelData('bottom',dxbottommiddlebothlayers, xLayerLength, 0);	
	var frequencyBottomMapX = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of Bottom X cells on Track -'+dxbottomChannelfrequencyComments,
		   borderColor: 'gray',
	       backgroundColor: 'blue', // Color or array of colors for the bars
	       data: getFrequency(dxbottomChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 },
		 {
		   label: 'Frequency of X Bottom Cells on Half-Track -'+dxbottomChannelfrequencyComments,
		   borderColor: 'gray',
		   backgroundColor: 'lightgreen', // Color or array of colors for the bars
		   data: getFrequency(dxbottomMiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
		 },		 
	  ],
	};			
	var scatterDXB1dChart = new Chart(dxB1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyBottomMapX,
		    options: deltaXdeltaYOptions,
		}		
	);	
	document.getElementById('downloadDXB1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxbottomChannelfrequency), 'DXB1Ddata.csv');
	});
	document.getElementById('downloadDXB1Ddata').addEventListener('click', () => {
	    downloadArray(dxbottomChannelfrequency, 'DXB1Dchanneldata.csv');
	});
	document.getElementById('downloadDXBM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxbottomMiddleChannelfrequency), 'DXBM1Ddata.csv');
	});
	document.getElementById('downloadDXBM1Ddata').addEventListener('click', () => {
	    downloadArray(dxbottomMiddleChannelfrequency, 'DXBM1Dchanneldata.csv');
	});

	// y top middle channel frequency
	var dytopChannelfrequencyComments = chartComments;
	var dytopChannelfrequency = getChannelData('top',dybothlayers, yLayerLength, 0);
	var dytopMiddleChannelfrequency = getChannelData('top',dytopmiddlebothlayers, yLayerLength, 0);	
	var frequencyTopMapY = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of Top Y cells on Track -'+dytopChannelfrequencyComments,
		   borderColor: 'gray',
	       backgroundColor: 'green', // Color or array of colors for the bars
	       data: getFrequency(dytopChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 },
		 {
		   label: 'Frequency of Y Top Cells on Half-Track -'+dytopChannelfrequencyComments,
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getFrequency(dytopMiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
		 },		 
	  ],
	};		
	var scatterDYT1dChart = new Chart(dyT1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyTopMapY,
		    options: deltaXdeltaYOptions,
	});	
	document.getElementById('downloadDYT1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dytopChannelfrequency), 'DYT1Ddata.csv');
	});
	document.getElementById('downloadDYT1Ddata').addEventListener('click', () => {
	    downloadArray(dytopChannelfrequency, 'DYT1Dchanneldata.csv');
	});
	document.getElementById('downloadDYTM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dytopMiddleChannelfrequency), 'DYTM1Ddata.csv');
	});
	document.getElementById('downloadDYTM1Ddata').addEventListener('click', () => {
	    downloadArray(dytopMiddleChannelfrequency, 'DYTM1Dchanneldata.csv');
	});
	
	//y middle channel frequency		
	var dymiddleChannelfrequencyComments = chartComments;
	var dymiddleChannelfrequency = getChannelData('middle',dybothlayers, yLayerLength, 0);	
	var dymiddleChannelfrequencyT = getChannelData('middle',dytopmiddlebothlayers, yLayerLength, 0);	
	var dymiddleChannelfrequencyB = getChannelData('middle',dybottommiddlebothlayers, yLayerLength, 0);	
	var frequencyMiddleMapY = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of Y Middle Cells on Track -'+dymiddleChannelfrequencyComments,
		   borderColor: 'gray',
	       backgroundColor: 'crimson', // Color or array of colors for the bars
	       data: getFrequency(dymiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 },
		 {
		   label: 'Frequency of Y Middle Cells on Half-Track (Top/Middle) -'+dymiddleChannelfrequencyComments,
		   borderColor: 'gray',
		   backgroundColor: 'lightblue', // Color or array of colors for the bars
		   data: getFrequency(dymiddleChannelfrequencyT), // Array of numerical values for the bars
		   pointRadius: 3,
		 },		 
		 {
		   label: 'Frequency of Y Middle Cells on Half-Track (Bottom/Middle -'+dymiddleChannelfrequencyComments,		   borderColor: 'gray',
			borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getFrequency(dymiddleChannelfrequencyB), // Array of numerical values for the bars
		   pointRadius: 3,
		 },	
	  ],
	};			
	var scatterDYM1dChart = new Chart(dyM1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyMiddleMapY,
		    options: deltaXdeltaYOptions
	});	
	document.getElementById('downloadDYM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dymiddleChannelfrequency), 'DYM1Ddata.csv');
	});
	document.getElementById('downloadDYM1Ddata').addEventListener('click', () => {
	    downloadArray(dymiddleChannelfrequency, 'DYM1Dchanneldata.csv');
	});
	document.getElementById('downloadDYM1DT').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dymiddleChannelfrequencyT), 'DYM1DTdata.csv');
	});
	document.getElementById('downloadDYM1DTdata').addEventListener('click', () => {
	    downloadArray(dymiddleChannelfrequencyT, 'DYM1DTchanneldata.csv');
	});
	document.getElementById('downloadDYM1DB').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dymiddleChannelfrequencyB), 'DYM1DBdata.csv');
	});
	document.getElementById('downloadDYM1DBdata').addEventListener('click', () => {
	    downloadArray(dymiddleChannelfrequencyB, 'DYM1DBchanneldata.csv');
	});

	// y bottom channel frequency
	var dybottomChannelfrequencyComments = chartComments;
	var dybottomChannelfrequency = getChannelData('bottom',dybothlayers, yLayerLength, 0);	
	var dybottomMiddleChannelfrequency = getChannelData('bottom',dybottommiddlebothlayers, yLayerLength, 0);	
	var frequencyBottomMapY = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of Bottom Y cells on Track -'+dybottomChannelfrequencyComments,
		   borderColor: 'gray',
	       backgroundColor: 'purple', // Color or array of colors for the bars
	       data: getFrequency(dybottomChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 },
		 {
		   label: 'Frequency of Y Bottom Cells on Half-Track -'+dybottomChannelfrequencyComments,
		   borderColor: 'gray',
		   backgroundColor: 'lightgreen', // Color or array of colors for the bars
		   data: getFrequency(dybottomMiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 3,
		 },		 
	  ],
	};		
	var scatterDYB1dChart = new Chart(dyB1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyBottomMapY,
		    options: deltaXdeltaYOptions,
	});		
	document.getElementById('downloadDYB1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dybottomChannelfrequency), 'DYB1Ddata.csv');
	});
	document.getElementById('downloadDYB1Ddata').addEventListener('click', () => {
	    downloadArray(dybottomChannelfrequency, 'DYB1Dchanneldata.csv');
	});
	document.getElementById('downloadDYBM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dybottomMiddleChannelfrequency), 'DYBM1Ddata.csv');
	});
	document.getElementById('downloadDYBM1Ddata').addEventListener('click', () => {
	    downloadArray(dybottomMiddleChannelfrequency, 'DYBM1Dchanneldata.csv');
	});
	end1 = new Date();
	if (globalThis.showTime) {
		console.log("DX/DY : "+calculateProcessTime(end1,start1)+" seconds");
	}
	start1 = new Date();

	//dx dz charts
	var DXDZDYDZdatasetsComments = chartComments;
	var DXDZDYDZdatasets = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX/DZ - DY/DZ -'+DXDZDYDZdatasetsComments,
		   borderColor: 'gray',
	       backgroundColor: 'cyan', // Color or array of colors for the bars
	       data: getDxDz(0), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 }
	 ],
	};				
	var scatterDXDZDYDZChart = new Chart(dxdzdydz, {
		    type: 'scatter',
		    data: DXDZDYDZdatasets,
		    options: deltaXdeltaYOptions,
	});
	document.getElementById('downloadDXDZDYDZ').addEventListener('click', () => {
	    downloadXYdata(getDxDz(0), 'DXDZDYDZdata.csv');
	});
	document.getElementById('downloadDXDZDYDZXdata').addEventListener('click', () => {
	    download2DArray(dxbothlayers, 'DXDZDYDZXdata.csv');
	});
	document.getElementById('downloadDXDZDYDZYdata').addEventListener('click', () => {
	    download2DArray(dybothlayers, 'DXDZDYDZYdata.csv');
	});

	//dx dz top middle
	var DXDZDYDZTMdatasetsComments = chartComments;
	var DXDZDYDZTMdatasets = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX/DZ - DY/DZ (TOP-MIDDLE) -'+DXDZDYDZTMdatasetsComments,
		   borderColor: 'gray',
	       backgroundColor: 'yellow', // Color or array of colors for the bars
	       data: getDxyDzMiddle(dxtopmiddlebothlayers,dytopmiddlebothlayers, 0), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 }
	 ],
	};
	var scatterDXDZDYDZTMChart = new Chart(dxdzdydzTM, {
		    type: 'scatter',
		    data: DXDZDYDZTMdatasets,
		    options: deltaXdeltaYOptions,
	});
	document.getElementById('downloadDXDZDYDZTM').addEventListener('click', () => {
	    downloadXYdata(getDxyDzMiddle(dxtopmiddlebothlayers,dytopmiddlebothlayers, 0), 'DXDZDYDZTMdata.csv');
	});
	document.getElementById('downloadDXDZDYDZTMXdata').addEventListener('click', () => {
	    download2DArray(dxtopmiddlebothlayers, 'DXDZDYDZTMXdata.csv');
	});
	document.getElementById('downloadDXDZDYDZTMYdata').addEventListener('click', () => {
	    download2DArray(dytopmiddlebothlayers, 'DXDZDYDZTMYdata.csv');
	});

	//dx dz middle bottom
	var DXDZDYDZMBdatasetsComments = chartComments;
	var DXDZDYDZMBdatasets = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX/DZ - DY/DZ (MIDDLE-BOTTOM) -'+DXDZDYDZMBdatasetsComments,
		   borderColor: 'gray',
	       backgroundColor: 'orange', // Color or array of colors for the bars
	       data: getDxyDzMiddle(dxbottommiddlebothlayers,dybottommiddlebothlayers, 0), // Array of numerical values for the bars
		   pointRadius: 3,
	  	 }
	 ],
	};
	var scatterDXDZDYDZMBChart = new Chart(dxdzdydzMB, {
		    type: 'scatter',
		    data: DXDZDYDZMBdatasets,
		    options: deltaXdeltaYOptions,
	});
	document.getElementById('downloadDXDZDYDZMB').addEventListener('click', () => {
	    downloadXYdata(getDxyDzMiddle(dxbottommiddlebothlayers,dybottommiddlebothlayers, 0), 'DXDZDYDZMBdata.csv');
	});
	document.getElementById('downloadDXDZDYDZMBXdata').addEventListener('click', () => {
	    download2DArray(dxbottommiddlebothlayers, 'DXDZDYDZMBXdata.csv');
	});
	document.getElementById('downloadDXDZDYDZMBYdata').addEventListener('click', () => {
	    download2DArray(dybottommiddlebothlayers, 'DXDZDYDZMBYdata.csv');
	});
	end1 = new Date();
	if (globalThis.showTime) {
		console.log("DX/DZ : "+calculateProcessTime(end1,start1)+" seconds");
	}
	start1 = new Date();

	//delta T charts
	var deltaTOptions = {
		      scales: {
		        x: {
		          type: 'linear', // Use linear scale for the x-axis
		          position: 'bottom',
		          suggestedMin: 0, // Set the minimum value to 0
		        },
		        y: {
		          type: 'linear', // Use linear scale for the y-axis
		          position: 'left'
		        }
		      }
		    };	
	var deltaTComments = chartComments;
	var deltaTdatasets = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 0 -'+deltaTComments, // Label for the dataset
		  borderColor: 'orange',
	      backgroundColor: 'orange', // Color or array of colors for the bars
	      data: getDeltaT(0,1), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
		 {
		   label: 'Delta T CAEN 2 - CAEN 0 -'+deltaTComments,
		   borderColor: 'purple',
		   backgroundColor: 'purple', // Color or array of colors for the bars
		   data: getDeltaT(0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		 },		 
		 {
		   label: 'Delta T CAEN 3 - CAEN 0 -'+deltaTComments,
		   borderColor: 'yellow',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getDeltaT(0,3), // Array of numerical values for the bars
		   pointRadius: 3,
		 },
		 {
		   label: 'Delta T CAEN 4 - CAEN 0 -'+deltaTComments,
		   borderColor: 'lightgreen',
		   backgroundColor: 'lightgreen', // Color or array of colors for the bars
		   data: getDeltaT(0,4), // Array of numerical values for the bars
		   pointRadius: 3,
		 },
		 {
		   label: 'Delta T CAEN 5 - CAEN 0 -'+deltaTComments,
		   backgroundColor: 'pink', // Color or array of colors for the bars
		   data: getDeltaT(0,5), // Array of numerical values for the bars
		   pointRadius: 3,
		 },
	 ],
	};	
	var scatterDeltaTChart = new Chart(deltaT, {
		type: 'scatter',
			data: deltaTdatasets,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDTData').addEventListener('click', () => {	
		download2DArray(globalThis.eventTime, 'DTdata.csv');
	});
	
	//single delta T charts
	var dT10 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 0 -'+deltaTComments,
		  borderColor: 'orange',
	      backgroundColor: 'orange', // Color or array of colors for the bars
	      data: getDeltaT(0,1), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var scatterDeltaT10Chart = new Chart(deltaT10, {
		type: 'scatter',
			data: dT10,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDT1-0').addEventListener('click', () => {
	    downloadArray(getDeltaT(0,1), 'DTCAEN1-0data.csv');
	});
	
	var dT20 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 2 - CAEN 0 -'+deltaTComments,
		  borderColor: 'purple',
	      backgroundColor: 'purple', // Color or array of colors for the bars
	      data: getDeltaT(0,2), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var scatterDeltaT20Chart = new Chart(deltaT20, {
		type: 'scatter',
			data: dT20,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDT2-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,2), 'DTCAEN2-0data.csv');
	});
	
	var dT30 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 3 - CAEN 0 -'+deltaTComments,
		  borderColor: 'yellow',
	      backgroundColor: 'yellow', // Color or array of colors for the bars
	      data: getDeltaT(0,3), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var scatterDeltaT30Chart = new Chart(deltaT30, {
		type: 'scatter',
			data: dT30,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDT3-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,3), 'DTCAEN3-0data.csv');
	});

	var dT40 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 4 - CAEN 0 -'+deltaTComments,
		  borderColor: 'lightgreen',
	      backgroundColor: 'lightgreen', // Color or array of colors for the bars
	      data: getDeltaT(0,4), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var scatterDeltaT40Chart = new Chart(deltaT40, {
		type: 'scatter',
			data: dT40,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDT4-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,4), 'DTCAEN4-0data.csv');
	});

	var dT50 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 5 - CAEN 0 -'+deltaTComments,
		  borderColor: 'pink',
	      backgroundColor: 'pink', // Color or array of colors for the bars
	      data: getDeltaT(0,5), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var scatterDeltaT50Chart = new Chart(deltaT50, {
		type: 'scatter',
			data: dT50,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDT5-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,5), 'DTCAEN5-0data.csv');
	});

	var dT42 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 4 - CAEN 2 -'+deltaTComments,
		  borderColor: 'brown',
	      backgroundColor: 'brown', // Color or array of colors for the bars
	      data: getDeltaT(2,4), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var scatterDeltaT42Chart = new Chart(deltaT42, {
		type: 'scatter',
			data: dT42,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDT4-2').addEventListener('click', () => {	
		downloadArray(getDeltaT(2,4), 'DTCAEN2-4data.csv');
	});

	var dT13 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 3 -'+deltaTComments,
		  borderColor: 'blue',
	      backgroundColor: 'blue', // Color or array of colors for the bars
	      data: getDeltaT(3,1), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var scatterDeltaT13Chart = new Chart(deltaT13, {
		type: 'scatter',
			data: dT13,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDT1-3').addEventListener('click', () => {	
		downloadArray(getDeltaT(3,1), 'DTCAEN1-3data.csv');
	});

	var dT15 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 5 -'+deltaTComments,
		  borderColor: 'red',
	      backgroundColor: 'red', // Color or array of colors for the bars
	      data: getDeltaT(5,1), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var scatterDeltaT15Chart = new Chart(deltaT15, {
		type: 'scatter',
			data: dT15,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDT1-5').addEventListener('click', () => {	
		downloadArray(getDeltaT(5,1), 'DTCAEN1-5data.csv');
	});

	var dT35 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 3 - CAEN 5 -'+deltaTComments,
		  borderColor: 'darkgreen',
	      backgroundColor: 'darkgreen', // Color or array of colors for the bars
	      data: getDeltaT(5,3), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var scatterDeltaT35Chart = new Chart(deltaT35, {
		type: 'scatter',
			data: dT35,
			options: deltaTOptions,
	});	
	document.getElementById('downloadDT3-5').addEventListener('click', () => {	
		downloadArray(getDeltaT(5,3), 'DTCAEN3-5data.csv');
	});
	end1 = new Date();
	if (globalThis.showTime) {
		console.log("Delta T : "+calculateProcessTime(end1,start1)+" seconds");
	}
	start1 = new Date();

	//track counts	
	var trackCountOptions = {
		scales: {
		  y: {
		    beginAtZero: true,
		    stepSize: 1,
		    precision: 0,// Set the step size to 1 to show only whole numbers
		  },
		},
	};
	// 4 top middle tracks per minute
	var eventWithTracksCount4TM = getEventsWithTracksPerMinute(4,'TM');
	var eventWithTracksCount4TMComments = chartComments + 'Events: '+ eventWithTracksCount4TM;
	var labels4TM = Object.keys(eventWithTracksCount4TM);
	var values4TM = Object.values(eventWithTracksCount4TM);
	var numberTracks4TM = {
	  labels: labels4TM, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (4) top-middle with tracks (per minute) -'+eventWithTracksCount4TMComments,
	       backgroundColor: 'purple',
	       data: values4TM,
	     },
	  ],
	};		
	var scatterChartTracks4TM = new Chart(tracks4TM, {
	    type: 'bar',
	    data: numberTracks4TM,
	    options: trackCountOptions,
	});
	document.getElementById('downloadTRACKS4TM').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(4,'TM'), 'EVENTSTRACKS4TMMINUTEdata.csv');
	});
	
	// 4 middle bottom tracks per minute
	var eventWithTracksCount4MB = getEventsWithTracksPerMinute(4,'MB');
	var eventWithTracksCount4MBComments = chartComments + 'Events: '+ getTotalChartEvents(eventWithTracksCount4MB);
	var labels4MB = Object.keys(eventWithTracksCount4MB);
	var values4MB = Object.values(eventWithTracksCount4MB);
	var numberTracks4MB = {
	  labels: labels4MB, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (4) middle-bottom with tracks (per minute) -'+eventWithTracksCount4MBComments,
	       backgroundColor: 'green',
	       data: values4MB,
	     },
	  ],
	};			
	var scatterChartTracks4MB = new Chart(tracks4MB, {
	    type: 'bar',
	    data: numberTracks4MB,
		options: trackCountOptions,
	});
	document.getElementById('downloadTRACKS4MB').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(4,'MB'), 'EVENTSTRACKS4MBMINUTEdata.csv');
	});		
	
	// 5 middle tracks per minute
	var eventWithTracksCount5M = getEventsWithTracksPerMinute(5,'M');
	var eventWithTracksCount5MComments = chartComments + 'Events: '+ getTotalChartEvents(eventWithTracksCount5M);
	var labels5M = Object.keys(eventWithTracksCount5M);
	var values5M = Object.values(eventWithTracksCount5M);
	var numberTracks5M = {
	  labels: labels5M, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (5) with tracks (per minute-MIDDLE missing) -'+eventWithTracksCount5MComments,
	       backgroundColor: 'pink',
	       data: values5M,
	     },
	  ],
	};			
	var scatterChartTracks5M = new Chart(tracks5M, {
	    type: 'bar',
	    data: numberTracks5M,
		options: trackCountOptions,
	});
	document.getElementById('downloadTRACKS5M').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(5,'M'), 'EVENTSTRACKS5MINUTEdataM.csv');
	});

	// 5 top bottom tracks per minute
	var eventWithTracksCount5TB = getEventsWithTracksPerMinute(5,'TB');
	var eventWithTracksCount5TBComments = chartComments + 'Events: '+ getTotalChartEvents(eventWithTracksCount5TB);
	var labels5TB = Object.keys(eventWithTracksCount5TB);
	var values5TB = Object.values(eventWithTracksCount5TB);
	var numberTracks5TB = {
	  labels: labels5TB, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (5) with tracks (per minute-TOP or BOTTOM missing) -'+eventWithTracksCount5TBComments,
	       backgroundColor: 'lightblue',
	       data: values5TB,
	     },
	  ],
	};			
	var scatterChartTracks5TB = new Chart(tracks5TB, {
	    type: 'bar',
	    data: numberTracks5TB,
		options: trackCountOptions,
	});
	document.getElementById('downloadTRACKS5TB').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(5,'TB'), 'EVENTSTRACKS5MINUTEdataTB.csv');
	});
		
	// 6 track count per minute		
	var eventWithTracksCount6 = getEventsWithTracksPerMinute(6,'');
	var eventWithTracksCount6Comments = chartComments + 'Events: '+ getTotalChartEvents(eventWithTracksCount6);
	var labels6 = Object.keys(eventWithTracksCount6);
	var values6 = Object.values(eventWithTracksCount6);
	var numberTracks6 = {
	  labels: labels6, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (6) with tracks (per minute) -'+eventWithTracksCount6Comments,
	       backgroundColor: 'orange',
	       data: values6,
	     },
	  ],
	};	
	var scatterChartTracks6 = new Chart(tracks6, {
	    type: 'bar',
	    data: numberTracks6,
		options: trackCountOptions,
	});
	document.getElementById('downloadTRACKS6').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(6,''), 'EVENTSTRACKS6MINUTEdata.csv');
	});

	end1 = new Date();
	if (globalThis.showTime) {
		console.log("Track counts : "+calculateProcessTime(end1,start1)+" seconds");
	}
	start1 = new Date();

	//ADC charts
	var xADRLabels = [];
	for(var i = 1; i <= xLayerLength; i++){
	    xADRLabels.push('Channel ' + (i-1).toString() + " & " + i.toString());
	}
	  
	var yADRLabels = [];
	for(var i = 1; i <= yLayerLength; i++){
	    yADRLabels.push('Channel ' + (i-1).toString() + " & " + i.toString());
	}
	
	var adcOptionsX = {
		scales: {
		  x: {
		    type: 'linear', // Use linear scale for the x-axis
		    position: 'bottom',
		    suggestedMin: 0, // Set the minimum value to 0
		    max: xLayerLength,
		    ticks: {
		      stepSize: 1, // Display ticks at every 1 unit interval
		      callback: function(value, index) {
		   	   // Use xADRLabels to display custom labels for each data point
		      	return xADRLabels[index];
		      }
		  }
		  },
		  y: {
		    type: 'linear', // Use linear scale for the y-axis
		    position: 'left'
		  }
		}		
	};			
	//ADCX1				
	var scatterChartADCX1 = new Chart(X1ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'X CAEN 0 Paired ADC -'+chartComments,
            data: popXADR(0),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 3, // Size of the data points
          }]
        },
        options: adcOptionsX,
	});
	document.getElementById('downloadXCAEN0ADC').addEventListener('click', () => {
	    downloadXYdata(popXADR(0), 'XCAEN0ADCdata.csv');
	});

	//ADCX1 average					
	var scatterChartADCX1Average = new Chart(X1ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'X CAEN 0 Paired ADC-Average -'+chartComments,
	        data: popXADRAverage(0),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 3, // Size of the data points
	      }]
	    },
		options: adcOptionsX,
	});
	
	//ADCX2				
	var scatterChartADCX2 = new Chart(X2ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'X CAEN 2 Paired ADC -'+chartComments,
            data: popXADR(1),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 3, // Size of the data points
          }]
        },
		options: adcOptionsX,
	});
	document.getElementById('downloadXCAEN2ADC').addEventListener('click', () => {
	    downloadXYdata(popXADR(1), 'XCAEN2ADCdata.csv');
	});

	//ADCX2 average									
	var scatterChartADCX2Average = new Chart(X2ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'X Layer 2 Paired ADC-Average -'+chartComments,
	        data: popXADRAverage(1),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 3, // Size of the data points
	      }]
	    },
		options: adcOptionsX,
	});
	
	//ADCX3
	var scatterChartADCX3 = new Chart(X3ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'X CAEN 4 Paired ADC -'+chartComments,
            data: popXADR(2),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 3, // Size of the data points
          }]
        },
		options: adcOptionsX,
	});
	document.getElementById('downloadXCAEN4ADC').addEventListener('click', () => {
	    downloadXYdata(popXADR(2), 'XCAEN4ADCdata.csv');
	});
		
	//ADCX3 average			
	var scatterChartADCX3Average = new Chart(X3ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'X CAEN 4 Paired ADC-Average -'+chartComments,
	        data: popXADRAverage(2),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 3, // Size of the data points
	      }]
	    },
		options: adcOptionsX,
	});

	//ADCY
	var adcOptionsY = {
		scales: {
		  x: {
		    type: 'linear', // Use linear scale for the x-axis
		    position: 'bottom',
		    suggestedMin: 0, // Set the minimum value to 0
		    max: yLayerLength,
		    ticks: {
		      stepSize: 1, // Display ticks at every 1 unit interval
		      callback: function(value, index) {
		          // Use xADRLabels to display custom labels for each data point
		          return yADRLabels[index];
		      }
		    }
		  },
		  y: {
		    type: 'linear', // Use linear scale for the y-axis
		    position: 'left'
		  }
		}		
	};

	//ADCY1
	var scatterChartADCY1 = new Chart(Y1ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'Y CAEN 1 Paired ADC -'+chartComments,
            data: popYADR(0),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 3, // Size of the data points
          }]
        },
        options: adcOptionsY,
	});
	document.getElementById('downloadYCAEN1ADC').addEventListener('click', () => {
	    downloadXYdata(popYADR(0), 'YCAEN1ADCdata.csv');
	});
	
	//ADCY1 average					
	var scatterChartADCY1Average = new Chart(Y1ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'Y CAEN 1 Paired ADC-Average -'+chartComments,
	        data: popYADRAverage(0),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 3, // Size of the data points
	      }]
	    },
		options: adcOptionsY,
	});

	//ADCY2	
	var scatterChartADCY2 = new Chart(Y2ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'Y CAEN 3 Paired ADC -'+chartComments,
            data: popYADR(1),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 3, // Size of the data points
          }]
        },
		options: adcOptionsY,
	});
	document.getElementById('downloadYCAEN3ADC').addEventListener('click', () => {
	    downloadXYdata(popYADR(1), 'YCAEN3ADCdata.csv');
	});
		
	//ADCY2 average
	var scatterChartADCY2Average = new Chart(Y2ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'Y CAEN 3 Paired ADC-Average -'+chartComments,
	        data: popYADRAverage(1),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 3, // Size of the data points
	      }]
	    },
		options: adcOptionsY,
	});

	//ADCY3
	var scatterChartADCY3 = new Chart(Y3ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'Y CAEN 5 Paired ADC -'+chartComments,
            data: popYADR(2),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 3, // Size of the data points
          }]
        },
		options: adcOptionsY,
	});
	document.getElementById('downloadYCAEN5ADC').addEventListener('click', () => {
	    downloadXYdata(popYADR(2), 'YCAEN5ADCdata.csv');
	});

	//ADCY3 average
	var scatterChartADCY3Average = new Chart(Y3ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'Y CAEN 5 Paired ADC-Average -'+chartComments,
	        data: popYADRAverage(2),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 3, // Size of the data points
	      }]
	    },
		options: adcOptionsY,
	});
	end1 = new Date();
	if (globalThis.showTime) {
		console.log("ADCs : "+calculateProcessTime(end1,start1)+" seconds");
	}
};//end of drawAnalysis
