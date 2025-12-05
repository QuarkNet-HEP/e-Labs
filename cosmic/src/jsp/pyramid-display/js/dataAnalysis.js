let debugAnalysis = false;
let debugTracking = false;
let debugFunction = false; //turn on for Mark's review
let debugEventsWithTracks = false;
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
let pointTolerance = 1.0;
var investigatePlanes = [];
var eventMissingOnePlane = [];
var tracking6MiddleMissedX = [];
var tracking6MiddleMissedY = [];
var tracking6MiddleMissedXY = [];
var tracking6MiddleHitsXY = [];
var tracking5TopMissingX = [];
var tracking5MiddleMissingX = [];
var tracking5BottomMissingX = [];
var tracking5TopMissingY = [];
var tracking5MiddleMissingY = [];
var tracking5BottomMissingY = [];
var tracking4TopMissing = [];
var tracking4MiddleMissing = [];
var tracking4BottomMissing = [];

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

function getCAENdata(arr, layer) {
	var vals = [];
	for(var a = 0; a < arr.length; a++) {
		vals.push(arr[a][layer]);		
	}
	return vals;
}// end of getCAENdata

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
}//end of getDxyBothLayers

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
}//end of getDxyTopMiddleBothLayers

function getDxyBottomMiddleBothLayers() {
	//console.log(dxbottommiddle);
	//console.log(dybottommiddle);
	
	for (var i = 0; i < dxbottommiddle.length; i++) {
		var event = dxbottommiddle[i][0];
		for (var j = 0; j < dybottommiddle.length; j++) {
			if (dybottommiddle[j][0] == event) {
				//if (event < 50) {
				//	console.log(event, dxbottommiddle[i], dybottommiddle[j]);
				//}
				dxbottommiddlebothlayers.push(dxbottommiddle[i]);
				dybottommiddlebothlayers.push(dybottommiddle[j]);
			}
		}
	}
	//no need to keep these in memory
	dxbottommiddle = [];
	dybottommiddle = [];
}//end of getDxyBottomMiddleBothLayers

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

function arePointsAlmostCollinear(event, point1, point2, point3) {
	var eventsToTest = [];//64796,24066,55425];
	var m = 0;
	var x3 = point3[0];
	if ((point2[0] - point1[0]) != 0) {
		m = (point2[1] - point1[1]) / (point2[0] - point1[0]);
		if (m != 0) {
			x3 = (point3[1] - point1[1]) / m + point1[0];
		} else {
			//x3 = point3[0];
		}
	} 				
	
	var lowerBound = x3 - pointTolerance;
	var upperBound = x3 + pointTolerance;
	if (eventsToTest.includes(event)) {
		console.log("in collinear:", event, point1,point2,point3,m,x3,lowerBound,upperBound);
	}
	if (point3[0] >= lowerBound && point3[0] <= upperBound) {
		return true;		
	} else {
		return false;
	}
}//end of arePointsAlmostCollinear

function findExpectedX(point1, point2, y3) {
	var x3 = point1[0];
	if ((point2[0] - point1[0]) != 0) {
	   const m = (point2[1] - point1[1]) / (point2[0] - point1[0]);
	   if (m != 0) {
		x3 = (y3 - point1[1]) / m + point1[0];	
	   }
   	}
	return {x3, y3};
}//end of findExpectedX

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

function getBinnedData(arr) {
	var bins = [];
	var binCount = 0;
	var interval = 1;
	//var numOfBuckets = 20;
	var arrayMinValue = arrayMin(arr)-1;
	var arrayMaxValue = arrayMax(arr)+1;

	//Setup Bins
	for(var i = arrayMinValue; i <= arrayMaxValue; i += interval){
	  bins.push({
	    binNum: Math.floor(i),
	    minNum: i,
	    maxNum: i + interval,
	    count: 0
	  })
	  binCount++;
	}
	//Loop through data and add to bin's count
	for (var i = 0; i < arr.length; i++){
	  var item = arr[i];
	  for (var j = 0; j < bins.length; j++){
	    var bin = bins[j];
	    if(item > bin.minNum && item <= bin.maxNum){
	      bin.count++;
	      break;  // An item can only be in one bin.
	    }
	  }  
	}	
	return bins;
}//end of getBinnedData

function getFrequency6ExpectedActual(option, arr1, arr2) {
	//console.log(option, arr1, arr2);
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
			diff = arr2[i][2].x3 - arr2[i][1][4][0];
			diffCollection.push(diff);
		}
	}
	var binnedData = getBinnedData(diffCollection);
	var result = [];
	for (var i = 0; i < binnedData.length; i++) {
		result.push({x:binnedData[i].binNum, y:binnedData[i].count});
	}
	return result;
}//end of getFrequency6ExpectedActual

function checkTracking(event, arr, numberofplanes1, numberofplanes2) {
	var eventsToTest = [];//64796,24066,55425];
	var points = []; //we'll collect x layer points first and y layer next, always top to bottom
	for (var i = 0; i < arr.length; i++) {
			points.push(arr[i][2]);
			points.push(arr[i][3]);
			points.push(arr[i][4]);
	}
	var pointCount = 0;
	for (var j = 0; j < points.length; j++) {
		if (typeof points[j][0] != 'undefined' && typeof points[j][1] != 'undefined') {
			pointCount += 1;
		}
	}
	//console.log(event, pointCount, points);
	var allPointsInLineX = true;
	var allPointsInLineY = true;

	if (pointCount == 6) {
		//test if all points are in the line
		allPointsInLineX = arePointsAlmostCollinear(event,points[0],points[2],points[1]);	
		allPointsInLineY = arePointsAlmostCollinear(event,points[3],points[5],points[4]);
		if (eventsToTest.includes(event)) {
			console.log("pointsCollinear?: ", event, points, allPointsInLineX, allPointsInLineY);
			}		
		if (allPointsInLineX == false && allPointsInLineY == false) {
			// it is a miss in X and Y
			var expectedPointX = findExpectedX(points[0], points[2], points[1][1]);
			var expectedPointY = findExpectedX(points[3], points[5], points[4][1]);
			tracking6MiddleMissedXY.push([event, points, expectedPointX, expectedPointY]);
			if (eventsToTest.includes(event)) {
				console.log("both off for 6 plane tracks: ", event, points, expectedPointX, expectedPointY);
				}
		} else if (allPointsInLineX == false) {
			// it is only a miss in X
			var expectedPoint = findExpectedX(points[0], points[2], points[1][1]);
			tracking6MiddleMissedX.push([event, points, expectedPoint]);
			if (eventsToTest.includes(event)) {
				console.log("x off for 6 plane tracks: ", event, points, expectedPoint);
				}
		} else if (allPointsInLineY == false) {
			// it is only a miss in Y
			var expectedPoint = findExpectedX(points[3], points[5], points[4][1]);
			tracking6MiddleMissedY.push([event, points, expectedPoint]);			
			if (eventsToTest.includes(event)) {
				console.log("y off for 6 plane tracks: ", event, points, expectedPoint);
				}
		} else {
			//do nothing
		}
		if (allPointsInLineX && allPointsInLineY) {
			if (eventsToTest.includes(event)) {
				console.log("hits for 6 plane tracks: ", event, points);
				}

			tracking6MiddleHitsXY.push([event, points]);
			globalThis.eventFilter6.push(event+1);
		}
		if (debugTracking) {
			console.log(event, pointCount, points, allPointsInLineX, allPointsInLineY);
		}
	} 
	var missingPointNdx = -1;
	var expectedPoint = [];
	var y3 = -1;
	if (pointCount == numberofplanes1 || allPointsInLineX == false || allPointsInLineY == false) {
		//there is a missing point in one of the planes
		for (var i = 0; i < points.length; i++) {
			if (typeof points[i][0] === 'undefined') {
				missingPointNdx = i;
			}
		}
		switch (missingPointNdx) {
			case 0:
				y3 = layerOrderX[2][0];
				expectedPoint = findExpectedX(points[1], points[2], y3);
				tracking5TopMissingX.push([event, points, expectedPoint]);
				break;
			case 1:
				y3 = layerOrderX[1][0];
				expectedPoint = findExpectedX(points[2], points[0], y3);
				tracking5MiddleMissingX.push([event, points, expectedPoint]);
				break;
			case 2:
				y3 = layerOrderX[0][0];
				expectedPoint = findExpectedX(points[1], points[0], y3);
				tracking5BottomMissingX.push([event, points, expectedPoint]);					
				break;
			case 3:
				y3 = layerOrderY[2][0];
				expectedPoint = findExpectedX(points[4], points[5], y3);
				tracking5TopMissingY.push([event, points, expectedPoint]);					
				break;
			case 4:
				y3 = layerOrderY[1][0];
				expectedPoint = findExpectedX(points[3], points[5], y3);
				tracking5MiddleMissingY.push([event, points, expectedPoint]);					
				break;
			case 5: 
				y3 = layerOrderY[0][0];
				expectedPoint = findExpectedX(points[3], points[4], y3);
				tracking5BottomMissingY.push([event, points, expectedPoint]);					
				break;
			default:
				break;
		}
		globalThis.eventFilter5.push(event+1);
		//need to find out which one is missing
		if (debugTracking) {
			console.log(event, pointCount, missingPointNdx, points, expectedPoint );
		}
	}
	// there are two points missing, either at the top, middle or bottom
	if (pointCount == numberofplanes2) {
		var countMissing = 0;
		var indicesUndef = [];
		for (var i = 0; i < points.length; i++) {
			if (typeof points[i][0] === 'undefined') {
				countMissing += 1;
				indicesUndef.push(i);
			}
		}
		if (countMissing == 2) {
			if (debugTracking) {
				console.log(event, indicesUndef, points);
			}
			var firstMissing = indicesUndef[0];
			var secondMissing = indicesUndef[1];
			if (firstMissing == 0 && secondMissing == 3) {
				//we are dealing with top
				y3 = layerOrderX[2][0];
				xExpectedPoint = findExpectedX(points[1], points[2], y3);
				y3 = layerOrderY[2][0];
				yExpectedPoint = findExpectedX(points[4], points[5], y3);
				tracking4TopMissing.push([event, xExpectedPoint, yExpectedPoint]);
				globalThis.eventFilter4.push(event+1);
			}			
			if (firstMissing == 1 && secondMissing == 4) {
				//we are dealing with middle
				y3 = layerOrderX[1][0];
				xExpectedPoint = findExpectedX(points[2], points[0], y3);
				y3 = layerOrderY[1][0];
				yExpectedPoint = findExpectedX(points[3], points[5], y3);
				tracking4MiddleMissing.push([event, xExpectedPoint, yExpectedPoint]);
				globalThis.eventFilter4.push(event+1);
			}
			if (firstMissing == 2 && secondMissing == 5) {
				//we are dealing with bottom
				y3 = layerOrderX[0][0];
				xExpectedPoint = findExpectedX(points[1], points[0], y3);
				y3 = layerOrderY[0][0];
				yExpectedPoint = findExpectedX(points[3], points[4], y3);				
				tracking4BottomMissing.push([event, xExpectedPoint, yExpectedPoint]);
				globalThis.eventFilter4.push(event+1);
			}
		}
	}
}// end of checkTracking

function get6planemiddlehits(arr) {
	var vals = [];
	for (var i = 0; i < arr.length; i++) {
			vals.push({x:arr[i][1][1][0],y:arr[i][1][4][0],event: (arr[i][0]+1)});
			if (debugFunction) {
				console.log("6 plane hits: ",i,arr[i],arr[i][1][1],arr[i][1][4]);
				}
	}
	return vals;
}// end of get6planemiddlehits

function get6planemiddlemissed(arr, option) {
	var vals = [];
	for (var i = 0; i < arr.length; i++) {
		//there is only one missed, either X or Y
		//add expected x vs real y
		if (arr[i].length == 3) {
			vals.push({x:arr[i][2].x3,y:arr[i][1][4][0],event: (arr[i][0]+1)});
			if (debugFunction) {
				console.log("6 plane tracks: ",option,i,arr[i],arr[i][2].x3,arr[i][1][4][0]);
				}
		}
	
		if (arr[i].length == 4) {
			//there are missed points both in middle X and middle Y	
			//add expected x vs real y
			vals.push({x:arr[i][2].x3,y:arr[i][1][4][0],event: (arr[i][0]+1)});
			vals.push({x:arr[i][3].x3,y:arr[i][1][2][0],event: (arr[i][0]+1)});
			if (debugFunction) {
				console.log("6 plane tracks: ",i,option,arr[i],arr[i][2].x3,arr[i][1][4][0],arr[i][3].x3,arr[i][1][2][0]);
				}
		}	
	}
	return vals;
}// end of get6planemiddlemissed

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

function getTotalChartEvents(arr) {
	return arr.length;
}//end of getTotalChartEvents

function checkCalculatedX(point1, point2, y3) {
   const m = (point2.y - point1.y) / (point2.x - point1.x);
   const x3 = (y3.y - point1.y) / m + point1.x;
   if (isNaN(x3)) {
	   return {x:point1.x, y:y3.y};	
   } else {
	   return {x:x3, y:y3.y};
   }
}// end of checkCcalculatedX

//attempt to calculate delta
function calculateDeltaPointByPercentage(event, x1, y1, x2, y2, percentage, yProjected,eventChannels, layer, zValue, neighbors) {
	var eventsToTest = [];
	var dx = x2 - x1;
	var dy = y2 - y1;
	//const x = ((x1 + (dx * percentage/100))/(size/2.0))+1;
	const x = ((x1 + (dx * percentage/100.0))/(overallCellSize/2.0))+0.5
	if (eventsToTest.includes(event)) {
		//console.log("percent0:",x2, x1, x2-x1);
		console.log("percent:",event, x1, x2, dx,percentage,x);
	}
	var y = zValue;
	if (neighbors[0] < neighbors[1]) {										
		var channel1 = eventChannels[layer][0];
		var channel2 = eventChannels[layer][1];
	} else {
		var channel1 = eventChannels[layer][1];
		var channel2 = eventChannels[layer][0];		
	}
  	return { x, y, yProjected, channel1, channel2};
}//end of calculatePointByPercentage

function getSingleDeltaSidePoint(event, layerTriangle,eventChannels, layer, zValue) {
	var eventsToTest = [];
	var sidePoint = [];
	var x1 = layerTriangle[2][0];
	var x2 = layerTriangle[3][0];
	var x3 = layerTriangle[4][0];
	//var x = (((x1 + x2 + x3)/3) /(size/2.0))+1;
	var x = (((x1 + x2 + x3)/3) /(overallCellSize/2.0))+0.5;
	var y = zValue;
	//var yProjected = (y /(size/2.0))+1;
	var yProjected = (y /(overallCellSize/2.0))+0.5;
	var channel1 = -1; 
	if (eventChannels[layer].length === 0) {
		channel1 = -1;
	} else {
		channel1 = eventChannels[layer][0];
	}
	if (eventsToTest.includes(event)) {
		console.log("single point:",event, x1,x2,x3,x, eventChannels);
	}
	var channel2 = -1;
	sidePoint = {x, y, yProjected, channel1, channel2};	
	return sidePoint; 
}//end of getSingleSidePoint

function getDeltaIndexesOfTwoHighest(arr) {
  // 1. Create an array of objects with value and original index
  const indexedArray = arr.map((value, index) => ({ value, index }));

  // 2. Sort the array in descending order based on value
  indexedArray.sort((a, b) => b.value - a.value);

  // 3. Extract the indices of the top two elements
  if (indexedArray.length >= 2) {
    return [indexedArray[0].index, indexedArray[1].index];
  } else if (indexedArray.length === 1) {
    return [indexedArray[0].index]; // Return only one index if array has only one element
  } else {
    return []; // Return an empty array for an empty input array
  }
}

function analyzeDeltaCluster(event, x,arr) {
	var eventsToTest = [];//41,110,9674,9681,9725,9858,9956];
	var ndx = [];
	var intensities = [];
	var lastX = 0;
	if (eventsToTest.includes(event)) {			
	 console.log("it gets here 0:", x,arr);
	 }
	if (arr.length-x == 2 && (arr[arr.length-1][0] - arr[arr.length-2][0] <= overallCellSize)) {
		intensities.push(arr[arr.length-2][1]);		
		intensities.push(arr[arr.length-1][1]);	
		if (eventsToTest.includes(event)) {			
		 //console.log("it gets here 1:", arr, arr[arr.length-1][0] - arr[arr.length-2][0], intensities);
		 }
	} else {
		for (var i = x; i < arr.length-1; i++) {
			if (arr[i+1][0] - arr[i][0] <= overallCellSize && intensities.length < 2) {
				//these are neighbors
				intensities.push(arr[i][1]);
				if (eventsToTest.includes(event)) {			
				 //console.log("it gets here 2:", intensities);
				 }
			}
			lastX = i;
		}
		//deal with one more item
		if (eventsToTest.includes(event)) {			
		 console.log("it gets here 3:", lastX, arr.length, intensities);
		}	
		if (arr.length >= lastX && lastX >= 1  && intensities.length < 2) {
			if (arr[lastX][0] - arr[lastX-1][0] <= overallCellSize) {
				intensities.push(arr[lastX][1])
			if (eventsToTest.includes(event)) {			
			 console.log("it gets here 3:", lastX, arr[lastX][0], arr[lastX-1][0],arr[lastX][0] - arr[lastX-1][0], intensities);
			}	
			}	
		}
	}
	ndx = getIndexesOfTwoHighest(intensities);
	for (var i = 0; i < ndx.length; i++) {
		ndx[i] += x;
	}
	if (eventsToTest.includes(event)) {			
	 console.log("it gets here last:", ndx);
	 }
	return ndx;
}

function getDeltaSidePointFromNeighbors(event, x, layerTriangle, layerAct, layer, eventChannels, zValue) {
	var eventsToTest = [];//26020,566119073,34789	
	var sidePoint = [];
	var yProjected = 0;
	var up = true;
	var x1 = 0;
	var y1 = 0;
	var x2 = 0;
	var y2 = 0;
	var point1Intensity = 0;
	var point2Intensity = 0;
	var neighborEventChannels = [];
	var neighbors = analyzeDeltaCluster(event,x,layerAct[layer]);
	if (eventsToTest.includes(event)) {
		//console.log("neighbors: ", neighbors, x, layerAct, layer, layerAct[layer]);
	}
	if (neighbors.length > 1) {
		if (neighbors[0] < neighbors[1]) {										
			up = layerTriangle[layer][neighbors[0]][0];					
			x1 = layerTriangle[layer][neighbors[0]][3][0];
		    y1 = layerTriangle[layer][neighbors[0]][3][1];
			x2 = layerTriangle[layer][neighbors[0]][4][0];
			y2 = layerTriangle[layer][neighbors[0]][4][1];
			yProjected = layerTriangle[layer][neighbors[0]][5];
			point1Intensity = layerTriangle[layer][neighbors[0]][1];
			point2Intensity = layerTriangle[layer][neighbors[1]][1];
		} else {
			up = layerTriangle[layer][neighbors[1]][0];					
			x1 = layerTriangle[layer][neighbors[1]][3][0];
			y1 = layerTriangle[layer][neighbors[1]][3][1];
			x2 = layerTriangle[layer][neighbors[1]][4][0];
			y2 = layerTriangle[layer][neighbors[1]][4][1];
			yProjected = layerTriangle[layer][neighbors[1]][5];
			point1Intensity = layerTriangle[layer][neighbors[1]][1];
			point2Intensity = layerTriangle[layer][neighbors[0]][1];						
		}
		var pointPercent = 0;
		var pointPercentSum = point1Intensity + point2Intensity;
		//console.log("get points from neighbors:", eventChannels, neighbors, neighborEventChannels);
		if (up) {
		   if (point1Intensity > point2Intensity) {
			 //first triangle is pyramid with higher intensity
			 pointPercent = point1Intensity * 100 / pointPercentSum;
			 sidePoint = calculateDeltaPointByPercentage(event,x1, y1, x2, y2, pointPercent, yProjected,eventChannels, layer, zValue, neighbors);
		   } else {
			 //first triangle is pyramid with lower intensity			 
			 pointPercent = point2Intensity * 100 / pointPercentSum;
			 sidePoint = calculateDeltaPointByPercentage(event, x2, y2, x1, y1, pointPercent, yProjected,eventChannels, layer, zValue, neighbors);
		   }			
		} else {
			if (point1Intensity > point2Intensity) {
			 //first triangle is down with higher intensity
			 pointPercent = point1Intensity * 100 / pointPercentSum;
			 sidePoint = calculateDeltaPointByPercentage(event, x1, y1, x2, y2, pointPercent, yProjected,eventChannels, layer, zValue, neighbors);
			} else {
		     //the first triangle is down with lower intensity
			 pointPercent = point2Intensity * 100 / pointPercentSum;
			 sidePoint = calculateDeltaPointByPercentage(event, x2, y2, x1, y1, pointPercent, yProjected,eventChannels, layer, zValue, neighbors);
			}
		}
	}
	return sidePoint;	
}//end of getDeltaSidePointFromNeighbors


function calculateDeltaSidePoint(event, layerAct, layerTriangle,eventChannels, layer, zValue) {
		var layerTracker = [];
		var eventsToTest = [];//26020,566119073,34789
		var sidePointGroup = [];
		var sidePoint = [];
		var yProjected = 0;
		if (layerTriangle[layer].length > 0) {
		  if (layerTriangle[layer].length == 1) {
			//the point falls in the middle of the triangle
			sidePoint = getSingleDeltaSidePoint(event, layerTriangle[layer][0],eventChannels, layer, zValue);
			if (eventsToTest.includes(event)) {
				//console.log("single point 1:", sidePoint ,layerTriangle[layer]);
			}
			sidePointGroup.push(sidePoint);
		  }	else {
			for (var x = 0; x < layerTriangle[layer].length-1; x++) {
				//var quadFirstCell = layerTriangle[layer][x][6];
				//var quadSecondCell = layerTriangle[layer][x+1][6];
				//var firstX = layerTriangle[layer][x][3][0];
				//var secondX = layerTriangle[layer][x+1][4][0];
				var layerValueDiff = layerAct[layer][x+1][0]-layerAct[layer][x][0];
				if (eventsToTest.includes(event)) {
					//console.log("checking neighbors:", layerValueDiff, layer, layerAct[layer]);
				}
				//these are not neighbors	
				if (layerValueDiff != 17.5 && layerValueDiff > overallCellSize && !layerTracker.includes(x)) {
					sidePoint = getSingleDeltaSidePoint(event, layerTriangle[layer][x],eventChannels, layer, zValue);
					if (eventsToTest.includes(event)) {
						console.log("single point 2-not neighbors:", sidePoint);
					}
					sidePointGroup.push(sidePoint);
					layerTracker.push(x);
				} else {
					if (!layerTracker.includes(x)) {
						var sidePoint = getDeltaSidePointFromNeighbors(event, x, layerTriangle, layerAct, layer, eventChannels, zValue);
						if (eventsToTest.includes(event)) {
							console.log("point 3-neighbors:", sidePoint);
						}
						if (!isPointInGroup(sidePoint, sidePointGroup)) {
						  sidePointGroup.push(sidePoint);
						}
					}			
					layerTracker.push(x);
					x += 1;
				 }
			 layerTracker.push(x);
			 }
		   }
			//need to deal with the last points
			if (layerTriangle[layer].length > 1) {
				//var quadFirstCell = layerTriangle[layer][layerTriangle[layer].length-2][6];
				//var quadSecondCell = layerTriangle[layer][[layerTriangle[layer].length-1]][6];
				//var firstX = layerTriangle[layer][[layerTriangle[layer].length-2]][3][0];
				//var secondX = layerTriangle[layer][[layerTriangle[layer].length-1]][4][0];
				var layerValueDiff = layerAct[layer][[layerTriangle[layer].length-1]][0]-layerAct[layer][[layerTriangle[layer].length-2]][0];
				var x = layerTriangle[layer].length-2;
				if (!layerTracker.includes(x)) {
					var neighbors = analyzeDeltaCluster(event, x,layerAct[layer]);
					if (neighbors.length > 1) {
						var sidePoint = getDeltaSidePointFromNeighbors(event, x, layerTriangle, layerAct, layer, eventChannels, zValue);
						if (eventsToTest.includes(event)) {
							console.log("last point 1 - neighbors:", sidePoint);
						}
						if (isPointInGroup(sidePoint, sidePointGroup)) {
						//do nothing
						} else {
							  sidePointGroup.push(sidePoint);
						}
					} else {
					    if (layerValueDiff != 17.5 && layerValueDiff > overallCellSize && !layerTracker.includes(x)) {
							  //we still need to deal with the last point
						  sidePoint = getSingleDeltaSidePoint(event, layerTriangle[layer][layerTriangle[layer].length-1], eventChannels,layer, zValue);
						  if (eventsToTest.includes(event)) {
						  	console.log("last point 2 - not neighbors:", sidePoint);
						  }
						  if (isPointInGroup(sidePoint, sidePointGroup)) {
							//do nothing
						  } else {
						  	  sidePointGroup.push(sidePoint);
						  } 
						}		
					}
				}			
			}
		  }// end of checking if there are points to work with
		return sidePointGroup;
}//end of calculateSidePoint

function calculateDeltaTrack(whichLayer, event, layerAct, layerQuad, layerQuadSize, layerTriangle, layerOrder,eventChannels){
  var eventsToTest = [];//64796,24066,55425];//[4968,3410,22605];
  var sidePointX1 = calculateDeltaSidePoint(event, layerAct, layerTriangle,eventChannels, layerOrder[0][2], layerOrder[0][0]);
  var sidePointX2 = calculateDeltaSidePoint(event, layerAct, layerTriangle,eventChannels, layerOrder[1][2], layerOrder[1][0]);
  var sidePointX3 = calculateDeltaSidePoint(event, layerAct, layerTriangle,eventChannels, layerOrder[2][2], layerOrder[2][0]);
  var expectedMiddlePoint = ''; 
  var pointX1 = {x:undefined, y:undefined, yProjected:undefined, channel1: -1,channel2:-1};
  var pointX2 = {x:undefined, y:undefined, yProjected:undefined, channel1: -1,channel2:-1};
  var pointX3 = {x:undefined, y:undefined, yProjected:undefined, channel1: -1,channel2:-1};
  var tempX1 = {x:undefined, y:undefined, yProjected:undefined, channel1: -1,channel2:-1};
  var tempX2 = {x:undefined, y:undefined, yProjected:undefined, channel1: -1,channel2:-1};
  var tempX3 = {x:undefined, y:undefined, yProjected:undefined, channel1: -1,channel2:-1};
  //get the first point of a group (we do not know if there is a group)
  if (sidePointX1.length > 0) {
  	pointX1 = sidePointX1[0];
  } 
  if (sidePointX2.length > 0) {
	pointX2 = sidePointX2[0];
  } 
  if (sidePointX3.length > 0) {
	pointX3 = sidePointX3[0];
 } 
 var diff = 1000.0;  
 //determine best track for all the data analysis
 // check if there is a middle point first in order to get the best one
 if (sidePointX2.length > 0) {
	//now check if it belongs to a full track
	if (sidePointX1.length > 0 && sidePointX3.length > 0) {
		//loop through the middle points
		for (var i = 0; i < sidePointX2.length; i++) {
			var middlePoint = sidePointX2[i];
			if (eventsToTest.includes(event)) {
			console.log("getting best point from these :", middlePoint);
			}
			//test case 1: 1 point in one of the other layer and more points in one of the other layers
			if (sidePointX3.length > 1 && sidePointX1.length == 1) {
				for (var j = 0; j < sidePointX3.length; j++) {
					//need to check if this middle point is the best for the other layer points
					expectedMiddlePoint = checkCalculatedX(sidePointX1[0],sidePointX3[j],middlePoint);
					//console.log(event, whichLayer, middlePoint, expectedMiddlePoint);
					if (Math.abs(middlePoint.x - expectedMiddlePoint.x) < diff) {
						diff = Math.abs(middlePoint.x - expectedMiddlePoint.x);
						tempX1 = sidePointX1[0];
						tempX2 = middlePoint;
						tempX3 = sidePointX3[j];	
						if (eventsToTest.includes(event)) {
							console.log("case 1 :", middlePoint.x, expectedMiddlePoint.x, diff, tempX2);
						}
					}					
				}
			}
			//test case 2: reverse case from above
			if (sidePointX1.length > 1 && sidePointX3.length == 1) {
				for (var j = 0; j < sidePointX1.length; j++) {
					expectedMiddlePoint = checkCalculatedX(sidePointX1[j],sidePointX3[0],middlePoint);
					//console.log(event, whichLayer, middlePoint, expectedMiddlePoint);
					if (Math.abs(middlePoint.x - expectedMiddlePoint.x) < diff) {
						diff = Math.abs(middlePoint.x - expectedMiddlePoint.x);
						tempX1 = sidePointX1[j];
						tempX2 = middlePoint;
						tempX3 = sidePointX3[0];	
						if (eventsToTest.includes(event)) {
							console.log("case 2 :", middlePoint.x, expectedMiddlePoint.x, diff, tempX2);
						}
					}
				}
			}
			//test case 3: there is only one point in both other layers
			if (sidePointX1.length == 1 && sidePointX3.length == 1) {
				expectedMiddlePoint = checkCalculatedX(sidePointX1[0],sidePointX3[0],middlePoint);
				//console.log(event, whichLayer, middlePoint, expectedMiddlePoint);
				if (Math.abs(middlePoint.x - expectedMiddlePoint.x) < diff) {
					diff = Math.abs(middlePoint.x - expectedMiddlePoint.x);
					tempX1 = sidePointX1[0];
					tempX2 = middlePoint;
					tempX3 = sidePointX3[0];	
					if (eventsToTest.includes(event)) {
						console.log("case 3 :", middlePoint.x, expectedMiddlePoint.x, diff, tempX2);
					}
				}
			}
			//test case 4: both layers have multiple points
			if (sidePointX1.length > 1 && sidePointX3.length > 1) {
				for (var j = 0; j < sidePointX1.length; j++) {
					for (var k = 0; k < sidePointX3.length; k++) {
						expectedMiddlePoint = checkCalculatedX(sidePointX1[j],sidePointX3[k],middlePoint);
						//console.log(event, whichLayer, middlePoint, expectedMiddlePoint);
						if (Math.abs(middlePoint.x - expectedMiddlePoint.x) < diff) {
							diff = Math.abs(middlePoint.x - expectedMiddlePoint.x);
							tempX1 = sidePointX1[j];
							tempX2 = middlePoint;
							tempX3 = sidePointX3[k];	
							if (eventsToTest.includes(event)) {
								console.log("case 4 :", middlePoint.x, expectedMiddlePoint.x, diff, tempX2);
							}
						}					
					}
				}
			}			
			if (typeof tempX1.x != "undefined" && tempX1.x != pointX1.x) {
				pointX1 = tempX1;
				//console.log(event, whichLayer, sidePointX1, pointX1);
			}
			if (typeof tempX2.x != "undefined" && tempX2.x != pointX2.x) {
				pointX2 = tempX2;
				//console.log(event, whichLayer, sidePointX2, pointX2);
			}
			if (typeof tempX3.x != "undefined" && tempX3.x != pointX3.x) {
				pointX3 = tempX3;
				//console.log(event, whichLayer, sidePointX3, pointX3);
			}							
		}	
	}
}
  if (eventsToTest.includes(event)) {
	console.log(sidePointX1, sidePointX2, sidePointX3, pointX1, pointX2, pointX3);
  }
  //investigate tracking
  var xTopPoint = [undefined,undefined];
  var xMiddlePoint = [undefined,undefined];
  var xBottomPoint = [undefined,undefined];
  var yTopPoint = [undefined,undefined];
  var yMiddlePoint = [undefined,undefined];
  var yBottomPoint = [undefined,undefined]; 
  if (whichLayer == 'X') {	
	 	xTopPoint = [pointX3.x, pointX3.y];
	  	xMiddlePoint = [pointX2.x, pointX2.y];
	  	xBottomPoint = [pointX1.x, pointX1.y];
	 investigatePlanes.push([whichLayer,event,xTopPoint,xMiddlePoint,xBottomPoint]);
   } else {
	    yTopPoint = [pointX3.x, pointX3.y];
 	  	yMiddlePoint = [pointX2.x, pointX2.y];
	  	yBottomPoint = [pointX1.x, pointX1.y];
	 investigatePlanes.push([whichLayer,event,yTopPoint,yMiddlePoint,yBottomPoint]);
  	  if (investigatePlanes.length >= 2) {
		checkTracking(event, investigatePlanes, 5, 4);
  		investigatePlanes = [];
	  }
   }
  
  if (pointX1.x > 0 && pointX3.x > 0) {
	var deltax = (pointX3.x - pointX1.x);
	var deltaz = (pointX3.y - pointX1.y);
	if (whichLayer == 'X') {
		dx.push([event, pointX1, pointX2, pointX3, deltax, deltaz]);
	} else {
		dy.push([event, pointX1, pointX2, pointX3, deltax, deltaz]);
	}
  } else {
	//test middle layer
		if (pointX1.x > 0 && pointX2.x > 0) {
			var deltax = (pointX2.x - pointX1.x);
			var deltaz = (pointX2.y - pointX1.y);
			if (whichLayer == 'X') {
				dxbottommiddle.push([event, pointX1, pointX2, pointX3, deltax, deltaz]);
			} else {
				dybottommiddle.push([event, pointX1, pointX2, pointX3, deltax, deltaz]);
			}		
		} else {
				var deltax = (pointX3.x - pointX2.x);
				var deltaz = (pointX3.y - pointX2.y);
				if (whichLayer == 'X') {
					dxtopmiddle.push([event, pointX1, pointX2, pointX3, deltax, deltaz]);
				} else {
					dytopmiddle.push([event, pointX1, pointX2, pointX3, deltax, deltaz]);
				}					
		}
	}
 }//end of calculateDeltaTrack

 // Function to populate the datalist dynamically
function populateDatalist(whichList, arr) {
     const datalist = document.getElementById(whichList);
     arr.forEach(value => {
         const option = document.createElement('option');
	     option.value = value;
     });
}
 
function populateDropdownSix() {
	populateDatalist('6planevaluesList', globalThis.eventFilter6);
	let oldIndex = 0; // Start with the first value
	const inputElement = document.getElementById('quantity6');
	inputElement.value = globalThis.eventFilter6[oldIndex]; // Set initial value
	inputElement.addEventListener('input', handleInputChange);
	function handleInputChange(event) {
	    const input = event.target;
	    let goalValue = parseInt(input.value, 10);
	    let newIndex = oldIndex;
	    // Determine the direction of change and update index
	    if (goalValue > globalThis.eventFilter6[oldIndex]) {
	        newIndex++;
	        // Keep index within bounds
	        if (newIndex >= globalThis.eventFilter6.length) newIndex = globalThis.eventFilter6.length - 1;
	    } else if (goalValue < globalThis.eventFilter6[oldIndex]) {
	        newIndex--;
	        // Keep index within bounds
	        if (newIndex < 0) newIndex = 0;
	    }
	    
	    // Update the input value to the corresponding list value
	    oldIndex = newIndex;
	    input.value = globalThis.eventFilter6[newIndex];
		if (is_numeric(input.value)) {
			if (input.value > 0) {
			  draw(input.value-1);
			} 
		}
	}
}//end of populateDropdownSix

function populateDropdownFive() {
	populateDatalist('5planevaluesList', globalThis.eventFilter5);
	let oldIndex = 0; // Start with the first value
	const inputElement = document.getElementById('quantity5');
	inputElement.value = globalThis.eventFilter5[oldIndex]; // Set initial value
	// Use the 'input' event to capture changes from both typing and spinner buttons
	inputElement.addEventListener('input', handleInputChange);
	// Function to handle input changes (spinner clicks or manual entry)	
	function handleInputChange(event) {
	    const input = event.target;
	    let goalValue = parseInt(input.value, 10);
	    let newIndex = oldIndex;

	    // Determine the direction of change and update index
	    if (goalValue > globalThis.eventFilter5[oldIndex]) {
	        newIndex++;
	        // Keep index within bounds
	        if (newIndex >= globalThis.eventFilter5.length) newIndex = globalThis.eventFilter5.length - 1;
	    } else if (goalValue < globalThis.eventFilter5[oldIndex]) {
	        newIndex--;
	        // Keep index within bounds
	        if (newIndex < 0) newIndex = 0;
	    }
	    
	    // Update the input value to the corresponding list value
	    oldIndex = newIndex;
	    input.value = globalThis.eventFilter5[newIndex];
		if (is_numeric(input.value)) {
			if (input.value > 0) {
			  draw(input.value-1);
			} 
		}
	}	
}//end of populateDropdownFive 
 
function populateDropdownFour() {
	populateDatalist('4planevaluesList', globalThis.eventFilter4);
	let oldIndex = 0; // Start with the first value
	// Function to handle input changes (spinner clicks or manual entry)
	const inputElement = document.getElementById('quantity4');
	inputElement.value = globalThis.eventFilter4[oldIndex]; // Set initial value
	// Use the 'input' event to capture changes from both typing and spinner buttons
	inputElement.addEventListener('input', handleInputChange);
	function handleInputChange(event) {
	    const input = event.target;
	    let goalValue = parseInt(input.value, 10);
	    let newIndex = oldIndex;

	    // Determine the direction of change and update index
	    if (goalValue > globalThis.eventFilter4[oldIndex]) {
	        newIndex++;
	        // Keep index within bounds
	        if (newIndex >= globalThis.eventFilter4.length) newIndex = globalThis.eventFilter4.length - 1;
	    } else if (goalValue < globalThis.eventFilter4[oldIndex]) {
	        newIndex--;
	        // Keep index within bounds
	        if (newIndex < 0) newIndex = 0;
	    }
	    
	    // Update the input value to the corresponding list value
	    oldIndex = newIndex;
	    input.value = globalThis.eventFilter4[newIndex];
		if (is_numeric(input.value)) {
			if (input.value > 0) {
			  draw(input.value-1);
			} 
		}
	}	
}//end of populateDropdownFour

function drawDeltaTriangle(dir, xpos, y, channel, inten, quadMember) {
	  var triangleCoords = [];
	  triangleCoords.push(dir,inten);
	  if(isNaN(inten)){
	    inten = 0;
	  }
	  triangleCoords.push([xpos, y]);
	  triangleCoords.push([xpos+size, y]);
	  //triangleCoords.push([xpos+overallCellSize, y]);
	  var y3 = 0;
	  var height = 0;
	  if (dir) {
		  y3 = y-(Math.sqrt(3) * size / 2);
		  height = y-((Math.sqrt(3) * size / 2)/2.0);
		  triangleCoords.push([xpos+(size/2), y3]);
		  //y3 = y-(Math.sqrt(3) * overallCellSize / 2);
		  //height = y-((Math.sqrt(3) * overallCellSize / 2)/2.0);
		  //triangleCoords.push([xpos+(overallCellSize/2), y3]);
	  } else { 
		  y3 = y+(Math.sqrt(3) * size / 2);
		  height = y+((Math.sqrt(3) * size / 2)/2.0);
	      triangleCoords.push([xpos+(size/2), y3]);
		  //y3 = y+(Math.sqrt(3) * overallCellSize / 2);
		  //height = y+((Math.sqrt(3) * overallCellSize / 2)/2.0);
		  //triangleCoords.push([xpos+(overallCellSize/2), y3]);
	  }
	  if(inten == 0){
		triangleCoords = [];
	  } else {
		//do nothing
	  }   
	  triangleCoords.push(height, quadMember);
	return triangleCoords;
}//end of drawDeltaTriangle

function calculateDeltaQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,coordArray,ped,layerQuad,quadMember,layerQuadSize,cellSize,quadGap,layerTriangle,eventChannels) {
	var adcChannel;
	var pedPosition;
	var triangleCoords = [];
	if(up){
		if (reversed) {
			//need to reverse the channels
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
			pedPosition = (numQuads * 4) - channelPosition;
	        //triangleCoords = drawDeltaTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
			triangleCoords = drawDeltaTriangle(true, up ? xp - (cellSize/2)+1 : xp+(cellSize/2)+1, yp+cellSize-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	//layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channelPosition]]);
				layerAct[layer].push([up ? xp - (cellSize/2) : xp+(cellSize/2) , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        //triangleCoords = drawDeltaTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
			triangleCoords = drawDeltaTriangle(true, up ? xp - (cellSize/2)+1 : xp+(cellSize/2)+1, yp+cellSize-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	//layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channel]]);
				layerAct[layer].push([up ? xp - (cellSize/2) : xp+(cellSize/2) , ped[event][layer][channel]]);
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
	        //triangleCoords = drawDeltaTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
			triangleCoords = drawDeltaTriangle(true, up ? xp - (cellSize/2)+1 : xp+(cellSize/2)+1, yp+cellSize-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	//layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channelPosition]]);
				layerAct[layer].push([up ? xp - (cellSize/2) : xp+(cellSize/2) , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);				
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        //triangleCoords = drawDeltaTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
			triangleCoords = drawDeltaTriangle(true, up ? xp - (cellSize/2)+1 : xp+(cellSize/2)+1, yp+cellSize-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	//layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channel]]);
				layerAct[layer].push([up ? xp - (cellSize/2) : xp+(cellSize/2) , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords);
				eventChannels[layer].push(adcChannel);				 
	        }
		}
	    channel++;

	}// end if inside for loop
	return channel;
}//end of calculateDeltaQuad

function calculateLayer(whichLayer, event) {
	 var eventsToTest = []; 
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
				  	channel = calculateDeltaQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,xCoord,subtractPedX,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle,eventChannels);
				  } else {
				  	channel = calculateDeltaQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,yCoord,subtractPedY,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle,eventChannels);					  
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
  globalThis.eventFilter6.push(" ");
  globalThis.eventFilter5.push(" ");
  globalThis.eventFilter4.push(" ");
  for (var event = 0; event < subtractPedX.length; event++) {
	  calculateLayer('X', event); 
  	  calculateLayer('Y', event); 
  }
}//end of getdxy
