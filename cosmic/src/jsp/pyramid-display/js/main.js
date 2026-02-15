/*
	Edit Peronja 23/10/2025: This script has functions that start and setup the main html page
*/

// Ensure helper functions and muon vector module load and attach globals before this module runs
import './helperFunctions.js';
import './dataFiles.js';
import './dataRead.js';
// Ensure draw3D module runs so it attaches initScene to window
import './draw3D.js';
import './muonVector.js';
// Global variables
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
  resetCameraPosition();
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
  try {
    const eventSelect = document.getElementById('event-selector');
    if (!eventSelect) return;
    if (what === 'remove') {
      // disable and clear
      if (eventSelect.tagName === 'SELECT') {
        eventSelect.innerHTML = '';
      } else if (eventSelect.tagName === 'INPUT' && eventSelect.type === 'number') {
        eventSelect.value = '';
      }
      eventSelect.disabled = true;
      return;
    }
    // rebuild options
    if (eventSelect.tagName === 'SELECT') {
      eventSelect.innerHTML = '';
      for (let i = 0; i < eventTotal.length; i++) {
        const opt = document.createElement('option');
        opt.value = eventTotal[i];
        opt.textContent = String(eventTotal[i]);
        eventSelect.appendChild(opt);
      }
      if (what === 'clear') {
        eventSelect.value = '0';
      } else {
        eventSelect.value = String(globalThis.parameters.eventIndex || 1);
      }
      eventSelect.disabled = false;
    } else if (eventSelect.tagName === 'INPUT' && eventSelect.type === 'number') {
      // spinner input: set min/max and value
      const minVal = (eventTotal && eventTotal.length > 0) ? eventTotal[0] : 0;
      const maxVal = (eventTotal && eventTotal.length > 0) ? eventTotal[eventTotal.length - 1] : 0;
      eventSelect.min = String(minVal);
      eventSelect.max = String(maxVal);
      if (what === 'clear') {
        eventSelect.value = String(minVal || 0);
      } else {
        // default to parameter or 1 (keep behaviour)
        const v = (typeof globalThis.parameters.eventIndex === 'number' && !isNaN(globalThis.parameters.eventIndex)) ? globalThis.parameters.eventIndex : 1;
        eventSelect.value = String(v);
      }
      eventSelect.disabled = false;
    }
  } catch (e) { console.warn('GUIupdate failed', e); }
}

// Create a custom DOM-based GUI (replacing dat.GUI)
function GUIinit() {
  const container = document.getElementById('gui-container');
  if (!container) {
    console.warn('No #gui-container found for GUIinit');
    return;
  }

  // clear previous contents
  container.innerHTML = '';
  globalThis.parameters.eventIndex = 1;
  globalThis.parameters.acceptRange = 0;
  globalThis.parameters.showModel = true;
  globalThis.parameters.showModelWire = true;
  globalThis.parameters.showSkybox = true;
  globalThis.parameters.showGround = true;
  function makeSection(title) {
    const sec = document.createElement('div');
    sec.className = 'custom-gui-section';
    const hdr = document.createElement('div'); hdr.className = 'custom-gui-header'; hdr.textContent = title;
    hdr.style.cursor = 'pointer'; hdr.style.padding = '6px 8px'; hdr.style.background = 'rgba(40,40,40,0.9)'; hdr.style.color = '#fff';
    // ensure header text is visibly white and bold even if parent rules set colors
    try { hdr.style.setProperty('color', '#ffffff', 'important'); } catch(e) { hdr.style.color = '#fff'; }
    try { hdr.style.setProperty('font-weight', '700', 'important'); } catch(e) { hdr.style.fontWeight = '700'; }
    hdr.style.borderRadius = '4px';
    const body = document.createElement('div'); body.className = 'custom-gui-body'; body.style.padding = '8px'; body.style.display = 'none';
    hdr.addEventListener('click', () => { body.style.display = body.style.display === 'none' ? 'block' : 'none'; });
    sec.appendChild(hdr); sec.appendChild(body); container.appendChild(sec);
    return {sec, hdr, body};
  }

  // Data section
  const dataSection = makeSection('Data');
  // Load File select
  const loadRow = document.createElement('div'); loadRow.style.display = 'flex'; loadRow.style.gap = '8px'; loadRow.style.alignItems = 'center';
  const loadLabel = document.createElement('label'); loadLabel.textContent = 'Load File'; loadLabel.style.minWidth = '80px'; loadLabel.style.color = '#000000';
  const loadSelect = document.createElement('select'); loadSelect.id = 'data-file-select'; loadSelect.style.flex = '1';
  try {
    if (typeof dataFiles !== 'undefined' && Array.isArray(dataFiles)) {
      for (const f of dataFiles) { const o = document.createElement('option'); o.value = f; o.textContent = f; loadSelect.appendChild(o); }
    }
  } catch (e) { console.warn('Failed to populate dataFiles', e); }
  loadSelect.addEventListener('change', (e) => { const v = e.target.value; try { useNewFile(v); } catch(err) { console.warn(err); } });
  loadRow.appendChild(loadLabel); loadRow.appendChild(loadSelect); dataSection.body.appendChild(loadRow);

  // Event selector
  const eventRow = document.createElement('div'); eventRow.style.display = 'flex'; eventRow.style.gap = '8px'; eventRow.style.alignItems = 'center'; eventRow.style.marginTop = '8px';
  const eventLabel = document.createElement('label'); eventLabel.textContent = 'Event'; eventLabel.style.minWidth = '80px'; eventLabel.style.color = '#000000';
  // Use a numeric spinner input instead of a <select> so users can type or use arrow keys
  const eventSelect = document.createElement('input'); eventSelect.type = 'number'; eventSelect.id = 'event-selector'; eventSelect.style.width = '140px'; eventSelect.disabled = true; eventSelect.min = '0'; eventSelect.value = '0'; eventSelect.step = '1';
  // On change, load the selected event index
  eventSelect.addEventListener('change', (e) => { const v = e.target.value; try { loadIndex(Number(v)); globalThis.parameters.eventIndex = Number(v); } catch(err) { console.warn(err); } });
  eventRow.appendChild(eventLabel); eventRow.appendChild(eventSelect); dataSection.body.appendChild(eventRow);

  // expose useNewFile for local scope
  function useNewFile(value) {
    console.clear();
    const selectedFile = document.getElementById('selected-file'); if (selectedFile) selectedFile.value = value;
    const path = 'data/'; globalThis.selectedFileClean = value.trim(); globalThis.selectedFile = path + value.trim();
    GUIupdate('remove');
    loadDataFile();
  }

  // open data section by default
  dataSection.body.style.display = 'block';

  // Scene section
  const sceneSection = makeSection('Scene'); sceneSection.body.style.display = 'block';

  // Clear Muon Vectors button
  const clearBtn = document.createElement('button'); clearBtn.textContent = 'Clear Muon Vectors'; clearBtn.style.display = 'block'; clearBtn.style.marginBottom = '8px';
  clearBtn.addEventListener('click', () => {
    for (let i in globalThis.muonVectors) { globalThis.sensor.group.remove(globalThis.muonVectors[i]); }
    for (let obj of globalThis.sensor.job) { obj.faces.material.color.set(globalThis.sensor.xcolor); obj.faces.material.transparent = true; obj.faces.material.opacity = 0.01; }
    GUIupdate('clear');
  });
  sceneSection.body.appendChild(clearBtn);

  // Acceptance Range control (slider + number)
  const arRow = document.createElement('div'); arRow.style.display = 'flex'; arRow.style.alignItems = 'center'; arRow.style.gap = '8px';
  const arLabel = document.createElement('label'); arLabel.textContent = 'Acceptance Range'; arLabel.style.minWidth = '120px'; arLabel.style.color = '#000000';
  const arRange = document.createElement('input'); arRange.type = 'range'; arRange.min = 0; arRange.max = 20000; arRange.step = 1; arRange.value = String(globalThis.parameters.acceptRange || 0);
  arRange.style.width = '220px'; const arNum = document.createElement('input'); arNum.type = 'number'; arNum.min = 0; arNum.max = 20000; arNum.step = 1; arNum.value = String(globalThis.parameters.acceptRange || 0); arNum.style.width = '80px';
  arRange.addEventListener('input', (e) => { const v = Number(e.target.value); arNum.value = String(v); globalThis.parameters.acceptRange = v; try { acceptanceRange(v); } catch(er){} });
  arNum.addEventListener('change', (e) => { const v = Number(e.target.value); arRange.value = String(v); globalThis.parameters.acceptRange = v; try { acceptanceRange(v); } catch(er){} });
  arRow.appendChild(arLabel); arRow.appendChild(arRange); arRow.appendChild(arNum); sceneSection.body.appendChild(arRow);

  // Show Pyramid checkbox
  function makeCheckbox(labelText, initial, onChange) {
    const row = document.createElement('div'); row.style.display = 'flex'; row.style.alignItems = 'center'; row.style.gap = '8px'; row.style.marginTop = '8px';
    const label = document.createElement('label'); label.textContent = labelText; label.style.minWidth = '120px'; label.style.color = '#000000';
    const cb = document.createElement('input'); cb.type = 'checkbox'; cb.checked = !!initial;
    cb.addEventListener('change', (e) => { try { onChange(e.target.checked); } catch(err){ console.warn(err); } });
    row.appendChild(label); row.appendChild(cb); sceneSection.body.appendChild(row);
    return cb;
  }

  const cbShowModel = makeCheckbox('Show Pyramid', globalThis.parameters.showModel, (v) => { globalThis.parameters.showModel = v; try { loadPyramid(globalThis.parameters.showModel, globalThis.parameters.showModelWire); } catch(e){} });
  const cbShowWire = makeCheckbox('Show Wireframe', globalThis.parameters.showModelWire, (v) => { globalThis.parameters.showModelWire = v; try { setPyramidWireframe(globalThis.parameters.showModelWire); } catch(e){} });
  const cbSkybox = makeCheckbox('Show Skybox', globalThis.parameters.showSkybox, (v) => { globalThis.parameters.showSkybox = v; try { skyboxMesh.visible = globalThis.parameters.showSkybox; } catch(e){} });
  const cbGround = makeCheckbox('Show Ground', globalThis.parameters.showGround, (v) => { globalThis.parameters.showGround = v; try { ground.visible = globalThis.parameters.showGround; } catch(e){} });

  // Pyramid Tuning toggle (show/hide the tuning panel created by createPyramidTuningUI)
  try {
    const tuningRow = document.createElement('div');
    tuningRow.style.display = 'flex'; tuningRow.style.alignItems = 'center'; tuningRow.style.gap = '8px'; tuningRow.style.marginTop = '8px';
    const tuningLabel = document.createElement('label'); tuningLabel.textContent = 'Pyramid Tuning'; tuningLabel.style.minWidth = '120px'; tuningLabel.style.color = '#000000';
    const tuningCb = document.createElement('input'); tuningCb.type = 'checkbox'; tuningCb.checked = false;
    tuningRow.appendChild(tuningLabel); tuningRow.appendChild(tuningCb); sceneSection.body.appendChild(tuningRow);

    // Prevent clicks on the checkbox from bubbling to the section header (which would toggle body display)
    tuningCb.addEventListener('click', (e) => { try { e.stopPropagation(); } catch(err) {} });

    function setTuningVisible(visible) {
      try {
        let panel = document.getElementById('pyramid-tuning-ui');
        // If the panel doesn't exist yet, create it into our tuning container if possible
        if (!panel) {
          try {
            const tuningContainer = document.getElementById('pyramid-tuning-container') || document.getElementById('gui-container') || null;
            if (typeof window !== 'undefined' && typeof window.createPyramidTuningUI === 'function') {
              try { window.createPyramidTuningUI(tuningContainer); } catch(e) { try { window.createPyramidTuningUI(); } catch(_) {} }
            }
            panel = document.getElementById('pyramid-tuning-ui');
          } catch(e) { /* ignore */ }
        }
        if (panel) {
          panel.style.display = visible ? '' : 'none';
          if (visible) {
            // bring to front and ensure it's visible
            try { panel.style.zIndex = '100000'; panel.scrollIntoView({ behavior: 'smooth', block: 'nearest' }); } catch(e) {}
          }
        }
      } catch(e) { console.warn('setTuningVisible failed', e); }
    }
    tuningCb.addEventListener('change', (e) => { try { e.stopPropagation(); setTuningVisible(e.target.checked); } catch(err) { console.warn(err); } });

    // If the tuning panel hasn't been created yet, poll briefly and hide it by default
    (function pollForTuningPanel() {
      try {
        const panel = document.getElementById('pyramid-tuning-ui');
        if (panel) {
          // hide by default until user enables
          panel.style.display = 'none';
          return;
        }
        let tries = 0;
        const id = setInterval(() => {
          const p = document.getElementById('pyramid-tuning-ui');
          if (p) {
            p.style.display = 'none';
            clearInterval(id);
          }
          tries++;
          if (tries > 40) clearInterval(id);
        }, 50);
      } catch(e) { /* ignore */ }
    })();

    // Create a dedicated container for the tuning panel and append it after the checkbox row
    try {
      const tuningContainer = document.createElement('div');
      tuningContainer.id = 'pyramid-tuning-container';
      tuningContainer.style.width = '100%';
      tuningContainer.style.boxSizing = 'border-box';
      // append the container so the actual tuning panel can be inserted there by createPyramidTuningUI
      sceneSection.body.appendChild(tuningContainer);
      // Create the panel into our container (if the factory exists). Wrap in try/catch for safety.
      if (typeof window !== 'undefined' && typeof window.createPyramidTuningUI === 'function') {
        try { window.createPyramidTuningUI(tuningContainer); } catch(e) { try { window.createPyramidTuningUI(); } catch(_) {} }
      }
    } catch(e) { console.warn('Failed to create tuning container', e); }

    // expose the checkbox so it can be toggled programmatically
    try { window.__gui_elements = Object.assign(window.__gui_elements || {}, { pyramidTuningCheckbox: tuningCb }); } catch(e) {}
  } catch(e) { console.warn('Failed to create pyramid tuning toggle', e); }

  // expose some elements for later updates
  try { window.__gui_elements = { arRange, arNum, loadSelect, eventSelect, cbShowModel, cbShowWire, cbSkybox, cbGround }; } catch(e) {}
}

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
