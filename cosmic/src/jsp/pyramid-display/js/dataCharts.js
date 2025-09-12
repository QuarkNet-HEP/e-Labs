function removeCharts() {
	canvasIDs = ['X1','X2','X3','Y1','Y2','Y3','DXDY','DX1D','DY1D',
		'DXT1D','DXM1D','DXB1D','DYT1D','DYM1D','DYB1D','DXDZDYDZ','DXDZDYDZTM','DXDZDYDZMB',
		'DT','DT10','DT20','DT30','DT40','DT50','#TRACKS4TM','#TRACKS4MB','#TRACKS5M','#TRACKS5TB','#TRACKS6',
		'X1ADC','X2ADC','X3ADC','Y1ADC','Y2ADC','Y3ADC',
		'X1ADCAverage','X2ADCAverage','X3ADCAverage','Y1ADCAverage','Y2ADCAverage','Y3ADCAverage'
	];
	for (var i = 0; i < canvasIDs.length; i++) {
		let chartStatus = Chart.getChart(canvasIDs[i]); // <canvas> id
		if (chartStatus != undefined) {
	  		chartStatus.destroy();
	  	}
	}
}

function drawAnalysis(l,g) {	
	removeCharts();
	var ctx1 = document.getElementById('X1').getContext('2d');
	var ctx2 = document.getElementById('X2').getContext('2d');
	var ctx3 = document.getElementById('X3').getContext('2d');
	var cty1 = document.getElementById('Y1').getContext('2d');
	var cty2 = document.getElementById('Y2').getContext('2d');
	var cty3 = document.getElementById('Y3').getContext('2d');
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
	
	getDxy();
	getDxyBothLayers();	
	getDxyTopMiddleBothLayers();
	getDxyBottomMiddleBothLayers();
		  
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
	
	var dataX1 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'X CAEN 0', // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: populateX('x', 0), // Array of numerical values for the bars
	    },
	  ],
	};

	var barChartX1 = new Chart(ctx1, {
    	type: 'bar',
    	data: dataX1,
    	options: {
      	scales: {
        	y: {
          		beginAtZero: true,
          		stepSize: 1,
          		precision: 0,// Set the step size to 1 to show only whole numbers
        	},
	     },
	   },
	});

	document.getElementById('downloadXCAEN0').addEventListener('click', () => {
	    downloadArray(populateX('x', 0), 'XCAEN0data.csv');
	});
	
	var dataX2 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'X CAEN 2',
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: populateX('x', 1),
	     },
	  ],
	};
			
	var barChartX2 = new Chart(ctx2, {
	    type: 'bar',
	    data: dataX2,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1,
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	     },
	   },
	});

	document.getElementById('downloadXCAEN2').addEventListener('click', () => {
	    downloadArray(populateX('x', 1), 'XCAEN2data.csv');
	});

	var dataX3 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
		{
	      label: 'X CAEN 4',
	       backgroundColor: 'rgba(20, 255, 132, 0.5)',
	       data: populateX('x', 2),
	     },
	  ],
	};
		
	var barChartX3 = new Chart(ctx3, {
	    type: 'bar',
	    data: dataX3,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1, 
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	      },
	    },
	});  

	document.getElementById('downloadXCAEN4').addEventListener('click', () => {
	    downloadArray(populateX('x', 2), 'XCAEN4data.csv');
	});

	var dataY1 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y CAEN 1', // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: populateY('y', 0), // Array of numerical values for the bars
	    },
	  ],
	};
				
	var barChartY1 = new Chart(cty1, {
	    type: 'bar',
	    data: dataY1,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1, 
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	      },
	    },
	});

	document.getElementById('downloadXCAEN1').addEventListener('click', () => {
	    downloadArray(populateY('y', 0), 'XCAEN1data.csv');
	});

	var dataY2 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y CAEN 3',
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: populateY('y', 1),
	     },
	  ],
	};
				
	var barChartY2 = new Chart(cty2, {
	    type: 'bar',
	    data: dataY2,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1,
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	      },
	    },
	});

	document.getElementById('downloadXCAEN3').addEventListener('click', () => {
	    downloadArray(populateY('y', 1), 'XCAEN3data.csv');
	});

	var dataY3 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Y CAEN 5',
	       backgroundColor: 'rgba(20, 255, 132, 0.5)',
	       data: populateY('y', 2),
	          options: options,
	     },
	  ],
	};	
		
	var barChartY3 = new Chart(cty3, {
	    type: 'bar',
	    data: dataY3,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1,
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	      },
	    },
	});

	document.getElementById('downloadXCAEN5').addEventListener('click', () => {
	    downloadArray(populateY('y', 2), 'XCAEN5data.csv');
	});

	var DXDYdatasets = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX - DY', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'cyan', // Color or array of colors for the bars
	       data: getDxDy(0), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 },
		 {
		   label: 'DX - DY Top/Middle', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getDxDyMiddle(dxtopmiddlebothlayers, dytopmiddlebothlayers, 0), // Array of numerical values for the bars
		   pointRadius: 5,
		 },		 
		 {
		   label: 'DX - DY Middle/Bottom', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'orange', // Color or array of colors for the bars
		   data: getDxDyMiddle(dxbottommiddlebothlayers, dybottommiddlebothlayers, 0), // Array of numerical values for the bars
		   pointRadius: 5,
		 },
	 ],
	};				
	var scatterDXDYChart = new Chart(dxdy, {
		    type: 'scatter',
		    data: DXDYdatasets,
		    options: {
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
		    }
		}		
	);
	
	document.getElementById('downloadDXDY').addEventListener('click', () => {
	    downloadXYdata(getDxDy(0), 'DXDYdata.csv');
	});
	document.getElementById('downloadDXDYTOPMIDDLE').addEventListener('click', () => {
	    downloadXYdata(getDxDyMiddle(dxtopmiddlebothlayers, dytopmiddlebothlayers, 0), 'DXDYTOPMIDDLEdata.csv');
	});
	document.getElementById('downloadDXDYBOTTOMMIDDLE').addEventListener('click', () => {
	    downloadXYdata(getDxDyMiddle(dxbottommiddlebothlayers, dybottommiddlebothlayers, 0), 'DXDYBOTTOMMIDDLEdata.csv');
	});
	//var bothlayersfrequency = calculateDeltaXDeltaYFrequency(dxbothlayers,0,2);
	var deltaXFrequency = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX Frequency Distribution', // Label for the dataset
		   //borderColor: 'gray',
	       backgroundColor: 'blue', // Color or array of colors for the bars
	       data: calculateDeltaXDeltaYFrequency(dxbothlayers,0,2), 
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
	  	 },
		 {
		   label: 'DX Top/Middle Frequency Distribution', // Label for the dataset
		   //borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: calculateDeltaXDeltaYFrequency(dxtopmiddlebothlayers,0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
		 },		 
		 {
		   label: 'DX Middle/Bottom Frequency Distribution', // Label for the dataset
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
		    options: {
		      scales: {
		        x: {
		          type: 'linear', // Use linear scale for the x-axis
		          position: 'bottom',
		    //      suggestedMin: 0, // Set the minimum value to 0
		        },
		        y: {
		          type: 'linear', // Use linear scale for the y-axis
		          position: 'left'
		        }
		      }
		    }
		}		
	);	

	document.getElementById('downloadDX1D').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dxbothlayers,0,2), 'DX1Ddata.csv');
	});	
	document.getElementById('downloadDX1DTOPMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dxtopmiddlebothlayers,0,2), 'DX1DTOPMIDDLEdata.csv');
	});	
	document.getElementById('downloadDX1DBOTTOMMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dxbottommiddlebothlayers,0,2), 'DX1DBOTTOMMIDDLEdata.csv');
	});	
	
	var deltaYFrequency = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DY Frequency Distribution', // Label for the dataset
		   //borderColor: 'gray',
	       backgroundColor: 'magenta', // Color or array of colors for the bars
	       data: calculateDeltaXDeltaYFrequency(dybothlayers,0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
	  	 },
		 {
		   label: 'DY Top/Middle Frequency Distribution', // Label for the dataset
		   //borderColor: 'gray',
		   backgroundColor: 'green', // Color or array of colors for the bars
		   data: calculateDeltaXDeltaYFrequency(dytopmiddlebothlayers,0,2), // Array of numerical values for the bars
		   pointRadius: 3,
		   borderWidth: 1,
		   lineTension: 0.5,
		   fill: false		   
		 },		 
		 {
		   label: 'DY Middle/Bottom Frequency Distribution', // Label for the dataset
		   //borderColor: 'gray',
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
		    options: {
		      scales: {
		        x: {
		          type: 'linear', // Use linear scale for the x-axis
		          position: 'bottom',
		          //suggestedMin: 0, // Set the minimum value to 0
		        },
		        y: {
		          type: 'linear', // Use linear scale for the y-axis
		          position: 'left'
		        }
		      }
		    }
		}		
	);	

	document.getElementById('downloadDY1D').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dybothlayers,0,2), 'DY1Ddata.csv');
	});	
	document.getElementById('downloadDY1DTOPMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dytopmiddlebothlayers,0,2), 'DY1DTOPMIDDLEdata.csv');
	});	
	document.getElementById('downloadDY1DBOTTOMMIDDLE').addEventListener('click', () => {
	    downloadArray(calculateDeltaXDeltaYFrequency(dybottommiddlebothlayers,0,2), 'DY1DBOTTOMMIDDLEdata.csv');
	});	

	var dxtopChannelfrequency = getChannelData('top',dxbothlayers, xLayerLength, 0);	
	var dxtopmiddleChannelfrequency = getChannelData('top',dxtopmiddlebothlayers, xLayerLength, 0);	
	var frequencyTopMapX = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of X Top Cells on Track', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'green', // Color or array of colors for the bars
	       data: getFrequency(dxtopChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 },
		 {
		   label: 'Frequency of X Top Cells on Half-Track', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getFrequency(dxtopmiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
		 },		 
 	  ],
	};		
	var scatterDXT1dChart = new Chart(dxT1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyTopMapX,
		    options: {
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
		    }
		}		
	);	
	
	document.getElementById('downloadDXT1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxtopChannelfrequency), 'DXT1Ddata.csv');
	});
	document.getElementById('downloadDXTM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(frequencyTopMiddleMapX), 'DXTM1Ddata.csv');
	});

	var dxmiddleChannelfrequency = getChannelData('middle',dxbothlayers, xLayerLength, 0);	
	var dxmiddleChannelfrequencyT = getChannelData('middle',dxtopmiddlebothlayers, xLayerLength, 0);	
	var dxmiddleChannelfrequencyB = getChannelData('middle',dxbottommiddlebothlayers, xLayerLength, 0);	
	var frequencyMiddleMapX = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of X Middle Cells on Track', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'red', // Color or array of colors for the bars
	       data: getFrequency(dxmiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 },
		 {
		   label: 'Frequency of X Middle Cells on Half-Track (Top/Middle)', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getFrequency(dxmiddleChannelfrequencyT), // Array of numerical values for the bars
		   pointRadius: 5,
		 },		 
		 {
		   label: 'Frequency of X Middle Cells on Half-Track (Bottom/Middle', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'blue', // Color or array of colors for the bars
		   data: getFrequency(dxmiddleChannelfrequencyB), // Array of numerical values for the bars
		   pointRadius: 5,
		 },	
	  ],
	};		

	var scatterDXM1dChart = new Chart(dxM1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyMiddleMapX,
		    options: {
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
		    }
		}		
	);	

	document.getElementById('downloadDXM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxmiddleChannelfrequency), 'DXM1Ddata.csv');
	});
	document.getElementById('downloadDXM1DT').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxmiddleChannelfrequencyT), 'DXM1DTdata.csv');
	});
	document.getElementById('downloadDXM1DB').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxmiddleChannelfrequencyB), 'DXM1DBdata.csv');
	});

	var dxbottomChannelfrequency = getChannelData('bottom',dxbothlayers, xLayerLength, 0);	
	var dxbottomMiddleChannelfrequency = getChannelData('bottom',dxbottommiddlebothlayers, xLayerLength, 0);	
	var frequencyBottomMapX = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of Bottom X cells on Track', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'blue', // Color or array of colors for the bars
	       data: getFrequency(dxbottomChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 },
		 {
		   label: 'Frequency of X Bottom Cells on Half-Track', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'lightgreen', // Color or array of colors for the bars
		   data: getFrequency(dxbottomMiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
		 },		 
	  ],
	};		
	
	var scatterDXB1dChart = new Chart(dxB1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyBottomMapX,
		    options: {
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
		    }
		}		
	);	

	document.getElementById('downloadDXB1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxbottomChannelfrequency), 'DXB1Ddata.csv');
	});
	document.getElementById('downloadDXBM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dxbottomMiddleChannelfrequency), 'DXBM1Ddata.csv');
	});

	var dytopChannelfrequency = getChannelData('top',dybothlayers, yLayerLength, 0);
	var dytopMiddleChannelfrequency = getChannelData('top',dytopmiddlebothlayers, yLayerLength, 0);	
	var frequencyTopMapY = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of Top Y cells on Track', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'green', // Color or array of colors for the bars
	       data: getFrequency(dytopChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 },
		 {
		   label: 'Frequency of Y Top Cells on Half-Track', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getFrequency(dytopMiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
		 },		 
	  ],
	};		
	var scatterDYT1dChart = new Chart(dyT1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyTopMapY,
		    options: {
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
		    }
		}		
	);	

	document.getElementById('downloadDYT1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dytopChannelfrequency), 'DYT1Ddata.csv');
	});
	document.getElementById('downloadDYTM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dytopMiddleChannelfrequency), 'DYTM1Ddata.csv');
	});
			
	var dymiddleChannelfrequency = getChannelData('middle',dybothlayers, yLayerLength, 0);	
	var dymiddleChannelfrequencyT = getChannelData('middle',dytopmiddlebothlayers, yLayerLength, 0);	
	var dymiddleChannelfrequencyB = getChannelData('middle',dybottommiddlebothlayers, yLayerLength, 0);	
	var frequencyMiddleMapY = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of Y Middle Cells on Track', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'crimson', // Color or array of colors for the bars
	       data: getFrequency(dymiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 },
		 {
		   label: 'Frequency of Y Middle Cells on Half-Track (Top/Middle)', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'lightblue', // Color or array of colors for the bars
		   data: getFrequency(dymiddleChannelfrequencyT), // Array of numerical values for the bars
		   pointRadius: 5,
		 },		 
		 {
		   label: 'Frequency of Y Middle Cells on Half-Track (Bottom/Middle', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getFrequency(dymiddleChannelfrequencyB), // Array of numerical values for the bars
		   pointRadius: 5,
		 },	
	  ],
	};		
	
	var scatterDYM1dChart = new Chart(dyM1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyMiddleMapY,
		    options: {
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
		    }
		}		
	);	

	document.getElementById('downloadDYM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dymiddleChannelfrequency), 'DYM1Ddata.csv');
	});
	document.getElementById('downloadDYM1DT').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dymiddleChannelfrequencyT), 'DYM1DTdata.csv');
	});
	document.getElementById('downloadDYM1DB').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dymiddleChannelfrequencyB), 'DYM1DBdata.csv');
	});

	var dybottomChannelfrequency = getChannelData('bottom',dybothlayers, yLayerLength, 0);	
	var dybottomMiddleChannelfrequency = getChannelData('bottom',dybottommiddlebothlayers, yLayerLength, 0);	
	var frequencyBottomMapY = {
	  labels: [],
	  datasets: [
	     {
	       label: 'Frequency of Bottom Y cells on Track', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'purple', // Color or array of colors for the bars
	       data: getFrequency(dybottomChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 },
		 {
		   label: 'Frequency of Y Bottom Cells on Half-Track', // Label for the dataset
		   borderColor: 'gray',
		   backgroundColor: 'lightgreen', // Color or array of colors for the bars
		   data: getFrequency(dybottomMiddleChannelfrequency), // Array of numerical values for the bars
		   pointRadius: 5,
		 },		 
	  ],
	};		
	
	var scatterDYB1dChart = new Chart(dyB1d, {
		    type: 'scatter',
			labels: [],
		    data: frequencyBottomMapY,
		    options: {
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
		    }
		}		
	);		

	document.getElementById('downloadDYB1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dybottomChannelfrequency), 'DYB1Ddata.csv');
	});
	document.getElementById('downloadDYBM1D').addEventListener('click', () => {
	    downloadXYdata(getFrequency(dybottomMiddleChannelfrequency), 'DYBM1Ddata.csv');
	});

	var DXDZDYDZdatasets = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX/DZ - DY/DZ', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'cyan', // Color or array of colors for the bars
	       data: getDxDz(0), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 }
	 ],
	};				
	var scatterDXDZDYDZChart = new Chart(dxdzdydz, {
		    type: 'scatter',
		    data: DXDZDYDZdatasets,
		    options: {
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
		    }
		}		
	);

	document.getElementById('downloadDXDZDYDZ').addEventListener('click', () => {
	    downloadXYdata(getDxDz(0), 'DXDZDYDZdata.csv');
	});

	var DXDZDYDZTMdatasets = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX/DZ - DY/DZ (TOP-MIDDLE)', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'yellow', // Color or array of colors for the bars
	       data: getDxyDzMiddle(dxtopmiddlebothlayers,dytopmiddlebothlayers, 0), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 }
	 ],
	};
					
	var scatterDXDZDYDZTMChart = new Chart(dxdzdydzTM, {
		    type: 'scatter',
		    data: DXDZDYDZTMdatasets,
		    options: {
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
		    }
		}		
	);

	document.getElementById('downloadDXDZDYDZTM').addEventListener('click', () => {
	    downloadXYdata(getDxyDzMiddle(dxtopmiddlebothlayers,dytopmiddlebothlayers, 0), 'DXDZDYDZTMdata.csv');
	});

	var DXDZDYDZMBdatasets = {
	  labels: [],
	  datasets: [
	     {
	       label: 'DX/DZ - DY/DZ (MIDDLE-BOTTOM)', // Label for the dataset
		   borderColor: 'gray',
	       backgroundColor: 'orange', // Color or array of colors for the bars
	       data: getDxyDzMiddle(dxbottommiddlebothlayers,dybottommiddlebothlayers, 0), // Array of numerical values for the bars
		   pointRadius: 5,
	  	 }
	 ],
	};
	
	var scatterDXDZDYDZMBChart = new Chart(dxdzdydzMB, {
		    type: 'scatter',
		    data: DXDZDYDZMBdatasets,
		    options: {
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
		    }
		}		
	);

	document.getElementById('downloadDXDZDYDZMB').addEventListener('click', () => {
	    downloadXYdata(getDxyDzMiddle(dxbottommiddlebothlayers,dybottommiddlebothlayers, 0), 'DXDZDYDZMBdata.csv');
	});
			
	var deltaTdatasets = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 0', // Label for the dataset
		  borderColor: 'orange',
	      backgroundColor: 'orange', // Color or array of colors for the bars
	      data: getDeltaT(0,1), // Array of numerical values for the bars
		  pointRadius: 5,
	  	 },
		 {
		   label: 'Delta T CAEN 2 - CAEN 0', // Label for the dataset
		   borderColor: 'purple',
		   backgroundColor: 'purple', // Color or array of colors for the bars
		   data: getDeltaT(0,2), // Array of numerical values for the bars
		   pointRadius: 5,
		 },		 
		 {
		   label: 'Delta T CAEN 3 - CAEN 0', // Label for the dataset
		   borderColor: 'yellow',
		   backgroundColor: 'yellow', // Color or array of colors for the bars
		   data: getDeltaT(0,3), // Array of numerical values for the bars
		   pointRadius: 5,
		 },
		 {
		   label: 'Delta T CAEN 4 - CAEN 0', // Label for the dataset
		   borderColor: 'lightgreen',
		   backgroundColor: 'lightgreen', // Color or array of colors for the bars
		   data: getDeltaT(0,4), // Array of numerical values for the bars
		   pointRadius: 5,
		 },
		 {
		   label: 'Delta T CAEN 5 - CAEN 0', // Label for the dataset
		   borderColor: 'pink',
		   backgroundColor: 'pink', // Color or array of colors for the bars
		   data: getDeltaT(0,5), // Array of numerical values for the bars
		   pointRadius: 5,
		 },
	 ],
	};	
	var scatterDeltaTChart = new Chart(deltaT, {
		type: 'scatter',
			data: deltaTdatasets,
			options: {
				scales: {
				  x: {
				    type: 'linear', // Use linear scale for the x-axis
				    position: 'bottom',
				    //suggestedMin: 0, // Set the minimum value to 0
				    }
				  },
				  y: {
				    type: 'linear', // Use linear scale for the y-axis
				    position: 'left'
				  }
				},
	});	
	
	document.getElementById('downloadDT1-0').addEventListener('click', () => {
	    downloadArray(getDeltaT(0,1), 'DTCAEN1-0data.csv');
	});
	document.getElementById('downloadDT2-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,2), 'DTCAEN2-0data.csv');
	});
	document.getElementById('downloadDT3-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,3), 'DTCAEN3-0data.csv');
	});
	document.getElementById('downloadDT4-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,4), 'DTCAEN4-0data.csv');
	});
	document.getElementById('downloadDT5-0').addEventListener('click', () => {	
		downloadArray(getDeltaT(0,5), 'DTCAEN5-0data.csv');
	});

	var dT10 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 1 - CAEN 0', // Label for the dataset
		  borderColor: 'orange',
	      backgroundColor: 'orange', // Color or array of colors for the bars
	      data: getDeltaT(0,1), // Array of numerical values for the bars
		  pointRadius: 5,
	  	 },
	 ],
	};	
	var scatterDeltaT10Chart = new Chart(deltaT10, {
		type: 'scatter',
			data: dT10,
			options: {
				scales: {
				  x: {
				    type: 'linear', // Use linear scale for the x-axis
				    position: 'bottom',
				    //suggestedMin: 0, // Set the minimum value to 0
				    }
				  },
				  y: {
				    type: 'linear', // Use linear scale for the y-axis
				    position: 'left'
				  }
				},
	});	
	
	var dT20 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 2 - CAEN 0', // Label for the dataset
		  borderColor: 'purple',
	      backgroundColor: 'purple', // Color or array of colors for the bars
	      data: getDeltaT(0,2), // Array of numerical values for the bars
		  pointRadius: 5,
	  	 },
	 ],
	};	
	var scatterDeltaT20Chart = new Chart(deltaT20, {
		type: 'scatter',
			data: dT20,
			options: {
				scales: {
				  x: {
				    type: 'linear', // Use linear scale for the x-axis
				    position: 'bottom',
				    //suggestedMin: 0, // Set the minimum value to 0
				    }
				  },
				  y: {
				    type: 'linear', // Use linear scale for the y-axis
				    position: 'left'
				  }
				},
	});	
	
	var dT30 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 3 - CAEN 0', // Label for the dataset
		  borderColor: 'yellow',
	      backgroundColor: 'yellow', // Color or array of colors for the bars
	      data: getDeltaT(0,3), // Array of numerical values for the bars
		  pointRadius: 5,
	  	 },
	 ],
	};	
	var scatterDeltaT30Chart = new Chart(deltaT30, {
		type: 'scatter',
			data: dT30,
			options: {
				scales: {
				  x: {
				    type: 'linear', // Use linear scale for the x-axis
				    position: 'bottom',
				    //suggestedMin: 0, // Set the minimum value to 0
				    }
				  },
				  y: {
				    type: 'linear', // Use linear scale for the y-axis
				    position: 'left'
				  }
				},
	});	

	var dT40 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 4 - CAEN 0', // Label for the dataset
		  borderColor: 'lightgreen',
	      backgroundColor: 'lightgreen', // Color or array of colors for the bars
	      data: getDeltaT(0,4), // Array of numerical values for the bars
		  pointRadius: 5,
	  	 },
	 ],
	};	
	var scatterDeltaT40Chart = new Chart(deltaT40, {
		type: 'scatter',
			data: dT40,
			options: {
				scales: {
				  x: {
				    type: 'linear', // Use linear scale for the x-axis
				    position: 'bottom',
				    //suggestedMin: 0, // Set the minimum value to 0
				    }
				  },
				  y: {
				    type: 'linear', // Use linear scale for the y-axis
				    position: 'left'
				  }
				},
	});	

	var dT50 = {
	  labels: [],
	  datasets: [
	    {
	      label: 'Delta T CAEN 5 - CAEN 0', // Label for the dataset
		  borderColor: 'pink',
	      backgroundColor: 'pink', // Color or array of colors for the bars
	      data: getDeltaT(0,5), // Array of numerical values for the bars
		  pointRadius: 5,
	  	 },
	 ],
	};	
	var scatterDeltaT50Chart = new Chart(deltaT50, {
		type: 'scatter',
			data: dT50,
			options: {
				scales: {
				  x: {
				    type: 'linear', // Use linear scale for the x-axis
				    position: 'bottom',
				    //suggestedMin: 0, // Set the minimum value to 0
				    }
				  },
				  y: {
				    type: 'linear', // Use linear scale for the y-axis
				    position: 'left'
				  }
				},
	});	
		
	var eventWithTracksCount4TM = getEventsWithTracksPerMinute(4,'TM');
	var labels4TM = Object.keys(eventWithTracksCount4TM);
	var values4TM = Object.values(eventWithTracksCount4TM);
	var numberTracks4TM = {
	  labels: labels4TM, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (4) top-middle with tracks (per minute)',
	       backgroundColor: 'purple',
	       data: values4TM,
	     },
	  ],
	};	
		
	var scatterChartTracks4TM = new Chart(tracks4TM, {
	    type: 'bar',
	    data: numberTracks4TM,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1,
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	      },
	    },
	});

	document.getElementById('downloadTRACKS4TM').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(4,'TM'), 'EVENTSTRACKS4TMMINUTEdata.csv');
	});

	var eventWithTracksCount4MB = getEventsWithTracksPerMinute(4,'MB');
	var labels4MB = Object.keys(eventWithTracksCount4MB);
	var values4MB = Object.values(eventWithTracksCount4MB);
	var numberTracks4MB = {
	  labels: labels4MB, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (4) middle-bottom with tracks (per minute)',
	       backgroundColor: 'green',
	       data: values4MB,
	     },
	  ],
	};	
		
	var scatterChartTracks4MB = new Chart(tracks4MB, {
	    type: 'bar',
	    data: numberTracks4MB,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1,
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	      },
	    },
	});

	document.getElementById('downloadTRACKS4MB').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(4,'MB'), 'EVENTSTRACKS4MBMINUTEdata.csv');
	});		
	
	var eventWithTracksCount5M = getEventsWithTracksPerMinute(5,'M');
	var labels5M = Object.keys(eventWithTracksCount5M);
	var values5M = Object.values(eventWithTracksCount5M);
	var numberTracks5M = {
	  labels: labels5M, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (5) with tracks (per minute-MIDDLE missing)',
	       backgroundColor: 'pink',
	       data: values5M,
	     },
	  ],
	};	
		
	var scatterChartTracks5M = new Chart(tracks5M, {
	    type: 'bar',
	    data: numberTracks5M,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1,
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	      },
	    },
	});

	document.getElementById('downloadTRACKS5M').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(5,'M'), 'EVENTSTRACKS5MINUTEdataM.csv');
	});

	var eventWithTracksCount5TB = getEventsWithTracksPerMinute(5,'TB');
	var labels5TB = Object.keys(eventWithTracksCount5TB);
	var values5TB = Object.values(eventWithTracksCount5TB);
	var numberTracks5TB = {
	  labels: labels5TB, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (5) with tracks (per minute-TOP or BOTTOM missing)',
	       backgroundColor: 'lightblue',
	       data: values5TB,
	     },
	  ],
	};	
		
	var scatterChartTracks5TB = new Chart(tracks5TB, {
	    type: 'bar',
	    data: numberTracks5TB,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1,
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	      },
	    },
	});

	document.getElementById('downloadTRACKS5TB').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(5,'TB'), 'EVENTSTRACKS5MINUTEdataTB.csv');
	});
				
	var eventWithTracksCount6 = getEventsWithTracksPerMinute(6,'');
	var labels6 = Object.keys(eventWithTracksCount6);
	var values6 = Object.values(eventWithTracksCount6);
	var numberTracks6 = {
	  labels: labels6, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	       label: '# of events (6) with tracks (per minute)',
	       backgroundColor: 'orange',
	       data: values6,
	     },
	  ],
	};	
		
	var scatterChartTracks6 = new Chart(tracks6, {
	    type: 'bar',
	    data: numberTracks6,
	    options: {
	      scales: {
	        y: {
	          beginAtZero: true,
	          stepSize: 1,
	          precision: 0,// Set the step size to 1 to show only whole numbers
	        },
	      },
	    },
	});

	document.getElementById('downloadTRACKS6').addEventListener('click', () => {
	    downloadXYdata(getEventsWithTracksPerMinute(6,''), 'EVENTSTRACKS6MINUTEdata.csv');
	});


								
	var scatterChartADCX1 = new Chart(X1ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'X CAEN 0 Paired ADC',
            data: popXADR(0),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 5, // Size of the data points
          }]
        },
        options: {
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
        }
	});

	document.getElementById('downloadXCAEN0ADC').addEventListener('click', () => {
	    downloadXYdata(popXADR(0), 'XCAEN0ADCdata.csv');
	});
					
	var scatterChartADCX1Average = new Chart(X1ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'X CAEN 0 Paired ADC-Average',
	        data: popXADRAverage(0),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 5, // Size of the data points
	      }]
	    },
	    options: {
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
	    }
	});
	
	document.getElementById('downloadXCAEN0ADCAverage').addEventListener('click', () => {
	    downloadXYdata(popXADRAverage(0), 'XCAEN0ADCAveragedata.csv');
	});
	
	var scatterChartADCX2 = new Chart(X2ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'X CAEN 2 Paired ADC',
            data: popXADR(1),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 5, // Size of the data points
          }]
        },
        options: {
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
        }
	});

	document.getElementById('downloadXCAEN2ADC').addEventListener('click', () => {
	    downloadXYdata(popXADR(1), 'XCAEN2ADCdata.csv');
	});
					
	var scatterChartADCX2Average = new Chart(X2ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'X Layer 2 Paired ADC-Average',
	        data: popXADRAverage(1),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 5, // Size of the data points
	      }]
	    },
	    options: {
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
	    }
	});

	document.getElementById('downloadXCAEN2ADCAverage').addEventListener('click', () => {
	    downloadXYdata(popXADRAverage(1), 'XCAEN2ADCAveragedata.csv');
	});
	
	var scatterChartADCX3 = new Chart(X3ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'X CAEN 4 Paired ADC',
            data: popXADR(2),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 5, // Size of the data points
          }]
        },
        options: {
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
        }
	});

	document.getElementById('downloadXCAEN4ADC').addEventListener('click', () => {
	    downloadXYdata(popXADR(2), 'XCAEN4ADCdata.csv');
	});
					
	var scatterChartADCX3Average = new Chart(X3ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'X CAEN 4 Paired ADC-Average',
	        data: popXADRAverage(2),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 5, // Size of the data points
	      }]
	    },
	    options: {
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
	    }
	});

	document.getElementById('downloadXCAEN4ADCAverage').addEventListener('click', () => {
	    downloadXYdata(popXADRAverage(2), 'XCAEN4ADCAveragedata.csv');
	});
	
	var scatterChartADCY1 = new Chart(Y1ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'Y CAEN 1 Paired ADC',
            data: popYADR(0),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 5, // Size of the data points
          }]
        },
        options: {
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
        }
	});

	document.getElementById('downloadYCAEN1ADC').addEventListener('click', () => {
	    downloadXYdata(popYADR(0), 'YCAEN1ADCdata.csv');
	});
					
	var scatterChartADCY1Average = new Chart(Y1ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'Y CAEN 1 Paired ADC-Average',
	        data: popYADRAverage(0),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 5, // Size of the data points
	      }]
	    },
	    options: {
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
	    }
	});

	document.getElementById('downloadYCAEN1ADCAverage').addEventListener('click', () => {
	    downloadXYdata(popYADRAverage(0), 'YCAEN1ADCAveragedata.csv');
	});
		
	var scatterChartADCY2 = new Chart(Y2ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'Y CAEN 3 Paired ADC',
            data: popYADR(1),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 5, // Size of the data points
          }]
        },
        options: {
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
        }
	});

	document.getElementById('downloadYCAEN3ADC').addEventListener('click', () => {
	    downloadXYdata(popYADR(1), 'YCAEN3ADCdata.csv');
	});
		
	var scatterChartADCY2Average = new Chart(Y2ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'Y CAEN 3 Paired ADC-Average',
	        data: popYADRAverage(1),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 5, // Size of the data points
	      }]
	    },
	    options: {
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
	    }
	});

	document.getElementById('downloadYCAEN3ADCAverage').addEventListener('click', () => {
	    downloadXYdata(popYADRAverage(1), 'YCAEN3ADCAveragedata.csv');
	});

	var scatterChartADCY3 = new Chart(Y3ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'Y CAEN 5 Paired ADC',
            data: popYADR(2),
            backgroundColor: 'rgba(54, 162, 235, 0.6)', // Color of the data points
            pointRadius: 5, // Size of the data points
          }]
        },
        options: {
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
        }
	});

	document.getElementById('downloadYCAEN5ADC').addEventListener('click', () => {
	    downloadXYdata(popYADR(2), 'YCAEN5ADCdata.csv');
	});

	var scatterChartADCY3Average = new Chart(Y3ADCAverage, {
	    type: 'scatter',
	    data: {
	      datasets: [{
	        label: 'Y CAEN 5 Paired ADC-Average',
	        data: popYADRAverage(2),
	        backgroundColor: 'blue', // Color of the data points
	        pointRadius: 5, // Size of the data points
	      }]
	    },
	    options: {
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
	    }
	});

	document.getElementById('downloadYCAEN5ADCAverage').addEventListener('click', () => {
	    downloadXYdata(popYADRAverage(2), 'YCAEN5ADCAveragedata.csv');
	});

};
