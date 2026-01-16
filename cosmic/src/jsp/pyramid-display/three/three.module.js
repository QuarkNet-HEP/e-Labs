// Compatibility shim: re-export the build copy so imports resolving to /three.module.js work
export * from './three/build/three.module.js';
export { default } from './three/build/three.module.js';
