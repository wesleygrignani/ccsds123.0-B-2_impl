----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_B2_package.all;

entity k_z_calc is
  port (i_clk         : in  std_logic;                                 -- clock signal
        i_enable      : in  std_logic;                                 -- enable signal from fsm
        i_counter     : in  std_logic_vector(COUNT_SIZE-1 downto 0);   -- counter value from z band
        i_accumulator : in  std_logic_vector(ACC_SIZE-1 downto 0);     -- accumulator value from z band
        o_kz          : out std_logic_vector(KZ_SIZE-1 downto 0));     -- k_z constant output
end k_z_calc;

architecture Behavioral of k_z_calc is

signal w_kz, w_counter, w_accumulator : integer := 0; 

begin
  
  w_counter <= to_integer(signed(i_counter));
  w_accumulator <= to_integer(signed(i_accumulator));
  --w_kz <= (w_accumulator + 49 * (w_counter/7)) /  (w_counter);
  
  process(i_clk, i_enable, w_accumulator, w_counter)
  begin
    w_kz <= (w_accumulator + 49 * (w_counter/7)) /  (w_counter);
    if(rising_edge(i_clk) and i_enable = '1') then
      if(w_counter*2 > (w_accumulator + ((49/2**7) * w_counter))) then 
        w_kz <= 0;
      elsif(w_kz > D - 2) then 
        w_kz <= D - 2;
      else
        w_kz <= 0;
      end if;
    end if;
  end process;
  
  o_kz <= std_logic_vector(to_unsigned (w_kz, KZ_SIZE));
   
end Behavioral;
