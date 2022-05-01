----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Description: Block for initialize the values for counter and accumulator memory
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity init_counter_accumulator is
  port (i_clk         : in  std_logic;
        i_enable      : in  std_logic;
        o_accumulator : out std_logic_vector(ACC_SIZE-1 downto 0);
        o_counter     : out std_logic_vector(COUNT_SIZE-1 downto 0));
end init_counter_accumulator;

architecture Behavioral of init_counter_accumulator is

signal w_counter_aux, w_counter, w_accumulator : integer := 0; 

begin

  w_counter_aux <= (2**INI_COUNT_EXP);
  
  process(i_clk, i_enable)
  begin
    if(rising_edge(i_clk) and i_enable = '1') then
      w_accumulator <= (w_counter_aux * (3 * (2**(ACCUMULATOR_INIT+6)) - 49)) / 7;
      w_counter <= w_counter_aux;
    end if;
  end process;

  o_accumulator <= std_logic_vector(to_signed(w_accumulator, ACC_SIZE));
  o_counter <= std_logic_vector(to_signed(w_counter, COUNT_SIZE));
  
end Behavioral;
