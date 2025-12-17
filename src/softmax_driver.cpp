#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <random>
#include <sys/types.h>

#ifndef VEC_SIZE
#define VEC_SIZE 1024
#endif

/* number of benchmark iterations */
#ifndef BENCH_ITERATIONS
#define BENCH_ITERATIONS 1000
#endif

/* MLIR-generated softmax with memref descriptor arguments */
extern "C" {
void softmax(float *input_allocated, float *input_aligned, int64_t input_offset,
             int64_t input_size, int64_t input_stride, float *output_allocated,
             float *output_aligned, int64_t output_offset, int64_t output_size,
             int64_t output_stride, int32_t K);
}

/* wrapper for easier calling */
void call_softmax(float *input, float *output, int32_t size) {
  softmax(input, input, 0, size,
          1, // input memref: allocated, aligned, offset, size, stride
          output, output, 0, size,
          1,     // output memref: allocated, aligned, offset, size, stride
          size); // K parameter
}
/* helper function to print global vector size */
void print_vector_size() {
  std::cout << "Defined Vector Size: " << VEC_SIZE << "\n\n";
}

/* helper printer function */
void print_vector(float *vector_to_print, std::string vector_name) {
  std::cout << vector_name << ":\n";
  std::cout << "(";
  for (int i = 0; i < VEC_SIZE; i++) {
    std::cout << vector_to_print[i];

    if (i + 1 != VEC_SIZE) {
      std::cout << ", ";
    }
  }
  std::cout << ")\n\n";
}

/* verify softmax output - sum should be approximately 1.0 */
bool verify_softmax(float *output) {
  double sum = 0.0;
  double min_val = output[0];
  double max_val = output[0];

  for (int i = 0; i < VEC_SIZE; i++) {
    sum += output[i];
    if (output[i] < min_val)
      min_val = output[i];
    if (output[i] > max_val)
      max_val = output[i];
  }

  double tolerance = 0.0001;
  if (VEC_SIZE > 100000) {
    tolerance = 0.001; /* 0.1% tolerance for large arrays */
  }
  bool valid = (sum > (1.0 - tolerance) && sum < (1.0 + tolerance));

  std::cout << "Verification:\n";
  std::cout << "  Sum of probabilities: " << std::fixed << std::setprecision(10)
            << sum << "\n";
  std::cout << "  Min value: " << std::scientific << std::setprecision(6)
            << min_val << "\n";
  std::cout << "  Max value: " << std::scientific << std::setprecision(6)
            << max_val << "\n";
  std::cout << "  Status: " << (valid ? "PASS ✓" : "FAIL ✗") << "\n\n";

  return valid;
}

void run_softmax_function(float *input, float *output) {
  call_softmax(input, output, VEC_SIZE);
}

/* create a logit vector of size VEC_SIZE */
float *create_logit_vector(double noise_thresh) {
  double score = 10.0;
  float *logit_vector = (float *)(malloc(VEC_SIZE * sizeof(float)));

  /* random with fixed seed for reproducibility */
  std::mt19937 gen(42);

  /* generate noise */
  std::normal_distribution<> noise_dist(-noise_thresh, noise_thresh);

  /* fill vector with noise */
  for (int i = 0; i < VEC_SIZE; i++) {
    logit_vector[i] = noise_dist(gen);
  }

  /* pick winning index to be "selected probability" */
  std::uniform_int_distribution<> index_dist(0, VEC_SIZE - 1);
  int winning_indx = index_dist(gen);

  logit_vector[winning_indx] += score;

  return logit_vector;
}

/* benchmark the softmax function */
double benchmark_softmax(float *input, float *output, int iterations) {
  /* warmup run */
  call_softmax(input, output, VEC_SIZE);

  /* timed benchmark */
  auto start = std::chrono::high_resolution_clock::now();

  for (int i = 0; i < iterations; i++) {
    call_softmax(input, output, VEC_SIZE);
  }

  auto end = std::chrono::high_resolution_clock::now();

  /* calculate average time in microseconds */
  auto duration =
      std::chrono::duration_cast<std::chrono::nanoseconds>(end - start);
  double avg_time_us = duration.count() / (double)iterations / 1000.0;

  return avg_time_us;
}

/* calculate memory throughput in GB/s */
double calculate_throughput(double time_us) {
  /* read input array + write output array */
  size_t bytes_transferred = VEC_SIZE * sizeof(float) * 2;
  double seconds = time_us / 1e6;
  double gb_per_second = (bytes_transferred / seconds) / 1e9;
  return gb_per_second;
}

int main(int argc, char **argv) {
  double threshold = 2.0;
  print_vector_size();

  std::cout << "Benchmark iterations: " << BENCH_ITERATIONS << "\n\n";

  /* initialize and print a test vector */
  float *initial_vector = create_logit_vector(threshold);
  print_vector(initial_vector, "Initial Vector");

  /* initialize, process, and print a softmax processed vector */
  float *softmax_vector = (float *)(malloc(VEC_SIZE * sizeof(float)));
  run_softmax_function(initial_vector, softmax_vector);
  print_vector(softmax_vector, "Softmax Vector");

  /* verify correctness */
  if (!verify_softmax(softmax_vector)) {
    std::cerr << "ERROR: Softmax verification failed!\n";
    free(initial_vector);
    free(softmax_vector);
    return 1;
  }

  /* run performance benchmark */
  std::cout << "Running performance benchmark...\n";
  double avg_time_us =
      benchmark_softmax(initial_vector, softmax_vector, BENCH_ITERATIONS);
  double throughput = calculate_throughput(avg_time_us);

  /* print performance results */
  std::cout << "Performance Results:\n";
  std::cout << std::fixed << std::setprecision(3);
  std::cout << " -> Average time:      " << std::setw(10) << avg_time_us
            << " micro seconds\n";
  std::cout << " -> Throughput:        " << std::setw(10) << throughput
            << " GB/s\n";
  std::cout << " -> Elements/sec:      " << std::setw(10) << std::scientific
            << (VEC_SIZE / (avg_time_us / 1e6)) << "\n";
  std::cout << "========================================\n\n";

  free(initial_vector);
  free(softmax_vector);

  return 0;
}
