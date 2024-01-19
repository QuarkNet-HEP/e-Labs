var x = [];
var y = [];

var geometry = [];
var subtractPedX; // Declare in the global scope
var subtractPedY;
var inputElement = document.getElementById("quantity");
var url1 = 'https://raw.githubusercontent.com/QuarkNet-HEP/pyramid/main/Pyramid_FakeTracker_XY-views_Run4_non-ZeroSup.txt';
var url2 = 'https://raw.githubusercontent.com/QuarkNet-HEP/pyramid/main/Pedastalv2.txt';
var geometryURL = 'https://raw.githubusercontent.com/QuarkNet-HEP/pyramid/main/GEOMETRY%20HEADER.txt';
var inputElement = document.getElementById("quantity");

// Function to process the data from the URL using fetch
function processData2(url) {
  return fetch(url)
    .then(function(response) {
      if (!response.ok) {
        throw new Error('Network response was not ok.');
      }
      return response.text();
    })
    .then(function(textData) {
      var df = Papa.parse(textData, { delimiter: /\s+/, header: false }).data;
      var filteredData = df.map(function(row) { return row.filter(function(cell) { return cell !== ''; }); }); // Filter out empty cells
      return filteredData;
    })
    .catch(function(error) {
      console.error('Error fetching data:', error);
      return [];
    });
}



// Function to shift the data in df based on certain conditions
function shiftData(df) {
  for (var i = 0; i < df.shape[0]; i++) {
    if (df.isna(df.at(i, 4))) {
      df.shift(i, -2);
    }
  }

  for (var i = 1; i < df.shape[0]; i++) {
    if (df.isna(df.at(df.index[i], 'TrgID'))) {
      df.data[i][1] = df.at(i - 1, 'TrgID');
    }
  }
}



// Function to process data from url1 and url2
function processData(url1, overallArr) {
  return fetch(url1)
    .then(function(response) {
      if (!response.ok) {
        throw new Error('Network response was not ok.');
      }
      return response.text();
    })
    .then(function(content) {
      var lines = content.trim().split('\n').slice(11); // Skip first 8 rows
      var header = lines[0].trim().split(/\s+/); // Assuming the first line is the header

      var data = lines.slice(1).filter(function(line) { return line.trim() !== ''; }).map(function(line) {
        var values = line.trim().split(/\s+/);
        
        for (var i = 0; i < header.length; i++) {
          if (values[i] === undefined) {
            values[i] = null; // Replace empty values with null
          }
        }
        return values;
      });

      var df = {
        data: data,
        shape: [data.length, header.length],
        index: Array.from({ length: data.length }, function(_, i) { return i; }),
        columns: header,
        T: function() {
          var transposed = this.data[0].map(function(_, columnIndex) {
            return this.data.map(function(row) {
              return row[columnIndex];
            });
          }, this);
          var transposedHeader = this.columns.map(function(_, i) {
            return this.data[0][i];
          }, this);
          this.data = transposed; // Exclude the header row
          return this;
        },
        shift: function(columnIndex, shiftAmount) {
          var columnData = this.data[columnIndex];
          var shiftedArray = columnData.slice(0); // Create a copy of the original array

          if (shiftAmount > 0) {
            for (var i = 0; i < shiftAmount; i++) {
              var element = shiftedArray.shift(); // Remove the first element and store it
              shiftedArray.push(element); // Add the element at the end of the array
            }
          } else if (shiftAmount < 0) {
            for (var i = 0; i < -shiftAmount; i++) {
              var element = shiftedArray.pop(); // Remove the last element and store it
              shiftedArray.unshift(element); // Add the element at the beginning of the array
            }
          }

          this.data[columnIndex] = shiftedArray;
          return this;
        },
        at: function(rowIndex, columnName) {
          var columnIndex;
          if (typeof columnName === 'string') {
            columnIndex = this.columns.indexOf(columnName);
          } else {
            columnIndex = columnName;
          }
          return this.data[rowIndex][columnIndex];
        },
        isna: function(num) {
          return num === null;
        }
      };

      shiftData(df);
      console.log(df);

      var id = 0;
      var i = 0;
      while (id <= parseInt(df.at(df.index[df.shape[0] - 1], 'TrgID'))) {
        x.push(Array.from({ length: 3 }, function() { return Array.from({ length: 28 }, function() { return 0; }); }));
        y.push(Array.from({ length: 3 }, function() { return Array.from({ length: 28 }, function() { return 0; }); }));

        while (i < df.shape[0] && parseInt(df.at(df.index[i], 'TrgID')) == id) {
          var brd = parseFloat(df.at(df.index[i], 'Brd'));
          var ch = parseInt(df.at(df.index[i], 'Ch'));
          var lg = parseFloat(df.at(df.index[i], 'LG'));

          if (brd % 2 === 0) {
            x[id][Math.floor(brd / 2)][ch] = lg;
          } else {
            y[id][Math.floor((brd - 1) / 2)][ch] = lg;
          }

          i++;
        }

        id++;
      }
      console.log("x: ", x);
      
      var minPed = 10;

      subtractPedX = x;
      subtractPedY = y;

      for (var x1 = 0; x1 < x.length; x1++) {
        for (var y1 = 0; y1 < x[0].length; y1++) {
          for (var z1 = 0; z1 < x[0][0].length; z1++) {
            subtractPedX[x1][y1][z1] = subtractPedX[x1][y1][z1] - parseInt(overallArr[x1][y1 * 2 + 1][z1]);
            if (subtractPedX[x1][y1][z1] < minPed) {
              subtractPedX[x1][y1][z1] = 0;
            }
          }
        }
      }
    
      console.log("subtractPedX: ", subtractPedX);
      
      console.log("subtractPedY: ", subtractPedY);
      
      processGeometry();
    
  });
}



function processGeometry(){
  
  fetch(geometryURL)
  .then(function(response) {
    return response.text();
  })
  .then(function(data) {
    //console.log('Fetched data:', data); // Debug: Output the fetched data to the console

    // Process the data as needed
    var lines = data.split(/\r?\n/); // Use regex to handle different line endings
    //console.log(lines);
    
    var i = 11;
    while (i < lines.length && (lines[i].substring(0, 3) === 'ATH' || lines[i].substring(5, 10) === 'Layer')) {
      geometry.push(lines[i].split(/\s+/)); 
      //console.log('Parsed Geometry:', geometry); 
      i++;
    }
    
    console.log(geometry);
    graph();
    
    
    // Use the geometry data as needed
    // Debug: Output the parsed geometry to the console
    // You can process the geometry data further or perform other operations here.
  })
  .catch(function(error) {
    console.error('Error fetching data:', error);
  });

  
}



fetch(url2)
  .then(function(response) {
    if (!response.ok) {
      throw new Error('Network response was not ok.');
    }
    return response.text();
  })
  .then(function(content) {
    var lines = content.trim().split('\n');
    var overallArr = [];
    var ped = [[], [], [], [], [], [], []];
    ped[0] = lines[0].trim().split(' ');

    var mod = 0;
    for (var r = 1; r < lines.length; r++) {
      if (lines[r].startsWith('ATH')) {
        overallArr.push(ped);
        ped = [[], [], [], [], [], [], []];
        ped[0] = lines[r].trim().split(' ');
        
        mod = 0;
      }
      if (lines[r].startsWith('Mod')) {
        r++;
        mod++;
      }
      ped[mod] = ped[mod].concat(lines[r].trim().split(' '));
      
    }
    overallArr.push(ped);
    
    processData(url1, overallArr);
    
    
  
    
  })
  .catch(function(error) {
    console.error('Error fetching data:', error);
  });


function addArrays(arr1, arr2) {

  var result = [];

  for (var i = 0; i < arr1.length; i++) {
    if(i < arr2.length){
      result.push(arr1[i] + arr2[i]);
  }else{
      result.push(arr1[i])
  }
  }
console.log("Value: ", result);
  return result;
}

function populateX(letter, layer){
  var vals = Array(28).fill(0);
  var pedastal =subtractPedX;
  for(var a = 0; a < pedastal.length; a++){
  var modPed = pedastal[a][layer].slice(0, 28).map(function(value) {
    return value > 0 ? 1 : value;
  });
    vals = addArrays(vals, modPed)
  }
  return vals;
}

/*function popXADR(letter, layer){
  var vals = Array(27).fill(0);
  for(var a = 0; a< subtractPedX.length; a++){
    vals = addArrays(vals, subtractPedX[a]);
  }
  return vals;
}*/




function popXADR(layer) {
      var vals = [];
      for (var event = 0; event < subtractPedX.length; event++) {
        for(var channel = 1; channel < subtractPedX[event][layer].length; channel++){
          if(subtractPedX[event][layer][channel-1]>0 &&subtractPedX[event][layer][channel]>0){
            var xCord = channel - 1;
            var yCord = (subtractPedX[event][layer][channel-1]+ subtractPedX[event][layer][channel]);
        
            vals.push({ x: xCord, y: yCord});
          }
        }
          
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
      return vals;
    }


function populateY(letter, layer){
  var vals = Array(48).fill(0);
  var pedastal =  subtractPedY;
  for(var a = 0; a < pedastal.length; a++){
  var modPed = pedastal[a][layer].slice(0, 48).map(function(value) {
    return value > 0 ? 1 : value;
  });
    vals = addArrays(vals, modPed)
  }
  return vals;
}


function graph() {
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
  
var xLabels = [];
for(var i = 0; i < 28; i++){
  xLabels.push('Channel ' + i.toString());
}
var xADRLabels = [];
for(var i = 1; i <= 28; i++){


    xADRLabels.push('Channel ' + (i-1).toString() + " & " + i.toString());
  
}
  
var yADRLabels = [];
for(var i = 1; i <= 48; i++){


    yADRLabels.push('Channel ' + (i-1).toString() + " & " + i.toString());
  
}
  
var yLabels = [];
for(var i = 0; i < 48; i++){
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


  
console.log(subtractPedX);
  
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

console.log(popXADR(0));
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
              max: 28,
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
              max: 28,
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
              max: 28,
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
              max: 48,
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
              max: 48,
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
              max: 48,
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


