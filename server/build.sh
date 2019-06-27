#!/usr/bin/env bash
mkdir -p build

if [ "$1" = "--release" ];
then
  dart2js -O2 -o build/out.js dart/main.dart
elif [ "$1" = "" ]
then
  dart2js -O0 -o build/out.js dart/main.dart
else
  echo "Invalid parameter $1"
  exit 1
fi
cat js/dart_main_runner.js js/node_preamble.js build/out.js > build/main.js