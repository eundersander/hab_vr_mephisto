# Overview

This is a simple Habitat VR app that lets a user view our `clothing_store` 3D scene in VR. It runs in any VR-compatible web browser, including the Oculus browser on Rift and Quest.

This is also a proof-of-concept for Mephisto integration. The Habitat VR app is entirely static client-side content (html, js, and data files). As such, the app is integrated into Mephisto here exactly as the existing Mephisto [simple_static_task example](https://github.com/facebookresearch/Mephisto/tree/master/examples/simple_static_task).

# Known Issues

- We are seeing an `alignfault` crash on Quest 2. Desktop browser VR emulation is unaffected. We speculate this is due to a recent Oculus browser update and a previously-hidden memory-alignment issue related to Emscripten and/or Magnum's TinyGLTF importer. We have a workaround for testing on Quest 2: strangely, you need to load the page while tethered to a desktop via ADB debugging (this avoids the crash). For a fix, we have some leads which we'll pursue as this project gets closer to deploying on Quest 2.

# Installation

1. Download and extract [data.zip](https://drive.google.com/file/d/1pwPUOar6ZSIdhVn9QpMH9KNSbQtarRDv/view?usp=sharing) as `task/server_files/habitat_vr_app/data/`.
1. Follow [instructions](https://github.com/facebookresearch/habitat-sim#experimental-emscripten-webgl-and-web-apps) for installing and activating Emscripten, including `source path/to/emsdk_env.sh` or similar to configure env variables.
1. `chmod +x build_and_install_habitat_sim_js.sh` and run `build_and_install_habitat_sim_js.sh`

# Testing

## VR emulation in your desktop browser, standalone (without Mephisto)

1. Http-serve the VR app folder:
```
cd task/server_files/habitat_vr_app
python3 -m http.server
```
2. Install the [WebXR emulator](https://blog.mozvr.com/webxr-emulator-extension/) and then restart your browser.
1. Browse to `http://0.0.0.0:8000/standalone.html`
1. Recommended: watch the dev console as the page loads.
1. Once loading is complete, click "Enter VR". You should see a stereo 3D view of our `clothing_store` scene.
1. In Chrome Developer Tools, find the WebXR tab. From the device list, select Oculus Quest or similar. In the WebXR panel's 3D view, move the headset or controllers to emulate the VR experience.
1. At the bottom of the WebXR tab, click "Exit immersive".
1. Observe the logged head poses in the html textarea.

## As a Mephisto simple static task
1. Follow Mephisto [Getting Started](https://github.com/facebookresearch/mephisto/blob/master/docs/quickstart.md).
2. Run `python3 task/static_test_script.py`.
3. Watch the console output for something like:
```
Mock task launched: localhost:3000 for preview, localhost:3000/?worker_id=x&assignment_id=0
```
4. Browse to the specified URL and follow the earlier instructions for VR emulation in your browser.
5. After exiting immersive VR, click to submit the task, including logged head poses.

## VR on Quest 2 (or other headset)
1. Using a modification of either method above, serve the content at a public URL. For example, you could upload the `task/server_files/habitat_vr_app` folder to Amazon S3 or any web host.
1. On Quest 2, open the browser and navigate to the URL. Use the Quest controller to click "Enter VR".
1. Exit immersive VR with the Quest 2 controller's home button.
1. (Mephisto-only) Click to submit the task, including logged head poses.

# Troubleshooting

If you encounter Habitat-sim build errors, make sure you have Emscripten properly installed and activated. Delete the build output folders (`habitat-sim/build_corrade-rc` and `habitat-sim/build_js`) and rebuild. 

If the VR app fails to load in your desktop browser, look for errors in the browser dev console. Make sure you have data files installed properly, e.g. `task/server_files/habitat_vr_app/data/stages/clothing_store_optimized.glb`. Make sure the WebXR emulator is installed and accessible (e.g. as a tab in Chrome Developer Tools).

# Project folder structure

`task` mirrors the structure of the Mephisto [simple_static_task example](https://github.com/facebookresearch/Mephisto/tree/master/examples/simple_static_task).

`task/server_files/habitat_vr_app` is a mostly-standalone Habitat web app.

`task/server_files/habitat_vr_app/data` contains the VR app's data files. These are 3D models and metadata files used by the simulator. They include a version of our `clothing_store` scene optimized for rendering on Quest 2.

`task/server_files/habitat_vr_app/standalone.html` and `task/server_files/habitat_vr_task.html` are nearly identical. `standalone.html` is a full html page for hosting the VR app without Mephisto. `habitat_vr_task.html` is an html snippet which becomes part of the Mephisto task (see `task/conf/example.yaml`).

`habitat-sim` is the Habitat-sim repo as a git submodule. See details below.

# Habitat-sim JS build

The Habitat-sim JS build is a webassembly build of the Habitat simulator. It's built by compiling Habitat-sim C++ code to webassembly using the Emscripten compiler. The build outputs are `hsim_bindings.js` and `hsim_bindings.wasm`. `hsim_bindings.js` can be included from Javascript and you can call into the simulator via the bindings defined in `habitat-sim/src/esp/bindings_js/bindings_js.cpp`.

The Habitat-sim JS build doesn't currently have an installer, so we can't get it from npm, conda, pip, or similar. We've added habitat-sim as a git submodule at `habitat-sim` and build it locally to produce `hsim_bindings.js` and `hsim_bindings.wasm`. We copy those files to `task/server_files/habitat_vr_app/lib/habitat-sim-js/` as a post-build step in `build_and_install_habitat_sim_js.sh`.

We're currently using the [for-web-apps](https://github.com/facebookresearch/habitat-sim/tree/for-web-apps) branch. It has a few minor fixes for web/VR that aren't yet in `master`.

In the future, we may also utilize some JS utilities provided as .js files inside Habitat-sim; those can be symlinked or copied from the Habitat-sim source folders to `task/server_files/habitat_vr_app/lib/habitat-sim-js/`.