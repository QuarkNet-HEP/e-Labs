function NewremoveCharts() {
	canvasIDs = ['NewX1','NewX2','NewX3','NewY1','NewY2','NewY3',
		'NewDT','NewDT10','NewDT20','NewDT30','NewDT40','NewDT50','NewDT42','NewDT13','NewDT15','NewDT35',

	];
	for (var i = 0; i < canvasIDs.length; i++) {
		let chartStatus = Chart.getChart(canvasIDs[i]); // <canvas> id
		if (chartStatus != undefined) {
	  		chartStatus.destroy();
	  	}
	}
}

function NewdrawAnalysis(l,g) {	
	NewremoveCharts();
	var Newctx1 = document.getElementById('NewX1').getContext('2d');
	var Newctx2 = document.getElementById('NewX2').getContext('2d');
	var Newctx3 = document.getElementById('NewX3').getContext('2d');
	var Newcty1 = document.getElementById('NewY1').getContext('2d');
	var Newcty2 = document.getElementById('NewY2').getContext('2d');
	var Newcty3 = document.getElementById('NewY3').getContext('2d');
	var NewdeltaT = document.getElementById('NewDT').getContext('2d');
	var NewdeltaT10 = document.getElementById('NewDT10').getContext('2d');
	var NewdeltaT20 = document.getElementById('NewDT20').getContext('2d');
	var NewdeltaT30 = document.getElementById('NewDT30').getContext('2d');
	var NewdeltaT40 = document.getElementById('NewDT40').getContext('2d');
	var NewdeltaT50 = document.getElementById('NewDT50').getContext('2d');
	var NewdeltaT42 = document.getElementById('NewDT42').getContext('2d');
	var NewdeltaT13 = document.getElementById('NewDT13').getContext('2d');
	var NewdeltaT15 = document.getElementById('NewDT15').getContext('2d');
	var NewdeltaT35 = document.getElementById('NewDT35').getContext('2d');

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
	
	var xADRLabels = [];
	for(var i = 1; i <= xLayerLength; i++){
	    xADRLabels.push('Channel ' + (i-1).toString() + " & " + i.toString());
	}
	  
	var yADRLabels = [];
	for(var i = 1; i <= yLayerLength; i++){
	    yADRLabels.push('Channel ' + (i-1).toString() + " & " + i.toString());
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

	var CAENOptions = {
		scales: {
		y: {
		 		beginAtZero: true,
		 		stepSize: 1,
		 		precision: 0,// Set the step size to 1 to show only whole numbers
			},
		},		
	};
	
	var NewdataX1 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'X CAEN 0 -'+chartComments, // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: populateX('x', 0), // Array of numerical values for the bars
	    },
	  ],
	};
	
	var NewbarChartX1 = new Chart(Newctx1, {
    	type: 'bar',
    	data: NewdataX1,
    	options: CAENOptions,
	});

	document.getElementById('NewdownloadXCAEN0').addEventListener('click', () => {
	    downloadArray(populateX('x', 0), 'XCAEN0data.csv');
	});
	document.getElementById('NewdownloadXCAEN0data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedX, 0), 'XCAEN0originaldata.csv');
	});
	
	var NewdataX2 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'X CAEN 2 -'+chartComments,
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: populateX('x', 1),
	     },
	  ],
	};

	var NewbarChartX2 = new Chart(Newctx2, {
	    type: 'bar',
	    data: NewdataX2,
	    options: CAENOptions,
	});

	document.getElementById('NewdownloadXCAEN2').addEventListener('click', () => {
	    downloadArray(populateX('x', 1), 'XCAEN2data.csv');
	});
	document.getElementById('NewdownloadXCAEN2data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedX, 1), 'XCAEN2originaldata.csv');
	});

	var NewdataX3 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
		{
	      label: 'X CAEN 4 -'+chartComments,
	       backgroundColor: 'rgba(20, 255, 132, 0.5)',
	       data: populateX('x', 2),
	     },
	  ],
	};
		
	var NewbarChartX3 = new Chart(Newctx3, {
	    type: 'bar',
	    data: NewdataX3,
	    options: CAENOptions,
	});  

	document.getElementById('NewdownloadXCAEN4').addEventListener('click', () => {
	    downloadArray(populateX('x', 2), 'XCAEN4data.csv');
	});
	document.getElementById('NewdownloadXCAEN4data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedX, 2), 'XCAEN4originaldata.csv');
	});
	
	//Y CAEN 1
	var NewdataY1 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y CAEN 1 -'+chartComments, // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: populateY('y', 0), // Array of numerical values for the bars
	    },
	  ],
	};
	var NewbarChartY1 = new Chart(Newcty1, {
	    type: 'bar',
	    data: NewdataY1,
	    options: CAENOptions,
	});
	document.getElementById('NewdownloadYCAEN1').addEventListener('click', () => {
	    downloadArray(populateY('y', 0), 'YCAEN1data.csv');
	});
	document.getElementById('NewdownloadYCAEN1data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedY, 0), 'YCAEN1originaldata.csv');
	});

	//Y CAEN 3
	var NewdataY2 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y CAEN 3 -'+chartComments,
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: populateY('y', 1),
	     },
	  ],
	};	
	var NewbarChartY2 = new Chart(Newcty2, {
	    type: 'bar',
	    data: NewdataY2,
	    options: CAENOptions,
	});
	document.getElementById('NewdownloadYCAEN3').addEventListener('click', () => {
	    downloadArray(populateY('y', 1), 'YCAEN3data.csv');
	});
	document.getElementById('NewdownloadYCAEN3data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedY, 1), 'YCAEN3originaldata.csv');
	});

	//Y CAEN 5
	var NewdataY3 = {
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
	var barChartY3 = new Chart(Newcty3, {
	    type: 'bar',
	    data: NewdataY3,
	    options: CAENOptions,
	});
	document.getElementById('NewdownloadYCAEN5').addEventListener('click', () => {
	    downloadArray(populateY('y', 2), 'YCAEN5data.csv');
	});
	document.getElementById('NewdownloadYCAEN5data').addEventListener('click', () => {
	    download2DArray(getCAENdata(subtractPedY, 2), 'YCAEN5originaldata.csv');
	});

	//delta T charts
	var NewdeltaTOptions = {
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
	var NewdeltaTComments = chartComments;
	var NewdeltaTdatasets = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 0 -'+NewdeltaTComments, // Label for the dataset
		  borderColor: 'orange',
	      backgroundColor: 'orange', // Color or array of colors for the bars
	      data: getDeltaT(0,1), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
		 {
		   label: 'Delta T CAEN 2 - CAEN 0 -'+NewdeltaTComments,
		   borderColor: 'purple',
		   backgroundColor: 'purple', // Color or array of colors for the bars
		   data: getDeltaT(0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		 },		 
		 {
		   label: 'Delta T CAEN 3 - CAEN 0 -'+NewdeltaTComments,
		   borderColor: 'yellow',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getDeltaT(0,3), // Array of numerical values for the bars
		   pointRadius: 3,
		 },
		 {
		   label: 'Delta T CAEN 4 - CAEN 0 -'+NewdeltaTComments,
		   borderColor: 'lightgreen',
		   backgroundColor: 'lightgreen', // Color or array of colors for the bars
		   data: getDeltaT(0,4), // Array of numerical values for the bars
		   pointRadius: 3,
		 },
		 {
		   label: 'Delta T CAEN 5 - CAEN 0 -'+NewdeltaTComments,
		   backgroundColor: 'pink', // Color or array of colors for the bars
		   data: getDeltaT(0,5), // Array of numerical values for the bars
		   pointRadius: 3,
		 },
	 ],
	};	
	var NewscatterDeltaTChart = new Chart(NewdeltaT, {
		type: 'scatter',
			data: NewdeltaTdatasets,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDTData').addEventListener('click', () => {	
		download2DArray(eventTime, 'DTdata.csv');
	});

	//single delta T charts
	var NewdT10 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 0 -'+NewdeltaTComments,
		  borderColor: 'orange',
	      backgroundColor: 'orange', // Color or array of colors for the bars
	      data: getDeltaT(0,1), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var NewscatterDeltaT10Chart = new Chart(NewdeltaT10, {
		type: 'scatter',
			data: NewdT10,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDT1-0').addEventListener('click', () => {
	    downloadArray(getDeltaT(0,1), 'DTCAEN1-0data.csv');
	});

	var NewdT20 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 2 - CAEN 0 -'+NewdeltaTComments,
		  borderColor: 'purple',
	      backgroundColor: 'purple', // Color or array of colors for the bars
	      data: getDeltaT(0,2), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var NewscatterDeltaT20Chart = new Chart(NewdeltaT20, {
		type: 'scatter',
			data: NewdT20,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDT2-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,2), 'DTCAEN2-0data.csv');
	});

	var NewdT30 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 3 - CAEN 0 -'+NewdeltaTComments,
		  borderColor: 'yellow',
	      backgroundColor: 'yellow', // Color or array of colors for the bars
	      data: getDeltaT(0,3), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var NewscatterDeltaT30Chart = new Chart(NewdeltaT30, {
		type: 'scatter',
			data: NewdT30,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDT3-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,3), 'DTCAEN3-0data.csv');
	});

	var NewdT40 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 4 - CAEN 0 -'+NewdeltaTComments,
		  borderColor: 'lightgreen',
	      backgroundColor: 'lightgreen', // Color or array of colors for the bars
	      data: getDeltaT(0,4), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var NewscatterDeltaT40Chart = new Chart(NewdeltaT40, {
		type: 'scatter',
			data: NewdT40,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDT4-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,4), 'DTCAEN4-0data.csv');
	});

	var NewdT50 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 5 - CAEN 0 -'+NewdeltaTComments,
		  borderColor: 'pink',
	      backgroundColor: 'pink', // Color or array of colors for the bars
	      data: getDeltaT(0,5), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var NewscatterDeltaT50Chart = new Chart(NewdeltaT50, {
		type: 'scatter',
			data: NewdT50,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDT5-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,5), 'DTCAEN5-0data.csv');
	});

	var NewdT42 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 4 - CAEN 2 -'+NewdeltaTComments,
		  borderColor: 'brown',
	      backgroundColor: 'brown', // Color or array of colors for the bars
	      data: getDeltaT(2,4), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var NewscatterDeltaT42Chart = new Chart(NewdeltaT42, {
		type: 'scatter',
			data: NewdT42,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDT4-2').addEventListener('click', () => {	
		downloadArray(getDeltaT(2,4), 'DTCAEN2-4data.csv');
	});

	var NewdT13 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 3 -'+NewdeltaTComments,
		  borderColor: 'blue',
	      backgroundColor: 'blue', // Color or array of colors for the bars
	      data: getDeltaT(3,1), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var NewscatterDeltaT13Chart = new Chart(NewdeltaT13, {
		type: 'scatter',
			data: NewdT13,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDT1-3').addEventListener('click', () => {	
		downloadArray(getDeltaT(3,1), 'DTCAEN1-3data.csv');
	});

	var NewdT15 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 5 -'+NewdeltaTComments,
		  borderColor: 'red',
	      backgroundColor: 'red', // Color or array of colors for the bars
	      data: getDeltaT(5,1), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var NewscatterDeltaT15Chart = new Chart(NewdeltaT15, {
		type: 'scatter',
			data: NewdT15,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDT1-5').addEventListener('click', () => {	
		downloadArray(getDeltaT(5,1), 'DTCAEN1-5data.csv');
	});

	var NewdT35 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 3 - CAEN 5 -'+NewdeltaTComments,
		  borderColor: 'darkgreen',
	      backgroundColor: 'darkgreen', // Color or array of colors for the bars
	      data: getDeltaT(5,3), // Array of numerical values for the bars
		  pointRadius: 3,
	  	 },
	 ],
	};	
	var NewscatterDeltaT35Chart = new Chart(NewdeltaT35, {
		type: 'scatter',
			data: NewdT35,
			options: NewdeltaTOptions,
	});	
	document.getElementById('NewdownloadDT3-5').addEventListener('click', () => {	
		downloadArray(getDeltaT(5,3), 'DTCAEN3-5data.csv');
	});

	document.getElementById('new-analysis-run').style.display = "none";
	document.getElementById('new-analysis-message').style.display = "none";
		
}