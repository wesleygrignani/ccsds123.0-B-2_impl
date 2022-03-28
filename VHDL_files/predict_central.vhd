-----------------------------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.ccsds123_b2_package.all;

entity predict_central is
  port (i_clk           : in  std_logic;
        i_enable        : in  std_logic;
        i_rst           : in  std_logic;
        local_diff_mem  : in  std_logic_vector(DATA_SIZE-1 downto 0);
        weights_mem     : in  std_logic_vector(WEIGHT_SIZE-1 downto 0);
        predict_central : out std_logic_vector(MAX_SIZE-1 downto 0));
end predict_central;

architecture Behavioral of predict_central is

signal w_sum, w_weights_aux, w_localdiff_aux : integer := 0;   

begin

w_weights_aux <= to_integer(signed (weights_mem));
w_localdiff_aux <= to_integer(signed (local_diff_mem));

process(i_clk, i_enable)
begin
  if(i_rst = '1') then
    w_sum <= 0;
  elsif(rising_edge(i_clk) and i_enable = '1') then
    w_sum <= w_sum + (w_weights_aux * w_localdiff_aux);
  end if;
end process;

predict_central <= std_logic_vector(to_signed (w_sum, MAX_SIZE));

end Behavioral;
