var x = [];
var y = [];
var canvas = document.getElementById('myCanvas');
var ctx = canvas.getContext('2d');
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
    draw(0);

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


function updateInputValue() {
  var inputValue = inputElement.value;
  console.log("Input value:", inputValue);
  draw(inputValue-1);

  
}

// Add an event listener to the input element
inputElement.addEventListener("input", updateInputValue);



function drawLine(x1, y1, x2, y2, extensionLength) {

  // Calculate the length and angle of the original line
  var originalLength = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
  var angle = Math.atan2(y2 - y1, x2 - x1);

  // Calculate the new end points based on the extensionLength and the angle
  var newX2 = x2 + extensionLength * Math.cos(angle);
  var newY2 = y2 + extensionLength * Math.sin(angle);
  var newX1 = x1 - 0.5*(newX2 - x2); // Adjust x1 based on the extension
  var newY1 = y1 - 0.5*(newY2 - y2); // Adjust y1 based on the extension
  ctx.strokeStyle = 'rgba(55, 255, 100,1)';
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.beginPath();
  ctx.moveTo(newX1, newY1);
  ctx.lineTo(newX2, newY2);
  ctx.lineWidth = 2;
  ctx.stroke();
}



function drawTriangle(dir, xpos, y, size, inten) {

      if(isNaN(inten)){
        inten = 0;
      }
      ctx.beginPath();
      ctx.moveTo(xpos, y);
      ctx.setTransform(1, 0, 0, 1, xpos, y);
      ctx.rotate(dir ? 0 : Math.PI / 3);
      
      ctx.fillStyle = 'rgba(255, 50, 100,' + inten + ')';
      ctx.lineWidth = 2;
      ctx.moveTo(0, 0);
      ctx.lineTo(size, 0);
      ctx.lineTo(size / 2, -Math.sqrt(3) * size / 2);
      ctx.closePath();
      
      if(inten == 0){
        ctx.fillStyle = 'rgba(255, 255, 255, 1 )';
      }else{
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.font = '15px Arial';
        ctx.fillStyle = 'rgba(0, 0, 0, 1)';
        ctx.fillText(Math.round(inten*300), xpos + size/2, dir ? y + size / 2: y - size / 3);
        ctx.fillStyle = 'rgba(255, 50, 100,' + inten + ')';
        ctx.setTransform(1, 0, 0, 1, xpos, y);
      }
      ctx.fill();
      ctx.strokeStyle = 'black'; // Set the border color to black
      ctx.stroke();
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      
    }


function drawPoint(x, y, pointSize) {
  ctx.beginPath();
  ctx.arc(x, y, pointSize / 2, 0, 2 * Math.PI);
  ctx.fillStyle = 'black'; // Color of the point (you can use any valid CSS color)
  ctx.fill();
}

function drawX(event, up, size){

    var layer = 0;
    var channel = 0;


// Read the value of the input
  
    
  var layerAct = [[],[],[]];

    
    for (var yp = 70; yp <= 360; yp += 130) {
      for (var xp = 255; xp < 745; xp += size) {
        if(up){
        console.log("UPPPPPP");
        console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedX[event][layer][channel]);
        drawTriangle(true, up ? xp - (size/2) : xp+(size/2), yp+size +3, size, subtractPedX[event][layer][channel]/300);
        if(subtractPedX[event][layer][channel] > 10){
          layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , subtractPedX[event][layer][channel]]);
          
        }
        channel++;
        console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedX[event][layer][channel]);
        drawTriangle(false, xp, yp, size, subtractPedX[event][layer][channel]/300);
        
        if(subtractPedX[event][layer][channel] > 10){
          layerAct[layer] .push([xp , subtractPedX[event][layer][channel]]);
        }
        channel++;
        }else{
          
          console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedX[event][layer][channel]);
          drawTriangle(false, xp, yp, size, subtractPedX[event][layer][channel]/300);
          if(subtractPedX[event][layer][channel] > 10){
          layerAct[layer].push([xp , subtractPedX[event][layer][channel]]);
        }
          channel++;
          console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedX[event][layer][channel]);
          drawTriangle(true, up ? xp - (size/2) : xp+(size/2), yp+size +3, size, subtractPedX[event][layer][channel]/300);
          if(subtractPedX[event][layer][channel] > 10){
          layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , subtractPedX[event][layer][channel]]);
        }
          channel++;
        }
        
        
      }
      channel = 0;
      layer++;
      
      
      
    lineRoute(layerAct, size, 350, 88);
      
    }
  
  
  
}


function drawY(event, up, size){


  
    var layer = 0;
    var channel = 0;


// Read the value of the input
  
    
  var layerAct = [[],[],[]];

    
    for (var yp = 450; yp <= 710; yp += 130) {
      for (var xp = 80; xp < 920; xp += size) {
        if(up){
        console.log("UPPPPPP");
        console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedY[event][layer][channel]);
        drawTriangle(true, up ? xp - (size/2) : xp+(size/2), yp+size +3, size, subtractPedY[event][layer][channel]/300);
        if(subtractPedY[event][layer][channel] > 10){
          layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , subtractPedY[event][layer][channel]]);
          
        }
        channel++;
        console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedY[event][layer][channel]);
        drawTriangle(false, xp, yp, size, subtractPedY[event][layer][channel]/300);
        
        if(subtractPedY[event][layer][channel] > 10){
          layerAct[layer] .push([xp , subtractPedY[event][layer][channel]]);
        }
        channel++;
        }else{
          
          console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedY[event][layer][channel]);
          drawTriangle(false, xp, yp, size, subtractPedY[event][layer][channel]/300);
          if(subtractPedY[event][layer][channel] > 10){
          layerAct[layer].push([xp , subtractPedY[event][layer][channel]]);
        }
          channel++;
          console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedY[event][layer][channel]);
          drawTriangle(true, up ? xp - (size/2) : xp+(size/2), yp+size +3, size, subtractPedY[event][layer][channel]/300);
          if(subtractPedY[event][layer][channel] > 10){
          layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , subtractPedY[event][layer][channel]]);
        }
          channel++;
        }
        
        
      }
      channel = 0;
      layer++;
      
     lineRoute(layerAct, size, 730, 470);
    
      
      
      
    }
  
  
}

function lineRoute(layerAct, size, lTop, lBot){
   
      console.log("Layer act: ", layerAct);
      var x1 = [];
      var totalN = 0;
      var totalD = 0;
      for(var i = 0; i < layerAct[0].length; i++){
        if(i>0 && Math.abs(layerAct[0][i][0]-layerAct[0][i-1][0])!=17.5){
          x1.push(Math.round(totalN/totalD));
          console.log("Value: ",Math.round(totalN/totalD) );
          console.log("Reason: ",layerAct[0][i][0]-layerAct[0][i-1][0]);
          
          totalN = 0;
          totalD = 0;
        }
        totalN += layerAct[0][i][0] * layerAct[0][i][1];
        totalD += layerAct[0][i][1];
      }
      if(totalN != 0){
        x1.push(Math.round(totalN/totalD));
      }
      console.log("Value: ",Math.round(totalN/totalD) );
      console.log(layerAct);
      console.log("x1:", x1);


      var x2 = [];
      totalN = 0;
      totalD = 0;

      for(var i = 0; i < layerAct[2].length; i++){
        if(i>0 && Math.abs(layerAct[2][i][0]-layerAct[2][i-1][0])!=17.5){
          x2.push(Math.round(totalN/totalD));
          console.log("Occured")
          totalN = 0;
          totalD = 0;
        }
        totalN += layerAct[2][i][0] * layerAct[2][i][1];
        totalD += layerAct[2][i][1];
      }
      if(totalN != 0){
        x2.push(Math.round(totalN/totalD));
      }
      console.log(layerAct);
      console.log("x2:", x2);
      
      
      for(var a = 0; a < x1.length; a++){
        for(var b = 0; b < x2.length; b++){
       //drawPoint(x1[a]+(size/2), lBot, 20);
        // drawPoint(x2[b]+(size/2), lTop, 20);
        drawLine(x1[a]+(size/2), lBot, x2[b]+(size/2), lTop, 80);
      }
      }
      
}

function draw(event){
  var up = !geometry[1][1] === "Tree";
  var size = 35;
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  console.log(subtractPedY[0][0][0]);
  drawY(event, up, size);
  
  drawX(event, up, size);
  
  ctx.font = 'italic 25px Arial';
  ctx.textAlign = 'center';
  ctx.fillStyle = 'rgba(0, 0, 0, 1 )'
  ctx.fillText('X-view display - find muon track with 3 planes', canvas.width / 2, 30);
  ctx.fillText('Y-view display - find muon track with 3 planes', canvas.width / 2, 420);
  
  
  
  
}

