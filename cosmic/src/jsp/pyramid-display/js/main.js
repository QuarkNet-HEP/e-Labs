/*
	Edit Peronja 23/10/2025: This script has functions that start and setup the main html page
*/

// Ensure helper functions and muon vector module load and attach globals before this module runs
import './helperFunctions.js';
import './dataFiles.js';
import './muonVector.js';
import './dataRead.js';
// Ensure draw3D module runs so it attaches initScene to window
import './draw3D.js';

globalThis.layerOrderX = [];
globalThis.layerOrderY = [];
globalThis.layers = [];
globalThis.singleGeometry = [];
globalThis.parameters = {};
globalThis.initialTime = null;
globalThis.endTime = null;
globalThis.detector = null
globalThis.totalEvents = 0;
let xLength;
let yLength;
let xCoordLength;
let yCoordLength;
let run = [];
let localGeometry;
let localADCmap;
let localPedestal;
let eventTotal = [1];
let dataGUI;
let debugMain = false;
const loadingMessage = document.getElementById("loading-message");

// Function to get the single geometry corresponding to the selected data file
function getSingleGeometry() {
	let timestamps = [];
	let done = false;
	for (let i = 0; i < localGeometry.length; i++) {
		if (localGeometry[i][0][0] === detector[0]) {
			//01JUL2023 09:46:47
			let gDate = parseFileDate(localGeometry[i][0][1], localGeometry[i][0][2]);
			let dDate = parseFileDate(detector[2], detector[3]);
			if (dDate > gDate && !done) {
					timestamps.push(localGeometry[i][0]);
					done = true;
					
			}
		}
	}
	//these two are global variables
	globalThis.singleGeometry = []
	globalThis.layers = [];
	// Instead of reassigning, clear the existing arrays so the global references remain valid
	globalThis.layerOrderX.length = 0;
	globalThis.layerOrderY.length = 0;
	for (let i = 0; i < localGeometry.length; i++) {
		//geometry needs to match detector name, date and time
		if (localGeometry[i][0][0] === timestamps[0][0] && localGeometry[i][0][1] === timestamps[0][1] && localGeometry[i][0][2] === timestamps[0][2]) {
			globalThis.singleGeometry.push(localGeometry[i][0]);
			for (let x = 1; x < 7; x++) {
				globalThis.singleGeometry.push(localGeometry[i][x]);
				if (localGeometry[i][x][0].startsWith("P")) {
					let layerDetail = [];
					done = false;
					for (let n = 3; n < localGeometry[i][x].length; n++) {
						if (localGeometry[i][x][n] === "OFF") {
							globalThis.layers.push(layerDetail);
							layerDetail = []
							done = true;
						} else {
							if (done == false) {
								layerDetail.push(localGeometry[i][x][n]);						}
						}
					}
				}
			}
		}
	}
	//get the layer order from the geometry
	// push into the existing arrays so global references remain valid
	globalThis.layerOrderX.push([parseFloat(globalThis.singleGeometry[1][globalThis.singleGeometry[1].length-4]),5,0]);
	globalThis.layerOrderX.push([parseFloat(globalThis.singleGeometry[3][globalThis.singleGeometry[3].length-4]),3,1]);
	globalThis.layerOrderX.push([parseFloat(globalThis.singleGeometry[5][globalThis.singleGeometry[5].length-4]),1,2]);
	// Sort in ascending order by the first element (preserve original behavior)
	globalThis.layerOrderX.sort(function(a, b) {
	  return a[0] - b[0]; 
	});
	//console.log(layerOrderX);
	globalThis.layerOrderY.push([parseFloat(globalThis.singleGeometry[2][globalThis.singleGeometry[2].length-4]),6,0]);
	globalThis.layerOrderY.push([parseFloat(globalThis.singleGeometry[4][globalThis.singleGeometry[4].length-4]),4,1]);
	globalThis.layerOrderY.push([parseFloat(globalThis.singleGeometry[6][globalThis.singleGeometry[6].length-4]),2,2]);
	// Sort in ascending order by the first element (preserve original behavior)
	globalThis.layerOrderY.sort(function(a, b) {
	  return a[0] - b[0]; 
	});
	//console.log(layerOrderY);
}// end of getGeometry

// Load the selected data file
async function loadDataFile() {
  // Keep the same visible side-effects (loadingMessage) and return a Promise via async
  loadingMessage.style.display = "block";
  globalThis.initialTime = new Date();
  try {
    // retrieveData already returns a Promise; await it directly
    const data = await globalThis.retrieveData();
    if (globalThis.subtractPedX != undefined && globalThis.subtractPedX.length > 0) { xLength = globalThis.subtractPedX.length; }
    if (globalThis.subtractPedY != undefined && globalThis.subtractPedY.length > 0) { yLength = globalThis.subtractPedY.length; }
    if (globalThis.xCoord != undefined && globalThis.xCoord.length > 0) { xCoordLength = globalThis.xCoord.length; }
    if (globalThis.yCoord != undefined && globalThis.yCoord.length > 0) { yCoordLength = globalThis.yCoord.length; }
    if (globalThis.subtractPedX != undefined && globalThis.subtractPedY != undefined) {
      if (xLength > 0 && yLength > 0) {
        eventTotal = [];
        eventTotal.push(0);
        for (let i = 0; i < xLength; i++) {
          eventTotal.push(i+1);
        }
		globalThis.totalEvents = eventTotal.length - 1;
        GUIupdate("update");
      } else {
        if (debugMain === true) {
          console.log("Data and/or geometry are empty");
        }
      }
    } else {
      if (debugMain === true) {
        console.log("Data and geometry are not defined properly");
      }
    }

    globalThis.detector = document.getElementById("detector-name").value.trim().split(' ');
    getSingleGeometry();
    draw2DSettings(0);
    draw3DSettings();
    drawCharts();
    if (debugMain === true) {
      console.log("Data and geometry are ready");
    }
    globalThis.endTime = new Date();
    document.getElementById("loading-time").value = "Loading time: "+calculateProcessTime(globalThis.endTime,globalThis.initialTime)+" seconds";
  } catch (error) {
    console.log(error);
    console.log("Waiting for data load");
  } finally {
    loadingMessage.style.display = "none";
  }
}

function GUIupdate(what) {
    let controller;
    if (what === "update" || what === "clear") {
	    controller = dataGUI.__controllers[1];
    	controller.remove();
    	globalThis.parameters.eventIndex = 1;
		if (what === "clear") {
			globalThis.parameters.eventIndex = 0;
		}
    }
	if (what != "remove") {
		//dataGUI.add(parameters, 'eventIndex', 1,eventTotal.length).step(1).name("Event").onChange(onEventIndexChange); 		
		dataGUI.add(globalThis.parameters, 'eventIndex', eventTotal).name("Event").onChange(onEventIndexChange); 
  		function onEventIndexChange() { loadIndex(globalThis.parameters.eventIndex); }
  		controller = dataGUI.__controllers[1];
  		dataGUI.__controllers[1].updateDisplay();
	}
}

// Create 3D datgui
function GUIinit() {
  //dat gui
  const guiContainer = document.getElementById('gui-container');
  const gui = new dat.GUI({ autoPlace: false });
  guiContainer.appendChild(gui.domElement);
  globalThis.parameters.loadDataFile = "";
  globalThis.parameters.eventIndex = 1;
  globalThis.parameters.acceptRange = 0;
  globalThis.parameters.showModel = false;
  globalThis.parameters.showModelWire = true;
  globalThis.parameters.showSkybox = true;
  globalThis.parameters.showGround = true;
  //File loading software
  dataGUI = gui.addFolder("Data");
  dataGUI.add(globalThis.parameters, "loadDataFile", dataFiles).name('Load File').listen().onChange((value)=>{useNewFile(value)});
  //dataGUI.add(parameters, 'eventIndex',0,eventTotal.length).step(1).name("Event").onChange(onEventIndexChange); 
  dataGUI.add(globalThis.parameters, 'eventIndex', eventTotal).name("Event").onChange(onEventIndexChange); 
  function onEventIndexChange() {loadIndex(globalThis.parameters.eventIndex);} 
  function useNewFile(value) { 
	console.clear();   
	const selectedFile = document.getElementById('selected-file');
	selectedFile.value = value;
	const path = "data/";
	globalThis.selectedFileClean = value.trim();
	globalThis.selectedFile = path+value.trim();
 	GUIupdate("remove");    
	loadDataFile();
  }
  dataGUI.open();
  const sceneGUI = gui.addFolder("Scene"); 
  const params = { clearVectors: function() { 
		for (let i in globalThis.muonVectors) { 
			globalThis.sensor.group.remove(globalThis.muonVectors[i]); 
		}
		for (let obj of globalThis.sensor.job) {
    		obj.faces.material.color.set(globalThis.sensor.xcolor);
    		obj.faces.material.transparent = true;
    		obj.faces.material.opacity = 0.01;
  		}
		GUIupdate("clear"); 
	} 
  };
  sceneGUI.add(params, 'clearVectors').name('Clear Muon Vectors'); 
  sceneGUI.add(globalThis.parameters, 'acceptRange', 0, 20000).step(1).name("Acceptance Range").onChange(onAcceptanceRangeChange); 
  function onAcceptanceRangeChange() { acceptanceRange(parameters.acceptRange) }
  sceneGUI.add(globalThis.parameters, 'showModel').name("Show Pyramid").onChange(onModelVisibilityChange);
  function onModelVisibilityChange() { loadPyramid(globalThis.parameters.showModel, globalThis.parameters.showModelWire);}  
  sceneGUI.add(globalThis.parameters, 'showModelWire').name("Show Wireframe").onChange(onModelWireframeChange);
  function onModelWireframeChange() { setPyramidWireframe(globalThis.parameters.showModelWire);}  
  sceneGUI.add(globalThis.parameters, 'showSkybox').name("Show Skybox").onChange(onSkyboxVisibilityChange);
  function onSkyboxVisibilityChange() { skyboxMesh.visible = globalThis.parameters.showSkybox; }  
  sceneGUI.add(globalThis.parameters, 'showGround').name("Show Ground").onChange(onGroundVisibilityChange);
  function onGroundVisibilityChange() { ground.visible = globalThis.parameters.showGround; }
  sceneGUI.open();
}// end of GUIinit

//function wait(ms) { return new Promise((resolve) => setTimeout(resolve, ms)); }
async function loadStaticDataFiles() {
  // Return a Promise via async; await the three retrievals in parallel
  try {
    const [pedestal, adcmap, geometry] = await Promise.all([
      globalThis.retrievePedestal(),
      globalThis.retrieveADCmap(),
      globalThis.retrieveGeometry()
    ]);

    if(globalThis.pedestalArr.length > 0) {
		localPedestal = globalThis.pedestalArr;
		if (debugMain === true) {
			console.log("We got pedestal data");
		}
		if(globalThis.adcmapArr.length > 0) {
			if (debugMain === true) {
				console.log("We got adcmap data");
			}
			localADCmap = globalThis.adcmapArr;
			if(globalThis.geometryArr.length > 0) {
				if (debugMain === true) {
				   console.log("We got geometry data");
				}
				localGeometry = globalThis.geometryArr;
				initScene();
				return;
			} else {
				if (debugMain === true) {
					console.log("Geometry is empty");	
				}
			}
		} else {
			if (debugMain === true) {
				console.log("Adcmap is empty");	
			}
		}
    } else {
		if (debugMain === true) { 	  
			console.log("Pedestal is empty");
		}
	}
  } catch (error) {
    console.log(error);
    console.log("Waiting for data load");
  }
}// end of loadStaticDataFiles

async function execute() {
	const geometryFile = document.getElementById("geometry-file");
	const pedestalFile = document.getElementById("pedestal-file");
	const adcmapFile = document.getElementById("adcmap-file");
	const path = "config/";
	globalThis.geometryFile = path+geometryFile.value.trim();
	globalThis.pedestalFile = path+pedestalFile.value.trim();
	globalThis.adcmapFile = path+adcmapFile.value.trim();
 	// Note: preserve original behavior where loadStaticDataFiles was not awaited
    loadStaticDataFiles();
    GUIinit();
}// end of execute

// Begin everything
execute();