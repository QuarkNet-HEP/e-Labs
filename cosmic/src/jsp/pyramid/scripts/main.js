// client-side js
// run by the browser each time your view template is loaded

// Extract globals, otherwise linting gets angry
const { THREE } = window;
const { dat } = window;
//const { Stats } = window;

const max_lg = 1200;

var x;
var y;
var g;

function print(string) { throw new Error(string); }

// Create a scene
const scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera(90, window.innerWidth / window.innerHeight, 0.01, 10000000);

// Create a renderer
var renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
const canvasContainer = document.getElementById('canvas-container');
canvasContainer.appendChild(renderer.domElement);

const renderPass = new THREE.RenderPass(scene, camera);
const bloomPass = new THREE.UnrealBloomPass();

const composer = new THREE.EffectComposer(renderer);
composer.addPass(renderPass);
composer.addPass(bloomPass);

const stats = new Stats();
//stats.showPanel(0); // 0: FPS, 1: MS (millisecond), 2: MB (megabytes)
const fpsContainer = document.getElementById('fps-container');
fpsContainer.appendChild(stats.domElement);



const url1 = "https://raw.githubusercontent.com/QuarkNet-HEP/pyramid/main/simple%20(1).stl";

var files = {};

var model;
const loader = new THREE.STLLoader();
  loader.load(url1, function (geometry) {
    var center = new THREE.Vector3();
    geometry.computeBoundingBox();
    center.x = (geometry.boundingBox.min.x + geometry.boundingBox.max.x) / 2;
    center.y = (geometry.boundingBox.min.y + geometry.boundingBox.max.y) / 2;
    center.z = (geometry.boundingBox.min.z + geometry.boundingBox.max.z) / 2;

    // Translate the model to center it
    geometry.translate(-center.x, -center.y, -center.z);
    
    
    const verticesAttribute = geometry.getAttribute('position');
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
    const target = 13*30; //12 is 1 meter. The pyramid is 24m
    const ratio = target/height;

    // Calculate the height
    
    
    const material = new THREE.MeshStandardMaterial();
    material.color.set(0xC2985E);
    material.wireframe = false;
    
    
    model = new THREE.Mesh(geometry, material);
    
    
    var rotationAngle = THREE.MathUtils.degToRad(270); // Convert degrees to radians
    var axis = new THREE.Vector3(1, 0, 0); // X-axis
    model.rotateOnWorldAxis(axis, rotationAngle);
    
    rotationAngle = THREE.MathUtils.degToRad(180); // Convert degrees to radians
    axis = new THREE.Vector3(0, 1, 0); // X-axis
    model.rotateOnWorldAxis(axis, rotationAngle);
    
    model.scale.x *= ratio;
    model.scale.y *= ratio;
    model.scale.z *= ratio;
    
    model.position.set(-6.25, 205, -250);
    model.castShadow = true;
    scene.add(model);
});


class triShaft {
  constructor() {
    this.dir = 'x';
    this.index = 0;
    this.length = 8.32;
    this.size = 0.52;
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
    
    
    //scene.add(this.prism)
    //this.prism = group
  }
}

class sensor {
  constructor (data) {
    this.centerx=0;
    this.centery=0;
    this.centerz=0;
    this.zoomPos = new THREE.Vector3(0,0,0);
    this.planeSpacing=6;
    this.moduleSpacing=0.1;
    this.gridx=28;
    this.gridy=48;
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
    for (let k = 0; k < 3; k++) {
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
      for (let i=0; i < this.gridx; i++) {
        n = new triShaft();
        if (i%2 != xpattern) { n.orientation = "up"; }
        if (i%2 == xpattern) { n.orientation = "down"; }

        if (i>0 && i%4==0) { spacing += this.moduleSpacing; }
        n.length = this.gridy/2 * n.size + this.moduleSpacing * (Math.floor(this.gridy/4)-1)// - n.size/2
        
        offset = -this.gridx/4 + spacing;
        n.xpos = offset + i*n.size/2;

        n.ypos = (1-k)*this.planeSpacing;
        n.zpos = -this.gridy/4 + n.size*2.5;
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
      for (let i=0; i<this.gridy; i++) {
        n = new triShaft();
        n.dir = "y";
        if (i%2 != ypattern) { n.orientation = "up"; }
        if (i%2 == ypattern) { n.orientation = "down"; }
        
        n.length = this.gridx/2 * n.size + this.moduleSpacing * (Math.floor(this.gridy/4)-1) - n.size/2
        n.xpos = -this.gridx/4;
        n.ypos = (1-k)*this.planeSpacing + n.size/2;

        if (i>0 && i%4==0) {spacing += this.moduleSpacing;}
        offset =  - this.gridy/2 + spacing;

        n.zpos = offset + i*n.size/2;
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
    
 
    
    scene.add(this.group);   
    
  }
}

function acceptanceRange(s,range) {
  //clear previous acceptance mesh
  for (i in acceptGroup) { s.group.remove(acceptGroup[i]); }
  
  const plane1 = s.shafts[0]['y'];
  const high1 = plane1[0];
  const high2 = plane1[plane1.length-1];
  const p1 = new THREE.Vector3(high1.xpos,high1.ypos+high1.size/2,high1.zpos-high2.size);
  const p2 = new THREE.Vector3(high2.xpos,high2.ypos+high2.size/2,high2.zpos);
  const p3 = new THREE.Vector3(high1.xpos+high1.length,high1.ypos+high1.size/2,high1.zpos-high2.size);
  const p4 = new THREE.Vector3(high2.xpos+high2.length,high2.ypos+high2.size/2,high2.zpos);
  
  const plane2 = s.shafts[2]['x'];
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
    s.group.add(mesh);
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
    s.group.add(line);
    acceptGroup.push(line);
  }
  //cube points at the corners of the acceptance cone
  /*
  function cube(pos,color) {
    const cubeGeometry = new THREE.BoxGeometry(0.3, 0.3, 0.3);
    const cubeMaterial = new THREE.MeshBasicMaterial({ color: color });
    const cubeMesh = new THREE.Mesh(cubeGeometry, cubeMaterial);
    cubeMesh.position.copy(pos);
    s.group.add(cubeMesh);
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

function loadEvent(eventIndex,x,y,s) {
  let eventX = x[eventIndex-1];
  let eventY = y[eventIndex-1];
  
  let x_prisms = {};
  let y_prisms = {};
  
  let x_hit = {};
  let y_hit = {};
  
  for (let obj of s.job) {
    obj.faces.material.color.set(s.xcolor);
    obj.faces.material.transparent = true;
    obj.faces.material.opacity = 0.01;
  }
  if (eventX == undefined) { eventX = []; }
  if (eventY == undefined) { eventY = []; }
  for (let layer=0; layer<eventX.length; layer++){
    let x_new = {};
    let xp_new = {};
    for (let i=0; i<eventX[layer].length; i++) {
      let lg = eventX[layer][i];
      
      obj = s.shafts[layer]["x"][i];
      if (obj != undefined) {
        x_new[i] = lg;
        xp_new[i] = obj;

        if (lg > 0) {
          obj.faces.material.color.set(new THREE.Color(`hsl(${((max_lg-lg)/max_lg)*60}, 100%, 50%)`));
          obj.faces.material.transparent = false;
          obj.faces.material.opacity = 1;
        }
      }
    }
    x_hit[layer] = x_new;
    x_prisms[layer] = xp_new;
  }
  
  for (let layer=0; layer<eventY.length; layer++){
    let y_new = {};
    let yp_new = {};
    for (let i=0; i<eventY[layer].length; i++) {
      let lg = eventY[layer][i];
      
      obj = s.shafts[layer]["y"][i];
      y_new[i] = lg;
      yp_new[i] = obj;
      
      if (lg > 0) {
        obj.faces.material.color.set(new THREE.Color(`hsl(${((max_lg-lg)/max_lg)*60}, 100%, 50%)`));
        obj.faces.material.transparent = false;
        obj.faces.material.opacity = 1;
      }
    }
    y_hit[layer] = y_new;
    y_prisms[layer] = yp_new;
  }
  
  let vectors = globalThis.calculate(scene,s,x_prisms, y_prisms, x_hit, y_hit);
  
  for (i in vectors) {
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
    
    const geometry = new THREE.BufferGeometry();
    var positions = new Float32Array([startPoint.x-s.centerx, startPoint.y-s.centery, startPoint.z-s.centerz, endPoint.x-s.centerx, endPoint.y-s.centery, endPoint.z-s.centerz]);
    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    
    const material = new THREE.LineBasicMaterial({ color: 0x00ff00 });
    
    const line = new THREE.Line(geometry, material);
    muonVectors.push(line);
    s.group.add(line);
    
  }
  
}

function loadAngle(s,x,y,z) {
  s.group.rotation.x = x;
  s.group.rotation.y = y;
  s.group.rotation.z = z;
}

function smoothCameraZoom(s,camera, targetPosition, duration) {
  const initialPosition = camera.position.clone();
  const startTime = Date.now();
  const zoomOutDistance = 30;
  
  // Calculate the zoomed position based on the target position and zoom out distance
  const direction = targetPosition.clone().sub(initialPosition).normalize();
  const zoomedPosition = targetPosition.clone().addScaledVector(direction, -zoomOutDistance);
  
  function updateCameraPosition() {
    const currentTime = Date.now();
    const elapsed = currentTime - startTime;
    const t = Math.min(1, elapsed / duration);

    // Interpolate the camera position based on the current time
    const newPosition = initialPosition.clone().lerp(zoomedPosition, t);
    camera.position.copy(newPosition);

    // Look at the target position
    camera.lookAt(targetPosition.add(new THREE.Vector3(s.centerx,s.centery,s.centerz)));
    
    // Continue the animation until the duration is reached
    if (t < 1) {
      requestAnimationFrame(updateCameraPosition);
    }
  }

  // Start the animation
  updateCameraPosition();
  controls.target.set(0, 0, 0); // Set the target position to the center of the scene
  controls.update();
}

function updateSpotlightPosition (spotlight,target,distance) {
    // Set the spotlight position to match the camera position
  spotlight.position.copy(camera.position);

  const cameraDirection = new THREE.Vector3();
  camera.getWorldDirection(cameraDirection);

  // Calculate the target position in front of the camera based on the distance
  const targetPosition = new THREE.Vector3();
  targetPosition.copy(cameraDirection).multiplyScalar(distance).add(camera.position);

  // Set the spotlight's target position to the calculated targetPosition
  spotlight.target.position.copy(targetPosition);
}

function handleWASDMovement() {
  const forward = new THREE.Vector3(0, 0, -1);
  const right = new THREE.Vector3(1, 0, 0);

  // Move forward and backward (W and S keys)
  if (keys.w) {
    camera.position.add(forward.clone().multiplyScalar(movementSpeed));
  }
  if (keys.s) {
    camera.position.add(forward.clone().multiplyScalar(-movementSpeed));
  }

  // Move left and right (A and D keys)
  if (keys.a) {
    camera.position.add(right.clone().multiplyScalar(-movementSpeed));
  }
  if (keys.d) {
    camera.position.add(right.clone().multiplyScalar(movementSpeed));
  }
}

//global variable init;
var controls;
var parameters = {};
var s;
var skyboxMesh;
var ground;
var updateSpotlightPosition;
var spotlight;
var ambientLight;
var target;
var muonVectors = [];
var acceptGroup = [];

const movementSpeed = 3;
const forward = new THREE.Vector3(0, 0, -1);
const right = new THREE.Vector3(1, 0, 0);

// Keep track of the keys that are pressed
const keys = {
  w: false,
  a: false,
  s: false,
  d: false,
};

function GUIinit() {
  // controls
  controls = new THREE.OrbitControls(camera, renderer.domElement);
  
  controls.enableDamping = true;
  controls.dampingFactor = 0.05;
  
  document.addEventListener("keydown", (event) => {
    if (event.key in keys) {
      keys[event.key] = true;
    }
  });

  document.addEventListener("keyup", (event) => {
    if (event.key in keys) {
      keys[event.key] = false;
    }
  });
  
  //dat gui
  const guiContainer = document.getElementById('gui-container');
  const gui = new dat.GUI({ autoPlace: false });
  guiContainer.appendChild(gui.domElement);
  
  parameters.shaders = false;
  parameters.eventIndex = 1;
  parameters.acceptRange = 200;
  parameters.showModel = true;
  parameters.showSkybox = true;
  parameters.showGround = true;
  parameters.keepVectors = true;
  parameters.xrot = 0;
  parameters.yrot = 0;
  parameters.zrot = 0;
  parameters.xpos = 0;
  parameters.ypos = 0;
  parameters.zpos = 0;
  parameters.fileName = "";
  parameters.loadFile = function(type, purpose) {
    return function() {
      const input = document.createElement('input');
      input.type = 'file';
      input.accept = type;
      input.style.visibility = 'hidden';
      input.addEventListener('change', function(event) {
        const file = event.target.files[0];

        useFile(file, updateGUI, type, purpose);
      });
      input.click();
    };
  };
  
  //File loading software
  const dataGUI = gui.addFolder("Data");
  dataGUI.add(parameters, 'loadFile').name('Load Text File Example').onFinishChange(parameters.loadFile('.txt', 'events'));
  
  
  // Function to handle the file loading logic
  function useFile(file, callback, type, purpose) {
    
    const filePath = file.name;
    files[filePath] = file;
    parameters[filePath]=filePath;
    callback(filePath);
  }

  // Callback function to update the GUI with the loaded file path or name
  function updateGUI(filePath) {
    var newFile = fileGUI.add(parameters, filePath).name('Loaded File').listen().setValue(filePath);
    newFile.onChange(function(value) {
      parameters[filePath] = filePath; // Restore the original value
      gui.updateDisplay(); // Update the GUI to reflect the original value
    });
  }
  
  
  dataGUI.open();
  
  const sceneGUI = gui.addFolder("Scene"); 
  
  const params1 = {
  zoomToSensor: function() {
    // Call the smoothCameraZoom function here with the desired target position and duration
    const targetPosition = new THREE.Vector3(s.centerx,s.centery,s.centerz); // Specify the target position
    const duration = 1000; // Specify the duration in milliseconds
    smoothCameraZoom(s, camera, targetPosition, duration);
    }
  };
  
  const params2 = { clearVectors: function() { for (i in muonVectors) { s.group.remove(muonVectors[i]); } } };

  // Add the button to the GUI
  sceneGUI.add(params1, 'zoomToSensor').name('Zoom to Sensor');
  
  sceneGUI.add(params2, 'clearVectors').name('Clear Muon Vectors');
  
  sceneGUI.add(parameters, 'acceptRange', 0, 20000).step(1).name("Acceptance Range").onChange(onAcceptanceRangeChange); 
  function onAcceptanceRangeChange() { acceptanceRange(s,parameters.acceptRange) }
  
  sceneGUI.add(parameters, 'shaders').name("Turn On Shaders")
  
  sceneGUI.add(parameters, 'showModel').name("Show Pyramid").onChange(onModelVisibilityChange);
  function onModelVisibilityChange() { model.visible = parameters.showModel; }
  
  sceneGUI.add(parameters, 'showSkybox').name("Show Skybox").onChange(onSkyboxVisibilityChange);
  function onSkyboxVisibilityChange() { skyboxMesh.visible = parameters.showSkybox; }
  
  sceneGUI.add(parameters, 'showGround').name("Show Ground").onChange(onGroundVisibilityChange);
  function onGroundVisibilityChange() { ground.visible = parameters.showGround; }

  sceneGUI.open(); 
  
  const sensorGUI = gui.addFolder("Sensor"); 
  
  sensorGUI.add(parameters, 'eventIndex', 1, x.length).step(1).name("Event").onChange(onEventIndexChange); 
  function onEventIndexChange() { loadEvent(parameters.eventIndex, x,y,s)}
  
  sensorGUI.add(parameters, 'xrot', 0, 3.14159265).step(0.00872664625).name("X Rotation").onChange(onXRotChange); 
  function onXRotChange() { loadAngle(s,parameters.xrot, parameters.yrot, parameters.zrot); }
  
  sensorGUI.add(parameters, 'yrot', 0, 3.14159265).step(0.00872664625).name("Y Rotation").onChange(onZRotChange); 
  function onZRotChange() { loadAngle(s,parameters.xrot, parameters.yrot, parameters.zrot); }
  
  sensorGUI.add(parameters, 'zrot', -3.14159265, 3.14159265).step(0.00872664625).name("Z Rotation").onChange(onYRotChange); 
  function onYRotChange() { loadAngle(s,parameters.xrot, parameters.yrot, parameters.zrot); }
  
  
  
  sensorGUI.add(parameters, 'xpos',-100,100).name("X Position").onChange(onXposChange);
  function onXposChange() { s.group.position.x = parameters.xpos; s.centerx = parameters.xpos; };
  
  sensorGUI.add(parameters, 'ypos',-100,100).name("Y Position").onChange(onYposChange);
  function onYposChange() { s.group.position.y = parameters.ypos; s.centery = parameters.ypos; };
  
  sensorGUI.add(parameters, 'zpos',-100,100).name("Z Position").onChange(onZposChange);
  function onZposChange() { s.group.position.z = parameters.zpos; s.centerz = parameters.zpos; };
  
  sensorGUI.open();
  
  const fileGUI = gui.addFolder("Files")
}

function init(x,y,g) {
  s = new sensor();
  s.centery = 50;
  s.centerx = 0;
  s.centerz = 0;
  s.xtransparency=0;
  s.ytransparency=0;
  s.xstart = 'down';
  s.ystart = 'down';
  s.render();
  
  //no coordinate system yet
  //waiting for data

  
  //camera.position.set(-200,2000,2000);
  camera.position.set(-200,500,500);
  camera.lookAt(s.centerx, s.centery, s.centerz);  
  
  acceptanceRange(s,parameters.acceptRange);
  
  //light
  ambientLight = new THREE.AmbientLight(0xFFFFFF,0.05);
  scene.add(ambientLight);
  
  spotlight = new THREE.SpotLight(0x808080, 0.8, 0, Math.PI / 2, 10);

  // Set the spotlight position to match the camera position
  spotlight.position.copy(camera.position);

  // Set the spotlight target to be a point in front of the camera
  target = new THREE.Vector3();

  // Add the spotlight to the scene
  scene.add(spotlight);

  const fogColor = 0xFFFFFF; // Adjust the color to the desired misty tone
  const fogDensity = 0.000002; // Adjust the density to control the mistiness

  scene.fog = new THREE.FogExp2(fogColor, fogDensity);

  
  //scene.background = new THREE.Color(0x87CEEB);
  let textureLoader = new THREE.TextureLoader();
  let texture = textureLoader.load('https://raw.githubusercontent.com/QuarkNet-HEP/pyramid/main/sky_water_landscape.jpg');

  let radius = 10000; // Adjust the radius as needed
  let widthSegments = 256; // Adjust the number of segments as needed
  let heightSegments = 256; // Adjust the number of segments as needed
  
  let sphereGeometry = new THREE.SphereGeometry(radius, widthSegments, heightSegments);
  // Create a base material for the skybox with the texture
  let material = new THREE.MeshStandardMaterial({ map: texture, side: THREE.BackSide });
  
  // Create the skybox mesh using the sphere geometry and the custom material
  skyboxMesh = new THREE.Mesh(sphereGeometry, material);
  scene.add(skyboxMesh);
  
  //ground
  var groundGeo = new THREE.CircleGeometry( 10000, 10000 );
  var groundMat = new THREE.MeshStandardMaterial( { color: 0xF6E4AD } );
  groundMat.opacity = 1;

  ground = new THREE.Mesh( groundGeo, groundMat );
  ground.rotation.x = -Math.PI/2;
  ground.position.y = 0;
  scene.add( ground );

  ground.receiveShadow = true;
  
  // Enable shadows in the renderer
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap; 
  
  
  loadEvent(1,x,y,s);

}

function animate() {
    requestAnimationFrame(animate);
    controls.update();
    stats.update();

    updateSpotlightPosition(spotlight,target,10);

    handleWASDMovement();
    
    // Update renderer dimensions when the window is resized
    const width = window.innerWidth;
    const height = window.innerHeight;
    if (renderer.domElement.width !== width || renderer.domElement.height !== height) {
      renderer.setSize(width, height);
      camera.aspect = width / height;
      camera.updateProjectionMatrix();
    }
    
    // Render the scene
    renderer.render(scene, camera);
    if (parameters.shaders) { 
      composer.render(); 
      spotlight.intensity = 0.8
      ambientLight.intensity = 0.05;
    } else {
      spotlight.intensity = 1
      ambientLight.intensity = 1;
    }
  }

function wait(ms) { return new Promise((resolve) => setTimeout(resolve, ms)); }

function waitUntilCondition() {
  return new Promise((resolve) => {
    const checkInterval = setInterval(() => {
      
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

      // Usage of Promise.all() to wait for both functions to finish
      Promise.all([retrieveData(), retrieveGeometry()])
        .then(([data, geometry]) => {
          if (globalThis.x != undefined && globalThis.x.length > 0) { x = globalThis.x; }
          if (globalThis.y != undefined && globalThis.y.length > 0) { y = globalThis.y; }
          if (globalThis.g != undefined && globalThis.g.length > 0) { g = globalThis.g; }
          

          
          if (x != undefined && y != undefined && g != undefined) {
            if (x.length > 0 && y.length > 0 && g.length > 0) {
              clearInterval(checkInterval);
              resolve();
            }
          }

          // Place your code here that relies on both data and geometry
        })
        .catch(error => {
          console.log("Waiting for data load");
        });
      
      
    }, 10); // Poll every 0.01 seconds
  });
}

async function execute() {
  await waitUntilCondition();
  
  //Execute everything until the global variables have transferred
  GUIinit();
  init(x,y,g);
  animate();  
}

execute();



