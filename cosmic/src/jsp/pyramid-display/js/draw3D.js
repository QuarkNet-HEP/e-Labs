/*
	Edit Peronja 23/10/2025: 3D variables and functions
*/

// Import THREE as an ES module and example helpers. Expose to window for compatibility
import * as THREE from '../three/build/three.module.js';
import { OrbitControls, MapControls } from '../three/examples/jsm/controls/OrbitControls.js';
import { STLLoader } from '../three/examples/jsm/loaders/STLLoader.js';
import { FontLoader } from '../three/examples/jsm/loaders/FontLoader.js';
import { TextGeometry } from '../three/examples/jsm/geometries/TextGeometry.js';
import { EffectComposer } from '../three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from '../three/examples/jsm/postprocessing/RenderPass.js';
import { ShaderPass } from '../three/examples/jsm/postprocessing/ShaderPass.js';
import { UnrealBloomPass } from '../three/examples/jsm/postprocessing/UnrealBloomPass.js';
import { CopyShader } from '../three/examples/jsm/shaders/CopyShader.js';
import { LuminosityHighPassShader } from '../three/examples/jsm/shaders/LuminosityHighPassShader.js';

globalThis.THREE = THREE;
globalThis.sensor = null;
globalThis.muonVectors = [];
var scene;
var camera;
var axesHelper;
var renderer;
var canvasContainer;
var controls;
var sensorX;
var sensorY;
var sensorZ;
var sensorPhi;
var sensorTheta;
var sensorHeight;
var skyboxMesh;
var ground;
var updateSpotlightPosition;
var spotlight;
var ambientLight;
var target;
var acceptGroup = [];
var pyramid;
var cameraPosition = [];
var cameraRotation = [];
const axis_length = 750;
const max_lg = 1200;
let debug3D = false;
let debug3Dsensor = false;
let debug3Devent = false;
let debug3Dreverse = false;
let debug3Dline = false;
var composer; // EffectComposer for postprocessing
var tonePass; // ShaderPass for tone-mapping
var toneShader; // shader definition
var bloomPass; // UnrealBloomPass for bloom effect
// Tone-mapping and postprocess parameters will be exposed via shader pass

// classes to create the 3D display
class triShaft {
  constructor() {
    this.dir = 'x';
    this.index = 0;
    this.length = 16;
    this.size = 1;
    this.xpos = 0;
    this.ypos = 0;
    this.zpos = 0;
    this.orientation = 'up';
    this.opacity = 0.5;
    this.color = 0xFFFFFF;
    this.outline = 0xFFFFF;
    this.borderOpacity = 1;
    this.border = null;
    this.faces = new THREE.Mesh();
    this.prism = new THREE.Group();
  }
  
  init() {
    //calculate vertices
    const leg = this.size/2;
    let vertices;
    switch (this.dir+this.orientation) {
      case 'xup':
        vertices = new Float32Array ([
          this.xpos,this.ypos,this.zpos,
          this.xpos+this.size,this.ypos,this.zpos,
          this.xpos+leg,this.ypos+leg,this.zpos,
          this.xpos,this.ypos,this.zpos-this.length,
          this.xpos+this.size,this.ypos,this.zpos-this.length,
          this.xpos+leg,this.ypos+leg,this.zpos-this.length
        ]);
        break;
      case 'xdown':
        vertices = new Float32Array ([
          this.xpos,this.ypos+leg,this.zpos,
          this.xpos+this.size,this.ypos+leg,this.zpos,
          this.xpos+leg,this.ypos,this.zpos,
          this.xpos,this.ypos+leg,this.zpos-this.length,
          this.xpos+this.size,this.ypos+leg,this.zpos-this.length,
          this.xpos+leg,this.ypos,this.zpos-this.length
        ]);
        break;
      case 'yup':
        vertices = new Float32Array ([
          this.xpos,this.ypos,this.zpos,
          this.xpos,this.ypos,this.zpos-this.size,
          this.xpos,this.ypos+leg,this.zpos-leg,
          this.xpos+this.length,this.ypos,this.zpos,
          this.xpos+this.length,this.ypos,this.zpos-this.size,
          this.xpos+this.length,this.ypos+leg,this.zpos-leg
        ]);
        break;
      case 'ydown':
        vertices = new Float32Array ([
          this.xpos,this.ypos+leg,this.zpos,
          this.xpos,this.ypos+leg,this.zpos-this.size,
          this.xpos,this.ypos,this.zpos-leg,
          this.xpos+this.length,this.ypos+leg,this.zpos,
          this.xpos+this.length,this.ypos+leg,this.zpos-this.size,
          this.xpos+this.length,this.ypos,this.zpos-leg
        ]);      
    }
    const indices1 = [0, 1, 2, 3, 5, 4, 0, 3, 1, 1, 3, 4, 1, 4, 2, 2, 4, 5, 2, 5, 0, 0, 5, 3];
    //render prism using vertices
    const geometry = new THREE.BufferGeometry();
    geometry.setIndex( indices1 );
    geometry.setAttribute( 'position', new THREE.BufferAttribute( vertices, 3 ) );
    geometry.computeVertexNormals();
    const material = new THREE.MeshStandardMaterial( { 
      color: this.color, 
      side: THREE.DoubleSide  //disable backface culling to enable rotation
      //metalness:0,
      //roughness:1
    } );
    const mesh = new THREE.Mesh( geometry, material );
    mesh.material.transparent = true;
    mesh.material.opacity = this.opacity;
    mesh.castShadow = true;
    mesh.recieveShadow = true;
    mesh.emissive = new THREE.Color(this.color);
    mesh.emissiveIntesnity = 1;
    this.prism.add(mesh);
    this.faces = mesh
    
    //render outline using vertices
    const lineVertices = new Float32Array(vertices);
    const indices2 = new Uint32Array([
      // Base outline
      0, 1, 1, 2, 2, 0,
      // Side edges
      0, 3, 1, 4, 2, 5,
      // Top outline
      3, 4, 4, 5, 5, 3
    ]);
    const lineg = new THREE.BufferGeometry();
    lineg.setAttribute('position', new THREE.BufferAttribute(lineVertices,3));
    lineg.setIndex(new THREE.BufferAttribute(indices2, 1));
    const linem = new THREE.MeshStandardMaterial({ color: this.outline });
    linem.transparent = false;
    linem.opacity = this.borderOpacity;
    linem.emissiveIntensity = 0.1;
    linem.emissive.set(0xFFFFFF);
    linem.color.set(0xFFFFFF);    
    const line = new THREE.LineSegments(lineg, linem);
    this.prism.add(line)
    this.border = line
    }
} // end of thiShaft class

class sensor {
  constructor (data) {
    this.centerx=0;
    this.centery=0;
    this.centerz=0;
    this.zoomPos = new THREE.Vector3(0,0,0);
    // planeSpacing is the space between the layers, this code assumes that total height is 1m=6
    let height = data * 6.0;
    this.planeSpacing=height;
    this.moduleSpacing=0.1;
    if (debug3Dsensor === true) {
		console.log("layers: ", globalThis.layers);
	}
	//we start from the top
    if (globalThis.layers[4].length > 0) {
		this.gridx = globalThis.layers[4].length * 4; //from the geometry
	} else {
		this.gridx = 28;	
	}
	if (globalThis.layers[5].length > 0) {
		this.gridy = globalThis.layers[5].length * 4; //from the geometry
	} else {
		this.gridy = 48;
	}    
    this.xrot = 0;
    this.yrot = 0;
    this.zrot = 0;
    this.xcolor = 0x00ff00;
    this.ycolor = 0x00ff00;
    this.borderColor = 0xFFFFFF;
    this.borderOpacity = 0.01;
    this.xtransparency = 0.05;
    this.ytransparency = 0.05;
    this.xstart = 'down';
    this.ystart = 'down';
    this.data = data;
    this.job = [];
    this.group = new THREE.Group();
    //lists of triangle shaft objects according to layer and type
    this.shafts = {
        0:{
            'x':[],
            'y':[]
        },
        1:{
            'x':[],
            'y':[]
        },
        2:{
            'x':[],
            'y':[]
        }
    }
  }
  render () {
    for (let k = 2; k >=0; k--) {
      let xpattern;
      let ypattern;
      switch (this.xstart) {
        case "down": 
          xpattern = 0;
          break;
        default: xpattern = 1;
      }
      switch (this.ystart) {
        case "down": 
          ypattern = 0;
          break;
        default: ypattern = 1;
      }

      let spacing = 0;
      //triangles in the x direction
      let n;
      let offset;
      //note: need to take into account the reverse setting in the geometry   
      for (let i=this.gridx; i >= 0; i--) {
        n = new triShaft();
        if (i%2 != xpattern) { n.orientation = "up"; }
        if (i%2 == xpattern) { n.orientation = "down"; }
        n.length = this.gridy/2 + this.gridy/4 * this.moduleSpacing;
        if (i>0 && i%4==0) { spacing += this.moduleSpacing; }
        offset = -this.gridx/4 + spacing;
        n.xpos = offset + i*n.size/2;
        n.ypos = (1-k)*this.planeSpacing;
        n.zpos = this.gridy/4;
        n.color = this.xcolor;
        n.opacity = this.xtransparency;
        n.outline = this.borderColor;
        n.index = i;
        n.init();
        this.job.push(n);
        this.group.add(n.prism);
        this.shafts[k][n.dir].push(n);
      }
      spacing = 0;  
      for (let i=this.gridy; i >= 0; i--) {
        n = new triShaft();
        n.dir = "y";
        if (i%2 != ypattern) { n.orientation = "up"; }
        if (i%2 == ypattern) { n.orientation = "down"; }  
        n.length = this.gridx/2 + n.size/2 + this.gridx/4 * this.moduleSpacing - this.moduleSpacing;
        n.xpos = -this.gridx/4;
        n.ypos = (1-k)*this.planeSpacing + n.size/2;
        if (i>0 && i%4==0) {spacing += this.moduleSpacing;}
        offset =  - this.gridy/4 + spacing;
        n.zpos = offset + i*n.size/2 - n.size/2;
        n.color = this.ycolor;
        n.opacity = this.ytransparency;
        n.outline = this.borderColor;
        n.index = i;
        n.init();
        this.job.push(n);
        this.group.add(n.prism);
        this.shafts[k][n.dir].push(n);
      }
    } 
    
    this.group.position.x += this.centerx;
    this.group.position.y += this.centery;
    this.group.position.z += this.centerz;
    this.group.rotation.x = this.xrot;
    this.group.rotation.y = this.yrot;
    this.group.rotation.z = this.zrot;
    if (debug3D === true) {
	    // Position axisHelper at center of geometry
		var sensorAxes = new THREE.AxesHelper(100);
		this.group.add(sensorAxes);
	}
    this.group.name = "sensor";    
    scene.add(this.group);     
  }
} // end of sensor class

function acceptanceRange(range) {
	if (scene.getObjectByName("sensor") != undefined) {

	  //clear previous acceptance mesh
	  for (var i in acceptGroup) { globalThis.sensor.group.remove(acceptGroup[i]); }
	  const plane1 = globalThis.sensor.shafts[0]['y'];
	  const high1 = plane1[0];
	  const high2 = plane1[plane1.length-1];
	  const p1 = new THREE.Vector3(high1.xpos,high1.ypos+high1.size/2,high1.zpos-high2.size);
	  const p2 = new THREE.Vector3(high2.xpos,high2.ypos+high2.size/2,high2.zpos);
	  const p3 = new THREE.Vector3(high1.xpos+high1.length,high1.ypos+high1.size/2,high1.zpos-high2.size);
	  const p4 = new THREE.Vector3(high2.xpos+high2.length,high2.ypos+high2.size/2,high2.zpos);
	  const plane2 = globalThis.sensor.shafts[2]['x'];
	  const low1 = plane2[0];
	  const low2 = plane2[plane2.length-1];
	  const p5 = new THREE.Vector3(low1.xpos,low1.ypos,low1.zpos);
	  const p6 = new THREE.Vector3(low2.xpos+low2.size,low2.ypos,low2.zpos);
	  const p7 = new THREE.Vector3(low1.xpos,low1.ypos,low1.zpos-low1.length);
	  const p8 = new THREE.Vector3(low2.xpos+low2.size,low2.ypos,low2.zpos-low2.length);

	  function ray(point1,point2,cutoff) {  
	    const direction = new THREE.Vector3().subVectors(point2, point1).normalize();
	    const lineLength = range;
	    const extendVector = direction.clone().multiplyScalar(lineLength);
	    const startPoint = new THREE.Vector3().subVectors(point1, extendVector);
	    const endPoint = new THREE.Vector3().addVectors(point2, extendVector);
	    if (endPoint.y < cutoff) {
	      // Calculate a new endPoint at the cutoff level
	      const t = (cutoff - point2.y) / direction.y;
	      endPoint.set(point2.x + t * direction.x, cutoff, point2.z + t * direction.z);
	    }
	    return new THREE.Vector2(startPoint,endPoint);
	  }
	  const cutoff = high1.ypos+high1.size/2;
	  const v1 = ray(p1,p6,cutoff);
	  const v2 = ray(p2,p8,cutoff);
	  const v3 = ray(p3,p5,cutoff);
	  const v4 = ray(p4,p7,cutoff);
	  
	  function quad(points) {
	    const vertices = [];
	    points.forEach(point => {
	      vertices.push(point.x, point.y, point.z);
	    });
	    // Define the indices to form a quad from the vertices
	    const indices = [0, 1, 2, 2, 1, 3];
	    // Create a BufferGeometry
	    const geometry = new THREE.BufferGeometry();
	    geometry.setAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));
	    geometry.setIndex(indices);
	    // Create a material
	    const material = new THREE.MeshBasicMaterial({ color: 0xff0000, side: THREE.DoubleSide });
	    material.transparent = true;
	    material.opacity = 0.05;
	    // Create a mesh using the BufferGeometry and material
	    const mesh = new THREE.Mesh(geometry, material);
	    globalThis.sensor.group.add(mesh);
	    acceptGroup.push(mesh);
	  }
	  
	  function line(v) {
	    const point1 = v.x
	    const point2 = v.y
	    // Create a BufferGeometry
	    const geometry = new THREE.BufferGeometry();
	    const positions = new Float32Array([point1.x, point1.y, point1.z, point2.x, point2.y, point2.z]);
	    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
	    // Create a material for the line
	    const material = new THREE.LineBasicMaterial({ color: 0xff0000 });
	    // Create a line using the BufferGeometry and material
	    const line = new THREE.Line(geometry, material);
	    globalThis.sensor.group.add(line);
	    acceptGroup.push(line);
	  }
	  //cube points at the corners of the acceptance cone
	  /*
	  function cube(pos,color) {
	    const cubeGeometry = new THREE.BoxGeometry(0.3, 0.3, 0.3);
	    const cubeMaterial = new THREE.MeshBasicMaterial({ color: color });
	    const cubeMesh = new THREE.Mesh(cubeGeometry, cubeMaterial);
	    cubeMesh.position.copy(pos);
	    globalThis.sensor.group.add(cubeMesh);
	  }
	  
	  cube(p1,0xFF0000);//red
	  cube(p2,0xFFA500);//orange
	  cube(p3,0xFFFF00);//yellow
	  cube(p4,0x00FF00);//green
	  cube(p5,0x0000FF);//blue
	  cube(p6,0x4B0082);//indgo
	  cube(p7,0xEE82EE);//violet
	  cube(p8,0x000000);//black
	  
	  const w = 0xFFFFFF;
	  cube(v1.x,0xFF0000);//red
	  cube(v1.y,0xFF0000);
	  cube(v2.x,0xFFA500);//orange
	  cube(v2.y,0xFFA500);
	  cube(v3.x,0xFFFF00);//yellow
	  cube(v3.y,0xFFFF00);
	  cube(v4.x,0x00FF00);//green
	  cube(v4.y,0x00FF00);
	  */
	  
	  quad([v1.x,v1.y,v2.x,v2.y]);
	  quad([v2.x,v2.y,v4.x,v4.y]);
	  quad([v4.x,v4.y,v3.x,v3.y]);
	  quad([v3.x,v3.y,v1.x,v1.y]);
	  quad([v1.x,v2.x,v3.x,v4.x]);
	  line(v1);
	  line(v2);
	  line(v3);
	  line(v4);
	}
} // end of acceptanceRange

function clearMuons() { 
  	for (var i in globalThis.muonVectors) { 
		globalThis.sensor.group.remove(globalThis.muonVectors[i]); 
	}
	for (let obj of globalThis.sensor.job) {
    	obj.faces.material.color.set(globalThis.sensor.xcolor);
    	obj.faces.material.transparent = true;
    	obj.faces.material.opacity = 0.01;
  	}
}// end of clearMuons

function loadIndex(eventIndex) {
	clearMuons();
	loadEvent(eventIndex,globalThis.subtractPedX,globalThis.subtractPedY);
} // end of loadIndex

function loadEvent(eventIndex,x,y) {
  let eventX = x[eventIndex-1];
  let eventY = y[eventIndex-1];
  let reversed = false;

  let channelPosition = 0;
  let channelSensor = 0;
  if (debug3Devent === true) {
    console.log(x, eventX);
	console.log(y, eventY);
	console.log(globalThis.singleGeometry);
  }
  let x_prisms = {};
  let y_prisms = {};  
  let x_hit = {};
  let y_hit = {};
  for (let obj of globalThis.sensor.job) {
    obj.faces.material.color.set(globalThis.sensor.xcolor);
    obj.faces.material.transparent = true;
    obj.faces.material.opacity = 0.01;
  }
  if (eventX == undefined) { eventX = []; }
  if (eventY == undefined) { eventY = []; }
  let ndxX = 5;
  let ndxY = 6;
 
  let end = globalThis.layerOrderX[0][0];
  let middle = globalThis.layerOrderX[1][0];
  let start = globalThis.layerOrderX[2][0];

  //change the order
  let ndx = globalThis.layerOrderX[2][1];
  let layer = globalThis.layerOrderX[2][2];
  let layerNdx = 2;
  //layer X
  for (let x = eventX.length-1; x >= 0; x--){
    let x_new = {};
    let xp_new = {};
	//check if channels are reversed
    if (globalThis.singleGeometry[ndx][2] === "REVERSED") {
    	reversed = true;
	} else {
		reversed = false;
	}    
    if (debug3Devent === true) {
      console.log(layer,globalThis.layers,reversed, eventX[layer]);
    }
    //need to test for reverse
    if (reversed === true) {
	   channelPosition = ((globalThis.layers[4].length-2) * 4) - 1;
	   channelSensor = 0;
	   if (debug3Devent === true) {
	      console.log("x start: ", channelPosition);
	   }
	    for (let i=channelPosition; i >= 0; i--) {
	      let lg = eventX[layer][i];
	      let obj = globalThis.sensor.shafts[layer]["x"][channelSensor];
		  if (debug3Devent === true) {
		      console.log(eventX[layer].length, i, lg, obj);
		  }
	      if (obj != undefined) {
	        x_new[i] = lg;
	        xp_new[i] = obj;
	        if (lg > 0) {
	          obj.faces.material.color.set(new THREE.Color(`hsl(${((max_lg-lg)/max_lg)*60}, 100%, 50%)`));
	          obj.faces.material.transparent = false;
	          obj.faces.material.opacity =1;
	        }   
	      }
	      channelSensor += 1;
	    }
	} else {
	    for (let i=0; i<eventX[layer].length; i++) {
	      let lg = eventX[layer][i];
	      let obj = globalThis.sensor.shafts[layer]["x"][i];
		  if (debug3Devent === true) {
		      console.log(eventX[layer].length, i, lg, obj);
		  }
	      if (obj != undefined) {
	        x_new[i] = lg;
	        xp_new[i] = obj;
	        if (lg > 0) {
	          obj.faces.material.color.set(new THREE.Color(`hsl(${((max_lg-lg)/max_lg)*60}, 100%, 50%)`));
	          obj.faces.material.transparent = false;
	          obj.faces.material.opacity =1;
	        }   
	      }
	    }
	}
    x_hit[layer] = x_new;
    x_prisms[layer] = xp_new;
	layerNdx -= 1;
	if (layerNdx >= 0) {
		layer = globalThis.layerOrderX[layerNdx][2];
		ndx = globalThis.layerOrderX[layerNdx][1];
	}
  }

  ndx = globalThis.layerOrderY[2][1];
  layer = globalThis.layerOrderY[2][2];
  layerNdx = 2;
  //Y layer
  for (let x=eventY.length-1; x >= 0; x--){
    let y_new = {};
    let yp_new = {};
	//check if channels are reversed
    if (globalThis.singleGeometry[ndx][2] === "REVERSED") {
    	reversed = true;
	} else {
		reversed = false;
	}    
    if (debug3Devent === true) {
      console.log(layer, globalThis.layers, reversed, eventY[layer]);
    }
    //need to test for reverse
	if (reversed === true) {
		channelPosition = ((globalThis.layers[5].length - 2) * 4) - 1;	
		channelSensor = 0;	
	   if (debug3Devent === true) {
	      console.log("y start: ", channelPosition);
	   }
	    for (let i=channelPosition; i >= 0; i--) {
	      let lg = eventY[layer][i];
	      let obj = globalThis.sensor.shafts[layer]["y"][channelSensor];
		  if (debug3Devent === true) {
		      console.log(eventY[layer].length, i, lg, obj);
		  }
		  if (obj != undefined) {
		      y_new[i] = lg;
		      yp_new[i] = obj;
		      if (lg > 0) {
		        obj.faces.material.color.set(new THREE.Color(`hsl(${((max_lg-lg)/max_lg)*60}, 100%, 50%)`));
		        obj.faces.material.transparent = false;
		        obj.faces.material.opacity = 1;
		      }    
		  }
	      channelSensor += 1;
	    }	
	 } else {
	    for (let i=0; i<eventY[layer].length; i++) {
	      let lg = eventY[layer][i];
	      let obj = globalThis.sensor.shafts[layer]["y"][i];
		  if (debug3Devent === true) {
		      console.log(eventY[layer].length, i, lg, obj);
		  }
		  if (obj != undefined) {
		  	 y_new[i] = lg;
	      	 yp_new[i] = obj;
	      	 if (lg > 0) {
	        	obj.faces.material.color.set(new THREE.Color(`hsl(${((max_lg-lg)/max_lg)*60}, 100%, 50%)`));
	        	obj.faces.material.transparent = false;
	        	obj.faces.material.opacity = 1;
	      	 }
		  }    
	    }
	}
    y_hit[layer] = y_new;
    y_prisms[layer] = yp_new;
	layerNdx -= 1;
	if (layerNdx >= 0) {
		layer = globalThis.layerOrderY[layerNdx][2];
		ndx = globalThis.layerOrderY[layerNdx][1];
	}
  }
  let vectors = globalThis.calculate(scene,x_prisms, y_prisms, x_hit, y_hit);
  if (debug3Dline === true) {
      console.log("vectors:",vectors, "xprisms:", x_prisms, "yprisms", y_prisms, "xhit:",x_hit, "yhit:", y_hit);
  }  
  for (var i in vectors) {
    const v = vectors[i];
    const point1 = v.x
    const point2 = v.y
    const direction = new THREE.Vector3().subVectors(point2, point1).normalize();
    const lineLength = 100000;
    const extendVector = direction.clone().multiplyScalar(lineLength);
    const startPoint = new THREE.Vector3().subVectors(point1, extendVector);
    const endPoint = new THREE.Vector3().addVectors(point2, extendVector);
    const yCutoff = 0; // Adjust this value to set the y-level where the line should be cutoff
    if (endPoint.y < yCutoff) {
      // Calculate a new endPoint at the yCutoff level
      const t = (yCutoff - point2.y) / direction.y;
      endPoint.set(point2.x + t * direction.x, yCutoff, point2.z + t * direction.z);
    }
	if (debug3Dline === true) {
	      console.log("point1:", point1, "point2:", point2, "direction:", direction, "extended:", extendVector, "startpoint:",startPoint, "endpoint:",endPoint);
	}  
    const geometry = new THREE.BufferGeometry();
    var positions = new Float32Array([startPoint.x-globalThis.sensor.centerx, startPoint.y-globalThis.sensor.centery, startPoint.z-globalThis.sensor.centerz, endPoint.x-globalThis.sensor.centerx, endPoint.y-globalThis.sensor.centery, endPoint.z-globalThis.sensor.centerz]);
    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    const material = new THREE.LineBasicMaterial({ color: 0x00ff00 });
    const line = new THREE.Line(geometry, material);
    globalThis.muonVectors.push(line);
    globalThis.sensor.group.add(line);
  }  
} //end of loadEvent

function loadAngle(x,y,z) {
  globalThis.sensor.group.rotation.order = 'YXZ';	
  globalThis.sensor.group.rotation.x = x;
  globalThis.sensor.group.rotation.y = y;
  globalThis.sensor.group.rotation.z = z;
} // end of loadAngle

function smoothCameraZoom(camera, targetPosition, duration, controls, options = {}) {
  // Options: { rotationTurns: number, rotationDegrees: number, pitchDegrees: number, forwardOffset: number, zoomOutDistance: number, lateralDistance: number }
  const initialPosition = camera.position.clone();
  const startTime = Date.now();
  const rotationTurns = (typeof options.rotationTurns === 'number') ? options.rotationTurns : undefined; // legacy-quarter-turns
  const rotationDegrees = (typeof options.rotationDegrees === 'number') ? options.rotationDegrees : (typeof rotationTurns === 'number' ? rotationTurns * -180 : undefined);
  const pitchDegrees = (typeof options.pitchDegrees === 'number') ? options.pitchDegrees : 0; // positive = tilt toward front (reduce phi)
  const forwardOffset = (typeof options.forwardOffset === 'number') ? options.forwardOffset : 0; // move closer to target
  const zoomOutDistance = (typeof options.zoomOutDistance === 'number') ? options.zoomOutDistance : 20;

  // compute sensor center (do not mutate targetPosition)
  const sensorCenter = new THREE.Vector3(globalThis.sensor.centerx, globalThis.sensor.centery, globalThis.sensor.centerz);
  // treat targetPosition as a world-space coordinate (caller passes absolute coordinates)
  const targetWorld = targetPosition.clone();

  // compute a baseline zoomed position (closer to target)
  const direction = targetWorld.clone().sub(initialPosition).normalize();
  const zoomedPosition = targetWorld.clone().addScaledVector(direction, -zoomOutDistance);

  // compute a right vector (perpendicular to direction and world up)
  const worldUp = new THREE.Vector3(0, 1, 0);
  const right = direction.clone().cross(worldUp).normalize();
  if (right.lengthSq() < 1e-6) right.set(1, 0, 0);

  // lateral distance: either from options or derived from sensor size
  let lateralDistance = (typeof options.lateralDistance === 'number') ? options.lateralDistance : 50;
  try {
    if ((!options.lateralDistance) && globalThis.sensor && globalThis.sensor.gridx && globalThis.sensor.gridy) {
      lateralDistance = Math.max(globalThis.sensor.gridx, globalThis.sensor.gridy) * 0.5;
      lateralDistance = Math.max(20, Math.min(200, lateralDistance));
    }
  } catch (e) { /* ignore */ }

  const targetWithRight = zoomedPosition.clone().addScaledVector(right, lateralDistance);

  // We'll perform a spherical (orbit) interpolation around the sensor center so the camera rotates around it
  const startRel = initialPosition.clone().sub(sensorCenter);
  const startS = new THREE.Spherical().setFromVector3(startRel);
  // Compute the final spherical coordinates from targetWithRight relative to sensor center
  const finalRel = targetWithRight.clone().sub(sensorCenter);

  // Determine final theta in radians. Positive rotationDegrees rotates to the right (subtract theta)
  let finalTheta;
  if (typeof rotationDegrees === 'number') {
    const rad = THREE.MathUtils.degToRad(rotationDegrees);
    finalTheta = startS.theta - rad;
  } else {
    // fallback: keep same theta but move radius/phi toward target
    finalTheta = startS.theta;
  }

  // Compute final radius, allow forwardOffset to move camera closer (subtract)
  const rawFinalRadius = finalRel.length() || startS.radius * 0.5;
  const finalRadius = Math.max(5, rawFinalRadius - forwardOffset);

  // Compute final phi (polar). Use targetRel phi + pitchDegrees adjustment (positive pitchDegrees tilts camera forward)
  const targetPhi = (finalRel.length() > 0) ? new THREE.Spherical().setFromVector3(finalRel).phi : startS.phi;
  // pitchDegrees positive should reduce phi (tilt toward horizontal/front) — convert and subtract
  const pitchRad = THREE.MathUtils.degToRad(pitchDegrees || 0);
  let finalPhi = targetPhi - pitchRad;
  // clamp phi into valid (EPS, PI - EPS)
  const EPS = 0.0001;
  finalPhi = Math.max(EPS, Math.min(Math.PI - EPS, finalPhi));

  // easing
  function easeInOutQuad(t) { return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t; }

  function lerpAngle(a, b, t) {
    // linear interpolation for angles; suitable for smooth motion
    return a + (b - a) * t;
  }

  function updateCameraPosition() {
    const currentTime = Date.now();
    const elapsed = currentTime - startTime;
    const rawT = Math.min(1, elapsed / duration);
    const t = easeInOutQuad(rawT);

    const curRadius = THREE.MathUtils.lerp(startS.radius, finalRadius, t);
    const curTheta = lerpAngle(startS.theta, finalTheta, t);
    const curPhi = THREE.MathUtils.lerp(startS.phi, finalPhi, t);

    const s = new THREE.Spherical(curRadius, curPhi, curTheta);
    const newPos = new THREE.Vector3().setFromSpherical(s).add(sensorCenter);

    camera.position.copy(newPos);
    camera.lookAt(sensorCenter);

    if (rawT < 1) {
      requestAnimationFrame(updateCameraPosition);
    }
  }

  // Start the animation
  updateCameraPosition();
  tintPyramid();
  // update controls target to sensor center
  if (controls) {
    controls.target.copy(sensorCenter);
    controls.update();
  }
} //end of smoothCameraZoom

updateSpotlightPosition = function (spotlight, target, distance) {
    // Set the spotlight position to match the camera position
    if (!camera) return; // defensive
    spotlight.position.copy(camera.position);
    const cameraDirection = new THREE.Vector3();
    camera.getWorldDirection(cameraDirection);
    // Calculate the target position in front of the camera based on the distance
    const targetPosition = new THREE.Vector3();
    targetPosition.copy(cameraDirection).multiplyScalar(distance).add(camera.position);
    // Set the spotlight's target position to the calculated targetPosition
    if (spotlight.target) spotlight.target.position.copy(targetPosition);
    if (spotlight.shadow && spotlight.shadow.camera) spotlight.shadow.camera.updateProjectionMatrix();
};

//end of updateSpotlightPosition

function animate() {
    controls.update();
    updateSpotlightPosition(spotlight,target,10);
    // Update renderer dimensions when the window is resized
    const width = window.innerWidth;
    const height = window.innerHeight;
    if (renderer.domElement.width !== width || renderer.domElement.height !== height) {
      renderer.setSize(width, height);
      composer.setSize(width, height);
      camera.aspect = width / height;
      camera.updateProjectionMatrix();
    }
    // Render the scene
    if (composer) composer.render(); else renderer.render(scene, camera);
    spotlight.intensity = 1
    ambientLight.intensity = 1;
    requestAnimationFrame(animate);
}// end of animate

function loadSkybox() {
  	let textureLoader = new THREE.TextureLoader();
  	let texture = textureLoader.load('images/sky_water_landscape.jpg');
  	let radius = 10000; // Adjust the radius as needed
  	let widthSegments = 80//256; // Adjust the number of segments as needed
  	let heightSegments = 80//256; // Adjust the number of segments as needed
  	let sphereGeometry = new THREE.SphereGeometry(radius, widthSegments, heightSegments);
  	// Create a base material for the skybox with the texture
  	let material = new THREE.MeshBasicMaterial({ map: texture, side: THREE.BackSide });
  	// Create the skybox mesh using the sphere geometry and the custom material//MeshStandardMaterial
  	skyboxMesh = new THREE.Mesh(sphereGeometry, material);
  	skyboxMesh.receiveShadow = false;
  	skyboxMesh.name = "skybox";
	skyboxMesh.rotation.y = -Math.PI / 2;
  	scene.add(skyboxMesh);	
}// end of loadSkybox

function loadGround() {
	let textureLoader = new THREE.TextureLoader();
  	var groundGeo = new THREE.CircleGeometry(10000, 10000);
  	let texture = textureLoader.load('images/ground3.jpg');
    let groundMat = new THREE.MeshStandardMaterial({ map: texture });
  	groundMat.opacity = 1;
  	ground = new THREE.Mesh( groundGeo, groundMat );
  	ground.rotation.x = -Math.PI/2;
  	ground.position.y = 0;
  	ground.receiveShadow = true;
  	ground.name = "ground";
  	scene.add(ground);	
}// end of loadGround

function setPyramidWireframe(wireframe) {
	if (scene.getObjectByName("pyramid") != undefined) {
		pyramid.material.wireframe = wireframe;
	}
}// end of setPyramidWireframe

function loadPyramid(visibility, wire) {
	if (scene.getObjectByName("pyramid") === undefined) {
	  const pyramidUrl = "images/"+document.getElementById('pyramid-file').value.trim();
	  const loader = new STLLoader();
	  const textureLoader = new THREE.TextureLoader();
	  // start loading the pyramid albedo texture and keep a reference to the Texture object
	  const pyramidTexture = textureLoader.load('images/pyramid.jpeg', (loadedTexture) => {
         try {
           if (THREE && THREE.sRGBEncoding) loadedTexture.encoding = THREE.sRGBEncoding;
           loadedTexture.wrapS = loadedTexture.wrapT = THREE.RepeatWrapping;
           loadedTexture.anisotropy = renderer ? renderer.capabilities.getMaxAnisotropy() : 1;
           loadedTexture.needsUpdate = true;
           //console.log('[draw3D] pyramid texture loaded');
           // if the pyramid already exists and uses a shader uniform uMap, update it
           if (pyramid && pyramid.material) {
             if (pyramid.material.uniforms && pyramid.material.uniforms.uMap) {
               pyramid.material.uniforms.uMap.value = loadedTexture;
               // ensure the shader material picks up the new texture immediately
               try { pyramid.material.needsUpdate = true; } catch(e) {}
             }
             // if the fallback material was created earlier, update its map
             if (pyramid.material.map && pyramid.material.map === pyramidTexture) {
               pyramid.material.map = loadedTexture; pyramid.material.needsUpdate = true;
             }
           }
         } catch (e) { console.warn('[draw3D] pyramid texture postprocess failed', e); }
       }, undefined, (err) => { console.warn('[draw3D] pyramid texture failed to load', err); });
	  const vertexShader = `
	    varying vec3 vPosition;
		attribute float isVertex; // 1.0 if vertex, 0.0 otherwise
		varying float vIsVertex;
	    void main() {
	      vPosition = position; // Pass local position to fragment shader
	      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
	    }
	  `;

	  const fragmentShader = `
	    varying vec3 vPosition;
		varying float vIsVertex;
	    uniform float vertexRadius;
	    uniform vec3 vertexColor;
	    uniform vec3 wireframeColor;

	    void main() {
	      // Basic idea: Highlight based on distance to a 'point' 
	      // Note: For complex STL, you may need to use barycentric coordinates (edge-finding)
	      // Here we use a simpler approach for vertex highlighting:
	      
	      // Check if the current fragment is close to a vertex
	      // (This requires passing vertex data, simplified for example)
	      
	      // Example: Highlight based on distance to center (for demonstration)
	      // Real vertex highlighting requires proper UVs or vertex color attributes
	      
	      gl_FragColor = vec4(wireframeColor, 1.0);
	      
	      // Simple placeholder logic: 
	      // If you have vertex colors/positions, you would calculate:
	      // float dist = distance(vPosition, someVertexPos);
	      // if (dist < vertexRadius) gl_FragColor = vec4(vertexColor, 1.0);
		  //if (vIsVertex > 0.5) {
		  //  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0); // Red vertex
		  //} else {
		  //  gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0); // White line
		  //}
	    }
	  `;	  
	  
	  loader.load(pyramidUrl, function (pyramidGeo) {
	      // 2. Create Shader Material
		  let center = new THREE.Vector3();
		  pyramidGeo.computeBoundingBox();
		  pyramidGeo.name = "pyramidSTL";  		
		  center.x = (pyramidGeo.boundingBox.min.x + pyramidGeo.boundingBox.max.x) / 2;
		  center.y = (pyramidGeo.boundingBox.min.y + pyramidGeo.boundingBox.max.y) / 2;
		  center.z = (pyramidGeo.boundingBox.min.z + pyramidGeo.boundingBox.max.z) / 2;
		  // Translate the model to center it with our rendering coordinates
		  pyramidGeo.translate(-center.x, -center.y, -center.z);    
		  const verticesAttribute = pyramidGeo.getAttribute('position');
		  const vertices = verticesAttribute.array;
		  // Find the maximum Y (top) and minimum Y (bottom) coordinates
		  let maxY = Number.NEGATIVE_INFINITY;
		  let minY = Number.POSITIVE_INFINITY;
		  for (let i = 0; i < verticesAttribute.count; i += 3) {
		    const vertex = new THREE.Vector3(vertices[i], vertices[i + 1], vertices[i + 2]);
		    if (vertex.y > maxY) {
		      maxY = vertex.y;
		    }
		    if (vertex.y < minY) {
		      minY = vertex.y;
		    }
		  }
		  const height = (maxY - minY)/2;
		  const target = 22*30; //12 is 1 meter. The pyramid is 24m
		  const ratio = (target/height)*2;	
	      // build a triplanar PBR-like shader that uses the pyramidTexture
	      try { if (pyramidTexture && THREE && THREE.sRGBEncoding) pyramidTexture.encoding = THREE.sRGBEncoding; } catch(e) {}
	      if (pyramidTexture) { pyramidTexture.wrapS = pyramidTexture.wrapT = THREE.RepeatWrapping; pyramidTexture.anisotropy = renderer ? renderer.capabilities.getMaxAnisotropy() : 1; }

	      const triVert = `
	        varying vec3 vWorldPos;
	        varying vec3 vNormal;
	        void main() {
	          vNormal = normalize(normalMatrix * normal);
	          vWorldPos = (modelMatrix * vec4(position, 1.0)).xyz;
	          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
	        }
	      `;

	      const triFrag = `
         precision mediump float;
         uniform sampler2D uMap;
         uniform float uScale;
         uniform float uBumpScale;
        uniform float uExposure;
         uniform vec3 uSunDir;
         uniform vec3 uSunColor;
         uniform float uSunIntensity;
         uniform float uAmbient;
         uniform vec3 uSpecColor;
         uniform float uShininess;
         uniform float uSpecStrength;
         varying vec3 vWorldPos;
         varying vec3 vNormal;

         // Keep gamma helpers available — exposure used to control final brightness
         vec3 SRGBToLinear(vec3 c) { return pow(c, vec3(2.2)); }
         vec3 LinearToSRGB(vec3 c) { return pow(c, vec3(1.0/2.2)); }
         float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

         vec3 sampleTriplanarColor(sampler2D map, vec3 p, vec3 n) {
           vec2 ux = vec2(p.z, p.y) * uScale;
           vec2 uy = vec2(p.x, p.z) * uScale;
           vec2 uz = vec2(p.x, p.y) * uScale;
           vec3 sx = SRGBToLinear(texture2D(map, fract(ux)).rgb);
           vec3 sy = SRGBToLinear(texture2D(map, fract(uy)).rgb);
           vec3 sz = SRGBToLinear(texture2D(map, fract(uz)).rgb);
           vec3 w = abs(n);
           w = w / (w.x + w.y + w.z + 1e-5);
           return sx * w.x + sy * w.y + sz * w.z;
         }

         float sampleTriplanarHeight(sampler2D map, vec3 p, vec3 n) {
           vec2 ux = vec2(p.z, p.y) * uScale;
           vec2 uy = vec2(p.x, p.z) * uScale;
           vec2 uz = vec2(p.x, p.y) * uScale;
           float sx = luma(SRGBToLinear(texture2D(map, fract(ux)).rgb));
           float sy = luma(SRGBToLinear(texture2D(map, fract(uy)).rgb));
           float sz = luma(SRGBToLinear(texture2D(map, fract(uz)).rgb));
           vec3 w = abs(n);
           w = w / (w.x + w.y + w.z + 1e-5);
           return sx * w.x + sy * w.y + sz * w.z;
         }

         void main() {
           vec3 N0 = normalize(vNormal);
           vec3 P = vWorldPos;
           vec3 albedoLinear = sampleTriplanarColor(uMap, P, N0);

           float eps = 0.02 / max(uScale, 1.0);
           vec3 up = abs(N0.y) < 0.99 ? vec3(0.0,1.0,0.0) : vec3(1.0,0.0,0.0);
           vec3 T = normalize(cross(up, N0));
           vec3 B = normalize(cross(N0, T));
           float hC = sampleTriplanarHeight(uMap, P, N0);
           float hX = sampleTriplanarHeight(uMap, P + T * eps, N0);
           float hY = sampleTriplanarHeight(uMap, P + B * eps, N0);
           float dhdx = (hX - hC) / eps;
           float dhdy = (hY - hC) / eps;
           vec3 N = normalize(N0 - (T * dhdx + B * dhdy) * uBumpScale);

           vec3 L = normalize(uSunDir);
           float diff = max(dot(N, L), 0.0);
           vec3 diffuse = albedoLinear * (uSunColor * uSunIntensity * diff + uAmbient);

           vec3 V = normalize(vec3(0.0,0.0,1.0));
           vec3 H = normalize(L + V);
           float spec = pow(max(dot(N, H), 0.0), max(1.0, uShininess));
           vec3 specular = uSpecColor * spec * uSpecStrength * uSunIntensity;

           vec3 colorLinear = diffuse + specular;
           // apply simple exposure control so we can brighten the result without changing color space logic
           colorLinear *= uExposure;
           vec3 color = LinearToSRGB(colorLinear);
           gl_FragColor = vec4(color, 1.0);
         }
       `;
	  
	  const triUniforms = {
        uMap: { value: pyramidTexture },
        uScale: { value: 1.0 },
        uBumpScale: { value: 0.04 },
        uExposure: { value: 3.5 },    // boost final output brightness
        uSunDir: { value: new THREE.Vector3(-0.8, 1.2, 0.8).normalize() },
        uSunColor: { value: new THREE.Color(0xFFFFFF) },
        uSunIntensity: { value: 2.0 }, // stronger directional light
        uAmbient: { value: 0.35 },     // stronger base ambient
        uSpecColor: { value: new THREE.Color(0x333333) },
        uShininess: { value: 12.0 },
        uSpecStrength: { value: 0.35 }
      };

	      // Always create the triplanar shader material. The uMap uniform points to pyramidTexture
	      // and will start sampling once the texture image is loaded. This avoids falling back to
	      // a non-triplanar material and ensures the texture is used when available.
	      const triMaterial = new THREE.ShaderMaterial({
	        uniforms: triUniforms,
	        vertexShader: triVert,
	        fragmentShader: triFrag,
	        side: THREE.FrontSide,
	        transparent: false,
	        wireframe: !!wire
	      });
 
	      pyramid = new THREE.Mesh(pyramidGeo, triMaterial);
	      
		  if (debug3D === true) {
		    console.log('[draw3D] pyramid created with triplanar material', pyramid);
		  }

		  // runtime controls (non-breaking): allow tuning from console/UI without changing signatures
		  (function() {
         // capture the original material on the mesh so we can swap back safely
         const originalMaterial = pyramid && pyramid.material ? pyramid.material : null;
         // detect if the original material is a shader material (triplanar)
         const shader = originalMaterial && originalMaterial.isShaderMaterial ? originalMaterial : null;
         // create a fallback PBR material using the loaded texture (if available)


        // We'll create the fallback lazily inside usePyramidFallback so it works if texture loads later.
        let fallback = null;

    	    function setPyramidTriplanarScale(s) {
    	      const mat = pyramid && pyramid.material ? pyramid.material : null;
    	      if (mat && mat.uniforms && mat.uniforms.uScale) { mat.uniforms.uScale.value = s; return true; }
    	      return false;
    	    }
    	    function setPyramidBumpScale(s) {
    	      const mat = pyramid && pyramid.material ? pyramid.material : null;
    	      if (mat && mat.uniforms && mat.uniforms.uBumpScale) { mat.uniforms.uBumpScale.value = s; return true; }
    	      return false;
    	    }
    	    function setPyramidSpecStrength(s) {
    	      const mat = pyramid && pyramid.material ? pyramid.material : null;
    	      if (mat && mat.uniforms && mat.uniforms.uSpecStrength) { mat.uniforms.uSpecStrength.value = s; return true; }
    	      return false;
    	    }
    	    function usePyramidFallback(use) {
    	      if (!pyramid) return false;
    	      if (use) {
                if (!fallback) {
                 // create fallback now if the texture is available
                  try {
                    if (pyramidTexture && pyramidTexture.image) {
                      fallback = new THREE.MeshStandardMaterial({ map: pyramidTexture, roughness: 0.8, metalness: 0.02 });
                      fallback.map && (fallback.map.wrapS = fallback.map.wrapT = THREE.RepeatWrapping);
                    }
                  } catch (e) { console.warn('[draw3D] failed to create fallback', e); }
                }
                if (!fallback) return false;
                pyramid.material = fallback;
                pyramid.material.needsUpdate = true;
               return true;
              } else {
                if (!originalMaterial) return false;
                pyramid.material = originalMaterial;
                pyramid.material.needsUpdate = true;
                return true;
              }
             }
    	    function setPyramidFallbackScale(s) {
    	      try { if (fallback && fallback.map) { fallback.map.repeat.set(s,s); fallback.map.needsUpdate = true; return true; } } catch(e) {}
    	      return false;
    	    }
    	    // expose to window for quick debugging and UI wiring, non-destructive
    	    if (typeof window !== 'undefined') {
    	      window.setPyramidTriplanarScale = setPyramidTriplanarScale;
    	      window.setPyramidBumpScale = setPyramidBumpScale;
    	      window.setPyramidSpecStrength = setPyramidSpecStrength;
    	      window.usePyramidFallback = usePyramidFallback;
    	      window.setPyramidFallbackScale = setPyramidFallbackScale;
              // helper to force-apply the loaded texture to the shader uniform (useful for debugging)
             window.applyPyramidTexture = function() {
                try {
                  if (pyramid && pyramid.material && pyramid.material.uniforms && pyramidTexture) {
                    pyramid.material.uniforms.uMap.value = pyramidTexture;
                    pyramid.material.needsUpdate = true;
                    return true;
                  }
                } catch(e) { console.warn('applyPyramidTexture failed', e); }
                return false;
              };
              window.setPyramidExposure = function(v) {
                try {
                  if (pyramid && pyramid.material && pyramid.material.uniforms && typeof v === 'number') {
                    pyramid.material.uniforms.uExposure.value = v;
                    pyramid.material.needsUpdate = true;
                    return true;
                  }
               } catch(e) { console.warn('setPyramidExposure failed', e); }
                return false;
              };
              // allow tuning sun intensity and ambient separately
              window.setPyramidSunIntensity = function(v) {
                try {
                  if (pyramid && pyramid.material && pyramid.material.uniforms && typeof v === 'number') {
                    pyramid.material.uniforms.uSunIntensity.value = v;
                    pyramid.material.needsUpdate = true;
                    return true;
                  }
                } catch(e) { console.warn('setPyramidSunIntensity failed', e); }
                return false;
              };
              window.setPyramidAmbient = function(v) {
                try {
                  if (pyramid && pyramid.material && pyramid.material.uniforms && typeof v === 'number') {
                    pyramid.material.uniforms.uAmbient.value = v;
                    pyramid.material.needsUpdate = true;
                    return true;
                  }
                } catch(e) { console.warn('setPyramidAmbient failed', e); }
                return false;
              };
             };
           })();
		  // ...existing code continues (rotate/scale/position/scene.add) ...

		  let rotationAngle = THREE.MathUtils.degToRad(270); // Convert degrees to radians
		  let axis = new THREE.Vector3(1, 0, 0); // X-axis
		  pyramid.rotateOnWorldAxis(axis, rotationAngle);
		  rotationAngle = THREE.MathUtils.degToRad(180); // Convert degrees to radians
		  axis = new THREE.Vector3(0, 1, 0); // Y-axis
		  pyramid.rotateOnWorldAxis(axis, rotationAngle);
		  pyramid.scale.x *= ratio;
		  pyramid.scale.y *= ratio;
		  pyramid.scale.z *= ratio;
		  pyramid.position.set(8, 555, -745); //255
		  pyramid.castShadow = true;
		  pyramid.name = 'pyramid';
		  if (debug3D === true) {    	
		  	let pyramidHelper = new THREE.AxesHelper(50);
		  	pyramid.add(pyramidHelper);
		  }
		  pyramid.visible = true;
		  scene.add(pyramid);
		  //console.log("Pyramid added to scene:", pyramid);
	    });
	} else {
		pyramid.visible = visibility;
	}
}// end of loadPyramid

// Add functions to tint the pyramid to a solid color and restore original appearance
function tintPyramid(colorHex = 0xC2985E) {
  try {
    if (!pyramid) { console.warn('tintPyramid: no pyramid present'); return false; }
    // If we've already saved the appearance, don't overwrite it
    if (pyramid.__appearanceSaved) { console.warn('tintPyramid: pyramid already tinted'); return false; }

    const saved = {
      originalMaterial: pyramid.material,
      castShadow: !!pyramid.castShadow,
      receiveShadow: !!pyramid.receiveShadow
    };

    // Create a simple PBR material in the requested color. Keep it simple so it works across shader/fallback cases.
    let tintMat;
    try {
      tintMat = new THREE.MeshStandardMaterial({
        color: colorHex,
        roughness: 0.85,
        metalness: 0.05,
        transparent: false,
		wireframe: !!pyramid.material.wireframe
      });
    } catch (e) {
      console.warn('tintPyramid: failed to create tinted material', e);
      try { tintMat = new THREE.MeshStandardMaterial({ color: colorHex }); } catch(e2) { console.warn('tintPyramid fallback material creation failed', e2); return false; }
    }

    saved.tintedMaterial = tintMat;

    // Swap material and reduce shadow influence so the color stays readable
    try {
      pyramid.material = tintMat;
      try { pyramid.material.needsUpdate = true; } catch (e) {}
      pyramid.castShadow = false;
      pyramid.receiveShadow = false;
      pyramid.__appearanceSaved = saved;
      return true;
    } catch (e) {
      console.warn('tintPyramid: failed to apply tinted material', e);
      // cleanup
      try { if (tintMat && typeof tintMat.dispose === 'function') tintMat.dispose(); } catch(e2) {}
      return false;
    }
  } catch (e) { console.warn('tintPyramid failed', e); return false; }
}

function restorePyramidAppearance() {
  try {
    if (!pyramid) { console.warn('restorePyramidAppearance: no pyramid present'); return false; }
    const saved = pyramid.__appearanceSaved;
    if (!saved) { console.warn('restorePyramidAppearance: no saved appearance to restore'); return false; }

    try {
      // Restore original material
      if (saved.originalMaterial) {
        pyramid.material = saved.originalMaterial;
        try { pyramid.material.needsUpdate = true; } catch (e) {}
      }
      // Restore shadow flags
      try { pyramid.castShadow = !!saved.castShadow; } catch(e) {}
      try { pyramid.receiveShadow = !!saved.receiveShadow; } catch(e) {}
      // Dispose the temporary tinted material if it was created and is not the same as the original
      try {
        if (saved.tintedMaterial && saved.tintedMaterial !== saved.originalMaterial && typeof saved.tintedMaterial.dispose === 'function') {
          saved.tintedMaterial.dispose();
        }
      } catch (e) { /* ignore */ }
    } catch (e) {
      console.warn('restorePyramidAppearance swap failed', e);
      return false;
    }

    pyramid.__appearanceSaved = null;
    return true;
  } catch (e) { console.warn('restorePyramidAppearance failed', e); return false; }
}

// Convenience helper: tint to specified gold color
function tintPyramidToGold() { return tintPyramid(0xC2985E); }

// expose new helpers to window
if (typeof window !== 'undefined') {
  window.tintPyramid = tintPyramid;
  window.restorePyramidAppearance = restorePyramidAppearance;
  window.tintPyramidToGold = tintPyramidToGold;
}

function removeObject3D(object3D) {
    if (!(object3D instanceof THREE.Object3D)) return false;
    // for better memory management and performance
    if (object3D.geometry) object3D.geometry.dispose();
    if (debug3D === true) {
		console.log("removing sensor");
	}
    if (object3D.material) {
        if (object3D.material instanceof Array) {
            // for better memory management and performance
            object3D.material.forEach(material => material.dispose());
        } else {
            // for better memory management and performance
            object3D.material.dispose();
        }
    }
    object3D.removeFromParent(); // the parent might be the scene or another Object3D, but it is sure to be removed this way
    return true;
}// end of removeObject3D

function resetPyramidPosition() {
	//if (scene.getObjectByName("pyramid") != undefined) {	
    //	pyramid.position.set(-1, 285, -365);
	//}
}//end of resetPyramidPosition

function resetCameraPosition() {
	// Reset camera to a known, deterministic starting state so repeated calls are identical
	try {
	  restorePyramidAppearance();
	  // Match the initial placement used in initScene for a consistent starting point
	  camera.position.set(-850, 750, 1400);
	  // Ensure camera up is the default world up
	  camera.up.set(0, 1, 0);
	  // Make OrbitControls target the sensor center and update internal state
	  if (controls) {
	    //controls.target.set(globalThis.sensor.centerx, globalThis.sensor.centery, globalThis.sensor.centerz);
	    controls.update();
	  }
	  // Ensure the camera is looking at the sensor center immediately
	  //camera.lookAt(globalThis.sensor.centerx, globalThis.sensor.centery, globalThis.sensor.centerz);
	} catch (e) {
	  // defensive: if camera/controls not ready, ignore and proceed
	  console.warn('draw3DSettings: failed to reset camera state', e);
	}
}// end of resetCameraPosition

function draw3DSettings() {
    if (debug3D === true) {        
        console.log("3D drawings");
    }
    if (scene.getObjectByName("sensor") != undefined) {
        removeObject3D(scene.getObjectByName("sensor"));
    }
    if (debug3Dreverse === true) {
        console.log("layers:",globalThis.layers);
    }
    //resetPyramidPosition();
    //detector information from data file
    sensorX = parseFloat(globalThis.detector[5]);
    sensorY = parseFloat(globalThis.detector[6]);
    sensorZ = parseFloat(globalThis.detector[7]);
    //console.log("sensor position:", sensorX, sensorY, sensorZ);
    sensorTheta = Math.floor(globalThis.detector[8]);
    sensorPhi = Math.floor(globalThis.detector[9]);
    sensorHeight = parseFloat(globalThis.detector[10]);    
    globalThis.sensor = new sensor(sensorHeight);
    globalThis.sensor.centery = sensorY;
    globalThis.sensor.centerx = sensorX;
    globalThis.sensor.centerz = sensorZ;
    globalThis.sensor.render();

    //resetPyramidPosition();
    acceptanceRange(parameters.acceptRange);
    clearMuons();  
    globalThis.muonVectors = [];
    loadEvent(1,globalThis.subtractPedX,globalThis.subtractPedY);
    loadAngle(THREE.MathUtils.degToRad(-sensorTheta),THREE.MathUtils.degToRad(sensorPhi),0);
    const targetPositionx = globalThis.sensor.centerx-10;
    const targetPositiony = globalThis.sensor.centery+15;
    const targetPositionz = globalThis.sensor.centerz+10;
    const targetPosition = new THREE.Vector3(targetPositionx,targetPositiony,targetPositionz); // Specify the target position
    //const targetPosition = new THREE.Vector3(globalThis.sensor.centerx-10,globalThis.sensor.centery+15,-globalThis.sensor.centerz+10); // Specify the target position
    //const targetPosition = new THREE.Vector3(-200,500,-500);
    const duration = 2000; // Specify the duration in milliseconds
    // Rotate further to the right: 450° == 360° + 90° => ends up 90° to the right of the start
    smoothCameraZoom(camera, targetPosition, duration, controls, { rotationDegrees: 450, pitchDegrees: 10, forwardOffset: 5 });
    animate();
} // end of draw3DSettings

function initScene() {
 	scene = new THREE.Scene();
 	camera = new THREE.PerspectiveCamera(90, window.innerWidth / window.innerHeight, 0.1, 10000000);
 	//camera.position.set(-200,500,500);
 	camera.position.set(-850,750,1400);
     if (debug3D === true) {	  
 		// Add axes to help with positioning and rotation - this is all to help, visibility off to start with
 		axesHelper = new THREE.AxesHelper(axis_length);
 		axesHelper.linewidth = 100;
 		scene.add(axesHelper);
 	}
 	// Create a renderer
 	renderer = new THREE.WebGLRenderer({ antialias: true });
 	renderer.setSize(window.innerWidth, window.innerHeight);
     // ensure correct output encoding so sRGB textures and shader conversions match display
     try { if (THREE && THREE.sRGBEncoding) renderer.outputEncoding = THREE.sRGBEncoding; } catch(e) {}
     	canvasContainer = document.getElementById('canvas-container');
     	canvasContainer.appendChild(renderer.domElement);
     	controls = new OrbitControls(camera, renderer.domElement);
    // --- setup postprocessing (tone-mapping shader + composer) ---
    // Tone-mapping shader supports Reinhard (mode=0) and ACES approximation (mode=1).
    toneShader = {
      uniforms: {
        tDiffuse: { value: null },
        exposure: { value: 1.0 },
        contrast: { value: 1.0 },
        saturation: { value: 1.0 },
        mode: { value: 1 } // 0=reinhard, 1=ACES
      },
      vertexShader: `
        varying vec2 vUv;
        void main() {
          vUv = uv;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        precision highp float;
        uniform sampler2D tDiffuse;
        uniform float exposure;
        uniform float contrast;
        uniform float saturation;
        uniform int mode;
        varying vec2 vUv;
   vec3 SRGBToLinear(vec3 c) { return pow(c, vec3(2.2)); }
   vec3 LinearToSRGB(vec3 c) { return pow(c, vec3(1.0/2.2)); }
   // ACES approximation (Uncharted2/Filmic-ish)
   vec3 toneMapACES(vec3 x) {
     // a simple filmic curve approximation
     x = max(vec3(0.0), x);
     vec3 a = x * (2.51 * x + 0.03);
     vec3 b = x * (2.43 * x + 0.59) + 0.14;
     return a / b;
   }
   vec3 toneMapReinhard(vec3 x) {
     return x / (vec3(1.0) + x);
   }
   // adjust contrast around 0.5 mid grey
   vec3 applyContrast(vec3 color, float c) {
     return mix(vec3(0.5), color, c);
   }
   vec3 applySaturation(vec3 color, float s) {
     float l = dot(color, vec3(0.2126, 0.7152, 0.0722));
     return mix(vec3(l), color, s);
   }
   void main() {
     vec4 col = texture2D(tDiffuse, vUv);
     // assume incoming is linear (renderer.outputEncoding set to sRGB)
     vec3 linear = SRGBToLinear(col.rgb) * exposure;
     vec3 mapped;
     if (mode == 1) {
       mapped = toneMapACES(linear);
     } else {
       mapped = toneMapReinhard(linear);
     }
     mapped = applySaturation(mapped, saturation);
     mapped = applyContrast(mapped, contrast);
     vec3 srgb = LinearToSRGB(mapped);
     gl_FragColor = vec4(srgb, col.a);
   }
      `
    };

    composer = new EffectComposer(renderer);
    const renderPass = new RenderPass(scene, camera);
    composer.addPass(renderPass);
    // Add bloom pass before tone mapping so bloom contributes to HDR linear buffer
    bloomPass = new UnrealBloomPass(new THREE.Vector2(window.innerWidth, window.innerHeight), 1.5, 0.4, 0.85);
    bloomPass.enabled = true;
    // expose defaults
    bloomPass.strength = 0.0;
    bloomPass.radius = 0.4;
    bloomPass.threshold = 0.85;
    composer.addPass(bloomPass);
    tonePass = new ShaderPass(toneShader);
    // default tuning -- brighter to counter earlier darkness
    tonePass.uniforms.exposure.value = 1.2;
    tonePass.uniforms.contrast.value = 1.05;
    tonePass.uniforms.saturation.value = 1.0;
    tonePass.uniforms.mode.value = 1; // ACES by default
    composer.addPass(tonePass);
    // Copy pass to screen
    const copy = new ShaderPass(CopyShader);
    copy.renderToScreen = true;
    composer.addPass(copy);
 	// Remove these two to take out the effect of keep moving after dragging with the mouse
 	//controls.enableDamping = true;
 	//controls.dampingFactor = 0.5;
 	//light
 	ambientLight = new THREE.AmbientLight(0xFFFFFF,0.05);
 	scene.add(ambientLight);
 	spotlight = new THREE.SpotLight(0x808080, 0.8, 0, Math.PI / 2, 10);
 	// Set the spotlight position to match the camera position
 	spotlight.position.copy(camera.position);
 	//spotlight.position.set(-50,75,75);
 	spotlight.castShadow = true;
 	spotlight.angle = 0.2;
 	// Add the spotlight to the scene
 	scene.add(spotlight);
 	if (debug3D === true) {	
 		const spotLightHelper = new THREE.SpotLightHelper(spotlight,100);
 		scene.add(spotLightHelper);
     }
 	// Set the spotlight target to be a point in front of the camera
 	const fogColor = 0xFFFFFF; // Adjust the color to the desired misty tone
 	const fogDensity = 0.000002; // Adjust the density to control the mistiness
 	scene.fog = new THREE.FogExp2(fogColor, fogDensity);		
 	loadSkybox();
   	loadGround();
	if (parameters.showModel === true) {
		loadPyramid(true, parameters.showModelWire);
	}
   	// Enable shadows in the renderer
   	renderer.shadowMap.enabled = true;
   	renderer.shadowMap.type = THREE.BasicShadowMap; 
	/*
	renderer.toneMapping = THREE.ReinhardToneMapping;
	// Post-processing setup
	const composer = new EffectComposer(renderer);
	composer.addPass(new RenderPass(scene, camera));
	const bloomPass = new UnrealBloomPass(
	    new THREE.Vector2(window.innerWidth, window.innerHeight),
	    1.5, // strength
	    0.4, // radius
	    0.85 // threshold (lower makes more things bloom)
	);
	composer.addPass(bloomPass);
	*/
 	// expose tone mapping and bloom controls globally
 	if (typeof window !== 'undefined') {
 	  window.setToneExposure = function(v) { if (tonePass) { tonePass.uniforms.exposure.value = v; return true;} return false; };
 	  window.setToneContrast = function(v) { if (tonePass) { tonePass.uniforms.contrast.value = v; return true;} return false; };
 	  window.setToneSaturation = function(v) { if (tonePass) { tonePass.uniforms.saturation.value = v; return true;} return false; };
 	  window.setToneMode = function(m) { if (tonePass) { tonePass.uniforms.mode.value = m; return true;} return false; };
      window.setBloomStrength = function(v) { try { if (bloomPass) { bloomPass.strength = v; bloomPass.enabled = v>0; return true; } } catch(e) {} return false; };
      window.setBloomRadius = function(v) { try { if (bloomPass) { bloomPass.radius = v; return true; } } catch(e) {} return false; };
      window.setBloomThreshold = function(v) { try { if (bloomPass) { bloomPass.threshold = v; return true; } } catch(e) {} return false; };
 	}
	// create on-screen tuning UI for live adjustments
	if (typeof window !== 'undefined') {
	  // createTuningUI defined below
	  try { createTuningUI(); } catch(e) { console.warn('createTuningUI failed', e); }
	}
	animate();
 } // end of initScene
 
 // createTuningUI: builds a control panel for live tuning of tone mapping and pyramid shader
 // Accepts either:
 // - an HTMLElement to embed the panel into (preferred), or
 // - a dat.GUI folder object (backwards-compatible), or
 // - nothing (floating panel appended to document.body)
 function createTuningUI(containerOrGuiFolder) {
   if (typeof document === 'undefined') return;
   // avoid creating multiple times
   if (document.getElementById('pyramid-tuning-ui')) return;

   // detect what the caller passed
   const embedContainer = (containerOrGuiFolder && containerOrGuiFolder.nodeType === 1) ? containerOrGuiFolder : null;
   const guiFolder = (!embedContainer && containerOrGuiFolder && typeof containerOrGuiFolder.add === 'function') ? containerOrGuiFolder : null;

   // Prefer to embed into explicit container if provided; otherwise use the gui-container to choose embedding
   const fallbackGuiContainer = document.getElementById('gui-container');
   const willEmbedIntoParent = !!embedContainer || !!fallbackGuiContainer;

   // CSS: choose lightweight styles. If embedding into a parent container we avoid !important overrides
   const cssEmbedded = `
     #pyramid-tuning-ui { position: relative; width: 100%; background: transparent; color: #000000; font-family: sans-serif; font-size:13px; padding:8px; border-radius:6px; margin-top:8px; }
     #pyramid-tuning-ui h4 { margin:6px 0 8px 0; font-size:14px; }
     #pyramid-tuning-ui .row { display:flex; align-items:center; margin:6px 0; }
     #pyramid-tuning-ui .row label { flex:1 0 120px; }
     #pyramid-tuning-ui .row input[type=range] { flex:1 1 auto; }
     #pyramid-tuning-ui .row .val { width:40px; text-align:right; margin-left:8px; }
     #pyramid-tuning-ui select, #pyramid-tuning-ui button { width:100%; margin-top:6px; }
   `;
   const cssFloating = `
     #pyramid-tuning-ui { position: fixed; right: 12px; top: 12px; width: 300px; background: rgba(0,0,0,0.55); color: #000000; font-family: sans-serif; font-size:13px; padding:10px; border-radius:8px; z-index:99999; box-shadow: 0 6px 20px rgba(0,0,0,0.4); border: 1px solid rgba(255,255,255,0.04); backdrop-filter: blur(6px) saturate(120%); -webkit-backdrop-filter: blur(6px) saturate(120%); background-clip: padding-box; }
     #pyramid-tuning-ui h4 { margin:6px 0 8px 0; font-size:14px; }
     #pyramid-tuning-ui .row { display:flex; align-items:center; margin:6px 0; }
     #pyramid-tuning-ui .row label { flex:1 0 120px; }
     #pyramid-tuning-ui .row input[type=range] { flex:1 1 auto; }
     #pyramid-tuning-ui .row .val { width:40px; text-align:right; margin-left:8px; }
     #pyramid-tuning-ui select, #pyramid-tuning-ui button { width:100%; margin-top:6px; }
   `;
   const style = document.createElement('style'); style.textContent = (embedContainer ? cssEmbedded : (fallbackGuiContainer ? cssEmbedded : cssFloating)); document.head.appendChild(style);

   const panel = document.createElement('div'); panel.id = 'pyramid-tuning-ui';
   try { panel.className = 'dg main'; } catch(e) {}
   // If embedding into a parent, keep panel background transparent so it inherits parent's background
   if (embedContainer) {
     try { embedContainer.appendChild(panel); panel.style.display = 'none'; /* hidden until user toggles */ } catch(e) { document.body.appendChild(panel); panel.style.display='none'; }
   } else if (fallbackGuiContainer) {
     // if there's a gui-container but no explicit embed container requested, try to insert into gui container
     try { fallbackGuiContainer.appendChild(panel); panel.style.display = 'none'; } catch(e) { document.body.appendChild(panel); panel.style.display='none'; }
   } else {
     // floating fallback
     try { document.body.appendChild(panel); panel.style.position = 'fixed'; panel.style.right = '12px'; panel.style.top = '12px'; panel.style.display = 'none'; } catch(e) { /* ignore */ }
   }

   // Build the panel content: controls must exist so the later wiring (map.forEach) can find them
   try {
     // Header: create a collapsible section styled like the main GUI sections (Data/Scene)
     const sec = document.createElement('div'); sec.className = 'custom-gui-section';
     const hdr = document.createElement('div'); hdr.className = 'custom-gui-header'; hdr.textContent = 'Pyramid Tuning';
     hdr.style.cursor = 'pointer'; hdr.style.padding = '6px 8px'; hdr.style.background = 'rgba(40,40,40,0.9)';
     // ensure header is white and bold even if other styles override
     try { hdr.style.setProperty('color', '#ffffff', 'important'); } catch(e) { hdr.style.color = '#fff'; }
     try { hdr.style.setProperty('font-weight', '700', 'important'); } catch(e) { hdr.style.fontWeight = '700'; }
     hdr.style.borderRadius = '4px';
     const body = document.createElement('div'); body.className = 'custom-gui-body'; body.style.padding = '8px';
     // Open by default so the tuning controls are visible
     body.style.display = 'block';
     hdr.addEventListener('click', () => { body.style.display = body.style.display === 'none' ? 'block' : 'none'; });
     sec.appendChild(hdr); sec.appendChild(body); panel.appendChild(sec);

     // helper to create a row with label, input and value display
     function addRange(id, labelText, min, max, step, value) {
       const row = document.createElement('div'); row.className = 'row';
       const lbl = document.createElement('label'); lbl.textContent = labelText; row.appendChild(lbl);
       const input = document.createElement('input'); input.type = 'range'; input.id = id; input.min = String(min); input.max = String(max); input.step = String(step); input.value = String(value);
       row.appendChild(input);
       const val = document.createElement('div'); val.className = 'val'; val.id = id + '-val'; val.textContent = String(value);
       row.appendChild(val);
       // append into the section body instead of the raw panel so it gets the header treatment
       body.appendChild(row);
     }

    function addSimpleRange(id,labelText,min,max,step,value) { addRange(id,labelText,min,max,step,value); }

     // Tone controls
     addRange('tone-exp','Exposure',0.1,5,0.1,1.2);
     addRange('tone-contrast','Contrast',0.5,2,0.01,1.05);
     addRange('tone-sat','Saturation',0,2,0.01,1.0);
     // tone mode select
     // Make "Tone Mode" its own header section (collapsible) inside the Pyramid Tuning panel
     const toneSec = document.createElement('div'); toneSec.className = 'custom-gui-section';
     const toneHdr = document.createElement('div'); toneHdr.className = 'custom-gui-header'; toneHdr.textContent = 'Tone Mode';
     toneHdr.style.cursor = 'pointer'; toneHdr.style.padding = '6px 8px'; toneHdr.style.background = 'rgba(40,40,40,0.9)';
     try { toneHdr.style.setProperty('color', '#ffffff', 'important'); } catch(e) { toneHdr.style.color = '#fff'; }
     try { toneHdr.style.setProperty('font-weight', '700', 'important'); } catch(e) { toneHdr.style.fontWeight = '700'; }
     toneHdr.style.borderRadius = '4px';
     const toneBody = document.createElement('div'); toneBody.className = 'custom-gui-body'; toneBody.style.padding = '8px'; toneBody.style.display = 'block';
     toneHdr.addEventListener('click', () => { toneBody.style.display = toneBody.style.display === 'none' ? 'block' : 'none'; });
     toneSec.appendChild(toneHdr); toneSec.appendChild(toneBody);
     // create the actual tone-mode row and append to toneBody
     const rowMode = document.createElement('div'); rowMode.className = 'row';
     //const lblMode = document.createElement('label'); lblMode.textContent = 'Tone Mode'; rowMode.appendChild(lblMode);
     const sel = document.createElement('select'); sel.id = 'tone-mode';
     const opt0 = document.createElement('option'); opt0.value = '0'; opt0.textContent = 'Reinhard'; sel.appendChild(opt0);
     const opt1 = document.createElement('option'); opt1.value = '1'; opt1.textContent = 'ACES'; sel.appendChild(opt1);
     sel.value = '1'; rowMode.appendChild(sel); toneBody.appendChild(rowMode);
     // append the Tone Mode section into the main tuning body
     body.appendChild(toneSec);

     // Pyramid triplanar controls
     addRange('tri-scale','Triplanar Scale',0.1,10,0.1,1.0);
     addRange('tri-bump','Bump Scale',0,0.2,0.01,0.04);
     addRange('tri-spec','Specular Strength',0,1,0.01,0.35);
     addRange('tri-sun','Sun Intensity',0,5,0.1,2.0);
     addRange('tri-amb','Ambient',0,1,0.01,0.35);

     // Bloom controls
     addRange('bloom-strength','Bloom Strength',0,3,0.01,0.0);
     addRange('bloom-radius','Bloom Radius',0,2,0.01,0.4);
     addRange('bloom-threshold','Bloom Threshold',0,1,0.01,0.85);

     // Pyramid Tint controls: checkbox + color picker
     (function() {
      const row = document.createElement('div'); row.className = 'row';
      // label area
      const label = document.createElement('label'); label.textContent = 'Pyramid Tint'; row.appendChild(label);
      // checkbox
      const cb = document.createElement('input'); cb.type = 'checkbox'; cb.id = 'pyramid-tint'; cb.style.marginRight = '8px';
      // color picker (default to hex for gold)
      const color = document.createElement('input'); color.type = 'color'; color.id = 'pyramid-tint-color'; color.value = '#C2985E'; color.title = 'Tint color';
      // wire events
      cb.addEventListener('change', (e) => {
        try {
          const checked = e.target.checked;
          const hex = document.getElementById('pyramid-tint-color').value || '#C2985E';
          const num = parseInt(hex.replace('#',''),16);
          if (checked) {
            // call the tint function with numeric color if available
            try { if (typeof window !== 'undefined' && typeof window.tintPyramid === 'function') { window.tintPyramid(num); return; } } catch(e){}
            // fallback: use safeCall to attempt invoking
            try { safeCall('tintPyramid', num); } catch(e) { console.warn('tintPyramid call failed', e); }
          } else {
            try { if (typeof window !== 'undefined' && typeof window.restorePyramidAppearance === 'function') { window.restorePyramidAppearance(); return; } } catch(e){}
            try { safeCall('restorePyramidAppearance'); } catch(e) { console.warn('restorePyramidAppearance failed', e); }
          }
        } catch(err) { console.warn('pyramid tint toggle failed', err); }
      });
      color.addEventListener('input', (e) => {
        try {
          const hex = e.target.value || '#C2985E'; const num = parseInt(hex.replace('#',''),16);
          const cbEl = document.getElementById('pyramid-tint');
          if (cbEl && cbEl.checked) {
            try { if (typeof window !== 'undefined' && typeof window.tintPyramid === 'function') { window.tintPyramid(num); return; } } catch(e){}
            try { safeCall('tintPyramid', num); } catch(e) { console.warn('tintPyramid failed', e); }
          }
        } catch(err) { console.warn('pyramid tint color change failed', err); }
      });
      row.appendChild(cb); row.appendChild(color);
      // small spacer to align with other rows
      body.appendChild(row);
    })();

     // buttons
     const btnRow = document.createElement('div'); btnRow.className = 'row';
     const btnFallback = document.createElement('button'); btnFallback.id = 'use-fallback'; btnFallback.textContent = 'Fallback'; btnRow.appendChild(btnFallback);
     const btnReset = document.createElement('button'); btnReset.id = 'reset-tuning'; btnReset.textContent = 'Reset'; btnRow.appendChild(btnReset);
     body.appendChild(btnRow);
   } catch(e) { console.warn('failed to build tuning UI DOM', e); }

   // If the panel is embedded into the tuning container (or any parent), ensure it is transparent.
   // Some global styles for `.dg` or `#gui-container` may force a dark background; this rule targets
   // the dedicated container we create and uses !important so it takes precedence.
   try {
     const transparentRule = `
      /* Force the pyramid tuning panel to be transparent when embedded into our container */
      #pyramid-tuning-container > #pyramid-tuning-ui,
      #pyramid-tuning-container #pyramid-tuning-ui {
        background: transparent !important;
        background-color: transparent !important;
        border: none !important;
        box-shadow: none !important;
        backdrop-filter: none !important;
      }
    `;
    const tstyle = document.createElement('style'); tstyle.textContent = transparentRule; document.head.appendChild(tstyle);
    // also set inline transparent background as a safe fallback for browsers that prefer inline styles
    try { panel.style.setProperty('background', 'transparent', 'important'); panel.style.setProperty('background-color', 'transparent', 'important'); panel.style.setProperty('border', 'none', 'important'); panel.style.setProperty('box-shadow', 'none', 'important'); } catch(e) {}
   } catch(e) { /* best-effort */ }
 
   function safeCall(name, v) {
     try {
       if (typeof window !== 'undefined' && typeof window[name] === 'function') return window[name](v);
       // fallback: try updating uniforms directly
       if (name === 'setToneExposure' && tonePass) { tonePass.uniforms.exposure.value = v; return true; }
       if (name === 'setToneContrast' && tonePass) { tonePass.uniforms.contrast.value = v; return true; }
       if (name === 'setToneSaturation' && tonePass) { tonePass.uniforms.saturation.value = v; return true; }
       if (name === 'setToneMode' && tonePass) { tonePass.uniforms.mode.value = v; return true; }
       if (typeof pyramid !== 'undefined' && pyramid && pyramid.material && pyramid.material.uniforms) {
         const u = pyramid.material.uniforms;
         if (name === 'setPyramidTriplanarScale' && u.uScale) { u.uScale.value = v; return true; }
         if (name === 'setPyramidBumpScale' && u.uBumpScale) { u.uBumpScale.value = v; return true; }
         if (name === 'setPyramidSpecStrength' && u.uSpecStrength) { u.uSpecStrength.value = v; return true; }
         if (name === 'setPyramidSunIntensity' && u.uSunIntensity) { u.uSunIntensity.value = v; return true; }
         if (name === 'setPyramidAmbient' && u.uAmbient) { u.uAmbient.value = v; return true; }
       }
       // handle bloom settings
       if (typeof bloomPass !== 'undefined' && bloomPass && bloomPass.uniforms) {
         const u = bloomPass.uniforms;
         if (name === 'setBloomStrength' && u.strength) { u.strength.value = v; return true; }
         if (name === 'setBloomRadius' && u.radius) { u.radius.value = v; return true; }
         if (name === 'setBloomThreshold' && u.threshold) { u.threshold.value = v; return true; }
       }
     } catch(e) { console.warn('safeCall failed', name, e); }
     return false;
   }

   // wire inputs
   const map = [
     ['tone-exp','setToneExposure','tone-exp-val',1.2],
     ['tone-contrast','setToneContrast','tone-contrast-val',1.05],
     ['tone-sat','setToneSaturation','tone-sat-val',1.0],
     ['tri-scale','setPyramidTriplanarScale','tri-scale-val',1.0],
     ['tri-bump','setPyramidBumpScale','tri-bump-val',0.04],
     ['tri-spec','setPyramidSpecStrength','tri-spec-val',0.35],
     ['tri-sun','setPyramidSunIntensity','tri-sun-val',2.0],
     ['tri-amb','setPyramidAmbient','tri-amb-val',0.35],
     ['bloom-strength', 'setBloomStrength', 'bloom-strength-val', 0.0],
     ['bloom-radius', 'setBloomRadius', 'bloom-radius-val', 0.4],
     ['bloom-threshold', 'setBloomThreshold', 'bloom-threshold-val', 0.85]
   ];

   map.forEach(item => {
     const [id, fn, valId, defaultVal] = item;
     const el = document.getElementById(id);
     const valEl = document.getElementById(valId);
     if (!el) return;
     // initialize display
     valEl.textContent = parseFloat(el.value).toFixed( (el.step && el.step.indexOf('.')>=0) ? el.step.split('.')[1].length : 2 );
     el.addEventListener('input', (e) => {
       const v = Number(e.target.value);
       valEl.textContent = (v.toFixed( (e.target.step && e.target.step.indexOf('.')>=0) ? e.target.step.split('.')[1].length : 2 ));
       // call exposed setter if present, otherwise safeCall will update uniforms
       safeCall(fn, v);
     });
   });

   // tone mode select
   const modeSel = document.getElementById('tone-mode');
   modeSel.addEventListener('change', (e) => { const m = parseInt(e.target.value); safeCall('setToneMode', m); });

   // fallback button and reset
   document.getElementById('use-fallback').addEventListener('click', () => {
     // toggle fallback state
     try {
       const ok = safeCall('usePyramidFallback', true);
       if (ok) {
         document.getElementById('use-fallback').textContent = 'Fallback ON';
       } else {
         // try toggle off
         const off = safeCall('usePyramidFallback', false);
         document.getElementById('use-fallback').textContent = off ? 'Fallback OFF' : 'Fallback';
       }
     } catch(e) { console.warn(e); }
   });

   document.getElementById('reset-tuning').addEventListener('click', () => {
     // reset to defaults
     [['tone-exp',1.2],['tone-contrast',1.05],['tone-sat',1.0],['tone-mode',1],['tri-scale',1.0],['tri-bump',0.04],['tri-spec',0.35],['tri-sun',2.0],['tri-amb',0.35],['bloom-strength', 1.0], ['bloom-radius', 0.4], ['bloom-threshold', 0.85]].forEach(pair => {
      const el = document.getElementById(pair[0]); if (!el) return; el.value = pair[1]; const ev = new Event('input'); el.dispatchEvent(ev);
    });
     // mode change
     document.getElementById('tone-mode').value = '1'; safeCall('setToneMode', 1);
     // clear pyramid tint state and reset color picker to default
     try {
      const tintCb = document.getElementById('pyramid-tint');
      const tintColor = document.getElementById('pyramid-tint-color');
      if (tintCb) { tintCb.checked = false; }
      if (tintColor) { tintColor.value = '#C2985E'; }
      try { if (typeof window !== 'undefined' && typeof window.restorePyramidAppearance === 'function') window.restorePyramidAppearance(); } catch(e) { try { safeCall('restorePyramidAppearance'); } catch(_) {} }
    } catch(e) { /* ignore */ }
    // if a dat.GUI controller exists for the tuning panel, ensure it's closed
    try { if (window._pyramidTuningController) window._pyramidTuningController.setValue(false); } catch(e) {}
   });
 }
 
 // expose for external callers (main.js) so the panel can be created after GUIinit
 if (typeof window !== 'undefined') {
	window.resetCameraPosition = resetCameraPosition;
 	window.draw3DSettings = draw3DSettings;
 	window.initScene = initScene;
 	window.acceptanceRange = acceptanceRange;
 	window.loadPyramid = loadPyramid;
 	window.setPyramidWireframe = setPyramidWireframe;
 	window.removeObject3D = removeObject3D;
 	window.loadIndex = loadIndex;
 	window.createPyramidTuningUI = createTuningUI;
 }
