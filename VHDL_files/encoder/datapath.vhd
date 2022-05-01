----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
----------------------------------------------------------------------------------
-- Description: Datapath for encoder stage 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity datapath is
  port (i_clk                   : in  std_logic;
        i_sel_mux_acc           : in  std_logic;
        i_sel_mux_count         : in  std_logic;
        i_en_init_mem           : in  std_logic;
        i_en_kzcalc             : in  std_logic;
        i_en_coding_procedure   : in  std_logic;
        i_en_acc_counter_update : in  std_logic;
        i_en_encode_kz          : in  std_logic;
        i_en_encode_umax        : in  std_logic;
        i_rd_counter            : in  std_logic;
        i_wr_counter            : in  std_logic;
        i_rd_accumulator        : in  std_logic;
        i_wr_accumulator        : in  std_logic;
        i_rst_kz_uz_register    : in  std_logic;
        i_en_decounter_kz       : in  std_logic;
        i_en_decounter_uz       : in  std_logic;
        i_en_kz_register        : in  std_logic;
        i_en_uz_register        : in  std_logic;
        i_en_verify_t           : in  std_logic;
        i_addr_mem              : in  std_logic_vector(P-1 downto 0);
        i_stage_kz              : in  std_logic_vector(1 downto 0);
        i_t                     : in  integer;
        i_stage_umax            : in  std_logic;
        i_d_index               : in  integer range 0 to D-1;
        i_mapped                : in  std_logic_vector(SAMPLE_SIZE-1 downto 0); 
        o_outbit                : out std_logic;
        o_outbit_2              : out std_logic;
        o_select                : out std_logic;
        o_kz_equal_zero         : out std_logic;
        o_uz_equal_zero         : out std_logic;
        o_verify_t              : out std_logic);
end datapath;

architecture Behavioral of datapath is

component k_z_calc is
  port (i_clk         : in  std_logic;                                 -- clock signal
        i_enable      : in  std_logic;                                 -- enable signal from fsm
        i_counter     : in  std_logic_vector(COUNT_SIZE-1 downto 0);   -- counter value from z band
        i_accumulator : in  std_logic_vector(ACC_SIZE-1 downto 0);     -- accumulator value from z band
        o_kz          : out std_logic_vector(KZ_SIZE-1 downto 0));     -- k_z constant output
end component;

component coding_procedure is
  port (i_clk    : in  std_logic;                                -- clock signal
        i_enable : in  std_logic;                                -- enable signal from fsm
        i_mapped : in  std_logic_vector(SAMPLE_SIZE-1 downto 0); -- mapped value from predictor
        i_kz     : in  std_logic_vector(KZ_SIZE-1 downto 0);     -- kz value calculated in the previous block
        o_select : out std_logic;                                -- output for fsm knows what path use for encode mapped sample 
        o_uz     : out std_logic_vector(KZ_SIZE-1 downto 0));    -- uz value calculate in this block and used after in encode part
end component;

component encode_kz is
  port (i_clk      : in  std_logic;
        i_enable   : in  std_logic;
        i_stage    : in  std_logic_vector(1 downto 0);             -- stage selected from fsm
        i_kz_index : in  std_logic_vector(KZ_SIZE-1 downto 0);     -- kz value from fsm and used in Stage 3 
        i_mapped   : in  std_logic_vector(SAMPLE_SIZE-1 downto 0); -- mapped sample value 
        o_outbit   : out std_logic);                               -- output encoded bit
end component;

component encode_umax is
  Port (i_clk     : in  std_logic;
        i_enable  : in  std_logic;
        i_stage   : in  std_logic;                                 -- stage selected by fsm
        i_mapped  : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);  -- mapped value from predictor
        i_d_index : in  integer range 0 to D-1;                    -- counter used by fsm to indicate the bit position of mapped on stage 2 
        o_outbit  : out std_logic);                                -- out encoded bit
end component;

component acc_counter_update is
  port (i_clk         : in  std_logic;
        i_enable      : in  std_logic;
        i_counter     : in  std_logic_vector(COUNT_SIZE-1 downto 0); 
        i_accumulator : in  std_logic_vector(ACC_SIZE-1 downto 0);
        i_mapped      : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
        o_counter     : out std_logic_vector(COUNT_SIZE-1 downto 0);
        o_accumulator : out std_logic_vector(ACC_SIZE-1 downto 0));
end component;

component accumulator_mem is
port ( i_clk  : in  std_logic;
       i_wr   : in  std_logic;
       i_rd   : in  std_logic;
       i_addr : in  std_logic_vector(P-1 downto 0);
       i_din  : in  std_logic_vector(ACC_SIZE-1 downto 0);
       o_dout : out std_logic_vector(ACC_SIZE-1 downto 0));
end component;

component counter_mem is
port ( i_clk  : in  std_logic;
       i_wr   : in  std_logic;
       i_rd   : in  std_logic;
       i_addr : in  std_logic_vector(P-1 downto 0);
       i_din  : in  std_logic_vector(COUNT_SIZE-1 downto 0);
       o_dout : out std_logic_vector(COUNT_SIZE-1 downto 0));
end component;

component kz_register is
  port ( i_clk              : in  std_logic;
         i_rst              : in  std_logic;
         i_enable_decounter : in  std_logic;
         i_enable_kz        : in  std_logic;
         i_kz_value         : in  std_logic_vector(KZ_SIZE-1 downto 0);
         o_output           : out std_logic_vector(KZ_SIZE-1 downto 0));
end component;

component uz_register is
  port ( i_clk              : in  std_logic;
         i_rst              : in  std_logic;
         i_enable_decounter : in  std_logic;
         i_enable_uz        : in  std_logic;
         i_uz_value         : in  std_logic_vector(KZ_SIZE-1 downto 0);
         o_output           : out std_logic_vector(KZ_SIZE-1 downto 0));
end component;

component iqual_zero is
  port (i_input  : in  std_logic_vector(KZ_SIZE-1 downto 0);
        o_output : out std_logic);
end component;

component verify_t is
  port ( i_clk    : in  std_logic;
         i_enable : in  std_logic;
         i_t      : in  integer;
         o_output : out std_logic);
end component;

component init_counter_accumulator is
  port (i_clk         : in  std_logic;
        i_enable      : in  std_logic;
        o_accumulator : out std_logic_vector(ACC_SIZE-1 downto 0);
        o_counter     : out std_logic_vector(COUNT_SIZE-1 downto 0));
end component;

component mux_accumulator_mem is
  port (i_accumulator_from_init   : in  std_logic_vector(COUNT_SIZE-1 downto 0);
        i_accumulator_from_update : in  std_logic_vector(COUNT_SIZE-1 downto 0); 
        i_sel                 : in  std_logic;
        o_accumulator_out         : out std_logic_vector(COUNT_SIZE-1 downto 0));
end component;

component mux_counter_mem is
  port (i_counter_from_init   : in  std_logic_vector(COUNT_SIZE-1 downto 0);
        i_counter_from_update : in  std_logic_vector(COUNT_SIZE-1 downto 0); 
        i_sel                 : in  std_logic;
        o_counter_out         : out std_logic_vector(COUNT_SIZE-1 downto 0));
end component;

signal w_kz, w_uz : std_logic_vector(KZ_SIZE-1 downto 0) := (others => '0');
signal w_counter_mem_in, w_counter_mem_out, w_init_mem_count, w_count_in_memory : std_logic_vector(COUNT_SIZE-1 downto 0) := (others => '0');
signal w_accumulator_mem_in, w_accumulator_mem_out, w_init_mem_acc, w_acc_in_memory : std_logic_vector(ACC_SIZE-1 downto 0) := (others => '0');
signal w_kz_register, w_uz_register : std_logic_vector(KZ_SIZE-1 downto 0);

begin

  u_kz_block : k_z_calc
    port map (i_clk => i_clk,
              i_enable => i_en_kzcalc,
              i_counter => w_counter_mem_in,
              i_accumulator => w_accumulator_mem_in,
              o_kz => w_kz);
        
              
  u_coding_block : coding_procedure
    port map (i_clk => i_clk,
              i_enable => i_en_coding_procedure,
              i_mapped => i_mapped,
              i_kz => w_kz,
              o_select => o_select,
              o_uz => w_uz);
  
  u_encoding_kz_block : encode_kz
    port map (i_clk => i_clk,
              i_enable => i_en_encode_kz,
              i_stage => i_stage_kz,
              i_kz_index => w_kz_register,
              i_mapped => i_mapped,
              o_outbit => o_outbit);
  
  u_encode_umax_block : encode_umax
    port map (i_clk => i_clk,
              i_enable => i_en_encode_umax,
              i_stage => i_stage_umax,
              i_mapped => i_mapped,
              i_d_index => i_d_index,
              o_outbit => o_outbit_2);  

  u_accumulator_mem_block : accumulator_mem
    port map (i_clk => i_clk,
              i_rd => i_rd_accumulator,
              i_wr => i_wr_accumulator,
              i_addr => i_addr_mem,
              i_din => w_acc_in_memory,
              o_dout => w_accumulator_mem_in);
  
  u_counter_mem_block : counter_mem
    port map (i_clk => i_clk,
              i_rd => i_rd_counter,
              i_wr => i_wr_counter,
              i_addr => i_addr_mem,
              i_din => w_count_in_memory,
              o_dout => w_counter_mem_in);

  u_update_block : acc_counter_update
    port map (i_clk => i_clk,
              i_enable => i_en_acc_counter_update,
              i_counter => w_counter_mem_in,
              i_accumulator => w_accumulator_mem_in,
              i_mapped => i_mapped,
              o_counter => w_counter_mem_out,
              o_accumulator => w_accumulator_mem_out);
   
              
  -- ligar esses registradores a um comparador de maior ou igual a zero
  u_kz_register : kz_register 
    port map (i_clk => i_clk,
              i_rst => i_rst_kz_uz_register,
              i_enable_decounter => i_en_decounter_kz,
              i_enable_kz => i_en_kz_register,
              i_kz_value => w_kz,
              o_output => w_kz_register);
              
  u_uz_register : uz_register
    port map (i_clk => i_clk,
              i_rst => i_rst_kz_uz_register,
              i_enable_decounter => i_en_decounter_uz,
              i_enable_uz => i_en_uz_register,
              i_uz_value => w_uz,
              o_output => w_uz_register);

  u_kz_comparator : iqual_zero
    port map (i_input => w_kz_register,
              o_output => o_kz_equal_zero);


  u_uz_comparator : iqual_zero
    port map (i_input => w_uz_register,
              o_output => o_uz_equal_zero);
              
                           
  u_verify_t : verify_t 
    port map (i_clk    => i_clk,
              i_enable => i_en_verify_t,
              i_t      => i_t,
              o_output => o_verify_t);
              
  u_init_mem : init_counter_accumulator 
  port map (i_clk => i_clk,
            i_enable => i_en_init_mem,
            o_accumulator => w_init_mem_acc,
            o_counter => w_init_mem_count);
            
  u_mux_acc : mux_accumulator_mem 
  port map (i_accumulator_from_init  => w_init_mem_acc,
            i_accumulator_from_update => w_accumulator_mem_out,
            i_sel => i_sel_mux_acc,
            o_accumulator_out  => w_acc_in_memory);
            
  u_mux_count : mux_counter_mem 
  port map (i_counter_from_init   => w_init_mem_count,
            i_counter_from_update => w_counter_mem_out,
            i_sel                 => i_sel_mux_count,
            o_counter_out         => w_count_in_memory);

end Behavioral;
