----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
----------------------------------------------------------------------------------
-- Description: Accumulator and counter update
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity acc_counter_update is
  port (i_clk         : in  std_logic;
        i_enable      : in  std_logic;
        i_counter     : in  std_logic_vector(COUNT_SIZE-1 downto 0); 
        i_accumulator : in  std_logic_vector(ACC_SIZE-1 downto 0);
        i_mapped      : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
        o_counter     : out std_logic_vector(COUNT_SIZE-1 downto 0);
        o_accumulator : out std_logic_vector(ACC_SIZE-1 downto 0));
end acc_counter_update;

architecture Behavioral of acc_counter_update is

signal w_limit, w_counter, w_accumulator, w_mapped : integer := 0;

begin
  
  w_limit <= (2**RESCALING_COUNTER_SIZE) - 1;
      
  process(i_clk, i_enable, w_counter, i_counter, i_accumulator, i_mapped) 
  begin 
    w_counter <= to_integer(unsigned (i_counter));
    w_accumulator <= to_integer(unsigned (i_accumulator));
    w_mapped <= to_integer(unsigned (i_mapped));
    
    if(rising_edge(i_clk) and i_enable = '1') then      
      if(w_counter < w_limit) then
        w_accumulator <= w_accumulator + w_mapped;
        w_counter <= w_counter + 1;
      else
        w_accumulator <= (w_accumulator + w_mapped + 1) / 2;
        w_counter <= (w_counter + 1)/2;
      end if;
    end if;    
  end process;
  
  o_counter <= std_logic_vector(to_unsigned (w_counter, COUNT_SIZE));
  o_accumulator <= std_logic_vector(to_unsigned (w_accumulator, ACC_SIZE));
  
end Behavioral;
