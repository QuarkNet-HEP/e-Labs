// (c) Dean McNamee <dean@gmail.com>, Dec 2008.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// This file implements helpers you might want to use when making a demo.  It
// mostly consists of UI helpers, like a toolbar for toggling modes, mouse
// and camera handling, etc.

DemoUtils = (function() {

  function min(a, b) {
    if (a < b) return a;
    return b;
  }

  function max(a, b) {
    if (a > b) return a;
    return b;
  }

  // Keep c >= a && c <= b.
  function clamp(a, b, c) {
    return min(b, max(a, c));
  }

  // A Ticker helps you keep a beat, calling a callback based on a target
  // frames-per-second.  You can stop and start the ticker, change the step
  // size, etc.  Your callback will be passed the frame number.
  function Ticker(fps, callback) {
    this.interval_ms_ = 1000 / fps;
    this.callback_ = callback;
    this.t_ = 0;
    this.step_ = 1;
    this.interval_handle_ = null;
  }

  Ticker.prototype.isRunning = function() {
    return this.interval_handle_ !== null;
  };

  Ticker.prototype.start = function(fps, callback) {
    if (this.isRunning())
      return;

    var self = this;
    this.interval_handle_ = setInterval(function() {
      var callback = self.callback_;
      callback(self.t_);
      self.t_ += self.step_;
    }, this.interval_ms_);
  };

  Ticker.prototype.stop = function() {
    if (!this.isRunning())
      return;

    clearInterval(this.interval_handle_);
    this.interval_handle_ = null;
  };

  Ticker.prototype.set_t = function(t) {
    this.t_ = t;
  };

  Ticker.prototype.set_step = function(step) {
    this.step_ = step;
  };

  Ticker.prototype.reverse_step_direction = function() {
    this.step_ = -this.step_;
  };

  // Registers some mouse listeners on a <canvas> element, to help you with
  // things like dragging, clicking, etc.  Your callback will get called on
  // any mouse movement, with info / state about the mouse.
  function registerMouseListener(canvas, listener) {
    var state = {
      first_event: true,
      is_clicking: false,
      last_x: 0,
      last_y: 0,
    };

    function relXY(e) {
      if (typeof e.offsetX == 'number')
        return {x: e.offsetX, y: e.offsetY};

      // TODO this is my offsetX/Y emulation for Firefox.  I'm not sure it is
      // exactly right, but it seems to work ok, including scroll, etc.
      var off = {x: 0, y: 0};
      var node = e.target;
      var pops = node.offsetParent;
      if (pops) {
        off.x += node.offsetLeft - pops.offsetLeft;
        off.y += node.offsetTop - pops.offsetTop;
      }

      return {x: e.layerX - off.x, y: e.layerY - off.y};
    }

    canvas.addEventListener('mousedown', function(e) {
      var rel = relXY(e);
      state.is_clicking = true;
      state.last_x = rel.x;
      state.last_y = rel.y
    }, false);

    canvas.addEventListener('mouseup', function(e) {
      state.is_clicking = false;
    }, false);

    canvas.addEventListener('mouseout', function(e) {
      state.is_clicking = false;
    }, false);

    canvas.addEventListener('mousemove', function(e) {
      var rel = relXY(e);
      var delta_x = state.last_x - rel.x;
      var delta_y = state.last_y - rel.y;

      // TODO: I'd like to use offsetX here, but it doesn't exist in Firefox.
      // I should make a shim, but you have to do some DOM walking...
      state.last_x = rel.x;
      state.last_y = rel.y;

      // We need one event to get calibrated.
      if (state.first_event) {
        state.first_event = false;
        return;
      }

      var info = {
        is_clicking: state.is_clicking,
        canvas_x: state.last_x,
        canvas_y: state.last_y,
        delta_x: delta_x,
        delta_y: delta_y,
        shift: e.shiftKey,
        ctrl: e.ctrlKey
      };

      listener(info);
    }, false);
  }

  // Register mouse handlers to automatically handle camera:
  //   Mouse -> rotate around origin x and y axis.
  //   Mouse + ctrl -> pan x / y.
  //   Mouse + shift -> pan z.
  //   Mouse + ctrl + shift -> adjust focal length.
  function autoCamera(renderer, ix, iy, iz, tx, ty, tz, draw_callback) {
    var camera_state = {
      rotate_x: tx,
      rotate_y: ty,
      rotate_z: tz,
      x: ix,
      y: iy,
      z: iz
    };

    function set_camera() {
      var ct = renderer.camera.transform;
      ct.reset();
      ct.rotateZ(camera_state.rotate_z);
      ct.rotateY(camera_state.rotate_y);
      ct.rotateX(camera_state.rotate_x);
      ct.translate(camera_state.x, camera_state.y, camera_state.z);
    }

    registerMouseListener(renderer.canvas, function(info) {
      if (!info.is_clicking) {
    	  return;
      }

      if (info.shift && info.ctrl) {
    	  renderer.camera.focal_length = clamp(0.05, 10,
    			  renderer.camera.focal_length + (info.delta_y * 0.01));
      }
      else if (info.shift) {
    	  camera_state.z += info.delta_y * 0.1;
      }
      else if (info.ctrl) {
    	  camera_state.x -= info.delta_x * 0.01;
    	  camera_state.y -= info.delta_y * 0.01;
      }
      else {
    	  camera_state.rotate_y -= info.delta_x * 0.01;
    	  camera_state.rotate_x -= info.delta_y * 0.01;
      }
      
      
      draw_callback();
    });

    // Set up the initial camera.
    set_camera();
    return camera_state;
  }

  function ToggleToolbar() {
    this.options_ = [ ];
  }

  ToggleToolbar.prototype.addEntry = function(text, initial, callback) {
    this.options_.push([text, !!initial, callback]);
  };

  ToggleToolbar.prototype.populateDiv = function(div) {
    var options = this.options_;
    for (var i = 0, il = options.length; i < il; ++i) {
      var option = options[i];
      var name = option[0];
      var checked = option[1];
      var handler = option[2];
      var span = document.createElement('span');
      span.style.marginRight = '20px';
      var cb = document.createElement('input');
      cb.type = 'checkbox';
      if (checked)
        cb.checked = true;
      cb.addEventListener('change', handler, false);
      span.appendChild(cb);
      span.appendChild(document.createTextNode(' ' + name));
      div.appendChild(span);
    }
  };

  ToggleToolbar.prototype.createBefore = function(element) {
    var div = document.createElement('div');
    this.populateDiv(div);
    var pops = element.parentNode;
    pops.insertBefore(div, pops.firstChild);
  };

  return {
    Ticker: Ticker,
    registerMouseListener: registerMouseListener,
    autoCamera: autoCamera,
    ToggleToolbar: ToggleToolbar,
  };
})();
