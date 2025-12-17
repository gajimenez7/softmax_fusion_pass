#include <cmath>

/* helper exp_sum function */
extern "C" {
// double exp_sum(const float *z, double max_ptr, const int K) {
//   double return_exp_sum = 0;
//   for (int i = 0; i < K; i++) {
//     return_exp_sum += std::exp((double)z[i] - max_ptr);
//   }
//   return return_exp_sum;
// }
//
// /* helper function to calculate max value */
// double calculate_max_ptrue(const float *input, const int K) {
//   double max_ptr = -1e9;
//
//   for (int i = 0; i < K; i++) {
//     double val = (double)input[i];
//     if (val > max_ptr) {
//       max_ptr = val;
//     }
//   }
//
//   return max_ptr;
// }

/* softmax function implementation with over/underflow removal */
float *softmax(const float *input, float *output, float *sum_storage,
               float *max_ptr, const int K) {

  /*
   * Softmax Function:
   * sigma(z)_i = (e^z_i - max(x))/(SUM(e^z_j for all j from 1 to K - max(x)))
   * Where z is tuple from z_i to z_K
   * and K is the number of elements in z
   */

  /* initialize memory variable values for hoisting */
  max_ptr[0] = -1e9;
  sum_storage[0] = 0.0f;

  /* calculate max value of vector */

  for (int i = 0; i < K; i++) {
    double val = (double)input[i];
    if (val > max_ptr[0]) {
      max_ptr[0] = val;
    }
  }

  /* calculate exponent denominator */
  double denominator = 0;
  for (int i = 0; i < K; i++) {
    output[i] += std::exp((double)input[i] - max_ptr[0]);
  }

  /* summation loop */
  for (int i = 0; i < K; i++) {
    sum_storage[0] = output[i];
  }

  float global_sum = sum_storage[0];
  for (int i = 0; i < K; i++) {
    output[i] += output[i] / global_sum;
  }
  return output;
}
}
