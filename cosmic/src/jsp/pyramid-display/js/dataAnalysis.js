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
function populateX(letter, layer){
    // Optimized: avoid slice/map and repeated addArrays allocations
    var vals = Array(xLayerLength).fill(0);
    var pedestal = subtractPedX;
    for (var a = 0; a < pedestal.length; a++) {
        var row = pedestal[a][layer];
        // defensive: if row is undefined, skip
        if (!row) continue;
        var len = Math.min(xLayerLength, row.length);
        for (var i = 0; i < len; i++) {
            var value = row[i];
            vals[i] += (value > 0 ? 1 : value);
        }
        // if row is shorter than xLayerLength, remaining vals unchanged
    }
    if (debugAnalysis === true) {
        console.log("X Pedestal "+layer+letter);
        console.log("values:", vals);
    }
	//console.log(letter, layer, vals);
    return vals;
}// end of populateX

function populateY(letter, layer){
    // Optimized: avoid slice/map and repeated addArrays allocations
    var vals = Array(yLayerLength).fill(0);
    var pedestal = subtractPedY;
    for (var a = 0; a < pedestal.length; a++){
        var row = pedestal[a][layer];
        if (!row) continue;
        var len = Math.min(yLayerLength, row.length);
        for (var i = 0; i < len; i++) {
            var value = row[i];
            vals[i] += (value > 0 ? 1 : value);
        }
    }
    if (debugAnalysis === true) {
        console.log("Y Pedestal "+layer+letter);
        console.log("values:", vals);
    }
	//console.log(letter, layer, vals);
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
	//console.log(arr.length);
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
	//console.log(option,arr.length);
	var vals = [];
	for (var i = 0; i < arr.length; i++) {
		vals.push({x:arr[i][1][1][0],y:arr[i][1][4][0],event: (arr[i][0]+1)});				
	}
	//console.log(option,vals);
	return vals;
}//end of get6singlepoints

function get6singlepointsBothLayers(option, arr1) {
	var vals = [];
	//console.log(option,arr1.length);
	for (var i = 0; i < arr1.length; i++) {
		vals.push({x:arr1[i][1][1][0],y:arr1[i][1][4][0],event: (arr1[i][0]+1)});
	}
	return vals;
}//end of get6singlepointsBothLayer


function getFrequency6ExpectedActualforHitsSingleLayer(option, arr, interval) {
	var diff = 0;
	var diffCollection = [];
	if (option == 'X') {
		for (var i = 0; i < arr.length; i++) {
			diff = arr[i][2].x3 - arr[i][1][1][0];
			diffCollection.push(diff);
		}
	}
	if (option == 'Y') {
		for (var i = 0; i < arr.length; i++) {
			diff = arr[i][2].x3 - arr[i][1][4][0];
			diffCollection.push(diff);
		}
	}
	var binnedData = getBinnedData(diffCollection, interval);
	var result = [];
	for (var i = 0; i < binnedData.length; i++) {
		result.push({x:binnedData[i].binNum, y:binnedData[i].count});
	}
	//console.log("frequency for 6 plane hits: ", option, result);
	return result;
}// end of getFrequency6ExpectedActualforHitsSingleLayer

function getFrequency6ExpectedActualforHits(option, arr) {
	//console.log(option, arr);
	var diff = 0;
	var diffCollection = [];
	var interval = 0.2;
	//for (var i = 0; i < arr.length; i++) {
	//	console.log(arr[i]);
	//}
	if (option == 'X') {
		for (var i = 0; i < arr.length; i++) {
			//if (i < 5) {
			//	console.log(option, arr[i]);
			//}
			diff = arr[i][2].x3 - arr[i][1][1][0];
			diffCollection.push(diff);
		}
	}
	if (option == 'Y') {
		for (var i = 0; i < arr.length; i++) {
			//if (i < 5) {
			//	console.log(option, arr[i]);
			//}
			diff = arr[i][3].x3 - arr[i][1][4][0];
			diffCollection.push(diff);
		}
		interval = 1.0;
	}
	//console.log(option, diffCollection);
	var binnedData = getBinnedData(diffCollection, interval);
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
    if (!Array.isArray(arr) || arr.length === 0) return bins;
    var interval = intervalSize;
    var min = Infinity, max = -Infinity;
    for (var i = 0; i < arr.length; i++) {
        var v = Number(arr[i]);
        if (v < min) min = v;
        if (v > max) max = v;
    }
    var arrayMinValue = min - intervalSize;
    var arrayMaxValue = max + intervalSize;
    var numBins = Math.floor((arrayMaxValue - arrayMinValue) / interval) + 1;
    // initialize bins with counts 0 and precompute min/max
    for (var b = 0; b < numBins; b++) {
        var binMin = arrayMinValue + b * interval;
        bins.push({
            binNum: binMin.toFixed(2),
            minNum: binMin,
            maxNum: binMin + interval,
            count: 0
        });
    }
    // single pass assignment using arithmetic index
    for (var i = 0; i < arr.length; i++){
      var item = Number(arr[i]);
      var idx = Math.floor((item - arrayMinValue) / interval);
      if (idx >= 0 && idx < bins.length) {
        // match previous inclusion: item must be > min and <= max
        var bin = bins[idx];
        if (item > bin.minNum && item <= bin.maxNum) {
          bin.count++;
        }
      }
    }
    return bins;
}//end of getBinnedData

function getFrequency6ExpectedActual(option, arr1) {
	var diff = 0;
	var diffCollection = [];
	if (option == 'X') {
		for (var i = 0; i < arr1.length; i++) {
			diff = arr1[i][2].x3 - arr1[i][1][1][0];
			diffCollection.push(diff);
		}
		//for (var i = 0; i < arr2.length; i++) {
		//	diff = arr2[i][2].x3 - arr2[i][1][1][0];
		//	diffCollection.push(diff);
		//}
	}
	if (option == 'Y') {
		for (var i = 0; i < arr1.length; i++) {
			diff = arr1[i][2].x3 - arr1[i][1][4][0];
			diffCollection.push(diff);
		}
		//for (var i = 0; i < arr2.length; i++) {
		//	diff = arr2[i][3].x3 - arr2[i][1][4][0];
		//	diffCollection.push(diff);
		//}
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

function calculateDeltaXDeltaYFrequency(option,arr, events, binWidth) {
    var totalEvents = arr.length;
    if (events > 0 && events <= arr.length) {
        totalEvents = events;
    }
    if (totalEvents <= 1) return []
    // Build deltaValues in-place from arr entries index 1..totalEvents-1
    var minVal = Infinity, maxVal = -Infinity;
    for (var i = 1; i < totalEvents; i++) {
        var v = Number(arr[i][4]);
        if (v < minVal) minVal = v;
        if (v > maxVal) maxVal = v;
    }
    if (!isFinite(minVal) || !isFinite(maxVal)) return [];
    var binCount = Math.floor((maxVal - minVal) / binWidth) + 1;
    if (binCount <= 0) binCount = 1;
    var bins = new Array(binCount).fill(0);
    for (var i = 1; i < totalEvents; i++) {
        var value = Number(arr[i][4]);
        var idx = Math.floor((value - minVal) / binWidth);
        if (idx < 0) idx = 0;
        if (idx >= binCount) idx = binCount - 1;
        bins[idx]++;
    }
    var lineChartData = [];
    for (var i = 0; i < bins.length; i++) {
      var binCenter = minVal + (i + 0.5) * binWidth;
      lineChartData.push({ x: binCenter, y: bins[i] });
    }
    return lineChartData;
}//end of calculateDeltaXDeltaYFrequency

//CHANNEL FREQUENCY
function getFrequency(arr1) {
	var vals = [];
	if (!Array.isArray(arr1) || arr1.length === 0) return vals;
	var freq = Object.create(null);
	for (var i = 0; i < arr1.length; i++) {
		var num = arr1[i];
		freq[num] = (freq[num] || 0) + 1;
	}
	for (var key in freq) {
		if (Object.prototype.hasOwnProperty.call(freq, key)) {
			vals.push({x: key, y: freq[key]});
		}
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
	var events6planehits = []
	//get the events that have 6 plane hits in both layers, then only calculate dx/dz for those events
	for (var i = 0; i < tracking6MiddleHitsXY.length; i++) {
		events6planehits.push(tracking6MiddleHitsXY[i][0]);
	}
	for (var i = 0; i < totalEvents; i++) { 
		if (events6planehits.includes(dxbothlayers[i][0])) {
			vals.push({x:dxbothlayers[i][4]/dxbothlayers[i][5], y:dybothlayers[i][4]/dybothlayers[i][5]});
		}
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
	//console.log(vals);
	return vals;
}//end of getDxyDzMiddle

//DELTA T 
function getDeltaT(index1, index2) {
	var vals = []
	for (var i = 0; i < globalThis.eventTime.length; i ++) {
		var time1 = globalThis.eventTime[i][index1];
		var time2 = globalThis.eventTime[i][index2];
		if (time1 > 0 && time2 > 0) {
			vals.push({x:i, y:time2-time1});
		}
	}
	return vals;
}// end of getDeltaT

//TRACK COUNTS
function getEventsWithTracksPerMinute(layerCount, option) {
    var vals = [];
    // Cache frequently used globals locally to avoid repeated global lookups
    var eventTime = globalThis.eventTime || [];
    var layerOrderX = globalThis.layerOrderX || [];
    var layerOrderY = globalThis.layerOrderY || [];
    var micro = microMinute;

    // Defensive guards for layerOrder arrays
    var safe = function(arr, i, j, fallback) {
        if (!Array.isArray(arr)) return fallback;
        if (arr.length <= i) return fallback;
        if (!Array.isArray(arr[i])) return fallback;
        if (typeof arr[i][j] === 'undefined') return fallback;
        return arr[i][j];
    };
    var xtop = safe(layerOrderX,2,2,-1);
    var xmiddle = safe(layerOrderX,1,2,-1);
    var xbottom = safe(layerOrderX,0,2,-1);
    var ytop = safe(layerOrderY,2,2,-1);
    var ymiddle = safe(layerOrderY,1,2,-1);
    var ybottom = safe(layerOrderY,0,2,-1);
    if (xtop !== -1) xtop = xtop*2; else xtop = -1;
    if (xmiddle !== -1) xmiddle = xmiddle*2; else xmiddle = -1;
    if (xbottom !== -1) xbottom = xbottom*2; else xbottom = -1;
    if (ytop !== -1) ytop = (ytop*2)+1; else ytop = -1;
    if (ymiddle !== -1) ymiddle = (ymiddle*2)+1; else ymiddle = -1;
    if (ybottom !== -1) ybottom = (ybottom*2)+1; else ybottom = -1;
    var startTime = 0;
    var minuteTime = micro + (eventTime[0] ? eventTime[0][0] : 0);
    var trackCounter = 0;

    for (var i = 0; i < eventTime.length; i++) {
        var et = eventTime[i];
        if (!Array.isArray(et)) continue;
        // Helper to read safely
        var v = function(idx) { return (typeof et[idx] === 'number') ? et[idx] : (et[idx] ? Number(et[idx]) : 0); };

        //check for top and bottom in both layers
        if (layerCount == 4) {
            if (option == 'TM') {
                if (v(xtop) > 0 && v(xmiddle) > 0 && v(xbottom) <= 0 && v(ytop) > 0 && v(ymiddle) > 0 && v(ybottom) <= 0) {
                    if (v(0) <= minuteTime) {
                        if (debugEventsWithTracks) {
                            console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
                        }
                        trackCounter += 1;
                    } else {
                        vals.push({x:startTime+1,y:trackCounter});
                        startTime += 1;
                        trackCounter = 0;
                        minuteTime = micro + v(0);
                    }
                }
            } else { //it is 'MB'
                if (v(xtop) <= 0 && v(xmiddle) > 0 && v(xbottom) > 0 && v(ytop) <= 0 && v(ymiddle) > 0 && v(ybottom) > 0) {
                    if (v(0) <= minuteTime) {
                        if (debugEventsWithTracks) {
                            console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
                        }
                        trackCounter += 1;
                    } else {
                        vals.push({x:startTime+1,y:trackCounter});
                        startTime += 1;
                        trackCounter = 0;
                        minuteTime = micro + v(0);
                    }
                }
            }
        }
        //check for top, middle and bottom but not in both layers
        if (layerCount == 5) {
            //middle missing
            if (option == 'M') {
                if ((v(xtop) > 0 && v(xbottom) > 0 && v(ytop) > 0 && v(ybottom) > 0) && ((v(xmiddle) > 0 && v(ymiddle) <= 0) || (v(xmiddle) <= 0 && v(ymiddle) > 0))) {
                    var count = et.filter(function(num){ return num > 0; }).length;
                    if (v(0) <= minuteTime && count == layerCount) {
                        if (debugEventsWithTracks) {
                            console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
                        }
                        trackCounter += 1;
                    } else {
                        vals.push({x:startTime+1,y:trackCounter});
                        startTime += 1;
                        trackCounter = 0;
                        minuteTime = micro + v(0);
                    }
                }
            } else { //it is TB, either top or bottom missing
                var count2 = et.filter(function(num){ return num > 0; }).length;
                if (v(xmiddle) > 0 && v(ymiddle) > 0 && count2 == layerCount) {
                    if (v(0) <= minuteTime) {
                        if (debugEventsWithTracks) {
                            console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
                        }
                        trackCounter += 1;
                    } else {
                        vals.push({x:startTime+1,y:trackCounter});
                        startTime += 1;
                        trackCounter = 0;
                        minuteTime = micro + v(0);
                    }
                }
            }
        }
        //check for top, middle and bottom in both layers
        if (layerCount == 6) {
            if (v(xtop) > 0 && v(xmiddle) > 0 && v(xbottom) > 0 && v(ytop) > 0 && v(ymiddle) > 0 && v(ybottom) > 0) {
                if (v(0) <= minuteTime) {
                    if (debugEventsWithTracks) {
                        console.log(i, layerCount, option, xtop, xmiddle, xbottom, ytop, ymiddle, ybottom, eventTime[i]);
                    }
                    trackCounter += 1;
                } else {
                    vals.push({x:startTime+1,y:trackCounter});
                    startTime += 1;
                    trackCounter = 0;
                    minuteTime = micro + v(0);
                }
            }
        }
    }
    vals.push({x:startTime+1,y:trackCounter});
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
    // Optimized grouping using Map to reduce property coercion overhead
    var grouped = new Map();
    for (var i = 0; i < data.length; i++) {
        var item = data[i];
        var x = item.x;
        var y = item.y;
        if (!grouped.has(x)) grouped.set(x, {sum: 0, count: 0});
        var entry = grouped.get(x);
        entry.sum += y;
        entry.count += 1;
    }
    var averageYPerX = {};
    grouped.forEach(function(val, key) {
        averageYPerX[key] = val.sum / val.count;
    });
    return averageYPerX;
}//end of getAverage