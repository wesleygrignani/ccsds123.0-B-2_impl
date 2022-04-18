------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
------------------------------------------------------------------------------------------------
-- Description: this block will encode the mapped value following the condition (uz < UMAX).
-- This block will operate in three stages, according to the code developed. Stages are going to 
-- be controled by fsm.

-- Stage 1   write_bits(0, u_z); write u_z's zeros 
-- Stage 2   write_bits(1, 1); write 1 one
-- Stage 3   write_bits_mapped2(mapped, k_z); write k_z least significant bits os mapped
------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;


entity encode_kz is
  port (i_clk      : in  std_logic;
        i_enable   : in  std_logic;
        i_stage    : in  std_logic_vector(1 downto 0);             -- stage selected from fsm
        i_kz_index : in  std_logic_vector(KZ_SIZE-1 downto 0);     -- kz value used in Stage 3
        i_mapped   : in  std_logic_vector(SAMPLE_SIZE-1 downto 0); -- mapped sample value 
        o_outbit   : out std_logic);                               -- output encoded bit
end encode_kz;

architecture Behavioral of encode_kz is

signal w_outbit : std_logic := '0';
begin
  
  w_outbit <= '0' when i_stage = "00" else 
              '1' when i_stage = "01" else
               i_mapped(to_integer(unsigned(i_kz_index))) when i_stage = "10" else '0';
               
  process(i_clk, i_enable)
  begin 
    if(rising_edge(i_clk) and i_enable = '1') then 
      o_outbit <= w_outbit;
    end if;
  end process;
  
end Behavioral;
