/*
	Edit Peronja 23/10/2025: This script is invoked when a new data file is selected.
*/
var xCoord = [];
var yCoord = [];
var subtractPedX = [];
var subtractPedY = [];
var adcmap = [];
var geometry = [];
var pedestal = [];
var detectorName = "";
var layerMaxSize = 64;
// Ensure these variables exist in this module scope to avoid ReferenceError when assigned inside functions
var x = [];
var y = [];
let debugRead = false;
globalThis.eventTime = [];
globalThis.adcmapArr = [];
globalThis.pedestalArr = [];
globalThis.geometryArr = [];
globalThis.selectedFile = "";
globalThis.selectedFileClean = "";
globalThis.pedestalFile = ""; 
globalThis.geometryFile = ""; 
globalThis.adcmapFile = "";
globalThis.selectedFileDate = "";
globalThis.conversionComments = "";
globalThis.runNumber = "";
globalThis.midPed = 0;
globalThis.eventFilter6 = [];
globalThis.eventFilter5 = [];
globalThis.eventFilter4 = [];
globalThis.showTime = false;

// Clean the headers
function cleanFile(arr, type) {
 	var temp = []
 	for (var ndx=0; ndx < arr.length; ndx++ ) {		
		// eliminate empty lines and comment lines
		if (arr[ndx] != "" && !arr[ndx].startsWith("//")) {
			if (arr[ndx].substring(0, 3) === 'ATH' && type === "DATAFILE") {
				document.getElementById("detector-name").value = arr[ndx].trim();
				detectorName = arr[ndx].trim();
				var parts = arr[ndx].split(" ");
				if (isNumeric(parts[1].trim())) {
					globalThis.runNumber = parts[1];
					document.getElementById("run-number").value = globalThis.runNumber;					
				}	
			} else if (arr[ndx].startsWith("COMMENTS")){
				globalThis.conversionComments = arr[ndx];
				//console.log(globalThis.conversionComments);
			} else {
				temp.push(arr[ndx]);
			}
		}	
 	}
 	return temp;
}//end of cleanFile

// Determine correct data based on timestamps
function retrieveTimedData(fileName, completeArr, type) {
	var timestamps = [];
	var detector = fileName.trim().split(' ');
	// function-scoped flag used to stop once we've found the correct module
	let done;
	if (type === "ADCMAP") {
		timestamps = [];
		done = false;
		for (var i = 0; i < completeArr.length; i++) {
			if (completeArr[i][0][0][0] === detector[0]) {
				//console.log(detector[0]);
				let gDate = parseFileDate(completeArr[i][0][0][1], completeArr[i][0][0][2]);
			    let dDate = parseFileDate(detector[2], detector[3]);
				if (dDate > gDate && !done) {
					var completeMod = completeArr[i][1].concat(completeArr[i][2], completeArr[i][3],completeArr[i][4])
					timestamps.push(completeMod);
					if (completeArr[i][0][1] === "Mod5") {
						done = true;
					}				
				}
			}
		}
 	return timestamps;
	}
	if (type === "PEDESTAL") {
		timestamps = [];
		done = false;
		for (var i = 0; i < completeArr.length; i++)  {
			if (completeArr[i][0][0][0] === detector[0]) {
				let gDate = parseFileDate(completeArr[i][0][0][1], completeArr[i][0][0][2]);
			    let dDate = parseFileDate(detector[2], detector[3]);
				if (dDate > gDate && !done) {
					var completeMod = completeArr[i][1].concat(completeArr[i][2], completeArr[i][3],completeArr[i][4])
					timestamps.push(completeMod);
					if (completeArr[i][0][1] === "Mod5") {
						done = true;
					}
				}
			}
		}
 	return timestamps;
   }
}// end of retrieveTimedData

// Retrieve the correct adc mapping
function getADCPosition(mod, channel, adcmap) {
	var mapPosition = 0;
	for (var i = 0; i < adcmap[mod].length; i++) {
		if (Math.floor(adcmap[mod][i]) > 0 && (channel+1) === Math.floor(adcmap[mod][i])) {
			mapPosition = i+1;
		}
	}
	return mapPosition;
}	
// Retrieve the correct pedestal value
function getPedestalValue(mod, channel, pedestal) {
	var pedestalValue = 0;
	for (var i = 0; i < pedestal[mod].length; i++) {
		if (i == channel) {
			pedestalValue = Math.floor(pedestal[mod][i]);
		}
	}
	return pedestalValue;
}	

// Read adcmap, pedestal and data file
globalThis.retrieveData = function () {
  return new Promise((resolve, reject) => {
  // process data file selected from the menu
  var dataUrl = globalThis.selectedFile;
  x = [];
  y = [];
  eventTime = [];
  subtractPedX = [];
  subtractPedY = [];
  fetch(dataUrl)
    .then(function(response) {
      return response.text();
    })
    .then(function(data) {
      var start = new Date();
      var lines = data.trim().split(/\r\n|\n|\r/);
      var allLines = cleanFile(lines, "DATAFILE");
      // check that we have a detector name, date and time
      if (detectorName === "") {
        throw new Error('File does not have detector, date and time information:');
        reject();
      }
      var header = allLines[0].trim().split(/\s+/); // Assuming the first line is the header
      var data = allLines.slice(1).filter(function(line) {
        return line.trim() !== '';
      }).map(function(line) {
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
          //console.log(rowIndex,columnIndex);
          return this.data[rowIndex][columnIndex];
        },
        isna: function(num) {
          return num === null;
        }
      };
      //df contains headers from data in columns arrays
      //df contains all the data in the data array
      //df.shape[0] has the total number of data lines
      //df.shape[1] has the number of columns for each line

      // Cache frequently used references and header indices to speed up hot loops
      var dfData = df.data;
      var nRows = df.shape[0];
      var nCols = df.shape[1];
      var headerIndex = {};
      for (var h = 0; h < df.columns.length; h++) {
        headerIndex[df.columns[h]] = h;
      }

      // Keep original semantics: use df.at where code expects it, but avoid repeated expensive lookups elsewhere
      for (var i = 0; i < nRows; i++) {
        if (df.isna(df.at(i, 4))) {
          df.shift(i, -2);
        }
      }
      // this copies over the value in TrgID from the first row to all the rows
      if (nRows > 1) {
        for (var r = 1; r < nRows; r++) {
          if (df.isna(df.at(df.index[r], 'TrgID'))) {
            df.data[r][1] = df.at(r - 1, 'TrgID');
          }
        }
      }

      // retrieve the correct adcmap by checking the name and timestamp
      var adcmap = retrieveTimedData(detectorName, globalThis.adcmapArr, 'ADCMAP');
      if (debugRead === true) {
        console.log("correct adcmap");
        console.log(adcmap);
      }
      var pedestal = retrieveTimedData(detectorName, globalThis.pedestalArr, 'PEDESTAL');
      if (debugRead === true) {
        console.log("correct pedestal");
        console.log(pedestal);
      }

      if (debugRead === true) {
        console.log("data read");
        console.log(df);
      }

      // Precompute ADC position and pedestal lookup tables once (big win)
      var maxMods = 6; // code references mods 0..5
      var mapPosCache = [];
      var pedValCache = [];
      for (var m = 0; m < maxMods; m++) {
        mapPosCache[m] = new Array(layerMaxSize).fill(0);
        pedValCache[m] = new Array(layerMaxSize).fill(0);
        if (adcmap && adcmap[m]) {
          var arr = adcmap[m];
          for (var j = 0; j < arr.length; j++) {
            var v = Math.floor(arr[j]);
            if (v > 0 && (v - 1) < layerMaxSize) {
              mapPosCache[m][v - 1] = j + 1;
            }
          }
        }
        if (pedestal && pedestal[m]) {
          var parr = pedestal[m];
          for (var k = 0; k < Math.min(parr.length, layerMaxSize); k++) {
            pedValCache[m][k] = Math.floor(parr[k]);
          }
        }
      }

      //id needs to get the first event in the file which it was first assumed as zero
      //we need to read the first event number instead
      var id = 0;
      var iRow = 0;
      var dn = detectorName.split(" ");
      var minPed = Math.floor(dn[dn.length-1]);
      globalThis.minPed = minPed;

      // Cache column indices used in the main loop to avoid string lookup each iteration
      var trgIdx = headerIndex['TrgID'];
      var brdIdx = headerIndex['Brd'];
      var chIdx = headerIndex['Ch'];
      var lgIdx = headerIndex['LG'];
      var tstampIdx = headerIndex['Tstamp_us'];

      // compute last trigger once
      var lastTrg = parseInt(df.at(df.index[nRows - 1], 'TrgID'));
      while (id <= lastTrg) {
        //initialize to zeros
        globalThis.eventTime.push(Array.from({ length: 6 }, function() { return 0; }));
        x.push(Array.from({ length: 3 }, function() {return Array.from({ length: layerMaxSize }, function() { return [0,0,0,0]; });}));
        y.push(Array.from({ length: 3 }, function() {return Array.from({ length: layerMaxSize }, function() { return [0,0,0,0]; });}));
        subtractPedX.push(Array.from({ length: 3 }, function() {return Array.from({ length: layerMaxSize }, function() { return 0; });}));
        subtractPedY.push(Array.from({ length: 3 }, function() {return Array.from({ length: layerMaxSize }, function() { return 0; });}));
        var countPerEvent = 0;
        var countX = 0;
        var countY = 0;
        // Initialize arrays with adcmap information
        // Use cached lookup tables instead of calling getADCPosition/getPedestalValue for every id
        for (var ndx = 0; ndx < layerMaxSize; ndx++) {
          x[id][0][ndx][0] = mapPosCache[0][ndx] || 0;
          x[id][0][ndx][2] = pedValCache[0][ndx] || 0;
          x[id][1][ndx][0] = mapPosCache[2][ndx] || 0;
          x[id][1][ndx][2] = pedValCache[2][ndx] || 0;
          x[id][2][ndx][0] = mapPosCache[4][ndx] || 0;
          x[id][2][ndx][2] = pedValCache[4][ndx] || 0;
          y[id][0][ndx][0] = mapPosCache[1][ndx] || 0;
          y[id][0][ndx][2] = pedValCache[1][ndx] || 0;
          y[id][1][ndx][0] = mapPosCache[3][ndx] || 0;
          y[id][1][ndx][2] = pedValCache[3][ndx] || 0;
          y[id][2][ndx][0] = mapPosCache[5][ndx] || 0;
          y[id][2][ndx][2] = pedValCache[5][ndx] || 0;
        }
        // Collect the data from that that specific id within TrgID
        while (iRow < nRows && parseInt(df.at(df.index[iRow], 'TrgID')) == id) {
          var countHit = true;
          var row = dfData[iRow];
          var brd = parseFloat(row[brdIdx]);
          var ch = parseInt(row[chIdx]);
          var lg = parseFloat(row[lgIdx]);
          //if the Brd value is even, it goes to X
          if (brd % 2 === 0) {
            //need to make sure the correct board is filled in
            //some do not exist
            var newLg = lg - x[id][Math.floor(brd / 2)][ch][2];
            if (newLg < minPed) {
              newLg = 0;
              countHit = false;
            }
            x[id][Math.floor(brd / 2)][ch][1] = lg;
            x[id][Math.floor(brd / 2)][ch][3] = newLg;
            subtractPedX[id][Math.floor(brd / 2)][ch] = newLg;
            countX++;
            var tstampVal = parseFloat(row[tstampIdx]);
            if (tstampVal > 0) {
              var time = tstampVal;
              if (countHit) {
                if (globalThis.eventTime.includes(time)){
                  //do nothing
                } else {
                  globalThis.eventTime[id][brd] = time;
                }
              }
            }
          // else it goes to Y
          } else {
            var newLg = lg - y[id][Math.floor((brd - 1) / 2)][ch][2];
            if (newLg < minPed) {
              newLg = 0;
              countHit = false;
            }
            y[id][Math.floor((brd - 1) / 2)][ch][1] = lg;
            y[id][Math.floor((brd - 1) / 2)][ch][3] = newLg;
            subtractPedY[id][Math.floor((brd - 1) / 2)][ch] = newLg;
            countY++;
            var tstampVal = parseFloat(row[tstampIdx]);
            if (tstampVal > 0) {
              var time = tstampVal;
              if (countHit) {
                if (globalThis.eventTime.includes(time)){
                  //do nothing
                } else {
                  globalThis.eventTime[id][brd] = time;
                }
              }
            }
          }
          countPerEvent++;
          iRow++;
        }
        id++;
      }
      if (debugRead === true) {
        console.log("data is ready");
        console.log(globalThis.eventTime);
        console.log(x);
        console.log(y);
        console.log(subtractPedX);
        console.log(subtractPedY);
      }
      var end = new Date();
      if (globalThis.showTime) {
        console.log("Read initial data: "+calculateProcessTime(end,start)+" seconds"); 
      }
      globalThis.xCoord = x;
      globalThis.yCoord = y;
      globalThis.subtractPedX = subtractPedX;
      globalThis.subtractPedY = subtractPedY;
      resolve();
      })
      .catch(function(error) {
         console.error('Error fetching data:', error);         
         reject();

     });
    //}//end of if we find file or read
   });
}// end of retrieveData    

// Read the pedestal file
globalThis.retrievePedestal = function () {
  return new Promise((resolve, reject) => {
    var pedestalUrl = globalThis.pedestalFile.trim();
    // Fetch the content of the URL using the fetch API
    fetch(pedestalUrl)
      .then(function(response) {
        return response.text();
      })
      .then(function(data) {
        var lines = data.trim().split(/\r\n|\n|\r/);
        var allLines = cleanFile(lines, "PEDESTAL");
        var pedestalArr = [];
        var pedestal = [[], [], [], [], []];
        let pedName;
        let pedData;
        pedName = allLines[0].trim().split(' ');
        pedestal[0] = [pedName, allLines[1].trim()];	
        var pedNdx = 1;
        for (var r = 2; r < allLines.length; r++) {
		  if (allLines[r].startsWith('ATH')) {
            pedName = allLines[r].trim().split(' ');
          } 
          if (allLines[r].startsWith('Mod')) {
            pedestalArr.push(pedestal);
            pedestal = [[], [], [], [], []];
            pedestal[0] = [pedName, allLines[r].trim()];
            pedNdx = 1;
		  } 
		  if (startsWithNumber(allLines[r])) {
		  	pedData = allLines[r].trim().split(' ');
			pedestal[pedNdx] = pedData;
			pedNdx++;
		  }
        }
        pedestalArr.push(pedestal);
        globalThis.pedestalArr = pedestalArr;
		if (debugRead === true) {	        
	        console.log("Pedestal is ready");
	        console.log(pedestalArr);
	    }	
        resolve();
      })
      .catch(function(error) {
        console.error('Error fetching adcmap data:', error);
        reject();
      });
  });
}//end of retrievePedestal

// Read the adcmap file
globalThis.retrieveADCmap = function () {
  return new Promise((resolve, reject) => {
    var adcmapUrl = globalThis.adcmapFile.trim();
    // Fetch the content of the URL using the fetch API
    fetch(adcmapUrl)
      .then(function(response) {
        return response.text();
      })
      .then(function(data) {
        var lines = data.trim().split(/\r\n|\n|\r/);
        var allLines = cleanFile(lines, "ADCMAP");
        var adcmapArr = [];
        var adcmap = [[], [], [], [], []];
        var mapName = allLines[0].trim().split(' ');       
        adcmap[0] = [mapName, allLines[1].trim(), allLines[2].trim()];
		var modData = [];
		var modNdx = 1;
        for (var r = 3; r < allLines.length; r++) {
		  if (allLines[r].startsWith('ATH')) {
            mapName = allLines[r].trim().split(' ');
          } 
          if (allLines[r].startsWith('Mod')) {
            adcmapArr.push(adcmap);
            adcmap = [[], [], [], [], []];
            adcmap[0] = [mapName, allLines[r].trim(), allLines[r+1].trim()];
            modNdx = 1;
		  } 
		  if (startsWithNumber(allLines[r])) {
		  	modData = allLines[r].trim().split(' ');
			adcmap[modNdx] = modData;
			modNdx++;
		  }

        }
        adcmapArr.push(adcmap);
        globalThis.adcmapArr = adcmapArr;
	    if (debugRead === true) {        
        	console.log("ADCMap is ready");
        	console.log(adcmapArr);
        }
        resolve();
      })
      .catch(function(error) {
        console.error('Error fetching adcmap data:', error);
        reject();
      });
  });
}//end of retrieveADCmap

// Read the geometry file
globalThis.retrieveGeometry = function () {
  return new Promise((resolve, reject) => {
    var geometryUrl = globalThis.geometryFile.trim();
    var up;
    // Fetch the content of the URL using the fetch API
    fetch(geometryUrl)
      .then(function(response) {
        return response.text();
      })
      .then(function(data) {
        // Process the data as needed
        var lines = data.split(/\r\n|\n|\r/); // Use regex to handle different line endings
        geometry = [];
        var singleGeometry = [];
        var addDetails = false;
        for (var i = 0; i < lines.length; i++) {
		  if (lines[i].substring(0, 3) === 'ATH') {
			if (singleGeometry.length > 0) {
				geometry.push(singleGeometry);
				singleGeometry = [];
			}
			singleGeometry.push(lines[i].split(/\s+/));	
			addDetails = true;
		  }
	      if (lines[i].substring(5, 10) === 'Layer' && addDetails === true) {
          	singleGeometry.push(lines[i].split(/\s+/)); 
          }
        }
		globalThis.geometryArr = geometry;
        if (debugRead === true) {
	        console.log("Geometry is ready");
	        console.log(geometry);
	    }
        resolve();
      })
      .catch(function(error) {
        console.error('Error fetching geometry data:', error);
        reject();
      });
  });
}//end of retrieveGeometry
