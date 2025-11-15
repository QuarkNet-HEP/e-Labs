var canvas = document.getElementById('myCanvas');
var ctx = canvas.getContext('2d');
var inputElement = document.getElementById("quantity");
// Add an event listener to the input element
inputElement.addEventListener("input", updateInputValue);
var geometry = [];
var layers = [];
var subtractPedX = [];
var subtractPedY = [];
var xCoord = [];
var yCoord = [];
let quadPosOffset = 60;
let pedThreshold = 10;
let size = 35;
let totalIntensity = 300;
let zOffset = 20;
let lineExtension = 80;
let pointSize = 8;
let debug2D = false;
let debug2DLayer = false;
let debug2DLayerMore = false;
let debug2DEvent = false;
let debug2DPoint = false;
let debug2DLine = false;
let debug2DTrack = false;
let debug2DTriangle = false;
let debug2DQuad = false;
let overallCellSize = 0;

var inputValue = inputElement.value;
function updateInputValue() {
  inputValue = inputElement.value;
  if (is_numeric(inputValue)) {
	if (inputValue > 0) {
	  draw(inputValue-1);
	} 
  }
}//end of updateInputValue

function is_numeric(str){
    return /^\d+$/.test(str);
}

function drawLine(x1, y1, x2, y2, extensionLength) {
  // 80 for extensionLength 
  // Calculate the length and angle of the original line
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
}//end of drawLine
		
function drawPoint(x, y, color) {
  ctx.beginPath();
  ctx.arc(x, y, pointSize / 2, 0, 2 * Math.PI);
  ctx.fillStyle = color; // Color of the point (you can use any valid CSS color)
  ctx.globalAlpha = 1;
  ctx.fill();
}//end of drawPoint

function calculatePointByPercentage(x1, y1, x2, y2, percentage, yProjected) {
  var dx = x2 - x1;
  var dy = y2 - y1;
  const x = x1 + (dx * percentage/100);
  const y = y1 + (dy * percentage/100);
  return { x, y, yProjected };
}//end of calculatePointByPercentage

function getSingleSidePoint(event, layerTriangle) {
	var sidePoint = [];
	var eventsToTest = [66];
	//var x1 = layerTriangle[layer][0][2][0];
	//var y1 = layerTriangle[layer][0][2][1];
	//var x2 = layerTriangle[layer][0][3][0];
	//var y2 = layerTriangle[layer][0][3][1];
	//var x3 = layerTriangle[layer][0][4][0];
	//var y3 = layerTriangle[layer][0][4][1];
	var x1 = layerTriangle[2][0];
	var y1 = layerTriangle[2][1];
	var x2 = layerTriangle[3][0];
	var y2 = layerTriangle[3][1];
	var x3 = layerTriangle[4][0];
	var y3 = layerTriangle[4][1];
	//if (eventsToTest.includes(event)) {
	//	console.log(x1,y1,x2,y2,x3,y3);
	//}
	var x = (x1 + x2 + x3)/3;
	var y = (y1 + y2 + y3)/3;
	yProjected = y;
	sidePoint = {x, y, yProjected};	
	return sidePoint; 
}//end of getSingleSidePoint

function calculateSidePoint(event, layerAct, layerTriangle, layer) {
	var sidePointGroup = [];
	var sidePoint = [];
	var yProjected = 0;
	var eventsToTest = [66];
	if (debug2DPoint === true) {
		console.log("layer triangle: ", layerAct, layerTriangle[layer], layer);
	}
	if (layerTriangle[layer].length > 0) {
	  if (layerTriangle[layer].length == 1) {
		sidePoint = getSingleSidePoint(event, layerTriangle[layer][0]);
		sidePointGroup.push(sidePoint);
	  }	else {			
		//first we have to check for neighbors
		for (var x = 0; x < layerTriangle[layer].length-1; x++) {
			var quadFirstCell = layerTriangle[layer][x][6];
			var quadSecondCell = layerTriangle[layer][x+1][6];
			var firstX = layerTriangle[layer][x][3][0];
			var secondX = layerTriangle[layer][x+1][4][0];
			var layerValueDiff = layerAct[layer][x+1][0]-layerAct[layer][x][0];
			if (debug2DPoint === true) {
				console.log(layer, x, layerAct[layer][x], layerAct[layer][x+1], layerValueDiff);
				console.log("checking x for neighbors: firstX and secondX in pixels", layerValueDiff, firstX, secondX, (secondX-firstX));
				console.log("single side point1-no neighbors", layer, layerAct[layer], layerTriangle[layer][x]);
				console.log("single side point2-no neighbors", layer, layerAct[layer], layerTriangle[layer][x+1]);
			}
			//these are not neighbors
			//if (event == 66) {
			//	console.log(x, layer, layerAct[x], layerTriangle, layerValueDiff, quadFirstCell,quadSecondCell, firstX, secondX, overallCellSize);
			//}	
			if ((quadSecondCell-quadFirstCell) > 1 || ((layerValueDiff) != 17.5) && ((secondX - firstX) > overallCellSize)) {
				//if (event == 66) {
				//	console.log("not neigbors:", x, x+1, layer, layerAct[x], layerTriangle, layerValueDiff, quadFirstCell,quadSecondCell, firstX, secondX, overallCellSize)
				//}
				sidePoint = getSingleSidePoint(event, layerTriangle[layer][x]);
				sidePointGroup.push(sidePoint);
				sidePoint = getSingleSidePoint(event, layerTriangle[layer][x+1]);
				sidePointGroup.push(sidePoint);
				x += 1;
			} else {
				//if (layerValueDiff == 17.5) {
					//we have to calculate between neighbors... I will assume it is the first two neigbors for now
					//NEED TO ADD CHECKING FOR OTHER NEIGHBORS TO THE RIGHT!!!!!
					var up = layerTriangle[layer][x][0];
					//the last line of the first triangle and the first line of the second triangle are a match
					//use the first values
					var x1 = layerTriangle[layer][x][3][0];
					var y1 = layerTriangle[layer][x][3][1];
					var x2 = layerTriangle[layer][x][4][0];
					var y2 = layerTriangle[layer][x][4][1];
					yProjected = layerTriangle[layer][x][5];	
					var point1Intensity = layerTriangle[layer][x][1];
					var point2Intensity = 0;
					if (layerTriangle[layer].length > 1) {
						point2Intensity = layerTriangle[layer][x+1][1];
					}
					var pointPercent = 0;
					var pointPercentSum = point1Intensity + point2Intensity;
					if (up) {
					   if (point1Intensity > point2Intensity) {
						 //first triangle is pyramid with higher intensity
						 pointPercent = point1Intensity * 100 / pointPercentSum;
						 sidePoint = calculatePointByPercentage(x1, y1, x2, y2, pointPercent, yProjected);
						 if (eventsToTest.includes(event)) {
							 //console.log("calculated point1", event, sidePoint, layerAct[layer], layerTriangle[layer][0]);
							 }
						 sidePointGroup.push(sidePoint);
					   } else {
						 //first triangle is pyramid with lower intensity			 
						 pointPercent = point2Intensity * 100 / pointPercentSum;
						 sidePoint = calculatePointByPercentage(x2, y2, x1, y1, pointPercent, yProjected);
						 if (eventsToTest.includes(event)) {
						  //console.log("calculated point2", event, sidePoint, layerAct[layer], layerTriangle[layer][0]);
						  }
						 sidePointGroup.push(sidePoint);
					   }			
					} else {
						if (point1Intensity > point2Intensity) {
						 //first triangle is down with higher intensity
						 pointPercent = point1Intensity * 100 / pointPercentSum;
						 sidePoint = calculatePointByPercentage(x1, y1, x2, y2, pointPercent, yProjected);
						 if (eventsToTest.includes(event)) {
						  //console.log("calculated point3", event, sidePoint, layerAct[layer], layerTriangle[layer][0]);
						  }
						 sidePointGroup.push(sidePoint);
						} else {
					     //the first triangle is down with lower intensity
						 pointPercent = point2Intensity * 100 / pointPercentSum;
						 sidePoint = calculatePointByPercentage(x2, y2, x1, y1, pointPercent, yProjected);
						 if (eventsToTest.includes(event)) {
						  //console.log("calculated point4", event, sidePoint, layerAct[layer], layerTriangle[layer][0]);
						  }
						 sidePointGroup.push(sidePoint);
						}
					}
					x += 1;
				//}
			}
		}
	  }
	  if (layerTriangle[layer].length > 1) {
		  var quadFirstCell = layerTriangle[layer][layerTriangle[layer].length-2][6];
		  var quadSecondCell = layerTriangle[layer][[layerTriangle[layer].length-1]][6];
		  var firstX = layerTriangle[layer][[layerTriangle[layer].length-2]][3][0];
		  var secondX = layerTriangle[layer][[layerTriangle[layer].length-1]][4][0];
		  var layerValueDiff = layerAct[layer][[layerTriangle[layer].length-1]][0]-layerAct[layer][[layerTriangle[layer].length-1]][0];
		  if ((quadSecondCell-quadFirstCell) > 1 || ((layerValueDiff) != 17.5) && ((secondX - firstX) > overallCellSize)) { 		
			  //we still need to deal with the last point
			  sidePoint = getSingleSidePoint(event, layerTriangle[layer][layerTriangle[layer].length-1]);
			  sidePointGroup.push(sidePoint);
		  }
		}
    }//end of checking if layerTriangle is great than 0
	return sidePointGroup;
}//end of calculateSidePoint

function findCalculatedX(point1, point2, y3) {
   const m = (point2.y - point1.y) / (point2.x - point1.x);
   const x3 = (y3.y - point1.y) / m + point1.x;
   return {x:x3, y:y3.y};
}

function caculateTrack(event, layerAct, layerQuad, layerQuadSize, layerTriangle, lTop, lBot, layerOrder){
	  var sidePointX1 = calculateSidePoint(event,layerAct, layerTriangle, layerOrder[0][2]);
	  if (debug2DTrack === true) {
		  console.log("side point pixels 1: ", sidePointX1);
	  }
	  var sidePointX2 = calculateSidePoint(event,layerAct, layerTriangle, layerOrder[1][2]);
	  if (debug2DTrack === true) {
		  console.log("side point pixels 2: ", sidePointX2);
	  }  
	  var sidePointX3 = calculateSidePoint(event,layerAct, layerTriangle, layerOrder[2][2]);
	  if (debug2DTrack === true) {
		  console.log("side point pixels 3: ", sidePointX3);
	  }
	  for (var i = 0; i < sidePointX3.length; i++) {
	  	drawPoint(sidePointX3[i].x, sidePointX3[i].y, 'yellow');
	  	drawPoint(sidePointX3[i].x, sidePointX3[i].yProjected, 'cyan');	 	
	  }
	  
	  for (var i = 0; i < sidePointX2.length; i++) {
	   drawPoint(sidePointX2[i].x, sidePointX2[i].y, 'yellow');
	   drawPoint(sidePointX2[i].x, sidePointX2[i].yProjected, 'cyan');	 	
	  }
	  for (var i = 0; i < sidePointX1.length; i++) {
	   drawPoint(sidePointX1[i].x, sidePointX1[i].y, 'yellow');
	   drawPoint(sidePointX1[i].x, sidePointX1[i].yProjected, 'cyan');	 	
	  }
	  	 
	  for (var i = 0; i < sidePointX1.length; i++) {
		for (var j = 0; j < sidePointX3.length; j++) {
			drawLine(sidePointX3[j].x, sidePointX3[j].yProjected, sidePointX1[i].x, sidePointX1[i].yProjected, lineExtension);							
	  	}
	  }
}//end of calculateTrack

function drawTriangle(dir, xpos, y, channel, inten, quadMember) {
	  var triangleCoords = [];
	  triangleCoords.push(dir,inten);
      if(isNaN(inten)){
        inten = 0;
      }
      ctx.beginPath();
      ctx.moveTo(xpos, y);
      triangleCoords.push([xpos, y]);
      if (debug2DTriangle == true) {
	      console.log("drawing triangle");
    	  console.log("x: ",xpos, "y: ", y, "dir: ", dir);
      }
      ctx.setTransform(1, 0, 0, 1, xpos, y);
      ctx.rotate(dir ? 0 : Math.PI / 3);
      ctx.fillStyle = 'rgba(255, 50, 100,' + inten + ')';
      ctx.lineWidth = 1;
      ctx.moveTo(0, 0);
      ctx.lineTo(size, 0);
      triangleCoords.push([xpos+size, y]);
      ctx.lineTo(size / 2, -Math.sqrt(3) * size / 2);
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
      ctx.closePath();
      if(inten == 0){
        ctx.fillStyle = 'rgba(255, 255, 255, 1 )';
	    if (debug2DTriangle == true) {
	    	console.log("intensity == 0");
	    }
		triangleCoords = [];
      } else {
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.font = '15px Arial';
        ctx.fillStyle = 'rgba(0, 0, 0, 1)';
        ctx.fillText(Math.round(inten*totalIntensity), xpos + size/2, dir ? y + size / 2: y - size / 3);
        ctx.fillStyle = 'rgba(255, 50, 100,' + inten + ')';
        ctx.setTransform(1, 0, 0, 1, xpos, y);
	    if (debug2DTriangle == true) {
	    	console.log("intensity > 0");
	    	console.log(triangleCoords);
	    }
      }   
      ctx.fill();
      ctx.strokeStyle = 'black'; // Set the border color to black
      ctx.stroke();
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.moveTo(xpos, y);
      //add the channel to the cell
      ctx.font = '9px Arial';
      ctx.fillStyle = 'rgba(0, 0, 0, 1)';
      if (channel < 10) {
		ctx.fillText(channel,xpos+(size/2), dir ? y-9 : y+(size/2));  
	  } else {
		ctx.fillText(channel,xpos+(size/2)-3, dir ? y-9 : y+(size/2));
	  }
	  triangleCoords.push(height, quadMember);
	return triangleCoords;
}//end of drawTriangle

function drawQuadPos(up, cellSize, xpos, ypos, value) {
    ctx.beginPath();
    ctx.moveTo(xpos, ypos + quadPosOffset);
    ctx.fillStyle = 'rgba(0, 0, 0, 1)';
    ctx.font = '9px Arial';
    ctx.fillText(value, up ? xpos - (cellSize/2)+1 : xpos+(cellSize/2)+1, ypos + quadPosOffset);  
}//end of drawQuadPos

function drawZPosition(xpos, ypos, value, reversed, caen) {
      ctx.beginPath();
      ctx.moveTo(xpos, ypos);
      ctx.fillStyle = 'rgba(0, 0, 0, 1)';
      ctx.font = '9px Arial';
	  ctx.fillText(value, xpos, ypos);  
	  ctx.moveTo(xpos, ypos+zOffset);
	  ctx.fillText(reversed, xpos, ypos+zOffset); 
	  
	  ctx.beginPath();
	  ctx.moveTo(xpos-45, ypos);
	  ctx.fillStyle = 'rgba(0, 0, 0, 1)';
	  ctx.font = '9px Arial';
	  var cbox = "CAEN " + caen + ":";
	  ctx.fillText(cbox, xpos-45, ypos);  
	   
}//end of drawZPosition

function drawQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,coordArray,ped,layerQuad,quadMember,layerQuadSize,cellSize,quadGap,layerTriangle) {
    var adcChannel;
    var pedPosition;
    var triangleCoords = [];
    if(up){
		if (reversed) {
			//need to reverse the channels
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
			pedPosition = (numQuads * 4) - channelPosition;
	        triangleCoords = drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
			if (debug2DEvent === true) {
				console.log(numQuads, reversed, up, channelPosition, adcChannel, pedPosition, ped[event][layer]);
			}
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }		
		}
	    channel++;	
		if (reversed) {
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
			pedPosition = (numQuads * 4) - channelPosition;
	        triangleCoords = drawTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
			if (debug2DEvent === true) {
				console.log(numQuads, reversed, up, channelPosition, adcChannel,  pedPosition, ped[event][layer]);
			}
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		}
	    channel++;	
    } else {
		if (reversed) {
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
			pedPosition = (numQuads * 4) - channelPosition;
	        triangleCoords = drawTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
			if (debug2DEvent === true) {
				console.log(numQuads, reversed, up, channelPosition, adcChannel, pedPosition, ped[event][layer]);
			}
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawTriangle(false, xp+1, yp, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	layerAct[layer].push([xp , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		}
	    channel++;	
		if (reversed) {
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
			pedPosition = (numQuads * 4) - channelPosition;
	        triangleCoords = drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channelPosition]/totalIntensity, quadMember);
			if (debug2DEvent === true) {
				console.log(numQuads, reversed, up, channelPosition, adcChannel, pedPosition, ped[event][layer]);
			}
	        if(ped[event][layer][channelPosition] > pedThreshold){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channelPosition]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channelPosition]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, adcChannel, ped[event][layer][channel]/totalIntensity, quadMember);
	        if(ped[event][layer][channel] > pedThreshold){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		}
	    channel++;

    }// end if inside for loop
	return channel;
}//end of drawQuad
	
function drawLayer(whichLayer, event, startX, startY, lineRouteBottom, lineRouteTop) {
    var channel = 0;
    var layer = 2; // we start with the top layer data in Z for both X and Y --> array goes 0,1,2
    var up = false;
    var reversed = false;
    var quadSize = 0.0;
    var cellSize = 0.0;
    var quadGap = 0.0;    
    var startPoint = startX;
	// Read the value of the input
    var layerAct = [[],[],[]];
    var layerQuad = [[],[],[]];
    var layerQuadSize = [[],[],[]];
    var layerTriangle = [[],[],[]];   
    var end, middle, start;
	var layerOrder = [];
	var startNdx = 0;
    if (whichLayer === 'X') { 
		layerOrder = layerOrderX;
		startNdx = 5;
    } else {
		layerOrder = layerOrderY;
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
	//need to check the pixel we start drawing based on the # of cells
	if (layers[ndx-1].length-2 === 12) {
		startPoint = 80;
	}
	var zPos = startPoint - 20;
	
    if (debug2DLayerMore === true) {
	  console.log("layer order:", layerOrder);
      console.log("canvas:", ctx);
      console.log("layers: ", layers);
	  console.log("startPoint", startPoint, "numQuads:", numQuads);
	}
	var units = 260.0 / (start - end);
    if (debug2DLayer === true) {
		console.log("start, middle, end, cm:",start, middle, end, units);
	}
    var firstLayer = startY; //starts drawing at this position in the canvas (70 and 450)
	var secondLayer = (start - middle) * units;	
    var thirdLayer = (start - end) * units;
    //loop to draw the three y layers, the layers are not evenly placed so we have to calculate
    if (debug2DLayer === true) {
		console.log("first, second and third layer: ", firstLayer, secondLayer, thirdLayer);
	}
	//draw the 3 layers for either X or Y
	for (var i = 0; i < 3; i++) {
	  var yp = firstLayer;
	  var zvalue = start;
	  if (i == 1) {
		  yp += secondLayer;
		  zvalue = middle;
	  }
	  if (i == 2) {
		  yp += thirdLayer;
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
	  overallCellSize = cellSize;
	  triangleHeight = Math.sqrt(3) * cellSize / 2;
	  quadGap =  size - cellSize; 
	  // Calculate the real estate for the triangles based on the geometry
	  var xpSize = ((numQuads * 2) * cellSize) + startPoint;
	  if (debug2DLayerMore === true) {
		  console.log("yp: ", yp);
		  console.log("up: ", up);
		  console.log("posQuadSize: ", posQuadSize);
		  console.log("quadSize: ", quadSize);
		  console.log("cellSize: ", cellSize);
		  console.log("quadGap: ", quadGap);
		  console.log("xpSize:", xpSize);
	  }
	  if (whichLayer === 'X') {
		drawZPosition(zPos, yp+(cellSize/2), zvalue, geometry[ndx][2], (layer*2));
	  } else {
		drawZPosition(zPos, yp+(cellSize/2), zvalue, geometry[ndx][2], ((layer*2)+1));		
	  }
	  //loop and draw quads taking into account the intercell spacing and flipping
	  var quadNo = 0;
	  for (var xp = startPoint; xp < xpSize; xp += quadGap) {
		  //have to pass the correct arguments per quad!!!!! need some calculations!!!!
		  if (quadNo <= numQuads) {
			  for (var quadMember = 0; quadMember < 2; quadMember++) {
				  if (quadMember == 0) {
					 drawQuadPos(up, cellSize, xp, yp, layers[ndx-1][quadNo]);
					 quadNo++;
				  }
				  if (debug2DLayer === true) {
				  	console.log(whichLayer,event,layer,up,cellSize,xp,yp,channel,layerAct,reversed,numQuads,xCoord,subtractPedX,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle);
    			  }
    			  if (whichLayer === 'X') { 				  
				  	channel = drawQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,xCoord,subtractPedX,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle);
				  } else {
				  	channel = drawQuad(event,layer,up,xp,yp,channel,layerAct,reversed,numQuads,yCoord,subtractPedY,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle);					  
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

   if (debug2DLine === true) {
	   console.log("calculateTrack for ",whichLayer,": ", layerAct, layerQuadSize, layerTriangle);
   }
   caculateTrack(event,layerAct, layerQuad, layerQuadSize, layerTriangle, lineRouteBottom, lineRouteTop, layerOrder);	
}//end of drawLayer

function draw(event){
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawLayer('X', event, 255, 70, 350, 88); //whichLayer, event, startX, startY, lineRouteBottom, lineRouteTop
  drawLayer('Y', event, 80, 450, 730, 470); //whichLayer, event, startX, startY, lineRouteBottom, lineRouteTop
  ctx.font = 'italic 25px Arial';
  ctx.textAlign = 'center';
  ctx.fillStyle = 'rgba(0, 0, 0, 1 )'
  ctx.fillText('X-view display - find muon track with 3 planes', canvas.width / 2, 30);
  ctx.fillText('Y-view display - find muon track with 3 planes', canvas.width / 2, 420);
}//end of draw

//function draw2DSettings(event, g, l) {
function draw2DSettings(event, detector, g, l, sX, sY, cX, cY){
	subtractPedX = sX;
	subtractPedY = sY;
	xCoord = cX;
	yCoord = cY;
	geometry = g;
	layers = l;
	if (debug2D === true) {		
		console.clear();
		console.log("2D drawings");
		console.log("geometry:",g);
		console.log("layers:",l);
	}
	document.getElementById('event').style = "display:inline";
	document.getElementById("quantity").value = 1;
	inputElement.max = subtractPedX.length;
	draw(event);
}