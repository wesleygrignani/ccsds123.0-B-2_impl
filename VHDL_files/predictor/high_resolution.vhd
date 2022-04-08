-----------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity high_resolution is
  port ( i_clk             : in  std_logic;
         i_enable          : in  std_logic;
         i_predict_central : in  std_logic_vector(MAX_SIZE-1 downto 0);
         i_local_sum       : in  std_logic_vector(DATA_SIZE-1 downto 0);
         o_high_res        : out std_logic_vector(MAX_SIZE-1 downto 0));
end high_resolution;

architecture Behavioral of high_resolution is

signal w_high_res, w_predict_central_int, w_local_sum_int : integer := 0;

begin

w_predict_central_int <= to_integer(signed (i_predict_central));
w_local_sum_int <= to_integer(signed (i_local_sum));
--w_high_res <= (w_predict_central_int + ((2**OMEGA)*(w_local_sum_int - (4 * SMID))) + (2**(OMEGA+2)*SMID) + ((2**(OMEGA+1))));

process(i_clk, i_enable)
begin
  if(rising_edge(i_clk) and i_enable = '1') then
  w_high_res <= (w_predict_central_int + ((2**OMEGA)*(w_local_sum_int - (4 * SMID))) + (2**(OMEGA+2)*SMID) + ((2**(OMEGA+1))));
    if(w_high_res > ((2**OMEGA+2)*SMAX  + (2**OMEGA+1))) then
      w_high_res <= ((2**OMEGA+2)*SMAX  + (2**OMEGA+1));
    end if;
  end if;
end process;

o_high_res <= std_logic_vector(to_signed(w_high_res, MAX_SIZE));

end Behavioral;
