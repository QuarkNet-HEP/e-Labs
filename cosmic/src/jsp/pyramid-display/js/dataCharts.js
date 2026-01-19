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

function drawCharts(g) { 
	// Cache DOM lookups to avoid repeated document.getElementById calls
	const _elCache = new Map();
	function getEl(id) {
		if (!_elCache.has(id)) _elCache.set(id, document.getElementById(id));
		return _elCache.get(id);
	}
	function getCtx(id) {
		const el = getEl(id);
		return el ? el.getContext('2d') : null;
	}
	removeCharts(); // Clear existing charts before drawing new ones
	var ctx1 = getCtx('X1');
	var ctx2 = getCtx('X2');
	var ctx3 = getCtx('X3');
	var cty1 = getCtx('Y1');
	var cty2 = getCtx('Y2');
	var cty3 = getCtx('Y3');
	var PTXYMIDDLE6 = getCtx('6PTXYMIDDLE');
	var PTXYMIDDLEX6 = getCtx('6PTXYMIDDLEX');
	var PTXYMIDDLEY6 = getCtx('6PTXYMIDDLEY');
	var PTXYMIDDLEXY6 = getCtx('6PTXYMIDDLEXY');
	var PDIFFMXHITS6 = getCtx('6PDIFFMXHITS');
	var PDIFFMYHITS6 = getCtx('6PDIFFMYHITS');
	var DXDYHITS6 = getCtx('6DXDYHITS');
	//var LEGO = getCtx('LEGO');
	var PTMX6 = getCtx('6PTMX');
	var PTMY6 = getCtx('6PTMY');
	var PTMXY6 = getCtx('6PTMXY');
	var PDIFFMX6 = getCtx('6PDIFFMX');
	var PDIFFMY6 = getCtx('6PDIFFMY');
	var PTTX5 = getCtx('5PTTX');
	var PTMX5 = getCtx('5PTMX');
	var PTBX5 = getCtx('5PTBX');
	var PTTY5 = getCtx('5PTTY');
	var PTMY5 = getCtx('5PTMY');
	var PTBY5 = getCtx('5PTBY');
	var PTT4 = getCtx('4PTT');
	var PTM4 = getCtx('4PTM');
	var PTB4 = getCtx('4PTB');
	var dxdy = getCtx('DXDY');
	var dx1d = getCtx('DX1D');
	var dy1d = getCtx('DY1D');
	var dxT1d = getCtx('DXT1D');
	var dxM1d = getCtx('DXM1D');
	var dxB1d = getCtx('DXB1D');
	var dyT1d = getCtx('DYT1D');
	var dyM1d = getCtx('DYM1D');
	var dyB1d = getCtx('DYB1D');
	var dxdzdydz = getCtx('DXDZDYDZ');
	var dxdzdydzTM = getCtx('DXDZDYDZTM');
	var dxdzdydzMB = getCtx('DXDZDYDZMB');
	var tracks4TM = getCtx('#TRACKS4TM');
	var tracks4MB = getCtx('#TRACKS4MB');
	var tracks5M = getCtx('#TRACKS5M');
	var tracks5TB = getCtx('#TRACKS5TB');
	var tracks6 = getCtx('#TRACKS6');
	var deltaT = getCtx('DT');
	var deltaT10 = getCtx('DT10');
	var deltaT20 = getCtx('DT20');
	var deltaT30 = getCtx('DT30');
	var deltaT40 = getCtx('DT40');
	var deltaT50 = getCtx('DT50');
	var deltaT42 = getCtx('DT42');
	var deltaT13 = getCtx('DT13');
	var deltaT15 = getCtx('DT15');
	var deltaT35 = getCtx('DT35');
	var X1ADC = getCtx('X1ADC');
	var X2ADC = getCtx('X2ADC');
	var X3ADC = getCtx('X3ADC');
	var Y1ADC = getCtx('Y1ADC');
	var Y2ADC = getCtx('Y2ADC');
	var Y3ADC = getCtx('Y3ADC');
	var X1ADCAverage = getCtx('X1ADCAverage');
	var X2ADCAverage = getCtx('X2ADCAverage');
	var X3ADCAverage = getCtx('X3ADCAverage');
	var Y1ADCAverage = getCtx('Y1ADCAverage');
	var Y2ADCAverage = getCtx('Y2ADCAverage');
	var Y3ADCAverage = getCtx('Y3ADCAverage');

	xLayerLength = (globalThis.layers[4].length - 2) * 4;
	yLayerLength = (globalThis.layers[5].length - 2) * 4;
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
	
	var chartComments = "Run: "+globalThis.runNumber+' '+globalThis.conversionComments+' ('+globalThis.totalEvents+' events)';
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
	// Precompute CAEN arrays once and reuse to avoid repeated computation
	const xCAEN0 = populateX('x', 0);
	const xCAEN2 = populateX('x', 1);
	const xCAEN4 = populateX('x', 2);
	const yCAEN1 = populateY('y', 0);
	const yCAEN3 = populateY('y', 1);
	const yCAEN5 = populateY('y', 2);
	const xCAEN0Original = getCAENdata(subtractPedX, 0);
	const xCAEN2Original = getCAENdata(subtractPedX, 1);
	const xCAEN4Original = getCAENdata(subtractPedX, 2);
	const yCAEN1Original = getCAENdata(subtractPedY, 0);
	const yCAEN3Original = getCAENdata(subtractPedY, 1);
	const yCAEN5Original = getCAENdata(subtractPedY, 2);

	//X CAEN 0
	var dataX1 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'X CAEN 0 -'+chartComments, // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: xCAEN0, // Reuse precomputed data
	    },
	  ],
	};
	var barChartX1 = new Chart(ctx1, {
    	type: 'bar',
    	data: dataX1,
    	options: CAENOptions,
	});
	const downloadXCAEN0 = getEl('downloadXCAEN0');
	if (downloadXCAEN0) downloadXCAEN0.addEventListener('click', () => {
	    downloadArray(xCAEN0, 'XCAEN0data.csv');
	});
	const downloadXCAEN0data = getEl('downloadXCAEN0data');
	if (downloadXCAEN0data) downloadXCAEN0data.addEventListener('click', () => {
	    download2DArray(xCAEN0Original, 'XCAEN0originaldata.csv');
	});
	
	//X CAEN 2
	var dataX2 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'X CAEN 2 -'+chartComments,
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: xCAEN2,
	     },
	  ],
	};
	var barChartX2 = new Chart(ctx2, {
	    type: 'bar',
	    data: dataX2,
	    options: CAENOptions,
	});
	const downloadXCAEN2 = getEl('downloadXCAEN2');
	if (downloadXCAEN2) downloadXCAEN2.addEventListener('click', () => {
	    downloadArray(xCAEN2, 'XCAEN2data.csv');
	});
	const downloadXCAEN2data = getEl('downloadXCAEN2data');
	if (downloadXCAEN2data) downloadXCAEN2data.addEventListener('click', () => {
	    download2DArray(xCAEN2Original, 'XCAEN2originaldata.csv');
	});

	//X CAEN 3
	var dataX3 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
		{
	      label: 'X CAEN 4 -'+chartComments,
	       backgroundColor: 'rgba(20, 255, 132, 0.5)',
	       data: xCAEN4,
	     },
	  ],
	};
	var barChartX3 = new Chart(ctx3, {
	    type: 'bar',
	    data: dataX3,
	    options: CAENOptions,
	});  
	const downloadXCAEN4 = getEl('downloadXCAEN4');
	if (downloadXCAEN4) downloadXCAEN4.addEventListener('click', () => {
	    downloadArray(xCAEN4, 'XCAEN4data.csv');
	});
	const downloadXCAEN4data = getEl('downloadXCAEN4data');
	if (downloadXCAEN4data) downloadXCAEN4data.addEventListener('click', () => {
	    download2DArray(xCAEN4Original, 'XCAEN4originaldata.csv');
	});

	//Y CAEN 1
	var dataY1 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y CAEN 1 -'+chartComments, // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: yCAEN1, // Reuse precomputed data
	    },
	  ],
	};
	var barChartY1 = new Chart(cty1, {
	    type: 'bar',
	    data: dataY1,
	    options: CAENOptions,
	});
	const downloadYCAEN1 = getEl('downloadYCAEN1');
	if (downloadYCAEN1) downloadYCAEN1.addEventListener('click', () => {
	    downloadArray(yCAEN1, 'YCAEN1data.csv');
	});
	const downloadYCAEN1data = getEl('downloadYCAEN1data');
	if (downloadYCAEN1data) downloadYCAEN1data.addEventListener('click', () => {
	    download2DArray(yCAEN1Original, 'YCAEN1originaldata.csv');
	});

	//Y CAEN 3
	var dataY2 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y CAEN 3 -'+chartComments,
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: yCAEN3,
	     },
	  ],
	};
	var barChartY2 = new Chart(cty2, {
	    type: 'bar',
	    data: dataY2,
	    options: CAENOptions,
	});
	const downloadYCAEN3 = getEl('downloadYCAEN3');
	if (downloadYCAEN3) downloadYCAEN3.addEventListener('click', () => {
	    downloadArray(yCAEN3, 'YCAEN3data.csv');
	});
	const downloadYCAEN3data = getEl('downloadYCAEN3data');
	if (downloadYCAEN3data) downloadYCAEN3data.addEventListener('click', () => {
	    download2DArray(yCAEN3Original, 'YCAEN3originaldata.csv');
	});

	//Y CAEN 5
	var dataY3 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Y CAEN 5 -'+chartComments,
	       backgroundColor: 'rgba(20, 255, 132, 0.5)',
	       data: yCAEN5,
	          options: options,
	     },
	  ],
	};
	var barChartY3 = new Chart(cty3, {
	    type: 'bar',
	    data: dataY3,
	    options: CAENOptions,
	});
	const downloadYCAEN5 = getEl('downloadYCAEN5');
	if (downloadYCAEN5) downloadYCAEN5.addEventListener('click', () => {
	    downloadArray(yCAEN5, 'YCAEN5data.csv');
	});
	const downloadYCAEN5data = getEl('downloadYCAEN5data');
	if (downloadYCAEN5data) downloadYCAEN5data.addEventListener('click', () => {
	    download2DArray(yCAEN5Original, 'YCAEN5originaldata.csv');
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
	getEl('download6PTMHdata').addEventListener('click', () => {
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
	getEl('download6PTMHXdata').addEventListener('click', () => {
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
	getEl('download6PTMHYdata').addEventListener('click', () => {
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
	getEl('download6PDIFFMXHITSdata').addEventListener('click', () => {
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
	getEl('download6PDIFFMYHITSdata').addEventListener('click', () => {
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
	getEl('download6DXHITSDY').addEventListener('click', () => {
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
	  // Add custom shapes, e.g., a vertical line at mean of X
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
	getEl('download6PTMXdata').addEventListener('click', () => {
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
	getEl('download6PTMYdata').addEventListener('click', () => {
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
	getEl('download6PTMXYdata').addEventListener('click', () => {
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
	getEl('download6PDIFFMXdata').addEventListener('click', () => {
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
	getEl('download6PDIFFMYdata').addEventListener('click', () => {
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
	getEl('download5PTTXdata').addEventListener('click', () => {
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
	getEl('download5PTMXdata').addEventListener('click', () => {
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
	getEl('download5PTBXdata').addEventListener('click', () => {
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
	getEl('download5PTTYdata').addEventListener('click', () => {
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
	getEl('download5PTMYdata').addEventListener('click', () => {
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
	getEl('download5PTBYdata').addEventListener('click', () => {
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
	getEl('download4PTdata').addEventListener('click', () => {
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
	getEl('download4PMdata').addEventListener('click', () => {
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
	getEl('download4PBdata').addEventListener('click', () => {
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
	getEl('downloadDXDY').addEventListener('click', () => {
	    downloadXYdata(getDxDy(0), 'DXDYdata.csv');
	});
	getEl('downloadDXdata').addEventListener('click', () => {
	    download2DArray(dxbothlayers, 'DXoriginaldata.csv');
	});
	getEl('downloadDYdata').addEventListener('click', () => {
	    download2DArray(dybothlayers, 'DYoriginaldata.csv');
	});
	getEl('downloadDXDYTOPMIDDLE').addEventListener('click', () => {
	    downloadXYdata(getDxDyMiddle(dxtopmiddlebothlayers, dytopmiddlebothlayers, 0), 'DXDYTOPMIDDLEdata.csv');
	});
	getEl('downloadDXTMdata').addEventListener('click', () => {
	    download2DArray(dxtopmiddlebothlayers, 'DXTMoriginaldata.csv');
	});
	getEl('downloadDYTMdata').addEventListener('click', () => {
	    download2DArray(dytopmiddlebothlayers, 'DYTMoriginaldata.csv');
	});
	getEl('downloadDXDYBOTTOMMIDDLE').addEventListener('click', () => {
	    downloadXYdata(getDxDyMiddle(dxbottommiddlebothlayers, dybottommiddlebothlayers, 0), 'DXDYBOTTOMMIDDLEdata.csv');
	});
	getEl('downloadDXBMdata').addEventListener('click', () => {
	    download2DArray(dxbottommiddlebothlayers, 'DXBMoriginaldata.csv');
	});
	getEl('downloadDYBMdata').addEventListener('click', () => {
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
	getEl('downloadDX1D').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dxbothlayers,0,2), 'DX1Ddata.csv');
	});
	getEl('downloadDX1Ddata').addEventListener('click', () => {
	    download2DArray(dxbothlayers, 'DX1Doriginaldata.csv');
	});
	getEl('downloadDX1DTOPMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dxtopmiddlebothlayers,0,2), 'DX1DTOPMIDDLEdata.csv');
	});
	getEl('downloadDX1DTOPMIDDLEdata').addEventListener('click', () => {
	    download2DArray(dxtopmiddlebothlayers, 'DX1DTOPMIDDLEoriginaldata.csv');
	});
	getEl('downloadDX1DBOTTOMMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dxbottommiddlebothlayers,0,2), 'DX1DBOTTOMMIDDLEdata.csv');
	});
	getEl('downloadDX1DBOTTOMMIDDLEdata').addEventListener('click', () => {
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
	getEl('downloadDY1D').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dybothlayers,0,2), 'DY1Ddata.csv');
	});
	getEl('downloadDY1Ddata').addEventListener('click', () => {
	    download2DArray(dybothlayers, 'DY1Doriginaldata.csv');
	});
	getEl('downloadDY1DTOPMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dytopmiddlebothlayers,0,2), 'DY1DTOPMIDDLEdata.csv');
	});
	getEl('downloadDY1DTOPMIDDLEdata').addEventListener('click', () => {
	    download2DArray(dytopmiddlebothlayers, 'DY1DTOPMIDDLEoriginaldata.csv');
	});
	getEl('downloadDY1DBOTTOMMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dybottommiddlebothlayers,0,2), 'DY1DBOTTOMMIDDLEdata.csv');
	});
	getEl('downloadDY1DBOTTOMMIDDLEdata').addEventListener('click', () => {
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
	getEl('downloadDXT1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxtopChannelfrequency), 'DXT1Ddata.csv');
	});
	getEl('downloadDXT1Ddata').addEventListener('click', () => {
	    downloadArray(dxtopChannelfrequency, 'DXT1Dchanneldata.csv');
	});
	getEl('downloadDXTM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxtopmiddleChannelfrequency), 'DXTM1Ddata.csv');
	});
	getEl('downloadDXTM1Ddata').addEventListener('click', () => {
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
	getEl('downloadDXM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxmiddleChannelfrequency), 'DXM1Ddata.csv');
	});
	getEl('downloadDXM1Ddata').addEventListener('click', () => {
	    downloadArray(dxmiddleChannelfrequency, 'DXM1Dchanneldata.csv');
	});
	getEl('downloadDXM1DT').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxmiddleChannelfrequencyT), 'DXM1DTdata.csv');
	});
	getEl('downloadDXM1DTdata').addEventListener('click', () => {
	    downloadArray(dxmiddleChannelfrequencyT, 'DXM1DTchanneldata.csv');
	});
	getEl('downloadDXM1DB').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxmiddleChannelfrequencyB), 'DXM1DBdata.csv');
	});
	getEl('downloadDXM1DBdata').addEventListener('click', () => {
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
	getEl('downloadDXB1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxbottomChannelfrequency), 'DXB1Ddata.csv');
	});
	getEl('downloadDXB1Ddata').addEventListener('click', () => {
	    downloadArray(dxbottomChannelfrequency, 'DXB1Dchanneldata.csv');
	});
	getEl('downloadDXBM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxbottomMiddleChannelfrequency), 'DXBM1Ddata.csv');
	});
	getEl('downloadDXBM1Ddata').addEventListener('click', () => {
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
	getEl('downloadDYT1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dytopChannelfrequency), 'DYT1Ddata.csv');
	});
	getEl('downloadDYT1Ddata').addEventListener('click', () => {
	    downloadArray(dytopChannelfrequency, 'DYT1Dchanneldata.csv');
	});
	getEl('downloadDYTM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dytopMiddleChannelfrequency), 'DYTM1Ddata.csv');
	});
	getEl('downloadDYTM1Ddata').addEventListener('click', () => {
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
	getEl('downloadDYM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dymiddleChannelfrequency), 'DYM1Ddata.csv');
	});
	getEl('downloadDYM1Ddata').addEventListener('click', () => {
	    downloadArray(dymiddleChannelfrequency, 'DYM1Dchanneldata.csv');
	});
	getEl('downloadDYM1DT').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dymiddleChannelfrequencyT), 'DYM1DTdata.csv');
	});
	getEl('downloadDYM1DTdata').addEventListener('click', () => {
	    downloadArray(dymiddleChannelfrequencyT, 'DYM1DTchanneldata.csv');
	});
	getEl('downloadDYM1DB').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dymiddleChannelfrequencyB), 'DYM1DBdata.csv');
	});
	getEl('downloadDYM1DBdata').addEventListener('click', () => {
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
	getEl('downloadDYB1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dybottomChannelfrequency), 'DYB1Ddata.csv');
	});
	getEl('downloadDYB1Ddata').addEventListener('click', () => {
	    downloadArray(dybottomChannelfrequency, 'DYB1Dchanneldata.csv');
	});
	getEl('downloadDYBM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dybottomMiddleChannelfrequency), 'DYBM1Ddata.csv');
	});
	getEl('downloadDYBM1Ddata').addEventListener('click', () => {
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
	getEl('downloadDXDZDYDZ').addEventListener('click', () => {
	    downloadXYdata(getDxDz(0), 'DXDZDYDZdata.csv');
	});
	getEl('downloadDXDZDYDZXdata').addEventListener('click', () => {
	    download2DArray(dxbothlayers, 'DXDZDYDZXdata.csv');
	});
	getEl('downloadDXDZDYDZYdata').addEventListener('click', () => {
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
	getEl('downloadDXDZDYDZTM').addEventListener('click', () => {
	    downloadXYdata(getDxyDzMiddle(dxtopmiddlebothlayers,dytopmiddlebothlayers, 0), 'DXDZDYDZTMdata.csv');
	});
	getEl('downloadDXDZDYDZTMXdata').addEventListener('click', () => {
	    download2DArray(dxtopmiddlebothlayers, 'DXDZDYDZTMXdata.csv');
	});
	getEl('downloadDXDZDYDZTMYdata').addEventListener('click', () => {
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
	getEl('downloadDXDZDYDZMB').addEventListener('click', () => {
	    downloadXYdata(getDxyDzMiddle(dxbottommiddlebothlayers,dybottommiddlebothlayers, 0), 'DXDZDYDZMBdata.csv');
	});
	getEl('downloadDXDZDYDZMBXdata').addEventListener('click', () => {
	    download2DArray(dxbottommiddlebothlayers, 'DXDZDYDZMBXdata.csv');
	});
	getEl('downloadDXDZDYDZMBYdata').addEventListener('click', () => {
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
	getEl('downloadDTData').addEventListener('click', () => {	
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
	getEl('downloadDT1-0').addEventListener('click', () => {
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
	getEl('downloadDT2-0').addEventListener('click', () => {	
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
	getEl('downloadDT3-0').addEventListener('click', () => {	
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
	getEl('downloadDT4-0').addEventListener('click', () => {	
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
	getEl('downloadDT5-0').addEventListener('click', () => {	
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
	getEl('downloadDT4-2').addEventListener('click', () => {	
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
	getEl('downloadDT1-3').addEventListener('click', () => {	
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
	getEl('downloadDT1-5').addEventListener('click', () => {	
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
	getEl('downloadDT3-5').addEventListener('click', () => {	
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
	getEl('downloadTRACKS4TM').addEventListener('click', () => {
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
	getEl('downloadTRACKS4MB').addEventListener('click', () => {
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
	getEl('downloadTRACKS5M').addEventListener('click', () => {
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
	getEl('downloadTRACKS5TB').addEventListener('click', () => {
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
	getEl('downloadTRACKS6').addEventListener('click', () => {
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
	getEl('downloadXCAEN0ADC').addEventListener('click', () => {
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
	getEl('downloadXCAEN2ADC').addEventListener('click', () => {
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
	getEl('downloadXCAEN4ADC').addEventListener('click', () => {
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
	getEl('downloadYCAEN1ADC').addEventListener('click', () => {
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
	getEl('downloadYCAEN3ADC').addEventListener('click', () => {
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
	getEl('downloadYCAEN5ADC').addEventListener('click', () => {
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
