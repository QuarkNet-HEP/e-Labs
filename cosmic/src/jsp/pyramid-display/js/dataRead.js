var xCoord = [];
var yCoord = [];
var subtractPedX = [];
var subtractPedY = [];
var adcmap = [];
var geometry = [];
var pedestal = [];
var detectorName = "";
var layerMaxSize = 64;
globalThis.adcmapArr = [];
globalThis.pedestalArr = [];
globalThis.geometryArr = [];
globalThis.selectedFile = "";
globalThis.pedestalFile = ""; 
globalThis.geometryFile = ""; 
globalThis.adcmapFile = "";
globalThis.selectedFileDate = "";
globalThis.midPed = 0;
let debugRead = false;

// helper function to clean the headers
function cleanFile(arr, type) {
 	var temp = []
 	for (var ndx=0; ndx < arr.length; ndx++ ) {		
		// eliminate empty lines and comment lines
		if (arr[ndx] != "" && !arr[ndx].startsWith("//")) {
			if (arr[ndx].substring(0, 3) === 'ATH' && type === "DATAFILE") {
				document.getElementById("detector-name").value = arr[ndx].trim();
				detectorName = arr[ndx].trim();
			} else {
				temp.push(arr[ndx]);
			}
		}	
 	}
 	return temp;
}
// helper function to determine if line starts with a number
function startsWithNumber(str) {
	return /^\d+\b/.test(str);
}

//let months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
function parseFileDate(d, t) {
	let day = d.substring(0,2);
	let month = d.substring(2,5);
	let M = months.indexOf(month);
	let y = d.substring(5,9);
	let [h,m,s] = t.split(/[- :]/);
	let newDate =  new Date(parseInt(y),M,parseInt(d),parseInt(h),parseInt(m),parseInt(s));
	return newDate;
}// end of parseFileDate

// helper function to determine correct data based on timestamps
function retrieveTimedData(fileName, completeArr, type) {
	var timestamps = [];
	var detector = fileName.trim().split(' ');	
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

// helper function to retrieve the correct adc mapping
function getADCPosition(mod, channel, adcmap) {
	var mapPosition = 0;
	for (var i = 0; i < adcmap[mod].length; i++) {
		if (Math.floor(adcmap[mod][i]) > 0 && (channel+1) === Math.floor(adcmap[mod][i])) {
			mapPosition = i+1;
		}
	}
	return mapPosition;
}	
// helper function to retrieve the correct pedestal value
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
      for (var i = 0; i < df.shape[0]; i++) {
        if (df.isna(df.at(i, 4))) {
          df.shift(i, -2);
        }
      }
	  // this copies over the value in TrgID from the first row to all the rows
      for (var i = 1; i < df.shape[0]; i++) {
        if (df.isna(df.at(df.index[i], 'TrgID'))) {
         df.data[i][1] = df.at(i - 1, 'TrgID');
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
      //id needs to get the first event in the file which it was first assumed as zero
      //we need to read the first event number instead
      var id = 0;
      var i = 0;
      var dn = detectorName.split(" ");
      var minPed = Math.floor(dn[dn.length-1]);
      globalThis.minPed = minPed;

      while (id <= parseInt(df.at(df.index[df.shape[0] - 1], 'TrgID'))) {
		//initialize to zeros
		eventTime.push(Array.from({ length: 6 }, function() { return 0; }));
        x.push(Array.from({ length: 3 }, function() {return Array.from({ length: layerMaxSize }, function() { return [0,0,0,0]; });}));
        y.push(Array.from({ length: 3 }, function() {return Array.from({ length: layerMaxSize }, function() { return [0,0,0,0]; });}));
        subtractPedX.push(Array.from({ length: 3 }, function() {return Array.from({ length: layerMaxSize }, function() { return 0; });}));
        subtractPedY.push(Array.from({ length: 3 }, function() {return Array.from({ length: layerMaxSize }, function() { return 0; });}));
        var countPerEvent = 0;
        var countX = 0;
        var countY = 0;
        // Initialize arrays with adcmap information
		// Need to un-hardcode this
        for (ndx = 0; ndx < layerMaxSize; ndx++) {
			x[id][0][ndx][0] = getADCPosition(0,ndx, adcmap);
			x[id][0][ndx][2] = getPedestalValue(0,ndx, pedestal);
			x[id][1][ndx][0] = getADCPosition(2,ndx, adcmap);
			x[id][1][ndx][2] = getPedestalValue(2,ndx, pedestal);
			x[id][2][ndx][0] = getADCPosition(4,ndx, adcmap);
			x[id][2][ndx][2] = getPedestalValue(4,ndx, pedestal);
			y[id][0][ndx][0] = getADCPosition(1,ndx, adcmap);
			y[id][0][ndx][2] = getPedestalValue(1,ndx, pedestal);
			y[id][1][ndx][0] = getADCPosition(3,ndx, adcmap);
			y[id][1][ndx][2] = getPedestalValue(3,ndx, pedestal);
			y[id][2][ndx][0] = getADCPosition(5,ndx, adcmap);
			y[id][2][ndx][2] = getPedestalValue(5,ndx, pedestal);
        }
        // Collect the data from that that specific id within TrgID
        while (i < df.shape[0] && parseInt(df.at(df.index[i], 'TrgID')) == id) {
          var brd = parseFloat(df.at(df.index[i], 'Brd'));
          var ch = parseInt(df.at(df.index[i], 'Ch'));
          var lg = parseFloat(df.at(df.index[i], 'LG'));
          //if the Brd value is even, it goes to X
          if (brd % 2 === 0) {
			//need to make sure the correct board is filled in
			//some do not exist
			newLg = lg - x[id][Math.floor(brd / 2)][ch][2];
			if (newLg < minPed) {
				newLg = 0;
			}
            x[id][Math.floor(brd / 2)][ch][1] = lg;
			x[id][Math.floor(brd / 2)][ch][3] = newLg;
            subtractPedX[id][Math.floor(brd / 2)][ch] = newLg;
			countX++;
			if (parseFloat(df.at(df.index[i], 'Tstamp_us')) > 0) {
				var time = parseFloat(df.at(df.index[i], 'Tstamp_us'));
				eventTime[id][brd] = time;
			}
          // else it goes to Y
          } else {
			//console.log('y', id, brd, ch);
			newLg = lg - y[id][Math.floor((brd - 1) / 2)][ch][2];
			if (newLg < minPed) {
				newLg = 0;
			}
            y[id][Math.floor((brd - 1) / 2)][ch][1] = lg;				
            y[id][Math.floor((brd - 1) / 2)][ch][3] = newLg;				
            subtractPedY[id][Math.floor((brd - 1) / 2)][ch] = newLg;
			countY++;
			if (parseFloat(df.at(df.index[i], 'Tstamp_us')) > 0) {
				var time = parseFloat(df.at(df.index[i], 'Tstamp_us'));
				eventTime[id][brd] = time;
			}
          }
		  countPerEvent++;
          i++;
		}
        id++;
      }
	  if (debugRead === true) {	      
	      console.log("data is ready");
		  console.log(eventTime);
	      console.log(x);
	      console.log(y);  
	      console.log(subtractPedX);
	      console.log(subtractPedY);  
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
}

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
}

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
}
