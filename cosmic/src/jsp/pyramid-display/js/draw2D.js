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
let debug2D = false;

var inputValue = inputElement.value;
function updateInputValue() {
  inputValue = inputElement.value;
  draw(inputValue-1); 
}

function drawLine(x1, y1, x2, y2, extensionLength) {
  // 80 for extensionLength 
  // Calculate the length and angle of the original line
  var originalLength = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
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
}
		
function drawPoint(x, y, pointSize) {
  ctx.beginPath();
  ctx.arc(x, y, pointSize / 2, 0, 2 * Math.PI);
  ctx.fillStyle = 'black'; // Color of the point (you can use any valid CSS color)
  ctx.globalAlpha = 1;
  ctx.fill();
}

function calculatePoint(x, la, ndx, size) {
  var oriXa = [];
  var oriXb = [];
  var intXa = [];
  var intXb = [];
  var weightedX = [];
  for (var n = 0; n < x.length; n++) {
	var xValue = x[n];
	for (var i = 1; i < la[ndx].length; i++) {
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
	}
  }	
  //Xweight = Xleft + (Xright - Xleft) * (ADCleft)/(ADCleft + ADCright).
  for (var i = 0; i < x.length; i++) {
	  if (debug2D === true) {
		  console.log(oriXa[i],oriXb[i]);
		  console.log(intXa[i],intXb[i]);
	  }
	  if (oriXb[i] - oriXa[i] == 17.5) {
		  let half =((oriXb[i] - oriXa[i]) / 2) + oriXa[i];
		  if (debug2D === true) {
			  console.log(half);
		  }
		  var intXsum = Math.floor(intXa[i])+Math.floor(intXb[i]);
		  var pixelAvg = 17.5/intXsum;
		  if (debug2D === true) {
			  console.log(intXsum);
			  console.log(pixelAvg);
		  }
		  var xapixels = pixelAvg * intXa[i];
		  var xbpixels = pixelAvg * intXb[i];
		  let apointpercent = xapixels / 17.5;
		  let bpointpercent = xbpixels / 17.5;
	 	  if (debug2D === true) {		  
		  	console.log(apointpercent,bpointpercent);
		  }
		  var xapix = 0;
		  //the point is heavy to the left
		  //if (apointpercent > 0.5) {
		  //xapix = oriXb[i] - (17.5 * apointpercent);
		  //}
		  //the point goes in the middle
		  //if (apointpercent === 0.5) {
		  //	xapix = oriXa[i] + (size/4);
		  //}
		  //the point is heavy to the right
		  //if (apointpercent < 0.5) {
			//xapix = oriXa[i] + (size/4);			
		  //}
		  xapix = oriXb[i] - (17.5 * apointpercent);
		  if (debug2D === true) {		  
		  	console.log(xapix);	
		  }	
		  weightedX.push(xapix); 
		  /* 
		  if (intXa[i] > intXb[i]) {
			  weightedX.push(Math.floor(oriXa[i])+xapixels);
		  }	  
		  if (intXa[i] === intXb[i]) {
			  weightedX.push(Math.floor(oriXa[i])+(size/4));
		  }	  
		  if (intXa[i] < intXb[i]) {
			  weightedX.push(Math.floor(oriXb[i])-xapix);
		  }	  
		  */
	} else {
		weightedX.push(Math.floor(oriXb[i]));
	}
  }
  if (la[ndx].length == 1) {
	  weightedX = x;
  }  
  return weightedX;
}// end of calculatePoint	
	
function lineRoute(layerAct, size, lTop, lBot){
  //350, 88 for lTop, lBot and size is 35
  //470, 730 for lTop, lBot
  if (debug2D === true) {
	  console.log("Layer act: ", layerAct);
  }
  var x1 = [];
  var totalN = 0;
  var totalD = 0;
  for(var i = 0; i < layerAct[0].length; i++){
	// 17.5 is the difference between the x coordinates: 500, 517.5, 535, 552,5 etc.
	// this indicates that we have multiple x1 values
    if(i > 0 && Math.abs(layerAct[0][i][0]-layerAct[0][i-1][0]) != 17.5){
	  if (totalD != 0) {
	      x1.push(Math.round(totalN/totalD));
      	  //console.log("Value: ",Math.round(totalN/totalD) );
      	  //console.log("Reason: ",Math.abs(layerAct[0][i][0]-layerAct[0][i-1][0]));    
      	  totalN = 0;
      	  totalD = 0;
      }
    }
    totalN += layerAct[0][i][0] * layerAct[0][i][1];
    totalD += layerAct[0][i][1];
  }
  if(totalN != 0 && totalD != 0){
    x1.push(Math.round(totalN/totalD));
  }
  if (debug2D === true) {
  	console.log("x1:", x1);
  }
  var weightedX1 = calculatePoint(x1, layerAct, 0, size); 
  if (debug2D === true) {
	  console.log("wx1",weightedX1);
  }
  var x2 = [];
  totalN = 0;
  totalD = 0;
  for(var i = 0; i < layerAct[2].length; i++){
	// 17.5 is the difference between the x coordinates: 500, 517.5, 535, 552,5 etc.
	// this indicates that we have multiple x2 values
    if(i > 0 && Math.abs(layerAct[2][i][0]-layerAct[2][i-1][0])!=17.5){
	  if (totalD != 0) {
	      x2.push(Math.round(totalN/totalD));
	      //console.log("Reason: ",Math.abs(layerAct[2][i][0]-layerAct[2][i-1][0]));    
	      totalN = 0;
	      totalD = 0;
	   }
    }
    totalN += layerAct[2][i][0] * layerAct[2][i][1];
    totalD += layerAct[2][i][1];
  }
  if(totalN != 0 && totalD != 0){
    x2.push(Math.round(totalN/totalD));
  }
  if (debug2D === true) {  
  	console.log("x2:", x2);
  }
  var weightedX2 = calculatePoint(x2, layerAct, 2, size);
  if (debug2D === true) {
    console.log("wx2",weightedX2);
  }
  for(var a = 0; a < x1.length; a++){
    for(var b = 0; b < x2.length; b++){
    //drawPoint(x1[a]+(size/2), lBot, 5);
    //drawPoint(x2[b]+(size/2), lTop, 5);
    drawPoint(weightedX1[a]+(size/2), lBot-3, 10);
    drawPoint(weightedX2[b]+(size/2), lTop-3, 10);
    // Draw the canvas coord for x1 + 17.5, bottom value, coord in x2 + 17.5, top value, 80 for the extension
    drawLine(x1[a]+(size/2), lBot, x2[b]+(size/2), lTop, 80);
  	}
  }
}
		
function drawTriangle(dir, xpos, y, size, channel, inten) {
	  //console.log(dir,xpos,y,size,channel,inten);
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
      //ctx.globalAlpha = 0.5;
      ctx.stroke();
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.moveTo(xpos, y);
      ctx.font = '9px Arial';
      ctx.fillStyle = 'rgba(0, 0, 0, 1)';
      if (channel < 10) {
		ctx.fillText(channel,xpos+17, dir ? y-9 : y+17);  
	  } else {
		ctx.fillText(channel,xpos+14, dir ? y-9 : y+17);
	  }
}
// Draw event on x grid			
function drawX(event, size){
	// Size is 35: width of the triangles in pixels
    var layer = 0;
    var channel = 0;
    var ndx = 1;
    var up = false;
    var startPoint = 255;
	if (layers[0].length === 12) {
		startPoint = 80;
	}
	//console.log((layers[0].length * 2));
    // Calculate the number of triangles based on the geometry
    var xpSize = ((layers[0].length * 2) * size) + startPoint;
	// Read the value of the input
    var layerAct = [[],[],[]];
    // Outer loop is to draw 3 panels
    for (var yp = 70; yp <= 360; yp += 130) {
	  // Inner loop is to draw two rows of triangles starting either up or down
	  if (geometry[ndx][1] === "Tree") {
	  	up = false;
	  } else {
		up = true;
	  } 
	  //console.log(up);
	  //console.log(geometry[ndx][1]);
      for (var xp = startPoint; xp < xpSize; xp += size) {
			// Decide whether we start up or down
        	if(up){
				//console.log("UP")
		        //console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedX[event][layer][channel]);
				var adcChannel = xCoord[event][layer][channel][0];
		        //drawTriangle(true, up ? xp - (size/2) : xp+(size/2), yp+size +3, size, adcChannel, subtractPedX[event][layer][channel]/300);
		        drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, subtractPedX[event][layer][channel]/300);
        		if(subtractPedX[event][layer][channel] > 10){
			        layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , subtractPedX[event][layer][channel]]);  
			    }
        	    channel++;
        		//console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedX[event][layer][channel]);
				var adcChannel = xCoord[event][layer][channel][0];
        		drawTriangle(false, xp+1, yp, size, adcChannel, subtractPedX[event][layer][channel]/300);
        		if(subtractPedX[event][layer][channel] > 10){
 	          		layerAct[layer] .push([xp , subtractPedX[event][layer][channel]]);
 	          	}
        		channel++;
        	} else {
	          	//console.log("X-Event triangle down: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedX[event][layer][channel]);
				var adcChannel = xCoord[event][layer][channel][0];
	          	drawTriangle(false, xp+1, yp, size, adcChannel, subtractPedX[event][layer][channel]/300);
        		if(subtractPedX[event][layer][channel] > 10){
		          	layerAct[layer].push([xp , subtractPedX[event][layer][channel]]);
				}
         		channel++;
          		//console.log("X-Event triangle up: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedX[event][layer][channel]);
				var adcChannel = xCoord[event][layer][channel][0];
				//drawTriangle(true, up ? xp - (size/2) : xp+(size/2), yp+size +3, size, adcChannel, subtractPedX[event][layer][channel]/300);
				drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, subtractPedX[event][layer][channel]/300);
         		if(subtractPedX[event][layer][channel] > 10){
          			layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , subtractPedX[event][layer][channel]]);
          		}
          	    channel++;
        	}// end if inside for loop
      	} //end inner for loop
      	channel = 0;
      	layer++;
	    ndx += 2;
	}// end outer for loop
	lineRoute(layerAct, size, 350, 88);
}
// Draw event on y grid			
function drawY(event, size){
    var layer = 0;
    var channel = 0;
    var ndx = 2;
    var up = false;
    // Calculate the number of triangles based on the geometry
    var xpSize = ((layers[1].length * 2) * size) + 80;
    // Read the value of the input
    var layerAct = [[],[],[]];
    for (var yp = 450; yp <= 710; yp += 130) {
	  if (geometry[ndx][1] === "Tree") {
	  	up = false;
	  } else {
		up = true;
	  } 
	  ///console.log(up);
	  //console.log(geometry[ndx][1]);
      for (var xp = 80; xp < xpSize; xp += size) {
		//console.log(yp + ' '+ xp);
        if(up){
	        //console.log("UPPPPPP");
	        //console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedY[event][layer][channel]);
			var adcChannel = yCoord[event][layer][channel][0];
	        //drawTriangle(true, up ? xp - (size/2) : xp+(size/2), yp+size + 3, size, adcChannel, subtractPedY[event][layer][channel]/300);
	        drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, subtractPedY[event][layer][channel]/300);
	        if(subtractPedY[event][layer][channel] > 10){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , subtractPedY[event][layer][channel]]);
	        }
	        channel++;
	        //console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedY[event][layer][channel]);
			var adcChannel = yCoord[event][layer][channel][0];
	        drawTriangle(false, xp+1, yp, size, adcChannel, subtractPedY[event][layer][channel]/300);
	        if(subtractPedY[event][layer][channel] > 10){
	          	layerAct[layer] .push([xp , subtractPedY[event][layer][channel]]);
	        }
	        //channel++;
        } else {
	        //console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedY[event][layer][channel]);
			var adcChannel = yCoord[event][layer][channel][0];
	        drawTriangle(false, xp+1, yp, size, adcChannel, subtractPedY[event][layer][channel]/300);
	        if(subtractPedY[event][layer][channel] > 10){
	          	layerAct[layer].push([xp , subtractPedY[event][layer][channel]]);
	        }
	        channel++;
	        //console.log("Event: ", event, " Layer: ", layer, " Channel: ", channel, " Intensity: ", subtractPedY[event][layer][channel]);
			var adcChannel = yCoord[event][layer][channel][0];
	        //drawTriangle(true, up ? xp - (size/2) : xp+(size/2), yp+size +3, size, adcChannel, subtractPedY[event][layer][channel]/300);
	        drawTriangle(true, up ? xp - (size/2)+1 : xp+(size/2)+1, yp+size-5, size, adcChannel, subtractPedY[event][layer][channel]/300);
	        if(subtractPedY[event][layer][channel] > 10){
	          	layerAct[layer].push([up ? xp - (size/2) : xp+(size/2) , subtractPedY[event][layer][channel]]);
	        }
          	channel++;
        }// end if inside for loop
      }//end inner for loop
      channel = 0;
      layer++;
      ndx += 2;
   }//end outer for loop
   lineRoute(layerAct, size, 730, 470);
}
	
function draw(event){
  //var up = !geometry[1][1] === "Tree";
  var size = 35;
  //console.log("canvas width and height: ",canvas.width, canvas.height);
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawY(event, size);
  drawX(event, size);
  ctx.font = 'italic 25px Arial';
  ctx.textAlign = 'center';
  ctx.fillStyle = 'rgba(0, 0, 0, 1 )'
  ctx.fillText('X-view display - find muon track with 3 planes', canvas.width / 2, 30);
  ctx.fillText('Y-view display - find muon track with 3 planes', canvas.width / 2, 420);
}

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
	}
	document.getElementById('event').style = "display:inline";
	document.getElementById("quantity").value = 1;
	inputElement.max = subtractPedX.length;
	draw(0);
}