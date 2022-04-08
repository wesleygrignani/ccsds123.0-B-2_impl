----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
----------------------------------------------------------------------------------

 library IEEE;
 use IEEE.std_logic_1164.all;
 use IEEE.numeric_std.all;
 
 package ccsds123_b2_package is 
 
 -- Constants
 
 -- Bands of predictions shall be an integer in the range 0 <= P <= 15
 constant P : integer := 5;
 
 -- Dynamic size of sample 
 constant D : integer := 16;
 
 -- OMEGA constant 
 constant OMEGA : integer := 8;
 
 -- Size of sample 
 constant SAMPLE_SIZE : integer := 16;
 
 -- Quantizer fidelity control - Utilized for near-lossless compression (error control)
 constant mz : integer := 0; 
 
 -- VMIN and VMAX values shall be integers in the range -6<=vmin<=vmax<=9 
 -- TINC shall be a power of 2 in the range (2^4 <= tinc <= 2^11)
 constant V_MIN : integer := 5;
 constant V_MAX : integer := 9;
 constant T_INC : integer := 6;
 
 -- Number of bands, rows and columns of the image and its used for prediction
 constant NBANDS : integer := 5;
 constant NROWS  : integer := 5;
 constant NCOLS  : integer := 5;
 
 -- Maximum and medium value of a sample size used
 constant SMAX : integer := 2**SAMPLE_SIZE - 1;
 constant SMID : integer := 2**(SAMPLE_SIZE - 1);
 
 -- WMAX and WMIN
 constant WMAX : integer := 2**(OMEGA + 2) - 1;
 constant WMIN : integer := -2**(OMEGA + 2);
 
 -- WEIGHT SIZE - Each weight value is a signed integer quantity that can be represented using Ω + 3 bits
 constant WEIGHT_SIZE : integer := OMEGA + 3;
 
 -- DATA SIZE -  Size of sample value after local ops
 constant DATA_SIZE : integer := SAMPLE_SIZE + 4;
 
 -- MAX SIZE FOR PREDICTED CENTRAL LOCAL DIFFERENCE 
 constant MAX_SIZE : integer := SAMPLE_SIZE + WEIGHT_SIZE;


 -- encoder constants 
 
 -- Accumulator size 
 constant ACC_SIZE : integer := 16; 
 
 -- Counter size
 constant COUNT_SIZE : integer := 16;
 
 -- k_z constant size
 constant KZ_SIZE : integer := 16; 
 
 -- Unary length limit shall be an integer in the range 8 to 32
 constant UMAX : integer := 8; 
 
 -- Initial count exponent shall be an integer in the range 1 to 8
 constant INI_COUNT_EXP : integer := 1;
 
 -- Rescaling counter size parameter
 constant RESCALING_COUNTER_SIZE : integer := 4;
 
 -- Accumulator initialization constant
 constant ACCUMULATOR_INIT : integer := 7;
 
 end package ccsds123_b2_package;