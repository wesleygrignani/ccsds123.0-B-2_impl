//
// Created by Wesley Grignani
//

#ifndef SAMPLE_ADAPTATIVE_H
#define SAMPLE_ADAPTATIVE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include <ap_cint.h>

// Spectral bands in image
#define BANDS 5

// Unary length limit shall be an integer in the range 8 to 32
#define UMAX 8

// Initial count exponent shall be an integer in the range 1 to 8
#define INI_COUNT_EXP 1

// Dynamic range
#define DYNAMIC_RANGE 16

// Rescaling counter size parameter
#define RESCALING_COUNTER_SIZE 4

// Accumulator initialization constant
#define ACCUMULATOR_INIT 7

//
#define M 3

// Number of bands, rows and columns of the image and its used for prediction
#define NBANDS 5
#define NROWS 5
#define NCOLS 5


void write_bits(int data, int size);
int encode_sample(uint16_t counter[BANDS], uint16_t accumulator[BANDS], uint16_t t, uint16_t z, uint16_t mapped, uint16_t *bits_written);
void write_bits_mapped(int data, int size);
void write_bits_mapped2(int data, int size);
void write_headers(uint16_t *bits_written);
unsigned int mlog2( unsigned int x );

#endif //SAMPLE_ADAPTATIVE_H
