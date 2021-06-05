git submodule update --init
cd habitat-sim
build_js.sh --no-web-apps
cd ../
cp habitat-sim/build_js/esp/bindings_js/hsim_bindings.js task/server_files/habitat_vr_app/lib/habitat-sim-js/
cp habitat-sim/build_js/esp/bindings_js/hsim_bindings.wasm task/server_files/habitat_vr_app/lib/habitat-sim-js/
