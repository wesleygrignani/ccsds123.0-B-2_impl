-----------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity init_weights is
  port (i_clk              : in  std_logic;
        i_enable           : in  std_logic;
        i_enable_first_mem : in  std_logic; 
        o_weights          : out std_logic_vector(WEIGHT_SIZE-1 downto 0));
end init_weights;

architecture Behavioral of init_weights is

signal w_weights : integer := 0;

begin

  process(i_clk, i_enable, i_enable_first_mem)
  begin
    if(rising_edge(i_clk) and i_enable = '1') then
      if(i_enable_first_mem = '1') then
        w_weights <= ((2**OMEGA)*7) / 8;
      else 
        w_weights <= w_weights/8;
      end if;
    end if;
  end process;
  
  o_weights <= std_logic_vector(TO_UNSIGNED(w_weights, WEIGHT_SIZE));
    
end Behavioral;
