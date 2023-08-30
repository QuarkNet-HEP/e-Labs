//const test is just so the linter gets annoyed at the first line
const test = '';
const min = 20
var y;
globalThis.calculate = function (temp1, s, x_prisms, y_prisms, x, y) {
  
  function point(x,y,z) { return new THREE.Vector2(x,y); }
  
  x_hits = {0:[],1:[],2:[]}
  //Search x-paths
  for (layer in x) {
    const plane = x[layer.toString()]
    var prev_lg=0
    var current_lg=0;
    
    for (i in plane) {
      //It will take maximum of two shafts at a time, since three hit shafts won't register all planes
      if (i>0) { prev_lg = plane[i-1] }
      //set current
      current_lg = plane[i]

      //process adjacent pairs
      var casework = current_lg >= min && prev_lg >= min
      casework = casework || (i>0 && current_lg>=min && prev_lg<min && plane[(parseInt(i)+1).toString()]<min )
      casework = casework || (i==1 && prev_lg >= min && current_lg < min)
      casework = casework || (i==plane.length && current_lg >= min && prev_lg < min)
      
      if (casework) {

        const prism = x_prisms[layer][i-1]
        
        //add interpolated distance to current position
        const estimatedPos = prism.size/2 + interpolate(prism.size/2,prev_lg,current_lg);

        const startX = prism.xpos + s.centerx;
        const startY = prism.ypos + s.centery;
        const startZ = prism.zpos + s.centerz;

        x_hits[layer].push( point(startX+estimatedPos,startY+prism.size/4) );

      }               
    }
    
  }
  //end first loop
  
  y_hits = {0:[],1:[],2:[]}
  //Search x-paths
  for (layer in y) {
    const plane = y[layer.toString()]
    var prev_lg=0
    var current_lg=0;
    
    for (i in plane) {
      //It will take maximum of two shafts at a time, since three hit shafts won't register all planes
      if (i>0) { prev_lg = plane[i-1] }
      //set current
      current_lg = plane[i]

      //process adjacent pairs
      var casework = current_lg >= min && prev_lg >= min
      casework = casework || (i>0 && current_lg>=min && prev_lg<min && plane[(parseInt(i)+1).toString()]<min )
      casework = casework || (i==1 && prev_lg >= min && current_lg < min)
      casework = casework || (i==plane.length && current_lg >= min && prev_lg < min)
      
      if (casework) {

        const prism = y_prisms[layer][i-1]

        const sizeOffset = prism.size/2
        //add interpolated distance to current position
        const estimatedPos = interpolate(prism.size/2,prev_lg,current_lg) - prism.size/2;

        const startX = prism.xpos + s.centerx;
        const startY = prism.ypos + s.centery;
        const startZ = prism.zpos + s.centerz;

        y_hits[layer].push( point(startZ+estimatedPos,startY+prism.size/4) );

      }               
    }
    
  }
  
  const vx = vectorize(x_hits);
  const vy = vectorize(y_hits);
  //console.log(vy);
  //create 3D vectors
  var v = [];
  for (let i=0;i<vy.length;i++) {
    const z1 = vy[i].x.x;
    const z2 = vy[i].y.x;
    //console.log(y1,y2);
    for (let j=0;j<vx.length;j++) {
      const x1 = vx[j].x.x;
      const x2 = vx[j].y.x;
      
      const y1 = vx[j].x.y;
      const y2 = vx[j].y.y;
      

      const point1 = new THREE.Vector3( x1,y1,z1 );
      const point2 = new THREE.Vector3( x2,y2,z2 );
      
      const final_vector = new THREE.Vector2(point1,point2);
      v.push(final_vector);
    }
  }
  //console.log(v);
  return v;
};

function interpolate (length,a,b) {
  //bogus interpolation method for now
  return b/(a+b)*length;
}

//Priority for LG value has not been incorporated yet
function vectorize(hits) {
  //Find all vectors intersecting the first and third plane
  //Calculate how close the vector is to a point in the second plane, that is the efficiency
  //sort by efficiency, and take the most efficient vector that belongs to each point in the first layer
  
  
  var vectors = [];
  var used = [];
  for (let i=0;i<hits[0].length;i++) {
    const p1 = hits[0][i];
    //console.log(p1)
    var efficiency = Number.MAX_SAFE_INTEGER;
    var effMap = [];
    
    var vector; //= new THREE.Vector2(p1,hits[2][0]);
    
    
    for (let j=0;j<hits[2].length;j++) {
      const p2 = hits[2][j];
      
      
      const m = (p1.x-p2.x)/(p1.y-p2.y);
      const b = p1.y-m*p1.x;
      
      //find most efficient vector
      var least_dist = Number.MAX_SAFE_INTEGER;
      
      //find efficiency
      for (let k=0;k<hits[1].length;k++) {
        const p3 = hits[1][k];
        const nx = (p3.y - b)/m; //x-value at intersection
        const nd = Math.abs( p3.x - nx ); //distance from actual x
        
        if (nd < least_dist ){ least_dist = nd; }
      }
      
      effMap[least_dist] = new THREE.Vector2(p1,p2);
    }
    
    //sort by efficiency
    effMap.sort(function(a, b) {
      return a.key - b.key;
    });
    

    for (efficiency in effMap) {
    
      if ( !used.includes( effMap[efficiency].y ) ) {
        vectors.push(effMap[efficiency]);
        used.push(effMap[efficiency].y);
        break;
      }
    }
  }
  
  return vectors;  
}