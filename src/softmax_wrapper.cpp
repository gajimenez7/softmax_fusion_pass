#include <cstdint>

// MLIR-generated function with memref descriptor arguments
extern "C" {
// MLIR memref signature:
// allocated_ptr, aligned_ptr, offset, size, stride for each memref
void _mlir_ciface_softmax(float *input_allocated, float *input_aligned,
                          int64_t input_offset, int64_t input_size,
                          int64_t input_stride, float *output_allocated,
                          float *output_aligned, int64_t output_offset,
                          int64_t output_size, int64_t output_stride,
                          int32_t K);

// Simple wrapper that your benchmark expects
void softmax(float *input, float *output, int32_t K) {
  _mlir_ciface_softmax(input, input, 0, K, 1,   // input memref descriptor
                       output, output, 0, K, 1, // output memref descriptor
                       K);
}
}
