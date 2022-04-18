------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
------------------------------------------------------------------------------------------------
-- Description: this block will encode the mapped value following the condition (not(uz < UMAX)).
-- This block will operate in three stages, according to the code developed. Stages are going to 
-- be controled by fsm.

-- Stage 1   write_bits(0, UMAX); write UMAX's zeros 
-- Stage 2   write_bits(mapped, D); write D-bit binary representation of mapped
------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.ccsds123_B2_package.all;

entity encode_umax is
  Port (i_clk     : in  std_logic;
        i_enable  : in  std_logic;
        i_stage   : in  std_logic;                                 -- stage selected by fsm
        i_mapped  : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);  -- mapped value from predictor
        i_d_index : in  integer range 0 to D-1;                    -- counter used by fsm to indicate the bit position of mapped on stage 2 
        o_outbit  : out std_logic);                                -- out encoded bit
end encode_umax;

architecture Behavioral of encode_umax is

signal w_outbit : std_logic := '0';

begin

  w_outbit <= '0' when i_stage = '0' else 
              i_mapped(i_d_index) when i_stage = '1' else '0';  

  process(i_clk, i_enable)
  begin
    if(rising_edge(i_clk) and i_enable = '1') then
      o_outbit <= w_outbit;
    end if;
  end process;
  
  
end Behavioral;
