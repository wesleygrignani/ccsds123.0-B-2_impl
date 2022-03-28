//
// Created by Wesley Grignani
//

#ifndef PREDICTOR_H
#define PREDICTOR_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include <ap_cint.h>

// Bands of predictions shall be an integer in the range 0 <= P <= 15
#define P 5

// Dynamic size of sample
#define D 16

// OMEGA constant
#define OMEGA 8

// Size of sample
#define SAMPLE_SIZE 16

// Quantizer fidelity control - Utilized for near-lossless compression (error control)
#define mz 0

#define V_MIN 5
#define V_MAX 9
#define T_INC 6

// Number of bands, rows and columns of the image and its used for prediction
#define NBANDS 5
#define NROWS 5
#define NCOLS 5

// Maximum and medium value of a sample size used
#define SMAX pow(2, SAMPLE_SIZE) - 1
#define SMID pow(2, SAMPLE_SIZE -1)

//
#define W_MAX pow(2, OMEGA + 2) - 1
#define W_MIN -pow(2, OMEGA + 2)

// Function to initialize the weights vector
//void init_weights();

int sgn(int val);

// Function to predict sample
int predictor(uint16_t sample, uint16_t neighboor, int t, int z, int init_weights);


#endif //PREDICTOR_H

