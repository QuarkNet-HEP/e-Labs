var x;
var y;
var detector = [];
var localGeometry;
var singleGeometry = [];
var layers = [];
var localADCmap;
var localPedestal;
var xCoord;
var yCoord;
var eventTotal = [1];
var parameters = {};
var dataGUI;
let debugMain = false;

// Display errors
function print(string) { throw new Error(string); }
// Load STL image of the pyramid
let dataFiles = ['Run17_list_MXStacked_Brd2AND4HoldDelay25ns.txt',
			     'Run18_listMXStacked_HoldDelayBrd2_25ns_Brd4_0ns.txt',
				 'Run19_listMXStacked_HoldDelayBrd2_25ns_Brd4_0ns_Brd4LGShape87.5.txt',
				 'Run10_list_Stacked_BunchTrgPass.txt',
				 'Run11_list_Stacked_T0TrgPass.txt',
				 'Run4_listTrgTest.txt',
				 'Run5_list_ZeroSurpStackedDet.txt',
				 'Run109_list.txt',
				 'Pyramid_FakeTracker_XY-views_Run14_non-ZeroSup.txt',
				 'Pyramid_Run0_non-ZeroSup.txt',
				 'Pyramid_Run1_non-ZeroSup.txt',
				 'Pyramid_OURFakeTracker_XY-views_Run14_non-ZeroSup.txt',
				 'Pyramid_Tracker_XY_1jan25_Run21_ZeroSup.txt',
				 'Pyramid_Tracker_XY_1jan25_Run22_ZeroSup.txt',]

let months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
function parseFileDate(d, t) {
	let day = d.substring(0,2);
	let month = d.substring(2,5);
	let M = months.indexOf(month);
	let y = d.substring(5,9);
	let [h,m,s] = t.split(/[- :]/);
	let newDate =  new Date(parseInt(y),M,parseInt(d),parseInt(h),parseInt(m),parseInt(s));
	return newDate;
}// end of parseFileDate

function getSingleGeometry() {
	timestamps = [];
	done = false;
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
	singleGeometry = []
	layers = [];
	for (let i = 0; i < localGeometry.length; i++) {
		//geometry needs to match detector name, date ?and time
		if (localGeometry[i][0][0] === timestamps[0][0] && localGeometry[i][0][1] === timestamps[0][1] && localGeometry[i][0][2] === timestamps[0][2]) {
			singleGeometry.push(localGeometry[i][0]);
			for (let x = 1; x < 7; x++) {
				singleGeometry.push(localGeometry[i][x]);
				if (localGeometry[i][x][0].startsWith("P")) {
					let layerDetail = [];
					done = false;
					for (let n = 3; n < localGeometry[i][x].length; n++) {
						if (localGeometry[i][x][n] === "OFF") {
							layers.push(layerDetail);
							layerDetail = []
							done = true;
						} else {
							if (done == false) {
								layerDetail.push(localGeometry[i][x][n]);								
							}
						}
					}
				}
			}
		} 
	}
	//console.log(singleGeometry);
}// end of getGeometry
const loadingMessage = document.getElementById("loading-message");

function loadDataFile() {
  return new Promise((resolve) => {
    //const checkInterval = setInterval(() => {
	  function retrieveData() {
        return new Promise((resolve, reject) => {
          globalThis.retrieveData()
          .then(data => {
            resolve(data);
          })
          .catch(error => {
            reject(error);
          });
        });		
	  }     
      // Usage of Promise.all() to wait for functions to finish
	  loadingMessage.style.display = "block";
      Promise.all([retrieveData()])
        .then(([data]) => {
          if (globalThis.subtractPedX != undefined && globalThis.subtractPedX.length > 0) { x = globalThis.subtractPedX; }
          if (globalThis.subtractPedY != undefined && globalThis.subtractPedY.length > 0) { y = globalThis.subtractPedY; }
          if (globalThis.xCoord != undefined && globalThis.xCoord.length > 0) { xCoord = globalThis.xCoord; }
          if (globalThis.yCoord != undefined && globalThis.yCoord.length > 0) { yCoord = globalThis.yCoord; }
           if (x != undefined && y != undefined) {
            if (x.length > 0 && y.length > 0) {
              //clearInterval(checkInterval);
              eventTotal = [];
              eventTotal.push(0);
              for (var i = 0; i < x.length; i++) {
	              eventTotal.push(i+1);
	          }
              GUIupdate("update");
              resolve();
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
          detector = document.getElementById("detector-name").value.trim().split(' ');
          getSingleGeometry();
          draw2DSettings(0, detector, singleGeometry, layers, x, y, xCoord, yCoord); //invoke the 2D display  
          draw3DSettings(detector, singleGeometry, layers, x, y, xCoord, yCoord);
          drawAnalysis(layers);  
          if (debugMain === true) {
	          console.log("Data and geometry are ready");
	          }
		  loadingMessage.style.display = "none";
        })
        .catch(error => {
	      console.log(error);
          console.log("Waiting for data load");
        });
    //}, 10); // Poll every 0.01 seconds
  });
}// end of loadDataFile

function GUIupdate(what) {
    var controller;
    if (what === "update" || what === "clear") {
	    controller = dataGUI.__controllers[1];
    	controller.remove();
    	parameters.eventIndex = 1;
		if (what === "clear") {
			parameters.eventIndex = 0;
		}
    }
	if (what != "remove") {
		dataGUI.add(parameters, 'eventIndex', eventTotal).name("Event").onChange(onEventIndexChange); 		
  		function onEventIndexChange() { loadIndex(parameters.eventIndex); }
  		//dataGUI.__controllers[1].domElement.style = 'height:150px';
  		controller = dataGUI.__controllers[1];
  		//controller.style ='height:150px';
  		//dataGUI.__controllers[1].setAttribute( "style", "height: 150px" );
  		//dataGUI.__controllers[1].style.height = "150px";
  		dataGUI.__controllers[1].updateDisplay();
  	}
}

function GUIinit() {
  //dat gui
  const guiContainer = document.getElementById('gui-container');
  const gui = new dat.GUI({ autoPlace: false });
  guiContainer.appendChild(gui.domElement);
  parameters.loadDataFile = "";
  parameters.eventIndex = 1;
  parameters.acceptRange = 0;
  parameters.showModel = false;
  parameters.showModelWire = true;
  parameters.showSkybox = true;
  parameters.showGround = true;
  //File loading software
  dataGUI = gui.addFolder("Data");
  dataGUI.add(parameters, "loadDataFile", dataFiles).name('Load File').listen().onChange((value)=>{useNewFile(value)});
  dataGUI.add(parameters, 'eventIndex', eventTotal).name("Event").onChange(onEventIndexChange); 
  function onEventIndexChange() {loadIndex(parameters.eventIndex);}
  function useNewFile(value) { 
	console.clear();   
	var selectedFile = document.getElementById('selected-file');
	selectedFile.value = value;
	var path = "data/";
	globalThis.selectedFile = path+value.trim();
 	GUIupdate("remove");    
	loadDataFile();
  }
  dataGUI.open();
  const sceneGUI = gui.addFolder("Scene"); 
  const params = { clearVectors: function() { 
		for (i in muonVectors) { 
			s.group.remove(muonVectors[i]); 
		}
		for (let obj of s.job) {
    		obj.faces.material.color.set(s.xcolor);
    		obj.faces.material.transparent = true;
    		obj.faces.material.opacity = 0.01;
  		}
		GUIupdate("clear"); 
	} 
  };
  sceneGUI.add(params, 'clearVectors').name('Clear Muon Vectors'); 
  sceneGUI.add(parameters, 'acceptRange', 0, 20000).step(1).name("Acceptance Range").onChange(onAcceptanceRangeChange); 
  function onAcceptanceRangeChange() { acceptanceRange(s,parameters.acceptRange) }
  sceneGUI.add(parameters, 'showModel').name("Show Pyramid").onChange(onModelVisibilityChange);
  function onModelVisibilityChange() { loadPyramid(parameters.showModel, parameters.showModelWire);}  
  sceneGUI.add(parameters, 'showModelWire').name("Show Wireframe").onChange(onModelWireframeChange);
  function onModelWireframeChange() { setPyramidWireframe(parameters.showModelWire);}  
  sceneGUI.add(parameters, 'showSkybox').name("Show Skybox").onChange(onSkyboxVisibilityChange);
  function onSkyboxVisibilityChange() { skyboxMesh.visible = parameters.showSkybox; }  
  sceneGUI.add(parameters, 'showGround').name("Show Ground").onChange(onGroundVisibilityChange);
  function onGroundVisibilityChange() { ground.visible = parameters.showGround; }
  sceneGUI.open();
}// end of GUIinit

//function wait(ms) { return new Promise((resolve) => setTimeout(resolve, ms)); }
function loadStaticDataFiles() {
  return new Promise((resolve) => {
    //const checkInterval = setInterval(() => {
      // Function to retrieve pedestal asynchronously
      function retrievePedestal() {
        return new Promise((resolve, reject) => {
          globalThis.retrievePedestal()
          .then(pedestal => {
            resolve(pedestal);
          })
          .catch(error => {
            reject(error);
          });  
        });
      } 
      function retrieveADCmap() {
        return new Promise((resolve, reject) => {
          globalThis.retrieveADCmap()
          .then(adcmap => {
            resolve(adcmap);
          })
          .catch(error => {
            reject(error);
          });  
        });
      } 
      // Function to retrieve geometry asynchronously
      function retrieveGeometry() {
        return new Promise((resolve, reject) => {
          globalThis.retrieveGeometry()
          .then(geometry => {
            resolve(geometry);
          })
          .catch(error => {
            reject(error);
          });  
        });
      }
      // Usage of Promise.all() to wait for functions to finish
      Promise.all([retrievePedestal(), retrieveADCmap(), retrieveGeometry()])
        .then(([pedestal, adcmap, geometry]) => {
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
	                resolve();
	                initScene();
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
        })
        .catch(error => {
	      console.log(error);
          console.log("Waiting for data load");
        });
    //}, 10); // Poll every 0.01 seconds
  });	
}// end of loadStaticDataFiles

async function execute() {
	var geometryFile = document.getElementById("geometry-file");
	var pedestalFile = document.getElementById("pedestal-file");
	var adcmapFile = document.getElementById("adcmap-file");
	var path = "config/";
	globalThis.geometryFile = path+geometryFile.value.trim();
	globalThis.pedestalFile = path+pedestalFile.value.trim();
	globalThis.adcmapFile = path+adcmapFile.value.trim();
 	//await 
    loadStaticDataFiles();
    GUIinit();
}// end of execute

execute();
