// Shared THREE loader used by draw3D.js and muonVector.js
// Exports ensureThreeReady() which returns a promise that resolves once THREE and helpers are available.

let _threeReadyPromise = null;

export function ensureThreeReady() {
  if (_threeReadyPromise) return _threeReadyPromise;

  _threeReadyPromise = (async () => {
    try {
      if (typeof window !== 'undefined' && window.THREE) {
        // THREE already on window: try to pick up helper classes if present
        const importIfMissing = async (path, names) => {
          try {
            const mod = await import(path);
            for (const n of names) {
              if (typeof window[n] === 'undefined' && typeof mod[n] !== 'undefined') {
                window[n] = mod[n];
              }
            }
          } catch (e) {
            // ignore
          }
        };
        // Attempt to load a few helpers if missing (best-effort)
        await importIfMissing('../three/examples/jsm/controls/OrbitControls.js', ['OrbitControls','MapControls']);
        await importIfMissing('../three/examples/jsm/loaders/STLLoader.js', ['STLLoader']);
        await importIfMissing('../three/examples/jsm/loaders/FontLoader.js', ['FontLoader']);
        await importIfMissing('../three/examples/jsm/geometries/TextGeometry.js', ['TextGeometry']);
        await importIfMissing('../three/examples/jsm/postprocessing/EffectComposer.js', ['EffectComposer']);
        await importIfMissing('../three/examples/jsm/postprocessing/RenderPass.js', ['RenderPass']);
        await importIfMissing('../three/examples/jsm/postprocessing/ShaderPass.js', ['ShaderPass']);
        await importIfMissing('../three/examples/jsm/postprocessing/UnrealBloomPass.js', ['UnrealBloomPass']);
        await importIfMissing('../three/examples/jsm/shaders/CopyShader.js', ['CopyShader']);
        await importIfMissing('../three/examples/jsm/shaders/LuminosityHighPassShader.js', ['LuminosityHighPassShader']);

        return window.THREE;
      }

      // Load three.module.js and helpers
      const threeModule = await import('../three/build/three.module.js');
      if (typeof window !== 'undefined') {
        try { window.THREE = threeModule; } catch (e) { /* ignore */ }
      }

      const tryLoad = async (path, names) => {
        try {
          const mod = await import(path);
          for (const n of names) {
            if (typeof window[n] === 'undefined' && typeof mod[n] !== 'undefined') {
              window[n] = mod[n];
            }
          }
        } catch (e) {
          // ignore
        }
      };

      await tryLoad('../three/examples/jsm/controls/OrbitControls.js', ['OrbitControls','MapControls']);
      await tryLoad('../three/examples/jsm/loaders/STLLoader.js', ['STLLoader']);
      await tryLoad('../three/examples/jsm/loaders/FontLoader.js', ['FontLoader']);
      await tryLoad('../three/examples/jsm/geometries/TextGeometry.js', ['TextGeometry']);
      await tryLoad('../three/examples/jsm/postprocessing/EffectComposer.js', ['EffectComposer']);
      await tryLoad('../three/examples/jsm/postprocessing/RenderPass.js', ['RenderPass']);
      await tryLoad('../three/examples/jsm/postprocessing/ShaderPass.js', ['ShaderPass']);
      await tryLoad('../three/examples/jsm/postprocessing/UnrealBloomPass.js', ['UnrealBloomPass']);
      await tryLoad('../three/examples/jsm/shaders/CopyShader.js', ['CopyShader']);
      await tryLoad('../three/examples/jsm/shaders/LuminosityHighPassShader.js', ['LuminosityHighPassShader']);

      return window.THREE;
    } catch (e) {
      console.warn('ensureThreeReady failed:', e);
      throw e;
    }
  })();

  return _threeReadyPromise;
}