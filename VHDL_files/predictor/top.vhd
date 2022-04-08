----------------------------------------------------------------------------------
-- Name: Wesley Grignani
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity top is
  port ( i_clk          : in  std_logic; 
         i_rst          : in  std_logic;
         i_start        : in  std_logic;
         i_t            : in  integer range 0 to 255;
         i_z            : in  integer range 0 to 5;
         i_sample       : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
         i_neighboor    : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
         o_mapped       : out std_logic_vector(SAMPLE_SIZE-1 downto 0));
end top;


architecture Behavioral of top is


-- control block
component control is
  port ( i_clk              : in  std_logic; 
         i_rst              : in  std_logic;
         i_start            : in  std_logic;
         i_z                : integer range 0 to 5;
         i_control_counter  : in  std_logic_vector(P-1 downto 0);
         o_enable_ls        : out std_logic;
         o_enable_ldiff     : out std_logic;
         o_enable_central   : out std_logic;
         o_enable_high      : out std_logic;
         o_enable_double    : out std_logic;
         o_enable_qnt       : out std_logic;
         o_sel_mux_weight   : out std_logic;
         o_rst              : out std_logic;
         o_init_weight      : out std_logic;
         o_wr_weights       : out std_logic;
         o_rd_weights       : out std_logic;
         o_wr_localdiff     : out std_logic;
         o_rd_localdiff     : out std_logic;
         o_enable_mapped    : out std_logic;
         o_enable_first_mem : out std_logic;
         o_rst_counter      : out std_logic;
         o_enable_counter   : out std_logic;
         o_en_update_weight : out std_logic);
end component;

-- datapath
component top_test is
  port (i_clk              : in  std_logic;
        i_enable_ls        : in  std_logic;
        i_wr_weights       : in  std_logic;
        i_rd_weights       : in  std_logic;
        i_wr_local_diff    : in  std_logic;
        i_rd_local_diff    : in  std_logic;
        i_init_weights     : in  std_logic;
        i_rst              : in  std_logic;
        i_sel_weight_mem   : in  std_logic;
        i_enable_ldiff     : in  std_logic;
        i_enable_central   : in  std_logic;
        i_enable_high      : in  std_logic;
        i_enable_double    : in  std_logic;
        i_enable_qnt       : in  std_logic;
        i_enable_mapped    : in  std_logic;
        i_enable_first_mem : in  std_logic;
        i_en_update_weight : in  std_logic; 
        i_t                : in  integer range 0 to 255;
        i_z                : in  integer range 0 to 5;
        i_sample           : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
        i_neighboor        : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
        i_rst_counter      : in  std_logic;
        i_enable_counter   : in  std_logic;
        o_control_counter  : out std_logic_vector(P-1 downto 0);
        o_mapped           : out std_logic_vector(SAMPLE_SIZE-1 downto 0));
end component;


signal w_reset_counter, w_enable_counter, w_enable_ls, w_enable_ldiff, w_enable_central, w_enable_high, w_enable_double, w_enable_qnt, w_enable_mapped, w_wr_weights, w_rd_weights, w_initweights_mem, w_enable_first_mem, w_wr_localdiff, w_rd_localdiff, w_en_update_weight, w_sel_weight, w_rst : std_logic := '0';
signal w_dout : std_logic_vector(WEIGHT_SIZE-1 downto 0) := (others => '0');
signal w_addr_weights, w_addr_localdiff : std_logic_vector(2 downto 0) := (others => '0');
signal w_control_counter : std_logic_vector(P-1 downto 0) := (others => '0');

begin

control_block : control 
  port map ( i_clk              => i_clk,
             i_rst              => i_rst,
             i_start            => i_start,
             i_z                => i_z,
             i_control_counter  => w_control_counter,
             o_enable_ls        => w_enable_ls,
             o_enable_ldiff     => w_enable_ldiff,
             o_enable_central   => w_enable_central,
             o_enable_high      => w_enable_high,
             o_enable_double    => w_enable_double,
             o_enable_qnt       => w_enable_qnt,
             o_enable_mapped    => w_enable_mapped,
             o_init_weight      => w_initweights_mem,
             o_wr_weights       => w_wr_weights,
             o_rd_weights       => w_rd_weights,
             o_wr_localdiff     => w_wr_localdiff,
             o_rd_localdiff     => w_rd_localdiff,
             o_sel_mux_weight   => w_sel_weight,
             o_rst              => w_rst,
             o_enable_first_mem => w_enable_first_mem,
             o_rst_counter      => w_reset_counter,
             o_enable_counter   => w_enable_counter,
             o_en_update_weight => w_en_update_weight);
             
 datapath_block : top_test 
  port map ( i_clk              => i_clk,
             i_enable_ls        => w_enable_ls,
             i_enable_ldiff     => w_enable_ldiff,
             i_enable_central   => w_enable_central,
             i_enable_high      => w_enable_high,
             i_enable_double    => w_enable_double,
             i_enable_qnt       => w_enable_qnt,
             i_enable_mapped    => w_enable_mapped,
             i_enable_first_mem => w_enable_first_mem,
             i_init_weights     => w_initweights_mem,
             i_t                => i_t,
             i_z                => i_z,
             i_sample           => i_sample,
             i_neighboor        => i_neighboor,
             i_wr_weights       => w_wr_weights,
             i_rd_weights       => w_rd_weights,
             i_wr_local_diff    => w_wr_localdiff,
             i_rd_local_diff    => w_rd_localdiff,
             i_en_update_weight => w_en_update_weight,
             i_sel_weight_mem   => w_sel_weight,
             i_rst              => w_rst,
             i_rst_counter      => w_reset_counter,
             i_enable_counter   => w_enable_counter,
             o_control_counter  => w_control_counter,
             o_mapped           => o_mapped);
    
   
end Behavioral;
