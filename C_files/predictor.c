// Name: Wesley Grignani
// CCSDS 123.0-B-2 compressor standard for lossless and near-lossless multispectral and hyperspectral image compression.


// CCSDS has two main block functions: the predictor block and encoder block.
// The first block to be implemented is the predictor block. This block are going to be created in the perspective to be used
// as reference to the hardware implementation.

#include "predictor.h"

/* Predictor block: returns a 16-bit residual mapped for the encode block
   Type of prediction: REDUCED MODE
   Local sum: COLUMN-ORIENTED
   the use of reduced mode in combination with column-oriented local sums tends to yield smaller compressed image data
   volumes for raw (uncalibrated) input images */

// local difference vector for P bands used to calculate the predicted sample value
int local_diff_vector[P] = {0x0};
int weights[P] = {0x0};
int previous_sample = 0;

int sgn(int val) {
    return (val < 0) ? -1 : 1;
}

int predictor(uint16_t sample, uint16_t neighboor, int t, int z, int init_weights){
#pragma HLS PIPELINE off

	/* weights initialization */
	if(init_weights == 1){
		/* default initialization weights */
	    weights[0] = (int) (pow(2, OMEGA) * 7 / 8.0);

	    for (int i = 1; i < P; i++) {
	        // should be ceil(), but Empordá implements floor()
	        weights[i] = floor(weights[i-1] / 8.0);
	    }
	}

	/* local sum: implemented using the column-oriented method as seen in the standard */
	int local_sum = 4 * neighboor;
	//printf("Local sum: %d\n", local_sum);
	/* The local sums are used to calculate local difference values
	 * central local difference: In each spectral band, the central local difference, is equal to
	 * the difference between the local sum σz,y,x and four times the sample representative value*/
	int central_local_diff = (4 * sample) - local_sum;
	printf("central_diff: %d\n",central_local_diff );

	/* PREDICTION CALCULATION */

	/* predict sample local difference */
	int predict_central = 0;
	for (int i = 0; i < ((z < P) ? z : P); i++){
		predict_central += local_diff_vector[i] * weights[i];
	}
	printf("predicted central: %d\n",predict_central);

	/* high resolution predicted sample value, is calculated as */
	int high_res = ((int) predict_central + (pow(2, OMEGA)*(local_sum - (4 * SMID))) + (pow(2, OMEGA+2)*SMID) + (pow(2, OMEGA+1)));
	if (high_res > (pow(2, OMEGA+2) * SMAX) + pow(2, OMEGA+1)){
		high_res = (pow(2, OMEGA+2) * SMAX) + pow(2, OMEGA+1);
	}
	printf("High res: %d\n", high_res);


	/* double resolution predicted sample is calculated as */
	int double_res = 0;
	if(t > 0){
		double_res = high_res / (pow(2, OMEGA+1));
	}else if (t == 0){
		if(z > 0)
			double_res = 2 * previous_sample;
		else
			double_res = 2 * SMID;
	}
	printf("Double res: %d\n", double_res);
	/* predicted sample value is calculated as */
	int predicted_sample = double_res/2;
	//printf("Predicted sample: %d\n", predicted_sample);
	previous_sample = sample;
	/* ------------------------------------- QUANTIZATION STEP --------------------------------- */
	/* The prediction residual, is the difference between the predicted and actual sample values */
	int predicted_residual = sample - predicted_sample;
	//printf("Predicted residual: %d\n", predicted_residual);

	/* The prediction residual shall be quantized using a uniform quantizer, producing as output
	 * the signed integer quantizer index defined as: */

	int quantized_index = 0;
	if(t > 0){
		quantized_index = sgn(predicted_residual) * (((abs(predicted_residual) + mz)) / (2*mz + 1));
	}else if(t == 0){
		quantized_index = predicted_residual;
	}
	printf("Quantized index: %d\n", quantized_index);

	// theta calculation
	int theta = (predicted_sample < SMAX-predicted_sample) ? predicted_sample : SMAX-predicted_sample;
	printf("theta: %d\n", theta);
    int mapped;
	/* mapped quantizer index (OUTPUT FROM PREDICTOR)*/
	/* The signed quantizer index is converted to an unsigned mapped quantizer index */
	if (abs(quantized_index) > theta){
		mapped = abs(quantized_index) + theta;
	}else if ((pow(-1, double_res) * quantized_index  >= 0) &&  (pow(-1, double_res) * quantized_index <= theta)){
		mapped = 2*abs(quantized_index);
	}else{
		mapped = (2*abs(quantized_index))-1;
	}

	/*--------------------------------------- WEIGHTS UPDATE ------------------------------------ */

	/* s' clipped version of the quantizer bin center */
	/* If lossless is used, then s'z(t) = sz(t) */
	int clipped = sample;
	//predicted_sample + quantized_index;
	//if (clipped > SMAX){
	//	clipped = SMAX;
	//}

	if(t > 0){
		/* double resolution prediction error */
		int double_res_pred_error = (2*clipped) - double_res;
		int p = V_MIN + floor((t-5) / pow(2, T_INC));
        if (p > V_MAX) p = V_MAX;
        else if (p < V_MIN) p = V_MIN;

        p = p + D - OMEGA;

        for (int j = 0; j < P; j++) {
            weights[j] = weights[j] + floor((sgn(double_res_pred_error) * pow(2, -p) * local_diff_vector[j] + 1) / 2);
            if (weights[j] > W_MAX) weights[j] = W_MAX;
            else if (weights[j] < W_MIN) weights[j] = W_MIN;
            printf("weight:%d\n", weights[j]);
        }
	}

    // Rotate local differences vector
    for (int k = P-1; k > 0; k--) {
    	local_diff_vector[k] = local_diff_vector[k-1];
    }
    local_diff_vector[0] = central_local_diff;

    return mapped;
}

