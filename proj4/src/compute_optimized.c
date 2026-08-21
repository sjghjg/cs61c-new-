#include <omp.h>
#include <x86intrin.h>

#include "compute.h"
// run thse two cmd to output blur img
// python3 tools/create_tests.py test_gif_kachow_blur
// make task_2 TEST=tests/test_gif_kachow_blur

// run thse two cmd to output sharpen img
// python3 tools/create_tests.py test_gif_kachow_sharpen
// make task_2 TEST=tests/test_gif_kachow_sharpen

// Computes the convolution of two matrices
int convolve(matrix_t *a_matrix, matrix_t *b_matrix, matrix_t **output_matrix) {
  // TODO: convolve matrix a and matrix b, and store the resulting matrix in
  // output_matrix
  uint32_t b_rows = b_matrix->rows;
  uint32_t b_cols = b_matrix->cols;
  uint32_t a_rows = a_matrix->rows;
  uint32_t a_cols = a_matrix->cols;
  int32_t* data_bmatrix = b_matrix->data;

  int32_t* flipped_bdata = malloc(sizeof(int32_t) * b_cols * b_rows);
  if (flipped_bdata == NULL){
    return -1;
  }

  for (uint32_t r = 0; r < b_rows; r++){
    for (uint32_t c = 0; c < b_cols; c++){
      flipped_bdata[r * b_cols + c] = data_bmatrix[(b_rows -1 -r)*b_cols + (b_cols -1 -c)];
    }
  }

  uint32_t output_rows =  a_rows - b_rows +1;
  uint32_t output_cols = a_cols - b_cols +1;

  *output_matrix = malloc(sizeof(matrix_t));
  if (*output_matrix == NULL){
    free(flipped_bdata);
    return -1;
  }

  (*output_matrix)->rows = output_rows;
  (*output_matrix)->cols = output_cols;
  (*output_matrix)->data = malloc(sizeof(int32_t) * output_rows * output_cols);
  if ((*output_matrix)->data == NULL){
    free(*output_matrix);
    free(flipped_bdata);
    return -1;
  }

  # pragma omp parallel for
  for(uint32_t out_r = 0; out_r< output_rows; out_r++){
    for (uint32_t out_c = 0; out_c< output_cols; out_c++){
      // sum = 0;
      __m256i sum0 = _mm256_setzero_si256();
      __m256i sum1 = _mm256_setzero_si256();
      __m256i head_sum = _mm256_setzero_si256();
      int32_t tail_sum = 0;
      for (uint32_t x = 0; x < b_rows; x++){
        uint32_t a_r = x + out_r;
        int y = 0;

        for (; y+15 < b_cols; y+=16){
          uint32_t a_c = y + out_c;
          __m256i a_val0 = _mm256_loadu_si256((__m256i *) &a_matrix->data[a_r * a_cols + a_c]);
          __m256i b_val0 = _mm256_loadu_si256((__m256i*) &flipped_bdata[x * b_cols + y]);
          __m256i prod0 = _mm256_mullo_epi32(a_val0, b_val0);
          sum0 = _mm256_add_epi32(sum0, prod0);

          __m256i a_val1 = _mm256_loadu_si256((__m256i *) &a_matrix->data[a_r * a_cols + a_c+8]);
          __m256i b_val1 = _mm256_loadu_si256((__m256i*) &flipped_bdata[x * b_cols + y+8]);
          __m256i prod1 = _mm256_mullo_epi32(a_val1, b_val1);
          sum1 = _mm256_add_epi32(sum1, prod1);
        }

        for (; y+7 < b_cols; y+=8){
          uint32_t a_c = y + out_c;
          __m256i a_val = _mm256_loadu_si256((__m256i *) &a_matrix->data[a_r * a_cols + a_c]);
          __m256i b_val = _mm256_loadu_si256((__m256i*) &flipped_bdata[x * b_cols + y]);
          __m256i prod = _mm256_mullo_epi32(a_val, b_val);
          sum0 = _mm256_add_epi32(sum0, prod);
        }

        head_sum = _mm256_add_epi32(sum0, sum1);
        for (;y < b_cols; y++){
          uint32_t a_c = y + out_c;
          int32_t a_val = a_matrix->data[a_r * a_cols + a_c];
          int32_t b_val = flipped_bdata[x * b_cols + y];
          tail_sum += a_val * b_val;
        }
      }
      
      int32_t tmp_sum[8];
      _mm256_storeu_si256((__m256i *) tmp_sum, head_sum);
      int sum = tail_sum + tmp_sum[0] + tmp_sum[1] + tmp_sum[2] + tmp_sum[3] + tmp_sum[4] + tmp_sum[5] + tmp_sum[6] + tmp_sum[7];
      (*output_matrix)->data[out_r * output_cols + out_c] = sum;
    }
  }
  free(flipped_bdata);
  return 0;
}

// Executes a task
int execute_task(task_t *task) {
  matrix_t *a_matrix, *b_matrix, *output_matrix;

  char *a_matrix_path = get_a_matrix_path(task);
  if (read_matrix(a_matrix_path, &a_matrix)) {
    printf("Error reading matrix from %s\n", a_matrix_path);
    return -1;
  }
  free(a_matrix_path);

  char *b_matrix_path = get_b_matrix_path(task);
  if (read_matrix(b_matrix_path, &b_matrix)) {
    printf("Error reading matrix from %s\n", b_matrix_path);
    return -1;
  }
  free(b_matrix_path);

  if (convolve(a_matrix, b_matrix, &output_matrix)) {
    printf("convolve returned a non-zero integer\n");
    return -1;
  }

  char *output_matrix_path = get_output_matrix_path(task);
  if (write_matrix(output_matrix_path, output_matrix)) {
    printf("Error writing matrix to %s\n", output_matrix_path);
    return -1;
  }
  free(output_matrix_path);

  free(a_matrix->data);
  free(b_matrix->data);
  free(output_matrix->data);
  free(a_matrix);
  free(b_matrix);
  free(output_matrix);
  return 0;
}
