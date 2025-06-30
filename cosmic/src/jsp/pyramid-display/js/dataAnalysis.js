let debugAnalysis = false;
var xLayerLength = 0;
var yLayerLength = 0;

//Analysis code
function addArrays(arr1, arr2) {
  var result = [];
  for (var i = 0; i < arr1.length; i++) {
    if(i < arr2.length){
      result.push(arr1[i] + arr2[i]);
  	}else{
      result.push(arr1[i])
  	}
  }
  return result;
}

function popXADR(layer) {
  	var vals = [];
  	for (var event = 0; event < subtractPedX.length; event++) {
    	for(var channel = 1; channel < subtractPedX[event][layer].length; channel++){
      		if(subtractPedX[event][layer][channel-1] > 0 && subtractPedX[event][layer][channel] > 0){
        		var xCord = channel - 1;
        		var yCord = (subtractPedX[event][layer][channel-1] + subtractPedX[event][layer][channel]);
        		vals.push({ x: xCord, y: yCord});
      		}
    	}
  	}
	if (debugAnalysis === true) {
  		console.log("XADR "+layer);
  		console.log("values:", vals);
  	}
  	return vals;
}

function popYADR(layer) {
  	var vals = [];
  	for (var event = 0; event < subtractPedY.length; event++) {
    	for(var channel = 1; channel < subtractPedY[event][layer].length; channel++){
      		if(subtractPedY[event][layer][channel-1]>0 &&subtractPedY[event][layer][channel]>0){
        		var xCord = channel - 1;
        		var yCord = (subtractPedY[event][layer][channel-1]+ subtractPedY[event][layer][channel]);
        		vals.push({ x: xCord, y: yCord});
      		}
    	}
  	}
	if (debugAnalysis === true) {
  		console.log("YADR "+layer);
  		console.log("values:", vals);
  	}
  	return vals;
}

function populateY(letter, layer){
  	var vals = Array(yLayerLength).fill(0);
  	var pedestal =  subtractPedY;
  	for(var a = 0; a < pedestal.length; a++){
  		var modPed = pedestal[a][layer].slice(0, yLayerLength).map(function(value) {
    	return value > 0 ? 1 : value;
  		});
    	vals = addArrays(vals, modPed)
  	}
	if (debugAnalysis === true) {
  		console.log("Y Pedestal "+layer+letter);
  		console.log("values:", vals);
  	}  	
  	return vals;
}

function populateX(letter, layer){
  	var vals = Array(xLayerLength).fill(0);
  	var pedestal = subtractPedX;
  	for(var a = 0; a < pedestal.length; a++) {
	    //console.log("pedestal:"+pedestal[a][layer]);
  		var modPed = pedestal[a][layer].slice(0, xLayerLength).map(function(value) {
    	return value > 0 ? 1 : value;
  		});
  		//console.log(modPed);
    	vals = addArrays(vals, modPed);
  	}
	if (debugAnalysis === true) {
  		console.log("X Pedestal "+layer+letter);
  		console.log("values:", vals);
  	}  	
  	return vals;
}

function removeCharts() {
	canvasIDs = ['X1','X2','X3','Y1','Y2','Y3','X1ADC','X2ADC','X3ADC','Y1ADC','Y2ADC','Y3ADC'];
	for (var i = 0; i < canvasIDs.length; i++) {
		let chartStatus = Chart.getChart(canvasIDs[i]); // <canvas> id
		if (chartStatus != undefined) {
	  		chartStatus.destroy();
	  	}
	}
	
}

function drawAnalysis(l) {	
	removeCharts();
	var ctx1 = document.getElementById('X1').getContext('2d');
	var ctx2 = document.getElementById('X2').getContext('2d');
	var ctx3 = document.getElementById('X3').getContext('2d');
	var cty1 = document.getElementById('Y1').getContext('2d');
	var cty2 = document.getElementById('Y2').getContext('2d');
	var cty3 = document.getElementById('Y3').getContext('2d');
	var X1ADC = document.getElementById('X1ADC').getContext('2d');
	var X2ADC = document.getElementById('X2ADC').getContext('2d');
	var X3ADC = document.getElementById('X3ADC').getContext('2d');
	var Y1ADC = document.getElementById('Y1ADC').getContext('2d');
	var Y2ADC = document.getElementById('Y2ADC').getContext('2d');
	var Y3ADC = document.getElementById('Y3ADC').getContext('2d');

	xLayerLength = (l[4].length - 2) * 4;
	yLayerLength = (l[5].length - 2) * 4;
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
	var xADRLabels = [];
	for(var i = 1; i <= xLayerLength; i++){
	    xADRLabels.push('Channel ' + (i-1).toString() + " & " + i.toString());
	}
	  
	var yADRLabels = [];
	for(var i = 1; i <= yLayerLength; i++){
	    yADRLabels.push('Channel ' + (i-1).toString() + " & " + i.toString());
	}
	  
	var yLabels = [];
	for(var i = 0; i < yLayerLength; i++){
	  yLabels.push('Channel ' + i.toString());
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
	      label: 'X Layer One', // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: populateX('x', 0), // Array of numerical values for the bars
	    },
	  ],
	};
	var dataX2 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'X Layer Two',
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: populateX('x', 1),
	     },
	  ],
	};
	var dataX3 = {
	  labels: xLabels, // Array of labels for each bar on the x-axis
	  datasets: [
		{
	      label: 'X Layer Three',
	       backgroundColor: 'rgba(20, 255, 132, 0.5)',
	       data: populateX('x', 2),
	     },
	  ],
	};
	var dataY1 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y Layer One', // Label for the dataset
	      backgroundColor: 'rgba(54, 162, 235, 0.5)', // Color or array of colors for the bars
	      data: populateY('y', 0), // Array of numerical values for the bars
	    },
	  ],
	};
	var dataY2 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	    {
	      label: 'Y Layer Two',
	       backgroundColor: 'rgba(255, 99, 132, 0.5)',
	       data: populateY('y', 1),
	     },
	  ],
	};
	var dataY3 = {
	  labels: yLabels, // Array of labels for each bar on the x-axis
	  datasets: [
	        {
	      label: 'Y Layer Three',
	       backgroundColor: 'rgba(20, 255, 132, 0.5)',
	       data: populateY('y', 2),
	          options: options,
	     },
	  ],
	};
	var myBarChartX1 = new Chart(ctx1, {
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
	var myBarChartX2 = new Chart(ctx2, {
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
	var myBarChartX3 = new Chart(ctx3, {
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
	var myBarChartY1 = new Chart(cty1, {
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
	var myBarChartY2 = new Chart(cty2, {
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
	var myBarChartY3 = new Chart(cty3, {
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
	var myBarChartADCX1 = new Chart(X1ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'X Layer 1 Paired ADC',
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
	var myBarChartADCX2 = new Chart(X2ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'X Layer 2 Paired ADC',
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
	var myBarChartADCX3 = new Chart(X3ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'X Layer 3 Paired ADC',
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
	var myBarChartADCY1 = new Chart(Y1ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'Y Layer 1 Paired ADC',
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
	var myBarChartADCY2 = new Chart(Y2ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'Y Layer 2 Paired ADC',
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
	var myBarChartADCY3 = new Chart(Y3ADC, {
        type: 'scatter',
        data: {
          datasets: [{
            label: 'Y Layer 3 Paired ADC',
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
};


