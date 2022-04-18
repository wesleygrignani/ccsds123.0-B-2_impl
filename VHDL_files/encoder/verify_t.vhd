----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity verify_t is
  port ( i_clk    : in  std_logic;
         i_enable : in  std_logic;
         i_t      : in  integer;
         o_output : out std_logic);
end verify_t;

architecture Behavioral of verify_t is

signal w_t : integer := 0;

begin

  process(i_clk, i_enable)
  begin
    if(rising_edge(i_clk) and i_enable = '1') then
      w_t <= i_t;
    end if;
  end process;
  
  o_output <= '1' when w_t = 0 else '0';
    
end Behavioral;
