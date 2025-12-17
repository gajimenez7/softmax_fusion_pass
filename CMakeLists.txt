cmake_minimum_required(VERSION 4.2.0)
project(SoftmaxFusionOptimization)

set(MLIR_DIR /usr/local/lib/cmake/mlir)
set(LLVM_DIR /usr/local/lib/cmake/llvm)

find_package(MLIR REQUIRED CONFIG)
find_package(LLVM REQUIRED CONFIG)

list(APPEND CMAKE_MODULE_PATH "${MLIR_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")

include(TableGen)
include(AddLLVM)
include(AddMLIR)

include_directories(${MLIR_INCLUDE_DIRS})
include_directories(${LLVM_INCLUDE_DIRS})

link_directories(${LLVM_BUILD_LIBRARY_DIR})
add_definitions(${LLVM_DEFINITIONS})

add_subdirectory(pass)
