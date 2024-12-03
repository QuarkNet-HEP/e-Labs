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
let debug2D = false;
let debug2DPoint = false;
let debug2DLine = true;
let debug2DTriangle = false;
let debug2DQuad = false;

var inputValue = inputElement.value;
function updateInputValue() {
  inputValue = inputElement.value;
  draw(inputValue-1); 
}//end of updateInputValue

function drawLine(x1, y1, x2, y2, extensionLength) {
  // 80 for extensionLength 
  // Calculate the length and angle of the original line
  //var originalLength = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
  //console.log("length",originalLength);
  var angle = Math.atan2(y2 - y1, x2 - x1);
  //console.log("angle",angle);
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
		
function drawPoint(x, y, pointSize, color) {
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

function getSingleSidePoint(layerTriangle, layer) {
	var sidePoint = [];
	var x1 = layerTriangle[layer][0][2][0];
	var y1 = layerTriangle[layer][0][2][1];
	var x2 = layerTriangle[layer][0][3][0];
	var y2 = layerTriangle[layer][0][3][1];
	var x3 = layerTriangle[layer][0][4][0];
	var y3 = layerTriangle[layer][0][4][1];
	var x = (x1 + x2 + x3)/3;
	var y = (y1 + y2 + y3)/3;
	yProjected = y;
	sidePoint = {x, y, yProjected};	
	return sidePoint; 
}//end of getSingleSidePoint

function calculateSidePoint(layerTriangle, layer) {
	var sidePoint = [];
	var yProjected = 0;
	if (debug2DPoint === true) {
		console.log("layer triangle: ", layerTriangle);
	}
	if (layerTriangle[layer].length > 0) {
	  if (layerTriangle[layer].length == 1) {
		//the point falls in the middle of the triangle
		sidePoint = getSingleSidePoint(layerTriangle, layer);
	  }	else {
		//first we have to check for neighbors
        var quadFirstCell = layerTriangle[layer][0][6];
        var quadSecondCell = layerTriangle[layer][1][6];
        //these are not neighbors
        if ((quadSecondCell-quadFirstCell) > 1) {
			sidePoint = getSingleSidePoint(layerTriangle, layer);
		} else {					
			//we have to calculate between neighbors... I will assume it is the first two neigbors for now
			var up = layerTriangle[layer][0][0];
			//the last line of the first triangle and the first line of the second triangle are a match
			//use the first values
			var x1 = layerTriangle[layer][0][3][0];
			var y1 = layerTriangle[layer][0][3][1];
			var x2 = layerTriangle[layer][0][4][0];
			var y2 = layerTriangle[layer][0][4][1];
			yProjected = layerTriangle[layer][0][5];	
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
				 sidePoint = calculatePointByPercentage(x1, y1, x2, y2, pointPercent, yProjected);
			   } else {
				 //first triangle is pyramid with lower intensity			 
				 pointPercent = point2Intensity * 100 / pointPercentSum;
				 sidePoint = calculatePointByPercentage(x2, y2, x1, y1, pointPercent, yProjected);
			   }			
			} else {
				if (point1Intensity > point2Intensity) {
				 //first triangle is down with higher intensity
				 pointPercent = point1Intensity * 100 / pointPercentSum;
				 sidePoint = calculatePointByPercentage(x1, y1, x2, y2, pointPercent, yProjected);
				} else {
			     //sthe first triangle is down with lower intensity
				 pointPercent = point2Intensity * 100 / pointPercentSum;
				 sidePoint = calculatePointByPercentage(x2, y2, x1, y1, pointPercent, yProjected);
				}
			}
		}//end of neighbor calculation
	  }
	} 
    if (debug2DPoint === true) {
		console.log("intensity:", point1Intensity, point2Intensity);
		console.log("point percent: ", pointPercent);
		console.log("side point coords: ", x1,y1,x2,y2);
		console.log("side point: ", sidePoint);
	}							
	return sidePoint;
}//end of calculateSidePoint

function getLineCoordinates(layerAct, ndx, layerQuad, layerQuadSize) {
  var x = [];
  var totalN = 0;
  var totalD = 0;
  if (debug2DLine === true) {
  	console.log("Loop through layerAct to calculate x");
  	console.log(layerAct[ndx]);
  	console.log(layerQuadSize[ndx]);
  }
  for(var i = 0; i < layerAct[ndx].length; i++){
	if (i > 0 && layerQuad[ndx][i][0] == layerQuad[ndx][i-1][0]) {
		sizeFactor = layerQuadSize[ndx][0][0] / 2.0; //they are in the same Quad
	} else {
		sizeFactor = (layerQuadSize[ndx][0][0] / 2.0) + layerQuadSize[ndx][0][1]; // the are in different Quads
	}
	if (debug2DLine === true) {
		console.log("sizeFactor: ", sizeFactor);
	}
	// sizeFactor is the difference between the x coordinates: 500, 517.5, 535, 552,5 etc.
	// this indicates that we have multiple x1 values
    if(i > 0 && Math.abs(layerAct[ndx][i][0]-layerAct[ndx][i-1][0]) != sizeFactor){
      if (debug2DLine === true) {
  	  	console.log("We get here if i > 0 and layeri - layeri-1 is not equal to half the cell size");
  	  	console.log(layerAct[ndx][i][0], layerAct[ndx][i-1][0], layerAct[ndx][i][0]-layerAct[ndx][i-1][0]);
  	  }  
	  if (totalD != 0) {
	      x.push(Math.round(totalN/totalD));
	      if (debug2DLine === true) {
      	  	console.log("We push totalN/totalD to the x list: ",Math.round(totalN/totalD) );
      	  	console.log("Reason: ",Math.abs(layerAct[ndx][i][0]-layerAct[ndx][i-1][0]));  
      	  }  
      	  totalN = 0;
      	  totalD = 0;
      }
    }
    totalN += layerAct[ndx][i][0] * layerAct[ndx][i][1];
    totalD += layerAct[ndx][i][1];
    if (debug2DLine === true) {
	   console.log(layerAct[ndx][i][0], layerAct[ndx][i][1], layerAct[ndx][i][0] * layerAct[ndx][i][1]);
	   console.log(layerAct[ndx][i][1]);
	   console.log("totalN: ", totalN);
	   console.log("totalD: ", totalD);	
	}
  }
  if(totalN != 0 && totalD != 0){
    x.push(Math.round(totalN/totalD));
	if (debug2DLine === true) {
	  	console.log("x = Math.round(totalN/totalD):", x);
	}
  }	
  return x;
}//end of getCoordinates

function caculateTrack(layerAct, layerQuad, layerQuadSize, layerTriangle, lTop, lBot){
  var sidePointX1 = calculateSidePoint(layerTriangle, 0);
  if (debug2DLine === true) {
	  console.log("side point pixels: ", sidePointX1);
  }
  var sidePointX2 = calculateSidePoint(layerTriangle, 1);
  if (debug2DLine === true) {
	  console.log("side point pixels: ", sidePointX2);
  }  
  var sidePointX3 = calculateSidePoint(layerTriangle, 2);
  if (debug2DLine === true) {
	  console.log("side point pixels: ", sidePointX3);
  } 
  drawPoint(sidePointX1.x, sidePointX1.y, 8, 'yellow');
  drawPoint(sidePointX1.x, sidePointX1.yProjected, 8, 'cyan');
  drawPoint(sidePointX2.x, sidePointX2.y, 8, 'yellow');
  drawPoint(sidePointX2.x, sidePointX2.yProjected, 8, 'cyan');
  drawPoint(sidePointX3.x, sidePointX3.y, 8, 'yellow');
  drawPoint(sidePointX3.x, sidePointX3.yProjected, 8, 'cyan');
  var x1 = getLineCoordinates(layerAct, 0, layerQuad, layerQuadSize); 
  var x2 = getLineCoordinates(layerAct, 0, layerQuad, layerQuadSize); 
  for(var a = 0; a < x1.length; a++){
    for(var b = 0; b < x2.length; b++){
    // Draw the canvas coord for x1 + 17.5, bottom value, coord in x2 + 17.5, top value, 80 for the extension
    drawLine(x1[a]+(layerQuadSize[0][0][0] / 2.0), lBot, x2[b]+(layerQuadSize[2][0][0] / 2.0), lTop, 80);
  	}
  }
}//end of calculateTrack

function drawTriangle(dir, xpos, y, size, channel, inten, quadMember) {
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
	    	triangleCoords = [];
	    }
      } else {
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.font = '15px Arial';
        ctx.fillStyle = 'rgba(0, 0, 0, 1)';
        ctx.fillText(Math.round(inten*300), xpos + size/2, dir ? y + size / 2: y - size / 3);
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

function drawQuadPos(up, size, xpos, ypos, value) {
	//console.log(xpos,ypos,value);
    ctx.beginPath();
    ctx.moveTo(xpos, ypos + quadPosOffset);
    ctx.fillStyle = 'rgba(0, 0, 0, 1)';
    ctx.font = '9px Arial';
    ctx.fillText(value, up ? xpos - (size/2)+1 : xpos+(size/2)+1, ypos + quadPosOffset);  
}//end of drawQuadPos

function drawZPosition(xpos, ypos, value, reversed) {
      ctx.beginPath();
      ctx.moveTo(xpos, ypos);
      ctx.fillStyle = 'rgba(0, 0, 0, 1)';
      ctx.font = '9px Arial';
	  ctx.fillText(value, xpos, ypos);  
	  ctx.moveTo(xpos, ypos+ 20);
	  ctx.fillText(reversed, xpos, ypos+20);  
}//end of drawZPosition

function drawQuad(event,layer,up,size,xp,yp,channel,layerAct,reversed,numQuads,coordArray,ped,layerQuad,quadMember,layerQuadSize,cellSize,quadGap,layerTriangle) {
    var adcChannel;
    var triangleCoords = [];
    if(up){
		if (reversed) {
			//need to reverse the channels
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];	
	        triangleCoords = drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, ped[event][layer][adcChannel - 1]/300, quadMember);
	        if(ped[event][layer][adcChannel - 1] > 10){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][adcChannel - 1]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][adcChannel - 1]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, ped[event][layer][channel]/300, quadMember);
	        if(ped[event][layer][channel] > 10){
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
	        triangleCoords = drawTriangle(false, xp+1, yp, size, adcChannel, ped[event][layer][adcChannel-1]/300, quadMember);
	        if(ped[event][layer][adcChannel - 1] > 10){
	          	layerAct[layer].push([xp , ped[event][layer][adcChannel - 1]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][adcChannel - 1]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawTriangle(false, xp+1, yp, size, adcChannel, ped[event][layer][channel]/300, quadMember);
	        if(ped[event][layer][channel] > 10){
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
	        triangleCoords = drawTriangle(false, xp+1, yp, size, adcChannel, ped[event][layer][adcChannel-1]/300, quadMember);
	        if(ped[event][layer][adcChannel-1] > 10){
	          	layerAct[layer].push([xp , ped[event][layer][adcChannel-1]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][adcChannel - 1]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawTriangle(false, xp+1, yp, size, adcChannel, ped[event][layer][channel]/300, quadMember);
	        if(ped[event][layer][channel] > 10){
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
	        triangleCoords = drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, ped[event][layer][adcChannel-1]/300, quadMember);
	        if(ped[event][layer][adcChannel-1] > 10){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][adcChannel-1]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][adcChannel - 1]]);
	          	layerQuadSize[layer].push([cellSize,quadGap]);
				layerTriangle[layer].push(triangleCoords); 
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        triangleCoords = drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, ped[event][layer][channel]/300, quadMember);
	        if(ped[event][layer][channel] > 10){
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
	
function drawLayer(whichLayer, event, size, startNdx, startX, startY, lineRouteBottom, lineRouteTop) {
    var channel = 0;
    var layer = 0;
    var ndx = startNdx;
    var up = false;
    var reversed = false;
    var quadSize = 0.0;
    var cellSize = 0.0;
    var quadGap = 0.0;    
    var numQuads = (layers[ndx-1].length-2);
    var startPoint = startX;
	if (layers[ndx-1].length-2 === 12) {
		startPoint = 80;
	}
	var zPos = startPoint - 20;
	// Read the value of the input
    var layerAct = [[],[],[]];
    var layerQuad = [[],[],[]];
    var layerQuadSize = [[],[],[]];
    var layerTriangle = [[],[],[]];    
    var end = parseFloat(geometry[1][geometry[1].length-4]);
    var middle = parseFloat(geometry[3][geometry[3].length-4]);
    var start = parseFloat(geometry[5][geometry[5].length-4]);
    if (debug2D === true) {
      console.log("canvas:", ctx);
      console.log("layers: ", layers);
	  console.log("startPoint", startPoint, "numQuads:", numQuads);
	}
    var cm = 260 / 100.0;
    if (debug2D === true) {
		console.log("start, middle, end:",start, middle, end);
	}
    var firstLayer = startY; //starts drawing at this position in the canvas
	var secondLayer = (start - middle) * cm;	
    var thirdLayer = 260;
    //loop to draw the three y layers, the layers are not evenly placed so we have to calculate
    //for (var yp = 450; yp <= 710; yp += 130) {
    if (debug2D === true) {
		console.log("first, second and third layer: ", firstLayer, secondLayer, thirdLayer);
	}
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
	  var posQuadSize = geometry[ndx].length-3;
	  quadSize = geometry[ndx][posQuadSize];
	  cellSize = quadSize * 35 / 2.0;
	  triangleHeight = Math.sqrt(3) * cellSize / 2;
	  quadGap =  size - cellSize; 
	  // Calculate the real estate for the triangles based on the geometry
	  var xpSize = ((numQuads * 2) * cellSize) + startPoint;
	  if (debug2D === true) {
		  console.log("yp: ", yp);
		  console.log("up: ", up);
		  console.log("posQuadSize: ", posQuadSize);
		  console.log("quadSize: ", quadSize);
		  console.log("cellSize: ", cellSize);
		  console.log("quadGap: ", quadGap);
		  console.log("xpSize:", xpSize);
	  }
	  drawZPosition(zPos, yp+(cellSize/2), zvalue, geometry[ndx][2]);
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
				  channel = drawQuad(event,layer,up,cellSize,xp,yp,channel,layerAct,reversed,numQuads,xCoord,subtractPedX,layerQuad, quadNo,layerQuadSize,cellSize,quadGap,layerTriangle);
				  xp += cellSize;
			  }
		  }
	  }//end inner for loop	
      channel = 0;
      layer++;
      ndx += 2;
   }//end outer for loop  

   if (debug2DLine === true) {
	   console.log("lineRoute for ",whichLayer,": ", layerAct, layerQuadSize, layerTriangle);
   }
   caculateTrack(layerAct, layerQuad, layerQuadSize, layerTriangle, lineRouteBottom, lineRouteTop);	
}//end of drawLayer

function draw(event){
  var size = 35; //this represents 1cm and the side of the triangle
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawLayer('X', event, size, 1, 255, 70, 350, 88); //whichLayer, event, size, startNdx, startX, startY, lineRouteBottom, lineRouteTop
  drawLayer('Y', event, size, 2, 80, 450, 730, 470); //whichLayer, event, size, startNdx, startX, startY, lineRouteBottom, lineRouteTop
  ctx.font = 'italic 25px Arial';
  ctx.textAlign = 'center';
  ctx.fillStyle = 'rgba(0, 0, 0, 1 )'
  ctx.fillText('X-view display - find muon track with 3 planes', canvas.width / 2, 30);
  ctx.fillText('Y-view display - find muon track with 3 planes', canvas.width / 2, 420);
}//end of draw

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
		console.log("subPedX:",sX);
		console.log("subPedY:",sY);
		console.log("xCoord:",cX);
		console.log("yCoord:",cY);
	}
	document.getElementById('event').style = "display:inline";
	document.getElementById("quantity").value = 1;
	inputElement.max = subtractPedX.length;
	draw(event);
}