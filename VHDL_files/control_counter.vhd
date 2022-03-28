----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
----------------------------------------------------------------------------------
-- counter for control block analysis of actual band for calcs 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;


entity control_counter is
  port (i_clk    : in  std_logic;
        i_rst    : in  std_logic;
        i_enable : in  std_logic;
        o_count  : out std_logic_vector(P-1 downto 0));
end control_counter;

architecture Behavioral of control_counter is

signal w_count : unsigned(P-1 downto 0) := (others => '0');

begin

  process(i_clk, i_enable)
  begin
    if(i_rst = '1') then 
      w_count <= (others => '0');
    elsif(rising_edge(i_clk) and i_enable = '1') then
      w_count <= w_count + 1;
    end if;
  end process;  
      
  o_count <= std_logic_vector(signed(w_count));    
  
end Behavioral;
