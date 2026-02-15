/*
	Edit Peronja 23/10/2025: all these functions are to provide the data for dataCharts
							 they are similar to the function in draw2D.js but these are
							 executed for all events at once.
 */
 let debugTracking = false;
 let debugEventsWithTracks = false;
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
 var investigatePlanes = [];
 var eventMissingOnePlane = [];
 var tracking6MiddleMissedX = [];
 var tracking6MiddleMissedY = [];
 var tracking6MiddleMissedXY = [];
 var tracking6MiddleHitsXY = [];
 var tracking6MiddleHitsOnlyX = [];
 var tracking6MiddleHitsOnlyY = [];
 var tracking6MiddleHitsXsingleTopBottom = [];
 var tracking6MiddleHitsYsingleTopBottom = [];
 var tracking6MiddleHitsXsingleBothLayers = [];
 var tracking5TopMissingX = [];
 var tracking5MiddleMissingX = [];
 var tracking5BottomMissingX = [];
 var tracking5TopMissingY = [];
 var tracking5MiddleMissingY = [];
 var tracking5BottomMissingY = [];
 var tracking4TopMissing = [];
 var tracking4MiddleMissing = [];
 var tracking4BottomMissing = [];
const pointTolerance = 3.0; // in cm, this is the tolerance we use to determine if a point is close enough to the expected point to be considered a hit, this can be adjusted based on the resolution of the detector and the expected scattering of the particles.
// Cache some global math constants to avoid repeated Math.sqrt calls in hot paths
const SQRT3 = Math.sqrt(3);
const pointWidth = 2.0; // in cm.

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
 
function arePointsAlmostCollinear(event, point1, point2, point3) {
	var eventsToTest = [];//111,112,113,114,115,116];//64796,24066,55425];
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
 
function analyzeTracking(event, arr, numberofplanes1, numberofplanes2) {
 	var eventsToTest = [];//111,112,113,114,115,116];//64796,24066,55425];
 	// we'll collect x layer points first and y layer next, always top to bottom
 	// Preallocate points array size: arr.length * 3 (we push 3 items per iteration)
 	var points = new Array(arr.length * 3);
 	var xLayerHitCount = [];
 	var yLayerHitCount = [];
 	if (eventsToTest.includes(event)) {
 		console.log(event, arr);
 	}
 	// fill the preallocated points array by index to avoid push allocations
 	for (var i = 0, p = 0; i < arr.length; i++, p += 3) {
 		points[p] = arr[i][2];
 		points[p+1] = arr[i][3];
 		points[p+2] = arr[i][4];
 	}
 	if (arr.length > 1) {
 		xLayerHitCount.push(arr[0][5]);
 		xLayerHitCount.push(arr[0][6]);
 		yLayerHitCount.push(arr[1][5]);
 		yLayerHitCount.push(arr[1][6]);
 	}
 	//console.log(event, arr);
 	var pointCount = 0;
 	for (var j = 0; j < points.length; j++) {
 		if (typeof points[j] != 'undefined' && typeof points[j][0] != 'undefined' && typeof points[j][1] != 'undefined') {
 			pointCount += 1;
 		}
 	}
 	//console.log(event, pointCount, points);
 	var allPointsInLineX = true;
 	var allPointsInLineY = true;
 	if (eventsToTest.includes(event)) {
 		console.log("check tracking: ", event, arr, points, xLayerHitCount, yLayerHitCount, pointCount);
 		}

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
 		// if all points are collinear, look further
 		if (allPointsInLineX && allPointsInLineY) {
 			//X layer: test if there is only one top and bottom hit in both layers
 			if (xLayerHitCount[0] == 1 && xLayerHitCount[1] == 1 && yLayerHitCount[0] == 1 && yLayerHitCount[1] == 1) {
 				tracking6MiddleHitsXsingleBothLayers.push([event, points]);
 			if (eventsToTest.includes(event)) {
 				console.log("XY layer, hits for 6 plane tracks: ", event, points, xLayerHitCount, tracking6MiddleHitsXsingleBothLayers);
 				}
 			} else if (xLayerHitCount[0] == 1 && xLayerHitCount[1] == 1) {
 				tracking6MiddleHitsXsingleTopBottom.push([event, points]);
 			if (eventsToTest.includes(event)) {
 				console.log("X layer, hits for 6 plane tracks: ", event, points, xLayerHitCount, tracking6MiddleHitsXsingleTopBottom);
 				}
 		    } else if (yLayerHitCount[0] == 1 && yLayerHitCount[1] == 1) {
 				//Y layer: test if there is only one top and bottom hit, if so, save for chart
 				tracking6MiddleHitsYsingleTopBottom.push([event, points]);
 				if (eventsToTest.includes(event)) {
 					console.log("Y layer, hits for 6 plane tracks: ", event, points, yLayerHitCount, tracking6MiddleHitsYsingleTopBottom);
 				}
 			} else {
 				//do nothing
 			}
 			//get the expected point event if it passes the tolerance for a different chart
 			var expectedPointX = findExpectedX(points[0], points[2], points[1][1]);
 			var expectedPointY = findExpectedX(points[3], points[5], points[4][1]);
 			tracking6MiddleHitsXY.push([event, points, expectedPointX, expectedPointY]);
 			if (eventsToTest.includes(event)) {
 				console.log("expected points even if they passed the tolerance: ", event, tracking6MiddleHitsXY);
 				}
 			globalThis.eventFilter6.push(event+1);
 		}
		if (allPointsInLineX == true) {
			//collect only for x layer
			//get the expected point event if it passes the tolerance for a different chart
			var expectedPointX = findExpectedX(points[0], points[2], points[1][1]);
			tracking6MiddleHitsOnlyX.push([event, points, expectedPointX]);
		}
		if (allPointsInLineY == true) {
			//collect only for y layer
			//get the expected point event if it passes the tolerance for a different chart
			var expectedPointY = findExpectedX(points[3], points[5], points[4][1]);
			tracking6MiddleHitsOnlyY.push([event, points, expectedPointY]);
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
 				y3 = globalThis.layerOrderX[2][0];
 				expectedPoint = findExpectedX(points[1], points[2], y3);
 				tracking5TopMissingX.push([event, points, expectedPoint]);
 				break;
 			case 1:
 				y3 = globalThis.layerOrderX[1][0];
 				expectedPoint = findExpectedX(points[2], points[0], y3);
 				tracking5MiddleMissingX.push([event, points, expectedPoint]);
 				break;
 			case 2:
 				y3 = globalThis.layerOrderX[0][0];
 				expectedPoint = findExpectedX(points[1], points[0], y3);
 				tracking5BottomMissingX.push([event, points, expectedPoint]);
 				break;
 			case 3:
 				y3 = globalThis.layerOrderY[2][0];
 				expectedPoint = findExpectedX(points[4], points[5], y3);
 				tracking5TopMissingY.push([event, points, expectedPoint]);
 				break;
 			case 4:
 				y3 = globalThis.layerOrderY[1][0];
 				expectedPoint = findExpectedX(points[3], points[5], y3);
 				tracking5MiddleMissingY.push([event, points, expectedPoint]);
 				break;
 			case 5: 
 				y3 = globalThis.layerOrderY[0][0];
 				expectedPoint = findExpectedX(points[3], points[4], y3);
 				tracking5BottomMissingY.push([event, points, expectedPoint]);
 				break;
 			default:
 				break;
 		}
 		globalThis.eventFilter5.push(event+1);
 		//need to find out which one is missing
 		//if (debugTracking) {
 		if (eventsToTest.includes(event)) {
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
 				y3 = globalThis.layerOrderX[2][0];
 				xExpectedPoint = findExpectedX(points[1], points[2], y3);
 				y3 = globalThis.layerOrderY[2][0];
 				yExpectedPoint = findExpectedX(points[4], points[5], y3);
 				tracking4TopMissing.push([event, xExpectedPoint, yExpectedPoint]);
 				globalThis.eventFilter4.push(event+1);
 			}
 			if (firstMissing == 1 && secondMissing == 4) {
 				//we are dealing with middle
 				y3 = globalThis.layerOrderX[1][0];
 				xExpectedPoint = findExpectedX(points[2], points[0], y3);
 				y3 = globalThis.layerOrderY[1][0];
 				yExpectedPoint = findExpectedX(points[3], points[5], y3);
 				tracking4MiddleMissing.push([event, xExpectedPoint, yExpectedPoint]);
 				globalThis.eventFilter4.push(event+1);
 			}
 			if (firstMissing == 2 && secondMissing == 5) {
 				//we are dealing with bottom
 				y3 = globalThis.layerOrderX[0][0];
 				xExpectedPoint = findExpectedX(points[1], points[0], y3);
 				y3 = globalThis.layerOrderY[0][0];
 				yExpectedPoint = findExpectedX(points[3], points[4], y3); 
 				tracking4BottomMissing.push([event, xExpectedPoint, yExpectedPoint]);
 				globalThis.eventFilter4.push(event+1);
 			}
 		}
 	}
}// end of analyzeTracking

function calculateAnalysisPointByPercentage(layerStart,event, x1, y1, x2, y2, percentage, yProjected,eventChannels, ndx, layer, zValue, neighbors) {
	var eventsToTest = [];
	var dx = x2 - x1;
	var dy = y2 - y1;
	var addOn = 0.0;
	if (layerStart[layer] == 'Pyramid') {
		addOn = 1.0;
	}
	//if (event ==0) {
	//	console.log(overallCellSize);
	//}
	//const x = ((x1 + (dx * percentage/100))/(size/2.0))+1;
	var x = ((x1 + (dx * percentage/100.0))/(overallCellSize/2.0))+addOn;
	x = x * pointWidth;
	if (eventsToTest.includes(event)) {
		//console.log("percent0:",x2, x1, x2-x1);
		console.log("percent:",event,x);
	}
	var y = zValue;
	if (neighbors[0] < neighbors[1]) {										
		var channel1 = eventChannels[layer][ndx];
		var channel2 = eventChannels[layer][ndx+1];
	} else {
		var channel1 = eventChannels[layer][ndx+1];
		var channel2 = eventChannels[layer][ndx];		
	}
  	return { x, y, yProjected, channel1, channel2};
}//end of calculateAnalysisPointByPercentage

function getAnalysisSingleSidePoint(layerStart,event, layerTriangle,eventChannels,channelNdx, layer, zValue) {
	var eventsToTest = [];
	var sidePoint = [];
	var addOn = 0.0;
	if (layerStart[layer] == 'Pyramid') {
		addOn = 1.0;
	}
	//if (event ==0) {
	//	console.log(overallCellSize);
	//}
	//console.log("getDeltaSidePoint",layerTriangle);
	var x1 = layerTriangle[2][0];
	var x2 = layerTriangle[3][0];
	var x3 = layerTriangle[4][0];
	//var x = (((x1 + x2 + x3)/3) /(size/2.0))+1;
	var x = (((x1 + x2 + x3)/3) /(overallCellSize/2.0))+addOn;
	x = x * pointWidth;
	var y = zValue;
	//var yProjected = (y /(size/2.0))+1;
	var yProjected = (y /(overallCellSize/2.0))+addOn;
	var channel1 = -1; 
	if (eventChannels[layer].length === 0) {
		channel1 = -1;
	} else {
		channel1 = eventChannels[layer][channelNdx];
	}
	if (eventsToTest.includes(event)) {
		console.log("single point:",event, x);
	}
	var channel2 = -1;
	sidePoint = {x, y, yProjected, channel1, channel2};	
	return sidePoint; 
}//end of getAnalysisSingleSidePoint

function getAnalysisIndexesOfTwoHighest(arr) {
  // O(n) scan to find indices of two highest values without allocations
  var len = arr.length;
  if (len === 0) return [];
  if (len === 1) return [0];
  var max1 = -Infinity, max2 = -Infinity;
  var idx1 = -1, idx2 = -1;
  for (var i = 0; i < len; i++) {
    var v = arr[i];
    if (v > max1) {
      max2 = max1; idx2 = idx1;
      max1 = v; idx1 = i;
    } else if (v > max2) {
      max2 = v; idx2 = i;
    }
  }
  // return indices in descending value order similar to previous behavior
  if (idx1 !== -1 && idx2 !== -1) return [idx1, idx2];
  if (idx1 !== -1) return [idx1];
  return [];
}//end of getAnalysisIndexesOfTwoHighest

function analyzeAnalysisCluster(event, x,arr, howmany) {
	var eventsToTest = [];//41,110,9674,9681,9725,9858,9956];
	var ndx = [];
	var intensities = [];
	var lastX = 0;
	/*
	if (howmany == 3) { //there is a cluster of 3
		var highestIntensityNdx = -1;
		var highestIntensityX = 0;
		var highestIntensity = -1;
		for (var i = x; i < howmany+x-1; i++) {
			if (arr[i][1] > highestIntensity || arr[i+1][1] > highestIntensity) {
				if (arr[i][1] > arr[i+1][1]) {
					highestIntensity = arr[i][1];
					highestIntensityNdx = i;
					highestIntesityX = i;
				} else {
					highestIntensity = arr[i+1][1];
					highestIntensityNdx = i+1;
					highestIntensityX = i+1;
				}
			}
		}
		//choose either left or right as neighbor
		if (highestIntensityNdx > -1) {
			if (highestIntensityNdx == howmany+x) {
				intensities.push(arr[highestIntensityNdx][1]);
				intensities.push(arr[highestIntensityNdx-1][1]);
				ndx.push(highestIntensity)
				ndx.push(highestIntensityX-1);
			} else if (highestIntensityNdx == x) {
				intensities.push(arr[x][1]);
				intensities.push(arr[x+1][1]);			
				ndx.push(x);
				ndx.push(x+1)
			} else {
				intensities.push(arr[highestIntensityNdx][1]);
				if (highestIntensityNdx < arr.length-1) {
					if (arr[highestIntensityNdx-1][1] > arr[highestIntensityNdx+1][1]) {
						intensities.push(arr[highestIntensityNdx-1][1]);				
					} else {
						intensities.push(arr[highestIntensityNdx+1][1]);							
					}
				} else {
					intensities.push(arr[highestIntensityNdx-1][1]);									
				}
				if (intensities[0] > intensities[1]) {
					ndx.push(highestIntensityX-1);
					ndx.push(highestIntensityX)
				} else {
					ndx.push(highestIntensityX)
					ndx.push(highestIntensityX-1);
				}
			}
		}		
	} else { //analyze pairs	
	*/
		//if (channelClusterCount <= 1) {
			if (arr.length-x == 2 && (arr[arr.length-1][0] - arr[arr.length-2][0] <= 35.0)) {
				intensities.push(arr[arr.length-2][1]);		
				intensities.push(arr[arr.length-1][1]);	
				if (eventsToTest.includes(event)) {				
				 //console.log("it gets here 1:", arr, arr[arr.length-1][0] - arr[arr.length-2][0], intensities);
				 }
			} else {
				for (var i = x; i < arr.length-1; i++) {
					if (arr[i+1][0] - arr[i][0] < 35.0 && intensities.length < 2) {
						//these are neighbors
						intensities.push(arr[i][1]);
						intensities.push(arr[i+1][1]);
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
					if (arr[lastX][0] - arr[lastX-1][0] < 35.0) {
						intensities.push(arr[lastX][1])
					if (eventsToTest.includes(event)) {			
					 //console.log("it gets here 3:", lastX, arr[lastX][0], arr[lastX-1][0],arr[lastX][0] - arr[lastX-1][0], intensities);
					}	
					}	
				}
			}
			ndx = getAnalysisIndexesOfTwoHighest(intensities);
			for (var i = 0; i < ndx.length; i++) {
				ndx[i] += x;	
			}
		//}		
	//}
	//console.log(event,channelClusterCount, intensities);
	if (eventsToTest.includes(event)) {			
	 	console.log("it gets here last:", intensities, ndx);
	}
	return ndx;
}//end of analyzeAnalysisCluster

function getAnalysisSidePointFromNeighbors(layerStart,event, x, layerTriangle, layerAct, layer, eventChannels, zValue, howmany) {
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
	var neighbors = analyzeAnalysisCluster(event,x,layerAct[layer],howmany);
	if (eventsToTest.includes(event)) {
		console.log("neighbors: ", neighbors, x, layerAct, layer, layerAct[layer], areNeighborsIn(neighbors, layerTriangle[layer].length));
	}
	if (neighbors.length > 1 && neighbors[0] > -1 && neighbors[1] > -1 && areNeighborsIn(neighbors, layerTriangle[layer].length)) {
		if (eventsToTest.includes(event)) {
			console.log("neighbors: ", neighbors, x, layerAct, layer, layerAct[layer], areNeighborsIn(neighbors, layerTriangle[layer].length));
		}
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
		if (eventsToTest.includes(event)) {
			console.log("neighbors: ", x1,y1,x2,y2);
		}
		pointPercent = point1Intensity * 100 / pointPercentSum;
		sidePoint = calculateAnalysisPointByPercentage(layerStart,event,x1, y1, x2, y2, pointPercent, yProjected,eventChannels,x, layer, zValue, neighbors);
	}
	return sidePoint;	
}//end of getAnalysisSidePointFromNeighbors

function calculateAnalysisSidePoint(layerStart,event, layerAct, layerTriangle,eventChannels, layer, zValue) {
		var eventsToTest = [];//119,120];//26020,566119073,34789
		var channelTracker = [];
		var sidePointGroup = [];
		var sidePoint = [];
		var yProjected = 0;
		if (eventsToTest.includes(event)) {
			console.log("channels:", eventChannels[layer]);
		}	
		if (layerTriangle[layer].length > 0) {
			//first we have to check for neighbors
			for (var x = 0; x < layerTriangle[layer].length; x++) {
				//check how many channels are involved in the cluster at x
				var channelClusterCount = 0;
				if (layerAct[layer].length == 1) {
					channelClusterCount = 1;
				} else {
					var done = false;
					for (var i = x; i < layerAct[layer].length-1; i++ ) {
						if (eventsToTest.includes(event)) {
							//console.log(event, x, i, layerAct[layer][i+1][0], layerAct[layer][i][0], layerAct[layer][i+1][0]-layerAct[layer][i][0]);
						}
						if (layerAct[layer][i+1][0]-layerAct[layer][i][0] < 35.0 && done == false) {						
							channelClusterCount += 1;
						} else {
							done = true;
						}
					}
					channelClusterCount += 1;
				}
				if (channelClusterCount == 1) {
					sidePoint = getAnalysisSingleSidePoint(layerStart,event, layerTriangle[layer][x],eventChannels,x,layer,zValue);
					sidePointGroup.push(sidePoint);
					if (eventsToTest.includes(event)) {
						console.log("# points 1",event, x, channelClusterCount, layerAct[layer]);
					}
				} else if (channelClusterCount == 2) { //just two neighbors
					var sidePoint = getAnalysisSidePointFromNeighbors(layerStart,event, x, layerTriangle, layerAct, layer, eventChannels, zValue,channelClusterCount);
					if (!isPointInGroup(sidePoint, sidePointGroup)) {
					  		sidePointGroup.push(sidePoint);
					}
					if (eventsToTest.includes(event)) {
						console.log("# points 2",event, x, channelClusterCount, layerAct[layer], sidePoint);
					}
					x += 1;				
				//} else if (channelClusterCount == 3) { //cluster of 3
				//	var sidePoint = getAnalysisSidePointFromNeighbors(layerStart,event, x, layerTriangle, layerAct, layer, eventChannels, zValue,channelClusterCount);
				//	if (!isPointInGroup(sidePoint, sidePointGroup)) {
				//	  		sidePointGroup.push(sidePoint);
				//	}
				//	if (eventsToTest.includes(event)) {
				//		console.log("# points 3",event, x, channelClusterCount, layerAct[layer]);
				//	}
				//	x += 2;				
				} else { // the cluster is greater than 3
					for (var j = x; j < channelClusterCount+x; j++) {
						var sidePoint = getAnalysisSidePointFromNeighbors(layerStart,event, j, layerTriangle, layerAct, layer, eventChannels, zValue, channelClusterCount);
						if (!isPointInGroup(sidePoint, sidePointGroup)) {
					  		sidePointGroup.push(sidePoint);
						}
					}
					if (eventsToTest.includes(event)) {
						console.log("# points multiple",event, x, channelClusterCount, layerAct[layer]);
					}
					x += channelClusterCount-1;				
				}
			}	
		}
		var newSidePointGroup = sidePointGroup.filter(value => Object.keys(value).length !== 0);
		return newSidePointGroup;
}//end of calculateAnalysisSidePoint

function calculateAnalysisTrack(whichLayer, event, layerAct, layerQuad, layerQuadSize, layerTriangle, layerOrder,eventChannels, layerStart){
  var eventsToTest = [];//119,120];//111,112,113,114,115,116];//64796,24066,55425];//[4968,3410,22605];
  var sidePointX1 = calculateAnalysisSidePoint(layerStart,event, layerAct, layerTriangle,eventChannels, layerOrder[0][2], layerOrder[0][0]);
  var sidePointX2 = calculateAnalysisSidePoint(layerStart,event, layerAct, layerTriangle,eventChannels, layerOrder[1][2], layerOrder[1][0]);
  var sidePointX3 = calculateAnalysisSidePoint(layerStart,event, layerAct, layerTriangle,eventChannels, layerOrder[2][2], layerOrder[2][0]);
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
	//now check if it belongs to a full track, we need to have points in all layers
	if (sidePointX1.length > 0 && sidePointX3.length > 0) {
		//loop through the middle points
		for (var i = 0; i < sidePointX2.length; i++) {
			var middlePoint = sidePointX2[i];
			if (eventsToTest.includes(event)) {
				console.log("getting best point from these :", middlePoint);
			}
			//test 1: there is only one point in both other layers
			if (sidePointX1.length == 1 && sidePointX3.length == 1) {
				expectedMiddlePoint = checkCalculatedX(sidePointX1[0],sidePointX3[0],middlePoint);
				if (Math.abs(middlePoint.x - expectedMiddlePoint.x) < diff) {
					diff = Math.abs(middlePoint.x - expectedMiddlePoint.x);
					tempX1 = sidePointX1[0];
					tempX2 = middlePoint;
					tempX3 = sidePointX3[0];	
					if (eventsToTest.includes(event)) {
						console.log("case 1 :", middlePoint.x, expectedMiddlePoint.x, diff, tempX2);
					}
				}
			}//end of test 1
			//test 2: 1 point in one of the other layer and more points in one of the other layers
			if (sidePointX3.length > 1 && sidePointX1.length == 1) {
				for (var j = 0; j < sidePointX3.length; j++) {
					//need to check if this middle point is the best for the other layer points
					expectedMiddlePoint = checkCalculatedX(sidePointX1[0],sidePointX3[j],middlePoint);
					if (Math.abs(middlePoint.x - expectedMiddlePoint.x) < diff) {
						diff = Math.abs(middlePoint.x - expectedMiddlePoint.x);
						tempX1 = sidePointX1[0];
						tempX2 = middlePoint;
						tempX3 = sidePointX3[j];	
						if (eventsToTest.includes(event)) {
							console.log("case 2 :", middlePoint.x, expectedMiddlePoint.x, diff, tempX2);
						}
					}					
				}
			}//end of test 2
			//test 3: reverse case from above
			if (sidePointX1.length > 1 && sidePointX3.length == 1) {
				for (var j = 0; j < sidePointX1.length; j++) {
					expectedMiddlePoint = checkCalculatedX(sidePointX1[j],sidePointX3[0],middlePoint);
					if (Math.abs(middlePoint.x - expectedMiddlePoint.x) < diff) {
						diff = Math.abs(middlePoint.x - expectedMiddlePoint.x);
						tempX1 = sidePointX1[j];
						tempX2 = middlePoint;
						tempX3 = sidePointX3[0];	
						if (eventsToTest.includes(event)) {
							console.log("case 3 :", middlePoint.x, expectedMiddlePoint.x, diff, tempX2);
						}
					}
				}
			}//end of test 3
			//test 4: both layers have multiple points
			if (sidePointX1.length > 1 && sidePointX3.length > 1) {
				for (var j = 0; j < sidePointX1.length; j++) {
					for (var k = 0; k < sidePointX3.length; k++) {
						expectedMiddlePoint = checkCalculatedX(sidePointX1[j],sidePointX3[k],middlePoint);
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
			}//end of test 4			
			if (typeof tempX1.x != "undefined" && tempX1.x != pointX1.x) {
				pointX1 = tempX1;
			}
			if (typeof tempX2.x != "undefined" && tempX2.x != pointX2.x) {
				pointX2 = tempX2;
				//console.log(event, whichLayer, sidePointX2, pointX2);
			}
			if (typeof tempX3.x != "undefined" && tempX3.x != pointX3.x) {
				pointX3 = tempX3;
			}										
		}//end for loop through middle points		
	}//end of checking if we have full tracks
 }//end of checking if we have a middle point
 
 if (eventsToTest.includes(event)) {
	console.log(event, whichLayer, layerStart, layerAct, sidePointX1, sidePointX2, sidePointX3, pointX1, pointX2, pointX3);
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
	 	investigatePlanes.push([whichLayer,event,xTopPoint,xMiddlePoint,xBottomPoint, layerAct[2].length, layerAct[0].length]);
   } else {
	    yTopPoint = [pointX3.x, pointX3.y];
 	  	yMiddlePoint = [pointX2.x, pointX2.y];
	  	yBottomPoint = [pointX1.x, pointX1.y];
	 	investigatePlanes.push([whichLayer,event,yTopPoint,yMiddlePoint,yBottomPoint, layerAct[2].length, layerAct[0].length]);
  	  	if (investigatePlanes.length >= 2) {
			analyzeTracking(event, investigatePlanes, 5, 4);
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
			if (pointX2.x > 0 && pointX3.x > 0) {
				var deltax = (pointX3.x - pointX2.x);
				var deltaz = (pointX3.y - pointX2.y);
				if (whichLayer == 'X') {
					dxtopmiddle.push([event, pointX1, pointX2, pointX3, deltax, deltaz]);
				} else {
					dytopmiddle.push([event, pointX1, pointX2, pointX3, deltax, deltaz]);
				}					
			}
		}
	}
 }//end of calculateAnalysisTrack

function calculateAnalysisTriangle(dir, xpos, y, channel, inten, quadMember) {
      // If intensity is falsy (0, NaN) return early to avoid allocating the triangle array
      if (!inten || isNaN(inten) || inten == 0) {
        return [];
      }
      var triangleCoords = [];
      triangleCoords.push(dir,inten);
      triangleCoords.push([xpos, y]);
      triangleCoords.push([xpos+size, y]);
      var y3 = 0;
      var height = 0;
      if (dir) {
          y3 = y-(SQRT3 * size / 2);
          height = y-((SQRT3 * size / 2)/2.0);
          triangleCoords.push([xpos+(size/2), y3]);
      } else { 
          y3 = y+(SQRT3 * size / 2);
          height = y+((SQRT3 * size / 2)/2.0);
          triangleCoords.push([xpos+(size/2), y3]);
      }
      triangleCoords.push(height, quadMember);
    return triangleCoords;
}//end of calculateAnalysisTriangle

function calculateAnalysisQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,coordArray,ped,layerQuad,quadMember,layerQuadSize,cellSize,quadGap,layerTriangle,eventChannels) {
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
			triangleCoords = calculateAnalysisTriangle(true, up ? xp - (cellSize/2)+1 : xp+(cellSize/2)+1, yp+cellSize-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
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
			triangleCoords = calculateAnalysisTriangle(true, up ? xp - (cellSize/2)+1 : xp+(cellSize/2)+1, yp+cellSize-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
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
	        triangleCoords = calculateAnalysisTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);
				}
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = calculateAnalysisTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
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
	        triangleCoords = calculateAnalysisTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
				eventChannels[layer].push(adcChannel);				
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = calculateAnalysisTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
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
			triangleCoords = calculateAnalysisTriangle(true, up ? xp - (cellSize/2)+1 : xp+(cellSize/2)+1, yp+cellSize-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
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
			triangleCoords = calculateAnalysisTriangle(true, up ? xp - (cellSize/2)+1 : xp+(cellSize/2)+1, yp+cellSize-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
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
}//end of calculateAnalysisQuad

function calculateAnalysisLayer(whichLayer, event) {
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
	 var layerStart = [];
	 var layerQuad = [[],[],[]];
	 var layerQuadSize = [[],[],[]];
	 var layerTriangle = [[],[],[]];
	 var eventChannels = [[],[],[]]; 
	 var end, middle, start;
	 var layerOrder = [];
	 var startNdx = 0;
	 if (whichLayer === 'X') { 
		var listx = [parseFloat(globalThis.singleGeometry[1][globalThis.singleGeometry[1].length-4]),5,0];
		layerOrder.push(listx);
		listx = [parseFloat(globalThis.singleGeometry[3][globalThis.singleGeometry[3].length-4]),3,1];
		layerOrder.push(listx);
		listx = [parseFloat(globalThis.singleGeometry[5][globalThis.singleGeometry[5].length-4]),1,2];
		layerOrder.push(listx);
		startNdx = 5;
	 } else {
		var listy = [parseFloat(globalThis.singleGeometry[2][globalThis.singleGeometry[2].length-4]),6,0];
		layerOrder.push(listy);
		listy = [parseFloat(globalThis.singleGeometry[4][globalThis.singleGeometry[4].length-4]),4,1];
		layerOrder.push(listy);
		listy = [parseFloat(globalThis.singleGeometry[6][globalThis.singleGeometry[6].length-4]),2,2];
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
	var firstLayer = start; //starts at the top position of the layer in the globalThis.singleGeometry
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
	  if (globalThis.singleGeometry[ndx][1] === "Tree") {
	 	up = false;
		layerStart.push("Tree");
	  } else {
		up = true;
		layerStart.push("Pyramid");
	  }
	  //check if channels are reversed
	  if (globalThis.singleGeometry[ndx][2] === "REVERSED") {
	 	reversed = true;
	  } else {
		reversed = false;
	  }	  
	  var posQuadSize = globalThis.singleGeometry[ndx].length-3; //get the quad size from the globalThis.singleGeometry
	  quadSize = globalThis.singleGeometry[ndx][posQuadSize];
	  cellSize = quadSize * size / 2.0;
	  triangleHeight = SQRT3 * cellSize / 2;
	  quadGap =  size - cellSize; 
	  // Calculate the real estate for the triangles based on the globalThis.singleGeometry
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
				  	channel = calculateAnalysisQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,xCoord,subtractPedX,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle,eventChannels);
				  } else {
				  	channel = calculateAnalysisQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,yCoord,subtractPedY,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle,eventChannels);					  
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
	calculateAnalysisTrack(whichLayer, event,layerAct, layerQuad, layerQuadSize, layerTriangle, layerOrder,eventChannels, layerStart);		
}//end of calculateAnalysisLayer

function getAnalysisBothLayers() {
    // Build a map from event -> dy entry for O(n) matching
    var dyMap = new Map();
    for (var j = 0; j < dy.length; j++) {
        dyMap.set(dy[j][0], dy[j]);
    }
    for (var i = 0; i < dx.length; i++) {
        var event = dx[i][0];
        var matching = dyMap.get(event);
        if (matching !== undefined) {
            dxbothlayers.push(dx[i]);
            dybothlayers.push(matching);
        }
    }
	//for (var k = 0; k < dxbothlayers.length; k++) {
	//	if (k < 10) {
	//		console.log("both layers:", dxbothlayers[k], dybothlayers[k]);
	//	}
	//}
    //no need to keep these in memory
    dx = [];
    dy = [];
}//end of getAnalysisBothLayers

function getAnalysisTopMiddleBothLayers() {
    var dyMap = new Map();
    for (var j = 0; j < dytopmiddle.length; j++) {
        dyMap.set(dytopmiddle[j][0], dytopmiddle[j]);
    }
    for (var i = 0; i < dxtopmiddle.length; i++) {
        var event = dxtopmiddle[i][0];
        var matching = dyMap.get(event);
        if (matching !== undefined) {
            dxtopmiddlebothlayers.push(dxtopmiddle[i]);
            dytopmiddlebothlayers.push(matching);
        }
    }
	//for (var k = 0; k < dxtopmiddlebothlayers.length; k++) {
	//	if (k < 10) {
	//		console.log("top middle layers:", dxtopmiddlebothlayers[k], dytopmiddlebothlayers[k]);
	//	}
	//}
    //no need to keep these in memory
    dxtopmiddle = [];
    dytopmiddle = [];
}//end of getAnalysisTopMiddleBothLayers

function getAnalysisBottomMiddleBothLayers() {
    var dyMap = new Map();
    for (var j = 0; j < dybottommiddle.length; j++) {
        dyMap.set(dybottommiddle[j][0], dybottommiddle[j]);
    }
    for (var i = 0; i < dxbottommiddle.length; i++) {
        var event = dxbottommiddle[i][0];
        var matching = dyMap.get(event);
        if (matching !== undefined) {
            dxbottommiddlebothlayers.push(dxbottommiddle[i]);
            dybottommiddlebothlayers.push(matching);
        }
    }
	//for (var k = 0; k < dxbottommiddlebothlayers.length; k++) {
	//	if (k < 10) {
	//		console.log("bottom middle layers:", dxbottommiddlebothlayers[k], dybottommiddlebothlayers[k]);
	//	}
	//}	
    //no need to keep these in memory
    dxbottommiddle = [];
    dybottommiddle = [];
}//end of getAnalysisBottomMiddleBothLayers

function getAnalysisXY(){
  globalThis.eventFilter6.push(" ");
  globalThis.eventFilter5.push(" ");
  globalThis.eventFilter4.push(" ");
  for (var event = 0; event < subtractPedX.length; event++) {
	  calculateAnalysisLayer('X', event); 
  	  calculateAnalysisLayer('Y', event); 
  }
}//end of getAnalysisXY
