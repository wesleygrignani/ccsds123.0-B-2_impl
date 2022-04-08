-----------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity double_res is
  port ( i_clk        : in  std_logic;
         i_enable     : in  std_logic;
         i_t          : in  integer range 0 to 255;
         i_sample     : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
         i_neighboor  : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
         i_z          : in  integer range 0 to 5;
         i_high_res   : in  std_logic_vector(MAX_SIZE-1 downto 0);
         o_double_res : out std_logic_vector(MAX_SIZE-1 downto 0));
end double_res;

architecture Behavioral of double_res is

signal w_high_res, w_double_res, w_sample, w_neighboor : integer := 0;

begin

w_high_res <= to_integer(signed(i_high_res));
w_sample <= to_integer(signed(i_sample));
w_neighboor <= to_integer(signed(i_neighboor));

process(i_clk, i_enable, i_z, i_t)
begin
  if(rising_edge(i_clk) and i_enable = '1') then
    if(i_t > 0) then
      w_double_res <= (w_high_res)/(2**(OMEGA+1));
    else --elsif (i_t = 0) then
      if(i_z > 0) then
        w_double_res <= 2*w_neighboor; --previous sample 
      else
        w_double_res <= 2*SMID;
      end if;
    end if;
  end if;
end process;

o_double_res <= std_logic_vector(to_signed(w_double_res, MAX_SIZE));

end Behavioral;
