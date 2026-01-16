// Minimal Pass.js implementation (ES module) adapted for this project
// Imports from local three.module.js build
import {
  OrthographicCamera,
  Scene,
  Mesh,
  PlaneGeometry,
  MeshBasicMaterial
} from '../../../build/three.module.js';

class Pass {
  constructor() {
    // Enabled by default
    this.enabled = true;
    this.needsSwap = true;
    this.clear = false;
    this.renderToScreen = false;
  }

  setSize(/* width, height */) {}

  render(/* renderer, writeBuffer, readBuffer, deltaTime, maskActive */) {
    console.warn('Pass: .render() must be implemented in derived pass.');
  }
}

class FullScreenQuad {
  constructor(material) {
    this._mesh = new Mesh(new PlaneGeometry(2, 2), material || new MeshBasicMaterial());
    this._camera = new OrthographicCamera(-1, 1, 1, -1, 0, 1);
    this._scene = new Scene();
    this._scene.add(this._mesh);
  }

  get material() {
    return this._mesh.material;
  }

  set material(value) {
    this._mesh.material = value;
  }

  render(renderer) {
    renderer.render(this._scene, this._camera);
  }

  dispose() {
    this._mesh.geometry.dispose();
    if (this._mesh.material && this._mesh.material.dispose) this._mesh.material.dispose();
  }
}

export { Pass, FullScreenQuad };
