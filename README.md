# Overview

This is a simple Habitat VR app that lets a user view our `clothing_store` 3D scene in VR. It runs in any VR-compatible web browser, including the Oculus browser on Rift and Quest.

This is also a proof-of-concept for Mephisto integration. The Habitat VR app is entirely static client-side content (html, js, and data files). As such, the app is integrated into Mephisto here exactly as the existing Mephisto [simple_static_task example](https://github.com/facebookresearch/Mephisto/tree/master/examples/simple_static_task).

# Installation

1. Download TODO:link to `task/server_files/habitat_vr_app/data`.

1. Follow [instructions](https://github.com/facebookresearch/habitat-sim#experimental-emscripten-webgl-and-web-apps) for installing and activating Emscripten.

1. Run `build_and_install_habitat_sim_js.sh`

# Testing

## VR emulation in your desktop browser (without Mephisto)

1. Http-serve the VR app folder:
```
cd task/server_files/habitat_vr_app
python3 -m http.server
```
1. Install the [WebXR emulator](https://blog.mozvr.com/webxr-emulator-extension/).
1. Browse to `http://0.0.0.0:8000/`
1. Recommended: watch the dev console as the page loads.
1. Once loading is complete, click "Enter VR". You should see a stereo 3D view of our `clothing_store` scene.
1. In Chrome Developer Tools, find the WebXR tab. Move the headset or controllers to emulate the VR experience.

## As a Mephisto simple static task
1. Follow Mephisto [Getting Started](https://github.com/facebookresearch/mephisto/blob/master/docs/quickstart.md).
1. Run `python3 task/static_test_script.py`.
1. Watch the console output for something like:
```
Mock task launched: localhost:3000 for preview, localhost:3000/?worker_id=x&assignment_id=0
```
1. Browse to the specified URL and follow the earlier instructions for VR emulation in your browser.

## VR on Quest 2 (or other headset)
1. Using a modification of either method above, serve the content to a public URL. For example, you could upload the `task/server_files/habitat_vr_app` folder to Amazon S3 or any web host.
1. On Quest 2, open the browser and navigate to the URL. Use the Quest controller to click the "Enter VR" button.

# Project structure

`./task` mirrors the structure of the Mephisto [simple_static_task example](https://github.com/facebookresearch/Mephisto/tree/master/examples/simple_static_task).

`./task/server_files/habitat_vr_app` is a mostly-standalone Habitat web app. The initial version doesn't do any communication with the Mephisto backend, but we can imagine extending it to pass collected data such as headset movement to the backend, either continuously or in a single batch at the end of the VR session.

`task/server_files/habitat_vr_app/data` contains the VR app's data files. These are 3D models and metadata files used by the simulator. They include a version of our `clothing_store` scene optimized for rendering on Quest 2.

`./habitat-sim` is the Habitat-sim repo as a git submodule. See details below.

# Habitat-sim JS build

The Habitat-sim JS build is a webassembly build of the Habitat simulator. It's built by compiling Habitat-sim C++ code to webassembly using the Emscripten compiler. The build outputs are `hsim_bindings.js` and `hsim_bindings.wasm`. `hsim_bindings.js` can be included from Javascript and you can call into the simulator via the bindings defined in `habitat-sim/src/esp/bindings_js/bindings_js.cpp`.

The Habitat-sim JS build doesn't currently have an installer, so we can't get it from npm, conda, pip, or similar. We'll add habitat-sim as a git submodule at `./habitat-sim` and build it locally to produce `hsim_bindings.js` and `hsim_bindings.wasm`. We copy those files to `task/server_files/habitat_vr_app/lib/habitat-sim-js/` as a post-build step in `build_and_install_habitat_sim_js.sh`.

In the future, we may also utilize some JS utilities provided as .js files inside Habitat-sim; those can be symlinked or copied from the Habitat-sim source folders to `task/server_files/habitat_vr_app/lib/habitat-sim-js/`.