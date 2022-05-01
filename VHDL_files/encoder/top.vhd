----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity top is
  port ( i_clk      : in  std_logic;
         i_mapped   : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
         i_rst      : in  std_logic;
         i_start    : in  std_logic;
         i_t        : in  integer;
         i_d_index  : in  integer range 0 to D-1;
         o_outbit   : out std_logic;
         o_outbit_2 : out std_logic);
end top;

architecture Behavioral of top is

component control_block is
  port ( i_clk                   : in  std_logic;
         i_rst                   : in  std_logic;
         i_start                 : in  std_logic;
         i_verify_t              : in  std_logic;  -- sinal para informar se t>=0
         i_select_coding         : in  std_logic;  -- selecionar qual caminho de codificação ira fazer
         i_kz_equal_zero         : in  std_logic;
         i_uz_equal_zero         : in  std_logic;
         o_sel_mux_acc           : out std_logic; 
         o_sel_mux_count         : out std_logic; 
         o_en_init_mem           : out std_logic; 
         o_en_coding_kz          : out std_logic;
         o_en_coding_umax        : out std_logic;
         o_enable_kzcalc         : out std_logic;  
         o_en_coding_procedure   : out std_logic;
         o_en_acc_counter_update : out std_logic;
         o_rd_counter            : out std_logic;
         o_wr_counter            : out std_logic;
         o_rd_accumulator        : out std_logic;
         o_wr_accumulator        : out std_logic;
         o_addr_mem              : out std_logic_vector(P-1 downto 0);
         o_rst_kz_uz_register    : out std_logic;
         o_en_decounter_kz       : out std_logic;
         o_en_decounter_uz       : out std_logic;
         o_en_kz_register        : out std_logic;
         o_en_uz_register        : out std_logic;
         o_en_verify_t           : out std_logic;
         o_stage_kz              : out std_logic_vector(1 downto 0);
         o_stage_umax            : out std_logic);
end component;

component datapath is
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
end component;

-- etapas
signal w_verify_t, w_select_coding, w_kz_equal_zero, w_uz_equal_zero, w_en_kzcalc, w_en_codingprocedure, w_en_acc_counter_update, w_rd_counter, w_wr_counter, w_rd_accumulator, w_wr_accumulator, w_en_coding_kz, w_en_coding_umax : std_logic := '0';
-- memoria
signal w_addr_mem : std_logic_vector(P-1 downto 0) := (others => '0');
-- decounter
signal w_rst_kz_uz_register, w_en_decounter_kz, w_en_decounter_uz, w_en_kz_register, w_en_uz_register : std_logic := '0';
-- enable verify t
signal w_en_verify_t : std_logic := '0';
-- stage kz
signal w_stage_kz : std_logic_vector(1 downto 0) := (others => '0');
-- stage umax
signal w_stage_umax : std_logic := '0';
-- seletor dos multiplexadores
signal w_sel_mux_acc, w_sel_mux_count : std_logic := '0';
-- enable da inicialização das memorias
signal w_en_init_mem : std_logic := '0';

begin

  u_control : control_block 
  port map ( i_clk => i_clk,
             i_rst => i_rst,
             i_start => i_start,
             i_verify_t => w_verify_t,
             i_select_coding => w_select_coding,
             i_kz_equal_zero => w_kz_equal_zero,
             i_uz_equal_zero => w_uz_equal_zero,
             o_sel_mux_acc  => w_sel_mux_acc, 
             o_sel_mux_count => w_sel_mux_count,
             o_en_init_mem => w_en_init_mem,
             o_en_coding_kz => w_en_coding_kz,
             o_en_coding_umax => w_en_coding_umax,
             o_enable_kzcalc => w_en_kzcalc,  
             o_en_coding_procedure => w_en_codingprocedure,
             o_en_acc_counter_update => w_en_acc_counter_update,
             o_rd_counter => w_rd_counter,
             o_wr_counter => w_wr_counter,
             o_rd_accumulator => w_rd_accumulator,
             o_wr_accumulator => w_wr_accumulator,
             o_addr_mem => w_addr_mem,
             o_rst_kz_uz_register => w_rst_kz_uz_register, 
             o_en_decounter_kz => w_en_decounter_kz,
             o_en_decounter_uz => w_en_decounter_uz,
             o_en_kz_register => w_en_kz_register,
             o_en_uz_register => w_en_uz_register,
             o_en_verify_t => w_en_verify_t,
             o_stage_kz => w_stage_kz,
             o_stage_umax => w_stage_umax);
             
             
             
  u_datapath : datapath
  port map ( i_clk => i_clk,
             i_sel_mux_acc => w_sel_mux_acc,
             i_sel_mux_count => w_sel_mux_count,
             i_en_init_mem => w_en_init_mem,
             i_en_kzcalc => w_en_kzcalc,
             i_en_coding_procedure  => w_en_codingprocedure,
             i_en_acc_counter_update => w_en_acc_counter_update,
             i_en_encode_kz  => w_en_coding_kz,
             i_en_encode_umax => w_en_coding_umax,
             i_rd_counter => w_rd_counter,
             i_wr_counter => w_wr_counter,
             i_rd_accumulator => w_rd_accumulator,
             i_wr_accumulator => w_wr_accumulator,
             i_rst_kz_uz_register => w_rst_kz_uz_register,
             i_en_decounter_kz => w_en_decounter_kz,
             i_en_decounter_uz => w_en_decounter_uz,
             i_en_kz_register => w_en_kz_register,
             i_en_uz_register => w_en_uz_register,
             i_en_verify_t => w_en_verify_t,
             i_addr_mem => w_addr_mem,
             i_stage_kz => w_stage_kz,
             i_t => i_t,
             i_stage_umax => w_stage_umax,
             i_d_index => i_d_index,
             i_mapped => i_mapped, 
             o_outbit => o_outbit,
             o_outbit_2 => o_outbit_2,
             o_select => w_select_coding,
             o_kz_equal_zero  => w_kz_equal_zero,
             o_uz_equal_zero  => w_uz_equal_zero,
             o_verify_t       => w_verify_t);

end Behavioral;
