function disableSelection(target){
	if (typeof target.onselectstart!="undefined") {//IE route
		target.onselectstart = function() {
			return false
		};
	}
	else if (typeof target.style.MozUserSelect!="undefined") {//Firefox route
		target.style.MozUserSelect = "none";
	}
	else {//All other route (ie: Opera)
		target.onmousedown = function() { 
			return false 
		};
	}
}


function keys(o) {
	s = "";
	for (var i in o) {
		s += i + ", ";
	}
	return s;
}

function toggle(key) {
	disabled[key] = !disabled[key];
	document.draw();
}

var disabled = new Array();
var ranks = new Array();

function addSwitchRow(html) {
	var tbl = document.getElementById("switches");
	tbl.insertRow(tbl.rows.length).innerHTML = html;
}

function clearSwitchRows() {
	var tbl = document.getElementById("switches");
	while (tbl.rows.length > 0) {
		tbl.deleteRow(0);
	}
}

if (d_event) {
	document.d_event = {"Collections": {}}; 
}

function initializeData() {
	var d_event = document.d_event;
	clearSwitchRows();
	for (var g = 0; g < d_groups.length; g++) {
		addSwitchRow('<td colspan="2" class="group">' + d_groups[g] + '</td>');
		for (var key in d_descr) {
			if (d_descr[key].group != d_groups[g]) {
				continue;
			}
			if (!d_event["Collections"][key]) {
				continue;
			}
			var on = d_descr[key].on ? ' checked="true"' : "";
			var count = d_event["Collections"][key].length;
			if (!d_descr[key].on) {
				disabled[key] = true;
			}
			var desc = d_descr[key].desc;
			if (desc == null) {
				desc = key;
			}
			var html = '<td class="sw">' + desc + ' (' + count + ')</td><td><input type="checkbox" id="' + key + '"' + on + ' onchange="toggle(\''+ key + '\');">';
			if (d_descr[key].rank) {
				html += '</td><td><img src="../graphics/range-selector.png" class="range-selector-button" onclick="showRange(event, \'' + key + '\');" />';
			}
			else {
				html += '</td><td>';
			}
			html += '</td>';
			addSwitchRow(html);
		}
	}
	fleXenv.fleXcrollMain("switches-div");
	
	document.perfWeights = buildPerformanceWeights();
	
	var data = new Array();
	  
	for (var key in d_descr) {
		var edata = d_event["Collections"][key];
		if (!edata) {
			continue;
		}
		if (edata.length == 0) {
			continue;
		}
		var vec = new Array();
		data[key] = vec;
		var desc = d_descr[key];
		desc.key = key;
		var fn = desc.fn;
		var type = desc.type;
		var rd = getRankingData(d_event, desc, edata);
		d_descr[key].rd = rd;
		var dataref = null;
		if (desc.dataref) {
			dataref = d_event["Collections"][desc.dataref];
		}
		if (type == TRACK || type == CURVES) {
			lines = fn(edata, rd, desc, dataref, d_event["Associations"][desc.assoc]);
			for (var k = 0; k < lines.length; k++) {
				vec.push(lines[k]);
			}
		}
		else if (type == LINES) {
			for (var j = 0; j < edata.length; j++) {
				lines = fn(edata[j], rd, desc);
				for (var k = 0; k < lines.length; k++) {
					vec.push(lines[k]);
				}
			}
		}
		else {
			for (var j = 0; j < edata.length; j++) {
				var obj = fn(edata[getIndex(rd, j)], rd, desc);
				if (obj != null) {
					vec.push(obj);
				}
			}
		}
	}
	
	document.data = data;
}

function buildPerformanceWeights() {
	var pw = [];
	for (var key in d_descr) {
		var desc = d_descr[key];
		if (d_event["Collections"][key]) {
			var l = d_event["Collections"][key].length;
			pw.push([key, d_event["Collections"][key].length * WEIGHTS[desc.type]]);
		}
	}
	var sw = pw.sort(function(a, b) { return a[1] - b[1] });
	log("pw: " + sw);
	return pw;
}

function pastDeadline(deadline) {
	return new Date().getTime() > deadline;
}

function getIndex(rd, i) {
	if (rd === null) {
		return i;
	}
	else {
		return rd.dataOrder[i];
	}
}

var GLOBAL_RANK_THRESHOLD = 0.9;

window.addEventListener('load', function() {
	restoreSettingsFromCookie();
	if (document.settings.invertColors) {
		document.body.className = "white";
	}
	else {
		document.body.className = "black";
	}
	
	initializeData();
	
	var black = new Pre3d.RGBA(0, 0, 0, 1);
	var white = new Pre3d.RGBA(1, 1, 1, 1);

	var screen_canvas = document.getElementById('canvas');
	disableSelection(screen_canvas);
	var renderer = new Pre3d.Renderer(screen_canvas);
	document.renderer = renderer;
	
	var arrowX = Pre3d.ShapeUtils.makeSolidArrow(0, 0, 0, 1, 0, 0, 10);
	var arrowY = Pre3d.ShapeUtils.makeSolidArrow(0, 0, 0, 0, 1, 0, 10);
	var arrowZ = Pre3d.ShapeUtils.makeSolidArrow(0, 0, 0, 0, 0, 1, 10);
	arrowX.fillColor = new Pre3d.RGBA(1, 0, 0, 1);
	arrowY.fillColor = new Pre3d.RGBA(0, 1, 0, 1);
	arrowZ.fillColor = new Pre3d.RGBA(0, 0, 1, 1);
	
	
	var TARGET_FPS = 30;
	var NEVER = 100000000000000000;
	var fastDraw = null;
    var slowDraw = null;
    
    function setCamera() {
    	var camera_state = document.cameraState;
        var ct = renderer.camera.transform;
        ct.reset();
        ct.rotateZ(camera_state.rotate_z);
        ct.rotateY(camera_state.rotate_y);
        ct.rotateX(camera_state.rotate_x);
        ct.translate(camera_state.x, camera_state.y, camera_state.z);
    }
    
	function redraw() {
		if (fastDraw != null) {
			clearTimeout(fastDraw);
		}
		if (slowDraw != null) {
			clearTimeout(slowDraw);
		}

		slowDraw = setTimeout(function() {
			slowDraw = null;
			setCamera();
			draw(NEVER);
		}, 100);
      
		fastDraw = setTimeout(function() {
			fastDraw = null;
			var now = new Date().getTime();
			setCamera();
			draw(now + 1000 / TARGET_FPS);
		}, 1);
	}
	
	var lastRoundCount = 1000;
	var lastChunkCount = 100000;

	function draw(deadline) {
		var start = new Date().getTime();
		if (deadline == NEVER) {
			lastRoundCount = 100000;
			lastChunkCount = 1000;
		}
		
		var perfWeights = document.perfWeights;
		var d_event = document.d_event;
		var data = document.data;
		
		renderer.precomputeTransform();
		renderer.ambientLight = 0.5;
		renderer.draw_overdraw = false;
		//renderer.createOffscreenBuffer();

		if (document.settings.invertColors) {
			renderer.ctx.setStrokeColor = function setStrokeColor(r, g, b, a) {
		        var rgba = [Math.floor((1-r) * 255), Math.floor((1-g) * 255), Math.floor((1-b) * 255), a];
		        this.strokeStyle = 'rgba(' + rgba.join(',') + ')';
		      }
			renderer.ctx.setFillColor = function setFillColor(r, g, b, a) {
		        var rgba = [Math.floor((1-r) * 255), Math.floor((1-g) * 255), Math.floor((1-b) * 255), a];
		        this.fillStyle = 'rgba(' + rgba.join(',') + ')';
		      }
		} 
		else {
			renderer.ctx.setStrokeColor = function setStrokeColor(r, g, b, a) {
		        var rgba = [Math.floor(r * 255), Math.floor(g * 255), Math.floor(b * 255), a];
		        this.strokeStyle = 'rgba(' + rgba.join(',') + ')';
		      }
			renderer.ctx.setFillColor = function setFillColor(r, g, b, a) {
		        var rgba = [Math.floor(r * 255), Math.floor(g * 255), Math.floor(b * 255), a];
		        this.fillStyle = 'rgba(' + rgba.join(',') + ')';
		      }
		}
		
		renderer.ctx.setFillColor(0, 0, 0, 1);
		renderer.drawBackground();
    
		for (var i = 0; i < perfWeights.length; i++) {
			var key = perfWeights[i][0];
			if (disabled[key]) {
				continue;
			}
			if (!data[key]) {
				continue;
			}
			var d = d_descr[key];
			if (d.color) {
				var c = d.color;
				renderer.ctx.setStrokeColor(c[0], c[1], c[2], c[3]);
			}
			if (d.fill) {
				var c = d.fill;
				renderer.ctx.setFillColor(c[0], c[1], c[2], c[3]);
			}
			if (d.lineWidth) {
				renderer.ctx.lineWidth = d.lineWidth;
			}
			var vec = data[key];
			var rd = d_descr[key].rd;
			switch (d.type) {
				case TRACK: 
				case LINES:
				case LINE:
					var lineCaps = d.lineCaps;
					if (lineCaps != null) {
						for (var j = 0; j < vec.length; j++) {
							renderer.drawLineWithCaps(vec[j].p1, vec[j].p2, lineCaps);
						}
					}
					else {
						for (var j = 0; j < vec.length; j++) {
							renderer.drawLine(vec[j].p1, vec[j].p2);
						}
					}
					break;
				case CURVES:
					for (var j = 0; j < vec.length; j++) {
						renderer.drawCurve(vec[j]);
					}
					break;
				case POINT:
					var shape;
					if (d.shape) {
						shape = d.shape;
					}
					else {
						shape = "x";
					}
					for (var k = 0; k <= vec.length / 1000; k++) {
						renderer.drawPoints(vec, shape, k * 1000, Math.min(k * 1000 + 1000, vec.length));
						if (k == lastChunkCount || pastDeadline(deadline)) {
							lastChunkCount = k;
							break;
						}
					}
					break;
				case SHAPE:
					var first = 0;
					var last = vec.length;
					if (rd !== null) {
						if (rd.dirty) {
							rebuildRankingIndices(rd);
						}
						first = rd.lowIndex;
						last = rd.highIndex;
					}
					for (var j = first; j < last; j++) {
						renderer.bufferShape(vec[j]);
					}
					break;
			}
			if (i >= lastRoundCount || pastDeadline(deadline)) {
				//Avoid flickering by alternating things to draw.
				//If in quick rendering mode, only draw up to what was drawn last time
				lastRoundCount = i;
				break;
			}
		}
	
		renderer.drawBuffer();
		renderer.emptyBuffer();
		
		//renderer.renderOffscreenBuffer();
    
		drawAxes(renderer, screen_canvas);
		
		
		var end = new Date().getTime();
		if (document.settings.showFPS) {
			renderer.ctx.setFillColor(1, 1, 1, 1);
			renderer.ctx.fillText("fps: " + Math.round(10000 / (end - start))/10, 10, 10);
			renderer.ctx.fillText("deadline: " + (deadline - start), 10, 20);
		}
	}
  
	function drawAxes(renderer, canvas) {
		renderer.ctx.lineWidth = 2;
		var w = canvas.width;
		var h = canvas.height;
		  
		renderer.ambientLight = 0.2;
		var ct = renderer.camera.transform;
		var x = ct.m.e3;
		var y = ct.m.e7;
		var z = ct.m.e11;
		ct.translate(-x, -y, -z - 20);
		renderer.precomputeTransform();
		renderer.draw_overdraw = true;
		
		renderer.ctx.save();
		renderer.ctx.translate(w / 2 - 50, h / 2 - 50);
		renderer.stroke_rgba = null;
		renderer.bufferShape(arrowX);
		renderer.bufferShape(arrowY);
		renderer.bufferShape(arrowZ);
		renderer.drawBuffer();
		renderer.emptyBuffer();
		renderer.ctx.setStrokeColor(1, 1, 0, 1);
		renderer.ctx.setFillColor(1, 1, 0, 1);
		renderer.ctx.font = "9pt Arial";
		renderer.drawText({x: 1.1, y: 0, z: 0}, "x");
		renderer.drawText({x: 0, y: 1.1, z: 0}, "y");
		renderer.drawText({x: 0, y: 0, z: 1.1}, "z");
		renderer.ctx.restore();
		renderer.draw_overdraw = false;
		ct.translate(x, y, z + 20);
	}

	renderer.camera.focal_length = 2.5;
	// Have the engine handle mouse / camera movement for us.
	document.cameraState = DemoUtils.autoCamera(renderer, 0, 0, -30, 0.40, -1.06, 0, redraw);

	document.addEventListener('keydown', function(e) {
		if (e.keyCode != 84)  // t
			return;
		
		toggleBackground();
	}, false);
	

	redraw();
	document.draw = redraw;
}, false);

function toggleBackground() {
	if (document.settings.invertColors) {
		document.body.className = "black";
	}
	else {
		document.body.className = "white";
	}
	document.settings.invertColors = !document.settings.invertColors;
	document.draw();
	if (document.redrawRange) {
		document.redrawRange();
	}
};

function setCameraRotation(rx, ry, rz) {
	var ct = document.renderer.camera.transform;
	var x = ct.m.e3;
	var y = ct.m.e7;
	var z = ct.m.e11;
	ct.reset();
	//this is the order that demo_utils does it in
	ct.rotateZ(rz);
	ct.rotateY(ry);
	ct.rotateX(rx);
	ct.translate(x, y, z);
	document.cameraState.rotate_x = rx;
	document.cameraState.rotate_y = ry;
	document.cameraState.rotate_z = rz;
	document.draw();
}
