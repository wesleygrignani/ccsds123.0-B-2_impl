//
// Sample adaptative entropy coder for CCSDS123-B-2 issue
// Created by Wesley on 2/22/2022
//

#include "sample_adaptative.h"

unsigned int mlog2( unsigned int x ) {
    unsigned int ans = 0 ;
    while( x >>= 1 ) ans++;
    return ans;
}

void write_bits(int data, int size){

    int i;
    for (i = size-1; i >= 0; i--) {
    	printf("%d", data);
    }
}

void write_bits_mapped(int data, int size){

	int mapped[16] = {0x0};
	for(int i = 0; data > 0; i++){
		mapped[i] = data % 2;
		data = data/2;
	}

	for(i = 0; i < size-1; i++){
		printf("%d", mapped[i]);
	}
}

void write_bits_mapped2(int data, int size){

	int mapped[16] = {0x0};
	for(int i = 0; data > 0; i++){
		mapped[i] = data % 2;
		data = data/2;
	}

	for(i = size-1; i >= 0; i--){
		printf("%d", mapped[i]);
	}
}


int encode_sample(uint16_t counter[BANDS], uint16_t accumulator[BANDS], uint16_t t, uint16_t z, uint16_t mapped, uint16_t *bits_written){
#pragma HLS PIPELINE off

	// The first mapped prediction residual in each spectral band shall be uncoded, remember that:(t = x + y * NCOLS)
	if (t == 0){ // first sample predicted in some z band
		write_bits_mapped2(mapped, DYNAMIC_RANGE);
		*bits_written += DYNAMIC_RANGE;
	}else{ // for t > 0

		int k_z = (int) mlog2((accumulator[z] + (49 * counter[z] >> 7)) / (double) counter[z]);

		if((2 * counter[z]) > (accumulator[z] + ((49/(pow(2,7))*counter[z])))){
			k_z = 0;
		}else if(k_z > DYNAMIC_RANGE - 2){
			k_z = DYNAMIC_RANGE - 2;
		}

		unsigned int u_z = (mapped >> k_z);

		// Coding procedure
		if(u_z < UMAX){ // then Rk consists of u_z 'zeros', followed by a 'one' and by the k least sig bits of the mapped
			//printf("u_z < UMAX");
			write_bits(0, u_z);
			write_bits(1, 1);
			write_bits_mapped2(mapped, k_z);
			*bits_written += u_z + 1 + k_z;
		}else{ // otherwise Rk consists of UMAX 'zeros' followed by D-bit binary representation of mappped
			//printf("else");
			write_bits(0, UMAX);
			write_bits_mapped2(mapped, DYNAMIC_RANGE);
			*bits_written += UMAX + DYNAMIC_RANGE;
		}

		// Accumulator and counter update
		//int limit = pow(2, RESCALING_COUNTER_SIZE) - 1;

        int limit = (1 << RESCALING_COUNTER_SIZE) - 1;
        if (counter[z] < limit) {
            accumulator[z] += mapped;
            counter[z]++;

        } else {
            accumulator[z] = (accumulator[z] + mapped + 1) >> 1;
            counter[z] = (counter[z] +1) >> 1;
        }
	}

	return 1;
}


void write_headers(uint16_t *bits_written){
    /************************************************ WRITE HEADER ****************************************************/
    /*************************************** IMAGE METADATA ********************************/
    const __uint8_t ud_data = 0;
    write_bits(ud_data, 8); // User Defined Data (8 bits)
    *bits_written += 8;

    const __uint16_t x_size = NCOLS;
    write_bits_mapped2(x_size, 16); // X Size (16 bits)
    *bits_written += 16;

    const __uint16_t y_size = NROWS;
    write_bits_mapped2(y_size, 16); // Y Size (16 bits)
    *bits_written += 16;

    const __uint16_t z_size = NBANDS;
    write_bits_mapped2(z_size, 16); // Z Size (16 bits)
    *bits_written += 16;

    const __uint8_t sample_type = 0; // Image sample values are unsigned integers
    write_bits(sample_type, 1); // Sample Type (1 bit)
    *bits_written += 1;

    write_bits(0, 1); // Reserved -> This field shall have value '0' (1 bit)
    *bits_written += 1;

    const __uint8_t large_dyn_range_flag = 0;  //‘0’: dynamic range satisfies D ≤ 16.
    write_bits(large_dyn_range_flag, 1);       //‘1’: dynamic range satisfies D > 16.
    *bits_written += 1;

    const __uint16_t dyn_range = 16; //DYNAMIC_RANGE; // = D
    write_bits_mapped2(dyn_range, 4); // Dynamic Range (4 bits)
    *bits_written += 4;

    const __uint8_t senc_order = 0; // encoded in band-interleaved order
    write_bits(senc_order, 1); // Sample Encoding Order (1 bit)
    *bits_written += 1;

    const __uint16_t int_depth = M;
    write_bits_mapped2(int_depth, 16); // Sub-frame interleaving depth (16 bits)
    *bits_written += 16;

    write_bits(0, 2); // Reserved
    *bits_written += 2;

    const __uint8_t ow_size = 4;
    write_bits_mapped2(ow_size, 3); // Output word size (3 bits)
    *bits_written += 3;

    const __uint8_t ecod_type = 0; // Sample-adaptive entropy coder
    write_bits(ecod_type, 2); // Entropy coder type (2 bits)
    *bits_written += 2;

    write_bits(0, 1); // Reserved (1 bits) this field shall have value 0
    *bits_written += 1;

    //quantizer fidelity control (2 bits)
    const __uint8_t fidelity_ctrl = 0;  //lossless
    write_bits(0, 2);
    *bits_written += 2;

    write_bits(0, 2); // Reserved (2 bits) this field shall contain all 'zeros'
    *bits_written += 2;

    //Supplementary Information Table Count (4bits)
    write_bits(0, 4); // If supplementary information tables are used, the number of such tables, τ, shall be at most 15.
    *bits_written += 4;


    /*********************************** PREDICTOR METADATA *******************************/
    write_bits(0, 1); // Reserved (1 bit)
    *bits_written += 1; // this field shall have value 0

    //Sample Representative Flag
    write_bits(0, 1); // Sample Representative subpart is not included in Predictor Metadata header part;
    *bits_written += 1;

    const __uint8_t n_pbands = 3; // = P
    write_bits_mapped2(n_pbands, 4); // Number of prediction bands (4 bits)
    *bits_written += 4;

    const __uint8_t p_mode = 1; // Reduced prediction mode
    write_bits(p_mode, 1); // Prediction mode (1 bit)
    *bits_written += 1;

    //Weight Exponent Offset Flag
    write_bits(0, 1);
    *bits_written += 1;


    // Column-oriented local sums are used '10'
    write_bits(1, 1);
    write_bits(0, 1);
    *bits_written += 2;

    const __uint8_t reg_size = 32; // = R
    write_bits_mapped2(reg_size, 6); // Register size (6 bits)
    *bits_written += 6;

    const __uint8_t wcomp_res = 4; // = Ohmega - 4
    write_bits_mapped2(wcomp_res, 4); // Weight component resolution (4 bits)
    *bits_written += 4;

    const __uint8_t wupd_scal_exp_cha_int = 4; // = Tinc
    write_bits_mapped2(wupd_scal_exp_cha_int, 4); // Weight update scaling exponent change interval (4 bits)
    *bits_written += 4;

    const __uint8_t wupd_scal_exp_ini_par = 8; // = VMIN + 6
    write_bits_mapped2(wupd_scal_exp_ini_par, 4); // Weight update scaling exponent initial parameter (4 bits)
    *bits_written += 4;

    const __uint8_t wupd_scal_exp_final_par = 9; // = VMAX + 6
    write_bits_mapped2(wupd_scal_exp_final_par, 4); // Weight update scaling exponent final parameter (4 bits)
    *bits_written += 4;

    write_bits(0, 1); // Weight Exponent Offset Table Flag
    *bits_written += 1;

    const __uint8_t winit_method = 0; // Default weight initialization
    write_bits(winit_method, 1); // Weight initialization method (1 bit)
    *bits_written += 1;

    const __uint8_t winit_tabflag = 0; // Weight initialization table is not included in predictor metadata
    write_bits(winit_tabflag, 1); // Weight initialization table flag (1 bit)
    *bits_written += 1;

    const __uint8_t w_resolution = 0; // When the default weight initialization is used, this field shall have value ‘00000’
    write_bits(w_resolution, 5); // Weight initialization resolution (5 bits)
    *bits_written += 5;


    /*********************************** Entropy Coder Metadata *********************************/
    const __uint8_t ulength_limit = UMAX;
    write_bits_mapped2(ulength_limit, 5); // Unitary length limit (5 bits)
    *bits_written += 5;

    const __uint8_t rcount_size = 4; //RESCALING_COUNTER_SIZE; // = delta* - 4
    write_bits_mapped2(rcount_size, 3); // Rescaling counter size (3 bits)
    *bits_written += 3;

    const __uint8_t inicount_exp = 1; // = delta0
    write_bits(inicount_exp, 3); // Initial count exponent (3 bits)
    *bits_written += 3;

    const __uint8_t acc_ini_const = ACCUMULATOR_INIT; // Accumulator Initialization Table is not included in Entropy Coder Metadata
    write_bits_mapped2(acc_ini_const, 4); // Accumulator Initialization Constant (5 bits)
    *bits_written += 4;

    const __uint8_t acc_ini_flag = 0; // Accumulator Initialization Table is not included in Entropy Coder Metadata
    write_bits(acc_ini_flag, 1); // Accumulator Initialization Table Flag (1 bit)
    *bits_written += 1;
}
