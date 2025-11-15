function NewremoveCharts() {
	canvasIDs = ['NewX1','NewX2','NewX3',
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
	      label: 'X CAEN 0 -'+globalThis.selectedFileClean+' '+globalThis.conversionComments, // Label for the dataset
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
	      label: 'X CAEN 2 -'+globalThis.selectedFileClean+' '+globalThis.conversionComments,
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
	      label: 'X CAEN 4 -'+globalThis.selectedFileClean+' '+globalThis.conversionComments,
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
}