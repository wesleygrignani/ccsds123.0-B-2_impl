//
// Sample adaptative entropy coder for CCSDS123-B-2 issue
// Created by Wesley on 2/22/2022
//

#include "sample_adaptative.h"

void write_bits(int data, int size){

    unsigned int wbits_written;
    unsigned int w_buffer;
    unsigned int w_buf_size;
    int i;

    for (i = size-1; i >= 0; i--) {
    	w_buffer = (w_buffer << 1) + ((data >> i) & 0x01);
    	data -= ((data >> i) & 0x01) << i;
    	w_buf_size++;
    	if (w_buf_size == 8) {
    		w_buf_size = 0;
    		// f_write(&fil_write, &w_buffer, 1, &wbits_written);
    		// printf("Data: %d", );
    	}
    }
}


int encode_sample(uint16_t counter[BANDS], uint16_t accumulator[BANDS], uint16_t t, uint16_t z, uint16_t mapped){
//#pragma HLS ARRAY_PARTITION variable=accumulator dim=1 complete
//#pragma HLS ARRAY_PARTITION variable=counter dim=1 complete
#pragma HLS PIPELINE off

	// The first mapped prediction residual in each spectral band shall be uncoded, remember that:(t = x + y * NCOLS)
	if (t == 0){ // first sample predicted in some z band
		write_bits(mapped, DYNAMIC_RANGE);
	}else{ // for t > 0
		int k_z;

		if((2 * counter[z]) > (accumulator[z] + ((49/(pow(2,7))*counter[z])))){
			k_z = 0;
		}else if(k_z > DYNAMIC_RANGE - 2){
			k_z = DYNAMIC_RANGE - 2;
		}

		unsigned int u_z = (mapped >> k_z);

		// Coding procedure
		if(u_z < UMAX){ // then Rk consists of u_z 'zeros', followed by a 'one' and by the k least sig bits of the mapped
			write_bits(0, u_z);
			write_bits(1, 1);
			write_bits(mapped, k_z);
		}else{ // otherwise Rk consists of UMAX 'zeros' followed by D-bit binary representation of mappped
			write_bits(0, UMAX);
			write_bits(mapped, DYNAMIC_RANGE);
		}

		// Accumulator and counter update
		int limit = pow(2, RESCALING_COUNTER_SIZE) - 1;

		if(counter[z] < limit){
			accumulator[z] += mapped;
			counter[z] ++;
		}else if(counter[z] == limit){
			accumulator[z] = (accumulator[z] + mapped + 1) >> 1;
			counter[z] = (counter[z] + 1) >> 1;
		}
	}

	return 1;
}
