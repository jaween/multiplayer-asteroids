#!/usr/bin/env bash
rm -r build
mkdir build
dart2js -O0 -o build/out.js dart/main.dart
cat js/dart_main_runner.js js/node_preamble.js build/out.js > build/main.js
rm build/out.*
