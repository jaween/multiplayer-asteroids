#!/usr/bin/env bash
rm -r build
mkdir build
dart2js -O3 -o build/out.js dart/lib/main.dart
cat js/dart_main_runner.js build/out.js > build/main.js
rm build/out.*

webpack --mode=production build/main.js
rm build/main.js
