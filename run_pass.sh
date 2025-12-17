#!/usr/bin/bash

ninja -C build && \
./build/pass/softmax-opt --canonicalize --cse --softmax-fusion ./src/naive_softmax.mlir
