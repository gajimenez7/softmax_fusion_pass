# Softmax Fusion Pass

## Project Structure

```
.
├── build
│   ├── build.ninja
│   ├── pass
│   │   ├── libSoftmaxFusionPass.a
│   │   └── softmax-opt
│   ├── softmax.ll
│   ├── softmax_llvm.mlir
│   └── softmax.o
├── CMakeLists.txt
├── commands.txt
├── out
│   ├── bench_fused
│   ├── bench_original
│   ├── fused.ll
│   ├── fused_llvm.mlir
│   ├── fused.mlir
│   ├── fused.o
│   ├── fused.s
│   ├── naive_ftmax.ll
│   ├── naive_softmax.ll
│   ├── original.ll
│   ├── original_llvm.mlir
│   ├── original.o
│   ├── original.s
│   ├── softmax_driver
│   └── wrapper.o
├── pass
│   ├── CMakeLists.txt
│   ├── driver
│   │   └── SoftmaxOptTool.cpp
│   ├── SoftmaxFusion.cpp
│   └── SoftmaxFusion.h
├── README.md
├── run_pass.sh
└── src
    ├── fuse_softmax.mlir
    ├── naive_softmax.cpp
    ├── naive_softmax.mlir
    ├── optimized_1.mlir
    ├── original_naive_softmax.cpp
    ├── softmax_driver.cpp
    └── softmax_wrapper.cpp
```

## Building and Running

Build and Run commands exist in the `commands.txt` file.

Vector size and Benchmark interations can be changed when building with:

`-DVEC_SIZE=`
`-DBENCH_ITERATIONS=`

```
g++ -O3 -std=c++17 -DVEC_SIZE=10000 src/softmax_driver.cpp \
out/original.o -o out/bench_original -lm && ./out/bench_original
```
