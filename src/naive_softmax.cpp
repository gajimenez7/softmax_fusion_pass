#include <cmath>

extern "C" {
/* softmax function implementation with over/underflow removal */
void softmax(float *__restrict input, float *__restrict output, int K) {

  /*
   * Softmax Function:
   * sigma(z)_i = (e^z_i - max(x))/(SUM(e^z_j for all j from 1 to K - max(x)))
   * Where z is tuple from z_i to z_K
   * and K is the number of elements in z
   */

  /* initialize memory variable values for hoisting */
  float max_val = -1e9;
  float sum_val = {0.0f};

  /* -- LOOP 1 -- */
  /* calculate max value of vector */
  for (int i = 0; i < K; i++) {
    double val = (double)input[i];
    if (val > max_val) {
      max_val = val;
    }
  }

  /* -- LOOP 2 -- */
  /* calculate exponent denominator */
  for (int i = 0; i < K; i++) {
    output[i] = expf(input[i] - max_val);
  }

  /* -- LOOP 3 -- */
  /* summation loop */
  for (int i = 0; i < K; i++) {
    sum_val += output[i];
  }

  /* -- LOOP 4 -- */
  float global_sum = sum_val;
  for (int i = 0; i < K; i++) {
    output[i] = output[i] / global_sum;
  }
}
}
