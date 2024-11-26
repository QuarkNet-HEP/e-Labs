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
let lineRouteXTop = 88;
let lineRouteXBottom = 350;
let lineRouteYTop = 470;
let lineRouteYBottom = 730;
let quadPosOffset = 60;
let debug2D = true;
let debug2DPoint = true;
let debug2DLine = true;

var inputValue = inputElement.value;
function updateInputValue() {
  inputValue = inputElement.value;
  draw(inputValue-1); 
}

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
		
function drawPoint(x, y, pointSize) {
  ctx.beginPath();
  ctx.arc(x, y, pointSize / 2, 0, 2 * Math.PI);
  ctx.fillStyle = 'black'; // Color of the point (you can use any valid CSS color)
  ctx.globalAlpha = 1;
  ctx.fill();
}//end of drawPoint

function calculatePoint(x, la, lq, ndx, layerQuadSize) {
  var oriXa = [];
  var oriXb = [];
  var intXa = [];
  var intXb = [];
  var weightedX = [];
  if (debug2DPoint === true) {
	  console.log("In calculatePoint, line value:", x);
  }
  for (var n = 0; n < x.length; n++) {
	var xValue = x[n];
	for (var i = 1; i < la[ndx].length; i++) {
		if (debug2DPoint === true) {
			console.log("In loop: ", la[ndx], lq[ndx]);
		}
		if (i > 0 && lq[ndx][i][0] == lq[ndx][i-1][0]) {
			sizeFactor = layerQuadSize[ndx][0][0] / 2.0; //they are in the same Quad
		} else {
			sizeFactor = (layerQuadSize[ndx][0][0] / 2) + layerQuadSize[ndx][0][1];; // the are in different Quads
		}
		if (debug2DPoint === true) {
			console.log("sizeFactor: ", sizeFactor);
		}
		//test for sizeFactor distance, then we calculate weighted point
		if (la[ndx][i][0] - la[ndx][i-1][0] <= sizeFactor) { 
			if (debug2DPoint === true) {
				console.log("we should be calculating weighted point", sizeFactor,la[ndx][i][0],la[ndx][i-1][0], la[ndx][i][0] - la[ndx][i-1][0]);
			}			
			if (xValue > la[ndx][i][0] && i == la[ndx].length-1) {
				oriXa.push(la[ndx][i-1][0]);
				oriXb.push(la[ndx][i][0]);
				intXa.push(la[ndx][i-1][1]);		
				intXb.push(la[ndx][i][1]);	
			}
			if (xValue < la[ndx][i][0]) {
				oriXa.push(la[ndx][i-1][0]);
				oriXb.push(la[ndx][i][0]);
				intXa.push(la[ndx][i-1][1]);		
				intXb.push(la[ndx][i][1]);	
			}
		} else {
			//there is only one point to draw, no need to weigh
			if (debug2DPoint === true) {
				console.log("nothing to weigh", xValue);
			}				
		   weightedX.push(xValue);
		}
	}
  }	
  for (var i = 0; i < x.length; i++) {
	  if (debug2DPoint === true) {
		  console.log("oriXa: ",oriXa[i],"oriXb:",oriXb[i]);
		  console.log("intXa: ",intXa[i],"intXb:",intXb[i]);
	  }
	  if (oriXb[i] - oriXa[i] == sizeFactor) {
		  let half =((oriXb[i] - oriXa[i]) / 2) + oriXa[i];
		  if (debug2DPoint === true) {
			  console.log("half value of ((oriXb[i] - oriXa[i]) / 2) + oriXa[i]: ",half);
		  }
		  var intXsum = Math.floor(intXa[i])+Math.floor(intXb[i]);
		  var pixelAvg = sizeFactor/intXsum;
		  if (debug2DPoint === true) {
			  console.log("sum of intX Math.floor(intXa[i])+Math.floor(intXb[i]):", intXsum);
			  console.log("pixel average: sizeFactor/intXsum", pixelAvg);
		  }
		  var xapixels = pixelAvg * intXa[i];
		  var xbpixels = pixelAvg * intXb[i];
		  let apointpercent = xapixels / sizeFactor;
		  let bpointpercent = xbpixels / sizeFactor;
	 	  if (debug2DPoint === true) {	
			console.log("xapixels: pixelAvg * intXa[i]",xapixels);
	        console.log("xbpixels: pixelAvg * intXb[i]", xbpixels);	  
		  	console.log("abpointpercent: xapixels / sizeFactor",apointpercent);
		  	console.log("bpointpercent: xbpixels / sizeFactor",bpointpercent);
		  }
		  var xapix = 0;
		  xapix = oriXb[i] - (sizeFactor * apointpercent);
		  if (debug2DPoint === true) {		  
		  	console.log("xapix: oriXb[i] - (sizeFactor * apointpercent)",xapix);	
		  }	
		  weightedX.push(xapix); 
	} else {
		weightedX.push(Math.floor(oriXb[i]));
	}
  }
  
  if (la[ndx].length == 1) {
	  weightedX = x;
  }  
  if (debug2DPoint === true) {
	  console.log("weightedX: ", weightedX);
  }
  return weightedX;
}// end of calculatePoint	
	
function lineRoute(layerAct, layerQuad, layerQuadSize, lTop, lBot){
  //350, 88 for lTop, lBot and size is 35 or less depending of intercell spacing
  //470, 730 for lTop, lBot
  if (debug2DLine === true) {
	  console.log("Layer act: ", layerAct);
	  console.log("Layer quad: ", layerQuad);
	  console.log("layerQuadSize: ", layerQuadSize);
  }
  var x1 = [];
  var totalN = 0;
  var totalD = 0;
  if (debug2DLine === true) {
  	console.log("Loop through layerAct[0] to calculate x1");
  	console.log(layerAct[0]);
  	console.log(layerQuadSize[0]);
  }
  for(var i = 0; i < layerAct[0].length; i++){
	if (i > 0 && layerQuad[0][i][0] == layerQuad[0][i-1][0]) {
		sizeFactor = layerQuadSize[0][0][0] / 2.0; //they are in the same Quad
	} else {
		sizeFactor = (layerQuadSize[0][0][0] / 2.0) + layerQuadSize[0][0][1]; // the are in different Quads
	}
	if (debug2DLine === true) {
		console.log("sizeFactor: ", sizeFactor);
	}
	// sizeFactor is the difference between the x coordinates: 500, 517.5, 535, 552,5 etc.
	// this indicates that we have multiple x1 values
    if(i > 0 && Math.abs(layerAct[0][i][0]-layerAct[0][i-1][0]) != sizeFactor){
      if (debug2DLine === true) {
  	  	console.log("We get here if i > 0 and layeri - layeri-1 is not equal to half the cell size");
  	  	console.log(layerAct[0][i][0], layerAct[0][i-1][0], layerAct[0][i][0]-layerAct[0][i-1][0]);
  	  }  
	  if (totalD != 0) {
	      x1.push(Math.round(totalN/totalD));
	      if (debug2DLine === true) {
      	  	console.log("We push totalN/totalD to the x1 list: ",Math.round(totalN/totalD) );
      	  	console.log("Reason: ",Math.abs(layerAct[0][i][0]-layerAct[0][i-1][0]));  
      	  }  
      	  totalN = 0;
      	  totalD = 0;
      }
    }
    totalN += layerAct[0][i][0] * layerAct[0][i][1];
    totalD += layerAct[0][i][1];
    if (debug2DLine === true) {
	   console.log(layerAct[0][i][0], layerAct[0][i][1], layerAct[0][i][0] * layerAct[0][i][1]);
	   console.log(layerAct[0][i][1]);
	   console.log("totalN: ", totalN);
	   console.log("totalD: ", totalD);	
	}
  }
  if(totalN != 0 && totalD != 0){
    x1.push(Math.round(totalN/totalD));
	if (debug2DLine === true) {
	  	console.log("x1 = Math.round(totalN/totalD):", x1);
	}
  }
  var weightedX1 = calculatePoint(x1, layerAct, layerQuad, 0, layerQuadSize); 
  if (debug2DLine === true) {
	  console.log("weightedX1=calculatePoint with x1: ",weightedX1);
  }
  var x2 = [];
  totalN = 0;
  totalD = 0;
  if (debug2DLine === true) {
  	console.log("Loop through layerAct[2] to calculate x2");
  	console.log(layerAct[2]);
  	console.log(layerQuadSize[2]);
  }
  for(var i = 0; i < layerAct[2].length; i++){
	if (i > 0 && layerQuad[2][i][0] == layerQuad[2][i-1][0]) {
		sizeFactor = layerQuadSize[2][0][0] / 2.0; //they are in the same Quad
	} else {
		sizeFactor = (layerQuadSize[2][0][0]  / 2.0) + layerQuadSize[2][0][1]; // the are in different Quads
	}
	if (debug2DLine === true) {
		console.log("sizeFactor: ", sizeFactor);
	}
 	//sizeFactor is the difference between the x coordinates: 500, 517.5, 535, 552,5 etc.
	// this indicates that we have multiple x2 values
    if(i > 0 && Math.abs(layerAct[2][i][0]-layerAct[2][i-1][0]) != sizeFactor){
      if (debug2DLine === true) {
  	  	console.log("We get here if i > 0 and layeri - layeri-1 is not equal to half the cell size");
  	  	console.log(layerAct[2][i][0], layerAct[2][i-1][0], layerAct[2][i][0]-layerAct[2][i-1][0]);
  	  }  
	  if (totalD != 0) {
	      x2.push(Math.round(totalN/totalD));
	      if (debug2DLine === true) {
      	  	console.log("We push totalN/totalD to the x2 list: ",Math.round(totalN/totalD) );
      	  	console.log("Reason: ",Math.abs(layerAct[2][i][0]-layerAct[2][i-1][0]));  
      	  }  
	      totalN = 0;
	      totalD = 0;
	   }
    }
    totalN += layerAct[2][i][0] * layerAct[2][i][1];
    totalD += layerAct[2][i][1];
    if (debug2DLine === true) {
	   console.log(layerAct[2][i][0], layerAct[2][i][1], layerAct[2][i][0] * layerAct[2][i][1]);
	   console.log(layerAct[2][i][1]);
	   console.log("totalN: ", totalN);
	   console.log("totalD: ", totalD);	
	}    
  }
  if(totalN != 0 && totalD != 0){
    x2.push(Math.round(totalN/totalD));
	if (debug2DLine === true) {
	  	console.log("x2 = Math.round(totalN/totalD):", x2);
	}
  }
  var weightedX2 = calculatePoint(x2, layerAct, layerQuad, 2, layerQuadSize);
  if (debug2DLine === true) {
	  console.log("weightedX2=calculatePoint with x2: ",weightedX2);
  }
  for(var a = 0; a < x1.length; a++){
    for(var b = 0; b < x2.length; b++){
    drawPoint(weightedX1[a]+(layerQuadSize[0][0][0] / 2.0), lBot-3, 10);
    drawPoint(weightedX2[b]+(layerQuadSize[2][0][0] / 2.0), lTop-3, 10);
    // Draw the canvas coord for x1 + 17.5, bottom value, coord in x2 + 17.5, top value, 80 for the extension
    drawLine(x1[a]+(layerQuadSize[0][0][0] / 2.0), lBot, x2[b]+(layerQuadSize[2][0][0] / 2.0), lTop, 80);
  	}
  }
}//end of lineRoute

function drawTriangle(dir, xpos, y, size, channel, inten) {
      if(isNaN(inten)){
        inten = 0;
      }
      ctx.beginPath();
      ctx.moveTo(xpos, y);
      ctx.setTransform(1, 0, 0, 1, xpos, y);
      ctx.rotate(dir ? 0 : Math.PI / 3);
      ctx.fillStyle = 'rgba(255, 50, 100,' + inten + ')';
      ctx.lineWidth = 1;
      ctx.moveTo(0, 0);
      ctx.lineTo(size, 0);
      ctx.lineTo(size / 2, -Math.sqrt(3) * size / 2);
      ctx.closePath();
      if(inten == 0){
        ctx.fillStyle = 'rgba(255, 255, 255, 1 )';
      } else {
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
      ctx.moveTo(xpos, y);
      ctx.font = '9px Arial';
      ctx.fillStyle = 'rgba(0, 0, 0, 1)';
      if (channel < 10) {
		ctx.fillText(channel,xpos+(size/2), dir ? y-9 : y+(size/2));  
	  } else {
		ctx.fillText(channel,xpos+(size/2)-3, dir ? y-9 : y+(size/2));
	  }
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

function drawQuad(event,layer,up,size,xp,yp,channel,layerAct,reversed,numQuads,coordArray,ped,layerQuad,quadMember,layerQuadSize,cellSize,quadGap) {
    var adcChannel;
    if(up){
		if (reversed) {
			//need to reverse the channels
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];	
	        drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, ped[event][layer][adcChannel - 1]/300);
	        if(ped[event][layer][adcChannel - 1] > 10){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][adcChannel - 1]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][adcChannel - 1]]);
	          	layerQuadSize[layer].push([cellSize,quadGap])
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, ped[event][layer][channel]/300);
	        if(ped[event][layer][channel] > 10){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap])
	        }		
		}
	    channel++;	
		if (reversed) {
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
	        drawTriangle(false, xp+1, yp, size, adcChannel, ped[event][layer][adcChannel-1]/300);
	        if(ped[event][layer][adcChannel - 1] > 10){
	          	layerAct[layer].push([xp , ped[event][layer][adcChannel - 1]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][adcChannel - 1]]);
	          	layerQuadSize[layer].push([cellSize,quadGap])
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        drawTriangle(false, xp+1, yp, size, adcChannel, ped[event][layer][channel]/300);
	        if(ped[event][layer][channel] > 10){
	          	layerAct[layer].push([xp , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap])
	        }
		}
	    channel++;	
    } else {
		if (reversed) {
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
	        drawTriangle(false, xp+1, yp, size, adcChannel, ped[event][layer][adcChannel-1]/300);
	        if(ped[event][layer][adcChannel-1] > 10){
	          	layerAct[layer].push([xp , ped[event][layer][adcChannel-1]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][adcChannel - 1]]);
	          	layerQuadSize[layer].push([cellSize,quadGap])
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        drawTriangle(false, xp+1, yp, size, adcChannel, ped[event][layer][channel]/300);
	        if(ped[event][layer][channel] > 10){
	          	layerAct[layer].push([xp , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap])
	        }
		}
	    channel++;	
		if (reversed) {
			channelPosition = (numQuads * 4) - channel - 1;
			adcChannel = coordArray[event][layer][channelPosition][0];
	        drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, ped[event][layer][adcChannel-1]/300);
	        if(ped[event][layer][adcChannel-1] > 10){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][adcChannel-1]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][adcChannel - 1]]);
	          	layerQuadSize[layer].push([cellSize,quadGap])
	        }
		} else {
			adcChannel = coordArray[event][layer][channel][0];
	        drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, ped[event][layer][channel]/300);
	        if(ped[event][layer][channel] > 10){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , ped[event][layer][channel]]);
	          	layerQuad[layer].push([quadMember, ped[event][layer][channel]]);
	          	layerQuadSize[layer].push([cellSize,quadGap])
	        }
		}
	    channel++;	
    }// end if inside for loop
	return channel;
}//end of drawQuad

// Draw event on x grid			
function drawX(event, size){
    var channel = 0;
    var layer = 0;
    var ndx = 1;
    var up = false;
    var reversed = false;
    var quadSize = 0.0;
    var cellSize = 0.0;
    var quadGap = 0.0;    
    var numQuads = (layers[0].length-2);
    var startPoint = 255;
	if (layers[0].length-2 === 12) {
		startPoint = 80;
	}
	var zPos = startPoint - 20;
	// Read the value of the input
    var layerAct = [[],[],[]];
    var layerQuad = [[],[],[]];
    var layerQuadSize = [[],[],[]];    
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
    var firstLayer = 70; //starts drawing at this position in the canvas
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
				  channel = drawQuad(event,layer,up,cellSize,xp,yp,channel,layerAct,reversed,numQuads,xCoord,subtractPedX,layerQuad, quadNo,layerQuadSize,cellSize,quadGap);
				  xp += cellSize;
			  }
		  }
	  }//end inner for loop	
      channel = 0;
      layer++;
      ndx += 2;
   }//end outer for loop  

   if (debug2DLine === true) {
	   console.log("lineRoute for X: ", layerAct, layerQuadSize);
   }
   lineRoute(layerAct, layerQuad, layerQuadSize, lineRouteXBottom, lineRouteXTop);
}//end if drawX

// Draw event on y grid			
function drawY(event, size){
    var channel = 0;
    var layer = 0;
    var ndx = 2;
    var up = false;
    var flipped = false;
    var quadSize = 0.0;
    var cellSize = 0.0;
    var quadGap = 0.0;    
    var numQuads = (layers[1].length-2);
    var startPoint = 80;
	var zPos = startPoint - 20;   
    // Read the value of the input
    var layerAct = [[],[],[]];
    var layerQuad = [[],[],[]];
    var layerQuadSize = [[],[],[]];
    var end = parseFloat(geometry[2][geometry[2].length-4]);
    var middle = parseFloat(geometry[4][geometry[4].length-4]);
    var start = parseFloat(geometry[6][geometry[6].length-4]);
    if (debug2D === true) {
      console.log("layers: ", layers);
	  console.log("startPoint", startPoint, "numQuads:", numQuads);
	}
    var cm = 260 / 100.0;
    if (debug2D === true) {
		console.log("start, middle, end:",start, middle, end);
	}
    var firstLayer = 450; //starts drawing at this position in the canvas
	var secondLayer = (start - middle) * cm;	
    var thirdLayer = 260;    //loop to draw the three y layers, the layers are not evenly placed so we have to calculate
    if (debug2D === true) {
		console.log("first, second and third layer: ", firstLayer, secondLayer, thirdLayer);
	}
    //for (var yp = 450; yp <= 710; yp += 130) {
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
	  //loop and draw quads taking into account the intercell spacing and flipping
	  for (var xp = 80; xp < xpSize; xp += quadGap) {
		  //have to pass the correct arguments per quad!!!!! need some calculations!!!!
		  if (quadNo <= numQuads) {
			  for (var quadMember = 0; quadMember < 2; quadMember++) {
				  if (quadMember == 0) {
					 drawQuadPos(up, cellSize, xp, yp, layers[ndx-1][quadNo]);
					 quadNo++;
				  }
				  channel = drawQuad(event,layer,up,cellSize,xp,yp,channel,layerAct,flipped,numQuads,yCoord,subtractPedY,layerQuad, quadNo, layerQuadSize,cellSize,quadGap);
				  xp += cellSize;
			  }
		  }
	  }//end inner for loop	
      channel = 0;
      layer++;
      ndx += 2;
   }//end outer for loop
      if (debug2DLine === true) {
	   console.log("lineRoute for Y: ", layerAct, layerQuadSize);
   }
   lineRoute(layerAct, layerQuad, layerQuadSize, lineRouteYBottom, lineRouteYTop);
}//end of drawY
	
function draw(event){
  var size = 35; //this represents 1cm and the side of the triangle
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawX(event, size);
  drawY(event, size);
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