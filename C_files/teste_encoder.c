#include <stdio.h>
#include "sample_adaptative.h"


const int MAPPED_RES[125] = {
        61273,
        140,
        318,
        764,
        1652,
        10,
        54,
        4,
        42,
        57,
        49,
        21,
        2,
        3,
        22,
        1,
        0,
        6,
        19,
        3,
        17,
        10,
        12,
        56,
        19,
        1,
        26,
        38,
        5,
        23,
        35,
        1,
        6,
        66,
        34,
        22,
        8,
        0,
        35,
        62,
        2,
        11,
        36,
        59,
        49,
        1,
        11,
        36,
        38,
        174,
        2,
        16,
        22,
        44,
        139,
        24,
        33,
        50,
        42,
        155,
        24,
        3,
        36,
        60,
        119,
        30,
        3,
        0,
        104,
        105,
        58,
        4,
        55,
        117,
        306,
        30,
        17,
        24,
        99,
        176,
        32,
        18,
        26,
        97,
        212,
        40,
        21,
        24,
        109,
        231,
        48,
        50,
        36,
        140,
        377,
        42,
        5,
        108,
        121,
        331,
        0,
        5,
        14,
        4,
        24,
        4,
        1,
        11,
        3,
        92,
        1,
        25,
        1,
        50,
        102,
        12,
        10,
        0,
        56,
        93,
        18,
        44,
        46,
        94,
        31,
};


int main(){

	uint16_t counter[BANDS] = {0x0};
	uint16_t accumulator[BANDS] = {0x0};
	uint16_t bits_written = 0;
	uint16_t x = 0, y = 0, t = 0, z = 0;

	// initializing counter and accumulator
	for(z = 0; z < BANDS; z++){
		counter[z] = 1 << INI_COUNT_EXP;
		accumulator[z] = (counter[z] * (3 * (1 << (ACCUMULATOR_INIT + 6)) - 49)) >> 7;
	}

    write_headers(&bits_written);

    printf("Final do header");

    x = 0;
    y = 0;
    z = 0;
    for (int i = 0; i < 125; i++) {
        t = x + y * NCOLS;

    	encode_sample(counter, accumulator, t, z, MAPPED_RES[i], &bits_written);

        z++;
        if (z == 5) {
            z = 0;
            x++;
            if (x == 5) {
                x = 0;
                y++;
            }
        }
    }

	return 0;
}
