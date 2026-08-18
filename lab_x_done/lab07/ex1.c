#include <time.h>
#include <stdio.h>
#include <x86intrin.h>
#include "ex1.h"

long long int sum(int vals[NUM_ELEMS]) {
    clock_t start = clock();

    long long int sum = 0;
    for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
        for(unsigned int i = 0; i < NUM_ELEMS; i++) {
            if(vals[i] >= 128) {
                sum += vals[i];
            }
        }
    }
    clock_t end = clock();
    printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
    return sum;
}

long long int sum_unrolled(int vals[NUM_ELEMS]) {
    clock_t start = clock();
    long long int sum = 0;

    for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
        for(unsigned int i = 0; i < NUM_ELEMS / 4 * 4; i += 4) {
            if(vals[i] >= 128) sum += vals[i];
            if(vals[i + 1] >= 128) sum += vals[i + 1];
            if(vals[i + 2] >= 128) sum += vals[i + 2];
            if(vals[i + 3] >= 128) sum += vals[i + 3];
        }

        // TAIL CASE, for when NUM_ELEMS isn't a multiple of 4
        // NUM_ELEMS / 4 * 4 is the largest multiple of 4 less than NUM_ELEMS
        // Order is important, since (NUM_ELEMS / 4) effectively rounds down first
        for(unsigned int i = NUM_ELEMS / 4 * 4; i < NUM_ELEMS; i++) {
            if (vals[i] >= 128) {
                sum += vals[i];
            }
        }
    }
    clock_t end = clock();
    printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
    return sum;
}

long long int sum_simd(int vals[NUM_ELEMS]) {
    clock_t start = clock();
    __m128i _127 = _mm_set1_epi32(127); // This is a vector with 127s in it... Why might you need this?
    long long int result = 0; // This is where you should put your final result!
    /* DO NOT MODIFY ANYTHING ABOVE THIS LINE (in this function) */

    for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
        /* YOUR CODE GOES HERE */
        __m128i sum_vec = _mm_setzero_si128();
        unsigned int size_padded = NUM_ELEMS / 4 * 4;
        for (unsigned int i = 0; i < size_padded; i+=4){
            __m128i tmp = _mm_loadu_si128((__m128i *) (vals+i));
            __m128i mask = _mm_cmpgt_epi32(tmp, _127);
            __m128i check_vals = _mm_and_si128(tmp, mask);
            sum_vec = _mm_add_epi32(sum_vec, check_vals);
        }
    /* Hint: you'll need a tail case. */
    int tmp_arr[4];
    _mm_storeu_si128((__m128i *)tmp_arr, sum_vec);
    result += (tmp_arr[0] + tmp_arr[1] + tmp_arr[2] + tmp_arr[3]);

    for (int i =size_padded; i < NUM_ELEMS; i++){
        if (vals[i] >= 128){
            result += vals[i];
        }
    }
    }

    /* DO NOT MODIFY ANYTHING BELOW THIS LINE (in this function) */
    clock_t end = clock();
    printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
    return result;
}

long long int sum_simd_unrolled(int vals[NUM_ELEMS]) {
    clock_t start = clock();
    __m128i _127 = _mm_set1_epi32(127);
    long long int result = 0;
    /* DO NOT MODIFY ANYTHING ABOVE THIS LINE (in this function) */

    for(unsigned int w = 0; w < OUTER_ITERATIONS; w++) {
        /* YOUR CODE GOES HERE */
        int size_vec = 4;
        int unrolled = 4;
        unsigned int block_size = size_vec * unrolled;
        __m128i sum_vec = _mm_setzero_si128();
        unsigned int size_padded = NUM_ELEMS / block_size * block_size;
        for (unsigned int i = 0; i < size_padded; i+=block_size){
            __m128i tmp0 = _mm_loadu_si128((__m128i *) (vals+i));
            __m128i mask0 = _mm_cmpgt_epi32(tmp0, _127);
            __m128i v0 = _mm_and_si128(tmp0, mask0);
            sum_vec = _mm_add_epi32(sum_vec, v0);

            __m128i tmp1 = _mm_loadu_si128((__m128i *) (vals+i+4));
            __m128i mask1 = _mm_cmpgt_epi32(tmp1, _127);
            __m128i v1 = _mm_and_si128(tmp1, mask1);
            sum_vec = _mm_add_epi32(sum_vec, v1);

            __m128i tmp2 = _mm_loadu_si128((__m128i *) (vals+i+8));
            __m128i mask2 = _mm_cmpgt_epi32(tmp2, _127);
            __m128i v2 = _mm_and_si128(tmp2, mask2);
            sum_vec = _mm_add_epi32(sum_vec, v2);

            __m128i tmp3 = _mm_loadu_si128((__m128i *) (vals+i+12));
            __m128i mask3 = _mm_cmpgt_epi32(tmp3, _127);
            __m128i v3 = _mm_and_si128(tmp3, mask3);
            sum_vec = _mm_add_epi32(sum_vec, v3);
        }
    /* Hint: you'll need a tail case. */
    int tmp_arr[4];
    _mm_storeu_si128((__m128i *)tmp_arr, sum_vec);
    result += (tmp_arr[0] + tmp_arr[1] + tmp_arr[2] + tmp_arr[3]);

    for (int i =size_padded; i < NUM_ELEMS; i++){
        if (vals[i] >= 128){
            result += vals[i];
        }
    }
        /* Copy your sum_simd() implementation here, and unroll it */

        /* Hint: you'll need 1 or maybe 2 tail cases here. */
    }

    /* DO NOT MODIFY ANYTHING BELOW THIS LINE (in this function) */
    clock_t end = clock();
    printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
    return result;
}
