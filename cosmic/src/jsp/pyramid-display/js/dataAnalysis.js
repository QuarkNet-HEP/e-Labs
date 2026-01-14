/*
	Edit Peronja 23/10/2025: all these functions analyze the data generated in dataAnalysisDataPreparation.js
							 and return values for dataCharts.js
*/

let debugAnalysis = false;
let debugFunction = false; //turn on for Mark's review
var xLayerLength = 0;
var yLayerLength = 0;
var microMinute = 60000000;

// Populate first 6 charts
var xLayerLength = 0;
var yLayerLength = 0;
var geometry = '';
var layers = [];
var dx = [];
var dy = [];
var dxtopmiddle = [];
var dytopmiddle = [];
var dxtopmiddlebothlayers = [];
var dytopmiddlebothlayers = [];
var dxbottommiddle = [];
var dybottommiddle = [];
var dxbottommiddlebothlayers = [];
var dybottommiddlebothlayers = [];
var dxbothlayers = [];
var dybothlayers = [];
var microMinute = 60000000;


function populateX(letter, layer){
  	var vals = Array(xLayerLength).fill(0);
  	var pedestal = subtractPedX;
  	for(var a = 0; a < pedestal.length; a++) {
  		var modPed = pedestal[a][layer].slice(0, xLayerLength).map(function(value) {
    	return value > 0 ? 1 : value;
  		});
    	vals = addArrays(vals, modPed);
  	}
	if (debugAnalysis === true) {
  		console.log("X Pedestal "+layer+letter);
  		console.log("values:", vals);
  	}  	
  	return vals;
}// end of populateX
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
}// end of populateY

// Get data for download from first 6 charts
function getCAENdata(arr, layer) {
	var vals = [];
	for(var a = 0; a < arr.length; a++) {
		vals.push(arr[a][layer]);		
	}
	return vals;
}// end of getCAENdata

//Used by populateX and populateY
}

//helper function used by populateX and populateY
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
}// end of addArrays

// TRACKING functions in the order they are called from drawCharts.js
// These following function analyze HITS
function get6planemiddlehits(arr) {
	var vals = [];
	console.log(arr.length);
	for (var i = 0; i < arr.length; i++) {
			//console.log(arr[i])
			vals.push({x:arr[i][1][1][0],y:arr[i][1][4][0],event: (arr[i][0]+1)});
			if (debugFunction) {
				console.log("6 plane hits: ",i,arr[i],arr[i][1][1],arr[i][1][4]);
				}
	}
	return vals;
}// end of get6planemiddlehits

function get6singlepoints(option, arr) {
	console.log(option,arr.length);
	var vals = [];
	for (var i = 0; i < arr.length; i++) {
		vals.push({x:arr[i][1][1][0],y:arr[i][1][4][0],event: (arr[i][0]+1)});				
	}
	//console.log(option,vals);
	return vals;
}//end of get6singlepoints

function get6singlepointsBothLayers(option, arr1) {
	var vals = [];
	console.log(option,arr1.length);
	for (var i = 0; i < arr1.length; i++) {
		vals.push({x:arr1[i][1][1][0],y:arr1[i][1][4][0],event: (arr1[i][0]+1)});
	}
	return vals;
}//end of get6singlepointsBothLayer

function getFrequency6ExpectedActualforHits(option, arr) {
	//console.log(option, arr);
	var diff = 0;
	var diffCollection = [];
	//for (var i = 0; i < arr.length; i++) {
	//	console.log(arr[i]);
	//}
	if (option == 'X') {
		for (var i = 0; i < arr.length; i++) {
			diff = arr[i][2].x3 - arr[i][1][1][0];
			diffCollection.push(diff);
		}
	}
	if (option == 'Y') {
		for (var i = 0; i < arr.length; i++) {
			diff = arr[i][3].x3 - arr[i][1][4][0];
			diffCollection.push(diff);
		}
	}
	//console.log(option, diffCollection);
	var binnedData = getBinnedData(diffCollection, 0.2);
	var result = [];
	for (var i = 0; i < binnedData.length; i++) {
		result.push({x:binnedData[i].binNum, y:binnedData[i].count});
	}
	//console.log("frequency for 6 plane hits: ", option, result);
	return result;
}//end of getFrequency6ExpectedActualforHits

function getDeltaXYforhits(option, arr) {
	var vals = [];
	//console.log(arr);
	for (var i = 0; i < arr.length; i++) {
		if (option == 'TB') {
			var deltax = arr[i][1][2][0] - arr[i][1][0][0];
			var deltay = arr[i][1][5][0] - arr[i][1][3][0];
			//console.log(arr, arr[i][0], arr[i][1][2], arr[i][1][0], deltax, deltay);
			vals.push({x:deltax, y:deltay, event: arr[i][0]+1});
		}
		if (option == 'TM') {
			var deltax = arr[i][1][2][0] - arr[i][1][1][0];
			var deltay = arr[i][1][5][0] - arr[i][1][4][0];
			//console.log(arr, arr[i][0], arr[i][1][2], arr[i][1][0], deltax, deltay);
			vals.push({x:deltax, y:deltay, event: arr[i][0]+1});
		}
		if (option == 'MB') {
			var deltax = arr[i][1][1][0] - arr[i][1][0][0];
			var deltay = arr[i][1][4][0] - arr[i][1][3][0];
			//console.log(arr, arr[i][0], arr[i][1][2], arr[i][1][0], deltax, deltay);
			vals.push({x:deltax, y:deltay, event: arr[i][0]+1});
		}
	}
	return vals;
}//end of getDeltaXYforhits

//These following functions analyze 6 plane X missed
function get6planemiddlemissed(arr, option) {
	var vals = [];
	//console.log("6 plane tracks: ",option,i,arr);
	for (var i = 0; i < arr.length; i++) {
		//there is only one missed, either X or Y
		//add expected x vs real y
		if (arr[i].length == 3) {
			if (option == 'X') {
				vals.push({x:arr[i][2].x3,y:arr[i][1][4][0],event: (arr[i][0]+1)});				
			}
			if (option == 'Y') {
				vals.push({x:arr[i][1][1][0],y:arr[i][2].x3,event: (arr[i][0]+1)});				
			}
		}
	
		if (arr[i].length == 4) {
			//there are missed points both in middle X and middle Y	
			//add expected x vs real y
			vals.push({x:arr[i][2].x3,y:arr[i][3].x3,event: (arr[i][0]+1)});
			//if (debugFunction) {
			//	console.log("6 plane tracks: ",i,option,arr[i],arr[i][2].x3,arr[i][1][4][0],arr[i][3].x3,arr[i][1][2][0]);
			//	}
		}	
	}
	return vals;
}// end of get6planemiddlemissed

function arrayMin(arr) {
  var len = arr.length, min = Infinity;
  while (len--) {
    if (Number(arr[len]) < min) {
      min = Number(arr[len]);
    }
  }
  return min;
};//end of arrayMin

function arrayMax(arr) {
  var len = arr.length, max = -Infinity;
  while (len--) {
    if (Number(arr[len]) > max) {
      max = Number(arr[len]);
    }
  }
  return max;
};//end of arrayMax

function getBinnedData(arr, intervalSize) {
	var bins = [];
	var binCount = 0;
	var interval = intervalSize;
	var arrayMinValue = arrayMin(arr)-intervalSize;
	var arrayMaxValue = arrayMax(arr)+intervalSize;

	//Setup Bins
	for(var i = arrayMinValue; i <= arrayMaxValue; i += interval){
	  bins.push({
	    binNum: i.toFixed(2),
	    minNum: i,
	    maxNum: i + interval,
	    count: 0
	  })
	  binCount++;
	}
	//Loop through data and add to bin's count
	var totalCount = 0;
	for (var i = 0; i < arr.length; i++){
	  var item = arr[i];
	  for (var j = 0; j < bins.length; j++){
	    var bin = bins[j];
	    if(item > bin.minNum && item <= bin.maxNum){
		  //console.log(item, bin.minNum, bin.maxNum);
	      bin.count++;
		  totalCount += 1;
	      break;  // An item can only be in one bin.
	    }
	  }  
	}	
	//console.log(intervalSize, arrayMinValue, arrayMaxValue)
	//for (var i = 0; i < bins.length; i++) {
	//	console.log(bins[i]);
	//}
	return bins;
}//end of getBinnedData

function getFrequency6ExpectedActual(option, arr1, arr2) {
	var diff = 0;
	var diffCollection = [];
	if (option == 'X') {
		for (var i = 0; i < arr1.length; i++) {
			diff = arr1[i][2].x3 - arr1[i][1][1][0];
			diffCollection.push(diff);
		}
		for (var i = 0; i < arr2.length; i++) {
			diff = arr2[i][2].x3 - arr2[i][1][1][0];
			diffCollection.push(diff);
		}
	}
	if (option == 'Y') {
		for (var i = 0; i < arr1.length; i++) {
			diff = arr1[i][2].x3 - arr1[i][1][4][0];
			diffCollection.push(diff);
		}
		for (var i = 0; i < arr2.length; i++) {
			diff = arr2[i][3].x3 - arr2[i][1][4][0];
			diffCollection.push(diff);
		}
	}
	//console.log(option, diffCollection);
	var binnedData = getBinnedData(diffCollection, 1.0);
	var result = [];
	for (var i = 0; i < binnedData.length; i++) {
		result.push({x:binnedData[i].binNum, y:binnedData[i].count});
	}
	return result;
}//end of getFrequency6ExpectedActual

//5 PLANE analysis: one of the layers is missing a hit
function getCountsBetween5(layer, option, arr, lowerbound, upperbound) {
	var totalCount = 0;
	if (layer == 'X') {
		if (option == 'TY') {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][1][0][0] >= lowerbound && arr[i][1][0][0] <= upperbound) {
					totalCount += 1;
				}
			}
		} else
		if (option == 'MY') {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][1][1][0] >= lowerbound && arr[i][1][1][0] <= upperbound) {
					totalCount += 1;
				}
			}
		} else		
		if (option == 'BY') {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][1][2][0] >= lowerbound && arr[i][1][2][0] <= upperbound) {
					totalCount += 1;
				}
			}
		} 				
		else {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][2].x3 >= lowerbound && arr[i][2].x3 <= upperbound) {
					totalCount += 1;
				}
			}
		}
	}
	if (layer == 'Y') {
		if (option == 'TX') {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][1][3][0] >= lowerbound && arr[i][1][3][0] <= upperbound) {
					totalCount += 1;
				}
			}
		} else
		if (option == 'MX') {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][1][4][0] >= lowerbound && arr[i][1][4][0] <= upperbound) {
					totalCount += 1;
				}
			}
		} else
		if (option == 'BX') {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][1][5][0] >= lowerbound && arr[i][1][5][0] <= upperbound) {
					totalCount += 1;
				}
			}
		} else {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][2].x3 >= lowerbound && arr[i][2].x3 <= upperbound) {
					totalCount += 1;
				}
			}			
		}
		
	}	
	return totalCount;
}//end of getCountsBetween5

function get5planemissing(arr, option) {
	var vals = [];
	if (option == 'TX') {
		for (var i = 0; i < arr.length; i++) {
			vals.push({x:arr[i][2].x3,y:arr[i][1][3][0],event: (arr[i][0]+1)});		
			if (debugFunction) {
				console.log("5 plane tracks: ", option, arr[i], arr[i][2].x3,arr[i][1][3][0]);
			}
		}
	}
	if (option == 'MX') {
		for (var i = 0; i < arr.length; i++) {
			vals.push({x:arr[i][2].x3,y:arr[i][1][4][0],event: (arr[i][0]+1)});		
			if (debugFunction) {
				console.log("5 plane tracks: ", option, arr[i], arr[i][2].x3,arr[i][1][4][0]);
			}
		}
	}
	if (option == 'BX') {
		for (var i = 0; i < arr.length; i++) {
			vals.push({x:arr[i][2].x3,y:arr[i][1][5][0],event: (arr[i][0]+1)});		
			if (debugFunction) {
				console.log("5 plane tracks: ", option, arr[i], arr[i][2].x3,arr[i][1][5][0]);
			}			
		}
	}
	
	if (option == 'TY') {
		for (var i = 0; i < arr.length; i++) {
			vals.push({x:arr[i][1][0][0],y:arr[i][2].x3,event: (arr[i][0]+1)});		
			if (debugFunction) {
				console.log("5 plane tracks: ", option, arr[i], arr[i][2].x3,arr[i][1][0][0]);
			}			
		}
	}
	if (option == 'MY') {
		for (var i = 0; i < arr.length; i++) {
			vals.push({x:arr[i][1][1][0],y:arr[i][2].x3,event: (arr[i][0]+1)});		
			if (debugFunction) {
				console.log("5 plane tracks: ", option, arr[i], arr[i][2].x3,arr[i][1][1][0]);
			}

		}
	}
	if (option == 'BY') {
		for (var i = 0; i < arr.length; i++) {
			vals.push({x:arr[i][1][2][0],y:arr[i][2].x3,event: (arr[i][0]+1)});		
			if (debugFunction) {
				console.log("5 plane tracks: ", option, arr[i], arr[i][2].x3,arr[i][1][2][0]);
			}
		}
	}
	return vals;	
}// end of get5planemissing

//4 PLANE analysis: one of the layers is missing a hit in both groups
function getCountsBetween4(layer, option, arr, lowerBound, upperBound) {
	var totalCount = 0;
	if (layer == 'X') {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][1].x3 >= lowerBound && arr[i][1].x3 <= upperBound) {
					totalCount += 1;
				}
			}						
	}
	if (layer == 'Y') {
			for (var i = 0; i < arr.length; i++) {
				if (arr[i][2].x3 >= lowerBound && arr[i][2].x3 <= upperBound) {
					totalCount += 1;
				}
			}						
	}
	return totalCount;
}//end of getCountsBetween4

function get4planemissing(arr, option) {
	var vals = [];
	for (var i = 0; i < arr.length; i++) {
		vals.push({x:arr[i][1].x3,y:arr[i][2].x3,event: (arr[i][0]+1)});		
		if (debugFunction) {
			console.log("4 plane tracks: ", option, arr[i], arr[i][1].x3,arr[i][2].x3);
		}
	}		
	return vals;
}//end of get4planemissing

//DELTA XY functions
function getDxDy(events) {
	var vals = [];
	var totalEvents = dxbothlayers.length;
	if (events > 0 && events <= dxbothlayers.length) {
		totalEvents = events;
	}
	for (var i = 0; i < totalEvents; i++) {
		//if (i < 5) {
		//	console.log(dxbothlayers[i],dybothlayers[i]);
		//}
		vals.push({x:dxbothlayers[i][4], y:dybothlayers[i][4]});
	}
	//console.log(vals);
	return vals;
}//end of getDxDy

function getDxDyMiddle(arrX, arrY, events) {
	var vals = [];
	var totalEvents = arrX.length;
	if (totalEvents > arrY.length) {
		totalEvents = arrY.length;
	}
	if (events > 0 && events <= arrX.length && events <= arrY.length) {
		totalEvents = events;
	}
	for (var i = 0; i < totalEvents; i++) {
		vals.push({x:arrX[i][4], y:arrY[i][4]});
	}
	return vals;
}//end of getDxDyMiddle

function calculateDeltaXDeltaYFrequency(arr, events, binWidth) {
	var deltaValues = [];
	var totalEvents = arr.length;
	if (events > 0 && events <= arr.length) {
		totalEvents = events;
	}
	for (let i = 1; i < totalEvents; i++) {
		deltaValues.push(arr[i][4]);
	}	
	// Find min and max values to determine the range
	var minVal = Math.min(...deltaValues);
	var maxVal = Math.max(...deltaValues);

	// Calculate bin boundaries
	var binBoundaries = [];
	for (let i = minVal; i <= maxVal + binWidth; i += binWidth) {
	    binBoundaries.push(i);
	}	
	
	// Initialize bins
	var bins = [];
	if (binBoundaries.length > 0) {
		bins = Array(binBoundaries.length - 1).fill(0);
	}
	// Populate bins
	deltaValues.forEach(value => {
	  for (let i = 0; i < binBoundaries.length - 1; i++) {
	    if (value >= binBoundaries[i] && value < binBoundaries[i + 1]) {
	      bins[i]++;
	      break;
	    }
	  }
	});

	var lineChartData = [];
	if (bins.length > 0) {
		for (let i = 0; i < bins.length; i++) {
		  var binCenter = (binBoundaries[i] + binBoundaries[i + 1]) / 2;
		  lineChartData.push({ x: binCenter, y: bins[i] }); 
		}		
	}
	return lineChartData;
}//end of calculateDeltaXDeltaYFrequency

//CHANNEL FREQUENCY
function getFrequency(arr1) {
	vals = [];
	var frequency = arr1.reduce((acc, num) => {
	  acc.set(num, (acc.get(num) || 0) + 1);
	  return acc;
	}, new Map());		

	for (const [n, f] of frequency.entries()) {
		vals.push({x:n,y:f});
	}	
	return vals;
}//end of getFrequency

function getChannelData(whichLayer, arr1, upperLimit, events) {
    var vals = [];
	var totalEvents = arr1.length;
	var layerNdx = 0;
	if (whichLayer == 'top') {
		layerNdx = 3;
	}
	if (whichLayer == 'middle') {
		layerNdx = 2;
	}
	if (whichLayer == 'bottom') {
		layerNdx = 1;
	}
	if (events > 0 && events <= arr1.length) {
		totalEvents = events;
	}
    for (var i = 0; i < totalEvents; i++) {		
        if (typeof arr1[i][layerNdx] != "undefined" && arr1[i][layerNdx].channel1 != -1) {
             if (arr1[i][layerNdx].channel1 > upperLimit) {
                  vals.push(upperLimit);
             } else {
                  vals.push(arr1[i][layerNdx].channel1);
             }
         }
         if (typeof arr1[i][layerNdx] != "undefined" && arr1[i][layerNdx].channel2 != -1) {
             if (arr1[i][layerNdx].channel2 > upperLimit) {
                  vals.push(upperLimit);
              } else {
                  vals.push(arr1[i][layerNdx].channel2);
              }
         }
    }
    return vals;
}//end of getChannelData

//DELTA XZ
function getDxDz(events) {
	var vals = [];
	var totalEvents = dxbothlayers.length;
	if (events > 0 && events <= dxbothlayers.length) {
		totalEvents = events;
	}
	for (var i = 0; i < totalEvents; i++) { 
		//if (i < 5) {
		//	console.log(dxbothlayers[i],dybothlayers[i], dxbothlayers[i][4]/dxbothlayers[i][5],dybothlayers[i][4]/dybothlayers[i][5] );
		//}
		vals.push({x:dxbothlayers[i][4]/dxbothlayers[i][5], y:dybothlayers[i][4]/dybothlayers[i][5]});
	}
	return vals;
}//end of getDxDz

function getDxyDzMiddle(arrX, arrY, events) {
	var vals = [];
	var totalEvents = arrX.length;
	if (events > 0 && events <= arrX.length) {
		totalEvents = events;
	}
	for (var i = 0; i < totalEvents; i++) {
		vals.push({x:arrX[i][4]/arrX[i][5], y:arrY[i][4]/arrY[i][5]});
	}
	return vals;
}//end of getDxyDzMiddle

//DELTA T 
function getDeltaT(index1, index2) {
	var vals = []
	for (var i = 0; i < eventTime.length; i ++) {
		var time1 = eventTime[i][index1];
		var time2 = eventTime[i][index2];
		if (time1 > 0 && time2 > 0) {
			vals.push({x:i, y:time2-time1});
		}
	}
	return vals;
}// end of getDeltaT

//TRACK COUNTS
function getEventsWithTracksPerMinute(layerCount, option) {
	var vals = [];
	var xtop = layerOrderX[2][2]*2;
	var xmiddle = layerOrderX[1][2]*2;
	var xbottom = layerOrderX[0][2]*2;
	var ytop = (layerOrderY[2][2]*2)+1;
	var ymiddle = (layerOrderY[1][2]*2)+1;
	var ybottom = (layerOrderY[0][2]*2)+1;
	var startTime = 0;
	var minuteTime = microMinute+eventTime[0][0];
	var trackCounter = 0;
	//console.log(eventTime);
	for (var i = 0; i < eventTime.length; i++) {		
		//check for top and bottom in both layers
		if (layerCount == 4) {
			if (option == 'TM') {
				if (eventTime[i][xtop] > 0 &&
					eventTime[i][xmiddle] > 0 &&
					eventTime[i][xbottom] <= 0 &&
					eventTime[i][ytop] > 0 &&
					eventTime[i][ymiddle] > 0 &&
					eventTime[i][ybottom] <= 0) {
					//check if it belongs within each minute
					if (eventTime[i][0] <= minuteTime) {
						if (debugEventsWithTracks) {
							console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
						}
						trackCounter += 1;
					} else {
						//console.log(layerCount, option, startTime, trackCounter);
						//save and move up a minute
						vals.push({x:startTime+1,y:trackCounter})
						startTime += 1;
						trackCounter = 0;
						minuteTime = microMinute+eventTime[i][0];
					}
				}				
			} else { //it is 'MB'
				if (eventTime[i][xtop] <= 0 &&
					eventTime[i][xmiddle] > 0 &&
					eventTime[i][xbottom] > 0 &&
					eventTime[i][ytop] <= 0 &&
					eventTime[i][ymiddle] > 0 &&
					eventTime[i][ybottom] > 0) {
					//check if it belongs within each minute
					if (eventTime[i][0] <= minuteTime) {
						if (debugEventsWithTracks) {
							console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
						}
						trackCounter += 1;
					} else {
						//console.log(layerCount, option, startTime, trackCounter);
						//save and move up a minute
						vals.push({x:startTime+1,y:trackCounter})
						startTime += 1;
						trackCounter = 0;
						minuteTime = microMinute+eventTime[i][0];
					}
				}				
			}
		}
		//check for top, middle and bottom but not in both layers
		if (layerCount == 5) {
			//middle missing
			if (option == 'M') {
				//console.log("5 middle missing");
				if ((eventTime[i][xtop] > 0 &&
					eventTime[i][xbottom] > 0 &&
					eventTime[i][ytop] > 0 &&
					eventTime[i][ybottom] > 0) &&
					((eventTime[i][xmiddle] > 0 && eventTime[i][ymiddle] <= 0)
				    || (eventTime[i][xmiddle] <= 0 && eventTime[i][ymiddle] > 0))) {					
					//check if it belongs within each minute
					var count = eventTime[i].filter(num => num > 0).length;
					if (eventTime[i][0] <= minuteTime && count == layerCount) {
						if (debugEventsWithTracks) {
							console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
						}
						trackCounter += 1;
					} else {
						//console.log(layerCount, option, startTime, trackCounter);
						//save and move up a minute
						vals.push({x:startTime+1,y:trackCounter})
						startTime += 1;
						trackCounter = 0;
						minuteTime = microMinute+eventTime[i][0];
					}
				}
			} else { //it is TB, either top or bottom missing
				var count = eventTime[i].filter(num => num > 0).length;
				if (eventTime[i][xmiddle] > 0 && eventTime[i][ymiddle] > 0 && count == layerCount) {
					if (eventTime[i][0] <= minuteTime) {
						if (debugEventsWithTracks) {
							console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
						}
						trackCounter += 1;						
					} else {
						//console.log(layerCount, option, startTime, trackCounter);
						//save and move up a minute
						vals.push({x:startTime+1,y:trackCounter})
						startTime += 1;
						trackCounter = 0;
						minuteTime = microMinute+eventTime[i][0];
					}					
				}
			}
		}		
		//check for top, middle and bottom in both layers
		if (layerCount == 6) {
			if (eventTime[i][xtop] > 0 &&
				eventTime[i][xmiddle] > 0 &&
				eventTime[i][xbottom] > 0 &&
				eventTime[i][ytop] > 0 &&
				eventTime[i][ymiddle] > 0 &&
				eventTime[i][ybottom] > 0) {
				//check if it belongs within each minute
				if (eventTime[i][0] <= minuteTime) {
					if (debugEventsWithTracks) {
						console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
					}
					trackCounter += 1;
				} else {
					//console.log(layerCount, option, startTime, trackCounter);
					//save and move up a minute
					vals.push({x:startTime+1,y:trackCounter})
					startTime += 1;
					trackCounter = 0;
					minuteTime = microMinute+eventTime[i][0];
				}
			}
		}		
	}
	vals.push({x:startTime+1,y:trackCounter})
	//console.log(layerCount,option,vals);
	return vals;
}// end of getEventsWithTracksPerMinute


function getTotalChartEvents(arr) {
	return arr.length;
}//end of getTotalChartEvents

function getTotalChartEventsComparing(arr1, arr2) {
	var eventCount = 0;
	for (var i = 0; i < arr1.length; i++) {
		for (var j = 0; j < arr2.length; j++) {
			if (arr1[i][0] == arr2[j][0]) {
				eventCount += 1;
			}
		}
	}
	return eventCount;
}//end of getTotalChartEventsComparing

// Populate the last 12 ADC charts
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
}// end of popXADR

function popXADRAverage(layer) {
	var data = [];
  	for (var event = 0; event < subtractPedX.length; event++) {
    	for(var channel = 1; channel < subtractPedX[event][layer].length; channel++){
      		if(subtractPedX[event][layer][channel-1] > 0 && subtractPedX[event][layer][channel] > 0){
        		var xCord = channel - 1;
        		var yCord = (subtractPedX[event][layer][channel-1] + subtractPedX[event][layer][channel]);
        		data.push({ x: xCord, y: yCord});
      		}
    	}
  	}
	var averageYPerX = getAverage(data);	
  	return averageYPerX;
}// end of popXADRAverage

function popXADRAverage(layer) {
	var data = [];
  	for (var event = 0; event < subtractPedX.length; event++) {
    	for(var channel = 1; channel < subtractPedX[event][layer].length; channel++){
      		if(subtractPedX[event][layer][channel-1] > 0 && subtractPedX[event][layer][channel] > 0){
        		var xCord = channel - 1;
        		var yCord = (subtractPedX[event][layer][channel-1] + subtractPedX[event][layer][channel]);
        		data.push({ x: xCord, y: yCord});
      		}
    	}
  	}
	var averageYPerX = getAverage(data);	
  	return averageYPerX;
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
}// end of popYADR

function popYADRAverage(layer) {
  	var data = [];
  	for (var event = 0; event < subtractPedY.length; event++) {
    	for(var channel = 1; channel < subtractPedY[event][layer].length; channel++){
      		if(subtractPedY[event][layer][channel-1]>0 &&subtractPedY[event][layer][channel]>0){
        		var xCord = channel - 1;
        		var yCord = (subtractPedY[event][layer][channel-1]+ subtractPedY[event][layer][channel]);
        		data.push({ x: xCord, y: yCord});
      		}
    	}
  	}
	//console.log(data);
	var averageYPerX = getAverage(data);	
	return averageYPerX;
}// end of popYADRAverage

//helper function used by popXADRAverage and popYADRAverage
function getAverage(data) {
	var groupedByX = {};
	data.forEach(item => {
	  if (!groupedByX[item.x]) {
	    groupedByX[item.x] = [];
	  }
	  groupedByX[item.x].push(item.y);
	});	

	var averageYPerX = {};

	for (var xValue in groupedByX) {
	  var yValues = groupedByX[xValue];
	  var sumY = yValues.reduce((sum, y) => sum + y, 0);
	  var averageY = sumY / yValues.length;
	  averageYPerX[xValue] = averageY;
	}	
	return averageYPerX;
}//end of getAverage
}

function popYADRAverage(layer) {
  	var data = [];
  	for (var event = 0; event < subtractPedY.length; event++) {
    	for(var channel = 1; channel < subtractPedY[event][layer].length; channel++){
      		if(subtractPedY[event][layer][channel-1]>0 &&subtractPedY[event][layer][channel]>0){
        		var xCord = channel - 1;
        		var yCord = (subtractPedY[event][layer][channel-1]+ subtractPedY[event][layer][channel]);
        		data.push({ x: xCord, y: yCord});
      		}
    	}
  	}
	var averageYPerX = getAverage(data);	
	return averageYPerX;
}

//helper function used by popXADRAverage and popYADRAverage
function getAverage(data) {
	var groupedByX = {};
	data.forEach(item => {
	  if (!groupedByX[item.x]) {
	    groupedByX[item.x] = [];
	  }
	  groupedByX[item.x].push(item.y);
	});	

	var averageYPerX = {};

	for (var xValue in groupedByX) {
	  var yValues = groupedByX[xValue];
	  var sumY = yValues.reduce((sum, y) => sum + y, 0);
	  var averageY = sumY / yValues.length;
	  averageYPerX[xValue] = averageY;
	}	
	return averageYPerX;
}

function getDxyBothLayers() {
	for (var i = 0; i < dx.length; i++) {
		var event = dx[i][0];
		for (var j = 0; j < dy.length; j++) {
			if (dy[j][0] == event) {
				dxbothlayers.push(dx[i]);
				dybothlayers.push(dy[j]);
			}
		}
	}
	//no need to keep these in memory
	dx = [];
	dy = [];
}

function getDxyTopMiddleBothLayers() {
	for (var i = 0; i < dxtopmiddle.length; i++) {
		var event = dxtopmiddle[i][0];
		for (var j = 0; j < dytopmiddle.length; j++) {
			if (dytopmiddle[j][0] == event) {
				dxtopmiddlebothlayers.push(dxtopmiddle[i]);
				dytopmiddlebothlayers.push(dytopmiddle[j]);
			}
		}
	}
	//no need to keep these in memory
	dxtopmiddle = [];
	dytopmiddle = [];
}

function getDxyBottomMiddleBothLayers() {
	for (var i = 0; i < dxbottommiddle.length; i++) {
		var event = dxbottommiddle[i][0];
		for (var j = 0; j < dybottommiddle.length; j++) {
			if (dybottommiddle[j][0] == event) {
				dxbottommiddlebothlayers.push(dxbottommiddle[i]);
				dybottommiddlebothlayers.push(dybottommiddle[j]);
			}
		}
	}
	//no need to keep these in memory
	dxbottommiddle = [];
	dybottommiddle = [];
}

function getChannelData(whichLayer, arr1, upperLimit, events) {
    var vals = [];
	var totalEvents = arr1.length;
	var layerNdx = 0;
	if (whichLayer == 'top') {
		layerNdx = 3;
	}
	if (whichLayer == 'middle') {
		layerNdx = 2;
	}
	if (whichLayer == 'bottom') {
		layerNdx = 1;
	}
	if (events > 0 && events <= arr1.length) {
		totalEvents = events;
	}
    for (var i = 0; i < totalEvents; i++) {		
        if (arr1[i][layerNdx].channel1 != -1) {
             if (arr1[i][layerNdx].channel1 > upperLimit) {
                  vals.push(upperLimit);
             } else {
                  vals.push(arr1[i][layerNdx].channel1);
             }
         }
         if (arr1[i][layerNdx].channel2 != -1) {
             if (arr1[i][layerNdx].channel2 > upperLimit) {
                  vals.push(upperLimit);
              } else {
                  vals.push(arr1[i][layerNdx].channel2);
              }
         }
    }
    return vals;
}

function getFrequency(arr1) {
	vals = [];
	var frequency = arr1.reduce((acc, num) => {
	  acc.set(num, (acc.get(num) || 0) + 1);
	  return acc;
	}, new Map());		

	for (const [n, f] of frequency.entries()) {
		vals.push({x:n,y:f});
	}	
	return vals;
}

function calculateDeltaXDeltaYFrequency(arr, events, binWidth) {
	var deltaValues = [];
	var totalEvents = arr.length;
	if (events > 0 && events <= arr.length) {
		totalEvents = events;
	}
	for (let i = 1; i < totalEvents; i++) {
		deltaValues.push(arr[i][4]);
	}	
	// Find min and max values to determine the range
	var minVal = Math.min(...deltaValues);
	var maxVal = Math.max(...deltaValues);

	// Calculate bin boundaries
	var binBoundaries = [];
	for (let i = minVal; i <= maxVal + binWidth; i += binWidth) {
	    binBoundaries.push(i);
	}	
	
	// Initialize bins
	var bins = [];
	if (binBoundaries.length > 0) {
		bins = Array(binBoundaries.length - 1).fill(0);
	}
	// Populate bins
	deltaValues.forEach(value => {
	  for (let i = 0; i < binBoundaries.length - 1; i++) {
	    if (value >= binBoundaries[i] && value < binBoundaries[i + 1]) {
	      bins[i]++;
	      break;
	    }
	  }
	});

	var lineChartData = [];
	if (bins.length > 0) {
		for (let i = 0; i < bins.length; i++) {
		  var binCenter = (binBoundaries[i] + binBoundaries[i + 1]) / 2;
		  lineChartData.push({ x: binCenter, y: bins[i] }); 
		}		
	}
	return lineChartData;
	/*
	var deltaValues = [];
	var totalEvents = arr.length;
	if (events > 0 && events <= arr.length) {
		totalEvents = events;
	}
	for (let i = 1; i < totalEvents; i++) {
    	deltaValues.push(arr[i][4]);
  	}
	var frequencyDistribution = {};
  	for (var delta of deltaValues) {
    	frequencyDistribution[delta] = (frequencyDistribution[delta] || 0) + 1; // Increment count or initialize to 1
  	}
  	return frequencyDistribution;
	*/
}

function getDxDy(events) {
	var vals = [];
	var totalEvents = dxbothlayers.length;
	if (events > 0 && events <= dxbothlayers.length) {
		totalEvents = events;
	}
	for (var i = 0; i < totalEvents; i++) {
		vals.push({x:dxbothlayers[i][4], y:dybothlayers[i][4]});
	}
	return vals;
}

function getDxDz(events) {
	var vals = [];
	var totalEvents = dxbothlayers.length;
	if (events > 0 && events <= dxbothlayers.length) {
		totalEvents = events;
	}
	for (var i = 0; i < totalEvents; i++) { 
		//if (i < 5) {
		//	console.log(dxbothlayers[i],dybothlayers[i], dxbothlayers[i][4]/dxbothlayers[i][5],dybothlayers[i][4]/dybothlayers[i][5] );
		//}
		vals.push({x:dxbothlayers[i][4]/dxbothlayers[i][5], y:dybothlayers[i][4]/dybothlayers[i][5]});
	}
	return vals;
}

function getDxDyMiddle(arrX, arrY, events) {
	var vals = [];
	var totalEvents = arrX.length;
	if (totalEvents > arrY.length) {
		totalEvents = arrY.length;
	}
	if (events > 0 && events <= arrX.length && events <= arrY.length) {
		totalEvents = events;
	}
	for (var i = 0; i < totalEvents; i++) {
		vals.push({x:arrX[i][4], y:arrY[i][4]});
	}
	return vals;
}

function getDxyDzMiddle(arrX, arrY, events) {
	var vals = [];
	var totalEvents = arrX.length;
	if (events > 0 && events <= arrX.length) {
		totalEvents = events;
	}
	for (var i = 0; i < totalEvents; i++) {
		//vals.push({x:arr[i][4], y:arr[i][5]});
		vals.push({x:arrX[i][4]/arrX[i][5], y:arrY[i][4]/arrY[i][5]});
	}
	//console.log(vals);
	return vals;
}

function getEventsWithTracksPerMinute(layerCount, option) {
	var vals = [];
	var xtop = layerOrderX[0][2]*2;
	var xmiddle = layerOrderX[1][2]*2;
	var xbottom = layerOrderX[2][2]*2;
	var ytop = (layerOrderY[0][2]*2)+1;
	var ymiddle = (layerOrderY[1][2]*2)+1;
	var ybottom = (layerOrderY[2][2]*2)+1;
	var startTime = 0;
	var minuteTime = microMinute+eventTime[0][0];
	var trackCounter = 0;
	for (var i = 0; i < eventTime.length; i++) {
		//check for top and bottom in both layers
		if (layerCount == 4) {
			if (option == 'TM') {
				if (eventTime[i][xtop] > 0 &&
					eventTime[i][xmiddle] > 0 &&
					eventTime[i][xbottom] <= 0 &&
					eventTime[i][ytop] > 0 &&
					eventTime[i][ymiddle] > 0 &&
					eventTime[i][ybottom] <= 0) {
					//check if it belongs within each minute
					if (eventTime[i][0] <= minuteTime) {
						//if (trackCounter < 5) {
						//	console.log(layerCount, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
						//}
						trackCounter += 1;
					} else {
						//save and move up a minute
						vals.push({x:startTime+1,y:trackCounter})
						startTime += 1;
						trackCounter = 0;
						minuteTime = microMinute+eventTime[i][0];
					}
				}				
			} else { //it is 'MB'
				if (eventTime[i][xtop] <= 0 &&
					eventTime[i][xmiddle] > 0 &&
					eventTime[i][xbottom] > 0 &&
					eventTime[i][ytop] <= 0 &&
					eventTime[i][ymiddle] > 0 &&
					eventTime[i][ybottom] > 0) {
					//check if it belongs within each minute
					if (eventTime[i][0] <= minuteTime) {
						//if (trackCounter < 5) {
						//	console.log(layerCount, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
						//}
						trackCounter += 1;
					} else {
						//save and move up a minute
						vals.push({x:startTime+1,y:trackCounter})
						startTime += 1;
						trackCounter = 0;
						minuteTime = microMinute+eventTime[i][0];
					}
				}				
			}
		}
		//check for top, middle and bottom but not in both layers
		if (layerCount == 5) {
			//middle missing
			if (option == 'M') {
				if ((eventTime[i][xtop] > 0 &&
					eventTime[i][xbottom] > 0 &&
					eventTime[i][ytop] > 0 &&
					eventTime[i][ybottom] > 0) &&
					((eventTime[i][xmiddle] > 0 && eventTime[i][ymiddle] <= 0)
				    || (eventTime[i][xmiddle] <= 0 && eventTime[i][ymiddle] > 0))) {					
					//check if it belongs within each minute
					var count = eventTime[i].filter(num => num > 0).length;
					if (eventTime[i][0] <= minuteTime && count == layerCount) {
						//if (trackCounter < 5) {
						//	console.log(layerCount, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
						//}
						trackCounter += 1;
					} else {
						//save and move up a minute
						vals.push({x:startTime+1,y:trackCounter})
						startTime += 1;
						trackCounter = 0;
						minuteTime = microMinute+eventTime[i][0];
					}
				}
			} else { //it is TB, either top or bottom missing
				var count = eventTime[i].filter(num => num > 0).length;
				if (eventTime[i][xmiddle] > 0 && eventTime[i][ymiddle] > 0 && count == layerCount) {
					if (eventTime[i][0] <= minuteTime) {
						trackCounter += 1;
					} else {
						//save and move up a minute
						vals.push({x:startTime+1,y:trackCounter})
						startTime += 1;
						trackCounter = 0;
						minuteTime = microMinute+eventTime[i][0];
					}					
				}
			}
		}		
		//check for top, middle and bottom in both layers
		if (layerCount == 6) {
			if (eventTime[i][xtop] > 0 &&
				eventTime[i][xmiddle] > 0 &&
				eventTime[i][xbottom] > 0 &&
				eventTime[i][ytop] > 0 &&
				eventTime[i][ymiddle] > 0 &&
				eventTime[i][ybottom] > 0) {
				//check if it belongs within each minute
				if (eventTime[i][0] <= minuteTime) {
					//if (trackCounter < 5) {
					//	console.log(layerCount, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
					//}
					trackCounter += 1;
				} else {
					//save and move up a minute
					vals.push({x:startTime+1,y:trackCounter})
					startTime += 1;
					trackCounter = 0;
					minuteTime = microMinute+eventTime[i][0];
				}
			}
		}
		
	}
	vals.push({x:startTime+1,y:trackCounter})
	//console.log(layerCount,option,vals);
	return vals;
}

//attempt to calculate delta
function calculateDeltaPointByPercentage(event, x1, y1, x2, y2, percentage, yProjected,eventChannels, layer, zValue) {
	var dx = x2 - x1;
	var dy = y2 - y1;
	const x = ((x1 + (dx * percentage/100))/(size/2.0))+1;
	var y = zValue;
	var channel1 = eventChannels[layer][0];
	var channel2 = eventChannels[layer][1];
  	return { x, y, yProjected, channel1, channel2};
}//end of calculatePointByPercentage

function getSingleDeltaSidePoint(event, layerTriangle,eventChannels, layer, zValue) {
	var sidePoint = [];
	var x1 = layerTriangle[layer][0][2][0];
	var x2 = layerTriangle[layer][0][3][0];
	var x3 = layerTriangle[layer][0][4][0];
	var x = (((x1 + x2 + x3)/3) /(size/2.0))+1;
	var y = zValue;
	yProjected = (y /(size/2.0))+1;
	var channel1 = -1; 
	if (eventChannels[layer].length === 0) {
		channel1 = -1;
	} else {
		channel1 = eventChannels[layer][0];
	}
	var channel2 = -1;
	sidePoint = {x, y, yProjected, channel1, channel2};	
	return sidePoint; 
}//end of getSingleSidePoint

function calculateDeltaSidePoint(event, layerTriangle,eventChannels, layer, zValue) {
	var sidePoint = [];
	var yProjected = 0;
	//if (event == 0) {
	//	console.log(layer, zValue);
	//}
	if (layerTriangle[layer].length > 0) {
	  if (layerTriangle[layer].length == 1) {
		//the point falls in the middle of the triangle
		sidePoint = getSingleDeltaSidePoint(event, layerTriangle,eventChannels, layer, zValue);
	  }	else {
		//first we have to check for neighbors
        var quadFirstCell = layerTriangle[layer][0][6];
        var quadSecondCell = layerTriangle[layer][1][6];
        //these are not neighbors
        if ((quadSecondCell-quadFirstCell) > 1) {
			sidePoint = getSingleDeltaSidePoint(event, layerTriangle,eventChannels, layer, zValue);
		} else {					
			//we have to calculate between neighbors... I will assume it is the first two neigbors for now
			var up = layerTriangle[layer][0][0];
			//the last line of the first triangle and the first line of the second triangle are a match
			//use the first values
			var x1 = layerTriangle[layer][0][3][0];
			var y1 = zValue;
			var x2 = layerTriangle[layer][0][4][0];
			var y2 = zValue;
			yProjected = (layerTriangle[layer][0][5]/(size/2.0))+1;	
			var point1Intensity = layerTriangle[layer][0][1];
			var point2Intensity = 0;
			if (layerTriangle[layer].length > 1) {
				point2Intensity = layerTriangle[layer][1][1];
			}
			var pointPercent = 0;
		    var pointPercentSum = point1Intensity + point2Intensity;
			if (up) {
			   if (point1Intensity > point2Intensity) {
				 //first triangle is pyramid with higher intensity
				 pointPercent = point1Intensity * 100 / pointPercentSum;
				 sidePoint = calculateDeltaPointByPercentage(event, x1, y1, x2, y2, pointPercent, yProjected,eventChannels, layer, zValue);
			   } else {
				 //first triangle is pyramid with lower intensity			 
				 pointPercent = point2Intensity * 100 / pointPercentSum;
				 sidePoint = calculateDeltaPointByPercentage(event, x2, y2, x1, y1, pointPercent, yProjected,eventChannels, layer, zValue);
			   }			
			} else {
				if (point1Intensity > point2Intensity) {
				 //first triangle is down with higher intensity
				 pointPercent = point1Intensity * 100 / pointPercentSum;
				 sidePoint = calculateDeltaPointByPercentage(event, x1, y1, x2, y2, pointPercent, yProjected,eventChannels, layer, zValue);
				} else {
			     //sthe first triangle is down with lower intensity
				 pointPercent = point2Intensity * 100 / pointPercentSum;
				 sidePoint = calculateDeltaPointByPercentage(event, x2, y2, x1, y1, pointPercent, yProjected,eventChannels, layer, zValue);
				}
			}
		}//end of neighbor calculation
	  }
	} 
	return sidePoint;
}//end of calculateSidePoint

function calculateDeltaTrack(whichLayer, event, layerAct, layerQuad, layerQuadSize, layerTriangle, layerOrder,eventChannels){
  var sidePointX1 = calculateDeltaSidePoint(event, layerTriangle,eventChannels, layerOrder[0][2], layerOrder[0][0]);
  var sidePointX2 = calculateDeltaSidePoint(event, layerTriangle,eventChannels, layerOrder[1][2], layerOrder[1][0]);
  var sidePointX3 = calculateDeltaSidePoint(event, layerTriangle,eventChannels, layerOrder[2][2], layerOrder[2][0]);
  if (sidePointX1.x > 0 && sidePointX3.x > 0) {
	var deltax = (sidePointX3.x - sidePointX1.x);
	var deltaz = (sidePointX3.y - sidePointX1.y);
	if (whichLayer == 'X') {
		dx.push([event, sidePointX1, sidePointX2, sidePointX3, deltax, deltaz]);
	} else {
		dy.push([event, sidePointX1, sidePointX2, sidePointX3, deltax, deltaz]);
	}
  } else {
	//test middle layer
	if (sidePointX1.x > 0 && sidePointX2.x > 0) {
		var deltax = (sidePointX2.x - sidePointX1.x);
		var deltaz = (sidePointX2.y - sidePointX1.y);
		if (whichLayer == 'X') {
			dxbottommiddle.push([event, sidePointX1, sidePointX2, sidePointX3, deltax, deltaz]);
		} else {
			dybottommiddle.push([event, sidePointX1, sidePointX2, sidePointX3, deltax, deltaz]);
		}		
	} else {
		if (sidePointX2.x > 0 && sidePointX3.x > 0) {
			var deltax = (sidePointX3.x - sidePointX2.x);
			var deltaz = (sidePointX3.y - sidePointX2.y);
			if (whichLayer == 'X') {
				dxtopmiddle.push([event, sidePointX1, sidePointX2, sidePointX3, deltax, deltaz]);
			} else {
				dytopmiddle.push([event, sidePointX1, sidePointX2, sidePointX3, deltax, deltaz]);
			}					
		}
	}
  }
}//end of calculateTrack

function drawDeltaTriangle(dir, xpos, y, channel, inten, quadMember) {
	  var triangleCoords = [];
	  triangleCoords.push(dir,inten);
	  if(isNaN(inten)){
	    inten = 0;
	  }
	  triangleCoords.push([xpos, y]);
	  triangleCoords.push([xpos+size, y]);
	  var y3 = 0;
	  var height = 0;
	  if (dir) {
		  y3 = y-(Math.sqrt(3) * size / 2);
		  height = y-((Math.sqrt(3) * size / 2)/2.0);
		  triangleCoords.push([xpos+(size/2), y3]);
	  } else { 
		  y3 = y+(Math.sqrt(3) * size / 2);
		  height = y+((Math.sqrt(3) * size / 2)/2.0);
	      triangleCoords.push([xpos+(size/2), y3]);
	  }
	  if(inten == 0){
		triangleCoords = [];
	  } else {
		//do nothing
	  }   
	  triangleCoords.push(height, quadMember);
	return triangleCoords;
}//end of drawTriangle

function drawDeltaQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,coordArray,ped,layerQuad,quadMember,layerQuadSize,cellSize,quadGap,layerTriangle,eventChannels) {
	var adcChannel;
	var pedPosition;
	var triangleCoords = [];
	if(up){
		if (reversed) {
			//need to reverse the channels
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
			pedPosition = (numQuads * 4) - channelPosition;
	        triangleCoords = drawDeltaTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawDeltaTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);
	        }		
		}
	    channel++;	
		if (reversed) {
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
			pedPosition = (numQuads * 4) - channelPosition;
	        triangleCoords = drawDeltaTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);
				}
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawDeltaTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);
			}
		}
	    channel++;	
	} else {
		if (reversed) {
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
			pedPosition = (numQuads * 4) - channelPosition;
	        triangleCoords = drawDeltaTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);				
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawDeltaTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords);
				eventChannels[layer].push(adcChannel);				 
	        }
		}
	    channel++;	
		if (reversed) {
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
			pedPosition = (numQuads * 4) - channelPosition;
	        triangleCoords = drawDeltaTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);				
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawDeltaTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords);
				eventChannels[layer].push(adcChannel);				 
	        }
		}
	    channel++;

	}// end if inside for loop
	return channel;
}//end of drawQuad

function calculateLayer(whichLayer, event) {
	 var channel = 0;
	 var layer = 2; // we start with the top layer data in Z for both X and Y --> array goes 0,1,2
	 var up = false;
	 var reversed = false;
	 var quadSize = 0.0;
	 var cellSize = 0.0;
	 var quadGap = 0.0;    
	 var startPoint = 0;
	// Read the value of the input
	 var layerAct = [[],[],[]];
	 var layerQuad = [[],[],[]];
	 var layerQuadSize = [[],[],[]];
	 var layerTriangle = [[],[],[]];
	 var eventChannels = [[],[],[]]; 
	 var end, middle, start;
	 var layerOrder = [];
	 var startNdx = 0;
	 if (whichLayer === 'X') { 
		var listx = [parseFloat(geometry[1][geometry[1].length-4]),5,0];
		layerOrder.push(listx);
		listx = [parseFloat(geometry[3][geometry[3].length-4]),3,1];
		layerOrder.push(listx);
		listx = [parseFloat(geometry[5][geometry[5].length-4]),1,2];
		layerOrder.push(listx);
		startNdx = 5;
	 } else {
		var listy = [parseFloat(geometry[2][geometry[2].length-4]),6,0];
		layerOrder.push(listy);
		listy = [parseFloat(geometry[4][geometry[4].length-4]),4,1];
		layerOrder.push(listy);
		listy = [parseFloat(geometry[6][geometry[6].length-4]),2,2];
		layerOrder.push(listy);
		startNdx = 4;
	}

	// Sort in descending order by the first element
	layerOrder.sort(function(a, b) {
	  return a[0] - b[0]; 
	});
	end = layerOrder[0][0];
	middle = layerOrder[1][0];
	start = layerOrder[2][0];

	var ndx = layerOrder[2][1];
	layer = layerOrder[2][2];
	var layerNdx = 2;
	var numQuads = (layers[ndx-1].length-2);

	var units = 260.0 / (start - end);
	var firstLayer = start; //starts at the top position of the layer in the geometry
	var secondLayer = middle;	
	var thirdLayer = end;
	//loop to draw the three y layers, the layers are not evenly placed so we have to calculate

	//loop through the three layers
	for (var i = 0; i < 3; i++) {
	  var yp = start;
	  var zvalue = start;
	  if (i == 1) {
		  yp = middle;
		  zvalue = middle;
	  }
	  if (i == 2) {
		  yp = end;
		  zvalue = end;
	  }
	  //check if we need to start with a three or a pyramid for each layer
	  if (geometry[ndx][1] === "Tree") {
	 	up = false;
	  } else {
		up = true;
	  }
	  //check if channels are reversed
	  if (geometry[ndx][2] === "REVERSED") {
	 	reversed = true;
	  } else {
		reversed = false;
	  }	  
	  var posQuadSize = geometry[ndx].length-3; //get the quad size from the geometry
	  quadSize = geometry[ndx][posQuadSize];
	  cellSize = quadSize * size / 2.0;
	  triangleHeight = Math.sqrt(3) * cellSize / 2;
	  quadGap =  size - cellSize; 
	  // Calculate the real estate for the triangles based on the geometry
	  var xpSize = ((numQuads * 2) * cellSize) + startPoint;
	  //loop and draw quads taking into account the intercell spacing and flipping
	  var quadNo = 0;
	  for (var xp = startPoint; xp < xpSize; xp += quadGap) {
		  //have to pass the correct arguments per quad!!!!! need some calculations!!!!
		  if (quadNo <= numQuads) {
			  for (var quadMember = 0; quadMember < 2; quadMember++) {
				  if (quadMember == 0) {
					 quadNo++;
				  }
	 			  if (whichLayer === 'X') { 
				  	channel = drawDeltaQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,xCoord,subtractPedX,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle,eventChannels);
				  } else {
				  	channel = drawDeltaQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,yCoord,subtractPedY,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle,eventChannels);					  
				  }
				  xp += cellSize;
			  }
		  }
	  }//end inner for loop	
	   channel = 0;
	  layerNdx -= 1;
	  if (layerNdx >= 0) {
	  	layer = layerOrder[layerNdx][2];
	  	ndx = layerOrder[layerNdx][1];
	  }
	}//end outer for loop  
	calculateDeltaTrack(whichLayer, event,layerAct, layerQuad, layerQuadSize, layerTriangle, layerOrder,eventChannels);		
}//end of calculateLayer


function getDxy(){
  for (var event = 0; event < subtractPedX.length; event++) {
	  calculateLayer('X', event); 
  	  calculateLayer('Y', event); 
  }
}//end of getdxy
